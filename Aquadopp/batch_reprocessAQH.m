% Bulk reprocess_SIG

expdir = 'S:\NORSE\2023\';% must end with \
savedir = 'C:\Users\kfitz\Dropbox\MATLAB\NORSE\Data\2023\SWIFT\reprocessedAQH\';% must end with \

missions = dir([expdir '\*SWIFT*']);

%% Loop through and Reprocess
%SUGGESTION: run 'batch_readAQH.m' prior to this script, to read in raw
% data first and save to mat files, instead of using opt 'readraw' here

for im = 1:length(missions)
    
    if isfolder([expdir missions(im).name '\AQH'])
        
        try
        missiondir = [expdir missions(im).name];         
        [SWIFT,SIG] = reprocess_AQH(missiondir,savedir,...
            'saveAQH','saveSWIFT','readraw');
        passthrough = false;
        catch ME
            if strcmp(ME.message,'   No burst files found    ')
                passthrough = true;
            else
                rethrow(ME)
            end
        end

        if passthrough
            disp(['No burst mat files found, skipping ' missions(im).name])
            continue
        end
    
    else
        disp(['No AQH data found in ' missions(im).name])
    end
    
end