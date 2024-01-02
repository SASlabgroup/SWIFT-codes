function aqh = catAQH(AQH,varargin)
%Produces summary plot of burst-averaged signature data stored in 'SIG'
%       also returns concatenated data

plotaqh = false;
QCaqh = false;

if nargin > 1
    if any(strcmp(varargin,'plot'))
        plotaqh = true;
    end
    if any(strcmp(varargin,'qc'))
        QCaqh = true;
    end
    if ~(any(strcmp(varargin,'plot') | strcmp(varargin,'qc')))
        error('Optional inputs must be ''plot'' or ''qc''')
    end
end

if isfield(AQH,'time')
    aqh.time = [AQH.time];
    nt = length(aqh.time);
    
    aqh.hrz = AQH(round(end/2)).HRprofile.z;
    nzhr = length(aqh.hrz);
    aqh.hrcorr = NaN(nzhr,nt);
    aqh.hramp = aqh.hrcorr;
    aqh.hrw = aqh.hrcorr;
    aqh.hrwvar = aqh.hrcorr;
    aqh.eps = aqh.hrcorr;
    aqh.mspe = aqh.hrcorr;
    aqh.slope = aqh.hrcorr;
    aqh.pspike = aqh.hrcorr;
    
    aqh.wpeofmag = aqh.hrcorr;
    aqh.eofs = NaN(nzhr,nzhr,nt);
    aqh.eofsvar = aqh.hrcorr;

    for it = 1:length(aqh.time)
        %HR
        nz = length(AQH(it).HRprofile.w);
        aqh.hrcorr(1:nz,it) = AQH(it).HRprofile.QC.hrcorr;
        aqh.hramp(1:nz,it) = AQH(it).HRprofile.QC.hramp;
        aqh.pspike(1:nz,it) = AQH(it).HRprofile.QC.pspike;
        aqh.hrw(1:nz,it) = AQH(it).HRprofile.w;
        aqh.hrwvar(1:nz,it) = AQH(it).HRprofile.wvar;

        aqh.eps(1:nz,it) = AQH(it).HRprofile.QC.epsEOF;
        aqh.mspe(1:nz,it) = AQH(it).HRprofile.QC.qualEOF.mspe;
        aqh.slope(1:nz,it) = AQH(it).HRprofile.QC.qualEOF.slope;
        
        aqh.wpeofmag(1:nz,it) = AQH(it).HRprofile.QC.wpeofmag;
        aqh.eofs(1:nz,1:nz,it) = AQH(it).HRprofile.QC.eofs;
        aqh.eofsvar(1:nz,it) = AQH(it).HRprofile.QC.eofsvar;
    end

    %QC
    badburst = [AQH.badburst];
    if QCaqh && sum(badburst) < length(aqh.time)
        aqh.avgcorr(:,badburst) = [];
        aqh.avgamp(:,badburst) = [];
        aqh.avgu(:,badburst) = [];
        aqh.avgv(:,badburst) = [];
        aqh.avgw(:,badburst) = [];
        aqh.avguvar(:,badburst) = [];
        aqh.avgvvar(:,badburst) = [];
        aqh.avgwvar(:,badburst) = [];
        aqh.hrcorr(:,badburst) = [];
        aqh.hramp(:,badburst) = [];
        aqh.hrw(:,badburst) = [];
        aqh.hrwvar(:,badburst) = [];
        aqh.eps(:,badburst) = [];
        aqh.mspe(:,badburst) = [];
        aqh.slope(:,badburst) = [];  
        aqh.pspike(:,badburst) = [];
        aqh.time(badburst) = [];
        
        aqh.wpeofmag(:,badburst) = [];
        aqh.eofs(:,:,badburst) = [];
        aqh.eofsvar(:,badburst) = [];
    else
        aqh.badburst = badburst;
    end

    % Plot
    if plotaqh && length(aqh.time)>1

        figure('color','w')
        MP = get(0,'monitorposition');
        set(gcf,'outerposition',MP(1,:).*[1 1 1 1]);
        clear b

        % Broadband
        h(1) = subplot(4,4,1);
        pcolor(aqh.time,-aqh.avgz,aqh.avgcorr);shading flat
        caxis([50 100]);
        ylabel('Depth (m)');cmocean('thermal');title('Correlation')
        c = colorbar;c.Label.String = '[%]';
        xlim([min(aqh.time) max(aqh.time)])
        datetick('x','KeepLimits')
        hold on; plot(xlim,-max(aqh.hrz)*[1 1],'--k')
        h(2) = subplot(4,4,2);
        pcolor(aqh.time,-aqh.avgz,aqh.avgamp);shading flat
        caxis([60 160]);
        ylabel('Depth (m)');cmocean('haline');title('Amplitude')
        c = colorbar;c.Label.String = '[counts]';
        xlim([min(aqh.time) max(aqh.time)])
        datetick('x','KeepLimits')
        hold on; plot(xlim,-max(aqh.hrz)*[1 1],'--k')
        h(5) = subplot(4,4,5);
        pcolor(aqh.time,-aqh.avgz,aqh.avgu);shading flat
        caxis([-0.25 0.25]);
        ylabel('Depth (m)');cmocean('balance');title('U')
        c = colorbar;c.Label.String = 'ms^{-1}';
        xlim([min(aqh.time) max(aqh.time)])
        datetick('x','KeepLimits')
        hold on; plot(xlim,-max(aqh.hrz)*[1 1],'--k')
        h(9) = subplot(4,4,9);
        pcolor(aqh.time,-aqh.avgz,aqh.avgv);shading flat
        caxis([-0.25 0.25]);
        ylabel('Depth (m)');cmocean('balance');title('V')
        c = colorbar;c.Label.String = 'ms^{-1}';
        xlim([min(aqh.time) max(aqh.time)])
        datetick('x','KeepLimits')
        hold on; plot(xlim,-max(aqh.hrz)*[1 1],'--k')
        h(13) = subplot(4,4,13);
        pcolor(aqh.time,-aqh.avgz,aqh.avgw);shading flat
        caxis([-0.25 0.25]);
        ylabel('Depth (m)');cmocean('balance');title('W')
        c = colorbar;c.Label.String = 'ms^{-1}';
        xlim([min(aqh.time) max(aqh.time)])
        datetick('x','KeepLimits')
        hold on; plot(xlim,-max(aqh.hrz)*[1 1],'--k')
        h(6) = subplot(4,4,6);
        pcolor(aqh.time,-aqh.avgz,sqrt(aqh.avguvar));shading flat
        caxis([0 0.25]);
        ylabel('Depth (m)');title('\sigma_U')
        c = colorbar;c.Label.String = 'ms^{-1}';
        xlim([min(aqh.time) max(aqh.time)])
        datetick('x','KeepLimits')
        hold on; plot(xlim,-max(aqh.hrz)*[1 1],'--k')
        h(10) = subplot(4,4,10);
        pcolor(aqh.time,-aqh.avgz,sqrt(aqh.avgvvar));shading flat
        caxis([0 0.25]);
        ylabel('Depth (m)');title('\sigma_V')
        c = colorbar;c.Label.String = 'ms^{-1}';
        xlim([min(aqh.time) max(aqh.time)])
        datetick('x','KeepLimits')
        hold on; plot(xlim,-max(aqh.hrz)*[1 1],'--k')
        h(14) = subplot(4,4,14);
        pcolor(aqh.time,-aqh.avgz,sqrt(aqh.avgwvar));shading flat
        caxis([0 0.25]);
        ylabel('Depth (m)');title('\sigma_W')
        c = colorbar;c.Label.String = 'ms^{-1}';
        xlim([min(aqh.time) max(aqh.time)])
        datetick('x','KeepLimits')
        hold on; plot(xlim,-max(aqh.hrz)*[1 1],'--k')
        % HR
        h(3) = subplot(4,4,3);% HR Correlation
        pcolor(aqh.time,-aqh.hrz,aqh.hrcorr);shading flat
        caxis([50 100]);
        ylabel('Depth (m)');cmocean('thermal');title('HR Correlation')
        c = colorbar;c.Label.String = '[%]';
        xlim([min(aqh.time) max(aqh.time)])
        datetick('x','KeepLimits')
        h(7) = subplot(4,4,7);% Vertical Velocity
        pcolor(aqh.time,-aqh.hrz,aqh.hrw);shading flat
        caxis([-0.05 0.05]);
        ylabel('Depth (m)');cmocean('balance');title('W')
        c = colorbar;c.Label.String = 'ms^{-1}';
        xlim([min(aqh.time) max(aqh.time)])
        datetick('x','KeepLimits')
        h(11) = subplot(4,4,11);% Velocity Variance
        pcolor(aqh.time,-aqh.hrz,sqrt(aqh.hrwvar));shading flat
        caxis([0 0.5]);
        ylabel('Depth (m)');title('\sigma_W')
        c = colorbar;c.Label.String = 'ms^{-1}';
        xlim([min(aqh.time) max(aqh.time)])
        datetick('x','KeepLimits')
        h(15) = subplot(4,4,15);% Percent Spikes
        pcolor(aqh.time,-aqh.hrz,100*aqh.pspike);shading flat
        caxis([0 25]);colormap(gca,lansey(25))
        ylabel('Depth (m)');title('Spike Percent')
        c = colorbar;c.Label.String = 'P [%]';
        xlim([min(aqh.time) max(aqh.time)])
        datetick('x','KeepLimits')
        h(4) = subplot(4,4,4);% HR Amplitude
        pcolor(aqh.time,-aqh.hrz,aqh.hramp);shading flat
        caxis([60 160]);
        ylabel('Depth (m)');cmocean('haline');title('HR Amplitude')
        c = colorbar;c.Label.String = '[counts]';
        xlim([min(aqh.time) max(aqh.time)])
        datetick('x','KeepLimits')
        h(8) = subplot(4,4,8);% Dissipation Rate
        pcolor(aqh.time,-aqh.hrz,log10(aqh.eps));shading flat
        caxis([-8 -5]);colormap(gca,'jet')
        ylabel('Depth (m)');title('Dissipation Rate')
        c = colorbar;c.Label.String = 'log_{10}(m^3s^{-2})';
        xlim([min(aqh.time) max(aqh.time)])
        datetick('x','KeepLimits')
        h(12) = subplot(4,4,12);% MSPE of SF r^(2/3) fit
        pcolor(aqh.time,-aqh.hrz,100*sqrt(aqh.mspe));shading flat
        caxis([0 25]);colormap(gca,lansey(25))
        ylabel('Depth (m)');title('MSPE')
        c = colorbar;c.Label.String = '[%]';        
        xlim([min(aqh.time) max(aqh.time)])
        datetick('x','KeepLimits')
        h(16) = subplot(4,4,16);% Best-fit slope to SF
        pcolor(aqh.time,-aqh.hrz,aqh.slope);shading flat
        caxis([0 2*2/3]);
        ylabel('Depth (m)');title('SF Slope')
        c = colorbar;c.Label.String = 'D \propto r^n';cmocean('curl')
        xlim([min(aqh.time) max(aqh.time)])
        datetick('x','KeepLimits')
        drawnow
        lw = h(1).Position([3 4]);
        ax = [2 4] + 4*(0:3)';
        for iax = 1:numel(ax)
            set(h(ax(iax)),'YTickLabel',[],'YLabel',[])
            h(ax(iax)).Position = h(ax(iax)).Position + [-0.02 0 0 0];
        end
        ax = [3 4] + 4*(0:3)';
        for iax = 1:numel(ax)
            h(ax(iax)).Position = h(ax(iax)).Position + [0.025 0 0 0];
        end
        for iax = 1:16
            h(iax).Position([3 4]) = lw;
        end
    end

else
    aqh = [];
    warning('AQH empty...')
end
