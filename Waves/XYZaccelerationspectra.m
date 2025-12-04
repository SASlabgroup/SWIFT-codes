function [ fmin, fmax, XX, YY, ZZ] = XYZaccelerationspectra(x, y, z, fs)

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



%% parameters

pts = length(x);  % length of the input data (should be 2^N for efficiency)

wsecs = 512; % window length in seconds, should make 2^N samples if sampling rate is even integer
merge = 5;   % freq bands to merge, must be odd?
maxf = .5;   % frequency cutoff for telemetry Hz

wpts = round(fs * wsecs); % window length in data points
if rem(wpts,2) ~= 0, wpts = wpts-1; end  % make wpts an even number
windows = floor( 4*(pts/wpts - 1)+1 ); % number of windows, the 4 comes from a 75% overlap
%dof = 2*windows*merge; % degrees of freedom

%% frequency resolution
Nyquist = fs / 2;     % highest spectral frequency
f1 = 1/(wsecs);    % frequency resolution
rawf = [ f1 : f1 : Nyquist ];  % raw frequency bands
bandwidth = f1*merge;  % freq (Hz) bandwitdh after merging
f = [ (f1 + bandwidth/2) : bandwidth : Nyquist ];  % frequency vector after merging
f(f>maxf) = [];  % should end up with length(f) = 51 with maxf=0.5, merge=5, and wsecs = 512

%% initialize spectral ouput, which will accumulate as windows are processed
% length will only be 42 if wsecs = 256, merge = 3, maxf = 0.5 (params above)
XX = single( zeros(1, length(f) ) );
YY = single( zeros(1, length(f) ) );
ZZ = single( zeros(1, length(f) ) );


%% loop thru windows, accumulating spectral results

for q=1:windows
    xwin = x(  (q-1)*floor(.25*wpts)+1  :  (q-1)*floor(.25*wpts)+wpts  );
    ywin = y(  (q-1)*floor(.25*wpts)+1  :  (q-1)*floor(.25*wpts)+wpts  );
    zwin = z(  (q-1)*floor(.25*wpts)+1  :  (q-1)*floor(.25*wpts)+wpts  );

    %% remove the mean

    xwin = xwin - mean(xwin);
    ywin = ywin - mean(ywin);
    zwin = zwin - mean(zwin);


    %% taper and rescale (to preserve variance)

    % get original variance of each window
    xvar = var(xwin);
    yvar = var(ywin);
    zvar = var(zwin);
    % define the taper
    taper = sin ( (1:wpts) * pi/wpts );
    % apply the taper
    xwin = xwin.* taper;
    ywin = ywin.* taper;
    zwin = zwin.* taper;
    % then rescale to regain the same original variance
    xwin = xwin* sqrt( xvar ./ var(xwin) );
    ywin = ywin* sqrt( yvar ./ var(ywin) );
    zwin = zwin* sqrt( zvar ./ var(zwin) );


    %% FFT

    % calculate Fourier coefs (complex values, double sided)
    % overnight the time series variables (to save memory)
    xwin= single(fft(xwin));
    ywin= single(fft(ywin));
    zwin= single(fft(zwin));

    % second half of Matlab's FFT is redundant, so throw it out
    xwin( round(wpts/2+1):wpts ) = [];
    ywin( round(wpts/2+1):wpts ) = [];
    zwin( round(wpts/2+1):wpts ) = [];

    % throw out the mean (first coef) by moving to the end and making it zero
    xwin = xwin([2:end 1]);
    ywin = ywin([2:end 1]);
    zwin = zwin([2:end 1]);
    xwin(end)=0;
    ywin(end)=0;
    zwin(end)=0;

    % Calculate the auto-spectra and cross-spectra from this window
    % ** do this before merging frequency bands or ensemble averging windows **
    % only compute for raw frequencies less than the max frequency of interest (to save memory)
    XXwindow = ( real ( xwin( rawf < maxf ) .* conj(xwin( rawf < maxf )) ) / (round(wpts/2) * fs ) );
    YYwindow = ( real ( ywin( rawf < maxf ) .* conj(ywin( rawf < maxf )) ) / (round(wpts/2) * fs ) );
    ZZwindow = ( real ( zwin( rawf < maxf ) .* conj(zwin( rawf < maxf )) ) / (round(wpts/2) * fs ) );

    % accumulate window results and merge neighboring frequency bands (to increase DOFs)
    for mi = merge : merge : length(f)*merge
        XX(mi/merge) = XX(mi/merge) + mean( XXwindow((mi-merge+1):mi) );
        YY(mi/merge) = YY(mi/merge) + mean( YYwindow((mi-merge+1):mi) );
        ZZ(mi/merge) = ZZ(mi/merge) + mean( ZZwindow((mi-merge+1):mi) );
    end


end % close window loop

%% divide accumulated results by number of windows (effectively an ensemble avg)
XX = XX ./ windows;
YY = YY ./ windows;
ZZ = ZZ ./ windows;


%% format for microSWIFT telemetry output (payload type 52)
fmin = half(min(f));
fmax = half(max(f));
XX = half(XX);
YY = half(YY);
ZZ = half(ZZ);




