function [HRprofile,fh] = processAQHburst(burst,opt)
    
%     % Default values
%     opt.xz = 0.2;
%     opt.nsumeof = 5;
%     opt.plotburst = true;
%     opt.lsm = 0.12;
%     opt.dz = 0.04;
%     opt.bz = 0.1;

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
    z = opt.xz - opt.bz - opt.dz*(1:nbin)';

    % Find Spikes + High Pass
    nsm = round(opt.lsm/opt.dz); % 0.16 m
    wlp = smooth_mat(w',hann(nsm))';
    wphp = w - wlp; 
    wstd = std(wphp);
    ispike = abs(wphp) > 3*wstd;
    wclean = w;wclean(ispike) = NaN;
    
    %%%%%% Velocity Profile %%%%%%
    HRprofile.w = mean(wclean,2,'omitnan');
    HRprofile.wvar = var(wclean,[],2,'omitnan');
    HRprofile.z = z;
    
    %%%%%% Dissipation Estimates %%%%%%

    % 1) Spatial High-pass

    % 2) EOF High-pass using interpolated data 
    badping = sum(ispike)./nbin > 0.6; 
    %   - remove worst pings to get good EOFs, then interpolate back in time
    %   - alternatively, could use *only* despiked data. This does not
    %       work well when data are very noisy/poor quality
    eofamp = NaN(size(w'));
    [eofs,eofamp(~badping,:),eofvar,~] = eof(wclean(:,~badping)');
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
    rmin = opt.dz;
    rmax = 4*opt.dz;
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

    % Plot Burst 
    if opt.plotburst
        
        % Visualize Data
        fh(1) = figure('color','w');
        clear c
        MP = get(0,'monitorposition');
        set(gcf,'outerposition',MP(1,:).*[1 1 1 1]);
        subplot(4,1,1)
        imagesc(amp);set(gca,'YDir','normal')
        caxis([50 160]); cmocean('amp')
        title('HR Data');
        ylabel('Bin #')
        c = colorbar;c.Label.String = 'A (dB)';
        subplot(4,1,2)
        imagesc(corr);set(gca,'YDir','normal')
        caxis([35 100]);cmocean('amp')
        ylabel('Bin #')
        c = colorbar;c.Label.String = 'C (%)';
        subplot(4,1,3)
        imagesc(w);set(gca,'YDir','normal')
        caxis([-0.5 0.5]);cmocean('balance');
        ylabel('Bin #')
        c = colorbar;c.Label.String = 'U_r(m/s)';
        subplot(4,1,4)
        imagesc(ispike);set(gca,'YDir','normal')
        caxis([0 2]);colormap(gca,[rgb('white'); rgb('black')])
        ylabel('Bin #')
        c = colorbar;c.Ticks = [0.5 1.5];
        c.TickLabels = {'Good','Spike'};
        xlabel('Ping #')
        drawnow
        

        % Velocity and Dissipation Profiles
        fh(2) = figure('color','w');
        clear b s
        MP = get(0,'monitorposition');
        set(gcf,'outerposition',MP(1,:).*[1 1 0.5 1]);
        subplot(1,2,1)
        b(1) = errorbar(HRprofile.w,HRprofile.z,sqrt(HRprofile.wvar)./nping,'horizontal');
        hold on
        set(b,'LineWidth',2)
        plot([0 0],[0 20],'k--')
        xlabel('w [m/s]');
        title('Velocity')
        set(gca,'Ydir','reverse')
        ylim([0 6])
        xlim([-0.1 0.1])
        set(gca,'YAxisLocation','right')
        subplot(1,2,2)
        s(1) = semilogx(epsNF,z,'k','LineWidth',2);
        hold on
        s(2) = semilogx(epsEOF,z,'r','LineWidth',2);
        s(3) =  semilogx(epsHP,z,'m','LineWidth',2);
        s(4) = semilogx(epsWV,z,'c','LineWidth',2);
        xlim(10.^([-9 -3]))
        ylim([0 6])
        legend(s,'No-filter','EOF Filter','HP Filter','Analytic Filter','Location','southeast')
        title('Dissipation')
        xlabel('\epsilon [W/Kg]'),ylabel('z [m]')
        set(gca,'Ydir','reverse')
        set(gca,'YAxisLocation','right')
        drawnow
    else
        fh = [];
    end
                   
end


