% add geoforce positions into SWIFT data structure
% (when primary GPS source is missing)
%
% first open the csv (in Excel), clean up extra columns and remove header
%
% J. Thomson, 10/2025

clear all, close all

csvfile = 'SWIFT17_geoforce_29Oct2025_to_09Nov2025.csv'

timeoffset = -8; % geoforce times are in user local time.  Have not figured out setting UTC

load SWIFT17_telemetry.mat

%% load breadcrumbs from Geoforce website
positions = importdata(csvfile);

headerlines = 0;

lat = positions.data(:,1)';
lon = positions.data(:,2)';

for ti = 1:length(lat)
    time(ti) = datenum(positions.textdata{ti});
end

[time sortindex] = sort(time);
lat = lat(sortindex);
lon = lon(sortindex);


%% calc drift

dlondt = diff(lon) ./ diff(time); % deg per day
dxdt = deg2km(dlondt,6371*cosd(nanmean(lat))) .* 1000 ./ ( 24*3600 ); % m/s

dlatdt = diff(lat) ./ diff(time); % deg per day
dydt = deg2km(dlatdt) .* 1000 ./ ( 24*3600 ); % m/s

speed = sqrt(dxdt.^2 + dydt.^2); % m/s
direction = atan2d(dxdt,dydt); 
direction( direction<0) = direction( direction<0 ) + 360;
%direction = atan2d(dydt,dxdt); % cartesian direction [deg]
%direction = direction + 90;  % rotate from eastward = 0 to northward  = 0
%direction( direction<0) = direction( direction<0 ) + 360; %make quadrant II 270->360 instead of -90->0

%% match to SWIFT structure

for si=1:length(SWIFT)

    [tdiff matchind] = min( abs( SWIFT(si).time - time + timeoffset ) );
    
    if tdiff < 2/24
        SWIFT(si).lat = lat(matchind);
        SWIFT(si).lon = lon(matchind);
        SWIFT(si).driftspd = speed(matchind);
        SWIFT(si).driftdirT = direction(matchind);
    else
        SWIFT(si).lat = NaN;
        SWIFT(si).lon = NaN;
        SWIFT(si).driftspd = NaN;
        SWIFT(si).driftdirT = NaN;
    end

end

%% OR interp

newlat = interp1(time,lat,[SWIFT.time]);
newlon = interp1(time,lon,[SWIFT.time]);
newspeed = interp1(time,[speed NaN],[SWIFT.time]);
newdirection = interp1(time,[direction NaN],[SWIFT.time]);


for si=1:length(SWIFT)
        matchind = si;
        SWIFT(si).lat = newlat(matchind);
        SWIFT(si).lon = newlon(matchind);
        SWIFT(si).driftspd = newspeed(matchind);
        SWIFT(si).driftdirT = newdirection(matchind);

        SWIFT(si).sigwaveheight = NaN;
        SWIFT(si).peakwaveperiod = NaN;
        SWIFT(si).peakwavedirT = NaN;
end