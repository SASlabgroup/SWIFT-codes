% Aggregate and read all SWIFT sbd data after concatenating the 
%   offload from SD card or the sbd email attachments. SBD files should be in the 
%   'ConcatProcessed' subfolder of any given SWIFT mission folder.
%   Based on compileSWIFT_SBDservertelemetry.m
% K. Zeiden 10/01/2024

%% Experiment directory
expdir = 'S:\SEAFAC\June2024';

%% Set Parameters
if ispc
    slash = '\';
else
    slash = '/';
end

% Processing parameters
plotflag = false;  % binary flag for plotting (compiled plots, not individual plots... that flag is in the readSWIFT_SBD call)
fixspectra = false; % binary flag to redact low freq wave spectra, note this also recalcs wave heights
fixpositions = false; % binary flag to use "filloutliers" to fix spurious positions.   Use with care. 

% QC Parameters
minwaveheight = 0;% minimum wave height in data screening
minsalinity = 0;% PSU, for use in screen points when buoy is out of the water (unless testing on Lake WA)
maxdriftspd = 5;% m/s, this is applied to telemetry drift speed, but reported drift is calculated after that 
maxwindspd = 30;% m/s for malfunctioning Airmars
minairtemp = -20;% min airtemp
disp('-------------------------------------')
disp('QC settings:')
disp(['Minimum wave height: ' num2str(minwaveheight) ' m'])
disp(['Minimum salinity: ' num2str(minsalinity) ' m'])
disp(['Maximum drift speed: ' num2str(maxdriftspd) ' m'])
disp(['Maximum wind speed: ' num2str(maxwindspd) ' m'])
disp(['Minimum air temp: ' num2str(minairtemp) ' m'])
disp('-------------------------------------')

%% List missions

missions = dir([expdir slash 'SWIFT*']);
missions = missions([missions.isdir]);

% for im = 1:length(missions)
im = 1;

missiondir = [missions(im).folder slash missions(im).name];
sname = missions(im).name;

disp(['Compiling ' sname ' SWIFT structure:'])

% Compile list of sbd burst files
if exist([missiondir slash 'ConcatProcessed'],'dir')
    blist = dir([missiondir slash 'ConcatProcessed' slash '*.sbd']);
else
    disp('Processed files have not been concatenated...')
    blist = [];
end
nburst = length(blist);

% Initialize badburst flag
badburst = false(1,nburst);

% Keep track of the number of fields in each burst
nfields = NaN(1,nburst);

%% Loop through all SBD burst files, load, QC, and save in SWIFT structure

for iburst = 1:nburst

    disp(['Burst file ''' blist(iburst).name ''''])
        
    [oneSWIFT,voltage]= readSWIFT_SBD([blist(iburst).folder slash blist(iburst).name],0);
    
    if voltage == 9999 % error flag from SBD message
        badburst(iburst) = true; 
    end
    
    if ~isempty(voltage)
        oneSWIFT.battery = voltage;
    else
        oneSWIFT.battery = NaN;
    end
    
    if isempty(oneSWIFT.lat) || isempty(oneSWIFT.lon)
        oneSWIFT.lat = NaN;
        oneSWIFT.lon = NaN;
    end
    
    %%% Time stamp %%%
    % Take the time from the filename, even when there is time from 
    %     the airmar (because of parsing errors). For telemetry, this 
    %     is the telemtry time (at the end of the burst). For offloaded data,
    %     this the concat file name (from the start of the burst).
    if blist(iburst).name(6) == 'S' % SWIFT v3 and v4
        nameoffset = 14;
        day = blist(iburst).name(nameoffset + (1:2));
        month = blist(iburst).name(nameoffset + (3:5));
        year = blist(iburst).name(nameoffset + (6:9));
        hr = blist(iburst).name(nameoffset + (11:12));
        minute = blist(iburst).name(nameoffset + (13:14));
        sec = blist(iburst).name(nameoffset + (15:16));
        oneSWIFT.time = datenum([day ' ' month ' ' year ' ' hr ':' minute ':' sec]);
        micro = false;
    elseif blist(iburst).name(6) == 'm' % microSWIFT
        % Use the time embedded within the payload 50 or 51 or 52 of the
        % SBD file, which is the time at the end of the burst of raw data.
        nameoffset = 20;
        micro = true;
    else
        nameoffset = 0;
        oneSWIFT.time = NaN;
        micro = false;
    end
    
    %%% Remove bad Airmar data %%%
    if isfield(oneSWIFT,'airtemp')
        if oneSWIFT.airtemp == 0.0 || oneSWIFT.airtemp < minairtemp || oneSWIFT.airtemp > 50
            oneSWIFT.airtemp = NaN;
            oneSWIFT.windspd = NaN;
        end
    end 
    
    %%% Extrapolate missing low frequencies of wave energy spectra %%
    % while requiring energy at lowest frequenc to be zero
    % not neccessary if post-processing for raw displacements
    % less necessary after Oct 2017 rev of onboard processing with improved RC filter
    if fixspectra && isfield(oneSWIFT,'wavespectra')
        notzero = find(oneSWIFT.wavespectra.energy ~= 0 & oneSWIFT.wavespectra.freq > 0.04);
        tobereplaced =  find(oneSWIFT.wavespectra.energy == 0 & oneSWIFT.wavespectra.freq > 0.04);
        if length(notzero) > 10
            E = interp1([0.04; oneSWIFT.wavespectra.freq(notzero)],[0; oneSWIFT.wavespectra.energy(notzero)],oneSWIFT.wavespectra.freq);
            oneSWIFT.wavespectra.energy(tobereplaced) = E(tobereplaced);
            df = median(diff(oneSWIFT.wavespectra.freq));
            oneSWIFT.sigwaveheight = 4*sqrt(sum(oneSWIFT.wavespectra.energy,'omitnan')*df);
        end
    end
    
    %%% Remove wave histograms %%%
    if isfield(oneSWIFT,'wavehistogram')
        oneSWIFT = rmfield(oneSWIFT,'wavehistogram');
    end
        
    %%% Screen the bad data (usually out of the water) %%%
    disp('=================================')
    % No data
    if isempty(oneSWIFT.lon) || isempty(oneSWIFT.lat) || isempty(oneSWIFT.time)
        badburst(iburst) = true;
        disp('No position or timestamp.')
    end
    % No position
    if oneSWIFT.lon == 0 || ~isnumeric(oneSWIFT.lon)
        badburst(iburst) = true;
        disp('No position.')
    end
    % Waves too small
    if isfield(oneSWIFT,'sigwaveheight')
        if oneSWIFT.sigwaveheight < minwaveheight || oneSWIFT.sigwaveheight >= 999
            badburst(iburst) = true;
            disp('Waves too small, removing burst.')
        end
    end
    % Salinity too small
    if isfield(oneSWIFT,'salinity') %&& ~micro
        if all(oneSWIFT.salinity < minsalinity) % & all(~isnan(oneSWIFT.salinity)),
            badburst(iburst) = true;
            disp('Salinity too low, removing burst.')
        end
    end
    % Drift speed limit
    if isfield(oneSWIFT,'driftspd')
        if oneSWIFT.driftspd > maxdriftspd
            badburst(iburst) = true;
            disp('Speed too fast, removing burst.')
        end
    end
    disp('=================================')

    %%% Increment main structure %%%
    onefields = fieldnames(oneSWIFT);
    nfields(iburst) = length(onefields);
    for ifield = 1:nfields(iburst)
        SWIFT(iburst).(onefields{ifield}) = oneSWIFT.(onefields{ifield});
    end
    
% End burst loop
end

%% Apply QC

SWIFT(badburst) = [];

%% Sort final structure

[~,tinds] = sort([SWIFT.time]);
SWIFT = SWIFT(tinds);

%% Look for outliers of position

if fixpositions
    [cleanlon,cloni] = filloutliers([SWIFT.lon],'linear');
    [cleanlat,clati] = filloutliers([SWIFT.lat],'linear');
    if cloni == clati
        for ci = find(cloni)
            SWIFT(ci).lon = cleanlon(ci);
            SWIFT(ci).lat = cleanlat(ci);
        end
        disp([num2str(sum(cloni)) ' positions filled that were outliers'])
    end
end

%% Recalculate drift (note that wind slip, which is 1%, is not removed)
% Drift speed is included from the Airmar results, 
% but that sensor is not always available or included
% (so simpler to just calculate it from differencing positions).

if length(SWIFT) > 3
    
    time = [SWIFT.time];%[time tinds ] = sort(time);
    lat = [SWIFT.lat]; %lat = lat(tinds);
    lon = [SWIFT.lon]; %lon = lon(tinds);
    dlondt = gradient(lon,time); % deg per day
    dxdt = deg2km(dlondt,6371*cosd(mean(lat,'omitnan'))) .* 1000 ./ ( 24*3600 ); % m/s
    dlatdt = gradient(lat,time); % deg per day
    dydt = deg2km(dlatdt) .* 1000 ./ ( 24*3600 ); % m/s
    dxdt(isinf(dxdt)) = NaN;
    dydt(isinf(dydt)) = NaN;
    speed = sqrt(dxdt.^2 + dydt.^2); % m/s
    direction = -180 ./ 3.14 .* atan2(dydt,dxdt); % cartesian direction [deg]
    direction = direction + 90;  % rotate from eastward = 0 to northward  = 0
    direction( direction<0) = direction( direction<0 ) + 360; % make quadrant II 270->360 instead of -90->0

    for si = 1:length(SWIFT)
        if si == 1 || si == length(SWIFT)
            SWIFT(si).driftspd = NaN;
            SWIFT(si).driftdirT = NaN;
        else
            SWIFT(si).driftspd = speed(si);
            SWIFT(si).driftdirT = direction(si);
        end
    end
    
    %     % remove last burst, if big change in direction (suggests recovery by ship)
    %     dirchange = abs( SWIFT( length(SWIFT) - 2).driftdirT  - SWIFT( length(SWIFT) - 1).driftdirT );
    %     if dirchange > 90,
    %         disp('removing last burst, suspect includes ship recovery')
    %         SWIFT( length(SWIFT) - 1).driftdirT = NaN;
    %         SWIFT( length(SWIFT) - 1).driftspd = NaN;
    %         SWIFT( length(SWIFT) ) = [];
    %         battery( length(SWIFT) ) = [];
    %     end
    
elseif length(SWIFT) <= 3
    for si = 1:length(SWIFT)
        SWIFT(si).driftspd = NaN;
        SWIFT(si).driftdirT = NaN;
    end
end

% Quality control by removing drift results associated with large time gaps
if length([SWIFT.time]) > 1
    dt = gradient([SWIFT.time]);
    for si = 1:length(SWIFT)
        if dt(si) > 1/12 % 1/12 of day is two hours
            SWIFT(si).driftspd = NaN;
            SWIFT(si).driftdirT = NaN;
        end
    end
end

% Quality control drift speeds too fast (prob on deck) with new drift spd
if length([SWIFT.time]) > 1 && isfield(SWIFT(1),'driftspd')
    toofast = [SWIFT.driftspd] > maxdriftspd;
    SWIFT( toofast ) =[];
end

%% Quality control wind speeds
if length([SWIFT.time]) > 1 && isfield(SWIFT(1),'windspd')
    for si = 1:length(SWIFT)
        if SWIFT(si).windspd > maxwindspd
            SWIFT(si).windspd = NaN;
            SWIFT(si).winddirT = NaN;
            SWIFT(si).winddirR = NaN;
        end
    end
end

%% Sort the microSWIFT onboard processing, using the battery voltage as a flag 
% only applies to v1 microSWIFTs from 2022

IMU = find([SWIFT.battery]==0);
GPS = find([SWIFT.battery]==1);

if ~isempty(IMU), SWIFT_IMU = SWIFT(IMU); end
if ~isempty(GPS), SWIFT_GPS = SWIFT(GPS); end

%% Fill in the ID field from mission directory name if NaN

idnan = isnan([SWIFT.ID]);
ID = sname(strfind(sname,'SWIFT')+ (5:6));

for si = find(idnan)
    SWIFT(si).ID = ID;
end

%% Save L1 file

if micro
    save([missiondir slash 'micro' sname '_L1.mat'],'SWIFT*')
elseif length([SWIFT.time]) > 1
    save([missiondir slash sname '_L1.mat'],'SWIFT')
end

%% Plot

if plotflag
    
    plotSWIFT(SWIFT)
    
    wd = pwd;
    wdi = find(wd == slash,1,'last');
    wd = wd((wdi+1):length(wd));
    
    % battery plot
    if any(~isnan([SWIFT.battery]))
        figure(7), clf,
        plot([SWIFT.time],[SWIFT.battery],'kx','linewidth',3)
        datetick, grid
        ylabel('Voltage')
        print('-dpng',[wd '_battery.png'])
    end
    
end

close all

% End mission loop
% end
