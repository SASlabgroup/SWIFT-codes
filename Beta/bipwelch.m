% [Bp,f] = bipwelch(xt,windowsz,fs)
%
% uses the WOSA, or Welch's overlapping segment method to make bi-spectra
%
%   xt          is the signal
%   windowsz    is in seconds
%   fs          is the sampling frequency

function [Bp,f] = bipwelch(xt,windowsz,fs)

%   xt          is the signal
%   windowsz    is in seconds
%   fs          is the sampling frequency

%uses 75% overlap
n = length(xt);

% break into windows (use 75 percent overlap) -----------------------------
w = round(fs * windowsz);  % window length in data points
% make w an even number
if rem(w,2)~=0
    w = w-1; 
end

% number of windows, the 4 comes from a 75% overlap
windows = floor( 4*(n/w - 1)+1 );   

%dof = 2*windows*merge; % degrees of freedom

% loop to create a matrix of time series, where COLUMN = WINDOW 
xt_window = zeros(w,windows);
for q=1:windows, 
	xt_window(:,q) = detrend( xt(  (q-1)*(.25*w)+1  :  (q-1)*(.25*w)+w  ) );
    %detrend individual windows
end

xt_var = var( xt_window,0,1 );
% taper and rescale (to preserve variance)  -----------------------------
taper = hann(w)*ones(1,windows);

% taper each window
xt_window = xt_window .* taper;

%re scale to insure variance is preserved
xt_window = xt_window .* (ones(w,1)*sqrt( xt_var./var(xt_window,0,1)  ));

%estimate bispectrum for each window -----------------------------
B = zeros(w/2,w/2,windows);
for q = 1:windows
    [B(:,:,q),f] = bispec(xt_window(:,q));
end

f = f*fs; %cyclic frequency
%average together
Bp = squeeze( nanmean(B,3) );

end