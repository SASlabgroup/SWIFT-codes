function [SWIFT,sinfo] = reprocess_ACS(missiondir,readraw)

% reprocess SWIFT v3 ACS results to get raw
% M. Smith 08/2016

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

bfiles = dir([missiondir slash '*' slash 'Raw' slash '*' slash '*ACS*.dat']);

for iburst = 1:length(bfiles)

     disp(['Burst ' num2str(iburst) ' : ' bfiles(iburst).name(1:end-4)])

    % Read mat file or load raw data
    if isempty(dir([bfiles(iburst).folder slash bfiles(iburst).name(1:end-4) '.mat'])) || readraw
        try
        [~, Temperature, Salinity, ~, ~]  = readSWIFTv3_ACS([bfiles(iburst).folder slash bfiles(iburst).name]);
        catch
            disp(['Cannot read ' bfiles(iburst).name '. Skipping...'])
        continue
        end
    else
         load([bfiles(iburst).folder slash bfiles(iburst).name(1:end-4) '.mat']), %#ok<LOAD>
    end

    % Find burst index in the existing SWIFT structure
    burstID = bfiles(iburst).name(13:end-4);
    sindex = find(strcmp(burstID,{SWIFT.burstID}'));
    if isempty(sindex)
        disp('No matching SWIFT index. Skipping...')
        continue
    end

    % Mean values
    watertemp = mean(Temperature,'omitnan');
    watertempstddev = std(Temperature,[],'omitnan');
    salinity = mean(Salinity,'omitnan');
    salinitystddev = std(Salinity,[],'omitnan');

    % Unrealistic Values
    if watertemp > 40
        watertemp = NaN;
        watertempstddev = NaN;
        salinity = NaN;
        salinitystddev = NaN;
    end

    % Replace Values in SWIFT structure
    SWIFT(sindex).watertemp = watertemp;
    SWIFT(sindex).watertempstddev = watertempstddev;
    SWIFT(sindex).salinitystddev = salinitystddev;
    SWIFT(sindex).salinity = salinity;

end
    
%% Log reprocessing and flags, then save new L3 file or overwrite existing one

if isfield(sinfo,'postproc')
ip = length(sinfo.postproc)+1; 
else
    sinfo.postproc = struct;
    ip = 1;
end
sinfo.postproc(ip).type = 'ACS';
sinfo.postproc(ip).usr = getenv('username');
sinfo.postproc(ip).time = string(datetime('now'));
sinfo.postproc(ip).flags = [];
sinfo.postproc(ip).params = [];

save([sfile.folder slash sfile.name(1:end-6) 'L3.mat'],'SWIFT','sinfo')

%% End function
end