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
    aqh.epsnf = aqh.hrcorr;
    aqh.mspe = aqh.hrcorr;
    aqh.slope = aqh.hrcorr;
    aqh.pspike = aqh.hrcorr;
    aqh.pbadping = NaN(1,nt);
    aqh.wpeofmag = aqh.hrcorr;
    aqh.eofs = NaN(nzhr,nzhr,nt);
    aqh.eofsvar = aqh.hrcorr;
    aqh.pitch = NaN(1,nt);
    aqh.roll = NaN(1,nt);
    aqh.head = NaN(1,nt);
    aqh.pitchvar = NaN(1,nt);
    aqh.rollvar = NaN(1,nt);
    aqh.headvar = NaN(1,nt);

    for it = 1:length(aqh.time)
        
        %HR
        nz = length(AQH(it).HRprofile.w);
        aqh.hrcorr(1:nz,it) = AQH(it).HRprofile.QC.hrcorr;
        aqh.hramp(1:nz,it) = AQH(it).HRprofile.QC.hramp;
        aqh.pspike(1:nz,it) = AQH(it).HRprofile.QC.pspike;
        aqh.pbadping(it) = AQH(it).HRprofile.QC.pbadping;
        aqh.hrw(1:nz,it) = AQH(it).HRprofile.w;
        aqh.hrwvar(1:nz,it) = AQH(it).HRprofile.wvar;
        aqh.eps(1:nz,it) = AQH(it).HRprofile.eps;
        aqh.epsnf(1:nz,it) = AQH(it).HRprofile.QC.epsNF;
        aqh.mspe(1:nz,it) = AQH(it).HRprofile.QC.qualEOF.mspe;
        aqh.slope(1:nz,it) = AQH(it).HRprofile.QC.qualEOF.slope;
        
        aqh.wpeofmag(1:nz,it) = AQH(it).HRprofile.QC.wpeofmag;
        aqh.eofs(1:nz,1:nz,it) = AQH(it).HRprofile.QC.eofs;
        aqh.eofsvar(1:nz,it) = AQH(it).HRprofile.QC.eofsvar;

        % Motion
        aqh.pitch(it) = AQH(it).motion.pitch;
        aqh.roll(it) = AQH(it).motion.roll;
        aqh.head(it) = AQH(it).motion.head;
        aqh.pitchvar(it) = AQH(it).motion.pitchvar;
        aqh.rollvar(it) = AQH(it).motion.rollvar;
        aqh.headvar(it) = AQH(it).motion.headvar;
    end

    %QC
    badburst = [AQH.badburst];
    if QCaqh && sum(badburst) < length(aqh.time)
      
        aqh.hrcorr(:,badburst) = [];
        aqh.hramp(:,badburst) = [];
        aqh.hrw(:,badburst) = [];
        aqh.hrwvar(:,badburst) = [];
        aqh.eps(:,badburst) = [];
        aqh.epsnf(:,badburst) = [];
        aqh.mspe(:,badburst) = [];
        aqh.slope(:,badburst) = [];  
        aqh.pspike(:,badburst) = [];
        aqh.pbadping(badburst) = [];
        aqh.time(badburst) = [];
        aqh.wpeofmag(:,badburst) = [];
        aqh.eofs(:,:,badburst) = [];
        aqh.eofsvar(:,badburst) = [];
        aqh.pitch(badburst) = AQH(badburst).motion.pitch;
        aqh.roll(badburst) = AQH(badburst).motion.roll;
        aqh.head(badburst) = AQH(badburst).motion.head;
        aqh.pitchvar(badburst) = AQH(badburst).motion.pitchvar;
        aqh.rollvar(badburst) = AQH(badburst).motion.rollvar;
        aqh.headvar(badburst) = AQH(badburst).motion.headvar;
    else
        aqh.badburst = badburst;
    end

    % Plot
    if plotaqh && length(aqh.time)>1

        figure('color','w')
        MP = get(0,'monitorposition');
        set(gcf,'outerposition',MP(1,:).*[1 1 0.5 1]);
        clear b

        % HR
        h(1) = subplot(4,2,1);% HR Correlation
        pcolor(aqh.time,-aqh.hrz,aqh.hrcorr);shading flat
        caxis([50 100]);
        ylabel('Depth (m)');cmocean('thermal');title('HR Correlation')
        c = colorbar;c.Label.String = '[%]';
        xlim([min(aqh.time) max(aqh.time)])
        datetick('x','KeepLimits')
        h(3) = subplot(4,2,3);% Vertical Velocity
        pcolor(aqh.time,-aqh.hrz,aqh.hrw);shading flat
        caxis([-0.05 0.05]);
        ylabel('Depth (m)');cmocean('balance');title('W')
        c = colorbar;c.Label.String = 'ms^{-1}';
        xlim([min(aqh.time) max(aqh.time)])
        datetick('x','KeepLimits')
        h(5) = subplot(4,2,5);% Velocity Variance
        pcolor(aqh.time,-aqh.hrz,sqrt(aqh.hrwvar));shading flat
        caxis([0 0.5]);
        ylabel('Depth (m)');title('\sigma_W')
        c = colorbar;c.Label.String = 'ms^{-1}';
        xlim([min(aqh.time) max(aqh.time)])
        datetick('x','KeepLimits')
        h(7) = subplot(4,2,7);% Percent Spikes
        pcolor(aqh.time,-aqh.hrz,100*aqh.pspike);shading flat
        caxis([0 25]);colormap(gca,lansey(25))
        ylabel('Depth (m)');title('Spike Percent')
        c = colorbar;c.Label.String = 'P [%]';
        xlim([min(aqh.time) max(aqh.time)])
        datetick('x','KeepLimits')
        h(2) = subplot(4,2,2);% HR Amplitude
        pcolor(aqh.time,-aqh.hrz,aqh.hramp);shading flat
        caxis([60 160]);
        ylabel('Depth (m)');cmocean('haline');title('HR Amplitude')
        c = colorbar;c.Label.String = '[counts]';
        xlim([min(aqh.time) max(aqh.time)])
        datetick('x','KeepLimits')
        h(8) = subplot(4,2,4);% Dissipation Rate
        pcolor(aqh.time,-aqh.hrz,log10(aqh.eps));shading flat
        caxis([-6 -3]);colormap(gca,'jet')
        ylabel('Depth (m)');title('Dissipation Rate')
        c = colorbar;c.Label.String = 'log_{10}(m^3s^{-2})';
        xlim([min(aqh.time) max(aqh.time)])
        datetick('x','KeepLimits')
        h(6) = subplot(4,2,6);% MSPE of SF r^(2/3) fit
        pcolor(aqh.time,-aqh.hrz,100*sqrt(aqh.mspe));shading flat
        caxis([0 25]);colormap(gca,lansey(25))
        ylabel('Depth (m)');title('MSPE')
        c = colorbar;c.Label.String = '[%]';        
        xlim([min(aqh.time) max(aqh.time)])
        datetick('x','KeepLimits')
        h(8) = subplot(4,2,8);% Best-fit slope to SF
        pcolor(aqh.time,-aqh.hrz,aqh.slope);shading flat
        caxis([0 2*2/3]);
        ylabel('Depth (m)');title('SF Slope')
        c = colorbar;c.Label.String = 'D \propto r^n';cmocean('curl')
        xlim([min(aqh.time) max(aqh.time)])
        datetick('x','KeepLimits')
        drawnow
    end

else
    aqh = [];
    warning('AQH empty...')
end
