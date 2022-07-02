function [time rawwindspd rawwinddir rawairtemp rawairpres lat lon sog cog pitch roll] = readSWIFTv3_PB2(filename);
% function to read Airmar data (wind and gps in 'PB2' files) from SWIFTs 
% return variables and automatically save mat file
%
% [time rawwindspd rawwinddir rawairtemp rawairpres lat lon sog cog pitch roll] = readSWIFTv3_PB2(filename);
%
%
% J. Thomson,  4/2012
%              9/2012 (fix wind dir north wrap bug, use u,v components)
%              12/2014  adapt for v3 SWIFTs
%               Jun 2015 converted to a function


linenum = 0;
mdalength = 0;
vtglength = 0;
xdrlength = 0;
ggalength = 0;
zdalength = 0;

fid = fopen([filename]);
while 1
tline = fgetl(fid);
linenum = linenum + 1;
if length(tline)>6 & linenum > 1000, % skip boot-up
    % met data, see PB100TechnicalManual_rev1.pdf, page 15
    % use wind in knts and convert, b/c 0.1 knt is better res than 0.1 m/s
    if tline(1:6) == '$WIMDA' & length(tline) > 50 & length(tline)<90,
        metdata = textscan(tline,'%s%n%s%n%s%n%s%n%s%n%s%n%s%n%s%n%s%n%s%n%s','Delimiter',',');
        if ~isempty(metdata{17+1}),
            mdalength = mdalength + 1;
            rawwindspd(mdalength) = metdata{17+1}*0.5144444; % TRUE knts converted to m/s
            rawwinddir(mdalength) = metdata{15+1}; % deg MAG
            WindType = 'M';
            rawairtemp(mdalength) = metdata{5+1};
            rawairpres(mdalength) = metdata{1+1};
            metlinenum(mdalength) = linenum;
        else end
        % GPS velocity data, see PB100TechnicalManual_rev1.pdf, page 22
        % NOTE VELOCITES ARE TOO DISCRETIZED (0.1 KM/HR) FOR WAVE SPECTRA
    elseif tline(1:6) == '$GPVTG' & length(tline) > 25,
        veldata = textscan(tline,'%s%n%s%n%s%n%s%n%s%s','Delimiter',',');
        if length(veldata{2})==1 & length(veldata{8})==1 & length(veldata{10})==1,
            vtglength = vtglength + 1;
            cog(vtglength) = veldata{1+1}; % deg T
            sog(vtglength) = veldata{7+1} * .2777; % convert from Km/h to m/s;
            velmode(vtglength) = veldata{9+1};  % D is differential (best)
            vellinenum(vtglength) = linenum;
        else
        end
        % GPS position data, see PB100TechnicalManual_rev1.pdf, page 6
    elseif tline(1:6) == '$GPGLL' & length(tline) > 25 & length(tline)<90,
        gpsdata = textscan(tline,'%s%s%s%s%s%[^\n]','Delimiter',',');
        if ~isempty(gpsdata{2}) & ~isempty(gpsdata{4}),% & char(gpsdata{3})=='N' & char(gpsdata{3})=='W',
            ggalength = ggalength + 1;
            latstring = char(gpsdata{1+1}); % string
            thislat = str2num(latstring(1:2)) + str2num(latstring(3:9))./60; % decimal degrees
            if length(thislat)==1 , lat(ggalength) = thislat; else lat(ggalength) = NaN; end
            lonstring = char(gpsdata{3+1}); % string
            thislon = - ( str2num(lonstring(1:3)) + str2num(lonstring(4:10))./60 ); % decimal degress, negative assumes western hemisphere
            if length(thislon)==1 , lon(ggalength) = thislon; else lon(ggalength) = NaN; end
            positionlinenum(ggalength) = linenum;
        else
        end
        % GPS position data, see PB100TechnicalManual_rev1.pdf, page 8
    elseif tline(1:6) == '$GPGGA' & length(tline) > 30,
        gpsdata = textscan(tline,'%s%s%s%s%s%s%s%n%s%n%s%[^\n]','Delimiter',',');
        ggalength = ggalength + 1;
        latstring = char(gpsdata{2+1}); % string
        lat(ggalength) = - ( str2num(latstring(1:3)) + str2num(latstring(4:10))./60 ); % decimal degress, negative assumes western hemisphere
        %thislat = str2num(latstring(1:2)) + str2num(latstring(3:9))./60; % decimal degrees
        %if length(thislat)==1, lat(ggalength) = thislat; else lat(ggalength) = NaN; end
        lonstring = char(gpsdata{4+1}); % string
        lon(ggalength) = - ( str2num(lonstring(1:3)) + str2num(lonstring(4:10))./60 ); % decimal degress, negative assumes western hemisphere
        gpsquality(ggalength) = gpsdata{6+1}; % 2 is differential (best)
        positionlinenum(ggalength) = linenum;
        % motion data, see PB100TechnicalManual_rev1.pdf, page 27
    elseif tline(1:6) == '$YXXDR' & length(tline) > 25, % note version 'B'
        motiondata = textscan(tline,'%s%s%n%s%s%s%n%s%s%[^\n]','Delimiter',',');
        if ~isempty(motiondata{3}) & ~isempty(motiondata{6+1})
            xdrlength = xdrlength + 1;
            pitch(xdrlength) = motiondata{2+1}; % deg, along SWIFT vane axis (AQD beam 1)
            roll(xdrlength) = motiondata{6+1}; % deg, transvers across SWIFT vane axis
            motionlinenum(xdrlength) = linenum;
        else end
        % GPS time data, see PB100TechnicalManual_rev1.pdf, page 30
    elseif tline(1:6) == '$GPZDA' & length(tline) > 25,
        timedata = textscan(tline,'%s%s%n%n%n%[^\n]','Delimiter',',');
        zdalength = zdalength + 1;
        hhmmss = char(timedata{1+1}); % string
        day = timedata{2+1};
        month = timedata{3+1};
        year = timedata{4+1};
        gpstime(zdalength) = datenum( year, month, day, str2num(hhmmss(1:2)), str2num(hhmmss(3:4)), str2num(hhmmss(5:6)) );
        timelinenum(zdalength) = linenum;
    else
    end
else
end
if tline==-1, break, end
end
fclose(fid);


if zdalength>1, % valid data indicated by a time string

    [timelinenum ui ] = unique(timelinenum);
    gpstime = gpstime(ui);

    alltime = interp1(timelinenum,gpstime,[1:linenum],'linear','extrap');

    save([filename(1:end-4) '.mat']);

else
    disp('no valid timestamps (ZDA string)')
    alltime = NaN;
end

time = alltime;
