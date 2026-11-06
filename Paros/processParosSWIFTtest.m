% Matlab script to read and process raw data from testing Paros sensor
% collected with a v5 (beta) SWIFT,
% including SBG motion data and RM Young sonio anemometer
%
% run this script in the test directory
%
% J. Thomson, 4/2026 version 1
% J. Thomson, 10/2026  update filenames and incorporate sonic timestamps

clear all, close all

%% AHRS data from SBG Ellipse sensor (GNSS-aided IMU with onboard EKF)

plotahrs = true;
warmupseconds = 60; % seconds of warm-up time for the GPS

ahrsfiles = dir('*_dev0.log'); %dir('*ahrs.log');

fs = 50; % Hz, motion data
fsgps = 5; % Hz, gps data

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
    gpstime = sbgData.GpsVel.time_stamp(:)'*10^(-6); % seconds
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

        figure(1)%,'color','w'), clf
        % [fh,sbgData] = plotSBG(sbgData,'qc')  % alternative

        subplot(3,1,1)
        plot(gpstime,z,'-k')
        hold on;
        plot(gpstime,filloutliers(z,'linear'),'-r','LineWidth',2)
        ylabel('\eta [m]');ylim([-0.5 0.5])
        plot(warmupseconds*[1 1],ylim,':k','LineWidth',2)
        legend('Raw','Despiked','Start')
        title(ahrsfiles(fi).name(1:end-4),'interpreter','none')

        subplot(3,1,2)
        plot(gpstime,u,'-k')
        hold on;
        plot(gpstime,filloutliers(u,'linear'),'-r','LineWidth',2)
        ylabel('u [m/s]');ylim([-1 1])
        plot(warmupseconds*[1 1],ylim,':k','LineWidth',2)

        subplot(3,1,3)
        plot(gpstime,v,'-k')
        hold on;axis tight
        plot(gpstime,filloutliers(v,'linear'),'-r','LineWidth',2)
        xlabel('Time [s]');
        ylabel('v [m/s]');ylim([-1 1])
        plot(warmupseconds*[1 1],ylim,':k','LineWidth',2)

        %             subplot(4,1,4)
        %             plot(gpstime,w,'-kx')
        %             hold on;axis tight
        %             plot(gpstime,filloutliers(w,'linear'),'-rx')
        %             xlabel('Time [s]');
        %             ylabel('w [m/s]');ylim([-2 2])
        %             plot(warmupseconds*[1 1],ylim,':k','LineWidth',2)

        h = findall(gcf,'Type','Axes');
        linkaxes(h,'x');
        xlim([0 max([550 max(gpstime)])])

        print([ahrsfiles(fi).name(1:end-4) '_uvz.png'],'-dpng')
        %close gcf
    end

    % Crop and despike data
    z = filloutliers(z(warmupseconds*fsgps:end),'linear');
    x = filloutliers(x(warmupseconds*fsgps:end),'linear');
    y = filloutliers(y(warmupseconds*fsgps:end),'linear');
    lat = filloutliers(lat(warmupseconds*fsgps:end), 'linear');
    lon = filloutliers(lon(warmupseconds*fsgps:end), 'linear');
    u = filloutliers(u(warmupseconds*fsgps:end),'linear');
    v = filloutliers(v(warmupseconds*fsgps:end),'linear');

    % Remove NaNs?
    ibad = isnan(z + x + y + u + v + lat + lon);
    z(ibad) = []; x(ibad) = []; y(ibad)=[]; u(ibad)=[];
    v(ibad)=[]; lat(ibad)=[]; lon(ibad)=[];

    % Caculate waves
    [Hs, Tp, Dp, E, f, a1, b1, a2, b2, check] = SBGwaves(u,v,z,fsgps);

    % remake z at high sampling rate (for later interpolate)
    zraw = sbgData.ShipMotion.heave(:);
    ahrstime = datenum(sbgData.UtcTime.year, sbgData.UtcTime.month, sbgData.UtcTime.day, sbgData.UtcTime.hour, ... 
            sbgData.UtcTime.min, sbgData.UtcTime.sec + sbgData.UtcTime.nanosec./1e9);
    ztime = interp1([1:length(ahrstime)],ahrstime,linspace(1,length(ahrstime),length(zraw)));
    
    % check times
    actualfs = 1./(median(diff(ztime))*24*3600);
    actualfsgps = 1./median(diff(gpstime));
    disp(['SBG (AHRS) sampling rate: ' num2str(actualfs) ' Hz'])
    disp(['SBG (GPS) sampling rate: ' num2str(actualfsgps) ' Hz'])

    % save output
    save([ahrsfiles(fi).name(1:(end-4)) '_processed.mat'])


end


%% Paros pressure data

parosfiles = dir('*dev1.log'); %dir('*paros.log');

fs = 20; % Hz, ** should confirm based on timestamps**
ptimeoffset = 0 % -2/(24*3600);  % Paros timestamps were 2 seconds ahead ... 
% Paros timestamps corrected on 6 Nov 2026 (firmware v0.1.1) ...
% and should be zero offset going forward

for fi=1:length(parosfiles)
    % read data
    fid = fopen(parosfiles(fi).name,'r');
    C = textscan(fid,'%s %s %f','HeaderLines',warmupseconds*fs,'Delimiter',','); % skip the same warm up time as the ARHS
    fclose(fid);
    ptime = datenum(C{2}) + ptimeoffset;
    p = C{3};

    % QC pres
    bad = isnan(p);
    p(bad) = [];
    ptime(bad) = [];

    % check times
    actualfs = 1./(median(diff(ptime))*24*3600);
    disp(['Paros sampling rate: ' num2str(actualfs) ' Hz'])

    % plotting
    figure(2), clf

    subplot(1,2,1)
    plot(ptime,p)
    ylabel('p [mb]'), datetick
    title(parosfiles(fi).name(1:end-4),'interp','none')

    subplot(1,2,2)
    pwelch(p,[],[],[],fs)
    set(gca,'xscale','log')

    print([(parosfiles(fi).name(1:end-4)) '_raw_spectra.png'],'-dpng')

    % save
    save([(parosfiles(fi).name(1:end-4)) '_processed.mat'],'p','ptime')

end

%% RM Young sonic anemometer data (from SWIFT codes repo)

sonicfiles = dir('*_dev2.log'); %dir('*sonic.log');

fs = 20; % Hz, ** should confirm based on timestamps**

for fi=1:length(sonicfiles)
    % read data
    fid = fopen(sonicfiles(fi).name,'r');
    D = textscan(fid,'%s %s','HeaderLines',warmupseconds*fs,'Delimiter',','); % skip the same warm up time as the ARHS
    fclose(fid);
    badline = false(length(D{1}),1);
    for linei = 1:length(D{1})
        thistime = D{1}{linei};
        thisdata = str2num( D{2}{linei} );
        if thistime([ 3 6]) == '//' & length(thisdata)==5
            stime(linei) = datenum( thistime );
            u(linei) = thisdata(1); % m/s
            v(linei) = thisdata(2); % m/s
            w(linei) = thisdata(3); % m/s
            T(linei) = thisdata(4); % virtual temperature
            err(linei) = thisdata(5);
        else
            badline(linei) = true;
        end
    end

    % remove bad timestamps
    badtime = stime < datenum(2026,1,1);
    stime(badtime) = [];
    u(badtime) = [];
    v(badtime) = [];
    w(badtime) = [];
    T(badtime) = [];
    err(badtime) = [];

    % check sampling rate
    actualfs = 1./(median(diff(stime))*24*3600);
    disp(['Sonic sampling rate: ' num2str(actualfs) ' Hz'])


    % simple QC
    bad = isnan(u+v+w);
    u(bad) = 0; v(bad) = 0; w(bad)=0;

    % plotting
    figure(3), clf

    subplot(1,2,1)
    plot(stime,u,stime,v,stime,w)
    legend('u','v','w')
    ylabel('m/s'), datetick
    title(sonicfiles(fi).name(1:end-4),'interp','none')

    subplot(1,2,2)
    pwelch([u v w],[],[],[],fs)
    set(gca,'xscale','log')

    print([(sonicfiles(fi).name(1:end-4)) '_raw_spectra.png'],'-dpng')

    % save
    save([(sonicfiles(fi).name(1:end-4)) '_processed.mat'],'stime','u','v','w','T')

end

%% preliminary p'w' analysis

clear all

sonicfiles = dir('*dev2.log');
parosfiles = dir('*dev1.log');
ahrsfiles = dir('*dev0.log');

% initialize
Preswork_DC = NaN(1,length(sonicfiles));
Preswork_spec  = NaN(1,length(sonicfiles));
Hs_all = NaN(1,length(sonicfiles));
U = NaN(1,length(sonicfiles));

% indices of filelist
pickfiles = 1;

for fi = 1

    load([(sonicfiles(fi).name(1:end-4)) '_processed.mat'],'stime','u','v','w','T');
    load([(parosfiles(fi).name(1:end-4)) '_processed.mat'],'p','ptime');
    load([(ahrsfiles(fi).name(1:end-4)) '_processed.mat'],'Hs','E','f','zraw','ztime'); f_wavespec = f; clear f;

    % QC pres
    bad = isnan(p);
    p(bad) = [];
    ptime(bad) = [];

    % pick a start time and interp the presure and the ahrs to match the sonic
    fs = round( 1./(median(diff(stime))*24*3600) );
    commonstart = max( [ ztime(1) ptime(1) stime(1) ] );
    commonend = min([ ztime(end) ptime(end) stime(end) ]);
    commonindices = find(stime>commonstart & stime<commonend);
    stime = stime(commonindices);
    u = u(commonindices);
    v = v(commonindices);
    w = w(commonindices);
    T = T(commonindices);

    praw = p;
    p = interp1(ptime,p,stime);

    z = interp1(ztime,zraw,stime);

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
    plot(ztime,zraw,'k-',stime,z,'k.','linewidth',2), hold on
    set(gca,'YLim',[-0.5 0.5])
    ylabel('\eta [m]'), datetick
    set(gca,'fontsize',14,'fontweight','demi')

    subplot(4,1,2)
    plot(ptime,praw,'r-',stime,p,'.','linewidth',2), hold on
    ylabel('pres [mb]'), datetick
    set(gca,'fontsize',14,'fontweight','demi')


    subplot(4,1,3)
    plot(stime,w,'b-','linewidth',2), hold on
    ylabel('w [m/s]'), datetick
    set(gca,'fontsize',14,'fontweight','demi')

    subplot(4,1,4)
    plot(stime,u,'g',stime,v,'m','linewidth',2), hold on
    ylabel('u,v [m/s]'), datetick
    set(gca,'fontsize',14,'fontweight','demi')

    print([(sonicfiles(fi).name(1:15)) '_timeseries.png'],'-dpng')

    % cross-spectra -----------------------------------------------------

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

    % recalc heave spectra (to extent to higher freq than standard SBGwaves)
    [ZZ, fz] = pwelch(zraw,[],[],[],round(1./(median(diff(ztime))*24*3600)));
    % -----------------------------------------------------------------------------

    figure(5), clf
    subplot(2,1,1)
    loglog(f_wavespec,E,'k',fz,ZZ,'k--',f,PP,'r', f, WW,'b','linewidth',2)
    set(gca,'XLim',[1e-2 1e1])
    legend('\eta','z','p','w','Location','Southwest')
    ylabel('Energy density')
    title([(sonicfiles(fi).name(1:15)) ', H_s = ' num2str(Hs,2) ' m'])
    set(gca,'fontsize',14,'fontweight','demi')

    subplot(4,1,3)
    semilogx(f,cohPW,'r',f,cohPW,'b.','linewidth',2)
    ylabel('Coherence')
    set(gca,'YLim',[0 1]),set(gca,'XLim',[1e-2 1e1])
    hold on,
    plot([min(f) max(f)],[cohSIG cohSIG],'k:')
    set(gca,'fontsize',14,'fontweight','demi')

    subplot(4,1,4)
    semilogx(f,phPW,'r',f,phPW,'b.','linewidth',2)
    ylabel('Phase')
    set(gca,'YLim',[-180 180]), set(gca,'XLim',[1e-2 1e1])
    set(gca,'fontsize',14,'fontweight','demi')

    xlabel('f [Hz]')

    print([(sonicfiles(fi).name(1:15)) '_crossspectra.png'],'-dpng')

    % stats from this burstan
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


