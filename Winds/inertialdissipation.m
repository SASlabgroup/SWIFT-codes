function [ustar epsilon meanu meanv meanw meantemp anisotropy quality freq tkespectrum ] = inertialdissipation(u, v, w, temp, z, fs);
% matlab function to process 3D sonic anemometer data
% based on the inertial dissipation methods of Yelland et al 1994
% inputs are turbulent components of wind u,v,w, and sonic (virtual) air temp 
%   also measurement height z and sampling frequency 
% ouptuts are wind friction velocity ustar, dissipation rate epsilon
%   means of each component and air temp, 
%   and an anisotropy metric for the inertial sub range of the spectrum
%   and a quality metric for the ustar estimate based on interial fitting
%   and tke frequency spectrum, 
%
%   [ustar epsilon meanu meanv meanw meantemp anisotropy quality freq tkespectrum ] = inertialdissipation(u, v, w, temp, z, fs);
%
% The intent is to run this on short bursts of data (nominally 10 to 60 minutes)
%   such that the input data have stationary statistics
%
% J. Thomson, Aug 2016 (modified from 2010 shipboard to waveglider)
%       note that works best with WG into the wind (strong negative u component measured)
% M. Schwendeman, Nov 2016 - modified from waveglider to SWIFT, fixed
% output vectors to length 116 (assumes wsecs = 256, merge = 11, fs = 10)
% J. Thomson, Sep 2020, remove despiking, which was incorrectly done before
%   removing mean (and would fail for large mean winds)... better to
%   despike separately
%  
%
%#codegen


%% fixed parameters
wsecs = 256;   % window length in seconds, should make 2^N samples
merge = 11;      % freq bands to merge, must be odd?
K = (4/3) * 0.55 ; % Kolmogorov const, where factor 4/3 is for cross-flow components... i.e., vertical)
kv = 0.4 ; % von Karman const  
windowlength = round(fs * wsecs);  % window length in data points


%% quality control... later require no more than 10% data loss in this screening
bad = [u == 0 | v == 0 | w == 0 | temp == 0];
 u( bad ) = [];
 v( bad ) = [];
 w( bad ) = [];
 temp( bad ) = [];
%u = u( ~bad );
%v = v( ~bad );
%w = w( ~bad );
%temp = temp( ~bad );

%% means
meanu = mean(u);
meanv = mean(v);
meanw = mean(w);
meantemp = mean(temp);

%% begin processing, if data sufficient
pts = length(u);       % record length in data points

if pts >= 2*wsecs  &  fs>1  &  sum(bad) < 0.1*pts,  % minimum length and quality for processing


%% break into windows (use 75 percent overlap)
if rem(windowlength,2)~=0, windowlength = windowlength-1; else end  % make w an even number
windows = floor( 4*(pts/windowlength - 1)+1 );   % number of windows, the 4 comes from a 75% overlap
dof = 2*windows*merge; % degrees of freedom
% loop to create a matrix of time series, where COLUMN = WINDOW 
uwindow = zeros(windowlength,windows);
vwindow = zeros(windowlength,windows);
wwindow = zeros(windowlength,windows);
for q=1:windows, 
	uwindow(:,q) = u(  (q-1)*(.25*windowlength)+1  :  (q-1)*(.25*windowlength)+windowlength  );  
	vwindow(:,q) = v(  (q-1)*(.25*windowlength)+1  :  (q-1)*(.25*windowlength)+windowlength  );  
  	wwindow(:,q) = w(  (q-1)*(.25*windowlength)+1  :  (q-1)*(.25*windowlength)+windowlength  );  
end

%% detrend individual windows (full series already detrended)
udetrend = zeros(windowlength,windows);
vdetrend = zeros(windowlength,windows);
wdetrend = zeros(windowlength,windows);
for q=1:windows
    udetrend(:,q) = detrend(uwindow(:,q));
    vdetrend(:,q) = detrend(vwindow(:,q));
    wdetrend(:,q) = detrend(wwindow(:,q));
end

%% taper and rescale (to preserve variance)
% form taper matrix (columns of taper coef)
taper = sin ( (1:windowlength) * pi/windowlength )' * ones(1,windows); 
% taper each window
xwindowtaper = udetrend .* taper;
ywindowtaper = vdetrend .* taper;
zwindowtaper = wdetrend .* taper;
% now find the correction factor (comparing old/new variance)
factx = sqrt( var(udetrend) ./ var(xwindowtaper) );
facty = sqrt( var(vdetrend) ./ var(ywindowtaper) );
factz = sqrt( var(wdetrend) ./ var(zwindowtaper) );
% and correct for the change in variance
% (mult each window by it's variance ratio factor)
xwindowready = (ones(windowlength,1)*factx).* xwindowtaper;
ywindowready = (ones(windowlength,1)*facty).* ywindowtaper;
zwindowready = (ones(windowlength,1)*factz).* zwindowtaper;


%% FFT
% calculate Fourier coefs
Uwindow = fft(xwindowready);
Vwindow = fft(ywindowready);
Wwindow = fft(zwindowready);
% second half of fft is redundant, so throw it out
Uwindow( (windowlength/2+1):windowlength, : ) = [];
Vwindow( (windowlength/2+1):windowlength, : ) = [];
Wwindow( (windowlength/2+1):windowlength, : ) = [];
% throw out the mean (first coef) and add a zero (to make it the right length)  
%Uwindow(1,:)=[]; Vwindow(1,:)=[]; Wwindow(1,:)=[]; 
Uwindow(1:(windowlength/2-1),:) = Uwindow(2:(windowlength/2),:);
Vwindow(1:(windowlength/2-1),:) = Vwindow(2:(windowlength/2),:);
Wwindow(1:(windowlength/2-1),:) = Wwindow(2:(windowlength/2),:);
Uwindow(windowlength/2,:)=0; Vwindow(windowlength/2,:)=0; Wwindow(windowlength/2,:)=0; 
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
UUwindowmerged = zeros(floor(windowlength/(2*merge)),windows);
VVwindowmerged = zeros(floor(windowlength/(2*merge)),windows);
WWwindowmerged = zeros(floor(windowlength/(2*merge)),windows);
UVwindowmerged = 1i*ones(floor(windowlength/(2*merge)),windows);
UWwindowmerged = 1i*ones(floor(windowlength/(2*merge)),windows);
VWwindowmerged = 1i*ones(floor(windowlength/(2*merge)),windows);

for mi = merge:merge:(windowlength/2) 
	UUwindowmerged(mi/merge,:) = mean( UUwindow((mi-merge+1):mi , : ) );
	VVwindowmerged(mi/merge,:) = mean( VVwindow((mi-merge+1):mi , : ) );
   	WWwindowmerged(mi/merge,:) = mean( WWwindow((mi-merge+1):mi , : ) );
	UVwindowmerged(mi/merge,:) = mean( UVwindow((mi-merge+1):mi , : ) );
  	UWwindowmerged(mi/merge,:) = mean( UWwindow((mi-merge+1):mi , : ) );
	VWwindowmerged(mi/merge,:) = mean( VWwindow((mi-merge+1):mi , : ) );
end
% freq range and bandwidth
n = (windowlength/2) / merge;                         % number of f bands
Nyquist = .5 * fs;                % highest spectral frequency 
bandwidth = Nyquist/n ;                    % freq (Hz) bandwitdh
% find middle of each freq band, ONLY WORKS WHEN MERGING ODD NUMBER OF BANDS!
f = 1/(wsecs) + bandwidth/2 + bandwidth.*(0:(n-1)) ; 
freq = f;


%% normalize (to get spectral density)... divide by N*samplerate to get power spectral density
% the two is b/c Matlab's fft output is the symmetric FFT, and we did not use the redundant half (so need to multiply the psd by 2)

UUwindowmerged  = ( UUwindowmerged ) / (windowlength/2 * fs  );
VVwindowmerged  = ( VVwindowmerged ) / (windowlength/2 * fs  );
WWwindowmerged  = ( WWwindowmerged ) / (windowlength/2 * fs  );
UVwindowmerged  = ( UVwindowmerged ) / (windowlength/2 * fs  ); 
UWwindowmerged  = ( UWwindowmerged ) / (windowlength/2 * fs  ); 
VWwindowmerged  = ( VWwindowmerged ) / (windowlength/2 * fs  );


%%  find interial sub range (hard wired or dynamic), 
% then get dissipation rate and ustar using the vertical component
% do this for each window, rather than ensemble spectra,
% because the advected velocity might change between windows (if vehicle turns, etc)

fmin = 2;  % inertial sub-range, min freq
fmax = 4.9; % inertial sub-range, max freq
inertialfreqs = f > fmin & f < fmax ;
inertiallevel = mean( (f(inertialfreqs)'.^(5/3)*ones(1,windows)) .* WWwindowmerged(inertialfreqs,:) ); % average value of compensated spectra
inertialstd = std( (f(inertialfreqs)'.^(5/3)*ones(1,windows)) .* WWwindowmerged(inertialfreqs,:) ); % average value of compensated spectra
advectionspeed = ( mean(uwindow).^2 + mean(vwindow).^2 ) .^ 0.5;  % speed at which frozen field turbulence is advected past sensor
epsilonwindow =  ( inertiallevel ./ ( ( advectionspeed ./ (2*pi) ).^(2/3)  .* K ) ).^(3/2);
ustarwindow = (kv * epsilonwindow * z ).^(1/3);  % assumes neutral

%% quality metrics
qualitywindow = (inertiallevel-inertialstd)./ inertiallevel; % quality of fit in ISR
%qualitywindow = WWwindowmerged(1,:)./WWwindowmerged(end,:); % low frequency contamination
%qualitywindow = ( std(uwindow) + std(vwindow) )./ advectionspeed; % advective speed variations



%% ensemble average windows together
% take the average of all windows at each freq-band
UU = mean( UUwindowmerged.' ) ;
VV = mean( VVwindowmerged.' ) ;
WW = mean( WWwindowmerged.' ) ;
UV = mean( UVwindowmerged.' ) ; 
UW = mean( UWwindowmerged.' ) ; 
VW = mean( VWwindowmerged.' ) ;

% find the windows with stable mean in the streamwise direction, use only those for ustar and epsilon ensembles
good = abs(mean(uwindow)) > std(uwindow); %disp('stable windows'), sum(good) % debug

if sum(good) >= 2,
    epsilon = mean(epsilonwindow(good));
    ustar = mean(ustarwindow(good));
    quality = mean(qualitywindow(good));
else
     ustar = 9999;
     epsilon = 9999; 
     quality = mean(qualitywindow);
end


%% sum component spectra to get proxy for TKE spectra

tkespectrum = ( UU + VV + WW );

% !!! Mike S: Fix output to exactly length 116 - Assumes: wsecs = 256, 
% merge = 11, fs = 10 !!!
tkespectrum = tkespectrum(1:116);
freq = freq(1:116);



%% anisotropy 
anisotropy = ( mean(UU(inertialfreqs))./mean(WW(inertialfreqs)) + mean(VV(inertialfreqs))./mean(WW(inertialfreqs)) )./2; ;

%% Quality control (check ustar against drag law)
dragcoef = ustar.^2 ./ (advectionspeed).^2 ;

dragoutofrange = [ dragcoef > 1e-2  dragcoef < 1e-5 ];
if all(dragoutofrange),
    QCflag = true;
else
    QCflag = false;
end

%% housekeeping

else % if not enough points or sufficent sampling rate or data, give 9999
  
     ustar = 9999;
     epsilon = 9999; 
     % !!! Mike S: Fix output to exactly length 116 - Assumes: wsecs = 256, 
     % merge = 11, fs = 10 !!!
     freq = 9999*ones(1,116);
     tkespectrum = 9999*ones(1,116);
     anisotropy = 9999;
     QCflag = true;
     quality = 0;
     disp('not enough pts')

end


% quality control
if QCflag == true,   
     ustar = 9999;
     epsilon = 9999; 
else 
end

