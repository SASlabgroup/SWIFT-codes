
if ispc
    slash = '\';
else
    slash = '/';
end

% Experiment Directory
expdir = 'S:\SEAFAC\June2024';

% SBD folder
SBDfold = 'ProcessedSBD';

% Processing parameters
plotflag = true;  % binary flag for plotting (compiled plots, not individual plots... that flag is in the readSWIFT_SBD call)
fixspectra = false; % binary flag to redact low freq wave spectra, note this also recalcs wave heights
fixpositions = false; % binary flag to use "filloutliers" to fix spurious positions.   Use with care. 

% QC Parameters
minwaveheight = 0;% minimum wave height in data screening
minsalinity = 0;% PSU, for use in screen points when buoy is out of the water (unless testing on Lake WA)
maxdriftspd = 5;% m/s, this is applied to telemetry drift speed, but reported drift is calculated after that 
maxwindspd = 30;% m/s for malfunctioning Airmars
minairtemp = -20;% min airtemp
maxairtemp = 50;% max airtemp

disp('-------------------------------------')
disp('QC settings:')
disp(['Minimum wave height: ' num2str(minwaveheight) ' m'])
disp(['Minimum salinity: ' num2str(minsalinity) ' PSU'])
disp(['Maximum drift speed: ' num2str(maxdriftspd) ' ms^{-1}'])
disp(['Maximum wind speed: ' num2str(maxwindspd) ' ms^{-1}'])
disp(['Minimum air temp: ' num2str(minairtemp) ' C'])
disp(['Maximum air temp: ' num2str(maxairtemp) ' C'])
disp('-------------------------------------')

% List missions
missions = dir([expdir slash 'SWIFT*']);
missions = missions([missions.isdir]);

%% Loop through missions

for im = 1:length(missions)
    
    missiondir = [missions(im).folder slash missions(im).name];
    cd(missiondir)
    sname = missions(im).name;

    l1file 
    
     diaryfile = [missions(im).name '_pruneSWIFT.txt'];
     if exist(diaryfile,'file')
        delete(diaryfile);
     end
     diary(diaryfile)
     disp(['Pruning ' sname])

end
