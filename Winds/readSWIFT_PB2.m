function [time,windspd,windspdR,winddirT,winddirR,airtemp,airpres,humidity,lat,lon,sog,cog,pitch,roll]  = readSWIFT_PB2(filename)
% % readSWIFT_PB2 reads in raw Airmar Data.

% The following data types are read in according to format in 
%  PB100TechnicalManual_rev1.pdf:

%   '$GPVTG' - GPS velocity data (pg. 22). 
%   '$WIMDA' - MET data, including true wind + direction (pg. 15)
%   '$WIMWV' - Wind data only (relative) (pg. 
%   '$GPGLL' - GPS standard lat/lon data (pg. 6)
%   '$GPGGA' - GPS 'fix' position data (pg. 8)
%   '$YXXDR' - Motion data (pg. 27)
%   '$GPZDA' - GPS time data (pg. 30)

% Notes: Use wind in knts (and convert to m/s) b/c 0.1 knt is a higher res
% than 0.1 m/s. GPS velocity data is too discretized (0.1 km/hr) for wave
% spectra. Lat + Lon are need to be converted to decimal degrees, and lon
% to negative (assumes western hemisphere). 'Pitch' from motion log is 
% along SWIFT vane axis (AQD beam 1), and 'Roll' is transvers across SWIFT
% vane axis. After being read in, time is interpolated to GPS position
% indices.

T = importdata(filename);

% Remove header
T = T(contains(T,'$') & ~contains(T,'PAMTT'));
nline = length(T);

%% Loop through each text line in read in data depending on log type

% Initial indices
imda = 0;
imwv = 0;
ivtg = 0;
ixdr = 0;
igga = 0;
izda = 0;

% Track gps + time indices
timeindex = NaN;
posindex = NaN;

% Initialize data vectors;
gpstime = NaN;
windspd = NaN;
windspdR = NaN;
winddirT = NaN;
winddirR = NaN;
airtemp = NaN;
airpres = NaN;
humidity = NaN;
lat = NaN;
lon = NaN;
sog = NaN;
cog = NaN;
pitch = NaN;
roll = NaN;

for iline = 1:nline

    % Text line
    tline = T{iline};

    if length(tline)<6
        continue
    end
    
    % Log type
    logtype = tline(1:6);
    
    switch logtype

        case '$WIMDA'% MET data 

            if length(tline) > 50 && length(tline) < 90
            metdata = textscan(tline,'%s%n%s%n%s%n%s%n%s%n%s%n%s%n%s%n%s%n%s%n%s',...
                'Delimiter',',');

            if ~isempty(metdata{17+1})

                imda = imda + 1;
                windspd(imda) = metdata{17+1}*0.5144444; % knts to m/s
                winddirT(imda) = metdata{15+1}; % deg MAG
                airtemp(imda) = metdata{5+1};
                airpres(imda) = metdata{1+1};
                humidity(imda) = metdata{9+1};% relative, percent

            end
            end
   
        case '$WIMWV' % MET data
            metdata = textscan(tline,'%s%n%s%n%s%s','Delimiter',',');

            if ~isempty(metdata{3+1}) && ~any(size(metdata{1+1})>1)

                imwv = imwv + 1;
                windspdR(imwv) = metdata{3+1}*0.5144444; % knts to m/s
                winddirR(imwv) = metdata{1+1};

            end

        case '$GPVTG' % GPS velocity data
            
            if length(tline) > 25
            veldata = textscan(tline,'%s%n%s%n%s%n%s%n%s%s',...
                'Delimiter',',');

            if length(veldata{1+1}) == 1 && length(veldata{7+1}) == 1

                ivtg = ivtg + 1;
                cog(ivtg) = veldata{1+1}; % deg T
                sog(ivtg) = veldata{7+1} * .2777; % Km/h to m/s;

            end
            end
    
        case '$GPGLL' % GPS position data
            
            if length(tline) > 25 && length(tline) < 90
            gpsdata = textscan(tline,'%s%s%s%s%s%[^\n]','Delimiter',',');

            if ~isempty(gpsdata{1+1}) && ~isempty(gpsdata{1+3})

                igga = igga + 1;

                % Latitude
                latstring = char(gpsdata{1+1});
                if length(latstring) >= 9
                    thislat = str2double(latstring(1:2)) + ...
                        str2double(latstring(3:9))./60;% decimal degress
                else
                    thislat = NaN;
                end
                if length(thislat) == 1
                    lat(igga) = thislat;
                else 
                    lat(igga) = NaN; 
                end

                % Longitude
                lonstring = char(gpsdata{3+1});
                if length(lonstring) >= 10
                    thislon = -(str2double(lonstring(1:3)) + ...
                        str2double(lonstring(4:10))./60); % decimal degress
                else
                    thislon = NaN;
                end
                if length(thislon) == 1
                    lon(igga) = thislon;
                else 
                    lon(igga) = NaN; 
                end
                
                posindex(igga) = iline;

            end
            end
    
        case '$GPGGA' % GPS position data

            if length(tline) > 30
            gpsdata = textscan(tline,'%s%s%s%s%s%s%s%n%s%n%s%[^\n]',...
                'Delimiter',',');

            igga = igga + 1;
            latstring = char(gpsdata{2+1});
            lat(igga) = - (str2double(latstring(1:3)) + ...
                str2double(latstring(4:10))./60 ); % decimal degress
            lonstring = char(gpsdata{4+1});
            lon(igga) = - (str2double(lonstring(1:3)) + ...
                str2double(lonstring(4:10))./60 );% decimal degress

            posindex(igga) = iline;
            end
    
        case '$YXXDR' % Motion data

            if length(tline) > 25
            motiondata = textscan(tline,'%s%s%n%s%s%s%n%s%s%[^\n]',...
                'Delimiter',',');

            if ~isempty(motiondata{3}) && ~isempty(motiondata{6+1})
                ixdr = ixdr + 1;
                pitch(ixdr) = motiondata{2+1}; % deg
                roll(ixdr) = motiondata{6+1}; % deg
            end
            end
    
        case '$GPZDA' % GPS time data

            if length(tline) > 25
            timedata = textscan(tline,'%s%s%n%n%n%[^\n]','Delimiter',',');
            izda = izda + 1;
            hhmmss = char(timedata{1+1});
            day = timedata{2+1};
            month = timedata{3+1};
            year = timedata{4+1};
            if length(hhmmss)>=6
                gpstime(izda) = datenum(year,month,day, ...
                    str2double(hhmmss(1:2)),str2double(hhmmss(3:4)),...
                    str2double(hhmmss(5:6)));
            else
                gpstime(izda) = NaN;
            end
            timeindex(izda) = iline;
            end
                
        otherwise % Unknown data type
            disp(['Line ' num2str(iline) ' unrecognized log type:' logtype])
    end
end

%% Interpolate time to GPS position indices
if izda > 1 && exist('posindex','var')% valid data indicated by a time string

    [timeindex,ui] = unique(timeindex);
    gpstime = gpstime(ui);
    ireal = ~isnan(gpstime);
    if sum(ireal) <= 2
        time = NaN(size(windspd));
    else
    time = interp1(timeindex(ireal),gpstime(ireal),posindex,...
        'linear','extrap');
    end
else
    time = NaN(size(windspd));
    disp('No valid timestamps (ZDA string).')
end

%% Save
save([filename(1:end-4) '.mat'],'time','windspd','winddirT','windspdR',...
    'winddirR','airtemp','airpres','lat','lon','sog','cog','pitch','roll');

end