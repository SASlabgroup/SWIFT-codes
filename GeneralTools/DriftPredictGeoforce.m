% predict buoy drift from geoforce csv export
%
% J. Thomson, 10/2025

clear all, close all

positions = importdata('BREADCRUMBS.csv');

%% load breadcrumbs from Geoforce website

headerlines = 6;

for pi = (headerlines+1):(length(positions)-1)

    pstring = positions{pi};
    commas = find(pstring == ',');
    time(pi-headerlines) = datenum(pstring(1:22));
    lat(pi-headerlines) = str2num(pstring( (commas(1)+1):(commas(2)-1)  ));
    lon(pi-headerlines) = str2num(pstring( (commas(2)+1):(commas(3)-1)  ));

end

[time sortindex] = sort(time);
lat = lat(sortindex);
lon = lon(sortindex);

figure(1), clf
plot(lon,lat,'x','linewidth',2), hold on
grid

%% calc drift

dlondt = diff(lon) ./ diff(time); % deg per day
dxdt = deg2km(dlondt,6371*cosd(nanmean(lat))) .* 1000 ./ ( 24*3600 ); % m/s

dlatdt = diff(lat) ./ diff(time); % deg per day
dydt = deg2km(dlatdt) .* 1000 ./ ( 24*3600 ); % m/s

speed = sqrt(dxdt.^2 + dydt.^2); % m/s
direction = atan2d(dxdt,dydt); 
direction( direction<0) = direction( direction<0 ) + 360
%direction = atan2d(dydt,dxdt); % cartesian direction [deg]
%direction = direction + 90;  % rotate from eastward = 0 to northward  = 0
%direction( direction<0) = direction( direction<0 ) + 360; %make quadrant II 270->360 instead of -90->0

ratio = [1./abs(cosd(nanmean(lat))),1,1];  % ratio of lat to lon distances at a given latitude
daspect(ratio)

quiver(lon(2:end),lat(2:end),dxdt*ratio(1),dydt)
title(['Last known ' datestr(time(end)) ' PDT: ' [num2str(lat(end)) ',' num2str(lon(end))] ' drifting ' num2str(speed(end)./2,2) ' knts at ' num2str(direction(end),3) ' T'])

%% prediction

targettime = datenum(2025,10,26,20,00,00);
datestr(targettime) 

targetlon = dlondt(end) * (targettime - time(end)) + lon(end)
targetlat = dlatdt(end) * (targettime - time(end)) + lat(end)

plot(targetlon, targetlat, 'rx', 'linewidth',3)
xlabel(['Prediction for ' datestr(targettime) ' PDT: ' num2str(targetlat) ' , ' num2str(targetlon)],'color',[1 0 0])


