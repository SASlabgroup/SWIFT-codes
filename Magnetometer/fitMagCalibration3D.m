function cal = fitMagCalibration3D(key,m,d,window,step,breaks,inclination)
%FITMAGCALIBRATION3D Windowed, inclination-constrained 3D magnetometer fit.
%
%   cal = fitMagCalibration3D(key,m,d,window,step,breaks,inclination)
%
%   key          time (datenum) of each record.
%   m, d         cell arrays, per record, of body-frame field samples
%                (n x 3) and unit down vectors in the body frame (n x 3).
%   window       fit window length, days (e.g. 24.84 h: two M2 cycles).
%   step         spacing of the window centers, days.
%   breaks       times at which the magnetic environment changes (e.g.
%                battery changes); no window spans one. May be empty.
%   inclination  magnetic inclination, deg (positive down), e.g. from WMM.
%
%   For a sample m with down vector d, the corrected field
%   p = S*(m - c) (c and S from magCalibrationAt) has vertical component
%   p.d = sin(inclination) and horizontal magnitude cos(inclination), i.e.
%   |p| = 1 at the Earth's inclination. The hard iron c is removed in the
%   body frame, before levelling, so it cannot leak into the horizontal
%   field as the tilt changes. In each window:
%     - RANSAC: Levenberg-Marquardt solves on 9 random samples for c and the
%       symmetric S, scored by how many 10-deg heading bins their inliers
%       cover (a moored buoy spends most of its time in the two watch-circle
%       lobes, so inlier count alone would favor fits through those two
%       clusters);
%     - the winner's inliers are refit, every heading bin weighted equally.
%   Constraining the vertical component pins the fit along the vertical,
%   where a moored buoy's small tilts give little coverage; an
%   unconstrained ellipsoid wanders there. Fits outside plausible limits
%   (see isPlausible) are rejected and left to neighbouring windows. A
%   segment shorter than 24 h is fit as one window.

key = key(:);
breaks = sort(breaks(:));
segment = discretize(key,[-Inf; breaks; Inf]);
stream = RandStream('mt19937ar','Seed',1);   % reproducible RANSAC
cal.method = "ransac3d";
cal.inclination = inclination;
cal.breaks = breaks;
cal.time = zeros(0,1); cal.center = zeros(0,3); cal.shape = zeros(3,3,0);
cal.segment = zeros(0,1);
for iseg = unique(segment)'
    in = find(segment == iseg);
    span = max(key(in))-min(key(in));
    if span < 1
        centers = mean(key(in));
        halfwidth = span/2 + 1/24;
    else
        centers = min(key(in)):step:max(key(in));
        halfwidth = window/2;
    end
    for t = centers
        w = in(abs(key(in)-t) <= halfwidth);
        M = vertcat(m{w});
        D = vertcat(d{w});
        if size(M,1) < 200; continue; end
        [c,S] = ransacFit(M,D,inclination,stream);
        if ~isfinite(c(1)); continue; end
        cal.time(end+1,1) = t;
        cal.center(end+1,:) = c;
        cal.shape(:,:,end+1) = S;
        cal.segment(end+1,1) = iseg;
    end
end
end

function [c,S] = ransacFit(M,D,inclination,stream)
% Fit in normalized units (field about its mean, unit median radius).
niter = 200;
mu = mean(M,1);
scale = median(vecnorm(M-mu,2,2));
X = (M-mu)/scale;
x0 = [0 0 0 1 1 1 0 0 0]';          % center at the mean, S = identity
n = size(X,1);
best = [-Inf -Inf]; xbest = []; keep = [];
for iter = 1:niter
    sample = randperm(stream,n,9);
    x = levenbergMarquardt(X(sample,:),D(sample,:),ones(9,1),x0,inclination,30);
    if isempty(x) || ~isPlausible(x); continue; end
    [rv,rh] = residuals(x,X,D,inclination);
    inlier = abs(rv) < 0.1 & abs(rh) < 0.1;
    score = [binsCovered(corrected(x,X(inlier,:)),D(inlier,:)) sum(inlier)];
    if isBetter(score,best)
        best = score; xbest = x; keep = inlier;
    end
end
c = [NaN NaN NaN]; S = NaN(3);
if isempty(xbest) || sum(keep) < 50; return; end
w = binWeights(corrected(xbest,X(keep,:)),D(keep,:));
x = levenbergMarquardt(X(keep,:),D(keep,:),w,xbest,inclination,50);
if isempty(x) || ~isPlausible(x); x = xbest; end
% Back to raw units: p = S*(m - c)
[cn,Sn] = unpack(x);
c = cn*scale + mu;
S = Sn/scale;
end

function tf = isPlausible(x)
% Normalized units: hard iron within 3 of the window mean; soft iron
% positive definite, axis ratio below 3, scale between 1/3 and 3.
[c,S] = unpack(x);
e = eig(S);
tf = norm(c) < 3 && all(e > 1/3) && all(e < 3) && max(e)/min(e) < 3;
end

function tf = isBetter(score,best)
% More heading bins covered, or as many and more inliers.
tf = score(1) > best(1) || (score(1) == best(1) && score(2) > best(2));
end

function [c,S] = unpack(x)
% x = [c(3); diagonal of S(3); off-diagonals S12, S13, S23]
c = x(1:3)';
S = [x(4) x(7) x(8); x(7) x(5) x(9); x(8) x(9) x(6)];
end

function p = corrected(x,X)
[c,S] = unpack(x);
p = (X-c)*S';     % S is symmetric
end

function [rv,rh] = residuals(x,X,D,inclination)
% Vertical-component and horizontal-magnitude misfit of the corrected field.
p = corrected(x,X);
v = sum(p.*D,2);
rv = v - sind(inclination);
rh = vecnorm(p - v.*D,2,2) - cosd(inclination);
end

function x = levenbergMarquardt(X,D,w,x,inclination,niter)
% Weighted least squares on both residuals; numerical Jacobian. Returns
% empty if the residuals stop being finite.
sw = sqrt([w; w]);
r = sw.*stackedResiduals(x);
lambda = 1e-2;
h = 1e-6;
for iter = 1:niter
    J = zeros(numel(r),numel(x));
    for j = 1:numel(x)
        xj = x; xj(j) = xj(j) + h;
        J(:,j) = (sw.*stackedResiduals(xj) - r)/h;
    end
    A = J'*J;
    step = -(A + lambda*diag(diag(A)+1e-12))\(J'*r);
    xnew = x + step;
    rnew = sw.*stackedResiduals(xnew);
    if ~all(isfinite(rnew)); x = []; return; end
    if sum(rnew.^2) < sum(r.^2)
        x = xnew; r = rnew; lambda = lambda/3;
        if norm(step) < 1e-8; break; end
    else
        lambda = lambda*5;
    end
end
    function rr = stackedResiduals(xx)
        [rv,rh] = residuals(xx,X,D,inclination);
        rr = [rv; rh];
    end
end

function n = binsCovered(p,D)
% Number of 10-deg heading bins holding at least 3 samples.
if isempty(p); n = 0; return; end
count = accumarray(headingBin(p,D),1,[36 1]);
n = sum(count >= 3);
end

function w = binWeights(p,D)
% 1/(samples in the heading bin), so every bin counts equally.
bin = headingBin(p,D);
count = accumarray(bin,1,[36 1]);
w = 1./count(bin);
end

function bin = headingBin(p,D)
% 10-deg bin of the horizontal direction of p (levelMagField).
[X,Y] = levelMagField(p,D);
bin = discretize(atan2d(Y,X),linspace(-180,180,37));
end
