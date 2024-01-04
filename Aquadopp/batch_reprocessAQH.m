% Bulk reprocess_AQH on an entire experiment w/multiple missions

%SUGGESTION: run 'batch_readrawAQH.m' prior to this script, to read in raw
% data first and save to mat files, instead of using opt 'readraw'

expdir = 'S:\PAPA\SikuliaqCruise2019\SWIFT_L0_raw\';
savedir = 'C:\Users\Kristin Zeiden\Dropbox\MATLAB\OSPAPA\Data\2019\reprocessed_AQH\';

missions = dir([expdir '\*SWIFT*']);
missions = missions([missions.isdir]);

%% Loop through and Reprocess

for im = 1:length(missions)
    
    if isfolder([expdir missions(im).name '\AQH'])
        
        try
        missiondir = [expdir missions(im).name];         
        [SWIFT,AQH] = reprocess_AQH(missiondir,savedir,...
            'saveAQH','saveSWIFT');
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