function [energy,info] = SignatureHeaveWaves(acceleration,time,target_frequency,opts)

arguments
    acceleration {mustBeNumeric} % Signature three-axis accelerometer counts
    time {mustBeNumeric,mustBeVector} % Sample times as MATLAB datenums
    target_frequency {mustBeNumeric,mustBeVector,mustBePositive} % Output frequency-bin centers, in Hz
    opts.accel_counts_per_g (1,1) double {mustBePositive,mustBeFinite} = 16384 % Accelerometer counts per g
end

% Estimate heave energy from the Signature accelerometer. The magnitude of
% the sensor-frame acceleration minus g is the vertical acceleration to first
% order in tilt, so the unreliable Signature AHRS orientation is not needed.
% Its spectrum is computed by SBGwaves, the standard SBG heave processing,
% and divided by (2*pi*f)^4 to give heave energy. SBGwaves labels each
% merged band half a raw bin high, so the division uses the true band centre
% (label - 1/(2*256 s)); at the labels it would bias the energy ~7% low at
% 0.12 Hz. Accelerometer noise divided by f^4 dominates at low frequency and
% the hull does not follow the surface above ~1 Hz, so callers must band
% limit the output. The second-order term |a_h|^2/(2g) of the magnitude
% proxy is ~1% of Hs (tested against the exact earth-vertical acceleration).
%
% M. LeClair w/ claude, Oct 2026

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

% SBGwaves needs whole samples per second and one 256 s window.
sample_rate = round(1/(median(diff(time(use)),'omitnan')*86400));
window_samples = 256*sample_rate;
if ~isfinite(sample_rate) || sample_rate < 2 || ...
        length(use) < window_samples
    info.status = "insufficient_data";
    info.samples = length(use);
    info.sample_rate = sample_rate;
    return
end

acceleration = acceleration(use,:)*(gravity/opts.accel_counts_per_g);
vertical_acceleration = vecnorm(acceleration,2,2)-gravity;

% Only the vertical spectrum is used; zero horizontal velocities leave the
% directional outputs undefined.
zero = zeros(size(vertical_acceleration));
[~,~,~,acceleration_energy,frequency] = SBGwaves(zero,zero, ...
    vertical_acceleration,sample_rate);
band_centre = frequency-1/(2*256);
heave_energy = acceleration_energy./(2*pi*band_centre).^4;

% At 4 Hz the SBGwaves bands are the SBG bands below 2 Hz, so this keeps the
% values and leaves target bands above the Signature Nyquist as NaN.
energy = interp1(frequency,heave_energy,target_frequency);

window_count = floor(4*(length(vertical_acceleration)/window_samples-1)+1);
info.status = "processed";
info.samples = length(vertical_acceleration);
info.sample_rate = sample_rate;
info.window_count = window_count;
info.nominal_dof = 2*window_count*3; % SBGwaves merges three bands

end
