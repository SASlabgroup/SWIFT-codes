function eps = processSIGburst_onboard_lowmem(w,cs,dz,bz,neoflp,rmin,rmax,nzfit,avgtype,fittype)

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
% Vast majority of memory suck is in structure function matrix nbin x nbin x nping
% Replaced linear algebra method w/loops -- saved 530+ MB 

% M0 = memory;
% M0 = M0.MemUsedMATLAB;

% N pings + N z-bins
[nbin,nping] = size(w);
z = 0.2 + bz + dz*(1:nbin)';

%% Despike

% Find Spikes (phase-shift threshold, Shcherbina 2018)
L = bz+dz*nbin; % m, pulse distance
F0 = 10^6; % Hz, pulse carrier frequency (1 MHz for Sig 1000)
cs = mean(cs,'omitnan');
Vr = cs.^2./(4*F0*L);% m/s
nfilt = round(1/dz);% 1 m

% Identify Spikes
ispike = abs(w - movmedian(w,nfilt,'omitnan')) > Vr/2;% was medfilt1

% Linearly interpolate through spikes
for iping = 1:nping    
    igood = find(~ispike(:,iping));
    if length(igood) > 3
    w(:,iping) = interp1(igood,w(igood,iping),1:nbin,'linear','extrap'); 
    end
end

%% Peform EOF High-pass

% Identify badpings with greater than 50% spikes
badping = sum(ispike)./nbin > 0.5;% 

% Compute EOFs from good pings
X = w(:,~badping)';
Xm = mean(X,'omitnan');
X = X - Xm;
X(isnan(X)) = 0;
R = X'*X;
[EOFs,E] = eig(R,'vector');
[~,s] = sort(E,'descend');
eofs = EOFs(:,s);
alpha = (X*eofs);
%clear X Xm R

% Reconstruct w/high-mode EOFs
wp = NaN(size(w));
wp(:,~badping) = real(eofs(:,neoflp+1:end)*(alpha(:,neoflp+1:end)'));

% Remove spikes
wp(ispike) = NaN;

%% Compute Structure Function

% Matrices of all possible data pair separation distances (R) and
%   corresponding mean vertical position (Z0)
z = z(:)';
dz = mean(diff(z));
R = z-z';
% R = round(R,2);
R = round(R*100)./100;
[Z1,Z2] = meshgrid(z);
Z0 = (Z1+Z2)/2;

% Remove time-mean from turbulent velocities
wp = wp - mean(wp,2,'omitnan');

% Mean squared velocity bin-pair squared differences
D = NaN(nbin,nbin);
for i = 1:nbin
    for j = 1:nbin
        dwpij = wp(i,:) - wp(j,:);
        iout = abs(dwpij) > 5*std(dwpij,'omitnan');
        dwpij(iout) = NaN;% remove > 5*sigma
        if strcmp(avgtype,'mean')
        D(i,j) = mean(dwpij.^2,'omitnan');
        elseif strcmp(avgtype,'logmean')
            D(i,j) = 10.^(mean(log10(dwpij.^2),'omitnan'));
        else
            error('Average Estimator must be ''mean'' or ''logmean''.')
        end
    end
end

%% Calculate Dissipation Rate

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

%% Memory
% MF = memory;
% MF = MF.MemUsedMATLAB;
% memused = MF-M0;
% disp(['Function used ' num2str(memused*10^(-6)) ' MB'])
