function sig = catSIG(SIG,varargin)
%Produces summary plot of burst-averaged signature data stored in 'SIG'
%       also returns concatenated data

plotsig = false;
QCsig = false;

if nargin > 1
    if any(strcmp(varargin,'plot'))
        plotsig = true;
    end
    if any(strcmp(varargin,'qc'))
        QCsig = true;
    end
    if ~(any(strcmp(varargin,'plot') | strcmp(varargin,'qc')))
        error('Optional inputs must be ''plot'' or ''qc''')
    end
end

if isfield(SIG,'time')
    sig.time = [SIG.time];

    sig.avgz = SIG(round(end/2)).profile.z';

    sig.avgcorr = NaN(length(sig.avgz),length(sig.time));
    sig.avgamp = sig.avgcorr;
    sig.avgu = sig.avgcorr;
    sig.avgv = sig.avgcorr;
    sig.avgw = sig.avgcorr;
    sig.avguvar = sig.avgcorr;
    sig.avgvvar = sig.avgcorr;
    sig.avgwvar = sig.avgcorr;
    sig.hrz = SIG(round(end/2)).HRprofile.z;
    sig.hrcorr = NaN(length(sig.hrz),length(sig.time));
    sig.hramp = sig.hrcorr;
    sig.hrw = sig.hrcorr;
    sig.hrwvar = sig.hrcorr;
    sig.eps = sig.hrcorr;
    sig.mspe = sig.hrcorr;
    sig.slope = sig.hrcorr;
    sig.pspike = sig.hrcorr;


    for it = 1:length(sig.time)
        %Broadband
        sig.avgamp(:,it) = SIG(it).profile.QC.uamp;
        sig.avgcorr(:,it) = SIG(it).profile.QC.ucorr;
        sig.avgu(:,it) = SIG(it).profile.u;
        sig.avgv(:,it) = SIG(it).profile.v;
        sig.avgw(:,it) = SIG(it).profile.w;
        sig.avguvar(:,it) = SIG(it).profile.uvar;
        sig.avgvvar(:,it) = SIG(it).profile.vvar;
        sig.avgwvar(:,it) = SIG(it).profile.wvar;
        %HR
        nz = length(SIG(it).HRprofile.w);
        sig.hrcorr(1:nz,it) = SIG(it).HRprofile.QC.hrcorr;
        sig.hramp(1:nz,it) = SIG(it).HRprofile.QC.hramp;
        sig.hrw(1:nz,it) = SIG(it).HRprofile.w;
        sig.hrwvar(1:nz,it) = SIG(it).HRprofile.wvar;
        sig.eps(1:nz,it) = SIG(it).HRprofile.eps_structEOF;
        sig.mspe(1:nz,it) = SIG(it).HRprofile.QC.mspeEOF;
        sig.slope(1:nz,it) = SIG(it).HRprofile.QC.slopeEOF;
        sig.pspike(1:nz,it) = SIG(it).HRprofile.QC.pspike;
    end

    %QC
    badburst = [SIG.badburst];
    if QCsig && sum(badburst) < length(sig.time)
        sig.avgcorr(:,badburst) = [];
        sig.avgamp(:,badburst) = [];
        sig.avgu(:,badburst) = [];
        sig.avgv(:,badburst) = [];
        sig.avgw(:,badburst) = [];
        sig.avguvar(:,badburst) = [];
        sig.avgvvar(:,badburst) = [];
        sig.avgwvar(:,badburst) = [];

        sig.hrcorr(:,badburst) = [];
        sig.hramp(:,badburst) = [];
        sig.hrw(:,badburst) = [];
        sig.hrwvar(:,badburst) = [];
        sig.eps(:,badburst) = [];
        sig.mspe(:,badburst) = [];
        sig.slope(:,badburst) = [];  
        sig.pspike(:,badburst) = [];

        sig.time(badburst) = [];
    else
        sig.badburst = badburst;
    end

    % Plot
    if plotsig && length(sig.time)>1

        figure('color','w')
        MP = get(0,'monitorposition');
        set(gcf,'outerposition',MP(1,:).*[1 1 1 1]);
        clear b

        % Broadband
        h(1) = subplot(4,4,1);
        pcolor(sig.time,-sig.avgz,sig.avgcorr);shading flat
        caxis([50 100]);
        ylabel('Depth (m)');cmocean('thermal');title('Correlation')
        c = colorbar;c.Label.String = '[%]';
        xlim([min(sig.time) max(sig.time)])
        datetick('x','KeepLimits')
        hold on; plot(xlim,-max(sig.hrz)*[1 1],'--k')
        h(2) = subplot(4,4,2);
        pcolor(sig.time,-sig.avgz,sig.avgamp);shading flat
        caxis([60 160]);
        ylabel('Depth (m)');cmocean('haline');title('Amplitude')
        c = colorbar;c.Label.String = '[counts]';
        xlim([min(sig.time) max(sig.time)])
        datetick('x','KeepLimits')
        hold on; plot(xlim,-max(sig.hrz)*[1 1],'--k')
        h(5) = subplot(4,4,5);
        pcolor(sig.time,-sig.avgz,sig.avgu);shading flat
        caxis([-0.25 0.25]);
        ylabel('Depth (m)');cmocean('balance');title('U')
        c = colorbar;c.Label.String = 'ms^{-1}';
        xlim([min(sig.time) max(sig.time)])
        datetick('x','KeepLimits')
        hold on; plot(xlim,-max(sig.hrz)*[1 1],'--k')
        h(9) = subplot(4,4,9);
        pcolor(sig.time,-sig.avgz,sig.avgv);shading flat
        caxis([-0.25 0.25]);
        ylabel('Depth (m)');cmocean('balance');title('V')
        c = colorbar;c.Label.String = 'ms^{-1}';
        xlim([min(sig.time) max(sig.time)])
        datetick('x','KeepLimits')
        hold on; plot(xlim,-max(sig.hrz)*[1 1],'--k')
        h(13) = subplot(4,4,13);
        pcolor(sig.time,-sig.avgz,sig.avgw);shading flat
        caxis([-0.25 0.25]);
        ylabel('Depth (m)');cmocean('balance');title('W')
        c = colorbar;c.Label.String = 'ms^{-1}';
        xlim([min(sig.time) max(sig.time)])
        datetick('x','KeepLimits')
        hold on; plot(xlim,-max(sig.hrz)*[1 1],'--k')
        h(6) = subplot(4,4,6);
        pcolor(sig.time,-sig.avgz,sqrt(sig.avguvar));shading flat
        caxis([0 0.25]);
        ylabel('Depth (m)');title('\sigma_U')
        c = colorbar;c.Label.String = 'ms^{-1}';
        xlim([min(sig.time) max(sig.time)])
        datetick('x','KeepLimits')
        hold on; plot(xlim,-max(sig.hrz)*[1 1],'--k')
        h(10) = subplot(4,4,10);
        pcolor(sig.time,-sig.avgz,sqrt(sig.avgvvar));shading flat
        caxis([0 0.25]);
        ylabel('Depth (m)');title('\sigma_V')
        c = colorbar;c.Label.String = 'ms^{-1}';
        xlim([min(sig.time) max(sig.time)])
        datetick('x','KeepLimits')
        hold on; plot(xlim,-max(sig.hrz)*[1 1],'--k')
        h(14) = subplot(4,4,14);
        pcolor(sig.time,-sig.avgz,sqrt(sig.avgwvar));shading flat
        caxis([0 0.25]);
        ylabel('Depth (m)');title('\sigma_W')
        c = colorbar;c.Label.String = 'ms^{-1}';
        xlim([min(sig.time) max(sig.time)])
        datetick('x','KeepLimits')
        hold on; plot(xlim,-max(sig.hrz)*[1 1],'--k')
        % HR
        h(3) = subplot(4,4,3);% HR Correlation
        pcolor(sig.time,-sig.hrz,sig.hrcorr);shading flat
        caxis([50 100]);
        ylabel('Depth (m)');cmocean('thermal');title('HR Correlation')
        c = colorbar;c.Label.String = '[%]';
        xlim([min(sig.time) max(sig.time)])
        datetick('x','KeepLimits')
        h(7) = subplot(4,4,7);% Vertical Velocity
        pcolor(sig.time,-sig.hrz,sig.hrw);shading flat
        caxis([-0.05 0.05]);
        ylabel('Depth (m)');cmocean('balance');title('W')
        c = colorbar;c.Label.String = 'ms^{-1}';
        xlim([min(sig.time) max(sig.time)])
        datetick('x','KeepLimits')
        h(11) = subplot(4,4,11);% Velocity Variance
        pcolor(sig.time,-sig.hrz,sqrt(sig.hrwvar));shading flat
        caxis([0 0.5]);
        ylabel('Depth (m)');title('\sigma_W')
        c = colorbar;c.Label.String = 'ms^{-1}';
        xlim([min(sig.time) max(sig.time)])
        datetick('x','KeepLimits')
        h(15) = subplot(4,4,15);% Percent Spikes
        pcolor(sig.time,-sig.hrz,100*sig.pspike);shading flat
        caxis([0 25]);colormap(gca,lansey(25))
        ylabel('Depth (m)');title('Spike Percent')
        c = colorbar;c.Label.String = 'P [%]';
        xlim([min(sig.time) max(sig.time)])
        datetick('x','KeepLimits')
        h(4) = subplot(4,4,4);% HR Amplitude
        pcolor(sig.time,-sig.hrz,sig.hramp);shading flat
        caxis([60 160]);
        ylabel('Depth (m)');cmocean('haline');title('HR Amplitude')
        c = colorbar;c.Label.String = '[counts]';
        xlim([min(sig.time) max(sig.time)])
        datetick('x','KeepLimits')
        h(8) = subplot(4,4,8);% Dissipation Rate
        pcolor(sig.time,-sig.hrz,log10(sig.eps));shading flat
        caxis([-8 -5]);colormap(gca,'jet')
        ylabel('Depth (m)');title('Dissipation Rate')
        c = colorbar;c.Label.String = 'log_{10}(m^3s^{-2})';
        xlim([min(sig.time) max(sig.time)])
        datetick('x','KeepLimits')
        h(12) = subplot(4,4,12);% MSPE of SF r^(2/3) fit
        pcolor(sig.time,-sig.hrz,100*sqrt(sig.mspe));shading flat
        caxis([0 25]);colormap(gca,lansey(25))
        ylabel('Depth (m)');title('MSPE')
        c = colorbar;c.Label.String = '[%]';        
        xlim([min(sig.time) max(sig.time)])
        datetick('x','KeepLimits')
        h(16) = subplot(4,4,16);% Best-fit slope to SF
        pcolor(sig.time,-sig.hrz,sig.slope);shading flat
        caxis([0 2*2/3]);
        ylabel('Depth (m)');title('SF Slope')
        c = colorbar;c.Label.String = 'D \propto r^n';cmocean('curl')
        xlim([min(sig.time) max(sig.time)])
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
    sig = [];
    warning('SIG empty...')
end
