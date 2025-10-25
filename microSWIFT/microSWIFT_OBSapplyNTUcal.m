% matlab script to apply NTU calibration to OpenOBS on microSWIFT buoys
%
% J. Thomson, Oct 2025

clear all, close all

%% load calibration coefficents

cals = importdata('microSWIFT_openOBS_FormazinCals.csv');
OBSsn = cals.data(:,1);
microID = cals.data(:,2);
slope = cals.data(:,3);
offset = cals.data(:,3);

%% list and loop mat files in a directory

flist = dir('*SWIFT*.mat');

for fi = 1:length(flist)

    load(flist(fi).name)

    if isfield(SWIFT,'OBS_uncalibrated')

        for si=1:length(SWIFT)

            match = find( SWIFT(si).OBS_serialnum == OBSsn ); 

            if ~isempty(match) && microID(match) == str2num(SWIFT(si).ID)
                disp('applying calibration')
                SWIFT(si).OBS_calibratedNTU = SWIFT(si).OBS_uncalibrated .* slope(match) + offset(match);
            else
                SWIFT(si).OBS_calibratedNTU = NaN(17,1);
            end

        end

    else

        disp(['no OBS data in ' flist(fi).name])

    end

    save(flist(fi).name,'SWIFT')

    plotSWIFT(SWIFT)
    
end