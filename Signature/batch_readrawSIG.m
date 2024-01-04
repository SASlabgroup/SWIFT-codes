% Bulk conversion of raw Signature 1000 files to mat files
% Counts on folder structure with following format:
%       expdir\mission\SIG\Raw\YYYYMMDD\rawfile.dat

% Experiment to process
expdir = 'S:\ATOMIC\SWIFT\';

% Plotting toggles
plotburst = false;% generates plot of each burst and saves as a png file
zoom = true;% zooms into center 20% of the pings for visual clarity

%% Generate list of missions
if ispc
    slash = '\';
else
    slash = '/';
end
if ~strcmp(expdir(end),slash)
    expdir = [expdir slash];
end
missions = dir([expdir 'SWIFT*']);
missions = missions([missions.isdir]);

%% Run through each mission, reading in raw SIG data (unless mat file already exists)
% Plot burst data if plotburst = true;

for im = 1:length(missions)
    
    if isfolder([expdir missions(im).name '\SIG'])
    
        bfiles = dir([expdir missions(im).name slash 'SIG' slash 'Raw' slash '*' slash '*.dat']);
    
        for iburst = 1:length(bfiles)
    
            % File and Folder names
            bname = bfiles(iburst).name(1:end-4);
            bfold = bfiles(iburst).folder;
            disp(['Burst ' num2str(iburst) ' : ' bname])
    
            % Read + save burst file (skip if mat file already exists)
            if exist([bfold slash bname '.mat'],'file')
                disp('*** mat file already exists ***')
                continue
            else
            [time] = readSWIFTv4_SIG([bfold slash bname '.dat']);
                if isempty(time)
                    disp('*** no data ***')
                end
            end
            
            % Plot burst + save if plotburst = true
            if plotburst
                burst = load([bfold slash bname '.mat']);
                fh = plotSIGburst(burst);
                figure(fh(1))
                figname = [bfold slash bname];
                if zoom
                   limx = xlim;
                   xlim(max(xlim).*[0.4 0.6])
                end
                print(figname,'-dpng')
                close(fh)
            end
    
        end
        
    else
        disp(['No SIG data found for ' missions(im).name])
        continue
    end
    
end