function [SWIFT,sinfo] = L2_pruneSWIFT(missiondir,plotflag,minwaveheight,minsalinity,maxdriftspd)

% Find out-of-water bursts and prune them from the SWIFT structure using
%   minimum wave height, minimum salinity and maximum drift speed
%   thresholds. 

% Note: Does not pull from any raw burst files, just what is in the L1 SWIFT
% structure.

% K. Zeiden 10/10/2024, based on SWIFT_QC.m by J. Thomson.

if ispc
    slash = '\';
else
    slash = '/';
end

%% Mission name

islash = strfind(missiondir,slash);

if ~isempty(islash)
    sname = missiondir(islash(end)+1:end);
else
    sname = missiondir;
end

 %% Create diary file

 diaryfile = [missiondir slash sname '_L2_pruneSWIFT.txt'];

 if exist(diaryfile,'file')
     diary off
    delete(diaryfile);
 end
 diary(diaryfile)
 disp(['Pruning ' sname])

%% Load L1 file

L1file = dir([missiondir slash '*SWIFT*L1.mat']);

if ~isempty(L1file) 
    load([L1file.folder slash L1file.name],'SWIFT','sinfo');
else %  Exit reprocessing if no L1 product exists
    warning(['No L1 product found for ' sname '. Skipping...'])
    return
end

%% Loop through and identify out-of-water bursts

nburst = length(SWIFT);
outofwater = false(1,nburst);

for iburst = 1:nburst
        
    oneSWIFT = SWIFT(iburst);
    btime = oneSWIFT.time;

    disp('=================================')
    disp(['Burst ' num2str(iburst) ' : ' datestr(btime,'mmm dd yyyy, HH:MM')])
    
    % Waves too small (probably out of water)
    if isfield(oneSWIFT,'sigwaveheight')
        if oneSWIFT.sigwaveheight < minwaveheight || oneSWIFT.sigwaveheight >= 999
            outofwater(iburst) = true;
            disp(['Waves too small, removing burst ' num2str(iburst) '.'])
        end
    end
    
    % Salinity too small (probably out of water)
    if isfield(oneSWIFT,'salinity') 
        if all(oneSWIFT.salinity < minsalinity) 
            outofwater(iburst) = true;
            disp(['Salinity too low, removing burst ' num2str(iburst) '.'])
        end
    end
    
    % Drift speed limit (if too fast, probably out of water)
    if isfield(oneSWIFT,'driftspd')
        if oneSWIFT.driftspd > maxdriftspd
            outofwater(iburst) = true;
            disp(['Speed too fast, removing burst ' num2str(iburst) '.'])
        end
    end

end

%% Remove out-of-water bursts

SWIFT(outofwater) = [];

%% Save L2 file

save([missiondir slash sname '_L2.mat'],'SWIFT','sinfo')

%% Re-load L2 SWIFT

L2file = dir([missiondir slash '*L2.mat']);
load([L2file.folder slash L2file.name],'SWIFT','sinfo')

%% Plot
if plotflag
    try
        if strcmp(sinfo.type,'V3')
            fh = plotSWIFTV3(SWIFT);
            else
                fh = plotSWIFTV4(SWIFT);
        end
    set(fh,'Name',L2file.name(1:end-4))
    print(fh,[L2file.folder slash L2file.name(1:end-4)],'-dpng')
    catch ME
        disp(['Plot failed: ' ME.message])
    end
end

%% Close diary

diary off

end % End function
