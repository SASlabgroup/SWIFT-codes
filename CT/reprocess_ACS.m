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
    Salclean = Salinity;
    Tempclean = Temperature;
    Salclean(iout) = NaN;
    Tempclean(iout) = NaN;

    % Salinity spikes/dropouts
    ispikesal = isoutlier(Salclean,'movmedian',30);
    if sum(~ispikesal) > 3
    Salclean = interp1(find(~ispikesal),Salclean(~ispikesal),1:length(Salclean));
    end

     % Temperature spikes
    ispiketemp = isoutlier(Tempclean,'movmedian',30);
    if sum(~ispiketemp) > 3
    Tempclean = interp1(find(~ispiketemp),Tempclean(~ispiketemp),1:length(Tempclean));
    end

    % Mean values
    meantemp = mean(Temperature,'omitnan');
    meantempclean = mean(Tempclean,'omitnan');
    tempstddev = std(Temperature,[],'omitnan');
    tempcleanstddev = std(Tempclean,[],'omitnan');
    meansal = mean(Salinity,'omitnan');
    meansalclean = mean(Salclean,'omitnan');
    salstddev = std(Salinity,[],'omitnan');
    salcleanstddev = std(Salclean,[],'omitnan');

    % Unrealistic Values
    % if meanwatertempclean > 40
    %     meanwatertempclean = NaN;
    %     watertempstddev = NaN;
    %     meansalinityclean = NaN;
    %     salinitystddev = NaN;
    % end

    % Replace Values in SWIFT structure
    SWIFT(sindex).watertemp = meantempclean;
    SWIFT(sindex).watertempstddev = tempcleanstddev;
    SWIFT(sindex).salinity = meansalclean;
    SWIFT(sindex).salinitystddev = salcleanstddev;
    SWIFTreplaced(sindex) = true;

    % Plotdata
    if plotburst
        figure('color','w')
        %fullscreen
        subplot(2,1,1)
        plot(Temperature,'-kx')
        %fullscreen
        subplot(4,1,1)
        plot(Temperature,'-x','color',rgb('cornflowerblue'))
        hold on
        axis tight
        plot(xlim,[1 1]*meantemp,'-','color',rgb('cornflowerblue'))
        plot(xlim,[1 1]*meantemp - tempstddev,'--','color',rgb('cornflowerblue'))
        plot(xlim,[1 1]*meantemp + tempstddev,'--','color',rgb('cornflowerblue'))
        s = scatter(find(ispiketemp),Temperature(ispiketemp),'k','LineWidth',1.5);
        title('Raw Temperature');
        legend(s,'Spikes')

        subplot(4,1,2)
        plot(Tempclean,'-bx')
        hold on
        axis tight
        plot(xlim,[1 1]*meantempclean,'b')
        plot(xlim,[1 1]*meantempclean - tempcleanstddev,'--b')
        plot(xlim,[1 1]*meantempclean + tempcleanstddev,'--b')
        title('QC Temperature')

        subplot(4,1,3)
        plot(Salinity,'-x','color',rgb('coral'))
        hold on
        axis tight
         plot(xlim,[1 1]*meansal,'-','color',rgb('coral'))
        plot(xlim,[1 1]*meansal - salstddev,'--','color',rgb('coral'))
        plot(xlim,[1 1]*meansal + salstddev,'--','color',rgb('coral'))
        s = scatter(find(ispikesal),Salinity(ispikesal),'k','LineWidth',1.5);
        title('Raw Salinity');

        subplot(4,1,4)
        plot(Salclean,'-rx')
        hold on
        axis tight
        plot(xlim,[1 1]*meansalclean,'r')
        plot(xlim,[1 1]*meansalclean - salcleanstddev,'--r')
        plot(xlim,[1 1]*meansalclean + salcleanstddev,'--r')
        title('QC Salinity')

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