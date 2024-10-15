function [SWIFT,sinfo] = fixtimes_V4SWIFT(missiondir,plotflag,daterange)

% Fix wonky times from V4 SWIFTs using Signature1000 burst times
% L1_compileSWIFT uses sbd burst file names to get time, so bad file
% names can create bad times in SWIFT structure
% 1. Load signature files to get internal burst time and generate time offset.
% 2. Recalculate drift speeds

% K.Zeiden Oct 2024

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

%% Load L1 file and determine whether times are bad
    
L1file = dir([missiondir slash '*L1.mat']);
load([L1file.folder slash L1file.name],'SWIFT','sinfo')

disp([sname ' time range:'])
timerange([SWIFT.time]);

if ~any([SWIFT.time] < daterange(1) | [SWIFT.time] > daterange(2))
    disp('Times are fine, skippping ...')
    return
    else
     disp('Fixing burst times using Sig1000 burst files...')
end

%% Get correct times from Signature1000 burst data

sigfiles = dir([missiondir slash 'SIG' slash 'Raw' slash '*' slash '*SIG*.mat']);

if isempty(sigfiles)
    disp('No Signature1000 files, cannot correct burst times...')
    return
end

sigfiletimes = NaN(1,length(sigfiles));
sigbursttimes = NaN(1,length(sigfiles));

progressbar(['Loading ' sname ' sig burst files...'])
for isig = 1:length(sigfiles)
    load([sigfiles(isig).folder slash sigfiles(isig).name],'burst')
    sigbursttimes(isig) = min(burst.time);
    date = sigfiles(isig).name(13:21);
    hour = sigfiles(isig).name(23:24);
    mint = sigfiles(isig).name(26:27);
    sigfiletimes(isig) = datenum(date)+datenum(0,0,0,str2double(hour),(str2double(mint)-1)*12,0);
    progressbar(isig/length(sigfiles))
end

toff = sigbursttimes-sigfiletimes;

%% Use offsets to correct SWIFT times

for iburst = 1:length(SWIFT)
    if SWIFT(iburst).time < datenum([2024 01 01])
    [~,imatch] = min(abs(SWIFT(iburst).time - sigfiletimes));
    SWIFT(iburst).time = SWIFT(iburst).time + toff(imatch);
    end
end

disp('New time range:')
timerange([SWIFT.time]);

%% Sort new times
[~,isort] = sort([SWIFT.time]);
SWIFT = SWIFT(isort);

%%  Compute new drift speeds

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

    % Remove drifts associated with large time gaps
    dt = gradient([SWIFT.time]);

    for si = 1:length(SWIFT)
        if si == 1 || si == length(SWIFT) || dt(si) > 1/12
            SWIFT(si).driftspd = NaN;
            SWIFT(si).driftdirT = NaN;
        else
            SWIFT(si).driftspd = speed(si);
            SWIFT(si).driftdirT = direction(si);
        end
    end
end

%% Save updated L1 file

save([L1file.folder slash L1file.name],'SWIFT','sinfo');

%% Plot

if plotflag
fh = plotSWIFTV4(SWIFT);
set(fh,'Name',L1file.name(1:end-4))
print(fh,[L1file.folder slash L1file.name(1:end-4)],'-dpng')
end

end



