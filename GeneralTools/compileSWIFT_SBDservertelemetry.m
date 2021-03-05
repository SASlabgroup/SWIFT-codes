% Aggregate and read all SWIFT sbd telemetry data, once downloaded from
% the swiftserver via http://faculty.washington.edu/jmt3rd/SWIFTdata/DynamicDataLinks.html
% (or run after concatenating the offload from SD card or the sbd email attachments
%
% run this script in the directory with all the SWIFT sbd files
%
% J. Thomson, 7/2014
%             12/2014 revised for v3.2 (and backwards compatible for v3.1)
%             1/2015    v3.3
%             6/2016    v3.4
%             1/2017    v4.0 (and backwards compatibile with v3x)
%             9/2017 fixed factor of 2 in post-calculation of ustar
%             9/2018 no longer assume any fields are present in the
%                   structure, other than time (consistent with
%                   readSWIFT_SBD.m update)
%             9/2018 improve screening for bad bursts
%             4/2019 disable screening for dir changes (proxy for ship recovery)
%                   and give messages for burst screening
%             9/2019   force timestamp from SBD filename always, rather than Airmar
clear all,

plotflag = 1;  % binary flag for plotting (compiled plots, not individual plots... that flag is in the readSWIFT_SBD call)

minwaveheight = 0.1; % minimum wave height in data screening

minsalinity = 25; % PSU, for use in screen points when buoy is out of the water (unless testing on Lake WA)

maxdriftspd = 3;  % m/s, for screening when buoy on deck of boat

maxwindspd = 30; % m/s for malfunctioning Airmars

minairtemp = -20; % min airtemp

wd = pwd;
wdi = find(wd == '/',1,'last');
wd = wd((wdi+1):length(wd));

flist = dir('*.sbd');
%flist = dir('*.dat');


for ai = 1:length(flist),
    
    badburst(ai) = false;  % intialize bad burst flag
    
    [ oneSWIFT voltage ]= readSWIFT_SBD( flist(ai).name , 0);
    
    if isempty(voltage),
        battery(ai) = NaN;
    else
        battery(ai) = voltage;
    end
    
    if isempty(oneSWIFT.lat) | isempty(oneSWIFT.lon),
        oneSWIFT.lat = NaN;
        oneSWIFT.lon = NaN;
    end
    
    %% time stamp: take the time from the filename, even when there is time from the airmar
    % for telemetry, this is the telemtry time (at the end of the burst).
    % for offloaded data, this the concat file name (from the start of the burst)
    
    if flist(ai).name(6)=='S', % SWIFT
        nameoffset = 14;
    elseif flist(ai).name(6)=='m', % microSWIFT
        nameoffset = 20;
    else
        nameoffset = 0;
    end
    
    day = flist(ai).name(nameoffset + [1:2]);
    month = flist(ai).name(nameoffset + [3:5]);
    year = flist(ai).name(nameoffset + [6:9]);
    hr = flist(ai).name(nameoffset + [11:12]);
    minute = flist(ai).name(nameoffset + [13:14]);
    sec = flist(ai).name(nameoffset + [15:16]);
    
    oneSWIFT.time = datenum([day ' ' month ' ' year ' ' hr ':' minute ':' sec]);
    
    
    %     if isempty(oneSWIFT.time),
    %         oneSWIFT.time = datenum([day ' ' month ' ' year ' ' hr ':' minute ':' sec]);
    %     elseif oneSWIFT.time == 0 |  isnan(oneSWIFT.time) | oneSWIFT.time < datenum(2014,1,1),
    %         oneSWIFT.time = datenum([day ' ' month ' ' year ' ' hr ':' minute ':' sec]);
    %     end
    
    
    %% remove bad Airmar data
    
    if isfield(oneSWIFT,'airtemp'),
        if oneSWIFT.airtemp == 0.0 | oneSWIFT.airtemp < minairtemp | oneSWIFT.airtemp > 50,
            oneSWIFT.airtemp = NaN;
            oneSWIFT.windspd = NaN;
        end
    end
    
    
    %% extrapolate missing low frequencies of wave energy spectra
    % while requiring energy at lowest frequenc to be zero
    % not neccessary if post-processing for raw displacements
    % less necessary after Oct 2017 rev of onboard processing with improved RC filter
    if isfield(oneSWIFT,'wavespectra')
        notzero = find(oneSWIFT.wavespectra.energy ~= 0 & oneSWIFT.wavespectra.freq > 0.04);
        tobereplaced =  find(oneSWIFT.wavespectra.energy == 0 & oneSWIFT.wavespectra.freq > 0.04);
        if length(notzero) > 10,
            E = interp1([0.04; oneSWIFT.wavespectra.freq(notzero)],[0; oneSWIFT.wavespectra.energy(notzero)],oneSWIFT.wavespectra.freq);
            oneSWIFT.wavespectra.energy(tobereplaced) = E(tobereplaced);
            df = median(diff(oneSWIFT.wavespectra.freq));
            oneSWIFT.sigwaveheight = 4*sqrt(nansum(oneSWIFT.wavespectra.energy)*df);
        else
        end
    end
    
    %% remove wave histograms, if present
    
    %     if isfield(oneSWIFT,'wavehistogram'),
    %         oneSWIFT = rmfield(oneSWIFT,'wavehistogram');
    %     else
    %     end
    
    %% increment main structure
    
    time(ai) = oneSWIFT.time;
    lat(ai) = oneSWIFT.lat;
    lon(ai) = oneSWIFT.lon;
    
    onenames = string(fieldnames(oneSWIFT));
    lengthofnames(ai) = length(onenames);
    
    % if first sbd, set the structure fields as the standard
    if ai == 1,
        SWIFT(ai) = oneSWIFT;
        allnames = string(fieldnames(SWIFT));
        
        % if payloads match, increment
    elseif ai > 1 && all(size(onenames) == size(allnames)) && all(onenames == allnames),
        SWIFT(ai) = oneSWIFT;
        
        % if additional payloads, favor that new structure (removing other)
    elseif ai > 1 && length(onenames) > length(allnames),
        clear SWIFT
        SWIFT(ai-1) = oneSWIFT; % place holder, which will be removed when badburst applied
        badburst(ai-1) = true;
        SWIFT(ai) = oneSWIFT;
        allnames = string(fieldnames(oneSWIFT)); % reset the prefer field names
        disp('=================================')
        disp(['found extra payloads in file ' num2str(ai) ', including only sbd files with'])
        disp(allnames)
        
        % if fewer paylaods, skip that burst
    elseif ai > 1 && length(onenames) < length(allnames),
        disp('=================================')
        disp(['found fewer payloads in file ' num2str(ai) ', cannot include this file in SWIFT structure'])
        SWIFT(ai) = SWIFT(1); % placeholder, which will be removed when badburst applied
        badburst(ai) = true;
    end
    
    badburst( find(lengthofnames < length(allnames) ) ) = true;
    
    %% screen the bad data (usually out of the water)
    
    % no data
    if isempty(oneSWIFT.lon) | isempty(oneSWIFT.lat) | isempty(oneSWIFT.time),
        badburst(ai) = true;
        disp('=================================')
        disp('no position or timestamp!')
    end
    % no position
    if oneSWIFT.lon == 0 | ~isnumeric(oneSWIFT.lon),
        badburst(ai) = true;
        disp('=================================')
        disp('no position!')
    end
    % wave limit
    if isfield(oneSWIFT,'sigwaveheight'),
        if oneSWIFT.sigwaveheight < minwaveheight,
            badburst(ai) = true;
            disp('=================================')
            disp('waves too small, removing burst')
        end
    end
    % salinity limit
    if isfield(oneSWIFT,'salinity'),
        if all(oneSWIFT.salinity < minsalinity), % & all(~isnan(oneSWIFT.salinity)),
            badburst(ai) = true;
            disp('=================================')
            disp('salinity too low, removing burst')
        end
    end
    
    % drift speed limit
    if isfield(oneSWIFT,'driftspd')
        if oneSWIFT.driftspd > maxdriftspd,
            badburst(ai) = true;
        end
    end
    
    
    
    %% close telemetry file loop
end


%% apply quality control

SWIFT(badburst) = [];
battery(badburst) = [];


%% sort final structure
[time tinds ] = sort([SWIFT.time]);
SWIFT = SWIFT(tinds);
battery = battery(tinds);


%% calc drift (note that wind slip, which is 5%, is not removed)
% drift speed is included from the Airmar results, but that sensor is not
% always available or included
% (so simpler to just calculate it from differencing positions)

if length(SWIFT) > 3,
    
    time = [SWIFT.time];%[time tinds ] = sort(time);
    lat = [SWIFT.lat]; %lat = lat(tinds);
    lon = [SWIFT.lon]; %lon = lon(tinds);
    dlondt = gradient(lon,time); % deg per day
    dxdt = deg2km(dlondt,6371*cosd(mean(lat))) .* 1000 ./ ( 24*3600 ); % m/s
    dlatdt = gradient(lat,time); % deg per day
    dydt = deg2km(dlatdt) .* 1000 ./ ( 24*3600 ); % m/s
    dxdt(isinf(dxdt)) = NaN;
    dydt(isinf(dydt)) = NaN;
    speed = sqrt(dxdt.^2 + dydt.^2); % m/s
    direction = -180 ./ 3.14 .* atan2(dydt,dxdt); % cartesian direction [deg]
    direction = direction + 90;  % rotate from eastward = 0 to northward  = 0
    direction( direction<0) = direction( direction<0 ) + 360; %make quadrant II 270->360 instead of -90->0
    
    for si = 1:length(SWIFT),
        if si == 1 | si == length(SWIFT),
            SWIFT(si).driftspd = NaN;
            SWIFT(si).driftdirT = NaN;
        else
            SWIFT(si).driftspd = speed(si);%speed(tinds(ai));
            SWIFT(si).driftdirT = direction(si);%dir(tinds(ai));
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
    
else
    for si = 1:length(SWIFT),
        SWIFT(si).driftspd = NaN;
        SWIFT(si).driftdirT = NaN;
    end
end

% quality control by removing drift results associated with large time gaps
if length([SWIFT.time]) > 1,
    dt = gradient([SWIFT.time]);
    for si = 1:length(SWIFT),
        if dt(si) > 1/12, % 1/12 of day is two hours
            SWIFT(si).driftspd = NaN;
            SWIFT(si).driftdirT = NaN;
        else
        end
    end
else
end

% quality control with wind speed limit
if length([SWIFT.time]) > 1,
    if isfield(SWIFT(1),'windspd')
        for si = 1:length(SWIFT),
            if SWIFT(si).windspd > maxwindspd, % 1/12 of day is two hours
                SWIFT(si).windspd = NaN;
                SWIFT(si).winddirT = NaN;
                SWIFT(si).winddirR = NaN;
            end
        end
    end
end

%% save
%save([ flist(ai).name(6:13) '.mat'], 'SWIFT')
save([ wd '.mat'], 'SWIFT')

%% ploting

if plotflag == 1,
    
    plotSWIFT(SWIFT)
    
    wd = pwd;
    wdi = find(wd == '/',1,'last');
    wd = wd((wdi+1):length(wd));
    
    % battery plot
    if any(~isnan(battery)),
        figure(7), clf,
        plot([SWIFT.time],battery,'kx','linewidth',3)
        datetick, grid
        ylabel('Voltage')
        print('-dpng',[wd '_battery.png'])
    else
    end
    
else
end % close plot statement
