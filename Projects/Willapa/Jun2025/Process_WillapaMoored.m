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

for im = 1:length(missions)

    missiondir = [missions(im).folder slash missions(im).name];
    cd(missiondir)
    islash = strfind(missiondir,slash);
    sname = missiondir(islash(end)+1:end);

    % Burst interval
    acsfiles = dir([missiondir slash '*' slash 'Raw' slash '*' slash '*ACS*.dat']);
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

    % Post-process all non-SBG sensors through the standard driver.
    [SWIFTL3,sinfoL3] = L3_postprocessSWIFT(missiondir, ...
        'rpWXT','rpPB2','rpY81','rpIMU','rpACS','rpACO', ...
        'rpSIG','rpAQH','rpAQD','plotswift');

    % SBG recovery decision (mounted-data audit, 8 Oct 2026): retain the
    % established 256-second FFT so the full wave-frequency range is
    % resolved; do not substitute 64/128/192-second windows. Only SWIFT26
    % uses the 76-second lower crop. Inspection of its first 90 seconds found
    % heave settling near 70--80 seconds, and tmin=76 recovers 18 additional
    % existing L2 records. No other Willapa mission gains a record relative
    % to the original 90-second crop, so those missions keep the default.
    %
    % SWIFT26 preview: 990 raw-SBG recoveries (888 three-window/18-DOF,
    % 18 two-window/12-DOF, 84 one-window/6-DOF). reprocess_SBG stores DOF
    % in wavespectra.dof, flags raw-SBG and reduced-DOF provenance in sinfo,
    % and writes SBG_processing_report.txt with source availability/errors.
    % A failed raw calculation remains missing: L2 wave values are not
    % carried into MATLAB L3/L4/L5. Expected ten-minute slots absent from L2
    % are reported but not inserted because they lack a vetted SWIFT record
    % skeleton.
    if strcmp(sname,'SWIFT26_16-27Jun2025')
        [SWIFTL3,sinfoL3] = reprocess_SBG( ...
            missiondir,false,false,false,true,90, ...
            tmin=76,minimum_windows=1);
    else
        [SWIFTL3,sinfoL3] = reprocess_SBG( ...
            missiondir,false,false,false,true,90);
    end

    % SWIFT25's SBG outage on 20--21 June is filled from the Signature
    % accelerometer after all available SBG records have been reprocessed.
    % The recovery is scalar and limited to 0.10--0.50 Hz; directional
    % moments and energy outside that band remain missing. reprocess_SIGheave
    % records the empirical calibration and per-record provenance in sinfo.
    if strcmp(sname,'SWIFT25_16-27Jun2025')
        [SWIFTL3,sinfoL3] = reprocess_SIGheave(missiondir, ...
            input_SWIFT=SWIFTL3,input_sinfo=sinfoL3);
    end

    close all

end

%% Ad Hoc QC

% AdHocQC_WillapaBay

%% Plot Overview of all Missions
plotall = true;
swift = allSWIFT(expdir,'L3',plotall);

