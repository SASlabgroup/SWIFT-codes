function plotWillapaL5Review(SWIFTL4,SWIFTL5,audit,watchheading,mountyaw, ...
        mintimecorrelation,sentinel,mission,reviewdir)
%PLOTWILLAPAL5REVIEW Save the three Willapa L5 review figures for a mission.
%
%   1. L4/L5 comparison: gyro lag, echo intensity, L4 and L5 east/north.
%   2. Two directional clusters of the depth-median current (L4, L5) over
%      Sentinel-2, with the two watch-circle bearing clusters.
%   3. Heading validation: watch-circle bearing, SBG yaw used by L5, the
%      onboard Signature compass, their observed offset, and the L5
%      depth-median current direction through time.
%
%   audit is the L5 source-audit table, watchheading the anchor-to-buoy
%   bearing per burst, and sentinel a struct with image, x and y.

swiftL4 = catSWIFT(SWIFTL4);
swiftL5 = catSWIFT(SWIFTL5);
time = [SWIFTL5.time]';

%% L4/L5 comparison

fh = figure('Color','w','Position',[50 50 1400 1300]);
theme(fh,'light')
ax = gobjects(6,1);
ax(1) = subplot(6,1,1);
yyaxis left
hold on
plot(time,audit.raw_time_lag_seconds,'.','Color',[0.7 0.7 0.7], ...
    'DisplayName','Raw lag estimate');
lag = audit.time_lag*86400;
direct = startsWith(audit.lag_method,"direct");
plot(time(direct),lag(direct),'.','Color',[0 0.45 0.74], ...
    'DisplayName','Applied direct lag');
plot(time(~direct),lag(~direct),'o','MarkerSize',3,'Color',[0.85 0.33 0.1], ...
    'DisplayName','Applied neighbor lag');
ylabel('lag [s]')
yyaxis right
plot(time,audit.lag_correlation,'.','MarkerSize',3,'Color',[0.35 0.35 0.35], ...
    'DisplayName','Gyro correlation');
yline(mintimecorrelation,':','DisplayName','Correlation threshold');
ylabel('correlation'); ylim([-0.05 1.05])
legend('Location','best','NumColumns',4)
title(mission + " SIG/SBG gyro lag",'Interpreter','none')

ax(2) = subplot(6,1,2);
if isfield(swiftL4,'echo')
    pcolor(swiftL4.time,swiftL4.echoz,swiftL4.echo); shading flat
    finiteecho = swiftL4.echo(isfinite(swiftL4.echo));
    if ~isempty(finiteecho); clim(prctile(finiteecho,[5 99])); end
    colormap(ax(2),cmocean('amp')); c = colorbar; c.Label.String = 'A [dB]';
end
ylim([0 max(swiftL4.depth,[],'all','omitnan')]); ylabel('Z [m]')
title('Echo intensity')

panels = {swiftL4,'relu','L4 east velocity'; swiftL4,'relv','L4 north velocity'; ...
    swiftL5,'relu','L5 east velocity'; swiftL5,'relv','L5 north velocity'};
for ipanel = 1:4
    [swiftp,field,paneltitle] = panels{ipanel,:};
    ax(ipanel+2) = subplot(6,1,ipanel+2);
    pcolor(swiftp.time,swiftp.depth,swiftp.(field)); shading flat
    clim([-1 1]); colormap(ax(ipanel+2),cmocean('balance'))
    c = colorbar; c.Label.String = 'U [ms^{-1}]';
    ylabel('Z [m]'); title(paneltitle)
end

% Show the altimeter return on the echo panel only. Overlaying it on the
% velocity panels obscures the current fields.
altz = swiftL4.altz;
altz(altz <= 0) = NaN;
hold(ax(2),'on')
plot(ax(2),swiftL4.time,altz,'k-','LineWidth',1.5)
plot(ax(2),swiftL4.time,altz,'w-','LineWidth',0.7)
set(ax(2:6),'YDir','reverse')
set(ax(1:5),'XTickLabel',[])
linkaxes(ax,'x'); xlim(ax(1),[min(time) max(time)])
datetick(ax(6),'x','mm/dd','keeplimits')
print(fh,fullfile(reviewdir,mission + "_L4_L5_comparison"),'-dpng','-r150')
close(fh)

%% Current-direction clusters over Sentinel-2

watch = watchheading(isfinite(watchheading));
[~,centers] = kmeans([sind(watch(:)) cosd(watch(:))],2,'Replicates',20);
watchmeans = sort(mod(atan2d(centers(:,1),centers(:,2)),360));
fprintf('%s watch-circle heading k-means: %.1f, %.1f degrees\n', ...
    mission,watchmeans(1),watchmeans(2))

[mapx,mapy] = projfwd(projcrs(32610),swiftL5.lat,mod(swiftL5.lon+180,360)-180);
x0 = mean(mapx,'omitnan');
y0 = mean(mapy,'omitnan');
xlimits = x0+[-14000 4000];
ylimits = y0+[-8000 7000];
columns = sentinel.x >= xlimits(1) & sentinel.x <= xlimits(2);
rows = sentinel.y >= ylimits(1) & sentinel.y <= ylimits(2);

fh = figure('Color','w','Position',[50 50 1000 850]);
theme(fh,'light')
image(([min(sentinel.x(columns)) max(sentinel.x(columns))]-x0)/1000, ...
    ([min(sentinel.y(rows)) max(sentinel.y(rows))]-y0)/1000, ...
    flipud(sentinel.image(rows,columns,:)));
set(gca,'YDir','normal'); hold on
plot((mapx-x0)/1000,(mapy-y0)/1000,'.','Color',[0.95 0.95 0.95], ...
    'MarkerSize',4,'DisplayName','GPS track');
products = {swiftL4,'L4',[0.85 0.1 0.1]; swiftL5,'L5',[0 0.75 1]};
for iproduct = 1:2
    [swiftp,name,color] = products{iproduct,:};
    u = median(swiftp.relu,1,'omitnan');
    v = median(swiftp.relv,1,'omitnan');
    speed = hypot(u,v);
    direction = mod(atan2d(u,v),360);
    good = isfinite(direction) & speed >= 0.2;
    if sum(good) < 2; continue; end
    directiongood = direction(good);
    directiongood = directiongood(:);
    speedgood = speed(good);
    speedgood = speedgood(:);
    unitvectors = [sind(directiongood) cosd(directiongood)];
    labels = kmeans(unitvectors,2,'Replicates',20);
    clustermeans = NaN(2,1);
    for icluster = 1:2
        incluster = labels == icluster;
        clustermeans(icluster) = mod(atan2d(mean(unitvectors(incluster,1)), ...
            mean(unitvectors(incluster,2))),360);
    end
    [clustermeans,isort] = sort(clustermeans);
    for isorted = 1:2
        icluster = isort(isorted);
        incluster = labels == icluster;
        clusterspeed = median(speedgood(incluster),'omitnan');
        lengthkm = 4*clusterspeed; % 4 km per m/s median speed
        dx = lengthkm*sind(clustermeans(isorted));
        dy = lengthkm*cosd(clustermeans(isorted));
        plot([0 dx],[0 dy],'-o','Color',color,'LineWidth',3, ...
            'MarkerFaceColor',color,'DisplayName',sprintf( ...
            '%s k=2: %.0f%c (n=%d, %.2f m/s)',name,clustermeans(isorted), ...
            char(176),sum(incluster),clusterspeed));
    end
end
for iw = 1:2
    plot([0 sind(watchmeans(iw))],[0 cosd(watchmeans(iw))],'-o', ...
        'Color',[1 0.25 0.8],'LineWidth',2.5,'MarkerFaceColor',[1 0.25 0.8], ...
        'DisplayName',sprintf('Watch k-mean %.0f%c',watchmeans(iw),char(176)));
end
axis equal; xlim((xlimits-x0)/1000); ylim((ylimits-y0)/1000)
xlabel('East of mean position [km]'); ylabel('North of mean position [km]')
legend('Location','best')
title(mission + " depth-median current direction clusters (speed >= 0.2 m/s)", ...
    'Interpreter','none')
print(fh,fullfile(reviewdir,mission + "_L4_L5_direction_clusters"),'-dpng','-r150')
close(fh)

%% Heading validation

sbgheading = mod(audit.mean_heading-mountyaw,360);
declination = 15.10;
% The Signature compass is magnetic and references the Signature x-axis.
% Convert it to true north, then express it in the SBG body frame so it can
% be compared directly with SBG yaw. The velocity correction applies this
% same mount transform as R_earth_T_sbg * R_sbg_T_sig.
signatureheading_sbg = mod(sbgheading+audit.heading_offset+declination-mountyaw,360);
watchplot = mod(watchheading,360);
headingresidual = mod(audit.heading_offset+declination-mountyaw+180,360)-180;
currentu = median(swiftL5.relu,1,'omitnan');
currentv = median(swiftL5.relv,1,'omitnan');
currentspeed = hypot(currentu,currentv);
currentdirection = mod(atan2d(currentu,currentv),360);
currentdirection(currentspeed < 0.2) = NaN;
noop = any(audit.action == "kept_original_valid_ahrs");
if noop
    sbglabel = 'SBG yaw candidate (not applied)';
else
    sbglabel = 'SBG yaw used by L5';
end

fh = figure('Color','w','Position',[50 50 1400 1100]);
theme(fh,'light')
layout = tiledlayout(3,1,'TileSpacing','compact','Padding','compact');
headingax = gobjects(3,1);

headingax(1) = nexttile;
plot(time,watchplot,'.','Color',[0.15 0.15 0.15],'MarkerSize',6, ...
    'DisplayName','Watch-circle bearing'); hold on
plot(time,sbgheading,'.','Color',[0.85 0.2 0.1],'MarkerSize',6, ...
    'DisplayName',sbglabel)
plot(time,signatureheading_sbg,'.','Color',[0 0.45 0.9],'MarkerSize',6, ...
    'DisplayName','Signature true heading (SBG frame)')
ylim([0 360]); yticks(0:90:360); ylabel('heading [degrees]')
grid on; legend('Location','best','NumColumns',3)
title('burst-mean heading sources; points are not connected')

headingax(2) = nexttile;
plot(time,headingresidual,'.','Color',[0.2 0.2 0.2],'MarkerSize',6, ...
    'DisplayName','Frame-aligned Signature minus SBG'); hold on
if ~noop
    yline(0,'--','Color',[0.85 0.2 0.1],'LineWidth',1.2, ...
        'DisplayName','expected = 0')
end
ylim([-180 180]); yticks(-180:45:180); grid on
ylabel('heading difference [degrees]')
xlabel('UTC date in 2025'); legend('Location','best')
title(sprintf('common-frame compass check: magnetic +15.10%c - mount',char(176)))

headingax(3) = nexttile;
plot(time,watchplot,'.','Color',[0.15 0.15 0.15],'MarkerSize',6, ...
    'DisplayName','Watch-circle bearing'); hold on
plot(time,currentdirection,'.','Color',[0 0.65 0.9],'MarkerSize',6, ...
    'DisplayName','L5 depth-median current direction')
ylim([0 360]); yticks(0:90:360); grid on
ylabel('direction [degrees]'); xlabel('UTC date in 2025')
legend('Location','best','NumColumns',2)
title('watch bearing and current direction; speed >= 0.2 m/s')

linkaxes(headingax,'x'); xlim(headingax(1),[min(time) max(time)])
set(headingax(1:2),'XTickLabel',[])
datetick(headingax(3),'x','mm/dd','keeplimits')
title(layout,mission + " heading validation",'Interpreter','none')
print(fh,fullfile(reviewdir,mission + "_heading_validation"),'-dpng','-r150')
close(fh)
end
