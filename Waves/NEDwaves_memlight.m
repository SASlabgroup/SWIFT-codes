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
%              1/2023 memory light version... removes filtering, windowing,etc
%                       assumes input data is clean and ready
%              6/2023 put windowing back in (as for loop that over-writes)
%                   abandon convention that upper cases is in frequency domain
%              9/2023 reverse convention for wave direction and filter twice
%
%#codegen



%% parameters

pts = length(east);  % length of the input data (should be 2^N for efficiency)
%fmin = 0.01; % min frequecny for final output, Hz
%fmax = 0.5; % max frequecny for final output, Hz
%nf = 42; % number of frequency bands in final result

RC = 4; % time constant [s] for high-pass filter (pass T < 2 pi * RC)
wsecs = 256;   % window length in seconds, should make 2^N samples is fs is even
merge = 3;      % freq bands to merge, must be odd?
maxf = .5;       % frequency cutoff for telemetry Hz

wpts = round(fs * wsecs); % window length in data points
if rem(wpts,2)~=0,
    wpts = wpts-1;
end  % make wpts an even number
windows = floor( 4*(pts/wpts - 1)+1 );   % number of windows, the 4 comes from a 75% overlap
%dof = 2*windows*merge; % degrees of freedom

%% frequency resolution
Nyquist = fs / 2;     % highest spectral frequency
f1 = 1./(wpts./fs);    % frequency resolution
rawf = linspace(f1, Nyquist, round(wpts/2)); % raw frequency bands
n = (wpts/2) / merge;                         % number of f bands after merging
bandwidth = Nyquist/n ;                    % freq (Hz) bandwitdh after merging
% find middle of each merged freq band, ONLY WORKS WHEN MERGING ODD NUMBER OF BANDS!
f = 1/(wsecs) + bandwidth/2 + bandwidth.*(0:(n-1)) ;

%% initialize spectral ouput, which will accumulate as windows are processed
% length will only be 42 is wsecs = 256, merge = 3, maxf = 0.5 (params above)
UU = single( zeros(1,42) );
VV = single( zeros(1,42) );
WW = single( zeros(1,42) );
UV = single( 1i*zeros(1,42) );
UW = single( 1i*zeros(1,42) );
VW = single( 1i*zeros(1,42) );

%% loop thru windows, accumulating spectral results

for q=1:windows
    u = east(  (q-1)*(.25*wpts)+1  :  (q-1)*(.25*wpts)+wpts  );
    v = north(  (q-1)*(.25*wpts)+1  :  (q-1)*(.25*wpts)+wpts  );
    w = down(  (q-1)*(.25*wpts)+1  :  (q-1)*(.25*wpts)+wpts  );
    
    %% remove the mean
    
    u = u - mean(u);
    v = v - mean(v);
    w = w - mean(w);
    
    
    %% high-pass RC filter, applied twice / ONCE / OFF
    
    alpha = RC / (RC + 1./fs);
    
    % filtereddata = u;
    % for ui = 2:length(filtereddata),
    %    filtereddata(ui) = alpha * filtereddata(ui-1) + alpha * ( u(ui) - u(ui-1) );
    % end
    % u = filtereddata;
    
    % filtereddata = u;
    % for ui = 2:length(filtereddata),
    %    filtereddata(ui) = alpha * filtereddata(ui-1) + alpha * ( u(ui) - u(ui-1) );
    % end
    % u = filtereddata;
    
    % filtereddata = v;
    % for ui = 2:length(filtereddata),
    %    filtereddata(ui) = alpha * filtereddata(ui-1) + alpha * ( v(ui) - v(ui-1) );
    % end
    % v = filtereddata;
    
    % filtereddata = v;
    % for ui = 2:length(filtereddata),
    %    filtereddata(ui) = alpha * filtereddata(ui-1) + alpha * ( v(ui) - v(ui-1) );
    % end
    % v = filtereddata;
    
    % filtereddata = w;
    % for ui = 2:length(filtereddata),
    %    filtereddata(ui) = alpha * filtereddata(ui-1) + alpha * ( w(ui) - w(ui-1) );
    % end
    % w = filtereddata;
    
    % filtereddata = w;
    % for ui = 2:length(filtereddata),
    %    filtereddata(ui) = alpha * filtereddata(ui-1) + alpha * ( w(ui) - w(ui-1) );
    % end
    % w = filtereddata;
    
    %% taper and rescale (to preserve variance)
    
    % get original variance of each
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
    
    % merge frequency bands (moved up to top of code)
    % Nyquist = fs / 2;     % highest spectral frequency
    % f1 = 1./(wpts./fs);    % frequency resolution
    % rawf = linspace(f1, Nyquist, round(wpts/2)); % raw frequency bands
    % n = (wpts/2) / merge;                         % number of f bands after merging
    % bandwidth = Nyquist/n ;                    % freq (Hz) bandwitdh after merging
    % % find middle of each freq band, ONLY WORKS WHEN MERGING ODD NUMBER OF BANDS!
    % f = 1/(wsecs) + bandwidth/2 + bandwidth.*(0:(n-1)) ;
    u = interp1( rawf, u, f);
    v = interp1( rawf, v, f);
    w = interp1( rawf, w, f);
    
    % remove the high frequency tail (to save memory)
    u( f > maxf ) = [];
    v( f > maxf ) = [];
    w( f > maxf ) = [];
    f( f > maxf ) = [];
    
    % accumulate POWER SPECTRAL DENSITY (auto-spectra) from this window
    UU = UU + ( real ( u .* conj(u) ) / (round(wpts/2) * fs ) );
    VV = VV + ( real ( v .* conj(v) ) / (round(wpts/2) * fs ) );
    WW = WW + ( real ( w .* conj(w) ) / (round(wpts/2) * fs ) );
    % accumulate CROSS-SPECTRAL DENSITY from this window
    UV = UV + ( ( u .* conj(v) ) / (round(wpts/2) * fs ) );
    UW = UW + ( ( u .* conj(w) ) / (round(wpts/2) * fs ) );
    VW = VW + ( ( v .* conj(w) ) / (round(wpts/2) * fs ) );
    
end % close window loop

%% divide accumulated results by number of windows (effectively an ensemble avg)
UU = UU ./ windows * merge;
VV = VV ./ windows * merge;
WW = WW ./ windows * merge;
UV = UV ./ windows * merge;
UW = UW ./ windows * merge;
VW = VW ./ windows * merge;


%% wave spectral moments
% see definitions from Kuik et al, JPO, 1988 and Herbers et al, JTech, 2012, Thomson et al, J Tech 2018

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
Hs  = 4*sqrt( sum( E(fwaves) ) * (f(2)-f(1)) );

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




