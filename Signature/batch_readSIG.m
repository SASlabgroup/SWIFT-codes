% Bulk conversion of raw Signature 1000 files to mat files
% Counts on folder structure with following format:
%       expdir\mission\SIG\Raw\YYYYMMDD\rawfile.dat

% Experiment to process
expdir = 'S:\NORSE\2023\';
missions = dir([expdir 'SWIFT2*']);

%% Run through each mission
if ispc
    slash = '\';
else
    slash = '/';
end
if ~strcmp(expdir(end),slash)
    expdir = [expdir slash];
end

for im = 2:length(missions)
    
    bfiles = dir([expdir missions(im).name slash 'SIG' slash 'Raw' slash '*' slash '*.dat']);

    for iburst = 1:length(bfiles)

        disp(['Burst ' num2str(iburst) ' : ' bfiles(iburst).name(1:end-4)])

        % Read burst file (skip if mat file already exists)
        if exist([bfiles(iburst).folder slash bfiles(iburst).name(1:end-4) '.mat'],'file')
            disp('*** mat file already exists ***')
            continue
        else
        [burst,avg,battery,echo] = readSWIFTv4_SIG([bfiles(iburst).folder slash bfiles(iburst).name]);
            if isempty(avg)
                disp('*** no data ***')
            end
        end

    end
    
end