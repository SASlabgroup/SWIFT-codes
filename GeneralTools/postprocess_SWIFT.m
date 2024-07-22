% [SWIFT,sinfo] = postprocess_SWIFT(expdir)

% Master post-processing function, that calls sub-functions to reprocess
% raw SWIFT data.

% K. Zeiden 07/2024

expdir = 'S:\SEAFAC\June2024';
cd(expdir)

if ispc
    slash = '\';
else
    slash = '/';
end

missions = dir([expdir slash 'SWIFT1*']);
missions = missions([missions.isdir]);

rpIMU = false; % Waves
rpSBG = false; % Waves
rpWXT = false; % MET
rpY81 = false; % MET
rpACS = false; % CT
rpSIG = false; % TKE
rpAQH = true; % TKE
rpAQD = false; % TKE

%% Loop through missions and reprocess

for im = 1:length(missions)

    disp(['Post-processing ' missions(im).name])

    missiondir = [missions(im).folder slash missions(im).name];
    cd(missiondir)

    % Locate L1 product, skip if does not exist. 
    % Else create 'sinfo' and modify L1 product.
    l1file = dir([missiondir slash '*L1*']);
    if isempty(l1file)
        disp(['No L1 product found for ' missiondir(end-16:end) '. Skipping...'])
    else
        load([l1file.folder slash l1file.name],'SWIFT');
        if isfield(SWIFT,'ID')
            disp('Create information structure ''sinfo''')
            sinfo.ID = SWIFT(1).ID;
            sinfo.CTdepth = SWIFT(1).CTdepth;
            sinfo.metheight = SWIFT(1).metheight;
           SWIFT = rmfield(SWIFT,{'ID','CTdepth','metheight'});
            disp('Saving new L1 product...')
            save([l1file.folder slash l1file.name],'SWIFT','sinfo')
        else
            load([l1file.folder slash l1file.name],'sinfo')
        end
    end
    
    % Reprocess IMU
    if rpIMU && ~isempty(dir([missiondir slash '*' slash 'Raw' slash '*' slash '*_IMU_*.dat']))
        disp('Reprocessing IMU data...')
        calctype = 'IMUandGPS';
        filtertype = 'RC';
        saveraw = false;
        [SWIFT,sinfo] = reprocess_IMU(missiondir,calctype,filtertype,saveraw);
    else
        disp('No IMU data...')
    end

    % Reprocess SBG
    if rpSBG && ~isempty(dir([missiondir slash '*' slash 'Raw' slash '*' slash '*_SBG_*.dat']))
        disp('Reprocessing SBG data...')
        saveraw = false;
        useGPS = false;
        interpf = false;
        [SWIFT,sinfo] = reprocess_SBG(missiondir,saveraw,useGPS,interpf);
    else
        disp('No SBG data...')
    end

    % Reprocess WXT
    if rpSBG && ~isempty(dir([missiondir slash '*' slash 'Raw' slash '*' slash '*_WXT_*.dat']))
        disp('Reprocessing Vaisala WXT data...')
        readraw = false;
        [SWIFT,sinfo] = reprocess_WXT(missiondir,readraw);
    else
        disp('No WXT data...')
    end

    % Reprocess Y81
    if rpY81 && ~isempty(dir([missiondir slash '*' slash 'Raw' slash '*' slash '*_Y81_*.dat']))
        disp('Reprocessing Y81 Sonic Anemometer data...')
        [SWIFT,sinfo] = reprocess_Y81(missiondir);
    else
        disp('No Y81 data...')
    end

    % Reprocess ACS
    if rpACS && ~isempty(dir([missiondir slash '*' slash 'Raw' slash '*' slash '*_ACS_*.dat']))
        disp('Reprocessing ACS CT data...')
        readraw = false;
        [SWIFT,sinfo] = reprocess_ACS(missiondir,readraw);
    else
        disp('No ACS data...')
    end

    % Reprocess PB2
    % does not exist

    % Reprocess SIG
    if rpSIG && ~isempty(dir([missiondir slash '*' slash 'Raw' slash '*' slash '*_SIG_*.dat']))
        disp('Reprocessing Signature1000 data...')
        plotburst = false; 
        readraw = false;
        [SWIFT,sinfo] = reprocess_SIG(missiondir,readraw,plotburst);
    else
        disp('No SIG data...')
    end

    % Reprocess AQD
    if rpAQD && ~isempty(dir([missiondir slash '*' slash 'Raw' slash '*' slash '*_AQD_*.dat']))
        disp('Reprocessing Aquadopp (AQD) data...')
        readraw = true;
        [SWIFT,sinfo] = reprocess_AQD(missiondir,readraw);
    else
        disp('No AQD data...')
    end

    % Reprocess AQH
    if rpAQH && ~isempty(dir([missiondir slash '*' slash 'Raw' slash '*' slash '*_AQH_*.dat']))
        disp('Reprocessing Aquadopp (AQH) data...')
        readraw = true;
        plotburst = false;
        [SWIFT,sinfo] = reprocess_AQH(missiondir,readraw,plotburst);
    else
        disp('No AQH data...')
    end

    % Reprocess 536
    % Heitronics CT15 ?
    % Does not exist

end



