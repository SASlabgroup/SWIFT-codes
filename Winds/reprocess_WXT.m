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
    load([sfile.folder slash sfile.name],'SWIFT','sinfo');
elseif isempty(l3file) && ~isempty(l2file)% If not, load L1 file
    sfile = l2file;
    load([sfile.folder slash sfile.name],'SWIFT','sinfo');
else %  Exit reprocessing if no L2 or L3 product exists
    warning(['No L2 or L3 product found for ' missiondir(end-16:end) '. Skipping...'])
    return
end

%% Loop through raw burst files and reprocess
burstreplaced = false(length(SWIFT),1);

bfiles = dir([missiondir slash 'WXT' slash 'Raw' slash '*' slash '*536*.dat']);
disp(['Found ' num2str(length(bfiles)) ' burst files...'])

for iburst = 1:length(bfiles)

   disp(['Burst ' num2str(iburst) ' : ' bfiles(iburst).name(1:end-4)])
        
        if bfiles(iburst).bytes   == 0
            disp('Burst file is empty. Skippping ...')
        end
            
        % Read mat file or load raw data
        if isempty(dir([bfiles(iburst).folder slash bfiles(iburst).name(1:end-4) '.mat'])) || readraw
            [winddirR,windspd,airtemp,relhumidity,airpres,rainaccum,rainint] = ...
                readSWIFT_WXT([bfiles(iburst).folder slash bfiles(iburst).name]);
        else
            load([bfiles(iburst).folder slash bfiles(iburst).name(1:end-4) '.mat']), %#ok<LOAD>
        end
        
        % Find matching time
        time = datenum(bfiles(iburst).name(13:21)) + str2double(bfiles(iburst).name(23:24))./24 ...
            + str2double(bfiles(iburst).name(26:27))./(24*6);
        [tdiff,tindex] = min(abs([SWIFT.time]-time));

        if tdiff > 12/(60*24)
            disp('No time match. Skippping...')
            continue
        end
        
        if usewind
        SWIFT(tindex).winddirR = nanmean(winddirR); %#ok<*NANMEAN> % mean wind direction (deg relative)
        SWIFT(tindex).windspd = nanmean(windspd); % mean wind speed (m/s)
        SWIFT(tindex).winddirRstddev =  nanstd(winddirR); % std dev of wind direction (deg)
        SWIFT(tindex).windspdstddev = nanstd(windspd);  % std dev of wind spd (m/s)
        end
        SWIFT(tindex).airtemp = nanmean(airtemp); % deg C
        SWIFT(tindex).airtempstddev = nanstd(airtemp); % deg C
        SWIFT(tindex).relhumidity = nanmean(relhumidity); % percent
        SWIFT(tindex).relhumiditystddev = nanstd(relhumidity); % percent
        SWIFT(tindex).airpres = nanmean(airpres); % millibars
        SWIFT(tindex).airpresstddev = nanstd(airpres); % millibars
        SWIFT(tindex).rainaccum = nanmean(rainaccum); % millimeters
        SWIFT(tindex).rainint = nanmean(rainint); % millimeters_per_hour
        burstreplaced(tindex) = true;

end


%% If SWIFT structure elements not replaced, fill variables with NaNs

for i = 1:length(SWIFT)
    if ~isfield(SWIFT(i),'relhumidity') || isempty(SWIFT(i).relhumidity)
        disp(['No data at index ' num2str(i)])
        % SWIFT(i).winddirR = NaN;
        SWIFT(i).winddirRstddev =  NaN;
        % SWIFT(i).windspd = NaN;
        SWIFT(i).windspdstddev = NaN;
        SWIFT(i).airtemp = NaN;
        SWIFT(i).airtempstddev = NaN;
        SWIFT(i).relhumidity = NaN;
        SWIFT(i).relhumiditystddev = NaN;
        SWIFT(i).airpres = NaN;
        SWIFT(i).airpresstddev = NaN;
        SWIFT(i).rainaccum = NaN;
        SWIFT(i).rainint = NaN;
    end
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