function [SWIFT,sinfo] = reprocess_ACO(missiondir,readraw,plotburst)
% reprocess SWIFT ACO (dissolved oxygen) from raw data
% K. Zeiden 08/2025

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

SWIFTreplaced = false(1,length(SWIFT));

bfiles = dir([missiondir slash '*' slash 'Raw' slash '*' slash '*ACO*.dat']);

for iburst = 1:length(bfiles)

     disp(['Burst ' num2str(iburst) ' : ' bfiles(iburst).name(1:end-4)])

    % Read mat file or load raw data
    if isempty(dir([bfiles(iburst).folder slash bfiles(iburst).name(1:end-4) '.mat'])) || readraw
        try
        O2  = readSWIFT_ACO([bfiles(iburst).folder slash bfiles(iburst).name]);
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

    % Replace Values in SWIFT structure
    SWIFT(sindex).O2conc = mean(O2.O2Concentration,'omitnan');
    SWIFT(sindex).O2concstddev = std(O2.O2Concentration,[],'omitnan');
    SWIFTreplaced(sindex) = true;

    % Plotdata
    if plotburst
        figure('color','w');
        subplot(3,1,1);plot(O2.O2Concentration,'LineWidth',2);
        ylabel('[uM]');
        title('O2 Concentration')
        subplot(3,1,2);
        plot(O2.AirSat,'LineWidth',2);
        ylabel('[%]');
        title('Air Saturation')
        subplot(3,1,3);
        plot(O2.Temp,'LineWidth',2);
        ylabel('[^{\circ}C]');
        title('Temperature')
        xlabel('N')
        h = findall(gcf,'Type','Axes');linkaxes(h,'x')
        axis tight
        set(h(2:end),'XTickLabel',[])
        print([bfiles(iburst).folder '\' bfiles(iburst).name(1:end-4)],'-dpng')
        close gcf
    end

end

%% NaN out bursts that weren't reprocessed 

if any(~SWIFTreplaced)
    for sindex = find(~SWIFTreplaced)

    SWIFT(sindex).O2conc = NaN;
    SWIFT(sindex).O2concstddev = NaN;

    end
end
    
%% Log reprocessing and flags, then save new L3 file or overwrite existing one

if isfield(sinfo,'postproc')
ip = length(sinfo.postproc)+1; 
else
    sinfo.postproc = struct;
    ip = 1;
end
sinfo.postproc(ip).type = 'ACO';
sinfo.postproc(ip).usr = getenv('username');
sinfo.postproc(ip).time = string(datetime('now'));
sinfo.postproc(ip).flags= [];
sinfo.postproc(ip).params = [];

save([sfile.folder slash sfile.name(1:end-6) 'L3.mat'],'SWIFT','sinfo')

%% End function
end