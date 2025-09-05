function [Xsm] = smooth_mat(X,win,pwin)
% [u_sm] = smooth_mat(x,win,pwin) uses a convolution to compute a running
% average along the 2nd dimension of matrix 'x'. NaN values are first 
% interpolated through (to allow for convolution), and then replaced after 
% smoothing.

% 'X' is the matrix to be smoothed (along 2nd dimension).
% 'win' is the window used to compute the local average (e.g. win =
%       hanning(10)).
% 'pwin' is a QC criteria. Smoothed points are NaN'd out if the number of
% points used to compute the average is less than pwin % of the integral of
% 'win'.

%K.Fitzmorris 12/3/2018 modified from M.Merrifield group 'smooth_gap1'

if nargin == 2
    pwin = 0.8;
end

%Matrix dimensions
[N,M] = size(X);

%Remove rows w/all NaN
iNaN = isnan(nanmean(X,2));
X(iNaN,:) = 0;

%Remove Mean from each row
Xm = nanmean(X,2);
X = X - repmat(Xm,1,M);

%Pad with first and last value
nwin = length(win);
npad = floor(nwin/2);
iX = NaN(N,1);
fX = NaN(N,1);
for iN = 1:N
    iX(iN) = X(iN,find(~isnan(X(iN,:)),1,'first'));
    fX(iN) = X(iN,find(~isnan(X(iN,:)),1,'last'));
end
X = [repmat(iX,1,npad) X repmat(fX,1,npad)];

%Flatten matrix
Xf = X';
Xf = Xf(:);

%Interpolate through NaN (necessary for matlab 'conv')
ireal = ~isnan(Xf);
inan = isnan(Xf);
if sum(ireal) > 3
Xf(inan) = interp1(find(ireal),Xf(ireal),find(inan),'pchip'); 
else
    Xsm = NaN(size(Xf));
    return
end

%Apply convolution and normalize (so each window is 1 total)
Xsm = conv(Xf,win,'same');
npt = conv(ones(size(Xsm)),win,'same');
Xsm = Xsm./npt;

%Apply pwin criteria
kn = npt/sum(win) < pwin;
Xsm(kn) = NaN;

%Re-NaN
Xsm(inan) = NaN;

%Return u_sm in same format as u
Xsm = reshape(Xsm',size(X'));
Xsm = Xsm';

%Remove zero padding
Xsm = Xsm(:,npad+1:npad+M);

%Add back mean
Xsm = Xsm + repmat(Xm,1,M);

%Replace NaN again
Xsm(iNaN,:) = NaN;
    



