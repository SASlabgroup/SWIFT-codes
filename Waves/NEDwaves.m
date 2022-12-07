function [ Hs, Tp, Dp, E, fmin, fmax, a1, b1, a2, b2, check] = NEDwaves(north, east, down, fs) 

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
%   [ Hs, Tp, Dp, E, fmin, fmax, a1, b1, a2, b2, check ] = NEDwaves(north,east,down,fs); 
%
% note that outputs are slightly different than other wave codes
% b/c this matches the half-float precision format of telemetry type 52
% and only uses frequency limits, not full f array
%
% J. Thomson,  12/2022 (modified from GPSwaves)
%
%#codegen

testing = false;

%% tunable parameters
    
Nstd = 4; % standard deviations for despiking        
    
RC = 3.5; % time constant [s] for high-pass filter (pass T < 2 pi * RC)
    

%% fixed parameters (which will produce 42 frequency bands)

wsecs = 256;   % windoz length in seconds, should make 2^N samples
merge = 3;      % freq bands to merge, must be odd?
maxf = .5;       % frequency cutoff for telemetry Hz
    

%% detrend

east = detrend(east);
north = detrend(north);
down = detrend(down);

%% Despike the time series

bad = abs(east) >= Nstd * std(east); % logical array of indices for bad points
east(bad) = mean( east(~bad) );
bad = abs(north) >= Nstd * std(north); % logical array of indices for bad points
north(bad) = mean( north(~bad) );
bad = abs(down) >= Nstd * std(down); % logical array of indices for bad points
down(bad) = mean( down(~bad) );


%% begin processing, if data sufficient
pts = length(east);       % record length in data points

if pts >= 2*wsecs & fs>=1 & sum(bad)<100 & sum(bad)<100,  % minimum length and quality for processing

    
%% high-pass RC filter, 

alpha = RC / (RC + 1./fs); 

filtereddata = east; 
for ui = 2:length(filtereddata),
   filtereddata(ui) = alpha * filtereddata(ui-1) + alpha * ( east(ui) - east(ui-1) );
end
east = filtereddata;

filtereddata = north; 
for ui = 2:length(filtereddata),
   filtereddata(ui) = alpha * filtereddata(ui-1) + alpha * ( north(ui) - north(ui-1) );
end
north = filtereddata;

filtereddata = down; 
for ui = 2:length(filtereddata),
   filtereddata(ui) = alpha * filtereddata(ui-1) + alpha * ( down(ui) - down(ui-1) );
end
down = filtereddata;


%% break into windows (use 75 percent overlap)

win = round(fs * wsecs); % window length in data points
if rem(win,2)~=0, win = win-1; else end  % make win an even number
windows = floor( 4*(pts/win - 1)+1 );   % number of windows, the 4 comes from a 75% overlap
dof = 2*windows*merge; % degrees of freedom

% loop to create a matrix of time series, where COLUMN = WINDOW 
uwindow = zeros(win,windows);
vwindow = zeros(win,windows);
wwindow = zeros(win,windows);

for q=1:windows, 
	uwindow(:,q) = east(  (q-1)*(.25*win)+1  :  (q-1)*(.25*win)+win  );  
	vwindow(:,q) = north(  (q-1)*(.25*win)+1  :  (q-1)*(.25*win)+win  );  
  	wwindow(:,q) = down(  (q-1)*(.25*win)+1  :  (q-1)*(.25*win)+win  );  
end

%% detrend individual windows (full series already detrended)
for q=1:windows
    uwindow(:,q) = detrend(uwindow(:,q));
    vwindow(:,q) = detrend(vwindow(:,q));
    wwindow(:,q) = detrend(wwindow(:,q));
end

%% taper and rescale (to preserve variance)

% get original variance of each window
uvar = var(uwindow);
vvar = var(vwindow);
wvar = var(wwindow);
% form taper matrix (columns of taper coef)
taper = sin ( (1:win) * pi/win )' * ones(1,windows); 
% taper each window
uwindow = uwindow .* taper;
vwindow = vwindow .* taper;
wwindow = wwindow .* taper;
% now find the correction factor (comparing old/new variance)
factu = sqrt( uvar ./ var(uwindow) );
factv = sqrt( vvar ./ var(vwindow) );
factw = sqrt( wvar ./ var(wwindow) );
% and correct for the change in variance
% (mult each window by it's variance ratio factor)
uwindow = (ones(win,1)*factu).* uwindow;
vwindow = (ones(win,1)*factv).* vwindow;
wwindow = (ones(win,1)*factw).* wwindow;

%% FFT
% note convention for lower case as time-domain and upper case as freq domain

% calculate Fourier coefs
Uwindow = single(fft(uwindow));
Vwindow = single(fft(vwindow));
Wwindow = single(fft(wwindow));
% second half of fft is redundant, so throw it out
Uwindow( (win/2+1):win, : ) = [];
Vwindow( (win/2+1):win, : ) = [];
Wwindow( (win/2+1):win, : ) = [];
% throw out the mean (first coef) and add a zero (to make it the right length)  
Uwindow(1,:)=[]; Vwindow(1,:)=[]; Wwindow(1,:)=[]; 
Uwindow(win/2,:)=0; Vwindow(win/2,:)=0; Wwindow(win/2,:)=0; 
% POWER SPECTRA (auto-spectra)
UUwindow = real ( Uwindow .* conj(Uwindow) );
VVwindow = real ( Vwindow .* conj(Vwindow) );
WWwindow = real ( Wwindow .* conj(Wwindow) );
% CROSS-SPECTRA 
UVwindow = ( Uwindow .* conj(Vwindow) );
UWwindow = ( Uwindow .* conj(Wwindow) );
VWwindow = ( Vwindow .* conj(Wwindow) );


%% merge neighboring freq bands (number of bands to merge is a fixed parameter)
% initialize
UUwindowmerged = zeros(floor(win/(2*merge)),windows);
VVwindowmerged = zeros(floor(win/(2*merge)),windows);
WWwindowmerged = zeros(floor(win/(2*merge)),windows);
UVwindowmerged = 1i*ones(floor(win/(2*merge)),windows);
UWwindowmerged = 1i*ones(floor(win/(2*merge)),windows);
VWwindowmerged = 1i*ones(floor(win/(2*merge)),windows);

for mi = merge:merge:(win/2) 
	UUwindowmerged(mi/merge,:) = mean( UUwindow((mi-merge+1):mi , : ) );
	VVwindowmerged(mi/merge,:) = mean( VVwindow((mi-merge+1):mi , : ) );
   	WWwindowmerged(mi/merge,:) = mean( WWwindow((mi-merge+1):mi , : ) );
	UVwindowmerged(mi/merge,:) = mean( UVwindow((mi-merge+1):mi , : ) );
  	UWwindowmerged(mi/merge,:) = mean( UWwindow((mi-merge+1):mi , : ) );
	VWwindowmerged(mi/merge,:) = mean( VWwindow((mi-merge+1):mi , : ) );
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
WW = mean( WWwindowmerged.' ) / (win/2 * fs  );
UV = mean( UVwindowmerged.' ) / (win/2 * fs  ); 
UW = mean( UWwindowmerged.' ) / (win/2 * fs  ); 
VW = mean( VWwindowmerged.' ) / (win/2 * fs  ); 

%% prune high frequency results 

UU( f > maxf ) = []; 
VV( f > maxf ) = []; 
WW( f > maxf ) = []; 
UV( f > maxf ) = []; 
UW( f > maxf ) = []; 
VW( f > maxf ) = []; 
f( f > maxf ) = [];


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
fwaves = f>0.05 & f<maxf; % frequency cutoff for wave stats, 0.4 is specific to SWIFT hull

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

if Tp > 18, % if peak not found, use centroid
    Tp = Ta;
    fpindex = feindex;
end


%% wave directions

% begin with cartesian, 0 deg is for waves headed towards positive x (EAST, right hand system)
%dir1 = atan2(b1,a1) ;  % [rad], 4 quadrant
%dir2 = atan2(b2,a2)/2 ; % [rad], only 2 quadrant
%spread1 = sqrt( 2 * ( 1 - sqrt(a1.^2 + b2.^2) ) );
%spread2 = sqrt( abs( 0.5 - 0.5 .* ( a2.*cos(2.*dir2) + b2.*cos(2.*dir2) )  ));

% peak wave direction, rotated to geographic conventions
Dp = atan2( b1(fpindex), a1(fpindex) ) ;  % [rad], 4 quadrant
Dp = - 180 ./ 3.14 * Dp;  % switch from rad to deg, and CCW to CW (negate)
Dp = Dp + 90;  % rotate from eastward = 0 to northward  = 0
if Dp < 0, Dp = Dp + 360; end % take NW quadrant from negative to 270-360 range
if Dp > 180, Dp = Dp - 180; end % take reciprocal such wave direction is FROM, not TOWARDS
if Dp < 180, Dp = Dp + 180; end % take reciprocal such wave direction is FROM, not TOWARDS


else % if not enough points or insufficent sampling rate give 9999
  
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


%% quality control for excessive low frequency problems
if Tp>20,   
     Hs = 9999;
     Tp = 9999; 
     Dp = 9999; 
else 
end

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


%% testing bits

% if testing
% 
%     figure(1), clf
%     subplot(2,1,1)
%     loglog(f,( UU + VV) ./ ( (2*pi*f).^2 ), f, ( WW ) ./ ( (2*pi*f).^2 ) )
%     set(gca,'YLim',[1e-3 2e2])
%     legend('E=(UU+VV)/f^2','E=WW/f^2')
%     ylabel('Energy [m^2/Hz]')
%     title(['Hs = ' num2str(Hs,2) ', Tp = ' num2str(Tp,2) ', Dp = ' num2str(Dp,3)])
%     subplot(2,1,2)
%     semilogx(f,a1, f,b1, f,a2,  f,b2)
%     set(gca,'YLim',[-1 1])
%     legend('a1','b1','a2','b2')
%     xlabel('frequency [Hz]')
%     drawnow
% 
% end


