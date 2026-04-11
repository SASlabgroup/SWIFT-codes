% Matlab script to read and process raw data from testing Paros sensor
% collected with a v5 (beta) SWIFT,
% including SBG motion data and RM Young sonio anemometer
%
% run this script in the test directory
%
% J. Thomson, 4/2026

%% AHRS data from SBG Ellipse sensor (GNSS-aided IMU with onboard EKF)

plotahrs = true;
tstart = 60; % seconds of warm-up time for the GPS

ahrsfiles = dir('*ahrs.log');

fs = 5; % Hz, ** should confirm based on timestamps**

for fi=1:length(ahrsfiles)

    % read the binary data into a Matlab structure,
    % using function from SWIFT codes repo
    sbgData = sbgBinaryToMatlab( ahrsfiles(fi).name );
    save([ahrsfiles(fi).name(1:(end-4)) '.mat'],'sbgData')

    % pull out essential variables, plot and process
    % following closely reprocess_SBG.m from SWIFT codes repo

    % IMU Motion
    z = sbgData.ShipMotion.heave(:)';
    x = sbgData.ShipMotion.surge(:)';
    y = sbgData.ShipMotion.sway(:)';
    ztime = sbgData.ShipMotion.time_stamp(:)'*10^(-6);% Convert to seconds
    imin = min([length(x) length(y) length(z) length(ztime)]);
    x = x(1:imin);y = y(1:imin);z = z(1:imin);ztime = ztime(1:imin);
    [~,iu] = unique(ztime);x = x(iu);y = y(iu);z = z(iu);ztime = ztime(iu);

    % GPS position
    lat = sbgData.GpsPos.lat(:)';
    lon = sbgData.GpsPos.long(:)';
    ltime = sbgData.GpsPos.time_stamp(:)'*10^(-6);
    imin = min([length(lon) length(lat) length(ltime)]);
    lat = lat(1:imin); lon = lon(1:imin); ltime = ltime(1:imin);
    [~,iu] = unique(ltime);lon = lon(iu);lat = lat(iu);ltime = ltime(iu);

    % GPS motion
    u = sbgData.GpsVel.vel_e(:)';
    v = sbgData.GpsVel.vel_n(:)';
    w = -sbgData.GpsVel.vel_d(:)';
    gpstime = sbgData.GpsVel.time_stamp(:)'*10^(-6);
    imin = min([length(u) length(v) length(w) length(gpstime)]);
    u = u(1:imin); v = v(1:imin); w = w(1:imin); gpstime = gpstime(1:imin);
    [~,iu] = unique(gpstime);
    u = u(iu); v = v(iu); w = w(iu); gpstime = gpstime(iu);

    % Interpolate to common time, using GPS time
    igood = ~isnan(lat) & ~isnan(lon) & ltime ~= 0;
    lat = interp1(ltime(igood),lat(igood),gpstime);
    lon = interp1(ltime(igood),lon(igood),gpstime);
    igood = ~isnan(x) & ~isnan(y) & ~isnan(z) & ztime ~= 0;
    z = interp1(ztime(igood),z(igood),gpstime);
    x = interp1(ztime(igood),x(igood),gpstime);
    y = interp1(ztime(igood),y(igood),gpstime);

    if plotahrs

        figure(1), clf
        % [fh,sbgData] = plotSBG(sbgData,'qc')  % alternative

        figure('color','w')
        subplot(3,1,1)
        plot(gpstime,z,'-k')
        hold on;
        plot(gpstime,filloutliers(z,'linear'),'-r','LineWidth',2)
        ylabel('\eta [m]');ylim([-0.5 0.5])
        plot(tstart*[1 1],ylim,':k','LineWidth',2)
        legend('Raw','Despiked','Start')
        title(ahrsfiles(fi).name(1:end-4),'interpreter','none')

        subplot(3,1,2)
        plot(gpstime,u,'-k')
        hold on;
        plot(gpstime,filloutliers(u,'linear'),'-r','LineWidth',2)
        ylabel('u [m/s]');ylim([-1 1])
        plot(tstart*[1 1],ylim,':k','LineWidth',2)

        subplot(3,1,3)
        plot(gpstime,v,'-k')
        hold on;axis tight
        plot(gpstime,filloutliers(v,'linear'),'-r','LineWidth',2)
        xlabel('Time [s]');
        ylabel('v [m/s]');ylim([-1 1])
        plot(tstart*[1 1],ylim,':k','LineWidth',2)

        %             subplot(4,1,4)
        %             plot(gpstime,w,'-kx')
        %             hold on;axis tight
        %             plot(gpstime,filloutliers(w,'linear'),'-rx')
        %             xlabel('Time [s]');
        %             ylabel('w [m/s]');ylim([-2 2])
        %             plot(tstart*[1 1],ylim,':k','LineWidth',2)

        h = findall(gcf,'Type','Axes');
        linkaxes(h,'x');
        xlim([0 max([550 max(gpstime)])])

        print([ahrsfiles(fi).name(1:end-4) '_uvz.png'],'-dpng')
        close gcf
    end

    % Crop and despike data
    z = filloutliers(z(tstart*5:end),'linear');
    x = filloutliers(x(tstart*5:end),'linear');
    y = filloutliers(y(tstart*5:end),'linear');
    lat = filloutliers(lat(tstart*5:end), 'linear');
    lon = filloutliers(lon(tstart*5:end), 'linear');
    u = filloutliers(u(tstart*5:end),'linear');
    v = filloutliers(v(tstart*5:end),'linear');

    % Remove NaNs?
    ibad = isnan(z + x + y + u + v + lat + lon);
    z(ibad) = []; x(ibad) = []; y(ibad)=[]; u(ibad)=[];
    v(ibad)=[]; lat(ibad)=[]; lon(ibad)=[];

    % Caculate waves
    [Hs, Tp, Dp, E, f, a1, b1, a2, b2, check] = SBGwaves(u,v,z,fs);

    % save output
    save([ahrsfiles(fi).name(1:(end-4)) '_processed.mat'])


end


%% Paros pressure data (new code)

parosfiles = dir('*paros.log');

fs = 20; % Hz, ** should confirm based on timestamps**

for fi=1:length(parosfiles)
    parosData = importdata(parosfiles(fi).name);
    p = parosData.data;
    %ptime = datenum(parosData.textdata{:,2});  %  not worth it when all 1970

    % plotting
    figure(2), clf

    subplot(1,2,1)
    plot([1:length(p)]./fs,p)
    ylabel('p [mb]'), xlabel('t [s]')
    title(parosfiles(fi).name(1:end-4),'interp','none')

    subplot(1,2,2)
    pwelch(p,[],[],[],fs)
    set(gca,'xscale','log')

    print([(parosfiles(fi).name(1:end-4)) '_raw_spectra.png'],'-dpng')

    % save
    save([(parosfiles(fi).name(1:end-4)) '_processed.mat'],'p','ptime')

end

%% RM Young sonic anemometer data (from SWIFT codes repo)

sonicfiles = dir('*sonic.log');

fs = 10; % Hz, ** should confirm based on timestamps**

for fi=1:length(sonicfiles)

    sonicData = importdata(sonicfiles(fi).name,' ', 2);
    t = sonicData.data(:,1);
    u = sonicData.data(:,2);
    v = sonicData.data(:,3);
    w = sonicData.data(:,4);
    T = sonicData.data(:,5);
    errors = sonicData.data(:,6);

    % simple QC
    bad = isnan(u+v+w);
    u(bad) = 0; v(bad) = 0; w(bad)=0;

    % plotting
    figure(3), clf

    subplot(1,2,1)
    plot(t,u,t,v,t,w)
    legend('u','v','w')
    title(sonicfiles(fi).name(1:end-4),'interp','none')

    subplot(1,2,2)
    pwelch([u v w],[],[],[],fs)
    set(gca,'xscale','log')

    print([(sonicfiles(fi).name(1:end-4)) '_raw_spectra.png'],'-dpng')

    % save
    save([(sonicfiles(fi).name(1:end-4)) '_processed.mat'],'t','u','v','w','T')

end

%% preliminary p'w' analysis

clear all

sonicfiles = dir('*sonic.log');
parosfiles = dir('*paros.log');
ahrsfiles = dir('*ahrs.log');

% initialize
Preswork_DC = NaN(1,length(sonicfiles));
Preswork_spec  = NaN(1,length(sonicfiles));
Hs_all = NaN(1,length(sonicfiles));
U = NaN(1,length(sonicfiles));

% indices of filelist
validtests = [3:8 12];
boatwakes = 5;
stilwater = 12;

for fi = validtests

    load([(sonicfiles(fi).name(1:end-4)) '_processed.mat'],'t','u','v','w','T');
    load([(parosfiles(fi).name(1:end-4)) '_processed.mat'],'p');
    load([(ahrsfiles(fi).name(1:end-4)) '_processed.mat'],'Hs','z','E','f'); f_wavespec = f; clear f;

    % interp the presure and the ahrs to match the sonic
    fs = 10; % sonic sampling rate
    toffset = 0;

    ptime = linspace(min(t), max(t), length(p)) + toffset;
    praw = p;
    p = interp1(ptime,p,t);

    ztime = linspace(min(t), max(t), length(z)) + toffset;
    zraw = z;
    z = interp1(ztime,z,t);

    %     % or resample pressure (20 Hz) to match the sonic (10 Hz)... worst option
    %     %p = resample(p, length(w), length(p));  fs = 10; % Hz
    %
    %     % or interp the sonic to match the pressure
    %     %u = interp(u,2); v = interp(v,2); w = interp(w,2);  fs = 20; %Hz
    %     if length(u)>length(p)
    %         u(length(p)+1:end)=[]; v(length(p)+1:end)=[];  w(length(p)+1:end)=[];
    %     elseif length(p)>length(u)
    %         p(length(u)+1:end)=[];
    %     end

    figure(4), clf % timeseries
    subplot(4,1,1)
    plot(ztime,zraw,'k-',t,z,'k.','linewidth',2), hold on
    set(gca,'YLim',[-0.5 0.5])
    ylabel('\eta [m]')
    set(gca,'fontsize',14,'fontweight','demi')

    subplot(4,1,2)
    plot(ptime,praw,'r-',t,p,'.','linewidth',2), hold on
    ylabel('pres [mb]')
    set(gca,'fontsize',14,'fontweight','demi')


    subplot(4,1,3)
    plot(t,w,'b-','linewidth',2), hold on
    ylabel('w [m/s]')
    set(gca,'fontsize',14,'fontweight','demi')

    subplot(4,1,4)
    plot(t,u,'g',t,v,'m','linewidth',2), hold on
    ylabel('u,v [m/s]')
    set(gca,'fontsize',14,'fontweight','demi')
    xlabel('time [s]')

    print([(sonicfiles(fi).name(1:15)) '_timeseries.png'],'-dpng')


    % cross-spectra

    [ f, PP, PU, PV, PW, UU, VV, WW, UV , cohSIG ]  =  PWspectra( p, u, v, w , fs);

    % Cospectrum & Quadrature:
    coPU = real(PU);   quPU = imag(PU);
    coPV = real(PV);   quPV = imag(PV);
    coPW = real(PV);   quPW = imag(PV);
    coUV = real(UV);   quUV = imag(UV);
    % Coherence & Phase at each freq-band
    % *** note that it's important to calc this AFTER all merging and ensemble avg.
    cohPU = sqrt( (coPU.^2 + quPU.^2) ./ (PP.* UU) );
    phPU  = 180/pi .* atan2( quPU , coPU );
    cohPV = sqrt((coPV.^2 + quPV.^2)./ (PP.* VV));
    phPV  = 180/pi .* atan2( quPV , coPV );
    cohPW = sqrt((coPW.^2 + quPW.^2)./ (PP.* WW));
    phPW  = 180/pi .* atan2( quPW , coPW );
    cohUV = sqrt((coUV.^2 + quUV.^2)./(UU .* VV));
    phUV  = 180/pi .* atan2( quUV , coUV );
    % -----------------------------------------------------------------------------

    figure(5), clf
    subplot(2,1,1)
    loglog(f_wavespec,E,'k',f,PP,'r', f, WW,'b','linewidth',2)
    legend('\eta','p','w')
    ylabel('Energy density')
    title([(sonicfiles(fi).name(1:15)) ', H_s = ' num2str(Hs,2) ' m'])
    set(gca,'fontsize',14,'fontweight','demi')

    subplot(4,1,3)
    semilogx(f,cohPW,'r',f,cohPW,'b.','linewidth',2)
    ylabel('Coherence')
    set(gca,'YLim',[0 1])
    hold on,
    plot([min(f) max(f)],[cohSIG cohSIG],'k:')
    set(gca,'fontsize',14,'fontweight','demi')

    subplot(4,1,4)
    semilogx(f,phPW,'r',f,phPW,'b.','linewidth',2)
    ylabel('Phase')
    set(gca,'YLim',[-180 180])
    set(gca,'fontsize',14,'fontweight','demi')

    xlabel('f [Hz]')

    print([(sonicfiles(fi).name(1:15)) '_crossspectra.png'],'-dpng')

    % stats from this burst
    Preswork_DC(fi) = mean(detrend(p).*detrend(w)) % direct covariance
    Preswork_spec(fi) = sum( real(PW) ) .* mean(diff(f)); % spectral variance
    Hs_all(fi) = Hs;
    U(fi) = sqrt( mean(u).^2 + mean(v).^2 );

end

figure(6), clf
subplot(3,1,1)
plot(Hs_all,'kx','linewidth',2)
xlabel('burst index')
ylabel('Waves H_s [m]')
set(gca,'fontsize',14,'fontweight','demi')


subplot(3,1,2)
plot(U,'k+','linewidth',2)
xlabel('burst index')
ylabel('Winds |U| [m/s]')
set(gca,'fontsize',14,'fontweight','demi')


subplot(3,1,3)
plot(Preswork_DC,'o','linewidth',3), hold on
plot(Preswork_spec,'s','linewidth',2)
xlabel('burst index')
ylabel('Pressure work <pw>')
legend('direct','spectral','Location','Southeast')
set(gca,'fontsize',14,'fontweight','demi')

print(['summary.png'],'-dpng')


