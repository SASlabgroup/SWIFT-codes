% Matlab script to read and process raw data from testing Paros sensor
% collected with a v5 (beta) SWIFT,
% including SBG motion data and RM Young sonio anemometer
%
% run this script in the test directory
%
% J. Thomson, 4/2026

%% AHRS data from SBG Ellipse sensor (GNSS-aided IMU with onboard EKF)

plotahrs = true;
tstart = 30; % seconds of warm-up time for the GPS

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

        % [fh,sbgData] = plotSBG(sbgData,'qc')  % alternative

        figure('color','w')
        subplot(3,1,1)
        plot(gpstime,z,'-kx')
        hold on;
        plot(gpstime,filloutliers(z,'linear'),'-rx')
        ylabel('\eta [m]');ylim([-2 2])
        plot(tstart*[1 1],ylim,':k','LineWidth',2)
        legend('Raw','Despiked','Start')
        title(ahrsfiles(fi).name(1:end-4),'interpreter','none')

        subplot(3,1,2)
        plot(gpstime,u,'-kx')
        hold on;
        plot(gpstime,filloutliers(u,'linear'),'-rx')
        ylabel('u [m/s]');ylim([-2 2])
        plot(tstart*[1 1],ylim,':k','LineWidth',2)

        subplot(3,1,3)
        plot(gpstime,v,'-kx')
        hold on;axis tight
        plot(gpstime,filloutliers(v,'linear'),'-rx')
        xlabel('Time [s]');
        ylabel('v [m/s]');ylim([-2 2])
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
    ptime = NaN;%datenum(parosData.textdata{:,2});  % convert cell to string

    % plot
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

    % plot
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

%% time logs (for synchronization)
