function [SWIFT,sinfo,diagnostics] = reprocess_SIGheave(missiondir,opts)

arguments
    missiondir {mustBeTextScalar} % SWIFT mission directory
    opts.fmin (1,1) double {mustBePositive,mustBeFinite} = 0.10 % Lowest band edge, in Hz; 0.05-fmin sets the noise floor
    opts.fmax (1,1) double {mustBePositive,mustBeFinite} = 1.00 % Highest Signature frequency used, in Hz (hull response)
    opts.noise_factor (1,1) double {mustBePositive,mustBeFinite} = 3 % Signal bins exceed this multiple of the noise floor
    opts.accel_counts_per_g (1,1) double {mustBePositive,mustBeFinite} = 16384 % Accelerometer counts per g
    opts.input_SWIFT struct = struct() % Optional in-memory product from preceding SBG reprocessing
    opts.input_sinfo struct = struct() % Provenance paired with input_SWIFT
    opts.save_product (1,1) logical = true % Save the separate fallback variables to L3
end

% Calculate a Signature-accelerometer wave fallback without changing the
% primary SWIFT wave variables. Each burst's heave energy comes from
% SignatureHeaveWaves (|a|-g spectrum through SBGwaves, divided by omega^4)
% on the native SBGwaves grid. A project driver must explicitly promote
% signaturewaves into the canonical fields.
%
% Spectrum: uncalibrated, kept only where it is above the accelerometer
% noise. The burst's noise floor is the median acceleration spectrum over
% 0.05-fmin Hz, where waves carry almost no acceleration. Starting at 0.3 Hz
% the band extends down while the acceleration spectrum is at least
% noise_factor times that floor, but not below fmin; it ends at fmax. Other
% bins are NaN.
%
% Hs: sigwaveheight is the full-band equivalent, the band Hs times the
% median ratio of SBG Hs (the standard product) to SBG Hs over each
% record's band on records that have both. band_sigwaveheight is the band
% Hs itself.
%
% M. LeClair w/ claude, Oct 2026

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

% Records whose SBG waves can be compared, and records to fill.
fixed_band = frequency > opts.fmin & frequency < opts.fmax;
reference_ok = ~reference_is_signature & isfinite(reference_hs) & ...
    reference_hs > 0 & reference_hs < 10; % reject gross SBG failures only
reference_qc = reference_ok & sum(isfinite(reference_energy(:,fixed_band)),2) >= 2;
reference_missing = ~reference_ok | sum(isfinite(reference_energy(:,fixed_band)),2) < 2;

bandwidth = median(diff(frequency));
band_centre = frequency-1/(2*256);           % SBGwaves labels sit half a bin high
noise_bins = frequency > 0.05 & frequency < opts.fmin;
band_start = find(frequency >= 0.3,1);

signature_energy = NaN(nrecord,nfreq);
band_hs = NaN(nrecord,1);
low_edge = NaN(nrecord,1);
noise_floor = NaN(nrecord,1);
energy_period = NaN(nrecord,1);
peak_period = NaN(nrecord,1);
for i = 1:nrecord
    acceleration_spectrum = raw_energy(i,:).*(2*pi*band_centre).^4;
    noise_floor(i) = median(acceleration_spectrum(noise_bins));
    if ~isfinite(noise_floor(i)) || ...
            any(~isfinite(raw_energy(i,frequency >= opts.fmin & frequency < opts.fmax)))
        continue
    end
    signal = acceleration_spectrum >= opts.noise_factor*noise_floor(i);
    j = band_start;
    while signal(j-1) && frequency(j-1) >= opts.fmin
        j = j-1;
    end
    low_edge(i) = frequency(j);
    use = frequency >= low_edge(i) & frequency < opts.fmax;
    signature_energy(i,use) = raw_energy(i,use);
    band_hs(i) = 4*sqrt(sum(raw_energy(i,use))*bandwidth);
    energy_period(i) = sum(raw_energy(i,use))/sum(frequency(use).*raw_energy(i,use));
    [~,peak] = max(raw_energy(i,use));
    band_frequency = frequency(use);
    peak_period(i) = 1/band_frequency(peak);
end

% Band to full-band Hs from the SBG on records with both.
compare = reference_qc & isfinite(band_hs);
reference_band_hs = NaN(nrecord,1);
for i = find(compare)'
    use = isfinite(signature_energy(i,:));
    reference_band_hs(i) = 4*sqrt(sum(reference_energy(i,use))*bandwidth);
end
hs_band_factor = median(reference_hs(compare)./reference_band_hs(compare),'omitnan');
if nnz(compare) < 20 || ~isfinite(hs_band_factor)
    warning('reprocess_SIGheave:FewOverlapRecords', ...
        'Only %d records with both sensors; sigwaveheight is the band Hs.',nnz(compare))
    hs_band_factor = 1;
end
signature_hs = hs_band_factor*band_hs;

fill_candidate = reference_missing & isfinite(signature_hs);
for i = find(isfinite(signature_hs))'
    SWIFT(i).signaturewaves.sigwaveheight = signature_hs(i);
    SWIFT(i).signaturewaves.band_sigwaveheight = band_hs(i);
    SWIFT(i).signaturewaves.hs_band_factor = hs_band_factor;
    SWIFT(i).signaturewaves.peakwaveperiod = peak_period(i);
    SWIFT(i).signaturewaves.energyperiod = energy_period(i);
    SWIFT(i).signaturewaves.energy = signature_energy(i,:);
    SWIFT(i).signaturewaves.freq = frequency;
    SWIFT(i).signaturewaves.dof = nominal_dof(i);
    SWIFT(i).signaturewaves.measured_band = [low_edge(i) opts.fmax];
    SWIFT(i).signaturewaves.source = 'SignatureHeave';
    if fill_candidate(i); status(i) = "fill_candidate"; end
end

params.fmin = opts.fmin;
params.fmax = opts.fmax;
params.noise_factor = opts.noise_factor;
params.hs_band_factor = hs_band_factor;
params.hs_band_factor_records = nnz(compare);
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
sinfo.postproc(ip).flags.low_edge = low_edge;

diagnostics.frequency = frequency;
diagnostics.raw_energy = raw_energy;
diagnostics.signature_energy = signature_energy;
diagnostics.reference_energy = reference_energy;
diagnostics.reference_hs = reference_hs;
diagnostics.reference_is_signature = reference_is_signature;
diagnostics.reference_qc = reference_qc;
diagnostics.fill_candidate = fill_candidate;
diagnostics.signature_hs = signature_hs;
diagnostics.band_hs = band_hs;
diagnostics.reference_band_hs = reference_band_hs;
diagnostics.hs_band_factor = hs_band_factor;
diagnostics.low_edge = low_edge;
diagnostics.noise_floor = noise_floor;
diagnostics.energy_period = energy_period;
diagnostics.peak_period = peak_period;
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
