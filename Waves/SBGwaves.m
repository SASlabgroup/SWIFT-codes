function [ Hs, Tp, Dp, E, f, a1, b1, a2, b2, check ] = SBGwaves(u,v,heave,fs) 

% matlab function to read and process SBG senor data (GPS velocities and heave)
%   to estimate wave height, period, direction, and spectral moments
%   assuming deep-water limit of surface gravity wave dispersion relation
%
% Inputs are east velocity [m/s], north velocity [m/s], vertical heave [m, positive down]
% sampling rate [Hz]
%
% Sampling rate must be at least 1 Hz and the same for all variables.  
% Additionaly, input time series data must have at least 512 points and all be the same size.
%
% Outputs are significat wave height [m], dominant period [s], dominant direction 
% [deg T, using meteorological from which waves are propagating], spectral 
% energy density [m^2/Hz], frequency [Hz],  
% the normalized spectral moments a1, b1, a2, b2, 
% and the spectral check factor (ratio of heave to sway + surge)
%
% Outputs will be '9999' for invalid results.
%
% Outputs can be supressed, in order, thus full usage is as follows:
%
%   [ Hs, Tp, Dp, E, f, a1, b1, a2, b2, check ] = SBGwaves(u,v,heave,fs); 
%
%
% J. Thomson,  10/2016 (adapated from GPSandIMUwaves_v6)
%              11/2016, M. Schwendeman:  (constant input/output vector sizes, 
%                   fixed increase in Uwindow size by indexing)
%               10/2017, fixed normalization of cross-spectra (affects a1,b1 moments)
%                       and added RC filter to GPS velocities (heave already filtered)
%               1/2018  add RC filter to heave also (helps a little in small wind-waves)       
% 
%#codegen
  

%% fixed parameters
wsecs = 256;   % window length in seconds, should make 2^N samples
merge = 3;      % freq bands to merge, must be odd?
maxf = 2;       % frequency cutoff for telemetry Hz
recip = true;   % flip wave directions (but not moments)
RC = 3.5;   % RC fitler... cuttoff freq is 1/(2*pi*RC), so nominal value is RC = 3.5
fmin = 0.05;  % lower frequency limit (usually 0.05 Hz)
fmax = 1;   % upper frequency limit (usually 1 Hz)

%% begin processing, if data sufficient
pts = length(u);       % record length in data points

if pts >= 2*wsecs && fs>1,  % minimum length and sampling for processing

    
%% high-pass filter the GPS velocities

% initialize
ufiltered = u;
vfiltered = v;
heavefiltered = heave;

alpha = RC / (RC + 1./fs); 

for ui = 2:length(u),
    ufiltered(ui) = alpha * ufiltered(ui-1) + alpha * ( u(ui) - u(ui-1) );
    vfiltered(ui) = alpha * vfiltered(ui-1) + alpha * ( v(ui) - v(ui-1) );
    heavefiltered(ui) = alpha * heavefiltered(ui-1) + alpha * ( heave(ui) - heave(ui-1) );
end

u = ufiltered;
v = vfiltered;
heave = heavefiltered;

    
%% break into windows (use 75 percent overlap)
w = round(fs * wsecs);  % window length in data points
if rem(w,2)~=0, w = w-1; else end  % make w an even number
windows = floor( 4*(pts/w - 1)+1 );   % number of windows, the 4 comes from a 75% overlap
dof = 2*windows*merge; % degrees of freedom
% loop to create a matrix of time series, where COLUMN = WINDOW 
uwindow = zeros(w,windows);
vwindow = zeros(w,windows);
heavewindow = zeros(w,windows);
for q=1:windows, 
	uwindow(:,q) = u(  (q-1)*(.25*w)+1  :  (q-1)*(.25*w)+w  );  
	vwindow(:,q) = v(  (q-1)*(.25*w)+1  :  (q-1)*(.25*w)+w  );  
  	heavewindow(:,q) = heave(  (q-1)*(.25*w)+1  :  (q-1)*(.25*w)+w  );  
end

%% detrend individual windows 
for q=1:windows
uwindow(:,q) = detrend(uwindow(:,q));
vwindow(:,q) = detrend(vwindow(:,q));
heavewindow(:,q) = detrend(heavewindow(:,q));
end

%% taper and rescale (to preserve variance)
% form taper matrix (columns of taper coef)
taper = sin ( (1:w) * pi/w )' * ones(1,windows); 
% taper each window
uwindowtaper = uwindow .* taper;
vwindowtaper = vwindow .* taper;
heavewindowtaper = heavewindow .* taper;
% now find the correction factor (comparing old/new variance)
factu = sqrt( var(uwindow) ./ var(uwindowtaper) );
factv = sqrt( var(vwindow) ./ var(vwindowtaper) );
factheave = sqrt( var(heavewindow) ./ var(heavewindowtaper) );
% and correct for the change in variance
% (mult each window by it's variance ratio factor)
uwindowready = (ones(w,1)*factu).* uwindowtaper;
vwindowready = (ones(w,1)*factv).* vwindowtaper;
heavewindowready = (ones(w,1)*factheave).* heavewindowtaper;


%% FFT, use capital letters to not spectral version of variables
% calculate Fourier coefs
Uwindow = fft(uwindowready);
Vwindow = fft(vwindowready);
Zwindow = fft(heavewindowready);
% second half of fft is redundant, so throw it out
Uwindow( (w/2+1):w, : ) = [];
Vwindow( (w/2+1):w, : ) = [];
Zwindow( (w/2+1):w, : ) = [];
% throw out the mean (first coef) and add a zero (to make it the right length)  
%Uwindow(1,:)=[]; Vwindow(1,:)=[]; Zwindow(1,:)=[]; 
Uwindow(1:(w/2-1),:) = Uwindow(2:(w/2),:);
Vwindow(1:(w/2-1),:) = Vwindow(2:(w/2),:);
Zwindow(1:(w/2-1),:) = Zwindow(2:(w/2),:);
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


%% convert to displacement spectra from GPS velocities
% assumes perfectly circular deepwater orbits
% could be extended to finite depth by calling wavenumber.m 
Exx = ( UU )  ./ ( (2*pi*f).^2 );  %[m^2/Hz]
Eyy = ( VV )  ./ ( (2*pi*f).^2 );  %[m^2/Hz]
Ezz = ( ZZ );  %[m^2/Hz]

Qxz = imag(UZ) ./ ( (2*pi*f).^1 ) ; %[m^2/Hz], quadspectrum of vertical heave and horizontal velocities
Cxz = real(UZ) ./ ( (2*pi*f).^1 ) ; %[m^2/Hz], cospectrum of vertical heave and horizontal velocities

Qyz = imag(VZ) ./ ( (2*pi*f).^1 ) ; %[m^2/Hz], quadspectrum of vertical heave and horizontal velocities
Cyz = real(VZ) ./ ( (2*pi*f).^1 ) ; %[m^2/Hz], cospectrum of vertical heave and horizontal velocities

Cxy = real(UV) ./ ( (2*pi*f).^2 );  %[m^2/Hz]


%% wave spectral moments 
% wave directions from Kuik et al, JPO, 1988 and Herbers et al, JTech, 2012
% NOTE THAT THIS USES COSPECTRA OF Z AND U OR V, WHICH DIFFS FROM QUADSPECTRA OF Z AND X OR Y
a1 = Cxz ./ sqrt( (Exx+Eyy) .* Ezz );  %[], would use Qxz for actual displacements
b1 = Cyz ./ sqrt( (Exx+Eyy) .* Ezz );  %[], would use Qyz for actual displacements
a2 = (Exx - Eyy) ./ (Exx + Eyy);
b2 = 2 .* Cxy ./ ( Exx + Eyy );

%% wave directions
% note that 0 deg is for waves headed towards positive x (EAST, right hand system)
dir1 = atan2(b1,a1) ;  % [rad], 4 quadrant
dir2 = atan2(b2,a2)/2 ; % [rad], only 2 quadrant

%spread1 = sqrt( 2 * ( 1 - sqrt(a1.^2 + b2.^2) ) );
%spread2 = sqrt( abs( 0.5 - 0.5 .* ( a2.*cos(2.*dir2) + b2.*cos(2.*dir2) )  ));


%% use orbit shape as check on quality
check = Ezz ./ (Eyy + Exx);
E = Ezz;  % (use heave spectra as scalar energy spectra... in some cases Exx + Eyy will be better)


%% wave stats
fwaves = f>fmin & f<fmax; % frequency cutoff for wave stats, 

E( ~fwaves ) = 0;

% significant wave height
Hs  = 4*sqrt( sum( E(fwaves) ) * bandwidth);

%  energy period
fe = sum( f(fwaves).*E(fwaves) )./sum( E(fwaves) );
[~ , feindex] = min(abs(f-fe));
Ta = 1./fe;

% peak period
%[~ , fpindex] = max(UU+VV); % can use velocity (picks out more distint peak)
[~ , fpindex] = max(E);
Tp = 1./f(fpindex);


%% spectral directions
dir = - 180 ./ 3.14 * dir1;  % switch from rad to deg, and CCW to CW (negate)
dir = dir + 90;  % rotate from eastward = 0 to northward  = 0
dir( dir < 0 ) = dir( dir < 0 ) + 360;  % take NW quadrant from negative to 270-360 range
if recip == true,
    westdirs = dir > 180;
    eastdirs = dir < 180;
    dir( westdirs ) = dir ( westdirs ) - 180; % take reciprocal such wave direction is FROM, not TOWARDS
    dir( eastdirs ) = dir ( eastdirs ) + 180; % take reciprocal such wave direction is FROM, not TOWARDS
else 
end

% directional spread
% spread = 180 ./ 3.14 .* spread1;

Dp = dir(fpindex); % dominant (peak) direction, use peak f


%% screen for bad direction estimate, or no heave data    

inds = fpindex + [-1:1]; % pick neighboring bands
if all(inds>0), 
    
  dirnoise = std( dir(inds) );

  if dirnoise > 45,
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
a1( f > maxf ) = [];
b1( f > maxf ) = [];
a2( f > maxf ) = [];
b2( f > maxf ) = [];
check( f > maxf ) = [];
f( f > maxf ) = [];

% Mike S: Prune to exactly 42 frequency bands - assumes fs = 5 Hz!!
% E = E(1:42);
% dir = dir(1:42);
% a1 = a1(1:42);
% b1 = b1(1:42);
% a2 = a2(1:42);
% b2 = b2(1:42);
% check = check(1:42);
% f = f(1:42);

else % if not enough points or sufficent sampling rate or data, give 9999
  
     Hs = 9999;
     Tp = 9999; 
     Dp = 9999; 
     % Mike S: Fix E,f, etc to 42 frequency bands - assumes fs = 5 Hz!!
     E = 9999*ones(1,42); 
     f = 9999*ones(1,42);
     a1 = 9999*ones(1,42);
     b1 = 9999*ones(1,42);
     a2 = 9999*ones(1,42);
     b2 = 9999*ones(1,42);
     check = 9999*ones(1,42);

end


% quality control
if Tp>20,   
     Hs = 9999;
     Tp = 9999; 
     Dp = 9999; 
else 
end