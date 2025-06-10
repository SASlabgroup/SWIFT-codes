function [profile,fh] = processSIGavg(avg,opt)

%    Check to make sure dimensions correct
    if size(avg.VelocityData,3) ~= 4
        disp('   Broadband data dimensions bad')
        profile = [];
        fh = [];
        return
    end

    % Data
    time = avg.time;
    amp = avg.AmplitudeData;
    corr = avg.CorrelationData;
    vel = avg.VelocityData;
    z = opt.xz + avg.Blanking + avg.CellSize*(1:size(avg.VelocityData,2))';
    temp = filloutliers(avg.Temperature,'linear');

    % Raw velocity profiles & standard error
    nping = length(time);
    nbin = length(z);
    iQC = false(size(vel));

    % QC: flag corr minimum values
    if opt.QCbin
        ibadbin = squeeze(mean(corr,1,'omitnan')) < opt.mincorr;
        ibadbin = repmat(ibadbin,1,1,nping);
        ibadbin = permute(ibadbin,[3 1 2]);
        iQC(ibadbin) = true;
    end

    % QC: flag fish w/ anomalously high amplitude: look for heavily skewed distributions
    ifish = false(size(amp));
    if opt.QCfish
        for ibeam = 1:4
            for ibin = 1:nbin
                [a,b] = hist(squeeze(amp(:,ibin,ibeam)));
                if sum(a) == 0
                    continue
                end
                [~,j] = max(a);
                if j == 1
                    ampfloor = b(1)+5;
                    ifish(:,ibin,ibeam) = amp(:,ibin) > ampfloor;
                end
            end
        end
        iQC(ifish) = true;
    end

    % Apply QC
    velqc = vel;
    velqc(iQC) = NaN;

    % Plot beam data and QC flags
    if opt.plotburst
        badany = zeros(size(vel));
        badany(ibadbin) = 1;
        badany(ifish) = 2;
        clear c
        QCcolor = [rgb('white');rgb('red');rgb('blue')];
        fh(1) = figure('color','w');
        MP = get(0,'monitorposition');
        set(gcf,'outerposition',MP(1,:).*[1 1 1 1]);
        for ibeam = 1:4
            subplot(5,4,ibeam+0*4)
            imagesc(squeeze(amp(:,:,ibeam))')
            clim([50 160]); cmocean('amp')
            title(['Beam ' num2str(ibeam)]);
            if ibeam == 1; ylabel('Bin #'); end
            if ibeam == 4;pos = get(gca,'Position');c(1) = colorbar;set(gca,'Position',pos);end
            subplot(5,4,ibeam+1*4)
            imagesc(squeeze(corr(:,:,ibeam))')
            clim([opt.mincorr-5 100]);  cmocean('amp')
            if ibeam == 1; ylabel('Bin #'); end
            if ibeam == 4;pos = get(gca,'Position');c(2) = colorbar;set(gca,'Position',pos);end
            subplot(5,4,ibeam+2*4)
            imagesc(squeeze(vel(:,:,ibeam))')
            clim([-0.5 0.5]);cmocean('balance');
            if ibeam == 1; ylabel('Bin #'); end
            if ibeam == 4;pos = get(gca,'Position');c(3) = colorbar;set(gca,'Position',pos);end
            subplot(5,4,ibeam+3*4)
            imagesc(squeeze(badany(:,:,ibeam))')
            clim([0 2]);colormap(gca,QCcolor)
            if ibeam == 1; ylabel('Bin #'); end
            if ibeam == 4;pos = get(gca,'Position');c(4) = colorbar;set(gca,'Position',pos);end
            subplot(5,4,ibeam+4*4)
            bincolor = jet(nbin);
            for ibin = 1:nbin
            vbin = squeeze(vel(:,ibin,ibeam));
             [PS,F,~] = hannwinPSD2(vbin,60,1,'par');
            loglog(F,PS,'color',bincolor(ibin,:))
            hold on
            end
            if ibeam == 1;ylabel('E [m^2s^{-2}]');end
            xlabel('F (Hz)')
            ylim(10.^[-3 0])
            xlim([min(F) max(F)])
            if ibeam == 4;pos = get(gca,'Position');c(5) = colorbar;set(gca,'Position',pos);end
            colormap(gca,jet)
        end
        c(1).Label.String = 'A (dB)';
        c(2).Label.String = 'C (%)';
        c(3).Label.String = 'U_r(m/s)';
        c(4).Ticks = [0.25 1 1.75];c(4).TickLabels = {'Good','Bad Bin','Fish'};
        c(5).Label.String = 'Bin #';c(5).TickLabels = num2str((c(5).Ticks')*nbin);
        drawnow
        
    else
        fh = [];
    end

    % Compute burst averaged velocity profiles
    u = squeeze(mean(velqc,1,'omitnan'));
    uvar = squeeze(var(velqc,[],1,'omitnan'));

    % Compute alternate shear profile (compute spd before averaging, fix for bad HPR)
    [~,spd_alt,~] = altSIGenu(avg,mean(avg.Heading,'omitnan'));
    iNaN = isnan(mean(u(:,[1 2 4]),2,'omitnan'));
    if opt.QCbin
        spd_alt(iNaN) = NaN;
    end

    % Separate U, V, W
    profile.z = z;
    profile.w = u(:,4);
    profile.v = u(:,2);
    profile.u = u(:,1);
    profile.wvar = uvar(:,4);
    profile.vvar = uvar(:,2);
    profile.uvar = uvar(:,1);
    profile.temp = mean(temp(1:round(end/4)),'omitnan');
    profile.spd_alt = spd_alt;

    % QC
    profile.QC.ucorr = squeeze(mean(corr(:,:,1)));
    profile.QC.vcorr = squeeze(mean(corr(:,:,2)));
    profile.QC.wcorr = squeeze(mean(corr(:,:,4)));
    profile.QC.uamp = squeeze(mean(amp(:,:,1)));
    profile.QC.vamp = squeeze(mean(amp(:,:,2)));
    profile.QC.wamp = squeeze(mean(amp(:,:,4)));
    
end

