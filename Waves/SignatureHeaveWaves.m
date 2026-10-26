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
% It is RC-filtered and integrated twice to heave as in rawdisplacements.m
% (RC path), then passed through SBGwaves exactly like SBG heave. The RC
% filters and trapezoid integration attenuate the result, most strongly
% toward the Nyquist frequency, so the output must be band limited. The
% magnitude proxy also contains the second-order horizontal-acceleration
% term |a_h|^2/(2g), which can bias the low-frequency spectrum high. The
% Willapa driver therefore treats this as a documented scalar fallback, not
% an unbiased replacement for SBG heave.
%
% mleclair (using claude), Oct 2026

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

% SBGwaves needs whole samples per second and one 256 s window after the
% integration trims 50 s from each end.
sample_rate = round(1/(median(diff(time(use)),'omitnan')*86400));
window_samples = 256*sample_rate;
trim_samples = 50*sample_rate;
if ~isfinite(sample_rate) || sample_rate < 2 || ...
        length(use) < window_samples+2*trim_samples
    info.status = "insufficient_data";
    info.samples = length(use);
    info.sample_rate = sample_rate;
    return
end

acceleration = acceleration(use,:)*(gravity/opts.accel_counts_per_g);
vertical_acceleration = vecnorm(acceleration,2,2)-gravity;
heave = integrateToHeave(vertical_acceleration,sample_rate,trim_samples);

% Only the heave spectrum is used; zero horizontal velocities leave the
% directional outputs undefined.
zero = zeros(size(heave));
[~,~,~,heave_energy,frequency] = SBGwaves(zero,zero,heave,sample_rate);

% At 4 Hz the SBGwaves bands are the SBG bands below 2 Hz, so this keeps the
% values and leaves target bands above the Signature Nyquist as NaN.
energy = interp1(frequency,heave_energy,target_frequency);

window_count = floor(4*(length(heave)/window_samples-1)+1);
info.status = "processed";
info.samples = length(heave);
info.sample_rate = sample_rate;
info.window_count = window_count;
info.nominal_dof = 2*window_count*3; % SBGwaves merges three bands

end

function heave = integrateToHeave(acceleration,sample_rate,trim_samples)

% RC high-pass and trapezoid integration to velocity and then to heave, as in
% the RC option of rawdisplacements.m. The first and last 50 s are dropped
% because they carry the filter start-up transient.
RC = 4;
dt = 1/sample_rate;
alpha = RC/(RC+dt);
acceleration = acceleration-mean(acceleration);
velocity = detrend(cumtrapz(rcHighPass(acceleration,alpha))*dt);
heave = cumtrapz(rcHighPass(velocity,alpha))*dt;
heave = heave-mean(heave);
heave = heave(trim_samples+1:end-trim_samples);

end

function filtered = rcHighPass(signal,alpha)

filtered = signal;
for i = 2:length(signal)
    filtered(i) = alpha*filtered(i-1)+alpha*(signal(i)-signal(i-1));
end

end
