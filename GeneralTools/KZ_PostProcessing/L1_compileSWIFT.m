function [SWIFT,sinfo] = L1_compileSWIFT(missiondir,SBDfold,burstinterval,plotswift)

% Aggregate and read all SWIFT sbd data after concatenating the 
%   offload from SD card. SBD files should be in the 
%   subfolder specified by 'SBDfold' of any given SWIFT mission folder.
%   No QC is performed. The intention is to create a pure L1 product which
%   has all data recorded. Basic QC has been allocated to 'L2_pruneSWIFT.m'.

% Time: SWIFT - Take the time from the SBD filename, even when there is time from 
    %     the airmar (because of parsing errors). For telemetry, this 
    %     is the telemtry time (at the end of the burst). For offloaded data,
    %     this the concat file name (from the start of the burst).
    %   microSWIFT - Use the time embedded within the payload 50 or 51 or 52 of the
    %     SBD file, which is the time at the end of the burst of raw data.

% NOTE: L1 contains no QC, just pulls onboard data and creates initial
%       SWIFT structure.

% K. Zeiden 10/01/2024, based on compileSWIFT_SBDservertelemetry.m

if ispc
    slash = '\';
else
    slash = '/';
end

%% Mission name

islash = strfind(missiondir,slash);
if ~isempty(islash)
    sname = missiondir(islash(end)+1:end);
else
    sname = missiondir;
end

%% Create diary file

 diaryfile = [missiondir slash sname '_L1_compileSWIFT.txt'];
 if exist(diaryfile,'file')
     diary off
    delete(diaryfile);
 end
 diary(diaryfile)
 disp(['Compiling ' sname])

%% Compile list of sbd burst files %%%

if exist([missiondir slash SBDfold],'dir')
    sbdlist = dir([missiondir slash SBDfold slash '*.sbd']);
else
    disp('Processed files have not been concatenated...')
    sbdlist = [];
end
nburst = length(sbdlist);

% Initialize badburst flag
badburst = false(1,nburst);

% Initialize vectors
battery = NaN(1,nburst);
npayloads = NaN(1,nburst);

%% Loop through all SBD burst files, load data and save in SWIFT structure

for iburst = 1:nburst

    disp('=================================')
    disp(['Burst ' num2str(iburst) ' : ' sbdlist(iburst).name])
        
    % Read in SBD file data
    try
    [oneSWIFT,voltage]= readSWIFT_SBD([sbdlist(iburst).folder slash sbdlist(iburst).name],0);
    catch ME
        disp(['Burst SBD file could not be read in. Error Message: ' ME.message])
        oneSWIFT.lon = NaN;
        oneSWIFT.lat = NaN;
        voltage = NaN;
    end

    % Track SBD file in SWIFT structure
    oneSWIFT.sbdfile = sbdlist(iburst).name;
    
    % Voltage/Battery
    if voltage == 9999 % error flag from SBD message
        badburst(iburst) = true; 
    end
    if ~isempty(voltage)
        battery(iburst) = voltage;
        oneSWIFT.battery = voltage;
    else
        oneSWIFT.battery = NaN;
    end
    
    % Create NaN lon + lat if missing
    if isempty(oneSWIFT.lat) || isempty(oneSWIFT.lon)
        oneSWIFT.lat = NaN;
        oneSWIFT.lon = NaN;
    end
    
    %%% SWIFT type, burst ID, and time stamp %%%
    if sbdlist(iburst).name(6) == 'S' % SWIFT v3 and v4
        nameoffset = 14;
        day = sbdlist(iburst).name(nameoffset + (1:2));
        month = sbdlist(iburst).name(nameoffset + (3:5));
        year = sbdlist(iburst).name(nameoffset + (6:9));
        hr = sbdlist(iburst).name(nameoffset + (11:12));
        minute = sbdlist(iburst).name(nameoffset + (13:14));
        sec = sbdlist(iburst).name(nameoffset + (15:16));
        oneSWIFT.time = datenum([day ' ' month ' ' year ' ' hr ':' minute ':' sec]);
        micro = false;
        bnum = ['0' num2str(str2double(minute)/burstinterval + 1)];
        burstID = [day month year '_' hr '_' bnum];
        oneSWIFT.burstID = burstID;
    elseif sbdlist(iburst).name(6) == 'm' % microSWIFT
        micro = true;
    else
        oneSWIFT.time = NaN;
        micro = false;
    end
    
    %%% Remove wave histograms %%%
    if isfield(oneSWIFT,'wavehistogram')
        oneSWIFT = rmfield(oneSWIFT,'wavehistogram');
    end
    
    %%% Add burst to SWIFT structure %%%
    burstpayloads = string(fieldnames(oneSWIFT));
    npayloads(iburst) = length(burstpayloads);

    % Loop through paylaods on current burst, add to SWIFT structure
    for ipay = 1:npayloads(iburst)
        SWIFT(iburst).(burstpayloads{ipay}) = oneSWIFT.(burstpayloads{ipay});
    end

    % List initial payloads, as well as any missing or additional payloads
    if iburst == 1 % Initial payloads
        allpayloads = burstpayloads;
        disp('Initial payloads:')
        disp(allpayloads)
    elseif iburst ~= 1 && npayloads(iburst) > length(allpayloads) % Additional payloads
        isnew = false(npayloads(iburst),1);
        for ip = 1:npayloads(iburst)
            isnew(ip) = ~any(strcmp(burstpayloads(ip),allpayloads));
        end
        newpayloads = burstpayloads(isnew);
        disp(['New payloads in burst file ' num2str(iburst) ':'])
        disp(newpayloads)
        allpayloads = burstpayloads;
    elseif iburst ~= 1 && npayloads(iburst) < length(allpayloads)% Missing payloads
        ismissing = false(length(allpayloads),1);
        for ip = 1:length(allpayloads)
            ismissing(ip) = ~any(strcmp(allpayloads(ip),burstpayloads));
        end
        missingpayloads = allpayloads(ismissing);
        disp(['Missing payloads in burst file ' num2str(iburst) ':'])
        disp(missingpayloads)
    end

     disp(['Burst ID: ' burstID])
     disp('=================================')
    
% End burst loop
end

%% Fill empty SWIFT fields due to missing payloads in a burst

payloads = fieldnames(SWIFT);
npay = length(payloads);
nburst = length(SWIFT);

for ipay = 1:npay

    var = [SWIFT.(payloads{ipay})];
   
    % If some burst values are empty
    if length(var) ~= nburst

        % If variable is a scalar (e.g. 'watertemp') fill with NaN
        if isa(var,'double')
            for iburst = 1:nburst
                if isempty(SWIFT(iburst).(payloads{ipay}))
                    SWIFT(iburst).(payloads{ipay}) = NaN;
                end
            end
        elseif isa(var,'char')
            for iburst = 1:nburst
                if isempty(SWIFT(iburst).(payloads{ipay}))
                    SWIFT(iburst).(payloads{ipay}) = var(1);
                end
            end
        else % If variable is a structure array (e.g. 'wavespectra') fill w/NaN structure
            for iburst = 1:nburst
                if isempty(SWIFT(iburst).(payloads{ipay}))
                    SWIFT(iburst).(payloads{ipay}) = NaNstructR(var(1));
                end
            end
        end

    end

end

%% Sort final structure by time
[~,tinds] = sort([SWIFT.time]);
SWIFT = SWIFT(tinds);
battery = battery(tinds);

%% Calculate drift speed 
%   Drift speed is included from the Airmar results, but not always avail.
%   Compute drift speed by differencing position.
%   Note that wind slip, which is 1%, is not removed.
%   NaN out values associated with large time gaps.

if length(SWIFT) > 3
    
    time = [SWIFT.time];
    lat = [SWIFT.lat];
    lon = [SWIFT.lon];
    dt = diff(time);
    dlondt = diff(lon)./dt; % deg/days
    u = deg2km(dlondt,6371*cosd(mean(lat,'omitnan'))) .* 1000 ./ ( 24*3600 ); % m/s
    dlatdt = diff(lat)./dt; % deg/days
    v = deg2km(dlatdt) .* 1000 ./ ( 24*3600 ); % m/s
    u(isinf(u)) = NaN;
    v(isinf(v)) = NaN;
    speed = sqrt(u.^2 + v.^2); % m/s
    direction = -180 ./ 3.14 .* atan2d(v,u); % cartesian direction [deg]
    direction = direction + 90;  % rotate from eastward = 0 to northward  = 0
    direction( direction<0) = direction( direction<0 ) + 360; % make quadrant II 270->360 instead of -90 -> 0

    for si = 1:length(SWIFT)
        % Do not include drift speeds associated with large time gaps
        if si == 1 || dt(si-1) > 2*burstinterval/(60*24)
            SWIFT(si).driftspd = NaN;
            SWIFT(si).driftdirT = NaN;
        else
            SWIFT(si).driftspd = speed(si-1);
            SWIFT(si).driftdirT = direction(si-1);
        end
    end
    
else

    for si = 1:length(SWIFT)
        SWIFT(si).driftspd = NaN;
        SWIFT(si).driftdirT = NaN;
    end

end

%% Enforce a single value for CT and MET sensor heights

if isfield(SWIFT,'CTdepth')
    for si = 1:length(SWIFT)
        SWIFT(si).CTdepth = median([SWIFT.CTdepth],'omitnan');
    end
end

if isfield(SWIFT,'metheight')
    for si = 1:length(SWIFT)
        SWIFT(si).metheight = median([SWIFT.metheight],'omitnan');
    end
end

%% Sort the microSWIFT onboard processing, using the battery voltage as a flag 
% only applies to v1 microSWIFTs from 2022

IMU = find(battery==0);
GPS = find(battery==1);
if ~isempty(IMU)
    SWIFT_IMU = SWIFT(IMU);
end
if ~isempty(GPS)
    SWIFT_GPS = SWIFT(GPS);
end

%% Fill in the ID field from mission directory name if NaN

idnan = isnan([SWIFT.ID]);
ID = sname(strfind(sname,'SWIFT')+ (5:6));

for si = find(idnan)
    SWIFT(si).ID = ID;
end

%% Create sinfo structure

if ~micro
    disp('Create information structure ''sinfo''')
    sinfo.ID = SWIFT(1).ID;
    sinfo.CTdepth = SWIFT(1).CTdepth;
    if isfield(SWIFT,'metheight')
    sinfo.metheight = SWIFT(1).metheight;
    end
    if isfield(SWIFT,'signature')
        sinfo.type = 'V4';
    else 
        sinfo.type = 'V3';
    end
end

%% Save L1 file

if micro
    save([missiondir slash 'micro' sname '_L1.mat'],'SWIFT*')
else
    save([missiondir slash sname '_L1.mat'],'SWIFT','sinfo')
end

%% Re-load L2 SWIFT

L1file = dir([missiondir slash '*L1.mat']);
load([L1file.folder slash L1file.name],'SWIFT','sinfo')

%% Plot

if plotswift
    try
        if strcmp(sinfo.type,'V3')
        fh = plotSWIFTV3(SWIFT);
        else
            fh = plotSWIFTV4(SWIFT);
        end
        set(fh,'Name',L1file.name(1:end-4))
        print(fh,[L1file.folder slash L1file.name(1:end-4)],'-dpng')
   catch ME
        disp(['Plot failed: ' ME.message])
    end

    
end


%% Close diary 
diary off

end % End function
