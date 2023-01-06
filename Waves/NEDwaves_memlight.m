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
%
%#codegen



%% parameters 

%testing = true;

pts = length(east);  % length of the input data (should be 2^N for efficiency)
fmin = 0.01; % min frequecny for final output, Hz
fmax = 0.5; % max frequecny for final output, Hz
nf = 42; % number of frequency bands in final result


%% remove the mean

north = north - mean(north);
east = east - mean(east);
down = down - mean(down);


%% taper and rescale (to preserve variance)

% get original variance of each 
northvar = var(north);
eastvar = var(east);
downvar = var(down);
% define the taper
taper = sin ( (1:pts) * pi/pts ); 
% apply the taper
north = north .* taper;
east = east .* taper;
down = down .* taper;
% then rescale to regain the same original variance
north = north * sqrt( northvar ./ var(north) );
east = east * sqrt( eastvar ./ var(east) );
down = down * sqrt( downvar ./ var(down) );


%% FFT, note convention for lower case as time-domain and upper case as freq domain

% calculate Fourier coefs (complex values, double sided)
U = single(fft(east));
V = single(fft(north));
W = single(fft(down));

% second half of Matlab's FFT is redundant, so throw it out
U( round(pts/2+1):pts ) = [];
V( round(pts/2+1):pts ) = [];
W( round(pts/2+1):pts ) = [];

% throw out the mean (first coef) and add a zero (to make it the right length)  
U(1)=[]; V(1)=[]; W(1)=[]; 
U(round(pts/2))=0; V(round(pts/2))=0; W(round(pts/2))=0; 

% determine the frequency vector
Nyquist = fs / 2;     % highest spectral frequency 
f1 = 1./(pts./fs);    % frequency resolution 
allf = linspace(f1, Nyquist, round(pts/2)); 

% remove high frequency tail (to save memory)
U( allf > 1.1*fmax ) = [];
V( allf > 1.1*fmax ) = [];
W( allf > 1.1*fmax ) = [];
allf( allf > 1.1*fmax ) = [];

% option to interp before... prob better to wait 
% f = linspace(fmin, fmax,nf);
% U = interp1(allf, U, f); 
% V = interp1(allf, V, f); 
% W = interp1(allf, W, f); 

% POWER SPECTRAL DENSITY (auto-spectra)
UU = real ( U .* conj(U) ) / (round(pts/2) * fs  );
VV = real ( V .* conj(V) ) / (round(pts/2) * fs  );
WW = real ( W .* conj(W) ) / (round(pts/2) * fs  );
% CROSS-SPECTRAL DENSITY 
UV = ( U .* conj(V) ) / (round(pts/2) * fs  );
UW = ( U .* conj(W) ) / (round(pts/2) * fs  );
VW = ( V .* conj(W) ) / (round(pts/2) * fs  );

%% interp onto output frequencies

f = linspace(fmin, fmax, nf);
UU = interp1(allf, UU, f); 
VV = interp1(allf, VV, f); 
WW = interp1(allf, WW, f); 
UV = interp1(allf, UV, f); 
UW = interp1(allf, UW, f); 
VW = interp1(allf, VW, f); 


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
if Dp > 180, Dp = Dp - 180; end % take reciprocal such wave direction is FROM, not TOWARDS
if Dp < 180, Dp = Dp + 180; end % take reciprocal such wave direction is FROM, not TOWARDS



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


%% plots during testing

% if testing
% 
%     figure(2), clf
%     subplot(2,1,1)
%     loglog(f,E,'k:'), hold on
%     loglog(f,( UU + VV) ./ ( (2*pi*f).^2 ), f, ( WW ) ./ ( (2*pi*f).^2 ) )
%     set(gca,'YLim',[1e-3 2e2])
%     legend('E','E=(UU+VV)/f^2','E=WW/f^2')
%     ylabel('Energy [m^2/Hz]')
%     title(['Hs = ' num2str(Hs,2) ', Tp = ' num2str(Tp,2) ', Dp = ' num2str(Dp,3)])
%     subplot(2,1,2)
%     semilogx(f,double(a1)./100, f,double(b1)./100, f,double(a2)./100,  f,double(b2)./100)
%     set(gca,'YLim',[-1 1])
%     legend('a1','b1','a2','b2')
%     xlabel('frequency [Hz]')
%     drawnow
% 
% end


