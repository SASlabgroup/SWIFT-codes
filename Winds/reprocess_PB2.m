function [SWIFT,sinfo] = reprocess_PB2(missiondir,readraw)

% Reprocess Airmar Weather Station model 200WX files
% loop thru raw data for a given SWIFT deployment, then
% replace values in the SWIFT data structure of results
% (assuming concatSWIFTv3_processed.m has already been run.

% K. Zeiden 03/2025 based on reprocess_WXT

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
    load([sfile.folder slash sfile.name],'SWIFT','sinfo');
elseif isempty(l3file) && ~isempty(l2file)% If not, load L1 file
    sfile = l2file;
    load([sfile.folder slash sfile.name],'SWIFT','sinfo');
else %  Exit reprocessing if no L2 or L3 product exists
    warning(['No L2 or L3 product found for ' missiondir(end-16:end) '. Skipping...'])
    return
end

%% Loop through raw burst files and reprocess
SWIFTreplaced = false(length(SWIFT),1);

bfiles = dir([missiondir slash '*' slash 'Raw' slash '*' slash '*PB2*.dat']);
disp(['Found ' num2str(length(bfiles)) ' burst files...'])

for iburst = 1:length(bfiles)

   disp(['Burst ' num2str(iburst) ' : ' bfiles(iburst).name(1:end-4)])
        
        if bfiles(iburst).bytes   == 0
            disp('Burst file is empty. Skippping ...')
            continue
        end
            
        % Read mat file or load raw data
        if isempty(dir([bfiles(iburst).folder slash bfiles(iburst).name(1:end-4) '.mat'])) || readraw
            [~,windspd,winddirT,airtemp,airpres,~,~,~,~,~,~] = ...
                readSWIFTv3_PB2([bfiles(iburst).folder slash bfiles(iburst).name]);
        else
            load([bfiles(iburst).folder slash bfiles(iburst).name(1:end-4) '.mat']), %#ok<LOAD>
            windspd = rawwindspd;
            winddirT = rawwinddir;
            airtemp = rawairtemp;
            airpres = rawairpres;
        end

        if ~any(~isnan(windspd))
            disp('No data read. Skipping...')
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
            winddirT = NaN;
        end

        % Check airpressure units (if O(10), is in inches of mercury)
        if mean(airpres,'omitnan') < 500
            airpres = airpres.*33.8639;% Convert to mb
        end

        % Find burst index in the existing SWIFT structure
        burstID = bfiles(iburst).name(13:end-4);
        sindex = find(strcmp(burstID,{SWIFT.burstID}'));
        if isempty(sindex)
            disp('No matching SWIFT index. Skipping...')
            continue
        end
        
        SWIFT(sindex).winddirT = nanmean(winddirT); %#ok<*NANMEAN> % mean wind direction (deg relative)
        SWIFT(sindex).windspd = nanmean(windspd); % mean wind speed (m/s)
        SWIFT(sindex).winddirTstddev =  nanstd(winddirT); % std dev of wind direction (deg)
        SWIFT(sindex).windspdstddev = nanstd(windspd);  % std dev of wind spd (m/s)
        SWIFT(sindex).airtemp = nanmean(airtemp); % deg C
        SWIFT(sindex).airtempstddev = nanstd(airtemp); % deg C
        SWIFT(sindex).airpres = nanmean(airpres); % millibars
        SWIFT(sindex).airpresstddev = nanstd(airpres); % millibars

        SWIFTreplaced(sindex) = true;

end


%% If SWIFT structure elements not replaced, fill variables with NaNs

if any(~SWIFTreplaced)

    [SWIFT(~SWIFTreplaced).winddirT] = deal(NaN);
    [SWIFT(~SWIFTreplaced).winddirTstddev] =  deal(NaN);
    [SWIFT(~SWIFTreplaced).windspd] = deal(NaN);
    [SWIFT(~SWIFTreplaced).windspdstddev] = deal(NaN);
    [SWIFT(~SWIFTreplaced).airtemp] = deal(NaN);
    [SWIFT(~SWIFTreplaced).airtempstddev] = deal(NaN);
    [SWIFT(~SWIFTreplaced).airpres] = deal(NaN);
    [SWIFT(~SWIFTreplaced).airpresstddev] = deal(NaN);

end

%% Log reprocessing and flags, then save new L3 file or overwrite existing one

if isfield(sinfo,'postproc')
ip = length(sinfo.postproc)+1; 
else
    sinfo.postproc = struct;
    ip = 1;
end
sinfo.postproc(ip).type = 'PB2';
sinfo.postproc(ip).usr = getenv('username');
sinfo.postproc(ip).time = string(datetime('now'));
sinfo.postproc(ip).flags = [];
sinfo.postproc(ip).params = [];

save([sfile.folder slash sfile.name(1:end-6) 'L3.mat'],'SWIFT','sinfo')

%% End function
end