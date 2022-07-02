% Batch Matlab read-in and reprocess of SWIFT PB2 (Airmar) data
%   reprocessing is to get positions when SBG or IMU fails
%   meant for use as part of SWIFTnewburst_processing
%
%   J. Thomson, Jul 2022

parentdir = pwd;  % change this to be the parent directory of all raw raw data (CF card offload from SWIFT)


%% load existing SWIFT structure created during concatSWIFTv3_processed, replace only the new wave results
cd(parentdir);
wd = pwd;
wdi = find(wd == '/',1,'last');
wd = wd((wdi+1):length(wd));

load([wd '_reprocessed.mat']) % this is being built in SWIFTnewburstprocessing

cd('COM-3/Raw/') % v4.0


%% loop thru raw data

dirlist = dir('20*');

for di = 1:length(dirlist),

    cd([dirlist(di).name])
    filelist = dir('*.dat');

    for fi=1:length(filelist),

        % read or load raw data
        if isempty(dir([filelist(fi).name(1:end-4) '.mat'])),
            [time rawwindspd rawwinddir rawairtemp rawairpres lat lon sog cog pitch roll] = readSWIFTv3_PB2(filelist(fi).name);
        else
            load([filelist(fi).name(1:end-4) '.mat']),
        end

        %% find matching time index in existing SWIFT structure
        % use median to get burst time, because first entries sometimes bad (no satellites acquired yet)
        [tdiff tindex] = min( abs( [SWIFT.time] - nanmedian(time) ) );
        if tdiff>1/48,
            disp('time gap too large at '),
            datestr(time)
            continue
        else
        end

        % include raw times and lat/lon in each burst of SWIFT structure
        SWIFT(tindex).rawtime = time;
        SWIFT(tindex).rawLat = lat;
        SWIFT(tindex).rawLon = lon;

        % difference the positions to get raw velocity components
        % note that these will also become the new drift spd and dir in SWIFTnewburst_processing.m
        x = deg2km(lon - median(lon), 6371*cosd(median(lat)) )  .* 1000; % [m]
        dxdt = gradient(x,time ); % meters per day
        u = dxdt ./ ( 24*3600 ); % m/s
        y = deg2km(lat - median(lat), 6371) .* 1000; % [m]
        dydt = gradient(y,time ); % meters per day
        v = dydt ./ ( 24*3600 ); % m/s

        % include raw positions and velocities
        SWIFT(tindex).x = x;
        SWIFT(tindex).y = y;
        SWIFT(tindex).z = zeros(size(x));
        SWIFT(tindex).u = u;
        SWIFT(tindex).v = v;


    end

    cd('../')

end

cd(parentdir)

%% Quality control
bad = false(size(SWIFT));

for si=1:length(SWIFT)

    if isfield(SWIFT(si),'u') && isempty(SWIFT(si).u)
        bad(si) = true;
    elseif all(isnan(time))
        bad(si) = true;
    end
end

SWIFT(bad) = [];

%% save a big file with raw positions

save([ wd '_reprocessed.mat'],'SWIFT')

