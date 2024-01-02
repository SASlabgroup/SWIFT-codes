function [eps,qual] = SFdissipation(w,z,rmin,rmax,nzfit,fittype,avgtype)
% This function applies Taylor cascade theory to estimate dissipation from 
% the second order velocity structure function computed from vertical profiles 
% of turbulent velocity (see Wiles et al. 2006). SFdissipation was
% formulated with data from the Nortek Signature 1000 ADCP operating in pulse-coherent
% (HR) mode, but can be applied to any ensemble of velocity profiles.
%       
%   in:     w (or dW)  nbin x nping ensemble of velocity profiles. Ensemble averaging
%                           occurs across the 'ping' dimension. Can alternatively 
%                           input the velocity difference matrix (dW).
%           z           1 x nbin, negative values (forced if not)
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
%           avgtype     either 'mean','logmean' or 'median', determines whether the
%                           mean of squares, mean of the log of squares, or median of squares
%                           is taken to determine the expected value of the squared velocity difference
%
%   out:    eps         1 x nbin profile of dissipation
%           qual        structure with metrics for evaluating quality of eps including:
%                       - mean square percent error of the fit (mspe), 
%                       - propagated error of the fit (epserr), 
%                       - ADCP error inferred from the SF intercept (N), 
%                       - slope of the SF (slope), 
%                       - wave term coefficient (B, if modified r^2 fit used).

%           K.Zeiden Summer/Fall 2022

% Return control to calling function/script if all NaN data
nz = length(z);
if ~any(~isnan(w(:)))
    eps = NaN(1,nz);
    qual.mspe = NaN(1,nz);
    qual.slope = NaN(1,nz);
    qual.epserr = NaN(1,nz);
    qual.A = NaN(1,nz);
    qual.B = NaN(1,nz);
    qual.N = NaN(1,nz);
    return
end

% Matrices of all possible data pair separation distances (R), and
% corresponding mean vertical position (Z0)
z = -abs(z(:)');
dz = median(diff(z));
R = z-z';
R = round(R,2);
[Z1,Z2] = meshgrid(z);
Z0 = (Z1+Z2)/2;

% Matrices of all possible data pair velocity differences for each ping.
%   Points greater than +/- 5 standard deviation are removed from each dist.
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

% Take mean (or median, or mean-of-the-logs) squared velocity difference to get D(z,r)
if strcmp(avgtype,'mean')
    D = mean(dW.^2,3,'omitnan');
    elseif strcmp(avgtype,'logmean')
        D = 10.^(mean(log10(dW.^2),3,'omitnan'));
    elseif strcmp(avgtype,'median')
        D = median(dW.^2,3,'omitnan');
    else
        error('Average estimator must be ''mean'', ''logmean'' or ''median''.')
end

%Standard Error on the mean
Derr = sqrt(var(dW.^2,[],3,'omitnan')./sum(~isnan(dW),3));

%Fit structure function to theoretical curve
Cv2 = 2.1;
eps = NaN(size(z));
epserr = eps;
A = NaN(size(z));
B = NaN(size(z));
Aerr = NaN(size(z));
N = NaN(size(z));
mspe = NaN(size(z));
slope = NaN(size(z));
for ibin = 1:length(z)

    %Find points in z0 bin
    iplot = Z0 >= z(ibin)- nzfit*dz/2 & Z0 <= z(ibin)+ nzfit*dz/2;
    Di = D(iplot);
    Dierr = Derr(iplot);
    Ri = R(iplot);
    [Ri,isort] = sort(Ri);
    Di = Di(isort);
    Dierr = Dierr(isort);

    %Select points within specified separation scale range
    ifit = Ri <= rmax & Ri >= rmin; 
    nfit = sum(ifit);
    if nfit < 3 % Must contain more than 3 points
        continue       
    end
    xN = ones(nfit,1);
    x1 = Ri(ifit).^(2/3);
    x3 = x1.^3;
    d = Di(ifit);
    derr = mean(Dierr(ifit),'omitnan');
    
    %Best-fit power-law to the structure function
    ilog = x1 > 0 & d > 0;% log(0) = -Inf
    x1log = log10(x1(ilog));
    dlog = log10(d(ilog));
    xNlog = xN(ilog);
    G = [x1log(:) xNlog(:)];
    Gg = (G'*G)\G';
    m = Gg*dlog(:);
    slope(ibin) = m(1);  
    
    %Fit Structure function to theoretical curves
    if strcmp(fittype,'cubic')
        
        % Fit structure function to D(z,r) = Br^2 + Ar^(2/3) + N
        G = [x3(:) x1(:) xN(:)];
        Gg = (G'*G)\G';
        m = Gg*d(:);
        B(ibin) = m(1);
        A(ibin) = m(1);
        
        %Remove model shear term & fit Ar^(2/3) to residual
        dmod = d-B(ibin)*x3;
        G = [x1(:) xN(:)];
        Gg = (G'*G)\G';
        m = Gg*dmod(:);
        dm = G*m;
        imse = abs(dm) > 10^(-8);
        mspe(ibin) =  mean(((dm(imse)-dmod(imse))./dm(imse)).^2);
        A(ibin) = m(1);
        N(ibin) = m(2);
        merr = sqrt(diag(derr.^2*((G'*G)^(-1))));
        Aerr(ibin) = merr(1);
        
        % Slope of residual structure function
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
            G = [x1(:) xN(:)];
            Gg = (G'*G)\G';
            m = Gg*d(:);
            dm = G*m;
            imse = abs(dm) > 10^(-8);
            mspe(ibin) =  mean(((dm(imse)-d(imse))./dm(imse)).^2);
            A(ibin) = m(1);
            N(ibin) = m(2);
            merr = sqrt(diag(derr.^2*((G'*G)^(-1))));
            Aerr(ibin) = merr(1);
            
    elseif strcmp(fittype,'log')
        
            d = d(x1>0);
            xN = xN(x1>0);
            x1 = x1(x1>0);
            x1log = log10(x1);
            dlog = log10(d);
            G = [x1log(:) xN(:)];
            Gg = (G'*G)\G';
            m = Gg*dlog(:);
            dm = G*m;
            imse = abs(dm) > 10^(-8);
            mspe(ibin) =  mean(((dm(imse)-d(imse))./dm(imse)).^2);
            slope(ibin) = m(1);
            A(ibin) = 10.^(m(2));   
            merr = sqrt(diag(derr.^2*((G'*G)^(-1))));
            Aerr(ibin) = merr(2);
            
    else
        error('Fit type must be ''linear'', ''cubic'' or ''log''')
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

