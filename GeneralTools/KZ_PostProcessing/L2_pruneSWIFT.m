% [SWIFT,sinfo] = L2_pruneSWIFT(expdir,plotflag)

% Find out-of-water bursts and prune them from the SWIFT structure using
%   minimum wave height, minimum salinity and maximum drift speed
%   thresholds. 

% K. Zeiden 10/10/2024, based on SWIFT_QC.m by J. Thomson.

%% User defined inputs

% Experiment Directory
expdir = '/Volumes/Data/SEAFAC/June2024';

% Plotting toggle
plotflag = false;

% QC Parameters
minwaveheight = 0;% minimum wave height in data screening
minsalinity = 1;% PSU, for use in screen points when buoy is out of the water (unless testing on Lake WA)
maxdriftspd = 3;% m/s, this is applied to telemetry drift speed, but reported drift is calculated after that 

%% List missions

if ispc
    slash = '\';
else
    slash = '/';
end

missions = dir([expdir slash 'SWIFT*']);
missions = missions([missions.isdir]);

%% Loop through missions and remove burst identified as out-of-water
for im = 1:length(missions)
    
    missiondir = [missions(im).folder slash missions(im).name];
    cd(missiondir)
    sname = missions(im).name;

     % Create diary file
     diaryfile = [missions(im).name '_L2_pruneSWIFT.txt'];
     if exist(diaryfile,'file')
        delete(diaryfile);
     end
     diary(diaryfile)
     disp(['Pruning ' sname])

    % Load L1 file
    l1file = dir([missiondir slash '*SWIFT*L1.mat']);
    if ~isempty(l1file) 
        load([l1file.folder slash l1file.name],'SWIFT','sinfo');
    else %  Exit reprocessing if no L1 product exists
        warning(['No L1 product found for ' missiondir(end-16:end) '. Skipping...'])
        return
    end

     % Loop through and identify out-of-water bursts
     nburst = length(SWIFT);
     outofwater = false(1,nburst);

     for iburst = 1:nburst
         oneSWIFT = SWIFT(iburst);
            
            % Waves too small (probably out of water)
            if isfield(oneSWIFT,'sigwaveheight')
                if oneSWIFT.sigwaveheight < minwaveheight || oneSWIFT.sigwaveheight >= 999
                    outofwater(iburst) = true;
                    disp('Waves too small, removing burst.')
                end
            end
            
            % Salinity too small (probably out of water)
            if isfield(oneSWIFT,'salinity') 
                if all(oneSWIFT.salinity < minsalinity) 
                    outofwater(iburst) = true;
                    disp('Salinity too low, removing burst.')
                end
            end
            
            % Drift speed limit (if too fast, probably out of water)
            if isfield(oneSWIFT,'driftspd')
                if oneSWIFT.driftspd > maxdriftspd
                    outofwater(iburst) = true;
                    disp('Speed too fast, removing burst.')
                end
            end

     end

     % Remove out-of-water bursts
     SWIFT(outofwater) = [];

     % Save L2 file
     save([missiondir slash sname '_L2.mat'],'SWIFT','sinfo')

     % Plot
     if plotflag
        L2file = dir([missiondir slash '*L2.mat']);
        if strcmp(sinfo.type,'V3')
        fh = plotSWIFTV3(SWIFT);
        else
            fh = plotSWIFTV4(SWIFT);
        end
        set(fh,'Name',L2file.name(1:end-4))
        print(fh,[L2file.folder slash L2file.name(1:end-4)],'-dpng')
      end

     % Turn off diary
     diary off

end % End mission loop