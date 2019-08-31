function [ Hs, Tp, Dp, E, f, a1, b1, a2, b2, check ] = UVZwaves(u,v,z,fs) 

% matlab function to process raw wave velocities (u,v) and heave displacments (z)
%   to estimate wave height, period, direction, directional moments and
%   check factor
%
% Inputs are displacements east [m/s], north [m/s], up [m], and sampling rate [Hz]
%
% For v3 SWIFTs, this assumes that post-processing of the IMU data using
% "rawdiplacements.m" has been completed.
%
% Sampling rate must be at least 1 Hz and the same
% for all variables.  Additionaly,  time series data must 
% have at least 512 points and all be the same size.
%
% Outputs are significat wave height [m], dominant period [s], dominant direction 
% [deg T, using meteorological from which waves are propagating], spectral 
% energy density [m^2/Hz], frequency [Hz], and 
% the normalized spectral moments a1, b1, a2, b2, 
%
% Outputs will be '9999' for invalid results.
%
% Outputs can be supressed, in order, full usage is as follows:
%
%   [ Hs, Tp, Dp, E, f, a1, b1, a2, b2, check ] = XYZwaves(x,y,z,fs) 

% J. Thomson, derived from PUVspectra.m (9/2003)
%             6/2016, adapted from GPSandIMUwaves.m
%             4/2017 adapted again for application to AWAC data
%             5/2018 fixed normalization of directional moments
%             8/2019    add RC filter for z (not just u,v)
%#codegen
  

%% fixed parameters
wsecs = 256;   % window length in seconds, should make 2^N samples
merge = 3;      % freq bands to merge, must be odd?
maxf = .5;       % frequency cutoff for telemetry Hz
   

%% begin processing, if data sufficient
pts = length(z);       % record length in data points

if pts >= 2*wsecs & fs>=.5,  % minimum length and quality for processing

    
%% high-pass RC filter, detrend first

RC = 3.5;

u = detrend(u);
v = detrend(v);
z = detrend(z);

% initialize
ufiltered = u;
vfiltered = v;
zfiltered = z;

alpha = RC / (RC + 1./fs); 

for ui = 2:length(u),
    ufiltered(ui) = alpha * ufiltered(ui-1) + alpha * ( u(ui) - u(ui-1) );
    vfiltered(ui) = alpha * vfiltered(ui-1) + alpha * ( v(ui) - v(ui-1) );
    zfiltered(ui) = alpha * zfiltered(ui-1) + alpha * ( z(ui) - z(ui-1) );
end

u = ufiltered;
v = vfiltered;  
z = zfiltered;

%% break into windows (use 75 percent overlap)
w = round(fs * wsecs);  % window length in data points
if rem(w,2)~=0, w = w-1; else end  % make w an even number
windows = floor( 4*(pts/w - 1)+1 );   % number of windows, the 4 comes from a 75% overlap
dof = 2*windows*merge; % degrees of freedom
% loop to create a matrix of time series, where COLUMN = WINDOW 
uwindow = zeros(w,windows);
vwindow = zeros(w,windows);
zwindow = zeros(w,windows);
for q=1:windows, 
	uwindow(:,q) = u(  (q-1)*(.25*w)+1  :  (q-1)*(.25*w)+w  );  
	vwindow(:,q) = v(  (q-1)*(.25*w)+1  :  (q-1)*(.25*w)+w  );  
  	zwindow(:,q) = z(  (q-1)*(.25*w)+1  :  (q-1)*(.25*w)+w  );  
end

%% detrend individual windows (full series already detrended)
for q=1:windows
uwindow(:,q) = detrend(uwindow(:,q));
vwindow(:,q) = detrend(vwindow(:,q));
zwindow(:,q) = detrend(zwindow(:,q));
end

%% taper and rescale (to preserve variance)
% form taper matrix (columns of taper coef)
taper = sin ( (1:w) * pi/w )' * ones(1,windows); 
% taper each window
uwindowtaper = uwindow .* taper;
vwindowtaper = vwindow .* taper;
zwindowtaper = zwindow .* taper;
% now find the correction factor (comparing old/new variance)
factx = sqrt( var(uwindow) ./ var(uwindowtaper) );
facty = sqrt( var(vwindow) ./ var(vwindowtaper) );
factz = sqrt( var(zwindow) ./ var(zwindowtaper) );
% and correct for the change in variance
% (mult each window by it's variance ratio factor)
uwindowready = (ones(w,1)*factx).* uwindowtaper;
vwindowready = (ones(w,1)*facty).* vwindowtaper;
zwindowready = (ones(w,1)*factz).* zwindowtaper;


%% FFT
% calculate Fourier coefs
Uwindow = fft(uwindowready);
Vwindow = fft(vwindowready);
Zwindow = fft(zwindowready);
% second half of fft is redundant, so throw it out
Uwindow( (w/2+1):w, : ) = [];
Vwindow( (w/2+1):w, : ) = [];
Zwindow( (w/2+1):w, : ) = [];
% throw out the mean (first coef) and add a zero (to make it the right length)  
Uwindow(1,:)=[]; Vwindow(1,:)=[]; Zwindow(1,:)=[]; 
Uwindow(w/2,:)=0; Vwindow(w/2,:)=0; Zwindow(w/2,:)=0; 
% POWER SPECTRA (auto-spectra)
UUwindow = real ( Uwindow .* conj(Uwindow) );
VVwindow = real ( Vwindow .* conj(Vwindow) );
ZZwindow = real ( Zwindow .* conj(Zwindow) );
% CROSS-SPECTRA 
UVwindow = ( Uwindow .* conj(Vwindow) );
UZwindow = ( Uwindow .* conj(Zwindow) );
VZwindow = ( Vwindow .* conj(Zwindow) );


%% merge neighboring freq bands (number of bands to merge is a fixed parameter)
% initialize
UUwindowmerged = zeros(floor(w/(2*merge)),windows);
VVwindowmerged = zeros(floor(w/(2*merge)),windows);
ZZwindowmerged = zeros(floor(w/(2*merge)),windows);
UVwindowmerged = 1i*ones(floor(w/(2*merge)),windows);
UZwindowmerged = 1i*ones(floor(w/(2*merge)),windows);
VZwindowmerged = 1i*ones(floor(w/(2*merge)),windows);

for mi = merge:merge:(w/2) 
	UUwindowmerged(mi/merge,:) = mean( UUwindow((mi-merge+1):mi , : ) );
	VVwindowmerged(mi/merge,:) = mean( VVwindow((mi-merge+1):mi , : ) );
   	ZZwindowmerged(mi/merge,:) = mean( ZZwindow((mi-merge+1):mi , : ) );
	UVwindowmerged(mi/merge,:) = mean( UVwindow((mi-merge+1):mi , : ) );
  	UZwindowmerged(mi/merge,:) = mean( UZwindow((mi-merge+1):mi , : ) );
	VZwindowmerged(mi/merge,:) = mean( VZwindow((mi-merge+1):mi , : ) );
end
% freq range and bandwidth
n = (w/2) / merge;                         % number of f bands
Nyquist = .5 * fs;                % highest spectral frequency 
bandwidth = Nyquist/n ;                    % freq (Hz) bandwitdh
% find middle of each freq band, ONLY WORKS WHEN MERGING ODD NUMBER OF BANDS!
f = 1/(wsecs) + bandwidth/2 + bandwidth.*(0:(n-1)) ; 


%% ensemble average windows together
% take the average of all windows at each freq-band
% and divide by N*samplerate to get power spectral density
% the two is b/c Matlab's fft output is the symmetric FFT, and we did not use the redundant half (so need to multiply the psd by 2)
UU = mean( UUwindowmerged.' ) / (w/2 * fs  );
VV = mean( VVwindowmerged.' ) / (w/2 * fs  );
ZZ = mean( ZZwindowmerged.' ) / (w/2 * fs  );
UV = mean( UVwindowmerged.' ) / (w/2 * fs  ); 
UZ = mean( UZwindowmerged.' ) / (w/2 * fs  ); 
VZ = mean( VZwindowmerged.' ) / (w/2 * fs  ); 


%% auto and cross displacement spectra, assuming deep water
Euu = UU ./ (2 * 3.14 * f).^2;  %[m^2/Hz]
Evv = VV ./ (2 * 3.14 * f).^2;  %[m^2/Hz]
Ezz = ZZ;  %[m^2/Hz]

Quz = imag(UZ); %[m^2/Hz], quadspectrum of vertical and horizontal displacements
Cuz = real(UZ); %[m^2/Hz], cospectrum of vertical and horizontal displacements

Qvz = imag(VZ); %[m^2/Hz], quadspectrum of vertical and horizontal displacements
Cvz = real(VZ); %[m^2/Hz], cospectrum of vertical and horizontal displacements

Cuv = real(UV);  %[m^2/Hz], cospectrum of horizontal displacements

%% check factor for circular orbits

check = (Euu + Evv) ./ Ezz;

%% wave spectral moments 
% wave directions from Kuik et al, JPO, 1988 and Herbers et al, JTech, 2012
a1 = Cuz ./ sqrt( (UU+VV) .* ZZ );  %[], would use Qxz for actual displacements
b1 = Cvz ./ sqrt( (UU+VV) .* ZZ );  %[], would use Qyz for actual displacements
a2 = (UU - VV) ./ (UU + VV);
b2 = 2 .* Cuv ./ ( UU + VV );

%% wave directions
% note that 0 deg is for waves headed towards positive x (EAST, right hand system)
dir1 = atan2(b1,a1) ;  % [rad], 4 quadrant
dir2 = atan2(b2,a2)/2 ; % [rad], only 2 quadrant
spread1 = sqrt( 2 * ( 1 - sqrt(a1.^2 + b2.^2) ) );
spread2 = sqrt( abs( 0.5 - 0.5 .* ( a2.*cos(2.*dir2) + b2.*cos(2.*dir2) )  ));


%% bulk parameters
E = Ezz;

fwaves = f>0.050 & f<1; % frequency cutoff for wave stats, 0.4 is specific to SWIFT hull

E( ~fwaves ) = 0;

% significant wave height
Hs  = 4*sqrt( sum( E(fwaves) ) * bandwidth);

%  energy period
fe = sum( f(fwaves).*E(fwaves) )./sum( E(fwaves) );
[~ , feindex] = min(abs(f-fe));
Ta = 1./fe;

% peak period
[~ , fpindex] = max(Ezz); 
%[~ , fpindex] = max(E);
Tp = 1./f(fpindex);


%% spectral directions
dir = - 180 ./ 3.14 * dir1;  % switch from rad to deg, and CCW to CW (negate)
dir = dir + 90;  % rotate from eastward = 0 to northward  = 0
dir( dir < 0 ) = dir( dir < 0 ) + 360;  % take NW quadrant from negative to 270-360 range
westdirs = dir > 180;
eastdirs = dir < 180;
dir( westdirs ) = dir ( westdirs ) - 180; % take reciprocal such wave direction is FROM, not TOWARDS
dir( eastdirs ) = dir ( eastdirs ) + 180; % take reciprocal such wave direction is FROM, not TOWARDS

% directional spread
spread = 180 ./ 3.14 .* spread1;


%% dominant direction

Dp = dir(fpindex); % dominant (peak) direction, use peak f


%% screen for bad direction estimate,     

inds = fpindex + [-1:1]; % pick neighboring bands
if all(inds>0) & max(inds) <= length(dir), 
    
  dirnoise = std( dir(inds) );

  if dirnoise > 45 ,
      Dp = NaN;
  else
      Dp = Dp;
  end
  
else
    Dp =NaN;
end


%% prune high frequency results
E( f > maxf ) = [];
dir( f > maxf ) = [];
spread( f > maxf ) = [];
a1( f > maxf ) = [];
b1( f > maxf ) = [];
a2( f > maxf ) = [];
b2( f > maxf ) = [];
check( f > maxf ) = [];
f( f > maxf ) = [];


else % if not enough points or sufficent sampling rate or data, give 9999
  
     Hs = NaN;
     Tp = NaN; 
     Dp = NaN; 
     E = NaN; 
     f = NaN;
     a1 = NaN;
     b1 = NaN;
     a2 = NaN;
     b2 = NaN;
     check = NaN;

end


% quality control, with or without check factor 
%   (should only test for check = unity if in deep water!)
%if Tp>20 | nanmedian(check(f>.05)) > 5  |  Hs < 0.1, 
if Tp>20  |  Hs < 0.1, 
    %disp('Bad spectral shape or low signal to noise')
     Hs = NaN;
     Tp = NaN; 
     Dp = NaN; 
     E(:) = NaN; 
     a1(:) = NaN;
     b1(:) = NaN;
     a2(:) = NaN;
     b2(:) = NaN;
     check(:) = NaN;
else 
end

