function [ lat lon sog cog depth time altitude ] = readNMEA(filename, varargin)
% function to read NMEA data from SWIFTs and other platforms
% return variables and automatically save mat file
%
%   [ lat lon sog cog depth time altitude] = readNMEA(filename, varargin);
%
%       where varargin is an option to specify spaces to skip at the
%       beginning of each line (must be positive integer)
%
% J. Thomson,  4/2012
%              9/2012 (fix wind dir north wrap bug, use u,v components)
%              12/2014  adapt for v3 SWIFTs
%               Jun 2015 converted to a function
%               7/2020 adapted to generic use, without wind data (use PB200 for that)
%               9/2020  include depth (DBT) sentence
%               1/2021  read time from GGA or RMC when ZDA not present, but note that it is only time (not date)
%               8/2021 include altitude from GGA 
%               10/2025 enforce ZDA timestamp if present, and choose position source based on availability
%
%   
% TO DO: still need to acount for S or E hemispheres

%% params

bootlines = 0;

if length(varargin{:})==1
    skipspaces = [1:varargin{1}];
else
    skipspaces = empty;
end


%% initialize
lat = [];
lon = [];
sog = [];
cog = [];
depth = [];
time = [];
altitude =[];

linenum = 0;
vtglength = 0;
ggalength = 0;
glllength = 0;
zdalength = 0;
dbtlength = 0;
rmclength = 0;

fid = fopen( filename );
while 1
    tline = fgetl(fid);
    linenum = linenum + 1;
    if length(tline)>6 & linenum > bootlines,
       
        tline(skipspaces) = [];

        %% VTG
        if tline(1:6) == '$GPVTG' & length(tline) > 25,
            veldata = textscan(tline,'%s%n%s%n%s%n%s%n%s%s','Delimiter',',');
            if length(veldata{2})==1 & length(veldata{8})==1 & length(veldata{10})==1,
                vtglength = vtglength + 1;
                vtgcog(vtglength) = veldata{1+1}; % deg T
                vtgsog(vtglength) = veldata{7+1} * .2777; % convert from Km/h to m/s;
                velmode(vtglength) = veldata{9+1};  % D is differential (best)
                vtglinenum(vtglength) = linenum;
            else
            end
            
            %% GLL
        elseif tline(1:6) == '$GPGLL' & length(tline) > 25 & length(tline)<90,
            gpsdata = textscan(tline,'%s%s%s%s%s%[^\n]','Delimiter',',');
            if ~isempty(gpsdata{2}) & ~isempty(gpsdata{4}),% & char(gpsdata{3})=='N' & char(gpsdata{3})=='W',
                glllength = glllength + 1;
                latstring = char(gpsdata{1+1}); % string
                thislat = str2num(latstring(1:2)) + str2num(latstring(3:9))./60; % decimal degrees
                if length(thislat)==1 , glllat(glllength) = thislat;
                else
                    glllat(glllength) = NaN;
                end
                lonstring = char(gpsdata{3+1}); % string
                thislon = - ( str2num(lonstring(1:3)) + str2num(lonstring(4:10))./60 ); % decimal degress W
                if length(thislon)==1 ,
                    glllon(glllength) = thislon;
                else
                    glllon(glllength) = NaN;
                end
                glllinenum(glllength) = linenum;
            else
            end
            
            %% GGA
        elseif tline(1:6) == '$GPGGA' & length(tline) > 30,
            gpsdata = textscan(tline,'%s%s%s%s%s%s%s%n%s%n%s%[^\n]','Delimiter',',');
            ggalength = ggalength + 1;
            timestring = char(gpsdata{1+1}); % hh:mm:sec , but no year, month, or date (so assign zero)
            ggatime(ggalength) =  datenum(0, 0, 0, str2num(timestring(1:2)), str2num(timestring(3:4)),str2num(timestring(5:end)) );
            latstring = char(gpsdata{2+1}); % string
            if length(latstring)==9
                ggalat(ggalength) = ( str2num(latstring(1:2)) + str2num(latstring(3:9))./60 ); % decimal degress W
            else
                ggalat(ggalength) = NaN;
            end
            lonstring = char(gpsdata{4+1}); % string
            if length(lonstring)==10
                ggalon(ggalength) = - ( str2num(lonstring(1:3)) + str2num(lonstring(4:10))./60 ); % decimal degress W
            else
                ggalon(ggalength) = NaN;
            end
            gpsquality(ggalength) = gpsdata{6+1}; % 2 is differential (best)
            altitude(ggalength) = gpsdata{9+1};
            ggalinenum(ggalength) = linenum;
            
            %% RMC
        elseif tline(1:6) == '$GPRMC' & length(tline) > 30,
            gpsdata = textscan(tline,'%s%s%s%s%s%s%s%n%n%s%[^\n]','Delimiter',',');
            rmclength = rmclength + 1;
            timestring = char(gpsdata{2}); % hhmmss.ms , but no year, month, or date (so assign zero)
            datestring = char(gpsdata{10});% ddmmyy
            rmctime(rmclength) =  datenum(2000+str2num(datestring(5:6)), str2num(datestring(3:4)), str2num(datestring(1:2)), ...
                str2num(timestring(1:2)), str2num(timestring(3:4)),str2num(timestring(5:end)) );
            latstring = char(gpsdata{4}); % string
            if length(latstring)==9
                rmclat(rmclength) = ( str2num(latstring(1:2)) + str2num(latstring(3:9))./60 ); % decimal degress W
            else
                rmclat(rmclength) = NaN;
            end
            lonstring = char(gpsdata{6}); % string
            if length(lonstring)==10
                rmclon(rmclength) = - ( str2num(lonstring(1:3)) + str2num(lonstring(4:10))./60 ); % decimal degress W
            else
                rmclon(rmclength) = NaN;
            end
            gpsquality(rmclength) = gpsdata{3}; % A=active or V=void
            rmcsog(rmclength) = gpsdata{8} * 0.514; % convert from knots to m/s
            rmccog(rmclength) = gpsdata{9};
            rmclinenum(rmclength) = linenum;
            
            %% ZDA
        elseif tline(1:6) == '$GPZDA' & length(tline) > 25,
            timedata = textscan(tline,'%s%s%n%n%n%[^\n]','Delimiter',',');
            zdalength = zdalength + 1;
            hhmmss = char(timedata{1+1}); % string
            day = timedata{2+1};
            month = timedata{3+1};
            year = timedata{4+1};
            time(zdalength) = datenum( year, month, day, str2num(hhmmss(1:2)), str2num(hhmmss(3:4)), str2num(hhmmss(5:6)) );
            timelinenum(zdalength) = linenum;
            
            %% DBT
        elseif tline(1:6) == '$GPDBT' & length(tline) > 20,
            dbtdata = textscan(tline,'%s%n%s%n%s%n%[^\n]','Delimiter',','); % feet, meter, fathoms
            dbtlength = dbtlength + 1;
            depthft(dbtlength) = dbtdata{1+1};
            depth(dbtlength) = dbtdata{3+1}; % meters
            dbtlinenum(dbtlength) = linenum;
        elseif tline(1:6) == '$SDDPT' & length(tline) > 6,
            dbtdata = textscan(tline,'%s%n%n%[^\n]','Delimiter',','); % feet, meter, fathoms
            dbtlength = dbtlength + 1;
            depth(dbtlength) = dbtdata{1+1}; % units?
            dbtlinenum(dbtlength) = linenum;
        else
        end
    else
    end
    if tline==-1, break, end
end
fclose(fid);

%% debug output 
% vtglength
% ggalength
% glllength
% zdalength
% dbtlength
% rmclength

%% choose which positions to use based on what data is available

[m mi] = max([ggalength, glllength, rmclength ]);

if mi == 1
    preferedsentence = 'GGA' % GGA or RMC or GLL
elseif mi == 2
    preferedsentence = 'GLL' % GGA or RMC or GLL
elseif mi == 3
    preferedsentence = 'RMC' % GGA or RMC or GLL
end


if preferedsentence == 'RMC' & rmclength>0,
    lat = rmclat;
    lon = rmclon;
    positionlinenumber = rmclinenum;
    sog = rmcsog;
    cog = rmccog;

elseif preferedsentence == 'GGA' & ggalength>0,
    lat = ggalat;
    lon = ggalon;
    positionlinenumber = ggalinenum;
    if vtglength>0
        sog = vtgsog;
        cog = vtgcog;
    end
elseif preferedsentence == 'GLL' & glllength>0,
    lat = glllat;
    lon = glllon;
    positionlinenumber = glllinenum;
    if vtglength>0,
        sog = vtgsog;
        cog = vtgcog;
    end
end

%% choose time source, with ZDA preferred

if zdalength > 0.01 * linenum % if ZDA are at least 1% of the data
    disp('Using ZDA sentences for time and date')
elseif preferedsentence == 'RMC'
    time = rmctime;
    timelinenum = rmclinenum;
    disp('Using RMC sentences for time (no date available)')
elseif preferedsentence == 'GGA'
    time = ggatime;
    timelinenum = ggalinenum;
    disp('Using GGA sentences for time (no date available)')
end


%% interpolate time and position data onto the depth readings
if ~isempty(depth) & ~isempty(time)
    
    depthtime = interp1( timelinenum, time, dbtlinenum);
    depthlat = interp1( positionlinenumber, lat, dbtlinenum);
    depthlon = interp1( positionlinenumber, lon, dbtlinenum);
    
    time = depthtime;
    lat = depthlat;
    lon = depthlon;
    
end

%% Export to CSV
% Determine the maximum length to create properly sized arrays
maxlen = max([length(lat), length(lon), length(sog), length(cog), length(depth), length(time), length(altitude)]);

% Pad arrays to same length with NaN
lat_padded = [lat(:); nan(maxlen - length(lat), 1)];
lon_padded = [lon(:); nan(maxlen - length(lon), 1)];
sog_padded = [sog(:); nan(maxlen - length(sog), 1)];
cog_padded = [cog(:); nan(maxlen - length(cog), 1)];
depth_padded = [depth(:); nan(maxlen - length(depth), 1)];
time_padded = [time(:); nan(maxlen - length(time), 1)];
altitude_padded = [altitude(:); nan(maxlen - length(altitude), 1)];

% Convert time to datestring
timestring_padded = cell(maxlen, 1);
for i = 1:length(time_padded)
    if ~isnan(time_padded(i))
        timestring_padded{i} = datestr(time_padded(i), 'yyyymmddTHH:MM:SS');
    else
        timestring_padded{i} = '';
    end
end

% Create table
T = table(timestring_padded, lat_padded, lon_padded, sog_padded, cog_padded, depth_padded, altitude_padded, ...
    'VariableNames', {'DateTime', 'Latitude_deg', 'Longitude_deg', 'SOG_ms', 'COG_deg', 'Depth_m', 'Altitude_m'});

% Generate output filename
[filepath, name, ext] = fileparts(filename);
csvfilename = fullfile(filepath, [name '_NMEA.csv']);

% Write to CSV
writetable(T, csvfilename);

fprintf('Data read into workspace and exported to: %s\n', csvfilename);
