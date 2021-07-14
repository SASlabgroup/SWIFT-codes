function [ Hs, Tp, Dp, E, f, a1, b1, a2, b2, check ] = XYZwaves(x,y,z,fs) 

% matlab function to read and process raw wave displacments
%   to estimate wave height, period, direction, directional moments and
%   check factor
%
% Inputs are displacements east [m], north [m], up [m], and sampling rate [Hz]
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

% J. Thomson, Jun 2016, adapted from GPSandIMUwaves.m
%
%#codegen
  

%% fixed parameters
wsecs = 256;   % window length in seconds, should make 2^N samples
merge = 3;      % freq bands to merge, must be odd?
maxf = .5;       % frequency cutoff for telemetry Hz
   

%% begin processing, if data sufficient
pts = length(z);       % record length in data points

if pts >= 2*wsecs & fs>=1,  % minimum length and quality for processing


%% break into windows (use 75 percent overlap)
w = round(fs * wsecs);  % window length in data points
if rem(w,2)~=0, w = w-1; else end  % make w an even number
windows = floor( 4*(pts/w - 1)+1 );   % number of windows, the 4 comes from a 75% overlap
dof = 2*windows*merge; % degrees of freedom
% loop to create a matrix of time series, where COLUMN = WINDOW 
xwindow = zeros(w,windows);
ywindow = zeros(w,windows);
zwindow = zeros(w,windows);
for q=1:windows, 
	xwindow(:,q) = x(  (q-1)*(.25*w)+1  :  (q-1)*(.25*w)+w  );  
	ywindow(:,q) = y(  (q-1)*(.25*w)+1  :  (q-1)*(.25*w)+w  );  
  	zwindow(:,q) = z(  (q-1)*(.25*w)+1  :  (q-1)*(.25*w)+w  );  
end

%% detrend individual windows (full series already detrended)
for q=1:windows
xwindow(:,q) = detrend(xwindow(:,q));
ywindow(:,q) = detrend(ywindow(:,q));
zwindow(:,q) = detrend(zwindow(:,q));
end

%% taper and rescale (to preserve variance)
% form taper matrix (columns of taper coef)
taper = sin ( (1:w) * pi/w )' * ones(1,windows); 
% taper each window
xwindowtaper = xwindow .* taper;
ywindowtaper = ywindow .* taper;
zwindowtaper = zwindow .* taper;
% now find the correction factor (comparing old/new variance)
factx = sqrt( var(xwindow) ./ var(xwindowtaper) );
facty = sqrt( var(ywindow) ./ var(ywindowtaper) );
factz = sqrt( var(zwindow) ./ var(zwindowtaper) );
% and correct for the change in variance
% (mult each window by it's variance ratio factor)
xwindowready = (ones(w,1)*factx).* xwindowtaper;
ywindowready = (ones(w,1)*facty).* ywindowtaper;
zwindowready = (ones(w,1)*factz).* zwindowtaper;


%% FFT
% calculate Fourier coefs
Xwindow = fft(xwindowready);
Ywindow = fft(ywindowready);
Zwindow = fft(zwindowready);
% second half of fft is redundant, so throw it out
Xwindow( (w/2+1):w, : ) = [];
Ywindow( (w/2+1):w, : ) = [];
Zwindow( (w/2+1):w, : ) = [];
% throw out the mean (first coef) and add a zero (to make it the right length)  
Xwindow(1,:)=[]; Ywindow(1,:)=[]; Zwindow(1,:)=[]; 
Xwindow(w/2,:)=0; Ywindow(w/2,:)=0; Zwindow(w/2,:)=0; 
% POWER SPECTRA (auto-spectra)
XXwindow = real ( Xwindow .* conj(Xwindow) );
YYwindow = real ( Ywindow .* conj(Ywindow) );
ZZwindow = real ( Zwindow .* conj(Zwindow) );
% CROSS-SPECTRA 
XYwindow = ( Xwindow .* conj(Ywindow) );
XZwindow = ( Xwindow .* conj(Zwindow) );
YZwindow = ( Ywindow .* conj(Zwindow) );


%% merge neighboring freq bands (number of bands to merge is a fixed parameter)
% initialize
XXwindowmerged = zeros(floor(w/(2*merge)),windows);
YYwindowmerged = zeros(floor(w/(2*merge)),windows);
ZZwindowmerged = zeros(floor(w/(2*merge)),windows);
XYwindowmerged = 1i*ones(floor(w/(2*merge)),windows);
XZwindowmerged = 1i*ones(floor(w/(2*merge)),windows);
YZwindowmerged = 1i*ones(floor(w/(2*merge)),windows);

for mi = merge:merge:(w/2) 
	XXwindowmerged(mi/merge,:) = mean( XXwindow((mi-merge+1):mi , : ) );
	YYwindowmerged(mi/merge,:) = mean( YYwindow((mi-merge+1):mi , : ) );
   	ZZwindowmerged(mi/merge,:) = mean( ZZwindow((mi-merge+1):mi , : ) );
	XYwindowmerged(mi/merge,:) = mean( XYwindow((mi-merge+1):mi , : ) );
  	XZwindowmerged(mi/merge,:) = mean( XZwindow((mi-merge+1):mi , : ) );
	YZwindowmerged(mi/merge,:) = mean( YZwindow((mi-merge+1):mi , : ) );
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
XX = mean( XXwindowmerged.' ) / (w/2 * fs  );
YY = mean( YYwindowmerged.' ) / (w/2 * fs  );
ZZ = mean( ZZwindowmerged.' ) / (w/2 * fs  );
XY = mean( XYwindowmerged.' ) / (w/2 * fs  ); 
XZ = mean( XZwindowmerged.' ) / (w/2 * fs  ); 
YZ = mean( YZwindowmerged.' ) / (w/2 * fs  ); 


%% auto and cross displacement spectra 
Exx = XX;  %[m^2/Hz]
Eyy = YY;  %[m^2/Hz]
Ezz = ZZ;  %[m^2/Hz]

Qxz = imag(XZ); %[m^2/Hz], quadspectrum of vertical and horizontal displacements
Cxz = real(XZ); %[m^2/Hz], cospectrum of vertical and horizontal displacements

Qyz = imag(YZ); %[m^2/Hz], quadspectrum of vertical and horizontal displacements
Cyz = real(YZ); %[m^2/Hz], cospectrum of vertical and horizontal displacements

Cxy = real(XY);  %[m^2/Hz], cospectrum of horizontal displacements

%% check factor for circular orbits

check = (Exx + Eyy) ./ Ezz;

%% wave spectral moments 
% wave directions from Kuik et al, JPO, 1988 and Herbers et al, JTech, 2012
a1 = Qxz ./ sqrt( (Exx+Eyy) .* Ezz );  %[], would use Qxz for actual displacements
b1 = Qyz ./ sqrt( (Exx+Eyy) .* Ezz );  %[], would use Qyz for actual displacements
a2 = (Exx - Eyy) ./ (Exx + Eyy);
b2 = 2 .* Cxy ./ ( Exx + Eyy );

%% wave directions
% note that 0 deg is for waves headed towards positive x (EAST, right hand system)
dir1 = atan2(b1,a1) ;  % [rad], 4 quadrant
dir2 = atan2(b2,a2)/2 ; % [rad], only 2 quadrant
spread1 = sqrt( 2 * ( 1 - sqrt(a1.^2 + b1.^2) ) );
spread2 = sqrt( abs( 0.5 - 0.5 .* ( a2.*cos(2.*dir2) + b2.*cos(2.*dir2) )  ));


%% bulk parameters
E = Ezz;

fwaves = f>0.04 & f<maxf; % frequency cutoff for wave stats, 0.4 is specific to SWIFT hull

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
      Dp = 9999;
  else
      Dp = Dp;
  end
  
else
    Dp =9999;
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
  
     Hs = 9999;
     Tp = 9999; 
     Dp = 9999; 
     E = 9999; 
     f = 9999;
     a1 = 9999;
     b1 = 9999;
     a2 = 9999;
     b2 = 9999;
     check = 9999;

end


% quality control, with or without check factor 
%   (should only test for check = unity if in deep water!)
%if Tp>20 | nanmedian(check(f>.05)) > 5  |  Hs < 0.1, 
% if Tp>20  |  Hs < 0.0, 
%     disp('Bad spectral shape or low signal to noise')
%      Hs = 9999;
%      Tp = 9999; 
%      Dp = 9999; 
%      %E(:) = 9999; 
%      a1(:) = 9999;
%      b1(:) = 9999;
%      a2(:) = 9999;
%      b2(:) = 9999;
%      check(:) = 9999;
% else 
% end

end


