% Runs all processing for Willapa Bay 2025 (moored)

% 1. L0_createSBD.m
% 2. L1_compileSWIFT.m
% 3. L2_pruneSWIFT.m
% 4. L3_postprocessSWIFT.m

% K. Zeiden June 2025

if ispc
    slash = '\';
else
    slash = '/';
end

%% Experiment specific parameters

% Experiment Directory
expdir = 'S:\Willapa\Jun2025\MooredSWIFTs';
% expdir = '/Volumes/Data/Willapa/Jun2025/MooredSWIFTs';

% SBD folder
SBDfold = 'ProcessedSBD';

% Sampling Parameters
payloadtype = '7'; % v3.3 (2015) and up 

% Plotting toggle
plotflag = true;

% Prune Parameters (to identify out-of-water-bursts)
minwaveheight = 0;% minimum wave height [m]
minsalinity = 0;% minimum salinity [PSU] 
maxdriftspd = 10;% maximum drift speed [m/s]

%% List of missions

missions = dir([expdir slash 'SWIFT*']);
missions = missions([missions.isdir]);
missions = missions(~contains({missions.name},'directoffload'));

%% Loop through missions and post process

for im = length(missions)

    missiondir = [missions(im).folder slash missions(im).name];
    cd(missiondir)
    islash = strfind(missiondir,slash);
    sname = missiondir(islash(end)+1:end);

    % Burst interval
    acsfiles = dir([missiondir '\*\Raw\*\*ACS*.dat']);
    burstind = NaN(length(acsfiles),1);
    for iburst = 1:length(acsfiles)
        burstind(iburst) = str2double(acsfiles(iburst).name(end-5:end-4));
    end
    burstinterval = 60/max(burstind);

    % Create SBD files
    L0_createSBD(missiondir,SBDfold,burstinterval,payloadtype);

    % Compile SWIFT structure
    [SWIFTL1,sinfoL1] = L1_compileSWIFT(missiondir,SBDfold,burstinterval,plotflag);

    % Prune out-of-water bursts
    [SWIFTL2,sinfoL2] = L2_pruneSWIFT(missiondir,plotflag,minwaveheight,minsalinity,maxdriftspd);

    % Post-process
    [SWIFTL3,sinfoL3] = L3_postprocessSWIFT(missiondir,'rpall','plotswift');

    close all

end

%% Ad Hoc QC

% AdHocQC_WillapaBay

%% Plot Overview of all Missions
plotall = true;
swift = allSWIFT(expdir,'L3',plotall);

