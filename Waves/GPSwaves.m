function [ Hs, Tp, Dp, E, f, a1, b1, a2, b2] = GPSwaves(u,v,z,fs) 

% matlab function to read and process GPS data
%   to estimate wave height, period, direction, and spectral moments
%   assuming deep-water limit of surface gravity wave dispersion relation
%
% Inputs are east velocity [m/s], north velocity [m/s], vertical 
% elevation relative to MSL [m], and sampling rate [Hz]
%
% Some inputs can be empty variables, in which case the algorithm will use
% whatever non-empty inputs are available, with preference for GPS
% velocities
%
% Required input is sampling rate, which must be at least 1 Hz and the same
% for all variables.  Additionaly, non-empty input time series data must 
% have at least 512 points and all be the same size.
%
% Outputs are significat wave height [m], dominant period [s], dominant direction 
% [deg T, using meteorological from which waves are propagating], spectral 
% energy density [m^2/Hz], frequency [Hz], and 
% the normalized spectral moments a1, b1, a2, b2, 
%
% Outputs will be '9999' for invalid results.
%
% Outputs can be supressed, in order, thus full usage is as follows:
%
%   [ Hs, Tp, Dp, E, f, a1, b1, a2, b2 ] = GPSwaves(u,v,z,fs); 
%
% and minimal usage is:
%
%   [ Hs, Tp ] = GPSwaves(u,v,[],[],[],fs); 
%
%
% J. Thomson,  12/2013, v1, modified from PUVspectra.m (2003)
%              10/2015, v2, include vertical GPS estimate to get all four directional moments
%              10/2017, v3, change the RC filter parameter to 3.5, after
%                           realizing that the cuttoff period is 2 pi * RC, not RC
%              11/2018, v4, force velocity spectra as source for scalar energy spectra
%                           remove LFNR usage
%                           correct sign of a1, b1
%               8/2019  force use of Tp from velocity spectra, increase max f to 1 Hz
%               
%
%#codegen

%% tunable parameters

% low frequency noise ratio tolerance (not applied as of Nov 2018)

    LFNR = 4 ; 
    
% standard deviations for despiking        
    Nstd = 10; 

% time constant [s] for high-pass filter 
    RC = 3.5; 

% energy ratios (unused as of Oct 2017)
%maxEratio = 5; % max allowed ratio of Ezz to Exx + Eyy, default is 5
%minEratio = .1; % min allowed ratio of Ezz to Exx + Eyy, default is 0.1
    

%% fixed parameters (which will produce 42 frequency bands)
wsecs = 256;   % windoz length in seconds, should make 2^N samples
merge = 3;      % freq bands to merge, must be odd?
maxf = .5;       % frequency cutoff for telemetry Hz

%% deal with variable input data, with priority for GPS velocity

% if no vertical, asign a dummy, but then void the a1,a2 result later
if isempty(z),  % check for accelerations
    z = zeros(size(u));
    zdummy = 1;
else
    z = z;
    zdummy = 0;
end

    
    
%% Quality control inputs (despike)

badu = abs(detrend(u)) >= Nstd * std(u); % logical array of indices for bad points
badv = abs(detrend(v)) >= Nstd * std(v); % logical array of indices for bad points
badz = abs(detrend(z)) >= Nstd * std(z); % logical array of indices for bad points
u(badu) = mean( u(~badu) );
v(badv) = mean( v(~badv) );
z(badz) = mean( z(~badz) );


%% begin processing, if data sufficient
pts = length(u);       % record length in data points

if pts >= 2*wsecs & fs>=1 & sum(badu)<100 & sum(badv)<100,  % minimum length and quality for processing

    
%% high-pass RC filter, detrend first

u = detrend(u);
v = detrend(v);
z = detrend(z);

%initialize
ufiltered = u;
vfiltered = v;
zfiltered = z;

alpha = RC / (RC + 1./fs); 

for ui = 2:length(z),
   ufiltered(ui) = alpha * ufiltered(ui-1) + alpha * ( u(ui) - u(ui-1) );
   vfiltered(ui) = alpha * vfiltered(ui-1) + alpha * ( v(ui) - v(ui-1) );
   zfiltered(ui) = alpha * zfiltered(ui-1) + alpha * ( z(ui) - z(ui-1) );
end

u = ufiltered;
v = vfiltered;
z = zfiltered;

%% break into windows (use 75 percent overlap)
win = round(fs * wsecs); % windoz length in data points
if rem(win,2)~=0, win = win-1; else end  % make z an even number
windows = floor( 4*(pts/win - 1)+1 );   % number of windows, the 4 comes from a 75% overlap
dof = 2*windows*merge; % degrees of freedom
% loop to create a matrix of time series, where COLUMN = WINDOz 
uwindow = zeros(win,windows);
vwindow = zeros(win,windows);
zwindow = zeros(win,windows);
for q=1:windows, 
	uwindow(:,q) = u(  (q-1)*(.25*win)+1  :  (q-1)*(.25*win)+win  );  
	vwindow(:,q) = v(  (q-1)*(.25*win)+1  :  (q-1)*(.25*win)+win  );  
  	zwindow(:,q) = z(  (q-1)*(.25*win)+1  :  (q-1)*(.25*win)+win  );  
end

%% detrend individual windows (full series already detrended)
for q=1:windows
uwindow(:,q) = detrend(uwindow(:,q));
vwindow(:,q) = detrend(vwindow(:,q));
zwindow(:,q) = detrend(zwindow(:,q));
end

%% taper and rescale (to preserve variance)
% form taper matrix (columns of taper coef)
taper = sin ( (1:win) * pi/win )' * ones(1,windows); 
% taper each window
uwindowtaper = uwindow .* taper;
vwindowtaper = vwindow .* taper;
zwindowtaper = zwindow .* taper;
% noz find the correction factor (comparing old/nez variance)
factu = sqrt( var(uwindow) ./ var(uwindowtaper) );
factv = sqrt( var(vwindow) ./ var(vwindowtaper) );
factz = sqrt( var(zwindow) ./ var(zwindowtaper) );
% and correct for the change in variance
% (mult each windoz by it's variance ratio factor)
uwindowready = (ones(win,1)*factu).* uwindowtaper;
vwindowready = (ones(win,1)*factv).* vwindowtaper;
zwindowready = (ones(win,1)*factz).* zwindowtaper;


%% FFT
% calculate Fourier coefs
Uwindow = fft(uwindowready);
Vwindow = fft(vwindowready);
Zwindow = fft(zwindowready);
% second half of fft is redundant, so throz it out
Uwindow( (win/2+1):win, : ) = [];
Vwindow( (win/2+1):win, : ) = [];
Zwindow( (win/2+1):win, : ) = [];
% throz out the mean (first coef) and add a zero (to make it the right length)  
Uwindow(1,:)=[]; Vwindow(1,:)=[]; Zwindow(1,:)=[]; 
Uwindow(win/2,:)=0; Vwindow(win/2,:)=0; Zwindow(win/2,:)=0; 
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
UUwindowmerged = zeros(floor(win/(2*merge)),windows);
VVwindowmerged = zeros(floor(win/(2*merge)),windows);
ZZwindowmerged = zeros(floor(win/(2*merge)),windows);
UVwindowmerged = 1i*ones(floor(win/(2*merge)),windows);
UZwindowmerged = 1i*ones(floor(win/(2*merge)),windows);
VZwindowmerged = 1i*ones(floor(win/(2*merge)),windows);

for mi = merge:merge:(win/2) 
	UUwindowmerged(mi/merge,:) = mean( UUwindow((mi-merge+1):mi , : ) );
	VVwindowmerged(mi/merge,:) = mean( VVwindow((mi-merge+1):mi , : ) );
   	ZZwindowmerged(mi/merge,:) = mean( ZZwindow((mi-merge+1):mi , : ) );
	UVwindowmerged(mi/merge,:) = mean( UVwindow((mi-merge+1):mi , : ) );
  	UZwindowmerged(mi/merge,:) = mean( UZwindow((mi-merge+1):mi , : ) );
	VZwindowmerged(mi/merge,:) = mean( VZwindow((mi-merge+1):mi , : ) );
end
% freq range and bandwidth
n = (win/2) / merge;                         % number of f bands
Nyquist = .5 * fs;                % highest spectral frequency 
bandwidth = Nyquist/n ;                    % freq (Hz) bandwitdh
% find middle of each freq band, ONLY WORKS WHEN MERGING ODD NUMBER OF BANDS!
f = 1/(wsecs) + bandwidth/2 + bandwidth.*(0:(n-1)) ; 


%% ensemble average windows together
% take the average of all windows at each freq-band
% and divide by N*samplerate to get power spectral density
% the two is b/c Matlab's fft output is the symmetric FFT, 
% and we did not use the redundant half (so need to multiply the psd by 2)
UU = mean( UUwindowmerged.' ) / (win/2 * fs  );
VV = mean( VVwindowmerged.' ) / (win/2 * fs  );
ZZ = mean( ZZwindowmerged.' ) / (win/2 * fs  );
UV = mean( UVwindowmerged.' ) / (win/2 * fs  ); 
UZ = mean( UZwindowmerged.' ) / (win/2 * fs  ); 
VZ = mean( VZwindowmerged.' ) / (win/2 * fs  ); 


%% convert to displacement spectra (from velocity and heave)
% assumes perfectly circular deepwater orbits
% could be extended to finite depth by calling wavenumber.m 
Exx = ( UU )  ./ ( (2*pi*f).^2 );  %[m^2/Hz]
Eyy = ( VV )  ./ ( (2*pi*f).^2 );  %[m^2/Hz]
Ezz = ( ZZ ) ; %[m^2/Hz]

% use orbit shape as check on quality, expect this to be < 1, b/c SWIFT wobbles
check = Ezz ./ (Eyy + Exx);

Qxz = imag(UZ) ./ ( (2*pi*f).^1 ); %[m^2/Hz], quadspectrum of vertical displacement and horizontal velocities
Cxz = real(UZ) ./ ( (2*pi*f).^1 ); %[m^2/Hz], cospectrum of vertical displacement and horizontal velocities

Qyz = imag(VZ) ./ ( (2*pi*f).^1 ); %[m^2/Hz], quadspectrum of vertical displacement and horizontal velocities
Cyz = real(VZ) ./ ( (2*pi*f).^1 ); %[m^2/Hz], cospectrum of vertical displacement and horizontal velocities

Cxy = real(UV) ./ ( (2*pi*f).^2 );  %[m^2/Hz]


%% wave spectral moments 
% wave directions from Kuik et al, JPO, 1988 and Herbers et al, JTech, 2012
% NOTE THAT THIS USES COSPECTRA OF Z AND U OR V, WHICH DIFFS FROM QUADSPECTRA OF Z AND X OR Y
% note also that normalization is skewed by the bias of Exx + Eyy over Ezz
% (non-unity check factor)
a1 = Cxz ./ sqrt( (Exx+Eyy).* Ezz );  %[], would use Qxz for actual displacements
b1 = Cyz ./ sqrt( (Exx+Eyy).* Ezz );  %[], would use Qyz for actual displacements
a2 = (Exx - Eyy) ./ (Exx + Eyy);
b2 = 2 .* Cxy ./ ( Exx + Eyy );

% discount a2 and b2 according to the check factor (non-circular orbits)
%a2 = check.*a2;
%b2 = check.*b2;

%% wave directions
% note that 0 deg is for waves headed towards positive x (EAST, right hand system)
dir1 = atan2(b1,a1) ;  % [rad], 4 quadrant
dir2 = atan2(b2,a2)/2 ; % [rad], only 2 quadrant
spread1 = sqrt( 2 * ( 1 - sqrt(a1.^2 + b2.^2) ) );
spread2 = sqrt( abs( 0.5 - 0.5 .* ( a2.*cos(2.*dir2) + b2.*cos(2.*dir2) )  ));

%% screen for presence/absence of vertical data
if zdummy ==1,
    Ezz(:) = 0;
    a1(:) = 9999;
    b1(:) = 9999;
    dir1(:) = 9999;
    spread1(:) = 9999;
else
end




%% apply LFNR tolerance 
%Exx(LFNR*(UU) < Exx ) = 0;  % quality control based on LFNR of swell
%Eyy(LFNR*(VV) < Eyy ) = 0;  % quality control based on LFNR of swell
%Ezz(LFNR*(ZZ) < Ezz ) = 0;  % quality control based on LFNR of swell


%% Scalar energy spectra (a0)

%if zdummy == 1,
E = Exx + Eyy;
%else
%    E = Ezz;
%end

%E = zeros(1,length(f));
%if wdummy ==1,
%    E = Exx + Eyy;
%else
%fchange = 0.1; 
%E(f>fchange) = Exx(f>fchange) +Eyy(f>fchange) ; % use GPS for scalar energy of wind waves
%E(f<=fchange) = Ezz(f<=fchange); % use heave acceleratiosn for scalar energy of swell
%end

% testing bits
%E = nanmean([Ezz' (Exx+Eyy)'],2)';
%E = Eyy+Exx; % pure GPS version (for testing)
%E( check > maxEratio | check < minEratio ) = 0; 
%figure, loglog(f,check)
%clf, loglog(f,UU+VV,'g',f,Exx+Eyy,'b',f,Ezz,'r'),legend('UU+VV','XX+YY','ZZ') % for testing
%loglog(f,abs(Cxz),f,abs(Cyz))
drawnow

%% wave stats
fwaves = f>0.05 & f<1; % frequency cutoff for wave stats, 0.4 is specific to SWIFT hull

%E( ~fwaves ) = 0;

% significant wave height
Hs  = 4*sqrt( sum( E(fwaves) ) * bandwidth);

%  energy period
fe = sum( f(fwaves).*E(fwaves) )./sum( E(fwaves) );
[~ , feindex] = min(abs(f-fe));
Ta = 1./fe;

% peak period
[~ , fpindex] = max(UU+VV); % can use velocity (picks out more distint peak)
%[~ , fpindex] = max(E);
Tp = 1./f(fpindex);

if Tp > 18, % if peak not found, use centroid
    Tp = Ta;
    fpindex = feindex;
end

%% spectral directions
dir = - 180 ./ 3.14 * dir1;  % switch from rad to deg, and CCz to Cz (negate)
dir = dir + 90;  % rotate from eastward = 0 to northward  = 0
dir( dir < 0 ) = dir( dir < 0 ) + 360;  % take Nz quadrant from negative to 270-360 range
westdirs = dir > 180;
eastdirs = dir < 180;
dir( westdirs ) = dir ( westdirs ) - 180; % take reciprocal such wave direction is FROM, not TOWARDS
dir( eastdirs ) = dir ( eastdirs ) + 180; % take reciprocal such wave direction is FROM, not TOWARDS

% directional spread
spread = 180 ./ 3.14 .* spread1;


%% dominant direction

% or peak direction (very noisy)
%Dp = dir(fpindex); % dominant (peak) direction, use peak f

% or average
Dp = dir(fpindex); % dominant (peak) direction, use peak f

if zdummy == 1,
    Dp = 9999;
else
end

%% screen for bad direction estimate, or no heave data    

% inds = fpindex + [-1:1]; % pick neighboring bands
% if all(inds>0) & all(inds<42), 
%     
%   dirnoise = std( dir(inds) );
% 
%   if dirnoise > 45  |  zdummy == 1,
%       Dp = 9999;
%   else
%       Dp = Dp;
%   end
%   
% else
%     Dp =9999;
% end


%% prune high frequency results
E( f > maxf ) = [];
Ezz( f > maxf ) = [];
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


% quality control
if Tp>20,   
     Hs = 9999;
     Tp = 9999; 
     Dp = 9999; 
else 
end


