function [SWIFT,sinfo,diagnostics] = reprocess_SIGheave(missiondir,opts)

arguments
    missiondir {mustBeTextScalar} % SWIFT mission directory
    opts.fmin (1,1) double {mustBePositive,mustBeFinite} = 0.05 % Canonical Hs lower frequency, in Hz
    opts.fmax (1,1) double {mustBePositive,mustBeFinite} = 1.00 % Highest Signature frequency used, in Hz (above the hull natural frequency)
    opts.accel_counts_per_g (1,1) double {mustBePositive,mustBeFinite} = 16384 % Accelerometer counts per g
    opts.input_SWIFT struct = struct() % Optional in-memory product from preceding SBG reprocessing
    opts.input_sinfo struct = struct() % Provenance paired with input_SWIFT
    opts.save_product (1,1) logical = true % Save the separate fallback variables to L3
end

% Calculate a Signature-accelerometer wave fallback without changing the
% primary SWIFT wave variables. This is the uncalibrated 0.05--1 Hz method
% adopted after the spectral-method comparison: energy above the hull's
% approximate 1 Hz natural frequency is discarded, and no empirical SBG
% transfer or extrapolated tail is applied. A project driver must explicitly
% promote signaturewaves into the canonical fields.
%
% mleclair (using claude), Oct 2026

if opts.fmax <= opts.fmin
    error('reprocess_SIGheave:InvalidBand', ...
        'fmax must be greater than fmin.')
end

missiondir = char(missiondir);
l3file = dir(fullfile(missiondir,'*SWIFT*L3.mat'));
l2file = dir(fullfile(missiondir,'*SWIFT*L2.mat'));
l3file = l3file(~startsWith({l3file.name},'._'));
l2file = l2file(~startsWith({l2file.name},'._'));
if ~isempty(l3file)
    source = l3file(1);
elseif ~isempty(l2file)
    source = l2file(1);
else
    error('reprocess_SIGheave:MissingProduct', ...
        'No L2 or L3 product found in %s.',missiondir)
end
if isempty(fieldnames(opts.input_SWIFT))
    loaded = load(fullfile(source.folder,source.name),'SWIFT','sinfo');
    SWIFT = loaded.SWIFT;
    sinfo = loaded.sinfo;
else
    if isempty(fieldnames(opts.input_sinfo))
        error('reprocess_SIGheave:MissingInputInfo', ...
            'input_sinfo is required with input_SWIFT.')
    end
    SWIFT = opts.input_SWIFT;
    sinfo = opts.input_sinfo;
end

nrecord = length(SWIFT);
frequency = [];
for i = 1:nrecord
    if isfield(SWIFT(i),'sbgwaves') && ...
            isfield(SWIFT(i).sbgwaves,'freq') && ...
            length(SWIFT(i).sbgwaves.freq) > 1
        frequency = double(SWIFT(i).sbgwaves.freq(:)');
        break
    end
end
if isempty(frequency)
    error('reprocess_SIGheave:MissingNativeSBG', ...
        ['Native SBG spectra are required. Run the current reprocess_SBG ' ...
        'before reprocess_SIGheave.'])
end

nfreq = length(frequency);
reference_energy = NaN(nrecord,nfreq);
reference_hs = NaN(nrecord,1);
reference_is_signature = false(nrecord,1);
for i = 1:nrecord
    if isfield(SWIFT(i),'sigwaveheight') && ...
            ~isempty(SWIFT(i).sigwaveheight)
        reference_hs(i) = double(SWIFT(i).sigwaveheight);
    end
    if isfield(SWIFT(i),'wavespectra') && ...
            isfield(SWIFT(i).wavespectra,'source') && ...
            strcmpi(string(SWIFT(i).wavespectra.source),'SignatureHeave')
        reference_is_signature(i) = true;
    end
    if ~isfield(SWIFT(i),'sbgwaves') || ...
            ~isfield(SWIFT(i).sbgwaves,'freq') || ...
            ~isfield(SWIFT(i).sbgwaves,'energy')
        continue
    end
    this_frequency = double(SWIFT(i).sbgwaves.freq(:)');
    this_energy = double(SWIFT(i).sbgwaves.energy(:)');
    if length(this_frequency) == nfreq && length(this_energy) == nfreq && ...
            all(abs(this_frequency-frequency) < 1e-8)
        reference_energy(i,:) = this_energy;
    end
end

sigfiles = dir(fullfile(missiondir,'SIG','Raw','**','SWIFT*_SIG_*.mat'));
sigfiles = sigfiles(~startsWith({sigfiles.name},'._'));
signames = string({sigfiles.name});
raw_energy = NaN(nrecord,nfreq);
source_file = strings(nrecord,1);
status = repmat("no_signature_file",nrecord,1);
sample_count = NaN(nrecord,1);
sample_rate = NaN(nrecord,1);
window_count = NaN(nrecord,1);
nominal_dof = NaN(nrecord,1);

for i = 1:nrecord
    burst_id = string(SWIFT(i).burstID);
    exact = find(endsWith(signames,"_SIG_"+burst_id+".mat"));
    partial = find(endsWith(signames,"_SIG_"+burst_id+"_partial.mat"));
    match = exact;
    if isempty(match); match = partial; end
    if isempty(match); continue; end
    if length(match) > 1
        [~,largest] = max([sigfiles(match).bytes]);
        match = match(largest);
    else
        match = match(1);
    end
    source_file(i) = string(fullfile(sigfiles(match).folder,sigfiles(match).name));

    try
        raw = load(char(source_file(i)),'burst');
        if ~isfield(raw,'burst') || ~isfield(raw.burst,'Accelerometer') || ...
                ~isfield(raw.burst,'time')
            status(i) = "missing_acceleration";
            continue
        end
        [raw_energy(i,:),info] = SignatureHeaveWaves( ...
            raw.burst.Accelerometer,raw.burst.time,frequency, ...
            accel_counts_per_g=opts.accel_counts_per_g);
        status(i) = info.status;
        sample_count(i) = info.samples;
        sample_rate(i) = info.sample_rate;
        window_count(i) = info.window_count;
        nominal_dof(i) = info.nominal_dof;
    catch ME
        status(i) = "processing_error:"+string(ME.identifier);
    end
end

measured_band = frequency > opts.fmin & frequency < opts.fmax;
reference_qc = ~reference_is_signature & isfinite(reference_hs) & ...
    reference_hs > 0 & reference_hs < 10 & ... % reject gross SBG failures only
    sum(isfinite(reference_energy(:,measured_band)),2) >= 2;

bandwidth = median(diff(frequency));

signature_energy = NaN(nrecord,nfreq);
signature_energy(:,measured_band) = raw_energy(:,measured_band);
signature_hs = NaN(nrecord,1);
energy_period = NaN(nrecord,1);
peak_period = NaN(nrecord,1);
low_frequency_fraction = NaN(nrecord,1);
low_band = frequency > opts.fmin & frequency < 0.10;

for i = 1:nrecord
    use = measured_band & isfinite(signature_energy(i,:)) & ...
        signature_energy(i,:) >= 0;
    if nnz(use) < 2 || ~all(isfinite(signature_energy(i,measured_band)))
        continue
    end
    variance = sum(signature_energy(i,use))*bandwidth;
    if ~isfinite(variance) || variance <= 0; continue; end
    signature_hs(i) = 4*sqrt(variance);
    mean_frequency = sum(frequency(use).*signature_energy(i,use))/ ...
        sum(signature_energy(i,use));
    energy_period(i) = 1/mean_frequency;
    band_frequency = frequency(use);
    band_energy = signature_energy(i,use);
    [~,peak] = max(band_energy);
    peak_period(i) = 1/band_frequency(peak);
    low_frequency_fraction(i) = ...
        sum(signature_energy(i,low_band))*bandwidth/variance;
end

reference_missing = reference_is_signature | ~isfinite(reference_hs) | ...
    reference_hs <= 0 | reference_hs >= 10 | ...
    sum(isfinite(reference_energy(:,measured_band)),2) < 2;
fill_candidate = reference_missing & isfinite(signature_hs);
for i = find(isfinite(signature_hs))'
    SWIFT(i).signaturewaves.sigwaveheight = signature_hs(i);
    SWIFT(i).signaturewaves.peakwaveperiod = peak_period(i);
    SWIFT(i).signaturewaves.energyperiod = energy_period(i);
    SWIFT(i).signaturewaves.energy = signature_energy(i,:);
    SWIFT(i).signaturewaves.freq = frequency;
    SWIFT(i).signaturewaves.dof = nominal_dof(i);
    SWIFT(i).signaturewaves.measured_band = [opts.fmin opts.fmax];
    SWIFT(i).signaturewaves.low_frequency_fraction = ...
        low_frequency_fraction(i);
    SWIFT(i).signaturewaves.source = 'SignatureHeave';
    if fill_candidate(i); status(i) = "fill_candidate"; end
end

params.fmin = opts.fmin;
params.fmax = opts.fmax;
params.accel_counts_per_g = opts.accel_counts_per_g;

if isfield(sinfo,'postproc')
    ip = length(sinfo.postproc)+1;
else
    sinfo.postproc = struct;
    ip = 1;
end
sinfo.postproc(ip).type = 'SignatureHeave';
sinfo.postproc(ip).usr = getenv('username');
sinfo.postproc(ip).time = string(datetime('now'));
sinfo.postproc(ip).params = params;
sinfo.postproc(ip).flags.status = status;
sinfo.postproc(ip).flags.fill_candidate = fill_candidate;
sinfo.postproc(ip).flags.source_file = source_file;
sinfo.postproc(ip).flags.window_count = window_count;
sinfo.postproc(ip).flags.nominal_dof = nominal_dof;

diagnostics.frequency = frequency;
diagnostics.raw_energy = raw_energy;
diagnostics.signature_energy = signature_energy;
diagnostics.reference_energy = reference_energy;
diagnostics.reference_hs = reference_hs;
diagnostics.reference_is_signature = reference_is_signature;
diagnostics.reference_qc = reference_qc;
diagnostics.fill_candidate = fill_candidate;
diagnostics.recovered = fill_candidate;
diagnostics.signature_hs = signature_hs;
diagnostics.canonical_hs = signature_hs;
diagnostics.band_hs = signature_hs;
diagnostics.energy_period = energy_period;
diagnostics.peak_period = peak_period;
diagnostics.low_frequency_fraction = low_frequency_fraction;
diagnostics.status = status;
diagnostics.source_file = source_file;
diagnostics.sample_count = sample_count;
diagnostics.sample_rate = sample_rate;
diagnostics.window_count = window_count;
diagnostics.nominal_dof = nominal_dof;
diagnostics.time = [SWIFT.time]';
diagnostics.burst_id = string({SWIFT.burstID})';

if opts.save_product
    output_file = fullfile(source.folder,[source.name(1:end-6) 'L3.mat']);
    save(output_file,'SWIFT','sinfo')
end

end
