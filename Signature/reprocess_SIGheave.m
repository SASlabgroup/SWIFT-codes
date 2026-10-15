function [SWIFT,sinfo,diagnostics] = reprocess_SIGheave(missiondir,opts)

arguments
    missiondir {mustBeTextScalar} % SWIFT mission directory
    opts.fmin (1,1) double {mustBePositive,mustBeFinite} = 0.05 % Canonical Hs lower frequency, in Hz
    opts.fmax (1,1) double {mustBePositive,mustBeFinite} = 2.00 % Highest measured Signature frequency, in Hz
    opts.tail_fmax (1,1) double {mustBePositive,mustBeFinite} = 2.50 % Upper frequency of extrapolated tail, in Hz
    opts.tail_anchor (1,2) double {mustBePositive,mustBeFinite} = [1.50 1.90] % Frequencies anchoring the tail, in Hz
    opts.tail_exponent (1,1) double {mustBePositive,mustBeFinite} = 4 % Exponent in E(f) proportional to f^-tail_exponent
    opts.window_seconds (1,1) double {mustBePositive,mustBeFinite} = 256 % Welch window length, in seconds
    opts.accel_counts_per_g (1,1) double {mustBePositive,mustBeFinite} = 16384 % Accelerometer counts per g
    opts.max_reference_hs (1,1) double {mustBePositive,mustBeFinite} = 0.5 % Maximum SBG Hs used for calibration, in m
    opts.calibration_stride (1,1) double {mustBeInteger,mustBePositive} = 5 % Record stride used for calibration
    opts.minimum_calibration_records (1,1) double {mustBeInteger,mustBePositive} = 20 % Required ratios per frequency bin
    opts.input_SWIFT struct = struct() % Optional in-memory product from preceding SBG reprocessing
    opts.input_sinfo struct = struct() % Provenance paired with input_SWIFT
    opts.save_product (1,1) logical = true % Save the separate fallback variables to L3
end

% Calculate a Signature-accelerometer wave fallback without changing the
% primary SWIFT wave variables. The frequency transfer and tail normalization
% are estimated from a calibration subset of native SBG spectra. A project
% driver must explicitly promote signaturewaves into the canonical fields.

if opts.fmax <= opts.fmin || opts.tail_fmax <= opts.fmax || ...
        opts.tail_anchor(1) >= opts.tail_anchor(2) || ...
        opts.tail_anchor(1) <= opts.fmin || opts.tail_anchor(2) >= opts.fmax
    error('reprocess_SIGheave:InvalidBand', ...
        'Frequency and tail limits must be strictly increasing.')
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
            window_seconds=opts.window_seconds, ...
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
tail_band = frequency >= opts.fmax & frequency < opts.tail_fmax;
tail_anchor = frequency >= opts.tail_anchor(1) & ...
    frequency <= opts.tail_anchor(2);
full_band = measured_band | tail_band;
reference_qc = ~reference_is_signature & isfinite(reference_hs) & ...
    reference_hs > 0 & reference_hs < opts.max_reference_hs & ...
    sum(isfinite(reference_energy(:,full_band)),2) >= 2;
calibration_record = reference_qc & ...
    mod((0:nrecord-1)',opts.calibration_stride) == 0;

transfer = NaN(1,nfreq);
calibration_count = zeros(1,nfreq);
for i = find(measured_band)
    ratio = raw_energy(calibration_record,i)./ ...
        reference_energy(calibration_record,i);
    ratio = ratio(isfinite(ratio) & ratio > 0);
    calibration_count(i) = length(ratio);
    if calibration_count(i) >= opts.minimum_calibration_records
        transfer(i) = median(ratio);
    end
end
if ~all(isfinite(transfer(measured_band)))
    error('reprocess_SIGheave:InsufficientCalibration', ...
        'Too few valid SBG/Signature records to calibrate the measured band.')
end
calibrated_energy = raw_energy./transfer;

tail_template = NaN(nrecord,nfreq);
for i = 1:nrecord
    use = tail_anchor & isfinite(calibrated_energy(i,:)) & ...
        calibrated_energy(i,:) > 0;
    if nnz(use) < 2; continue; end
    constant = median(calibrated_energy(i,use).* ...
        frequency(use).^opts.tail_exponent);
    tail_template(i,tail_band) = constant.* ...
        frequency(tail_band).^(-opts.tail_exponent);
end
bandwidth = median(diff(frequency));
actual_tail_variance = sum(reference_energy(:,tail_band),2,'omitnan')*bandwidth;
template_tail_variance = sum(tail_template(:,tail_band),2,'omitnan')*bandwidth;
tail_ratio = actual_tail_variance(calibration_record)./ ...
    template_tail_variance(calibration_record);
tail_ratio = tail_ratio(isfinite(tail_ratio) & tail_ratio > 0);
if length(tail_ratio) < opts.minimum_calibration_records
    error('reprocess_SIGheave:InsufficientTailCalibration', ...
        'Too few valid SBG/Signature records to calibrate the tail.')
end
tail_scale = median(tail_ratio);

signature_energy = NaN(nrecord,nfreq);
signature_energy(:,measured_band) = calibrated_energy(:,measured_band);
signature_energy(:,tail_band) = tail_scale*tail_template(:,tail_band);
signature_hs = NaN(nrecord,1);
energy_period = NaN(nrecord,1);
peak_period = NaN(nrecord,1);
low_frequency_fraction = NaN(nrecord,1);
low_band = frequency > opts.fmin & frequency < 0.10;

for i = 1:nrecord
    use = full_band & isfinite(signature_energy(i,:)) & ...
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
    sum(isfinite(reference_energy(:,full_band)),2) < 2;
fill_candidate = reference_missing & isfinite(signature_hs);
for i = find(isfinite(signature_hs))'
    SWIFT(i).signaturewaves.sigwaveheight = signature_hs(i);
    SWIFT(i).signaturewaves.peakwaveperiod = peak_period(i);
    SWIFT(i).signaturewaves.energyperiod = energy_period(i);
    SWIFT(i).signaturewaves.energy = signature_energy(i,:);
    SWIFT(i).signaturewaves.freq = frequency;
    SWIFT(i).signaturewaves.dof = nominal_dof(i);
    SWIFT(i).signaturewaves.measured_band = [opts.fmin opts.fmax];
    SWIFT(i).signaturewaves.tail_band = [opts.fmax opts.tail_fmax];
    SWIFT(i).signaturewaves.tail_extrapolated = tail_band;
    SWIFT(i).signaturewaves.low_frequency_fraction = ...
        low_frequency_fraction(i);
    SWIFT(i).signaturewaves.source = 'SignatureHeave';
    if fill_candidate(i); status(i) = "fill_candidate"; end
end

params.fmin = opts.fmin;
params.fmax = opts.fmax;
params.tail_fmax = opts.tail_fmax;
params.tail_anchor = opts.tail_anchor;
params.tail_exponent = opts.tail_exponent;
params.tail_scale = tail_scale;
params.tail_calibration_count = length(tail_ratio);
params.window_seconds = opts.window_seconds;
params.accel_counts_per_g = opts.accel_counts_per_g;
params.max_reference_hs = opts.max_reference_hs;
params.calibration_stride = opts.calibration_stride;
params.minimum_calibration_records = opts.minimum_calibration_records;
params.transfer = transfer;
params.calibration_count = calibration_count;

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
sinfo.postproc(ip).flags.calibration_record = calibration_record;
sinfo.postproc(ip).flags.source_file = source_file;
sinfo.postproc(ip).flags.window_count = window_count;
sinfo.postproc(ip).flags.nominal_dof = nominal_dof;

diagnostics.frequency = frequency;
diagnostics.raw_energy = raw_energy;
diagnostics.calibrated_energy = calibrated_energy;
diagnostics.signature_energy = signature_energy;
diagnostics.reference_energy = reference_energy;
diagnostics.reference_hs = reference_hs;
diagnostics.reference_is_signature = reference_is_signature;
diagnostics.reference_qc = reference_qc;
diagnostics.calibration_record = calibration_record;
diagnostics.transfer = transfer;
diagnostics.calibration_count = calibration_count;
diagnostics.tail_template = tail_template;
diagnostics.tail_scale = tail_scale;
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
