% [SWIFT,sinfo] = postprocess_SWIFT(expdir)

% Master post-processing function, that calls sub-functions to reprocess
% raw SWIFT data.

% K. Zeiden 07/2024

expdir = 'S:\SEAFAC\June2024\SouthMooring';
cd(expdir)

if ispc
    slash = '\';
else
    slash = '/';
end

missions = dir([expdir slash 'SWIFT*']);
missions = missions([missions.isdir]);

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
    
    %% Reprocess IMU
    if ~isempty(dir([missiondir slash '*' slash 'Raw' slash '*' slash '*_IMU_*.dat']))
        disp('Reprocessing IMU data...')
        calctype = 'IMUandGPS';
        filtertype = 'RC';
        saveraw = false;
        [SWIFT,sinfo] = reprocess_IMU(missiondir,calctype,filtertype,saveraw);
    else
        disp('No IMU data...')
    end

    %% Reprocess SBG
    if ~isempty(dir([missiondir slash '*' slash 'Raw' slash '*' slash '*_SBG_*.dat']))
        disp('Reprocessing SBG data...')
        saveraw = false;
        useGPS = false;
        interpf = false;
        [SWIFT,sinfo] = reprocess_SBG(missiondir,saveraw,useGPS,interpf);
    end

    %% Reprocess SIG
    % if ~isempty(dir([missiondir slash '*' slash 'Raw' slash '*' slash '*_SIG_*.dat']))
    %     disp('Reprocessing SIG data...')
    %     plotburst = false; 
    %     readraw = false;
    %     [SWIFT,sinfo] = reprocess_SIG(missiondir,readraw,plotburst);
    % end

    %%
    % Reprocess WXT

    % Reprocess Y81

    % Reprocess ACS

    % Reprocess PB2

    % Reprocess IMU

    % Reprocess AQD

    % Reprocess AQH


    %clear SWIFT sinfo
end



