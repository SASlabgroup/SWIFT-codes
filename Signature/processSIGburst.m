function [HRprofile,fh] = processSIGburst(burst,opt)

    % Initialize bad burst flag
    badburst = false;

    % Check to make sure dimensions correct
    % NOTE: need tocatch error in reprocess_SIG
    if length(size(burst.VelocityData)) > 2
        disp('   HR data dimensions bad')
        badburst = true;
    end
    
    % Data
    hrtime = burst.time;
    hrcorr = burst.CorrelationData';
    hramp = burst.AmplitudeData';
    hrvel = -burst.VelocityData';

    % N pings + N z-bins
    [nbin,nping] = size(hrvel);
    dz = burst.CellSize;
    bz = burst.Blanking;
    hrz = opt.xz + bz + dz*(1:nbin);
    dt = ( max(hrtime) - min(hrtime) ) ./nping*24*3600; %range(hrtime)./nping*24*3600;

    % Find Spikes (phase-shift threshold, Shcherbina 2018)
    L = bz+dz*nbin; % m
    F0 = 10^6; % Hz, pulse carrier frequency (1 MHz for Sig 1000)
    cs = mean(burst.SoundSpeed,'omitnan'); % m/s
    Vr = cs.^2./(4*F0*L);% m/s
    nfilt = round(1/dz);% 1 m
    [wclean,ispike] = despikeSIG(hrvel,nfilt,Vr/2,'interp');
    
    %%%%%% Abort if spikes > 70% of the data (arbitrary, sigh) %%%%%%
    if sum(ispike(:))/numel(hrvel) > 0.7
        disp('   HR data spike percentage > 70%')
        badburst = true;
    end
    
    %%%%%% Velocity Profile %%%%%%%%
    hrw = nanmean(wclean,2);
    hrwvar = var(wclean,[],2,'omitnan');

    %%%%%% Dissipation Estimates %%%%%%
    
    if ~badburst

    % Sampling rate and window size
    fs = 1/dt; nwin = 64;
    if nwin > nping
    nwin = nping;
    end
    
    % 1) Spatial High-pass
    nsm = round(2/dz); % 1 m
    wphp = wclean - smooth_mat(wclean',hann(nsm))';

    % 2) EOF High-pass (remove worst pings to get good EOFs)
    badping = sum(ispike)./nbin > 0.6; % | std(wphp,[],'omitnan') > 0.01;
    eof_amp = NaN(nping,nbin);
    [eofs,eof_amp(~badping,:),~,~] = eof(wclean(:,~badping)');
    for ieof = 1:nbin
        eof_amp(:,ieof) = interp1(find(~badping),eof_amp(~badping,ieof),1:nping);
    end
    wpeof = eofs(:,opt.nsumeof+1:end)*(eof_amp(:,opt.nsumeof+1:end)');
    
    %Structure Function Dissipation
    ibad = ispike | repmat(badping,nbin,1);
    rmin = dz;
    rmax = 4*dz;
    nzfit = 1;
    w = wclean;
    wp1 = wpeof;
    wp2 = wphp;
    w(ibad) = NaN;
    wp1(ibad) = NaN;
    wp2(ibad) = NaN;
    warning('off','all')
    [eps_struct0,qual0] = SFdissipation(w,hrz,rmin,2*rmax,nzfit,'cubic','mean');
    [eps_structEOF,qualEOF] = SFdissipation(wp1,hrz,rmin,rmax,nzfit,'linear','mean');
    [eps_structHP,qualHP] = SFdissipation(wp2,hrz,rmin,rmax,nzfit,'linear','mean');
    warning('on','all')

    % Save results to struture
    HRprofile.w = hrw;
    HRprofile.wvar = hrwvar;
    HRprofile.z = hrz';
    HRprofile.eps_struct0 = eps_struct0';
    HRprofile.eps_structHP = eps_structHP';
    HRprofile.eps_structEOF = eps_structEOF';
    
    % Save QC params to structure    
    HRprofile.QC.wmag = mean(abs(wclean),2,'omitnan')';
    HRprofile.QC.wmag0 = mean(abs(hrvel),2,'omitnan')';
    HRprofile.QC.w0 = mean(hrvel,2,'omitnan')';
    HRprofile.QC.wvar0 = var(hrvel,[],2,'omitnan')';
    HRprofile.QC.wpvar = var(wpeof,[],2,'omitnan')';
    HRprofile.QC.hrcorr = mean(hrcorr,2,'omitnan')';
    HRprofile.QC.hramp = mean(hramp,2,'omitnan')';
    HRprofile.QC.hrampvar = var(hramp,[],2,'omitnan')';
    HRprofile.QC.hrcorrvar = var(hrcorr,[],2,'omitnan')';
    HRprofile.QC.mspe0 = qual0.mspe;
    HRprofile.QC.mspeHP = qualHP.mspe;
    HRprofile.QC.mspeEOF = qualEOF.mspe;
    HRprofile.QC.slope0 = qual0.slope;
    HRprofile.QC.slopeHP = qualHP.slope;
    HRprofile.QC.slopeEOF = qualEOF.slope;
    HRprofile.QC.epserr0 = qual0.epserr;
    HRprofile.QC.epserrHP = qualHP.epserr;
    HRprofile.QC.epserrEOF = qualEOF.epserr;       
    HRprofile.QC.N0 = qual0.N;
    HRprofile.QC.NHP = qualHP.N;
    HRprofile.QC.NEOF = qualEOF.N;    
    HRprofile.QC.pspike = (sum(ispike,2,'omitnan')./nping)';
    
    else
        disp('   Bad burst, skipping dissipation...')
        % Bad burst, save NaNs to struture
        HRprofile.w = hrw;
        HRprofile.wvar = hrwvar;
        HRprofile.z = hrz';
        HRprofile.eps_struct0 = NaN(size(hrw))';
        HRprofile.eps_structHP = NaN(size(hrw))';
        HRprofile.eps_structEOF = NaN(size(hrw))';
        HRprofile.QC.wmag = NaN(size(hrw));
        HRprofile.QC.wmag0 = NaN(size(hrw));
        HRprofile.QC.w0 = NaN(size(hrw));
        HRprofile.QC.wvar0 = NaN(size(hrw));
        HRprofile.QC.wpvar = NaN(size(hrw));
        HRprofile.QC.hrcorr = NaN(size(hrw));
        HRprofile.QC.hramp = NaN(size(hrw));
        HRprofile.QC.hrampvar = NaN(size(hrw));
        HRprofile.QC.hrcorrvar = NaN(size(hrw));
        HRprofile.QC.mspe0 = NaN(size(hrw));
        HRprofile.QC.mspeHP = NaN(size(hrw));
        HRprofile.QC.mspeEOF = NaN(size(hrw));
        HRprofile.QC.slope0 = NaN(size(hrw));
        HRprofile.QC.slopeHP = NaN(size(hrw));
        HRprofile.QC.slopeEOF = NaN(size(hrw));
        HRprofile.QC.epserr0 = NaN(size(hrw));
        HRprofile.QC.epserrHP = NaN(size(hrw));
        HRprofile.QC.epserrEOF = NaN(size(hrw));       
        HRprofile.QC.N0 = NaN(size(hrw));
        HRprofile.QC.NHP = NaN(size(hrw));
        HRprofile.QC.NEOF = NaN(size(hrw));    
        HRprofile.QC.pspike = NaN(size(hrw));
    end

    % Plot Burst 
    if opt.plotburst
        
        % Visualize Data
        fh(1) = figure('color','w');
        clear c
        MP = get(0,'monitorposition');
        set(gcf,'outerposition',MP(1,:).*[1 1 1 1]);
        subplot(4,1,1)
        imagesc(hramp)
        caxis([50 160]); cmocean('amp')
        title('HR Data');
        ylabel('Bin #')
        c = colorbar;c.Label.String = 'A (dB)';
        subplot(4,1,2)
        imagesc(hrcorr)
        caxis([35 100]);cmocean('amp')
        ylabel('Bin #')
        c = colorbar;c.Label.String = 'C (%)';
        subplot(4,1,3)
        imagesc(hrvel)
        caxis([-0.5 0.5]);cmocean('balance');
        ylabel('Bin #')
        c = colorbar;c.Label.String = 'U_r(m/s)';
        subplot(4,1,4)
        imagesc(ispike)
        caxis([0 2]);colormap(gca,[rgb('white'); rgb('black')])
        ylabel('Bin #')
        c = colorbar;c.Ticks = [0.5 1.5];
        c.TickLabels = {'Good','Spike'};
        xlabel('Ping #')
        drawnow
        if opt.saveplots
            figname = [savedir SNprocess slash get(gcf,'Name')];
            print(figname,'-dpng')
            close gcf
        end

        % Velocity and Dissipation Profiles
        fh(2) = figure('color','w');
        clear b s
        MP = get(0,'monitorposition');
        set(gcf,'outerposition',MP(1,:).*[1 1 0.5 1]);
        subplot(1,2,1)
        b(1) = errorbar(hrw,hrz,sqrt(hrwvar)./nping,'horizontal');
        hold on
        set(b,'LineWidth',2)
        plot([0 0],[0 20],'k--')
        xlabel('w [m/s]');
        title('Velocity')
        set(gca,'Ydir','reverse')
        ylim([0 6])
        xlim([-0.075 0.075])
        set(gca,'YAxisLocation','right')
        subplot(1,2,2)
        s(1) = semilogx(eps_structEOF,hrz,'r','LineWidth',2);
        hold on
        s(2) =  semilogx(eps_structHP,hrz,':r','LineWidth',2);
        s(3) = semilogx(eps_struct0,hrz,'color',rgb('grey'),'LineWidth',2);
        xlim(10.^([-9 -3]))
        ylim([0 6])
        legend(s,'SF','SF (high-pass)','SF (modified)','Location','southeast')
        title('Dissipation')
        xlabel('\epsilon [W/Kg]'),ylabel('z [m]')
        set(gca,'Ydir','reverse')
        set(gca,'YAxisLocation','right')
        drawnow
        if opt.saveplots
            figname = [savedir SNprocess slash get(gcf,'Name')];
            print(figname,'-dpng')
            close gcf
        end
    else
        fh = [];
    end
                   
end

