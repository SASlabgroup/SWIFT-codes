function [EOFs,alpha,E,Xm] = eof(X)
% [EOFs,alpha,E] = eof(X) calculates basic EOF components
%   Columns of X are timeseries. NaN replaced w/0 for covariance
%   calculation. Xm is the mean removed to compute the EOFs.

[nsamp,neof] = size(X);

%Remove the time mean of each column
Xm = mean(X,'omitnan');
X0 = repmat(Xm,nsamp,1);
X = X - X0;

% Sub NaN w/0
inan = isnan(X);
X(inan) = 0;

% Data-data covariance matrix
R = X'*X;

% Eigenvectors are modes and eigenvalues are variance
try
[EOFs,E] = eig(R,'vector');
catch ME
    disp(['Warning using ''eig'': ' ME.message])
    EOFs = NaN(neof,neof);
    alpha = NaN(nsamp,neof);
    E = NaN(1,neof);
    Xm = NaN(1,neof);
    return
end

% Sort by EOF variance
[E,s] = sort(E,'descend');
EOFs = EOFs(:,s);

% Fraction of variance explained by each mode
E = (E./sum(E))';

% EOF amplitudes
alpha = (X*EOFs);
