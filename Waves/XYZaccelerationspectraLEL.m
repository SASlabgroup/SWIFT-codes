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


% Laura's take on input parameters:
% DATA_POINTS = 4096
% WINDOW_POINTS = 512  % Should be 2^N for efficiency
% MERGE = 5  % How many bins of the FFT to merge in reported spectra. Must be odd.
% NFBANDS = 48 % How many frequency bands to report
% FREQ = ??  (Simply used for converting output spectra into units involving Hz)

% 1) In order to meet the nyquist criterion, window_points > 2 * merge * nfbands
% 2) In order for windows to evenly divide into the data, you want
% %  data_points % (window_points/4) == 0
% %  (And the implementation requires data_points >= (5/4) * window_points, but
% %  I don't think that's a fundamental constraint.)


%% parameters

% TODO(LEL): In the C implementation, this will either be a constant or a parameter.
% NOTE(LEL): I don't think that *this* needs to be 2^N ... presumably, the window
%    length should be, and window_pts/4 needs to divide evenly into this.
pts = length(x_input);  % length of the input data (should be 2^N for efficiency)

% QUESTION(LEL): Why do we call `round(fs)` here?
% NOTE(LEL): maybe just directly specify window length in points?
wsecs =  4096/round(fs)/2; % window length in seconds, usually 512 for wave processing ** now dynamic **
merge = 5;   % freq bands to merge in reported spectra, must be odd

nfbands = 48; % number of frequency bands

wpts = round(fs * wsecs); % window length in data points
if rem(wpts,2) ~= 0  % if (wpts % 2 != 0 ) {
    wpts = wpts-1; % make wpts an even number
end

% QUESTION(LEL): Should it be an error/warning if the number of windows doesn't
%    divide evenly? In that case, we'd just be ignoring the last few points...
num_windows = floor( 4*(pts/wpts - 1)+1 ); % number of windows, the 4 comes from a 75% overlap

% TODO(LEL): Confirm with Jim that the intent was if NO windows were available,
%   not that we need 5.
%   I think this is another case where we could do somethign like:
% `static_assert(data_points >= window_points, "Insufficient points in input data to fill window");`
if num_windows <= 1 % Exit early if insufficient data
    fmin = half(9999);
    fmax = half(9999);
    half_XX = half(ones(1,nfbands)*9999);
    half_YY = half(ones(1,nfbands)*9999);
    half_ZZ = half(ones(1,nfbands)*9999);
    return
end

%% frequency resolution
% Not needed any more -- fs cancels out in the nyquist criterion
% check.
% Nyquist = fs / 2;     % highest spectral frequency

% TODO(LEL) Sort this out, (though it probably doesn't matter)
%%f1 = 1/wsecs;    % frequency resolution

% TODO(LEL): Actually probably don't even need to keep the array of raw frequencies
%     around -- you can derive it from the index of the FFT if you know the sampling
%     period.
% Yeah -- this was only being used to compare to merged_freqs and decide which
% to keep. replacing with 1:merge*nfbands worked.
% Initialize it like I would in C...
% rawf = [ f1 : f1 : Nyquist ];  % raw frequency bands
% raw_freqs = zeros(1, wpts/2);
% for idx=1:wpts/2
%     raw_freqs(idx) = idx*f1;
% end
f1 = fs / window_points;

bandwidth = f1*merge;  % freq (Hz) bandwitdh after merging

% f = [ (f1 + bandwidth/2) : bandwidth : Nyquist ];  % frequency vector after merging
% TODO(LEL): Find more intuitive way to express this -- this early return is handling
%    the case where length(merged_freqs) < nfbands, and so we woudl be calculating
%    fewer frequency bands. The matlab code handled that by truncating the array,
%    but I don't want to have variable sized arrays ...
% TODO(LEL): I think f0 needs to be at the center of the cell, not this.
%%f0 = f1 + bandwidth / 2;
f0 = f1 * (1 + merge) / 2;  % arthmetic mean of merged frequencies
% TODO(LEL): Better way to handle case where the bands we've requested go beyond Nyquist?
%   The example code simply returns a shorter array, so I guess we could
%   check for (fs/wpts)*merge*nfbands > fs/w => wpts < 2 * merge * nfbands
% if f0 + bandwidth * (nfbands - 1) > Nyquist % Exit early if merged frequency vector would be too small
% Confirm the requested number of frequency bands is supportable by our data
% (aka all calculated frequencies will be below Nyquist)
% TODO: If this isn't satisfied, could simply return data for fewer nfbands ...
%    I think that the proper way of handling that will depend on how
%    configuration is handled. Either make it a check in the configuration GUI,
%    or a compile-time assert? Maybe try:
%  `static_assert(wpts >= 2 * merge * nfbands, "Window size too short to meet nyquist criteria");`
if window_points < 2 * merge * nfbands
    fmin = half(9999);
    fmax = half(9999);
    half_XX = half(ones(1,nfbands)*9999);
    half_YY = half(ones(1,nfbands)*9999);
    half_ZZ = half(ones(1,nfbands)*9999);
    return
end

merged_freqs = zeros(1, nfbands); % Frequency vector after merging
for idx = 1:nfbands % prune the higher frequencies
    merged_freqs(idx) = f0 + bandwidth*(idx-1);
end
%if merged_freqs(nfbands) < Nyquist
%    "Pruned higher frequencies: ", nfbands, merged_freqs(nfbands), Nyquist
%end

%% initialize spectral ouput, which will accumulate as windows are processed
XX = single(zeros(1, nfbands));
YY = single(zeros(1, nfbands));
ZZ = single(zeros(1, nfbands));

%% Initialize taper and loop variables

taper = zeros(1, window_points);
for idx=1:window_points
    % NOTE(LEL): I think the denom should probably be (window_points + 1)
    %    so neither end point evaluates to 0.
    taper(idx) = sin(idx * pi / window_points);
end

xwin = single(zeros(1, window_points));
ywin = single(zeros(1, window_points));
zwin = single(zeros(1, window_points));

XXwindow = zeros(1, merge * nfbands);
YYwindow = zeros(1, merge * nfbands);
ZZwindow = zeros(1, merge * nfbands);

%% loop thru windows, accumulating spectral results

for win_idx=1:num_windows
    offset = (win_idx - 1) * floor(.25 * window_points);
    for idx=1:window_points
        xwin(idx) = x_input(offset+idx);
        ywin(idx) = y_input(offset+idx);
        zwin(idx) = z_input(offset+idx);
    end

    %% remove the mean

    mean_x = mean(xwin);
    mean_y = mean(ywin);
    mean_z = mean(zwin);
    for idx=1:window_points
        xwin(idx) = xwin(idx) - mean_x;
        ywin(idx) = ywin(idx) - mean_y;
        zwin(idx) = zwin(idx) - mean_z;
    end

    %% taper and rescale (to preserve variance)

    % get original variance of each window
    xvar = var(xwin);
    yvar = var(ywin);
    zvar = var(zwin);

    % apply the taper
    for idx=1:window_points
        xwin(idx) = xwin(idx) * taper(idx);
        ywin(idx) = ywin(idx) * taper(idx);
        zwin(idx) = zwin(idx) * taper(idx);
    end

    % then rescale to regain the same original variance
    new_xvar = var(xwin);
    xwin = xwin * sqrt(xvar / new_xvar);
    new_yvar = var(ywin);
    ywin = ywin * sqrt(yvar / new_yvar);
    new_zvar = var(zwin);
    zwin = zwin * sqrt(zvar / new_zvar);


    %% FFT

    % calculate Fourier coefs (complex values, double sided)
    % overnight the time series variables (to save memory)
    % QUESTION(LEL): Why convert to single precision here?
    % TODO(LEL): I'm not a huge fan of this in-place attempt, since the types WILL be different.
    % xwin= fft(xwin);
    fft_x = fft(xwin);
    fft_y = fft(ywin);
    fft_z = fft(zwin);

    % second half of Matlab's FFT is redundant, so throw it out
    fft_x( round(window_points/2+1):window_points ) = [];
    fft_y( round(window_points/2+1):window_points ) = [];
    fft_z( round(window_points/2+1):window_points ) = [];

    % throw out the mean (first coef) by moving to the end and making it zero
    % xwin = xwin([2:end 1]);
    % ywin = ywin([2:end 1]);
    % zwin = zwin([2:end 1]);
    % UGH THEY RESIZED IT. Can we just ignore those fields??
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
    % only compute for raw frequencies less than the max frequency of interest (to save memory)
    % NOTE(LEL): % This is probably actually worth doing, since it's a
    %      factor of ~4 in array length. However, this is the last remaining
    %      dynamic allocation ... but I think that we could figure out
    %      what the "good" indices are analytically, rather than at run time.
    % QUESTION(LEL): Why are they dividing by that??
    denom = (round(window_points/2) * fs );
    for idx=1:merge*nfbands
        XXwindow(idx) = real(fft_x(idx) .* conj(fft_x(idx))) / denom;
        YYwindow(idx) = real(fft_y(idx) .* conj(fft_y(idx))) / denom;
        ZZwindow(idx) = real(fft_z(idx) .* conj(fft_z(idx))) / denom;
    end

    % accumulate window results and merge neighboring frequency bands (to increase DOFs)
    % NOTE(LEL): The previous code didn't actually do the calculations
    %    for the final bin. Fix this once Jim OK's it.
    xx_merge = zeros(1, merge);
    yy_merge = zeros(1, merge);
    zz_merge = zeros(1, merge);
    for mi = 1 : 1 : nfbands-1 % (length(merged_freqs)-1)
        for idx=1:merge
            xx_merge(idx) = XXwindow((mi-1)*merge + idx);
            yy_merge(idx) = YYwindow((mi-1)*merge + idx);
            zz_merge(idx) = ZZwindow((mi-1)*merge + idx);
        end

        XX(mi) = XX(mi) + mean(xx_merge);
        YY(mi) = YY(mi) + mean(yy_merge);
        ZZ(mi) = ZZ(mi) + mean(zz_merge);
    end


end % close window loop

%% divide accumulated results by number of windows (effectively an ensemble avg)
% XX = XX / num_windows
for idx=1:nfbands
    XX(idx) = XX(idx) / num_windows;
    YY(idx) = YY(idx) / num_windows;
    ZZ(idx) = ZZ(idx) / num_windows;
end


%% format for microSWIFT telemetry output (payload type 52)
fmin = half(min(merged_freqs));
fmax = half(max(merged_freqs));
half_XX = half(XX);
half_YY = half(YY);
half_ZZ = half(ZZ);




% Replace `mean` with arm_mean_f32: (example from Google AI)
% #include "arm_math.h"
% float32_t data_array[] = {1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0, 9.0, 10.0};
% uint32_t num_pts = sizeof(data_array) / sizeof(data_array[0]); // Number of samples
% float32_t result_mean;
% // Parameters: *pSrc (input array), blockSize (number of elements), *pResult (output pointer)
% arm_mean_f32(data_array, num_pts, &result_mean);

% zeros(1, npts);  will be replaced by something like
% float32_t foo[npts]; memset(foo, 0, sizeof(foo));
% or float32-t foo[npts] = {0};


% floor() and round() exist in C; just #include <math.h>