function [ fmin, fmax, half_XX, half_YY, half_ZZ] = XYZaccelerationspectraLEL(x_input, y_input, z_input, fs)
% matlab function to process linear accelerations (x,y,z) components
%   following the spectral processing steps of microSWIFT wave processing with "NEDwaves"
%
%
% input time series are linear acceleration components x [m/s^2], y [m/s^2], z [m/s^2]
% and sampling rate [Hz], which must be at least 1 Hz
% Input time series data must have at least 1024 points and all be the same size.
%
% Outputs are minimum frequency, maximum frequency, X auto-spectra, Y auto-spectra, Z auto-spectra
%   the actual frequency bands are uniformly spaced between [fmin, fmax]
%   with length to match the auto-spectra
%
% Outputs will be '9999' for invalid results.
%
% Usage is as follows:
%
%   [ fmin, fmax, XX, YY, ZZ] =  XYZaccelerationspectra(x, y, z, fs);
%
%
% J. Thomson,  12/2025 (modified from NEDwaves_memlight, without RC filter, without despike)
%
%#codegen

%% Parameters

% Laura's take on input parameters:
% DATA_POINTS = 4096
% WINDOW_POINTS = 1024  % Should be 2^N for efficiency
% MERGE = 5  % How many bins of the FFT to merge in reported spectra. Must be odd.
% NFBANDS = 48 % How many frequency bands to report
% FREQ = ??  (Simply used for converting output spectra into units involving Hz)

% 1) In order to meet the nyquist criterion, window_points > 2 * merge * nfbands
% 2) In order for windows to evenly divide into the data, you want
% %  data_points % (window_points/4) == 0
% %  (And the implementation requires data_points >= (5/4) * window_points, but
% %  I don't think that's a fundamental constraint.)

data_points = length(x_input);
merge = 5;   % freq bands to merge in reported spectra, must be odd
nfbands = 48; % number of frequency bands

window_points = 2048;
% % TODO: Delete this section as soon as Jim agrees to modify original Matlab code.
% %   (I have to leave it in for now to make results match!)
% window_points = round(2048 * fs / round(fs));
% if rem(window_points, 2) ~= 0
%     window_points = window_points - 1;
% end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Compute derived parameters

window_step = floor(0.25 * window_points);  % 75% overlap between windows
num_windows = floor(data_points / window_step) - 3;

f1 = fs / window_points;
min_freq = f1 * (1 + merge) / 2;
bandwidth = f1*merge;  % freq (Hz) bandwitdh after merging
max_freq = min_freq + (nfbands - 1) * bandwidth;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Check assumptions about input data
assert(rem(merge, 2) == 1);
assert(rem(window_points, 2) == 0);   % Window must be even

if rem(data_points, window_step) ~= 0
    discarded_points = rem(data_points, window_step);
    fprintf("window_length/4 (%f) does not evenly divide data length (%f); will discard %f points.\n", window_step, data_points, discarded_points)
end

% TODO(LEL): Confirm with Jim that the intent was >= 1, not > 1
%   I think this is another case where we could do something like:
% `static_assert(data_points >= window_points, "Insufficient points in input data to fill window");`
assert(num_windows >= 1);  % Need at least one window!

% Confirm that we will have enough points in a window to calculate the
% requested number of frequency components.
% This is unitless check because frequency cancels out:
% max-frequency component <= nyquist frequency
%    (fs / window_points) * (merge * nfbands) <= fs / 2
%    2 * merge * nfbands <= window_points
assert (2 * merge * nfbands <= window_points);


% TODO: For *any* of the early-exit criteria that can't be checked with
%    a static assert, we need to set these values.
if num_windows <= 1 % Exit early if insufficient data
    fmin = half(9999);
    fmax = half(9999);
    half_XX = half(ones(1,nfbands)*9999);
    half_YY = half(ones(1,nfbands)*9999);
    half_ZZ = half(ones(1,nfbands)*9999);
    return
end


f1 = fs / window_points;
min_freq = f1 * (1 + merge) / 2;
bandwidth = f1*merge;  % freq (Hz) bandwitdh after merging
max_freq = min_freq + (nfbands - 1) * bandwidth;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Initialize taper and loop variables

x_window = single(zeros(1, window_points));
y_window = single(zeros(1, window_points));
z_window = single(zeros(1, window_points));

fft_x = zeros(1, window_points);
fft_y = zeros(1, window_points);
fft_z = zeros(1, window_points);

% initialize spectral ouput, which will accumulate as windows
% are processed
XX_bands = single(zeros(1, nfbands));
YY_bands = single(zeros(1, nfbands));
ZZ_bands = single(zeros(1, nfbands));


taper = zeros(1, window_points);
for idx=1:window_points
    % NOTE(LEL): I think the denom should probably be
    %    (window_points + 1)
    %    so neither end point evaluates to 0.
    taper(idx) = sin(idx * pi / window_points);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Loop thru windows, accumulating spectral results

for win_idx=1:num_windows
    offset = (win_idx - 1) * floor(.25 * window_points);
    for idx=1:window_points
        x_window(idx) = x_input(offset+idx);
        y_window(idx) = y_input(offset+idx);
        z_window(idx) = z_input(offset+idx);
    end

    %% Remove the mean

    mean_x = mean(x_window);
    mean_y = mean(y_window);
    mean_z = mean(z_window);
    for idx=1:window_points
        x_window(idx) = x_window(idx) - mean_x;
        y_window(idx) = y_window(idx) - mean_y;
        z_window(idx) = z_window(idx) - mean_z;
    end

    %% Taper and rescale (to preserve variance)

    % Get original variance of each window
    xvar = var(x_window);
    yvar = var(y_window);
    zvar = var(z_window);

    % Apply the taper
    for idx=1:window_points
        x_window(idx) = x_window(idx) * taper(idx);
        y_window(idx) = y_window(idx) * taper(idx);
        z_window(idx) = z_window(idx) * taper(idx);
    end

    % Rescale to regain the same original variance
    new_xvar = var(x_window);
    new_yvar = var(y_window);
    new_zvar = var(z_window);
    for idx=1:window_points
        x_window(idx) = x_window(idx) * sqrt(xvar / new_xvar);
        y_window(idx) = y_window(idx) * sqrt(yvar / new_yvar);
        z_window(idx) = z_window(idx) * sqrt(zvar / new_zvar);
    end


    %% FFT

    % Calculate Fourier coeffs (complex values, double sided)

    fft_x = fft(x_window);
    fft_y = fft(y_window);
    fft_z = fft(z_window);

    % throw out the mean (first coef) by moving to the end and making it zero
    for idx=1:round(window_points/2)-1
        fft_x(idx)  = fft_x(idx+1);
        fft_y(idx)  = fft_y(idx+1);
        fft_z(idx)  = fft_z(idx+1);
    end
    fft_x(round(window_points/2))=0;
    fft_y(round(window_points/2))=0;
    fft_z(round(window_points/2))=0;

    % Calculate the auto-spectra and cross-spectra from this window
    % ** do this before merging frequency bands or ensemble averging windows **

    % These loops combine multiple accumulators from the original code:
    %  XXwindow = ( real ( xwin( rawf < max(f) ) .* conj(xwin( rawf < max(f) )) ) / (round(wpts/2) * fs ) );
    %  XX(mi/merge) = XX(mi/merge) + mean( XXwindow((mi-merge+1):mi) );

    % TODO: Get rid of the `-1` as soon as Jim confirms
    % QUESTION(LEL): Why are they dividing by that??1
    denom = (round(window_points/2) * fs );
    for ii = 1 : 1 : nfbands-1 % Iterate over merged frequency bins
        idx0 = (ii - 1) * merge;
        for jj=1:merge % Iterate over frequency in each bin
            tmpx = real(fft_x(idx0 + jj) * conj(fft_x(idx0 + jj))) / denom;
            tmpy = real(fft_y(idx0 + jj) * conj(fft_y(idx0 + jj))) / denom;
            tmpz = real(fft_z(idx0 + jj) * conj(fft_z(idx0 + jj))) / denom;
            XX_bands(ii) = XX_bands(ii) + tmpx;
            YY_bands(ii) = YY_bands(ii) + tmpy;
            ZZ_bands(ii) = ZZ_bands(ii) + tmpz;
        end
    end
end

%% Finish computing average

% Rather than averaging over merge bins and then again over windows
% like the Matlab implementation did, we just accumulate through
% both loops and divide now.

for idx=1:nfbands
    XX_bands(idx) = XX_bands(idx) / (num_windows * merge);
    YY_bands(idx) = YY_bands(idx) / (num_windows * merge);
    ZZ_bands(idx) = ZZ_bands(idx) / (num_windows * merge);
end


%% format for microSWIFT telemetry output (payload type 55)

fmin = half(min_freq);
fmax = half(max_freq);
half_XX = half(XX_bands);
half_YY = half(YY_bands);
half_ZZ = half(ZZ_bands);



