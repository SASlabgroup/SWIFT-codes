function [HRprofile,fh] = processSIGburst(burst,opt)
% NOTE: Quality Control
%   - remove worst pings to get good EOFs, then interpolate back in time
%   - alternatively, could use *only* despiked data. This does not
%       work well when data are very noisy/poor quality

%    Check to make sure dimensions correct
if length(size(burst.VelocityData)) > 2
    disp('   HR data dimensions bad')
    HRprofile = [];
    fh = [];
    return
end

% Data
corr = burst.CorrelationData';
amp = burst.AmplitudeData';
w = -burst.VelocityData';

% N pings + N z-bins
[nbin,nping] = size(w);
dz = burst.CellSize;
bz = burst.Blanking;
xz = opt.xz;
z = xz + bz + dz*(1:nbin)';

% Despike (phase-shift threshold, Shcherbina 2018)
L = bz+dz*nbin; % m, pulse distance
F0 = 10^6; % Hz, pulse carrier frequency (1 MHz for Sig 1000)
cs = mean(burst.SoundSpeed,'omitnan'); % m/s, sound speed
Vr = cs.^2./(4*F0*L);% m/s
nfilt = round(1/dz);% 1 m
[wdespike,ispike] = despikeSIG(w,nfilt,Vr/2,'interp');

%%%%%% Velocity Profile %%%%%%
HRprofile.w = mean(wdespike,2,'omitnan');
HRprofile.wvar = var(wdespike,[],2,'omitnan');
HRprofile.z = z;

%%%%%% Dissipation Estimates %%%%%%

% 0) NaN bad bins (spike percentage of data in a bin > 70 %)'; remove bad pings ( > 50% in a ping)
pspike = 100*(sum(ispike,2,'omitnan')./nping);
badbin = pspike > opt.pspikemaxbin;
wcrop = wdespike;
if opt.cropbin
wcrop(badbin,:) = NaN;
badping = 100*sum(ispike(~badbin,:))./sum(~badbin) > opt.pspikemaxping;% | std(wphp,[],'omitnan') > 0.01; 
else
    badping = 100*sum(ispike,'omitnan')./nbin > opt.pspikemaxping;
end
wcrop(:,badping) = NaN;

% if opt.nanspike
%     wcrop(ispike) = NaN;
% end

% 1) No filter
wnf = wcrop;

% 2) Spatial High-pass
nsm = round(2/dz); % 1 m
wphp = wcrop - smooth_mat(wcrop',hann(nsm))';

% 3) EOF High-pass using interpolated data 
[eofs,eofamp,eofvar,~] = eof(wcrop');
wpeof = eofs(:,opt.nsumeof+1:end)*(eofamp(:,opt.nsumeof+1:end)');

% 4) Estimate dissipation rate from velocity structure functions
rmin = dz;
rmax = 4*dz;
nzfit = 1;

if opt.nanspike
    wnf(ispike) = NaN;
    wpeof(ispike) = NaN;
    wphp(ispike) = NaN;
end

warning('off','all')
% No filter, no analytic wave fit (D ~ r^{-2/3})
[epsNF,qualNF] = SFdissipation(wnf,z,rmin,2*rmax,nzfit,'linear','mean');
% Analytic wave fit  (D ~ Ar^{-2/3} + Br^2)
[epsWV,qualWV] = SFdissipation(wnf,z,rmin,2*rmax,nzfit,'cubic','mean');
% EOF filter (D ~ r^{-2/3})
[epsEOF,qualEOF] = SFdissipation(wpeof,z,rmin,rmax,nzfit,'linear','mean');
% High-pass filter (D ~ r^{-2/3})
[epsHP,qualHP] = SFdissipation(wphp,z,rmin,rmax,nzfit,'linear','mean');
warning('on','all')

% Save Dissipation Results
HRprofile.eps = epsEOF';% Presumed to be best estimate

% Additional information for quality control
HRprofile.QC.epsNF = epsNF';
HRprofile.QC.epsWV = epsWV'; 
HRprofile.QC.epsHP = epsHP';
HRprofile.QC.epsEOF = epsEOF';
HRprofile.QC.qualNF = qualNF;
HRprofile.QC.qualWV = qualWV;
HRprofile.QC.qualHP = qualHP;
HRprofile.QC.qualEOF = qualEOF;
HRprofile.QC.eofs = eofs;
HRprofile.QC.eofvar = eofvar;
HRprofile.QC.eofamp = eofamp';
HRprofile.QC.wpeofmag = std(wpeof,[],2,'omitnan')';
HRprofile.QC.hrcorr = mean(corr,2,'omitnan');
HRprofile.QC.hramp = mean(amp,2,'omitnan');
HRprofile.QC.pspike = pspike;  
HRprofile.QC.pbadping = sum(badping)./nping;

% Plot Burst 
if opt.plotburst
    
    % Visualize Data
    fh(1) = figure('color','w');
    clear c
    MP = get(0,'monitorposition');
    set(gcf,'outerposition',MP(1,:).*[1 1 1 1]);
    subplot(5,1,1)
    imagesc(amp)
    caxis([50 160]); cmocean('amp')
    title('HR Data');
    ylabel('Bin #')
    c = colorbar;c.Label.String = 'A (dB)';
    subplot(5,1,2)
    imagesc(corr)
    caxis([35 100]);cmocean('amp')
    ylabel('Bin #')
    c = colorbar;c.Label.String = 'C (%)';
    subplot(5,1,3)
    imagesc(w)
    caxis([-0.5 0.5]);cmocean('balance');
    ylabel('Bin #')
    c = colorbar;c.Label.String = 'W_r (m/s)';
    subplot(5,1,4)
    imagesc(ispike)
    caxis([0 2]);colormap(gca,[rgb('white'); rgb('black')])
    ylabel('Bin #')
    c = colorbar;c.Ticks = [0.5 1.5];
    c.TickLabels = {'Good','Spike'};
    subplot(5,1,5)
    imagesc(wpeof)
    ylabel('Bin #')
    caxis([-0.05 0.05]);cmocean('balance')
    c = colorbar;c.Label.String = 'W_hp (m/s)';

    xlabel('Ping #')
    drawnow
else
    fh = [];
end
                   
end

