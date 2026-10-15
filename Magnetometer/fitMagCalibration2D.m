function cal = fitMagCalibration2D(key,xy,window,step,breaks)
%FITMAGCALIBRATION2D Windowed hard- and soft-iron fit of a levelled magnetometer.
%
%   cal = fitMagCalibration2D(key,xy,window,step,breaks)
%
%   key     time (datenum) of each record.
%   xy      cell array, per record, of levelled horizontal field samples
%           [X Y] (levelMagField).
%   window  fit window length, days (e.g. 24.84 h: two M2 cycles).
%   step    spacing of the window centers, days.
%   breaks  times at which the magnetic environment changes (e.g. battery
%           changes); no window spans one. Optional.
%
%   For a sample p at time t, S*(p - c) lies on a circle, with c and S from
%   magCalibrationAt(cal,t). S is symmetric with unit determinant, so it
%   stretches the ellipse into a circle without rotating it and cannot
%   absorb a mounting offset. cal.method is "ransac2d", or "mean" when a
%   segment between breaks is shorter than 24 h.
%
%   A moored buoy spends most of its time in the two watch-circle lobes,
%   which need not be 180 deg apart, so neither a mean nor a circle through
%   those two clusters gives an unbiased center. Each window is fit by
%   RANSAC: a candidate is the conic through 5 random samples; it is scored
%   by how many 10-deg heading bins (about its center) its inliers occupy,
%   which rewards ellipses that also pass through the sparse slack-water
%   turning arcs. The winner's inliers are refit with a direct ellipse fit,
%   every heading bin weighted equally. A segment shorter than 24 h has too
%   few turns to fit an ellipse; it gets one center, the mean of the
%   record-mean field, and no shape correction.
%
%   This levels first and fits in 2D, so a large body-frame hard iron that
%   projects differently as the tilt changes is not removed; see
%   fitMagCalibration3D.

if nargin < 5; breaks = []; end
nbin = 36;          % 10-deg heading bins
niter = 1000;       % RANSAC candidates per window
inliertol = 0.1;    % inlier distance, fraction of the field radius
stream = RandStream('mt19937ar','Seed',1);   % reproducible RANSAC

key = key(:);
breaks = sort(breaks(:));
segment = discretize(key,[-Inf; breaks; Inf]);
recordmean = cell2mat(cellfun(@(p) mean(p,1),xy(:),'UniformOutput',false));
cal.method = "ransac2d";
cal.breaks = breaks;
cal.time = zeros(0,1); cal.center = zeros(0,2); cal.shape = zeros(2,2,0);
cal.segment = zeros(0,1);
for iseg = unique(segment)'
    in = find(segment == iseg);
    if max(key(in))-min(key(in)) < 1
        cal.method = "mean";
        cal = addWindow(cal,mean(key(in)),mean(recordmean(in,:),1,'omitnan'), ...
            eye(2),iseg);
        continue
    end
    % Field radius about a running mean (only sets the inlier band and the
    % plausible ellipse size).
    centered = cell(numel(in),1);
    for j = 1:numel(in)
        near = in(abs(key(in)-key(in(j))) <= window/2);
        centered{j} = xy{in(j)} - mean(recordmean(near,:),1,'omitnan');
    end
    centered = vertcat(centered{:});
    radius0 = median(hypot(centered(:,1),centered(:,2)));
    for t = min(key(in)):step:max(key(in))
        samples = vertcat(xy{in(abs(key(in)-t) <= window/2)});
        if size(samples,1) < 100; continue; end
        [c,S,nbins] = ransacEllipse(samples,radius0,inliertol*radius0,nbin, ...
            niter,stream);
        % Too few heading bins covered: the window does not constrain an
        % ellipse.
        if nbins < nbin/3; continue; end
        cal = addWindow(cal,t,c,S/sqrt(det(S)),iseg);
    end
end
end

function cal = addWindow(cal,t,c,S,iseg)
cal.time(end+1,1) = t;
cal.center(end+1,:) = c;
cal.shape(:,:,end+1) = S;
cal.segment(end+1,1) = iseg;
end

function [center,S,nbins] = ransacEllipse(xy,radius0,tol,nbin,niter,stream)
% Keep the candidate whose inliers (Sampson distance < tol) cover the most
% heading bins, ties broken by inlier count; semi-axes outside 0.5-1.5
% radius0 are rejected. Refit the winner's inliers.
best = [-Inf -Inf];
center = [NaN NaN];
S = NaN(2);
keep = false(size(xy,1),1);
n = size(xy,1);
for iter = 1:niter
    conic = null(conicDesign(xy(randperm(stream,n,5),:)));
    if size(conic,2) ~= 1; continue; end
    [c,Q] = ellipseGeometry(conic);
    if ~plausibleEllipse(Q,radius0); continue; end
    inlier = sampsonDistance(conic,xy) < tol;
    score = [binsCovered(xy(inlier,:)-c,nbin) sum(inlier)];
    if isBetter(score,best)
        best = score;
        center = c;
        S = sqrtm(Q);
        keep = inlier;
    end
end
nbins = best(1);
if ~isfinite(center(1)); return; end
conic = fitEllipse(xy(keep,:),center,nbin);
[c,Q] = ellipseGeometry(conic);
if plausibleEllipse(Q,radius0)
    center = c;
    S = sqrtm(Q);
end
end

function tf = isBetter(score,best)
% More heading bins covered, or as many and more inliers.
tf = score(1) > best(1) || (score(1) == best(1) && score(2) > best(2));
end

function D = conicDesign(xy)
% Rows [x^2 xy y^2 x y 1] of the conic A x^2 + B xy + C y^2 + D x + E y + F.
D = [xy(:,1).^2 xy(:,1).*xy(:,2) xy(:,2).^2 xy(:,1) xy(:,2) ones(size(xy,1),1)];
end

function [center,Q] = ellipseGeometry(conic)
% Center and quadratic form Q, (x - center)' Q (x - center) = 1. Q is not
% positive definite if the conic is not an ellipse.
A = conic(1); B = conic(2); C = conic(3); D = conic(4); E = conic(5); F = conic(6);
center = (-([2*A B; B 2*C]\[D; E]))';
F0 = F + (D*center(1) + E*center(2))/2;
Q = -[A B/2; B/2 C]/F0;
end

function tf = plausibleEllipse(Q,radius0)
% A real ellipse with both semi-axes within 0.5-1.5 radius0.
e = eig(Q);
tf = isreal(e) && all(e > 0) && all(1./sqrt(e) > 0.5*radius0) && ...
    all(1./sqrt(e) < 1.5*radius0);
end

function d = sampsonDistance(conic,xy)
% First-order geometric distance of each sample to the conic.
value = conicDesign(xy)*conic(:);
gx = 2*conic(1)*xy(:,1) + conic(2)*xy(:,2) + conic(4);
gy = conic(2)*xy(:,1) + 2*conic(3)*xy(:,2) + conic(5);
d = abs(value)./hypot(gx,gy);
end

function n = binsCovered(d,nbin)
% Number of heading bins holding at least 3 samples (d relative to center).
if isempty(d); n = 0; return; end
bin = discretize(atan2d(d(:,2),d(:,1)),linspace(-180,180,nbin+1));
n = sum(accumarray(bin,1,[nbin 1]) >= 3);
end

function conic = fitEllipse(xy,center,nbin)
% Direct least-squares ellipse fit (Fitzgibbon et al. 1999, in the
% numerically stable form of Halir & Flusser 1998), each sample weighted by
% 1/(samples in its heading bin about center) so every bin counts equally.
bin = discretize(atan2d(xy(:,2)-center(2),xy(:,1)-center(1)), ...
    linspace(-180,180,nbin+1));
count = accumarray(bin,1,[nbin 1]);
w = 1./count(bin);
D1 = [xy(:,1).^2 xy(:,1).*xy(:,2) xy(:,2).^2];
D2 = [xy(:,1) xy(:,2) ones(size(xy,1),1)];
S1 = D1'*(w.*D1);
S2 = D1'*(w.*D2);
S3 = D2'*(w.*D2);
T = -(S3\S2');
M = S1 + S2*T;
M = [M(3,:)/2; -M(2,:); M(1,:)/2];     % premultiply by inv(C1), 4ac - b^2 = 1
[V,~] = eig(M);
isellipse = 4*V(1,:).*V(3,:) - V(2,:).^2 > 0;
a1 = V(:,find(isellipse,1));
conic = [a1; T*a1];
end
