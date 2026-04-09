
function [ f, PP, PU, PV, PW, UU, VV, WW, UV , cohSIG ]  =  PWspectra( p, u, v, w , fs);

%
% Matlab function to calculate and plot cross-spectra from pressure and velocity 
%
%
%    [ f, PP, PU, PV, PW, UU, VV, WW, UV ]  =  PWspectra( p, u, v, w , fs , cohSIG);
%
% Output is freq (Hz) and power spectra, and 95% significance level for coherence
%
% J. Thomson, 4/2026, adapted from PUVspectra (2003-2005), 
%             

pts = length(p);                 % record length in data points
secs = pts / fs;        % record length in seconds

% WINDOW THE DATA (use 75 percent overlap)--------------------------------------
% WINDOW LENGTH SHOULD BE 2^n FOR FFT EFFICIENCY
window_length = 200;  % seconds
merge = 5; 
windowpts = fs * window_length;    % window length in data points
windows = 4*floor(pts/windowpts -1)+1   % number of windows, the 4 comes from a 75% overlap
% loop to create a matrix of time series, where COLUMN = WINDOW 
for q=1:windows, 
	p_window(:,q) = p(  (q-1)*(.25*windowpts)+1  :  (q-1)*(.25*windowpts)+windowpts  );  
	u_window(:,q) = u(  (q-1)*(.25*windowpts)+1  :  (q-1)*(.25*windowpts)+windowpts  );  
	v_window(:,q) = v(  (q-1)*(.25*windowpts)+1  :  (q-1)*(.25*windowpts)+windowpts  );  
    w_window(:,q) = w(  (q-1)*(.25*windowpts)+1  :  (q-1)*(.25*windowpts)+windowpts  );  
end
%-------------------------------------------------------------------------------



% DETREND THE WINDOWED DATA-----------------------------------------------------

for q=1:windows
    p_window_detrend(:,q) = detrend(p_window(:,q));
    u_window_detrend(:,q) = detrend(u_window(:,q));
    v_window_detrend(:,q) = detrend(v_window(:,q));
    w_window_detrend(:,q) = detrend(w_window(:,q));
end
%------------------------------------------------------------------------------




% TAPER THE DATA (use a Hanning type window)-----------------------------------
% form taper matrix (columns of taper coef)
taper = sin ([1:windowpts] * pi/windowpts )' * ones(1,windows); 
% taper each window
p_window_taper = p_window_detrend .* taper;
u_window_taper = u_window_detrend .* taper;
v_window_taper = v_window_detrend .* taper;
w_window_taper = w_window_detrend .* taper;
% now find the correction factor (comparing old/new variance)
factp = sqrt( var(p_window_detrend) ./ var(p_window_taper) );
factu = sqrt( var(u_window_detrend) ./ var(u_window_taper) );
factv = sqrt( var(v_window_detrend) ./ var(v_window_taper) );
factw = sqrt( var(w_window_detrend) ./ var(w_window_taper) );
% and correct for the change in variance
% (mult each window by it's variance ratio factor)
p_window_ready = (ones(windowpts,1)*factp).* p_window_taper;
u_window_ready = (ones(windowpts,1)*factu).* u_window_taper;
v_window_ready = (ones(windowpts,1)*factv).* v_window_taper;
w_window_ready = (ones(windowpts,1)*factw).* w_window_taper;
% check & report
if abs(  var(p_window_ready) - var(p_window_detrend)  ) > 0.1,
  disp('******************************')
  disp('Problem preserving variance variance');
  disp('******************************')
  else end
%------------------------------------------------------------------------------



% SPECTRA (FFT)-----------------------------------------------------------------
% calculate Fourier coefs
P_window = fft(p_window_ready);
U_window = fft(u_window_ready);
V_window = fft(v_window_ready);
W_window = fft(w_window_ready);
% second half of fft is redundant, so throw it out
P_window( (windowpts/2+1):windowpts, : ) = [];
U_window( (windowpts/2+1):windowpts, : ) = [];
V_window( (windowpts/2+1):windowpts, : ) = [];
W_window( (windowpts/2+1):windowpts, : ) = [];
% throw out the mean (first coef) and add a zero (to make it the right length)  
P_window(1,:)=[];  U_window(1,:)=[]; V_window(1,:)=[]; W_window(1,:)=[]; 
P_window(windowpts/2,:)=0; U_window(windowpts/2,:)=0; V_window(windowpts/2,:)=0; W_window(windowpts/2,:)=0; 
% POWER SPECTRA (auto-spectra)
PP_window = ( P_window .* conj(P_window) );
UU_window = ( U_window .* conj(U_window) );
VV_window = ( V_window .* conj(V_window) );
WW_window = ( W_window .* conj(W_window) );
% CROSS-SPECTRA 
PU_window = ( P_window .* conj(U_window) );
PV_window = ( P_window .* conj(V_window) );
PW_window = ( P_window .* conj(W_window) );
UV_window = ( U_window .* conj(V_window) );
% -----------------------------------------------------------------------------



% MERGE FREQUENCY BANDS -------------------------------------------------------
% raw fft has windowpts/2 frequency bands before merging... merge to improve stastics
% number of bands to merge is an input to function
for i = merge:merge:(windowpts/2) 
	PP_window_merged(i/merge,:) = mean( PP_window((i-merge+1):i , : ) );
	UU_window_merged(i/merge,:) = mean( UU_window((i-merge+1):i , : ) );
	VV_window_merged(i/merge,:) = mean( VV_window((i-merge+1):i , : ) );
    WW_window_merged(i/merge,:) = mean( WW_window((i-merge+1):i , : ) );
	PU_window_merged(i/merge,:) = mean( PU_window((i-merge+1):i , : ) );
	PV_window_merged(i/merge,:) = mean( PV_window((i-merge+1):i , : ) );
    PW_window_merged(i/merge,:) = mean( PW_window((i-merge+1):i , : ) );
	UV_window_merged(i/merge,:) = mean( UV_window((i-merge+1):i , : ) );
end
% freq range and bandwidth
n = (windowpts/2) / merge;                         % number of f bands
Nyquist = .5 * fs;                % highest spectral frequency 
bandwidth = Nyquist/n ;                    % freq (Hz) bandwitdh
% find middle of each freq band, ONLY WORKS WHEN MERGING ODD NUMBER OF BANDS!
f = 1/(window_length) + bandwidth/2 + bandwidth.*[0:(n-1)] ; 
% -----------------------------------------------------------------------------



% ENSEMBLE AVERAGE THE WINDOWS -------------------------------------------------
% take the average of all windows at each freq-band
% and divide by N*fs to get power spectral density
% the two is b/c Matlab's fft output is the symmetric FFT, and we did not use the redundant half (so need to multiply the psd by 2)
PP = mean( PP_window_merged.' ) / (windowpts/2 * fs );    
UU = mean( UU_window_merged.' ) / (windowpts/2 * fs  );
VV = mean( VV_window_merged.' ) / (windowpts/2 * fs  );
WW = mean( WW_window_merged.' ) / (windowpts/2 * fs  );
PU = mean( PU_window_merged.' ) / (windowpts/2 * fs  ); 
PV = mean( PV_window_merged.' ) / (windowpts/2 * fs  ); 
PW = mean( PW_window_merged.' ) / (windowpts/2 * fs  ); 
UV = mean( UV_window_merged.' ) / (windowpts/2 * fs  ); 
%--------------------------------------------------------------------------


% COHERENCE & PHASE, etc -------------------------------------------------------
% Cospectrum & Quadrature:
coPU = real(PU);   quPU = imag(PU);
coPV = real(PV);   quPV = imag(PV);
coPW = real(PV);   quPW = imag(PV);
coUV = real(UV);   quUV = imag(UV);
% Coherence & Phase at each freq-band
% *** note that it's important to calc this AFTER all merging and ensemble avg.
cohPU = sqrt( (coPU.^2 + quPU.^2) ./ (PP.* UU) );
phPU  = 180/pi .* atan2( quPU , coPU );  
cohPV = sqrt((coPV.^2 + quPV.^2)./ (PP.* VV));
phPV  = 180/pi .* atan2( quPV , coPV ); 
cohPW = sqrt((coPW.^2 + quPW.^2)./ (PP.* WW));
phPW  = 180/pi .* atan2( quPW , coPW );  
cohUV = sqrt((coUV.^2 + quUV.^2)./(UU .* VV));
phUV  = 180/pi .* atan2( quUV , coUV );  
% -----------------------------------------------------------------------------


% DEGREES OF FREEDOM and level of no significant coherence --------------------
% DOF = 2 * (# independent windows) * (# bands merged)
DOF = 2 * pts/windowpts * merge  
chi2 = chi2pdf([1:100],DOF);  within95 = find(chi2 > 0.05*max(chi2));
low = within95(1)/find(chi2==max(chi2));
high = within95(length(within95))/find(chi2==max(chi2)); 
% 95% significance level for zero coherence
cohSIG = sqrt(6/DOF) %
% ------------------------------------------------------------------------------

