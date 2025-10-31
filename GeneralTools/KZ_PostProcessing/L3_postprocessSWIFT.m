function [SWIFT,sinfo] = L3_postprocessSWIFT(missiondir,varargin)

% Master post-processing function, that calls sub-functions to reprocess
% each different type of raw SWIFT data and create an L3 product.
% L1 product must have been created prior to running this script,
% by running 'compileSWIFT.m', and L2 created by running 'pruneSWIFT.m';
% 
% [SWIFT,sinfo] = L3_postprocessSWIFT(missiondir,varargin)
%
% Need to consider additional QC steps after processing...
% Airmar temp, NaN out if below/above -20/50 deg C
% Wind speed, NaN out above 30 m/s
%
% K. Zeiden 07/2024, based on existing sensor-specific processing codes

if ispc
    slash = '\';
else
    slash = '/';
end

%% Default processing toggles

if nargin > 1

    % Read in Raw Data
    readraw = false;

    % Plotting
    plotswift = false;
    plotburst = false;

    % MET
    rpWXT = false; % MET
    rpPB2 = false; % MET
    rpY81 = false; % MET
    
    % Waves
    rpIMU = false; % Waves
    rpSBG = false; % Waves
    
    % CT
    rpACS = false; % CT

    % ACO
    rpACO = false;% Dissolved O2
    
    % ADCP
    rpSIG = false; % TKE 
    rpAQH = false; % TKE
    rpAQD = false; % TKE   

    % Look for post processing types
    for ivar = 1:length(varargin)
        command = varargin{ivar};
        
        switch command
            case 'rpWXT'; rpWXT = true;                
            case 'rpPB2'; rpPB2 = true;
            case 'rpY81'; rpY81 = true;
            case 'rpIMU'; rpIMU = true;
            case 'rpSBG'; rpSBG = true;
            case 'rpACS'; rpACS = true;
            case 'rpACO'; rpACO = true;
            case 'rpSIG'; rpSIG = true;
            case 'rpAQH'; rpAQH = true;
            case 'rpAQD'; rpAQD = true;
            case 'rpADCP'; rpSIG = true; rpAQH = true;rpAQD = true;
            case 'rpMET'; rpWXT = true; rpPB2 = true; rpY81 = true;
            case 'rpCT'; rpACS = true;
            case 'rpDO'; rpACO = true;
            case 'rpWaves'; rpIMU = true; rpSBG = true;
            case 'plotswift'; plotswift = true;
            case 'plotburst';plotburst = true;
            case 'readraw';readraw = true;
            case 'rpall'; rpWXT = true; rpPB2 = true; rpY81 = true; rpIMU = true;...
                    rpSBG = true; rpACS = true; rpACO = true; rpSIG = true; rpAQH = true; rpAQD = true;

            otherwise
                error('Unrecognized command: %s\n', command);

        end
    end

% If no inputs, reprocess everything, read raw, plot bursts...
else

% Readraw
readraw = true;

% Plotting
plotswift = true;
plotburst = false;

% MET
rpWXT = true; % MET
rpPB2 = true; % MET
rpY81 = true; % MET

% Waves
rpIMU = true; % Waves
rpSBG = true; % Waves

% CT
rpACS = true; % CT

% ACO
rpACO = true;

% ADCP
rpSIG = true; % TKE 
rpAQH = false; % TKE
rpAQD = true; % TKE    

end

if readraw
    warning('Reading raw burst files in.')
end


%% Mission name

islash = strfind(missiondir,slash);
if ~isempty(islash)
    sname = missiondir(islash(end)+1:end);
else
    sname = missiondir;
end

 %% Create diary file

diaryfile = [missiondir slash sname '_L3_postprocessSWIFT.txt'];

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
        saveraw = false; % this is the raw wave displacements, not the raw motion data
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
        tstart = 90;
        [SWIFT,sinfo] = reprocess_SBG(missiondir,plotburst,saveraw,useGPS,interpf,tstart);
    else
        disp('No SBG data...')
    end
end

%% Reprocess WXT (536, confusing b/c CT15 can also be 536)

if rpWXT
    if ~isempty(dir([missiondir slash 'WXT' slash 'Raw' slash '*' slash '*_536_*.dat']))
        disp('Reprocessing Vaisala WXT data...')
        usewind = true;
        [SWIFT,sinfo] = reprocess_WXT(missiondir,readraw,usewind);
    else
        disp('No WXT data...')
    end
end

%% Reprocess PB2 

if rpPB2
    if ~isempty(dir([missiondir slash '*' slash 'Raw' slash '*' slash '*_PB2_*.dat']))
        disp('Reprocessing Airmar Anemometer (PB2) data...')
        [SWIFT,sinfo] = reprocess_PB2(missiondir,readraw,plotburst);
    else
        disp('No PB2 data...')
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
        [SWIFT,sinfo] = reprocess_ACS(missiondir,readraw,plotburst);
    else
        disp('No ACS data...')
    end
end

%% Reprocess ACO

if rpACO
    if ~isempty(dir([missiondir slash '*' slash 'Raw' slash '*' slash '*_ACO_*.dat']))
        disp('Reprocessing ACO O2 Conc data...')
        [SWIFT,sinfo] = reprocess_ACO(missiondir,readraw,plotburst);
    else
        disp('No ACO data...')
    end
end

%% Reprocess SIG

if rpSIG 
    if ~isempty(dir([missiondir slash '*' slash 'Raw' slash '*' slash '*_SIG_*.dat']))
        disp('Reprocessing Signature1000 data...')
        [SWIFT,sinfo] = reprocess_SIG(missiondir,readraw,plotburst);
    else
        disp('No SIG data...')
    end
end

%% Reprocess AQD

if rpAQD 
    if ~isempty(dir([missiondir slash '*' slash 'Raw' slash '*' slash '*_AQD_*.dat']))
        disp('Reprocessing Aquadopp (AQD) data...')
        [SWIFT,sinfo] = reprocess_AQD(missiondir,readraw);
    else
        disp('No AQD data...')
    end
end

%% Reprocess AQH
if rpAQH 
    if ~isempty(dir([missiondir slash '*' slash 'Raw' slash '*' slash '*_AQH_*.dat']))
        disp('Reprocessing Aquadopp (AQH) data...')
        [SWIFT,sinfo] = reprocess_AQH(missiondir,readraw,plotburst);
    else
        disp('No AQH data...')
    end
end

%% Re-load L3 SWIFT

L3file = dir([missiondir slash '*L3.mat']);
load([L3file.folder slash L3file.name],'SWIFT','sinfo')

%% Plot

if plotswift
    try
        if strcmp(sinfo.type,'V3')
        fh = plotSWIFTV3(SWIFT);
        else
            fh = plotSWIFTV4(SWIFT);
        end
        set(fh,'Name',L3file.name(1:end-4))
        print(fh,[L3file.folder slash L3file.name(1:end-4)],'-dpng')
    catch ME
        disp(['Plot failed: ' ME.message])
    end
end



%% Close diary

diary off

end % End function




