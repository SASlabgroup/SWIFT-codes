function [energy,info] = SignatureHeaveWaves(acceleration,time,target_frequency,opts)

arguments
    acceleration {mustBeNumeric} % Signature three-axis accelerometer counts
    time {mustBeNumeric,mustBeVector} % Sample times as MATLAB datenums
    target_frequency {mustBeNumeric,mustBeVector,mustBePositive} % Output frequency-bin centers, in Hz
    opts.window_seconds (1,1) double {mustBePositive,mustBeFinite} = 256 % Welch window length, in seconds
    opts.accel_counts_per_g (1,1) double {mustBePositive,mustBeFinite} = 16384 % Accelerometer counts per g
end

% Estimate scalar elevation energy from the rotation-invariant magnitude of
% the Signature accelerometer. The result contains orientation and
% centripetal contamination at low frequency and must be band limited and
% calibrated before use as a wave product.

gravity = 9.80665;
target_frequency = double(target_frequency(:)');
energy = NaN(size(target_frequency));
info.status = "invalid_input";
info.samples = 0;
info.sample_rate = NaN;
info.window_count = 0;
info.nominal_dof = NaN;

acceleration = double(acceleration);
time = double(time(:));
if size(acceleration,2) ~= 3 && size(acceleration,1) == 3
    acceleration = acceleration';
end
if size(acceleration,2) ~= 3 || length(target_frequency) < 2
    return
end

count = min(size(acceleration,1),length(time));
acceleration = acceleration(1:count,:);
time = time(1:count);
valid = all(isfinite(acceleration),2) & isfinite(time);
valid_index = find(valid);
if isempty(valid_index)
    return
end

% Do not bridge acquisition gaps when selecting data for the spectrum.
run_break = [0; find(diff(valid_index) > 1); length(valid_index)];
run_length = diff(run_break);
[~,longest] = max(run_length);
use = valid_index(run_break(longest)+1:run_break(longest+1));
if length(use) < 2
    return
end

sample_rate = 1/(median(diff(time(use)),'omitnan')*86400);
window_samples = round(opts.window_seconds*sample_rate);
window_samples = window_samples-rem(window_samples,2);
if ~isfinite(sample_rate) || sample_rate < 1 || ...
        length(use) < window_samples || window_samples < 4
    info.status = "insufficient_data";
    info.samples = length(use);
    info.sample_rate = sample_rate;
    return
end

acceleration = acceleration(use,:)*(gravity/opts.accel_counts_per_g);
vertical_acceleration = vecnorm(acceleration,2,2)-gravity;
step = round(window_samples/4);
window_start = 1:step:(length(vertical_acceleration)-window_samples+1);
window_count = length(window_start);
taper = 0.5-0.5*cos(2*pi*(0:window_samples-1)'/window_samples);
taper_power = sum(taper.^2);
acceleration_psd = zeros(window_samples/2+1,window_count);

for i = 1:window_count
    segment = vertical_acceleration( ...
        window_start(i):window_start(i)+window_samples-1);
    segment = detrend(segment,'linear').*taper;
    spectrum = fft(segment,window_samples);
    spectrum = abs(spectrum(1:window_samples/2+1)).^2/ ...
        (sample_rate*taper_power);
    spectrum(2:end-1) = 2*spectrum(2:end-1);
    acceleration_psd(:,i) = spectrum;
end

acceleration_psd = mean(acceleration_psd,2);
frequency = (0:window_samples/2)'*sample_rate/window_samples;
omega = 2*pi*frequency;
elevation_psd = NaN(size(acceleration_psd));
elevation_psd(2:end) = acceleration_psd(2:end)./omega(2:end).^4;

bandwidth = median(diff(target_frequency));
for i = 1:length(target_frequency)
    in_bin = frequency >= target_frequency(i)-bandwidth/2 & ...
        frequency < target_frequency(i)+bandwidth/2;
    if any(in_bin)
        energy(i) = mean(elevation_psd(in_bin),'omitnan');
    end
end

info.status = "processed";
info.samples = length(use);
info.sample_rate = sample_rate;
info.window_count = window_count;
info.nominal_dof = 2*window_count;

end
