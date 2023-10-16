function [ Hs, Tp, Dp, E, fmin, fmax, a1, b1, a2, b2, check] = NEDwaves_memlight(north, east, down, fs)

% matlab function to process GPS velocity components north, east, down
%   to estimate wave height, period, direction, and spectral moments
%   assuming deep-water limit of surface gravity wave dispersion relation
%
% input time series are velocity components north [m/s], east [m/s], down [m/s]
% and sampling rate [Hz], which must be at least 1 Hz
% Input time series data must have at least 512 points and all be the same size.
%
% Outputs are significat wave height [m], dominant period [s], dominant direction
% [deg T, using meteorological from which waves are propagating], spectral
% energy density [m^2/Hz], frequency [Hz], and
% the normalized spectral moments a1, b1, a2, b2,
% and the check factor (ratio of vertical to horizontal motion)
%
% Outputs will be '9999' for invalid results.
%
% Usage is as follows:
%
%   [ Hs, Tp, Dp, E, fmin, fmax, a1, b1, a2, b2, check ] = NEDwaves_memlight(north,east,down,fs);
%
% note that outputs are slightly different than other wave codes
% b/c this matches the half-float precision format of telemetry type 52
% and only uses frequency limits, not full f array
%
% J. Thomson,  12/2022 (modified from GPSwaves)
%
%              1/2023 memory light version... removes filtering, windowing,etc
%                       assumes input data is clean and ready
%
%              6/2023 put windowing back in (as for loop that over-writes)
%                   abandon convention that upper cases is in frequency domain
%
%              9/2023 reverse convention for wave direction and filter twice
%
%              10/2023 fix major bug introduced at 6/2023 wherein raw fft
%              coefficients where merged across neighbor frequencies before
%              calculating auto and cross spectra (i.e., averaging before
%              applying a nonlinear operator)
%
%              10/2023 reintroduce simply despiking
%
%#codegen



%% parameters

pts = length(east);  % length of the input data (should be 2^N for efficiency)

Nstd = 10;   % number of standard deviations to identify spikes
RC = 4;      % time constant [s] for high-pass filter (pass T < 2 pi * RC)
wsecs = 256; % window length in seconds, should make 2^N samples is fs is even
merge = 3;   % freq bands to merge, must be odd?
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
f(f>maxf) = [];  % should end up with length(f) = 42 with maxf=0.5, merge=3, and wsecs = 256

%% initialize spectral ouput, which will accumulate as windows are processed
% length will only be 42 if wsecs = 256, merge = 3, maxf = 0.5 (params above)
UU = single( zeros(1,42) );
VV = single( zeros(1,42) );
WW = single( zeros(1,42) );
UV = single( 1i*zeros(1,42) );
UW = single( 1i*zeros(1,42) );
VW = single( 1i*zeros(1,42) );

%% Despike the full time series

bad = abs(east) >= Nstd * std(east); % logical array of indices for bad points
east(bad) = mean( east(~bad) );
bad = abs(north) >= Nstd * std(north); % logical array of indices for bad points
north(bad) = mean( north(~bad) );
bad = abs(down) >= Nstd * std(down); % logical array of indices for bad points
down(bad) = mean( down(~bad) );

%% loop thru windows, accumulating spectral results

for q=1:windows
    u = east(   (q-1)*floor(.25*wpts)+1  :  (q-1)*floor(.25*wpts)+wpts  );
    v = north(  (q-1)*floor(.25*wpts)+1  :  (q-1)*floor(.25*wpts)+wpts  );
    w = down(   (q-1)*floor(.25*wpts)+1  :  (q-1)*floor(.25*wpts)+wpts  );

    %% remove the mean

    u = u - mean(u);
    v = v - mean(v);
    w = w - mean(w);


    %% high-pass RC filter this window

    alpha = RC / (RC + 1./fs);

    filtereddata = u;
    for ui = 2:length(filtereddata),
        filtereddata(ui) = alpha * filtereddata(ui-1) + alpha * ( u(ui) - u(ui-1) );
    end
    u = filtereddata;

    filtereddata = v;
    for ui = 2:length(filtereddata),
        filtereddata(ui) = alpha * filtereddata(ui-1) + alpha * ( v(ui) - v(ui-1) );
    end
    v = filtereddata;

    filtereddata = w;
    for ui = 2:length(filtereddata),
        filtereddata(ui) = alpha * filtereddata(ui-1) + alpha * ( w(ui) - w(ui-1) );
    end
    w = filtereddata;

    %% taper and rescale (to preserve variance)

    % get original variance of each window
    uvar = var(u);
    vvar = var(v);
    wvar = var(w);
    % define the taper
    taper = sin ( (1:wpts) * pi/wpts );
    % apply the taper
    u = u .* taper;
    v = v .* taper;
    w = w .* taper;
    % then rescale to regain the same original variance
    u = u * sqrt( uvar ./ var(u) );
    v = v * sqrt( vvar ./ var(v) );
    w = w * sqrt( wvar ./ var(w) );


    %% FFT

    % calculate Fourier coefs (complex values, double sided)
    u = single(fft(u));
    v = single(fft(v));
    w = single(fft(w));

    % second half of Matlab's FFT is redundant, so throw it out
    u( round(wpts/2+1):wpts ) = [];
    v( round(wpts/2+1):wpts ) = [];
    w( round(wpts/2+1):wpts ) = [];

    % throw out the mean (first coef) and add a zero (to make it the right length)
    u(1)=[];
    v(1)=[];
    w(1)=[];
    u(round(wpts/2))=0;
    v(round(wpts/2))=0;
    w(round(wpts/2))=0;

    % Calculate the auto-spectra and cross-spectra from this window 
    % ** do this before merging frequency bands or ensemble averging windows **
    % only compute for raw frequencies less than the max frequency of interest (to save memory)
    UUwindow = ( real ( u( rawf < maxf ) .* conj(u( rawf < maxf )) ) / (round(wpts/2) * fs ) );
    VVwindow = ( real ( v( rawf < maxf ) .* conj(v( rawf < maxf )) ) / (round(wpts/2) * fs ) );
    WWwindow = ( real ( w( rawf < maxf ) .* conj(w( rawf < maxf )) ) / (round(wpts/2) * fs ) );
    UVwindow = ( ( u( rawf < maxf ) .* conj(v( rawf < maxf )) ) / (round(wpts/2) * fs ) );
    UWwindow = ( ( u( rawf < maxf ) .* conj(w( rawf < maxf )) ) / (round(wpts/2) * fs ) );
    VWwindow = ( ( v( rawf < maxf ) .* conj(w( rawf < maxf )) ) / (round(wpts/2) * fs ) );

    % accumulate window results and merge neighboring frequency bands (to increase DOFs)
    for mi = merge : merge : length(f)*merge
        UU(mi/merge) = UU(mi/merge) + mean( UUwindow((mi-merge+1):mi) );
        VV(mi/merge) = VV(mi/merge) + mean( VVwindow((mi-merge+1):mi) );
        WW(mi/merge) = WW(mi/merge) + mean( WWwindow((mi-merge+1):mi) );
        UV(mi/merge) = UV(mi/merge) + mean( UVwindow((mi-merge+1):mi) );
        UW(mi/merge) = UW(mi/merge) + mean( UWwindow((mi-merge+1):mi) );
        VW(mi/merge) = VW(mi/merge) + mean( VWwindow((mi-merge+1):mi) );
    end


end % close window loop

%% divide accumulated results by number of windows (effectively an ensemble avg)
UU = UU ./ windows;
VV = VV ./ windows;
WW = WW ./ windows;
UV = UV ./ windows;
UW = UW ./ windows;
VW = VW ./ windows;

%% wave spectral moments
% see definitions from Kuik et al, JPO, 1988 and Herbers et al, JTech, 2012, Thomson et al, J Tech 2018
% save memory by calling the co- and quad spectra inline, rather than making the variables

%Qxz = imag(UW); % quadspectrum of vertical and east horizontal motion
%Cxz = real(UW); % cospectrum of vertical and east horizontal motion
%Qyz = imag(VW); % quadspectrum of vertical and north horizontal motion
%Cyz = real(VW); % cospectrum of vertical and north horizontal motion
%Cxy = real(UV) ./ ( (2*pi*f).^2 );  % cospectrum of east and north motion

a1 = imag(UW) ./ sqrt( (UU+VV).* WW );
b1 = imag(VW) ./ sqrt( (UU+VV).* WW );
a2 = (UU - VV) ./ (UU + VV);
b2 = 2 .* real(UV) ./ ( UU + VV );


%% Scalar energy spectra (a0)

E = ( UU + VV) ./ ( (2*pi*f).^2 ); % assumes perfectly circular deepwater orbits
% E = ( WW ) ./ ( (2*pi*f).^2 ); % arbitrary depth, but more noise?

% use orbit shape as check on quality (=1 in deep water)
check = WW ./ (UU + VV);


%% wave stats
fwaves = f>0.05; % frequency cutoff for wave stats

% significant wave height
Hs  = 4*sqrt( sum( E(fwaves) ) * bandwidth);

%  energy period
fe = sum( f(fwaves).*E(fwaves) )./sum( E(fwaves) );
[~ , feindex] = min(abs(f-fe));
Te = 1./fe;

% peak period
%[~ , fpindex] = max(UU+VV); % can use velocity (picks out more distint peak)
[~ , fpindex] = max(E);
Tp = 1./f(fpindex);

if Tp > 18, % if reasonable peak not found, use centroid
    Tp = double(Te);
    fpindex = feindex;
end


%% wave directions

% peak wave direction, rotated to geographic conventions
Dp = atan2( b1(fpindex), a1(fpindex) ) ;  % [rad], 4 quadrant
Dp = - 180 ./ 3.14 * Dp;  % switch from rad to deg, and CCW to CW (negate)
Dp = Dp + 90;  % rotate from eastward = 0 to northward  = 0
if Dp < 0, Dp = Dp + 360; end % take NW quadrant from negative to 270-360 range
%if Dp > 180, Dp = Dp - 180; end % take reciprocal such wave direction is FROM, not TOWARDS
%if Dp < 180, Dp = Dp + 180; end % take reciprocal such wave direction is FROM, not TOWARDS



%% format for microSWIFT telemetry output (payload type 52)
Hs = half(Hs);
Tp = half(Tp);
Dp = half(Dp);
E = half(E);
fmin = half(min(f));
fmax = half(max(f));
a1 = int8(a1*100);
b1 = int8(b1*100);
a2 = int8(a2*100);
b2 = int8(b2*100);
check = uint8(check*10);




