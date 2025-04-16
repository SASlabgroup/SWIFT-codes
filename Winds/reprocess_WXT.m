function [SWIFT,sinfo] = reprocess_WXT(missiondir,readraw,usewind)

% reprocess SWIFT Vaisala WXT files
% loop thru raw data for a given SWIFT deployment, then
% replace values in the SWIFT data structure of results
% (assuming concatSWIFTv3_processed.m has already been run.

% J. Thomson, 4/2020 (derived from reprocess_AQD.m)
% K. Zeiden 07/2024 reformatted for symmetry with bulk post processing
%    postprocess_SWIFT.m

if ispc 
    slash = '\';
else
    slash = '/';
end

%% Load existing L3 product, or L2 product if does not exist. If no L3 product, return to function

l2file = dir([missiondir slash '*SWIFT*L2.mat']);
l3file = dir([missiondir slash '*SWIFT*L3.mat']);

if ~isempty(l3file) % First check to see if there is an existing L3 file to load
    sfile = l3file;
    disp(['Loading L3 product for ' missiondir(end-16:end) '...'])
    load([sfile.folder slash sfile.name],'SWIFT','sinfo');
elseif isempty(l3file) && ~isempty(l2file)% If not, load L2 file
    sfile = l2file;
    disp(['Loading L2 product for ' missiondir(end-16:end) '...'])
    load([sfile.folder slash sfile.name],'SWIFT','sinfo');
else %  Exit reprocessing if no L2 or L3 product exists
    warning(['No L2 or L3 product found for ' missiondir(end-16:end) '. Skipping...'])
    return
end

%% Loop through raw burst files and reprocess
SWIFTreplaced = false(length(SWIFT),1);

bfiles = dir([missiondir slash 'WXT' slash 'Raw' slash '*' slash '*536*.dat']);
nburst = length(bfiles);
disp(['Found ' num2str(nburst) ' burst files...'])
btime = NaN(nburst,1);

for iburst = 1:nburst

   disp(['Burst ' num2str(iburst) ' : ' bfiles(iburst).name(1:end-4)])

       btime(iburst) = datenum(bfiles(iburst).name(13:21)) + str2double(bfiles(iburst).name(23:24))./24 ...
        + str2double(bfiles(iburst).name(26:27))./(24*6);
        
        % Skip if file size is 0 (empty)
        if bfiles(iburst).bytes == 0
            disp('File is empty. Skippping ...')
            continue
        end
            
        % Read mat file or load raw data
        if isempty(dir([bfiles(iburst).folder slash bfiles(iburst).name(1:end-4) '.mat'])) || readraw
            [winddirR,windspd,airtemp,relhumidity,airpres,rainaccum,rainint] = ...
                readSWIFT_WXT([bfiles(iburst).folder slash bfiles(iburst).name]);
        else
            load([bfiles(iburst).folder slash bfiles(iburst).name(1:end-4) '.mat']), %#ok<LOAD>
        end

        % Skip replacement if all NaN
        if ~any(~isnan(winddirR)) && ~any(~isnan(windspd)) && ~any(~isnan(airtemp)) ...
                && ~any(~isnan(relhumidity)) && ~any(~isnan(airpres)) && ~any(~isnan(rainaccum))...
                && ~any(~isnan(rainint))
            disp('All NaN. Skipping...')
            continue
        end
        
        % Find burst index in the existing SWIFT structure
        burstID = bfiles(iburst).name(13:end-4);
        sindex = find(strcmp(burstID,{SWIFT.burstID}'));
        if isempty(sindex)
            disp('No matching SWIFT index. Skipping...')
            continue
        end

        % Check for zero-d data
        if mean(airtemp,'omitnan') == 0 && mean(windspd,'omitnan') == 0
            disp('Bad data (all zero). Skipping...')
            continue
        end

        % Check for bad winds
        if mean(windspd,'omitnan') > 50 && std(windspd,[],'omitnan') < 1
            warning('Bad wind.')
            windspd = NaN;
            winddirR = NaN;
        end

        % Replace temp, humid, press and rain values and wind if specified
        SWIFT(sindex).airtemp = mean(airtemp,'omitnan'); % deg C
        SWIFT(sindex).airtempstddev = std(airtemp,[],'omitnan'); % deg C
        SWIFT(sindex).relhumidity = mean(relhumidity,'omitnan'); % percent
        SWIFT(sindex).relhumiditystddev = std(relhumidity,[],'omitnan'); % percent
        SWIFT(sindex).airpres = mean(airpres,'omitnan'); % millibars
        SWIFT(sindex).airpresstddev = std(airpres,[],'omitnan'); % millibars
        SWIFT(sindex).rainaccum = mean(rainaccum,'omitnan'); % millimeters
        SWIFT(sindex).rainint = mean(rainint,'omitnan'); % millimeters_per_hour

        if usewind
            SWIFT(sindex).winddirR = mean(winddirR,'omitnan');% mean wind direction (deg relative)
            SWIFT(sindex).windspd = mean(windspd,'omitnan'); % mean wind speed (m/s)
            SWIFT(sindex).winddirRstddev =  std(winddirR,[],'omitnan'); % std dev of wind direction (deg)
            SWIFT(sindex).windspdstddev = std(windspd,[],'omitnan');  % std dev of wind spd (m/s)
        end

        disp(['SWIFT index ' num2str(sindex) ' replaced.'])
        SWIFTreplaced(sindex) = true;

end

%% If SWIFT structure elements not replaced, fill variables with NaNs

if any(~SWIFTreplaced)

    if usewind
        [SWIFT(~SWIFTreplaced).winddirR] = deal(NaN);
        [SWIFT(~SWIFTreplaced).winddirRstddev] =  deal(NaN);
        [SWIFT(~SWIFTreplaced).windspd] = deal(NaN);
        [SWIFT(~SWIFTreplaced).windspdstddev] = deal(NaN);
    end

    [SWIFT(~SWIFTreplaced).airtemp] = deal(NaN);
    [SWIFT(~SWIFTreplaced).airtempstddev] = deal(NaN);
    [SWIFT(~SWIFTreplaced).airpres] = deal(NaN);
    [SWIFT(~SWIFTreplaced).airpresstddev] = deal(NaN);
    [SWIFT(~SWIFTreplaced).relhumidity] = deal(NaN);
    [SWIFT(~SWIFTreplaced).relhumiditystddev] = deal(NaN);
    [SWIFT(~SWIFTreplaced).rainaccum] = deal(NaN);
    [SWIFT(~SWIFTreplaced).rainint] = deal(NaN);

end

%% Log reprocessing and flags, then save new L3 file or overwrite existing one

if isfield(sinfo,'postproc')
ip = length(sinfo.postproc)+1; 
else
    sinfo.postproc = struct;
    ip = 1;
end
sinfo.postproc(ip).type = 'WXT';
sinfo.postproc(ip).usr = getenv('username');
sinfo.postproc(ip).time = string(datetime('now'));
sinfo.postproc(ip).flags = [];
sinfo.postproc(ip).params = [];

save([sfile.folder slash sfile.name(1:end-6) 'L3.mat'],'SWIFT','sinfo')

%% End function
end