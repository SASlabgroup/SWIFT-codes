function [SWIFT,sinfo] = L3_postprocessSWIFT(missiondir,plotflag)

% Master post-processing function, that calls sub-functions to reprocess
% each different type of raw SWIFT data and create an L3 product.
% L1 product must have been created prior to running this script,
% by running 'compileSWIFT.m', and L2 created by running 'pruneSWIFT.m';

% Need to consider additional QC steps after processing...
% Airmar temp, NaN out if below/above -20/50 deg C
% Wind speed, NaN out above 30 m/s

% K. Zeiden 07/2024, based on existing sensor-specific processing codes w 

if ispc
    slash = '\';
else
    slash = '/';
end

%% Processing toggles

rpIMU = true; % Waves
rpSBG = true; % Waves
rpWXT = true; % MET
rpY81 = true; % MET
rpACS = true; % CT
rpSIG = true; % TKE 
rpAQH = true; % TKE
rpAQD = true; % TKE

%% Mission name

islash = strfind(missiondir,slash);
if ~isempty(islash)
    sname = missiondir(islash(end)+1:end);
else
    sname = missiondir;
end

 %% Create diary file

diaryfile = [missiondir slash sname '_L3_postprocessSWIFT.txt'];
 if exist(diaryfile,'file')
    diary off
    delete(diaryfile);
 end
diary(diaryfile)

disp(['Post-processing ' sname])

%% Locate L2 product, skip if does not exist. 

L2file = dir([missiondir slash '*L2.mat']);

if isempty(L2file)
    disp(['No L2 product found for ' sname '. Skipping...'])
    return
else
    load([L2file.folder slash L2file.name],'SWIFT','sinfo');
end

%% Reprocess IMU

if rpIMU
    if ~isempty(dir([missiondir slash '*' slash 'Raw' slash '*' slash '*_IMU_*.dat']))
        disp('Reprocessing IMU data...')
        calctype = 'GPS';
        filtertype = 'RC';
        saveraw = false;
        interpf = false;
        [SWIFT,sinfo] = reprocess_IMU(missiondir,calctype,filtertype,saveraw,interpf);
    else 
        disp('No IMU data...')
    end
end

%% Reprocess SBG

if rpSBG 
    if ~isempty(dir([missiondir slash '*' slash 'Raw' slash '*' slash '*_SBG_*.dat']))
        disp('Reprocessing SBG data...')
        saveraw = false;
        useGPS = false;
        interpf = false;
        [SWIFT,sinfo] = reprocess_SBG(missiondir,saveraw,useGPS,interpf);
    else
        disp('No SBG data...')
    end
end

%% Reprocess WXT (536, confusing b/c CT15 can also be 536)

if rpWXT
    if ~isempty(dir([missiondir slash 'WXT' slash 'Raw' slash '*' slash '*_536_*.dat']))
        disp('Reprocessing Vaisala WXT data...')
        readraw = false;
        usewind = false;
        [SWIFT,sinfo] = reprocess_WXT(missiondir,readraw,usewind);
    else
        disp('No WXT data...')
    end
end

%% Reprocess Y81

if rpY81 
    if ~isempty(dir([missiondir slash '*' slash 'Raw' slash '*' slash '*_Y81_*.dat']))
        disp('Reprocessing Y81 Sonic Anemometer data...')
        [SWIFT,sinfo] = reprocess_Y81(missiondir);
    else
        disp('No Y81 data...')
    end
end

%% Reprocess ACS

if rpACS 
    if ~isempty(dir([missiondir slash '*' slash 'Raw' slash '*' slash '*_ACS_*.dat']))
        disp('Reprocessing ACS CT data...')
        readraw = false;
        [SWIFT,sinfo] = reprocess_ACS(missiondir,readraw);
    else
        disp('No ACS data...')
    end
end

%% Reprocess SIG

if rpSIG 
    if ~isempty(dir([missiondir slash '*' slash 'Raw' slash '*' slash '*_SIG_*.dat']))
        disp('Reprocessing Signature1000 data...')
        plotburst = false; 
        readraw = false;
        [SWIFT,sinfo] = reprocess_SIG(missiondir,readraw,plotburst);
    else
        disp('No SIG data...')
    end
end

%% Reprocess AQD

if rpAQD 
    if ~isempty(dir([missiondir slash '*' slash 'Raw' slash '*' slash '*_AQD_*.dat']))
        disp('Reprocessing Aquadopp (AQD) data...')
        readraw = true;
        [SWIFT,sinfo] = reprocess_AQD(missiondir,readraw);
    else
        disp('No AQD data...')
    end
end

%% Reprocess AQH
if rpAQH 
    if ~isempty(dir([missiondir slash '*' slash 'Raw' slash '*' slash '*_AQH_*.dat']))
        disp('Reprocessing Aquadopp (AQH) data...')
        readraw = false;
        plotburst = false;
        [SWIFT,sinfo] = reprocess_AQH(missiondir,readraw,plotburst);
    else
        disp('No AQH data...')
    end
end

%% Plot

L3file = dir([missiondir slash '*L3.mat']);

if plotflag
    if strcmp(sinfo.type,'V3')
    fh = plotSWIFTV3(SWIFT);
    else
        fh = plotSWIFTV4(SWIFT);
    end
    set(fh,'Name',L3file.name(1:end-4))
    print(fh,[L3file.folder slash L3file.name(1:end-4)],'-dpng')
end

%% Close diary

diary off

end % End function



