function [SWIFT,sinfo] = reprocess_ACS(missiondir,readraw,plotburst)

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

outofwater = false(1,length(SWIFT));
SWIFTreplaced = false(1,length(SWIFT));

bfiles = dir([missiondir slash '*' slash 'Raw' slash '*' slash '*ACS*.dat']);

for iburst = 1:length(bfiles)

     disp(['Burst ' num2str(iburst) ' : ' bfiles(iburst).name(1:end-4)])

    % Read mat file or load raw data
    if isempty(dir([bfiles(iburst).folder slash bfiles(iburst).name(1:end-4) '.mat'])) || readraw
        try
        [~, Temperature, Salinity, ~, ~]  = readSWIFTv3_ACS([bfiles(iburst).folder slash bfiles(iburst).name]);
        catch ME
            disp(['Cannot read ' bfiles(iburst).name '. Error: ' ME.message '. Skipping...'])
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

    % Out of water
    iout = Salinity < 1;
    if sum(iout)/length(Salinity)>0.1
        outofwater(sindex) = true;
    end
    cleanSalinity = Salinity;
    cleanTemperature = Temperature;
    cleanSalinity(iout) = NaN;
    cleanTemperature(iout) = NaN;

    % Salinity spikes/dropouts
    ispikesal = isoutlier(cleanSalinity,'movmedian',30);
    if sum(~ispikesal) > 3
    cleanSalinity = interp1(find(~ispikesal),cleanSalinity(~ispikesal),1:length(cleanSalinity));
    end

     % Temperature spikes
    ispiketemp = isoutlier(cleanTemperature,'movmedian',30);
    if sum(~ispiketemp) > 3
    cleanTemperature = interp1(find(~ispiketemp),cleanTemperature(~ispiketemp),1:length(cleanTemperature));
    end

    % Mean values
    meanwatertemp = mean(Temperature,'omitnan');
    meanwatertempclean = mean(cleanTemperature,'omitnan');
    watertempstddev = std(cleanTemperature,[],'omitnan');
    meansalinity = mean(Salinity,'omitnan');
    meansalinityclean = mean(cleanSalinity,'omitnan');
    salinitystddev = std(cleanSalinity,[],'omitnan');

    % Unrealistic Values
    % if meanwatertempclean > 40
    %     meanwatertempclean = NaN;
    %     watertempstddev = NaN;
    %     meansalinityclean = NaN;
    %     salinitystddev = NaN;
    % end

    % Replace Values in SWIFT structure
    SWIFT(sindex).watertemp = meanwatertempclean;
    SWIFT(sindex).watertempstddev = watertempstddev;
    SWIFT(sindex).salinitystddev = salinitystddev;
    SWIFT(sindex).salinity = meansalinityclean;
    SWIFTreplaced(sindex) = true;

    % Plotdata
    if plotburst
        figure('color','w')
        %fullscreen
        subplot(2,1,1)
        plot(Temperature,'-kx')
        hold on
        plot(cleanTemperature,'-bx')
        axis tight
        plot(xlim,[1 1]*meanwatertemp,'-k','LineWidth',2)
        plot(xlim,[1 1]*meanwatertempclean,'-b','LineWidth',2)
        scatter(find(ispiketemp),Temperature(ispiketemp),'k','filled')
        title('Temperature');
        subplot(2,1,2)
        plot(Salinity,'-kx')
        hold on
        plot(cleanSalinity,'-rx')
        axis tight
        plot(xlim,[1 1]*meansalinity,'-k','LineWidth',2)
        plot(xlim,[1 1]*meansalinityclean,'-r','LineWidth',2)
        scatter(find(ispikesal),Salinity(ispikesal),'k','filled')
        title('Salinity');
        print([bfiles(iburst).folder '\' bfiles(iburst).name(1:end-4)],'-dpng')
        close gcf
    end

end

%% NaN out bursts that weren't reprocessed 

if any(~SWIFTreplaced)
    for sindex = find(~SWIFTreplaced)

    SWIFT(sindex).watertemp = NaN;
    SWIFT(sindex).watertempstddev = NaN;
    SWIFT(sindex).salinitystddev = NaN;
    SWIFT(sindex).salinity = NaN;

    end
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
sinfo.postproc(ip).flags.outofwater = outofwater;
sinfo.postproc(ip).params = [];

save([sfile.folder slash sfile.name(1:end-6) 'L3.mat'],'SWIFT','sinfo')

%% End function
end