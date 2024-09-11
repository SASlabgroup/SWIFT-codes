% [SWIFT,sinfo] = postprocess_SWIFT(expdir)

% Master post-processing function, that calls sub-functions to reprocess
% each different type of raw SWIFT data.
% L1 product must have been created prior to running this script,
% by running 'concatSWIFT_offloadedSDcard.m' in the mission directory
% Note: concatSWIFT in turn runs 'compileSWIFT_SBDservertelemetry.m',
%       which in turn calls the function 'readSWIFT_SBD.m'
% Currently no reprocessing option for Airmar (PB2) 
%       nor Heitronics CTs (536?)

% K. Zeiden 07/2024

%% User defined experiment directory (to be later converted to function inputs)

if ispc
    slash = '\';
else
    slash = '/';
end

expdir = ['S:' slash 'NORSE' slash '2023'];

% Processing toggles
rpIMU = false; % Waves
rpSBG = false; % Waves
rpWXT = false; % MET
rpY81 = false; % MET
rpACS = false; % CT
rpSIG = true; % TKE
rpAQH = false; % TKE
rpAQD = false; % TKE

% Plotting toggle
plotL1L2 = true;

%% Loop through missions and reprocess
cd(expdir)
missions = dir([expdir slash 'SWIFT*']);
missions = missions([missions.isdir]);

for im = 17

    disp(['Post-processing ' missions(im).name])

    missiondir = [missions(im).folder slash missions(im).name];
    cd(missiondir)

    %% Locate L1 product, skip if does not exist. 
    % Else create 'sinfo' and modify L1 product.
    l1file = dir([missiondir slash '*L1.mat']);
    if isempty(l1file)
        disp(['No L1 product found for ' missiondir(end-16:end) '. Skipping...'])
    else
        load([l1file.folder slash l1file.name],'SWIFT');
        if isfield(SWIFT,'ID')
            disp('Create information structure ''sinfo''')
            sinfo.ID = SWIFT(1).ID;
            sinfo.CTdepth = SWIFT(1).CTdepth;
            if isfield(SWIFT,'metheight')
            sinfo.metheight = SWIFT(1).metheight;
            end
            if isfield(SWIFT,'signature')
                sinfo.type = 'V4';
            else 
                sinfo.type = 'V3';
            end
            disp('Saving new L1 product...')
            save([l1file.folder slash l1file.name],'SWIFT','sinfo')
        end
        % One time, will remove later
        if isfield(SWIFT,'signature')
            sinfo.type = 'V4';
            save([l1file.folder slash l1file.name],'sinfo','-append')
            else
                sinfo.type = 'V3';
                save([l1file.folder slash l1file.name],'sinfo','-append')
        end
    end
    
    %% Reprocess IMU
    if rpIMU
        if ~isempty(dir([missiondir slash '*' slash 'Raw' slash '*' slash '*_IMU_*.dat']))
            disp('Reprocessing IMU data...')
            calctype = 'IMUandGPS';
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

    %% Reprocess WXT (536!!!)
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
            plotburst = true; 
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

    %% Re-load L1 and L2 product and plot each for comparison
    load([l1file.folder slash l1file.name],'SWIFT','sinfo');
    SWIFTL1 = SWIFT;
    l2file = dir([missiondir slash '*L2.mat']);
    load([l2file.folder slash l2file.name],'SWIFT');
    SWIFTL2 = SWIFT;

    if plotL1L2
        if strcmp(sinfo.type,'V3')
        fh1 = plotSWIFTV3(SWIFTL1);
        fh2 = plotSWIFTV3(SWIFTL2);
        else
            fh1 = plotSWIFTV4(SWIFTL1);
            fh2 = plotSWIFTV4(SWIFTL2);
        end
        print(fh1,[l1file.folder slash l1file.name(1:end-4)],'-dpng')
        print(fh2,[l2file.folder slash l2file.name(1:end-4)],'-dpng')
    end

end




