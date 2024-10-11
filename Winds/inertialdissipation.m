function [ustar,epsilon,meanu,meanv,meanw,meantemp,anisotropy,quality,f,TKEpsd] = inertialdissipation(u,v,w,temp,z,fs)
% Function to process 3D sonic anemometer data using the inertial dissipation method of Yelland et al 1994.
% Inputs: turbulent wind components (u,v,w), sonic (virtual) air
%         temperature (temp), measurement height (z) and sampling frequency (fs)
% Outputs: wind friction velocity (ustar), dissipation rate (epsilon), mean
%         velocities and temperature (meanu,meanv,meanw,meantemp), quality checks
%         (anisotropy,quality), and TKE spectrum and corresponding frequency (TKEpsd)
%
% The intent is to run this on short bursts of data (nominally 10 to 60 minutes)
%   such that the input data have stationary statistics
%
% J. Thomson, Aug 2016 (modified from 2010 shipboard to waveglider)
%       note that works best with WG into the wind (strong negative u component measured)
% M. Schwendeman, Nov 2016 - modified from waveglider to SWIFT, fixed
%       output vectors to length 116 (assumes wsecs = 256, merge = 11, fs = 10)
% J. Thomson, Sep 2020, remove despiking, which was incorrectly done before
%       removing mean (and would fail for large mean winds)... better to
%       despike separately
% K.Zeiden, Oct 2024, cleaned up + remove QC steps (still returns QC values), to
%       avoid tossing good data. Rotates into downstream
%       direction (using both horizontal direction and vertical tilt). Uses
%       downstream component, not vertical, to compute epsilon and ustar (no 4/3 factor).


%% Fixed parameters
% K = (4/3)*0.55; % Kolmogorov const, where factor 4/3 is for cross-flow components... i.e., vertical)
K = 0.55;
kv = 0.4; % von Karman constant

% Window length
twin = 256;   % Window length in seconds (should make 2^N samples)
nwin = round(fs*twin);  % Window length in data points
if rem(nwin,2) ~= 0 % Enforce even number window length
    nwin = nwin-1;
end

% Number of windows
N = length(u);
M = floor(4*(N/nwin-1)+1);   % 4x results from 75% window overlap

% Freq range and bandwidth after averagining across frequency bands
nfmerge = 11; % Frequency bands to merge (must be odd?)
nf = floor((nwin/2)/nfmerge); % number of frequency bands
Nyquist = fs/2; % highest spectral frequency 
bandwidth = Nyquist/nf ; % freq (Hz) bandwitdh

% Find middle of each freq band
f = 1/(twin) + bandwidth/2 + bandwidth.*(0:(nf-1)) ; 

% Inertial subrange
fmin = 1.5;  % min frequency
fmax = 4; % max frequency

%% Mean burst wind speed and temperature values

meanu = mean(u);
meanv = mean(v);
meanw = mean(w);
meantemp = mean(temp);

%% Ensure sufficient data 
% (this should be taken care of outside of function actually)

% if N <= 2*nwin
%     ustar = NaN;
%     epsilon = NaN; 
%     freq = NaN(1,116);
%     tkespectrum = NaN(1,116);
%     anisotropy = NaN;
%     quality = 0;
%     disp('Not enough points to compute spectra...')
%     return
% end

%% Break into windows with 75% overlap. Windows are matrix columns.

U = NaN(nwin,M);
V = NaN(nwin,M);
W = NaN(nwin,M);

for iwin = 1:M
    j2win = (iwin-1)*(nwin/4)+1 : (iwin-1)*(nwin/4)+nwin;
    U(:,iwin) = u(j2win);  
    V(:,iwin) = v(j2win);  
	W(:,iwin) = w(j2win);  
end

%% Rotate into down-stream and cross-stream coordinates
% Ur = downstream, Vr = horizontal cross stream, 
%       Wr = vertical cross stream

Ur = NaN(size(U));
Vr = NaN(size(V));
Wr = NaN(size(W));

% Rotate horizontally into downstream direction
thetaH = atan2d(mean(V),mean(U));
for iwin = 1:M
R1 = [cosd(thetaH(iwin)), -sind(thetaH(iwin));...
    sind(thetaH(iwin)), cosd(thetaH(iwin))];

UV_rot = R1'*([U(:,iwin)'; V(:,iwin)']);
Ur(:,iwin) = UV_rot(1,:);
Vr(:,iwin) = UV_rot(2,:);
end

% Rotate vertically into tilt direction
thetaV = atan2d(mean(W),mean(Ur));
for iwin = 1:M
R1 = [cosd(thetaV(iwin)), -sind(thetaV(iwin));...
    sind(thetaV(iwin)), cosd(thetaV(iwin))];

UrW_rot = R1'*([Ur(:,iwin)'; W(:,iwin)']);
Ur(:,iwin) = UrW_rot(1,:);
Wr(:,iwin) = UrW_rot(2,:);
end

%% Detrend windows
Ud = detrend(Ur);
Vd = detrend(Vr);
Wd = detrend(Wr);

%% Taper windows to prevent edge effects in spectra
taper = sin((1:nwin)*pi/nwin)'; 

% Apply taper
Ut = Ud.*repmat(taper,1,M);
Vt = Vd.*repmat(taper,1,M);
Wt = Wd.*repmat(taper,1,M);

%% Rescale to preserve variance

% Variance correction factor (preserve original variance)
usca = sqrt(var(Ud)./var(Ut));
vsca = sqrt(var(Vd)./var(Vt));
wsca = sqrt(var(Wd)./var(Wt));

% Apply scaling
Us = Ut.*repmat(usca,nwin,1);
Vs = Ut.*repmat(vsca,nwin,1);
Ws = Ut.*repmat(wsca,nwin,1);

%% Compute power-spectra (auto) and cross-spectra

% Fourier Coefficients
FU = fft(Us);
FV = fft(Vs);
FW = fft(Ws);

% FFT is symmetric, so keep only positive frequencies 
%    (need to double the power later)
FU = FU(1:nwin/2,:);
FV = FV(1:nwin/2,:);
FW = FW(1:nwin/2,:);

% Throw out the mean (first coef) and add a zero (to make it the right length)  
FU(1:(nwin/2-1),:) = FU(2:(nwin/2),:);
FV(1:(nwin/2-1),:) = FV(2:(nwin/2),:);
FW(1:(nwin/2-1),:) = FW(2:(nwin/2),:);
FU(nwin/2,:) = 0; FV(nwin/2,:) = 0; FW(nwin/2,:) = 0; 

% POWER SPECTRA (auto-spectra)
PU = 2*real(FU.*conj(FU));
PV = 2*real(FV.*conj(FV));
PW = 2*real(FW.*conj(FW));

% CROSS-SPECTRA 
CUV = 2*(FU.*conj(FV));
CUW = 2*(FU.*conj(FW));
CVW = 2*(FV.*conj(FW));

%% Average within designated frequency bands

PUm = NaN(nf,M);
PVm = NaN(nf,M);
PWm = NaN(nf,M);
CUVm = 1i*ones(nf,M);
CUWm = 1i*ones(nf,M);
CVWm = 1i*ones(nf,M);

for ifreq = 1:nf 
    iband = (ifreq-1)*nfmerge + (1:nfmerge);
	PUm(ifreq,:) = mean(PU(iband,:));
	PVm(ifreq,:) = mean(PV(iband,:));
   	PWm(ifreq,:) = mean(PW(iband,:));
	CUVm(ifreq,:) = mean(CUV(iband,:));
  	CUWm(ifreq,:) = mean(CUW(iband,:));
	CVWm(ifreq,:) = mean(CVW(iband,:));
end

%% Normalize by N*fs to get power spectral density

PUm  = PUm/(fs*nwin);
PVm  = PVm/(fs*nwin);
PWm  = PWm/(fs*nwin);
CUVm  = CUVm/(fs*nwin);
CUWm  = CUWm/(fs*nwin);
CVWm  = CVWm/(fs*nwin);

%% Calculate dissipation rate and friction velocity for each window
% Advective velocity may be different for each window

% Frequencies in ISR
isrf = f > fmin & f < fmax ;

% ISR mean energy level (compensated spectra)
Eisr = mean(repmat(f(isrf)'.^(5/3),1,M).* PUm(isrf,:));

% Standard deviation of compensated spectra
Eisrstd = std((f(isrf)'.^(5/3)*ones(1,M)).*PUm(isrf,:)); 

% Downstream advective speed (frozen field)
Uadv = mean(Ur); 

% Dissipation rate
Eps =  (Eisr./((Uadv./(2*pi)).^(2/3).*K)).^(3/2);

% Friction velocity (assumes neutral stability)
Ustar = (kv*Eps*z).^(1/3);

%% Ensemble average across windows

upsd = mean(PUm,2);
vpsd = mean(PVm,2);
wpsd = mean(PWm,2);
uvcopsd = mean(CUVm,2); 
uwcopsd = mean(CUWm,2); 
vwcopsd = mean(CVWm,2);

% uadv = mean(Uadv);
epsilon = mean(Eps);
ustar = mean(Ustar);

%% Sum component spectra to get proxy for TKE spectra
TKEpsd = (upsd + vpsd + wpsd);

%% Quality Checks

% ISR Fit quality
quality = mean((Eisr-Eisrstd)./Eisr);

% Anisotropy 
anisotropy = (mean(upsd(isrf))./mean(wpsd(isrf)) + mean(vpsd(isrf))./mean(wpsd(isrf)) )./2;

% Drag coefficient
% Cd =  ustar.^2 ./ (uadv).^2;

end
