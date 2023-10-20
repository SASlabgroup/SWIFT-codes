function [profile,fh] = processSIGavg(avg,opt)

    % Data
    avgtime = avg.time;
    avgamp = avg.AmplitudeData;
    avgcorr = avg.CorrelationData;
    avgvel = avg.VelocityData;
    avgz = opt.xz + avg.Blanking + avg.CellSize*(1:size(avg.VelocityData,2));
    avgtemp = filloutliers(avg.Temperature,'linear');

    % Raw velocity profiles & standard error
    nping = length(avgtime);
    nbin = length(avgz);
    avgu_noqc = squeeze(nanmean(avgvel,1));
    avguerr_noqc = squeeze(nanstd(avgvel,[],1))/sqrt(nping);

    % QC: flag corr minimum values
    lowcorr = avgcorr < opt.mincorr;
    badbin = squeeze(nansum(lowcorr,1)./nping > opt.pbadmax/100); %#ok<*NANSUM>
    badbin = permute(repmat(badbin,1,1,nping),[3 1 2]);
    badping = squeeze(sum(lowcorr,2)./nbin > opt.pbadmax/100);
    badping = permute(repmat(badping,1,1,nbin),[1 3 2]);

    % QC: flag fish w/ anomalously high amplitude: look for heavily skewed distributions
    badfish = false(size(avgamp));
    for ibeam = 1:4
        for ibin = 1:nbin
            [a,b] = hist(squeeze(avgamp(:,ibin,ibeam)));
            if sum(a) == 0
                continue
            end
            [~,j] = max(a);
            if j == 1
                ampfloor = b(1)+5;
                badfish(:,ibin,ibeam) = avgamp(:,ibin) > ampfloor;
            end
        end
    end

    % QC broadband data and recompute velocity profiles & SE
    iQC = false(size(avgvel));
    if opt.QCcorr; iQC(lowcorr) = true; end%#ok<*UNRCH>
    if opt.QCbin; iQC(badbin) = true; end
    if opt.QCping; iQC(badping) = true; end
    if opt.QCfish; iQC(badfish) = true; end
    velqc = avgvel;
    velqc(iQC) = NaN;
    navg = squeeze(sum(~iQC,1));
    avgu = squeeze(nanmean(velqc,1));
    avguvar = squeeze(var(velqc,[],1,'omitnan'));

    % Plot beam data and QC flags
    if opt.plotburst
        badany = zeros(size(lowcorr));
        badany(lowcorr) = 1;
        badany(badfish) = 2;
        clear c
        QCcolor = [rgb('white');rgb('red');rgb('blue')];
        fh(1) = figure('color','w');
        MP = get(0,'monitorposition');
        set(gcf,'outerposition',MP(1,:).*[1 1 1 1]);
        for ibeam = 1:4
            subplot(5,4,ibeam+0*4)
            imagesc(squeeze(avgamp(:,:,ibeam))')
            caxis([50 160]); cmocean('amp')
            title(['Beam ' num2str(ibeam)]);
            if ibeam == 1; ylabel('Bin #'); end
            if ibeam == 4;pos = get(gca,'Position');c(1) = colorbar;set(gca,'Position',pos);end
            subplot(5,4,ibeam+1*4)
            imagesc(squeeze(avgcorr(:,:,ibeam))')
            caxis([opt.mincorr-5 100]);  cmocean('amp')
            if ibeam == 1; ylabel('Bin #'); end
            if ibeam == 4;pos = get(gca,'Position');c(2) = colorbar;set(gca,'Position',pos);end
            subplot(5,4,ibeam+2*4)
            imagesc(squeeze(avgvel(:,:,ibeam))')
            caxis([-0.5 0.5]);cmocean('balance');
            if ibeam == 1; ylabel('Bin #'); end
            if ibeam == 4;pos = get(gca,'Position');c(3) = colorbar;set(gca,'Position',pos);end
            subplot(5,4,ibeam+3*4)
            imagesc(squeeze(badany(:,:,ibeam))')
            caxis([0 2]);colormap(gca,QCcolor)
            if ibeam == 1; ylabel('Bin #'); end
            if ibeam == 4;pos = get(gca,'Position');c(4) = colorbar;set(gca,'Position',pos);end
            subplot(5,4,ibeam+4*4)
            bincolor = jet(nbin);
            for ibin = 1:nbin
            vbin = squeeze(avgvel(:,ibin,ibeam));
             [PS,F,~] = hannwinPSD2(vbin,90,1,'par');
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
        c(4).Ticks = [0.25 1 1.75];c(4).TickLabels = {'Good','Bad C','Fish'};
        c(5).Label.String = 'Bin #';c(5).TickLabels = num2str([c(5).Ticks']*nbin);
        drawnow

        fh(2) = figure('color','w');
        set(gcf,'outerposition',MP(1,:).*[1 1 0.5 1]);
        clear b1 b2 b3 p1 p2 p3
        for ibeam = 1:4
            subplot(2,3,ibeam)
            errorbar(-avgz,avgu_noqc(:,ibeam),avguerr_noqc(:,ibeam));
            hold on
            errorbar(-avgz,avgu(:,ibeam),avguvar(:,ibeam));
            grid
            xlim([min(-avgz) max(-avgz)])
            ylim(nanmean(avgu_noqc(:,ibeam))+[-0.1 0.1])
            plot(xlim,[0 0],'--k')
            view(gca,[90 -90])
            title(['Beam ' num2str(ibeam)])
            ylabel('u_{r} [m/s]');xlabel('z[m]')
        end
        subplot(2,3,5)
        p1 = plot(squeeze(nanmean(avgamp)),-avgz,'linewidth',1.5);
        hold on
        ylim([min(-avgz) max(-avgz)])
        xlim([50 175])
        hold on
        legend(p1,'Beam 1','Beam 2','Beam 3','Beam 4',...
            'location','southeast')
        xlabel('A [dB]')
        ylabel('z [m]')
        title('Amplitude')
        subplot(2,3,6)
        plot(squeeze(nanmean(avgcorr)),-avgz,'linewidth',1.5);
        hold on
        ylim([min(-avgz) max(-avgz)])
        xlim([40 100])
        plot(opt.mincorr*[1 1],ylim,'r');
        title('Correlation')
        xlabel('C [%]')
        ylabel('z [m]')
        drawnow
    else
        fh = [];
    end

    % Check that QC actually reduced the standard error
    if any(avguvar(:) > avguerr_noqc(:))
        ibadqc = avguvar > avguerr_noqc;
        avgu(ibadqc) = avgu_noqc(ibadqc);
        avguvar(ibadqc) = avguerr_noqc(ibadqc);
    end

    % Separate U, V, W
    profile.avgz = avgz;
    profile.avgw = avgu(:,4);
    profile.avgv = avgu(:,2);
    profile.avgu = avgu(:,1);
    % Save variance, corr & amp profiles for QC later if necessary
    profile.avgwvar = avguvar(:,4);
    profile.avgvvar = avguvar(:,2);
    profile.avguvar = avguvar(:,1);
    profile.ucorr = squeeze(mean(avgcorr(:,:,1)));
    profile.vcorr = squeeze(mean(avgcorr(:,:,2)));
    profile.wcorr = squeeze(mean(avgcorr(:,:,4)));
    profile.uamp = squeeze(mean(avgamp(:,:,1)));
    profile.vamp = squeeze(mean(avgamp(:,:,2)));
    profile.wamp = squeeze(mean(avgamp(:,:,4)));
    profile.temp = avgtemp;
    profile.temp = mean(profile.temp(1:round(end/4)),'omitnan');
    
end

