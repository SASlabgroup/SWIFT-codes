function [HRprofile,fh] = processSIGburst(burst,opt)

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
z = opt.xz + bz + dz*(1:nbin)';

% Find Spikes (phase-shift threshold, Shcherbina 2018)
L = bz+dz*nbin; % m, pulse distance
F0 = 10^6; % Hz, pulse carrier frequency (1 MHz for Sig 1000)
cs = mean(burst.SoundSpeed,'omitnan'); % m/s, sound speed
Vr = cs.^2./(4*F0*L);% m/s
nfilt = round(1/dz);% 1 m
[winterp,ispike] = despikeSIG(w,nfilt,Vr/2,'interp');

%%%%%% Velocity Profile %%%%%%
HRprofile.w = mean(winterp,2,'omitnan');
HRprofile.wvar = var(winterp,[],2,'omitnan');
HRprofile.z = z;

%%%%%% Dissipation Estimates %%%%%%

% 1) Spatial High-pass
nsm = round(2/dz); % 1 m
wphp = winterp - smooth_mat(winterp',hann(nsm))';

% 2) EOF High-pass using interpolated data 
badping = sum(ispike)./nbin > 0.5;% | std(wphp,[],'omitnan') > 0.01; 
%   - remove worst pings to get good EOFs, then interpolate back in time
%   - alternatively, could use *only* despiked data. This does not
%       work well when data are very noisy/poor quality
eofamp = NaN(size(w'));
[eofs,eofamp(~badping,:),eofvar,~] = eof(winterp(:,~badping)');
if sum(~badping) > 2
    for ieof = 1:nbin
        eofamp(:,ieof) = interp1(find(~badping),eofamp(~badping,ieof),1:nping);
    end
    wpeof = eofs(:,opt.nsumeof+1:end)*(eofamp(:,opt.nsumeof+1:end)');
else
    wpeof = NaN(size(w));
end        

% 3) Estimate dissipation rate from velocity structure functions
ibad = ispike | repmat(badping,nbin,1);
rmin = dz;
rmax = 4*dz;
nzfit = 1;
w(ibad) = NaN;
wpeof(ibad) = NaN;
wphp(ibad) = NaN;

warning('off','all')
% No filter, no analytic wave fit (D ~ r^{-2/3})
[epsNF,qualNF] = SFdissipation(w,z,rmin,2*rmax,nzfit,'linear','mean');
% Analytic wave fit  (D ~ Ar^{-2/3} + Br^2)
[epsWV,qualWV] = SFdissipation(w,z,rmin,2*rmax,nzfit,'cubic','mean');
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
HRprofile.QC.eofsvar = eofvar;
HRprofile.QC.wpeofmag = std(wpeof,[],2,'omitnan')';
HRprofile.QC.hrcorr = mean(corr,2,'omitnan');
HRprofile.QC.hramp = mean(amp,2,'omitnan');
HRprofile.QC.pspike = (sum(ispike,2,'omitnan')./nping);  
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

    % Velocity and Dissipation Profiles
%         fh(2) = figure('color','w');
%         clear b s
%         MP = get(0,'monitorposition');
%         set(gcf,'outerposition',MP(1,:).*[1 1 0.5 1]);
%         subplot(1,2,1)
%         b(1) = errorbar(HRprofile.w,HRprofile.z,sqrt(HRprofile.wvar)./nping,'horizontal');
%         hold on
%         set(b,'LineWidth',2)
%         plot([0 0],[0 20],'k--')
%         xlabel('w [m/s]');
%         title('Velocity')
%         set(gca,'Ydir','reverse')
%         ylim([0 6])
%         xlim([-0.1 0.1])
%         set(gca,'YAxisLocation','right')
%         subplot(1,2,2)
%         s(1) = semilogx(epsNF,z,'k','LineWidth',2);
%         hold on
%         s(2) = semilogx(epsEOF,z,'r','LineWidth',2);
%         s(3) =  semilogx(epsHP,z,'m','LineWidth',2);
%         s(4) = semilogx(epsWV,z,'c','LineWidth',2);
%         xlim(10.^([-9 -3]))
%         ylim([0 6])
%         legend(s,'No-filter','EOF Filter','HP Filter','Analytic Filter','Location','southeast')
%         title('Dissipation')
%         xlabel('\epsilon [W/Kg]'),ylabel('z [m]')
%         set(gca,'Ydir','reverse')
%         set(gca,'YAxisLocation','right')
%         drawnow
else
    fh = [];
end
                   
end

