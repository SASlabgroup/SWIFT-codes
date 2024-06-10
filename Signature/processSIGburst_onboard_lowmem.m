function eps = processSIGburst_onboard_lowmem(wraw,...
    cs,dz,bz,neoflp,rmin,rmax,nzfit,avgtype,fittype)

% w = nbin x nping HR velocity data
% cs = 1 x nping sound speed, from HR data
% dz = 1 x 1 bin size (m);
% bz = 1 x 1 blanking distance (m);
% neoflp = 1 x 1 number of low-mode EOFs to filter from the data;

% ONBOARD NOTES:
% No plotting
% Replace 'opt' structure input with variables
% Burst variables are now inputs
% No need to check dimensions as prespecified   
% Don't interpolate through bad pings 
%  ---- bad pings are currently tossed before computing eps

% LOW MEMORY VERSION NOTES:
% Everytime I create a new version of w, its 4 MB. Should remove at end
% Vast majority is in structure function matrix nbin x nbin x nping

M0 = memory;

% N pings + N z-bins
[nbin,nping] = size(wraw);
xz = 0.2;
z = xz + bz + dz*(1:nbin)';

%%%%%%% Despike %%%%%%%

% Find Spikes (phase-shift threshold, Shcherbina 2018)
L = bz+dz*nbin; % m, pulse distance
F0 = 10^6; % Hz, pulse carrier frequency (1 MHz for Sig 1000)
cs = mean(cs,'omitnan');
Vr = cs.^2./(4*F0*L);% m/s
nfilt = round(1/dz);% 1 m

% Identify Spikes
wfilt = movmedian(wraw,nfilt,'omitnan');
ispike = abs(wraw - wfilt) > Vr/2;% was medfilt1
clear wfilt

% Fill with linear interpolation
winterp = NaN(size(wraw));
for iping = 1:nping    
    igood = find(~ispike(:,iping));
    if length(igood) > 3
    winterp(:,iping) = interp1(igood,wraw(igood,iping),1:nbin,'linear','extrap'); 
    end
end
clear igood

% Memory requirements
M1 = memory;
memdiff = (M1.MemUsedMATLAB - M0.MemUsedMATLAB)*10^(-6);
disp(['Despiking Required: ' num2str(memdiff) ' MB'])

%%%%%% EOF High-pass %%%%%%

% Identify badpings with greater than 50% spikes
badping = sum(ispike)./nbin > 0.5;% 

% Compute EOFs from good pings
X = winterp(:,~badping)';
Xm = nanmean(X);
X = X - Xm;
X(isnan(X)) = 0;
R = X'*X;
[EOFs,E] = eig(R,'vector');
[~,s] = sort(E,'descend');
eofs = EOFs(:,s);
alpha = (X*eofs);
clear X Xm R

% Reconstruct w/high-mode EOFs
wpeof = NaN(size(winterp));
wpeof(:,~badping) = real(eofs(:,neoflp+1:end)*(alpha(:,neoflp+1:end)'));

% Remove spikes 
wpeof(ispike) = NaN;

% Memory requirements
M2 = memory;
memdiff = (M2.MemUsedMATLAB - M1.MemUsedMATLAB)*10^(-6);
disp(['EOF Comp Required: ' num2str(memdiff) ' MB'])

%%%%%% Compute Dissipation Rate %%%%%%
w = wpeof;

% Matrices of all possible data pair separation distances (R), and
% corresponding mean vertical position (Z0)
z = z(:)';
dz = mean(diff(z));
R = z-z';
% R = round(R,2);
R = round(R*100)./100;
[Z1,Z2] = meshgrid(z);
Z0 = (Z1+Z2)/2;

% Matrices of all possible data pair velocity differences for each ping.
dW = repmat(w-mean(w,2,'omitnan'),1,1,nbin);
dW = permute(dW,[1 3 2])-permute(dW,[3 1 2]);
dW(abs(dW) > 5*std(dW,[],3,'omitnan')) = NaN;

% Take mean (or median, or mean-of-the-logs) squared velocity difference to get D(z,r)
if strcmp(avgtype,'mean')
    D = mean(dW.^2,3,'omitnan');
    elseif strcmp(avgtype,'logmean')
        D = 10.^(mean(log10(dW.^2),3,'omitnan'));
    else
        error('Average estimator must be ''mean'' or ''logmean''.')
end

% Fit structure function to theoretical curve
Cv2 = 2.1;
eps = NaN(size(z));
A = NaN(size(z));
for ibin = 1:length(z)

    % Find points in z0 bin
    iplot = Z0 >= z(ibin)- 1.1*nzfit*dz/2 & Z0 <= z(ibin)+ 1.1*nzfit*dz/2;
    Di = D(iplot);
    Ri = R(iplot);
    [Ri,isort] = sort(Ri);
    Di = Di(isort);

    % Select points within specified separation scale range
    ifit = Ri <= rmax & Ri >= rmin; 
    nfit = sum(ifit);
    if nfit < 3 % Must contain more than 3 points
        continue
        
    end
    xN = ones(nfit,1);
    x1 = Ri(ifit).^(2/3);
    x3 = x1.^3;
    d = Di(ifit);    
    
    %Fit Structure function to theoretical curves
    if strcmp(fittype,'cubic')
        
        % Fit structure function to D(z,r) = Br^2 + Ar^(2/3) + N
        G = [x3(:) x1(:) xN(:)];
        Gg = (G'*G)\G';
        m = Gg*d(:);
        A(ibin) = m(2);
        
    elseif strcmp(fittype,'linear')
        
            % Fit structure function to D(z,r) = Ar^(2/3) + N
            G = [x1(:) xN(:)];
            Gg = (G'*G)\G';
            m = Gg*d(:);
            A(ibin) = m(1);
            
    elseif strcmp(fittype,'log')
        
            % Don't presume a slope
            d = d(x1>0);
            xN = xN(x1>0);
            x1 = x1(x1>0);
            x1log = log10(x1);
            dlog = log10(d);
            G = [x1log(:) xN(:)];
            Gg = (G'*G)\G';
            m = Gg*dlog(:);
            A(ibin) = 10.^(m(2));   

    else
        error('Fit type must be ''linear'', ''cubic'' or ''log''')
    end


    eps(ibin) = (A(ibin)./Cv2).^(3/2);      
end

% Remove unphysical values
eps(A<0) = NaN;

% Memory requirements
M3 = memory;
memdiff = (M3.MemUsedMATLAB - M2.MemUsedMATLAB)*10^(-6);
disp(['Dissipation Comp Required: ' num2str(memdiff) ' MB'])
