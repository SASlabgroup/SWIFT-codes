function [eps,qual,sfdata] = SFdissipation_fast(w,z,rmin,rmax,nzfit,fittype,avgtype,sfdata)
% This function applies Taylor cascade theory to estimate dissipation from
% the second order velocity structure function computed from vertical profiles
% of turbulent velocity (see Wiles et al. 2006). SFdissipation was
% formulated with data from the Nortek Signature 1000 ADCP operating in pulse-coherent
% (HR) mode, but can be applied to any ensemble of velocity profiles.
%
%   in:     w (or dW)  nbin x nping ensemble of velocity profiles. Ensemble averaging
%                           occurs across the 'ping' dimension. Can alternatively
%                           input the velocity difference matrix (dW).
%           z           1 x nbin
%           rmin        minimum separation distance allowed in the fit
%           rmax        maximum separation distance, assumed to be within the
%                           inerital subrange
%           nzfit       number of vertical bins to include in fit at each
%                       depth, e.g. for nzfit = 1 , fit all pairs with
%                       mean pair depth <= z0 +\- dz/2, i.e. vertical
%                       smoothing
%           fittype     either 'linear' or 'cubic', determines whether the
%                           structure function is fit to a theoretical curve which is
%                           linear or cubic in R^(2/3). The latter should be used if
%                           there is likely significant profile-scale shear in the profiles,
%                           such as surface waves (Scannell et al. 2017)
%                           12/2022: Added 'log', which does the linear fit
%                           in log space instead. Assumes noise term is
%                           very low.
%                           9/2024: removed 'log', and just compute the
%                           slope to know what it is
%           avgtype     either 'mean','logmean' or 'median', determines whether the
%                           mean of squares, mean of the log of squares, or median of squares
%                           is taken to determine the expected value of the squared velocity difference
%           sfdata      optional preprocessing structure returned by an
%                       earlier fit to the same velocity field and avgtype
%
%   out:    eps         1 x nbin profile of dissipation
%           qual        structure with metrics for evaluating quality of eps including:
%                       - mean square percent error of the fit (mspe),
%                       - propagated error of the fit (epserr),
%                       - ADCP error inferred from the SF intercept (N),
%                       - slope of the SF (slope),
%                       - wave term coefficient (B, if modified r^2 fit used).
%           sfdata      reusable structure-function mean and standard error
%                       for fitting the same velocity field a second time.

%           K.Zeiden Summer/Fall 2022
%           Faster version of SFdissipation: for a velocity matrix and
%           avgtype 'mean', the pair statistics are built one bin row at a
%           time from running sums over pings, using only the upper
%           triangle (dW is antisymmetric). Equal to SFdissipation within
%           floating-point tolerance.

arguments
    w
    z
    rmin
    rmax
    nzfit
    fittype {mustBeMember(fittype,{'linear','cubic'})}
    avgtype {mustBeMember(avgtype,{'mean','logmean','median'})}
    sfdata = []
end

nz = length(z);
if ~isempty(sfdata)
    if ~all(isfield(sfdata,{'D','Derr','avgtype'})) || ...
            ~strcmp(sfdata.avgtype,avgtype)
        error('Invalid SFdissipation preprocessing structure.')
    end
    D = sfdata.D;
    Derr = sfdata.Derr;
elseif ~any(~isnan(w(:)))
    eps = NaN(1,nz);
    qual.mspe = NaN(1,nz);
    qual.slope = NaN(1,nz);
    qual.epserr = NaN(1,nz);
    qual.A = NaN(1,nz);
    qual.B = NaN(1,nz);
    qual.N = NaN(1,nz);
    return
else

    % Matrices of all possible data pair velocity differences for each ping.
    % Points greater than +/- 5 standard deviation are removed from each dist.
    if ismatrix(w) && strcmp(avgtype,'mean')
        [nbin,~] = size(w);
        if nbin ~= length(z)
            w = w';
            [nbin,~] = size(w);
        end
        [D,Derr] = meanSF(w-mean(w,2,'omitnan'));
        sfdata.D = D;
        sfdata.Derr = Derr;
        sfdata.avgtype = avgtype;
    end
end

if isempty(sfdata)
    if ismatrix(w)
        [nbin,~] = size(w);
        if nbin ~= length(z)
            w = w';
            [nbin,~] = size(w);
        end
        dW = repmat(w-mean(w,2,'omitnan'),1,1,nbin);
        dW = permute(dW,[1 3 2])-permute(dW,[3 1 2]);
        dW(abs(dW) > 5*std(dW,[],3,'omitnan')) = NaN;
    elseif ndims(w) == 3
        dW = w;
        [nbin,nbin2,~] = size(dW);
        if nbin ~= nbin2 || nbin ~= length(z)
            error('Check dimensions of ''dW''')
        end
    else
        error('Check dimensions of ''w''')
    end

    % Take mean (or median, or mean-of-the-logs) squared velocity difference.
    dW2 = dW.^2;
    if strcmp(avgtype,'mean')
        D = mean(dW2,3,'omitnan');
    elseif strcmp(avgtype,'logmean')
        D = 10.^(mean(log10(dW2),3,'omitnan'));
    elseif strcmp(avgtype,'median')
        D = median(dW2,3,'omitnan');
    else
        error('Average estimator must be ''mean'', ''logmean'' or ''median''.')
    end

    % Standard error on the mean. Return both fields for a second fit to the
    % same velocity field without rebuilding the large difference array.
    Derr = sqrt(var(dW2,[],3,'omitnan')./sum(~isnan(dW),3));
    sfdata.D = D;
    sfdata.Derr = Derr;
    sfdata.avgtype = avgtype;
end

% Matrices of all possible separation distances and mean vertical positions.
z = z(:)';
dz = median(diff(z));
R = round(z-z',2);
[Z1,Z2] = meshgrid(z);
Z0 = (Z1+Z2)/2;

% Fit structure function to theoretical curve
Cv2 = 2.1;
eps = NaN(size(z));
epserr = eps;
A = NaN(size(z));
B = NaN(size(z));
Aerr = NaN(size(z));
N = NaN(size(z));
mspe = NaN(size(z));
slope = NaN(size(z));
kbin = fitIndices(R,Z0,z,dz,nzfit,rmin,rmax);
for ibin = 1:length(z)

    % Points in z0 bin within specified separation scale range, sorted by r
    kfit = kbin{ibin};
    nfit = length(kfit);
    if nfit < 3 % Must contain more than 3 points
        continue

    end
    xN = ones(nfit,1);
    x1 = R(kfit);
    x23 = x1.^(2/3);
    x2 = x23.^3;
    d = D(kfit);
    derr = mean(Derr(kfit),'omitnan');

    % Best-fit power-law to the structure function
    ilog = x1 > 0 & d > 0;% log(0) = -Inf
    x1log = log10(x1(ilog));
    dlog = log10(d(ilog));
    xNlog = xN(ilog);
    G = [x1log(:) xNlog(:)];
    Gg = (G'*G)\G';
    m = Gg*dlog(:);
    slope(ibin) = m(1);

    % Fit structure function to theoretical curves
    if strcmp(fittype,'cubic')

        % Fit structure function to D(z,r) = Br^2 + Ar^(2/3) + N
        G = [x2(:) x23(:) xN(:)];
        Gg = (G'*G)\G';
        m = Gg*d(:);
        B(ibin) = m(1);
        A(ibin) = m(2);

        % Remove model shear term & fit Ar^(2/3) to residual (to get mspe)
        dmod = d-B(ibin)*x2;
        G = [x23(:) xN(:)];
        Gg = (G'*G)\G';
        m = Gg*dmod(:);
        dm = G*m;
        imse = abs(dm) > 10^(-8);
        mspe(ibin) =  mean(((dm(imse)-dmod(imse))./dm(imse)).^2);
        N(ibin) = m(2);
        merr = sqrt(diag(derr.^2*((G'*G)^(-1))));
        Aerr(ibin) = merr(1);

        % update w/slope of residual structure function
        ilog = x1 > 0 & dmod > 0;% log(0) = -Inf
        x1log = log10(x1(ilog));
        dlog = log10(dmod(ilog));
        xNlog = xN(ilog);
        G = [x1log(:) xNlog(:)];
        Gg = (G'*G)\G';
        m = Gg*dlog(:);
        slope(ibin) = m(1);

    elseif strcmp(fittype,'linear')

        % Fit structure function to D(z,r) = Ar^(2/3) + N
        G = [x23(:) xN(:)];
        Gg = (G'*G)\G';
        m = Gg*d(:);
        dm = G*m;
        imse = abs(dm) > 10^(-8);
        mspe(ibin) =  mean(((dm(imse)-d(imse))./dm(imse)).^2);
        A(ibin) = m(1);
        N(ibin) = m(2);
        merr = sqrt(diag(derr.^2*((G'*G)^(-1))));
        Aerr(ibin) = merr(1);

    else
        error('Fit type must be ''linear'' or ''cubic''')
    end
    eps(ibin) = (A(ibin)./Cv2).^(3/2);
    epserr(ibin) = Aerr(ibin)*(3/2)*eps(ibin)./A(ibin);

end

% Remove unphysical values
eps(A<0) = NaN;
epserr(A<0) = NaN;

% Save quality metrics
qual.mspe = mspe;
qual.slope = slope;
qual.epserr = epserr;
qual.A = A;
qual.B = B;
qual.N = N;

%%%%% End function

end


function [D,Derr] = meanSF(wd)
% Mean and standard error of squared pair differences, matching the
% 5-standard-deviation cut in SFdissipation. Moments of all pair differences
% come from matrix products over pings; outliers are then found one bin row
% at a time and their contributions removed.

nbin = size(wd,1);
wd = wd';
good = ~isnan(wd);
x = wd;
x(~good) = 0;
g = double(good);
x2 = x.^2;

% Count, sum, sum of squares and sum of fourth powers of x_i - x_j
n = g'*g;
s1 = x'*g;
s1 = s1 - s1';
s2 = x2'*g;
s2 = s2 + s2' - 2*(x'*x);
s4 = (x2.^2)'*g;
s3 = (x2.*x)'*x;
s4 = s4 + s4' - 4*(s3 + s3') + 6*(x2'*x2);
s1(1:nbin+1:end) = 0;
s2(1:nbin+1:end) = 0;
s4(1:nbin+1:end) = 0;

sd2 = max(s2 - s1.^2./n,0)./(n-1);
sd2(n == 1) = 0;

% Remove outliers; pairs with max|x_i| + max|x_j| <= 5 sd cannot have any
xmax = max(abs(x),[],1);
for ibin = 1:nbin
    jbin = ibin:nbin;
    jbin = jbin((xmax(ibin) + xmax(jbin)).^2*(1+1e-12) > 25*sd2(ibin,jbin));
    if isempty(jbin)
        continue
    end
    dw2 = (wd(:,ibin) - wd(:,jbin)).^2;
    ibad = find(dw2 > 25*sd2(ibin,jbin));
    if isempty(ibad)
        continue
    end
    dw2 = dw2(ibad);
    jbad = ceil(ibad/size(wd,1));
    nj = length(jbin);
    n(ibin,jbin) = n(ibin,jbin) - accumarray(jbad,1,[nj 1])';
    s2(ibin,jbin) = s2(ibin,jbin) - accumarray(jbad,dw2,[nj 1])';
    s4(ibin,jbin) = s4(ibin,jbin) - accumarray(jbad,dw2.^2,[nj 1])';
end
n = triu(n) + triu(n,1)';
s2 = triu(s2) + triu(s2,1)';
s4 = triu(s4) + triu(s4,1)';

D = s2./n;
v = max(s4 - n.*D.^2,0)./(n-1);
v(n == 1) = 0;
Derr = sqrt(v./n);

end


function kbin = fitIndices(R,Z0,z,dz,nzfit,rmin,rmax)
% Linear indices of pairs used in each depth-bin fit, sorted by separation.

kbin = cell(length(z),1);
for ibin = 1:length(z)
    k = find(Z0 >= z(ibin)- nzfit*dz/2 & Z0 <= z(ibin)+ nzfit*dz/2);
    [Ri,isort] = sort(R(k));
    k = k(isort);
    kbin{ibin} = k(Ri <= rmax & Ri >= rmin);
end

end

