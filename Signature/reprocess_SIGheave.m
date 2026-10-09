function [SWIFT,sinfo,diagnostics] = reprocess_SIGheave(missiondir,opts)

arguments
    missiondir {mustBeTextScalar} % SWIFT mission directory
    opts.fmin (1,1) double {mustBePositive,mustBeFinite} = 0.10 % Lowest recovered frequency, in Hz
    opts.fmax (1,1) double {mustBePositive,mustBeFinite} = 0.50 % Highest recovered frequency, in Hz
    opts.window_seconds (1,1) double {mustBePositive,mustBeFinite} = 256 % Welch window length, in seconds
    opts.accel_counts_per_g (1,1) double {mustBePositive,mustBeFinite} = 16384 % Accelerometer counts per g
    opts.max_reference_hs (1,1) double {mustBePositive,mustBeFinite} = 0.5 % Maximum SBG Hs used for calibration, in m
    opts.calibration_stride (1,1) double {mustBeInteger,mustBePositive} = 5 % Record stride used for calibration
    opts.minimum_calibration_records (1,1) double {mustBeInteger,mustBePositive} = 20 % Required ratios per frequency bin
    opts.save_product (1,1) logical = true % Save the updated L3 product
end

% Recover scalar, band-limited wave spectra from Signature acceleration when
% the primary SBG wave product is missing. The empirical transfer function
% is deployment specific and is estimated from valid SBG/Signature overlap.

if opts.fmax <= opts.fmin
    error('reprocess_SIGheave:InvalidBand','fmax must exceed fmin.')
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
loaded = load(fullfile(source.folder,source.name),'SWIFT','sinfo');
SWIFT = loaded.SWIFT;
sinfo = loaded.sinfo;

nrecord = length(SWIFT);
frequency = [];
for i = 1:nrecord
    if isfield(SWIFT(i),'wavespectra') && ...
            isfield(SWIFT(i).wavespectra,'freq') && ...
            length(SWIFT(i).wavespectra.freq) > 1
        frequency = double(SWIFT(i).wavespectra.freq(:)');
        break
    end
end
if isempty(frequency)
    error('reprocess_SIGheave:MissingFrequency', ...
        'The source product has no wave-frequency grid.')
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
            isfield(SWIFT(i).wavespectra,'freq') && ...
            isfield(SWIFT(i).wavespectra,'energy')
        if isfield(SWIFT(i).wavespectra,'source') && ...
                strcmpi(string(SWIFT(i).wavespectra.source),'SignatureHeave')
            reference_is_signature(i) = true;
        end
        this_frequency = double(SWIFT(i).wavespectra.freq(:)');
        this_energy = double(SWIFT(i).wavespectra.energy(:)');
        if length(this_frequency) == nfreq && length(this_energy) == nfreq && ...
                all(abs(this_frequency-frequency) < 1e-8 | ...
                (isnan(this_frequency) & isnan(frequency)))
            reference_energy(i,:) = this_energy;
        end
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
    if isempty(match)
        match = partial;
    end
    if isempty(match)
        continue
    end
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

waveband = frequency > opts.fmin & frequency < opts.fmax;
reference_qc = ~reference_is_signature & isfinite(reference_hs) & ...
    reference_hs > 0 & ...
    reference_hs < opts.max_reference_hs & ...
    sum(isfinite(reference_energy(:,waveband)),2) >= 2;
calibration_record = reference_qc & ...
    mod((0:nrecord-1)',opts.calibration_stride) == 0;

transfer = NaN(1,nfreq);
calibration_count = zeros(1,nfreq);
for i = find(waveband)
    ratio = raw_energy(calibration_record,i)./ ...
        reference_energy(calibration_record,i);
    ratio = ratio(isfinite(ratio) & ratio > 0);
    calibration_count(i) = length(ratio);
    if calibration_count(i) >= opts.minimum_calibration_records
        transfer(i) = median(ratio);
    end
end
if ~all(isfinite(transfer(waveband)))
    error('reprocess_SIGheave:InsufficientCalibration', ...
        'Too few valid SBG/Signature records to calibrate the full band.')
end
calibrated_energy = raw_energy./transfer;

reference_missing = reference_is_signature | ~isfinite(reference_hs) | ...
    reference_hs <= 0 | reference_hs >= 10 | ...
    sum(isfinite(reference_energy(:,waveband)),2) < 2;
recovered = false(nrecord,1);
band_hs = NaN(nrecord,1);
energy_period = NaN(nrecord,1);
peak_period = NaN(nrecord,1);

for i = 1:nrecord
    use = waveband & isfinite(calibrated_energy(i,:)) & ...
        calibrated_energy(i,:) >= 0;
    if nnz(use) < 2
        continue
    end
    variance = trapz(frequency(use),calibrated_energy(i,use));
    if ~isfinite(variance) || variance <= 0
        continue
    end
    band_hs(i) = 4*sqrt(variance);
    mean_frequency = trapz(frequency(use), ...
        frequency(use).*calibrated_energy(i,use))/variance;
    energy_period(i) = 1/mean_frequency;
    band_frequency = frequency(use);
    band_energy = calibrated_energy(i,use);
    [~,peak] = max(band_energy);
    peak_period(i) = 1/band_frequency(peak);
end

for i = find(reference_missing & isfinite(band_hs))'
    use = waveband & isfinite(calibrated_energy(i,:)) & ...
        calibrated_energy(i,:) >= 0;
    if ~isfield(SWIFT(i),'wavespectra') || ...
            ~isfield(SWIFT(i).wavespectra,'freq') || ...
            length(SWIFT(i).wavespectra.freq) ~= nfreq
        SWIFT(i).wavespectra.freq = frequency;
    end
    original_size = size(SWIFT(i).wavespectra.freq);
    replacement_energy = NaN(size(frequency));
    replacement_energy(use) = calibrated_energy(i,use);
    SWIFT(i).sigwaveheight = band_hs(i);
    SWIFT(i).peakwaveperiod = peak_period(i);
    SWIFT(i).peakwavedirT = NaN;
    SWIFT(i).wavespectra.energy = reshape(replacement_energy,original_size);
    SWIFT(i).wavespectra.a1 = NaN(original_size);
    SWIFT(i).wavespectra.b1 = NaN(original_size);
    SWIFT(i).wavespectra.a2 = NaN(original_size);
    SWIFT(i).wavespectra.b2 = NaN(original_size);
    SWIFT(i).wavespectra.check = NaN(original_size);
    SWIFT(i).wavespectra.dof = nominal_dof(i);
    SWIFT(i).wavespectra.source = 'SignatureHeave';
    SWIFT(i).wavespectra.band = [opts.fmin opts.fmax];
    recovered(i) = true;
    status(i) = "recovered";
end

params.fmin = opts.fmin;
params.fmax = opts.fmax;
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
sinfo.postproc(ip).flags.recovered = recovered;
sinfo.postproc(ip).flags.calibration_record = calibration_record;

diagnostics.frequency = frequency;
diagnostics.raw_energy = raw_energy;
diagnostics.calibrated_energy = calibrated_energy;
diagnostics.reference_energy = reference_energy;
diagnostics.reference_hs = reference_hs;
diagnostics.reference_is_signature = reference_is_signature;
diagnostics.reference_qc = reference_qc;
diagnostics.calibration_record = calibration_record;
diagnostics.transfer = transfer;
diagnostics.calibration_count = calibration_count;
diagnostics.recovered = recovered;
diagnostics.band_hs = band_hs;
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
