function [ lat lon sog cog depth time ] = readNMEA(filename);
% function to read NMEA data from SWIFTs and other platforms
% return variables and automatically save mat file
%
% [ lat lon sog cog depth time] = readNMEA(filename);
%
%
% J. Thomson,  4/2012
%              9/2012 (fix wind dir north wrap bug, use u,v components)
%              12/2014  adapt for v3 SWIFTs
%               Jun 2015 converted to a function
%               7/2020 adapted to generic use, without wind data (use PB200 for that)
%               9/2020  include depth (DBT) sentence

%% initialize
lat = [];
lon = [];
sog = [];
cog = [];
depth = [];
time = [];

linenum = 0;
vtglength = 0;
ggalength = 0;
zdalength = 0;
dbtlength = 0;

fid = fopen([filename]);
while 1
    tline = fgetl(fid);
    linenum = linenum + 1;
    if length(tline)>6 & linenum > 1000, % skip boot-up
        if tline(1:6) == '$GPVTG' & length(tline) > 25,
            veldata = textscan(tline,'%s%n%s%n%s%n%s%n%s%s','Delimiter',',');
            if length(veldata{2})==1 & length(veldata{8})==1 & length(veldata{10})==1,
                vtglength = vtglength + 1;
                cog(vtglength) = veldata{1+1}; % deg T
                sog(vtglength) = veldata{7+1} * .2777; % convert from Km/h to m/s;
                velmode(vtglength) = veldata{9+1};  % D is differential (best)
                vellinenum(vtglength) = linenum;
            else
            end
        elseif tline(1:6) == '$GPGLL' & length(tline) > 25 & length(tline)<90,
            gpsdata = textscan(tline,'%s%s%s%s%s%[^\n]','Delimiter',',');
            if ~isempty(gpsdata{2}) & ~isempty(gpsdata{4}),% & char(gpsdata{3})=='N' & char(gpsdata{3})=='W',
                ggalength = ggalength + 1;
                latstring = char(gpsdata{1+1}); % string
                thislat = str2num(latstring(1:2)) + str2num(latstring(3:9))./60; % decimal degrees
                if length(thislat)==1 , lat(ggalength) = thislat; else lat(ggalength) = NaN; end
                lonstring = char(gpsdata{3+1}); % string
                thislon = - ( str2num(lonstring(1:3)) + str2num(lonstring(4:10))./60 ); % decimal degress W
                if length(thislon)==1 , lon(ggalength) = thislon; else lon(ggalength) = NaN; end
                positionlinenum(ggalength) = linenum;
            else
            end
        elseif tline(1:6) == '$GPGGA' & length(tline) > 30,
            gpsdata = textscan(tline,'%s%s%s%s%s%s%s%n%s%n%s%[^\n]','Delimiter',',');
            ggalength = ggalength + 1;
            latstring = char(gpsdata{2+1}); % string
            if length(latstring)==9
                lat(ggalength) = ( str2num(latstring(1:2)) + str2num(latstring(3:9))./60 ); % decimal degress W
            else
                lat(ggalength) = NaN;
            end
            %thislat = str2num(latstring(1:2)) + str2num(latstring(3:9))./60; % decimal degrees
            %if length(thislat)==1, lat(ggalength) = thislat; else lat(ggalength) = NaN; end
            lonstring = char(gpsdata{4+1}); % string
            if length(lonstring)==10
                lon(ggalength) = - ( str2num(lonstring(1:3)) + str2num(lonstring(4:10))./60 ); % decimal degress W
            else
                lon(ggalength) = NaN;
            end
            gpsquality(ggalength) = gpsdata{6+1}; % 2 is differential (best)
            positionlinenum(ggalength) = linenum;
        elseif tline(1:6) == '$GPZDA' & length(tline) > 25,
            timedata = textscan(tline,'%s%s%n%n%n%[^\n]','Delimiter',',');
            zdalength = zdalength + 1;
            hhmmss = char(timedata{1+1}); % string
            day = timedata{2+1};
            month = timedata{3+1};
            year = timedata{4+1};
            time(zdalength) = datenum( year, month, day, str2num(hhmmss(1:2)), str2num(hhmmss(3:4)), str2num(hhmmss(5:6)) );
            timelinenum(zdalength) = linenum;
        elseif tline(1:6) == '$GPDBT' & length(tline) > 20,
            dbtdata = textscan(tline,'%s%n%s%n%s%n%[^\n]','Delimiter',','); % feet, meter, fathoms
            dbtlength = dbtlength + 1;
            depthft(dbtlength) = dbtdata{1+1};
            depth(dbtlength) = dbtdata{3+1}; % meters
            dbtlinenum(dbtlength) = linenum;
        else
        end
    else
    end
    if tline==-1, break, end
end
fclose(fid);


%% interpolate to depth readings
if ~isempty(depth),
    
    depthtime = interp1( timelinenum, time, dbtlinenum);
    depthlat = interp1( positionlinenum, lat, dbtlinenum);
    depthlon = interp1( positionlinenum, lon, dbtlinenum);
    
    time = depthtime;
    lat = depthlat;
    lon = depthlon;
 
end
