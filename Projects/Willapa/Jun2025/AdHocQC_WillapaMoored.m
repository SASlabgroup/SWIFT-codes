% Ad hoc QC Willapa Moored
% K. Zeiden July 2025

% Note: format to NaN out bad data
% ibad = [SWIFT.variable] > varmax;
% if ~isempty(ibad)
%     [SWIFT(ibad).variable] = deal(NaN);
% end

if ~exist('expdir','var') || isempty(expdir)
    if ispc
        expdir = 'S:/Willapa/Jun2025/MooredSWIFTs';
    else
        expdir = '/Volumes/PortableSSD/MooredSWIFTS';
    end
end

L3files = dir(fullfile(expdir,'SWIFT*','SWIFT*L3.mat'));
if exist('missionnames','var') && ~isempty(missionnames)
    keep = false(size(L3files));
    for im = 1:length(L3files)
        [~,missionname] = fileparts(L3files(im).folder);
        keep(im) = ismember(missionname,missionnames);
    end
    L3files = L3files(keep);
end

%%

for im = 1:length(L3files)

    disp(['QCing ' L3files(im).name '...'])

    load(fullfile(L3files(im).folder,L3files(im).name))

    %%% QC Out-of-water bursts using ACS flags
    iacs = find(strcmp({sinfo.postproc.type}','ACS'));
    iout = sinfo.postproc(iacs(end)).flags.outofwater;
    SWIFT = SWIFT(~iout);

    %%% Remove predeployment SWIFT28 records (the stray 5 June bursts)
    if strcmp(SWIFT(1).ID,'28')
        iexp = [SWIFT.time] >= datenum([2025 06 20]);
        SWIFT = SWIFT(iexp);
    end

    %%% Rotate Signature currents from magnetic to true north
    % Every Willapa Signature (SWIFT22-28) was configured with DECL=0.00, so
    % its onboard AHRS heading, and therefore the L3 east/north, are
    % referenced to magnetic north. Found in the ASCII config at the start
    % of each raw Signature file:
    %   $ strings -n 6 SIG/Raw/20250617/SWIFT22_SIG_17Jun2025_17_04.dat | grep GETUSER
    %   GETUSER,POFF=9.50,DECL=0.00,HX=0,HY=0,HZ=0
    % Rotate by the WMM2025 declination at the Willapa entrance, June 2025
    % (+15.10 E, uncertainty 0.38 deg; identical to 0.01 deg at 46.65N
    % 124.10W on 16 Jun), from the NOAA calculator:
    %   $ curl "https://www.ngdc.noaa.gov/geomag-web/calculators/calculateDeclination?lat1=46.70&lon1=-124.05&model=WMM&startYear=2025&startMonth=6&startDay=21&key=zNEw7&resultFormat=json"
    % The SBG already outputs true heading (EKF mode 4 with magnetometer
    % aiding applies its internal declination model), so the SBG-corrected
    % L5 profiles are true without this step. Checked by comparing EkfEuler
    % yaw with a tilt-compensated heading from the SBG's own calibrated Mag
    % log (60 records per buoy; median yaw - maghead = +16.0 SWIFT22,
    % +16.4 SWIFT23, +15.5 SWIFT24, +15.9 SWIFT25):
    %   Xh = mx.*cos(pitch) + my.*sin(roll).*sin(pitch) + mz.*cos(roll).*sin(pitch);
    %   Yh = my.*cos(roll) - mz.*sin(roll);
    %   maghead = atan2d(-Yh,Xh);   % compare with rad2deg(EkfEuler.yaw)
    % This also explains most of SWIFT22's Signature-vs-SBG compass gap
    % (+25 deg before 23 Jun vs +45.4 deg physical mounting from the gyros:
    % 45.4 - 15.1 = 30.3). uvar/vvar are left unrotated (no u-v covariance
    % is stored; a 15 deg rotation changes them little).
    % This is a more general problem: SWIFT Signature processing nowhere
    % applies declination, so Signature currents from any deployment with
    % DECL=0 are magnetic unless corrected downstream.
    declination = 15.10;
    if isfield(SWIFT,'signature')
        for it = 1:length(SWIFT)
            east = SWIFT(it).signature.profile.east;
            north = SWIFT(it).signature.profile.north;
            SWIFT(it).signature.profile.east = east*cosd(declination) + north*sind(declination);
            SWIFT(it).signature.profile.north = north*cosd(declination) - east*sind(declination);
        end
    end

    %%% Trim Altimeter & Remove Bottom Reflections
    if isfield(SWIFT,'signature')
        for it = 1:length(SWIFT)

            % if isfield(SWIFT(it).signature,'altimeter')
            %     maxz = SWIFT(it).signature.altimeter;
            % 
            %     % Trim HR
            %     hrtrim = SWIFT(it).signature.HRprofile.z > maxz;
            %     SWIFT(it).signature.HRprofile.w(hrtrim) = NaN;
            %     SWIFT(it).signature.HRprofile.wvar(hrtrim) = NaN;
            %     SWIFT(it).signature.HRprofile.eps(hrtrim) = NaN;
            % 
            %     % Trim Broadband
            %     avgtrim = SWIFT(it).signature.profile.z > maxz;
            %     SWIFT(it).signature.profile.east(avgtrim) = NaN;
            %     SWIFT(it).signature.profile.north(avgtrim) = NaN;
            %     SWIFT(it).signature.profile.w(avgtrim) = NaN;
            %     SWIFT(it).signature.profile.uvar(avgtrim) = NaN;
            %     SWIFT(it).signature.profile.vvar(avgtrim) = NaN;
            %     SWIFT(it).signature.profile.wvar(avgtrim) = NaN;
            %     SWIFT(it).signature.profile.spd_alt(avgtrim) = NaN;
            % 
            %     % Trim Echogram
            %     echotrim = SWIFT(it).signature.echoz > maxz;
            %     SWIFT(it).signature.echo(echotrim) = NaN;
            % end

            % Remove bottom reflections from dissipation
            ibad = isnan(SWIFT(it).signature.HRprofile.w);
            SWIFT(it).signature.HRprofile.tkedissipationrate(ibad) = NaN;
        end
    end 

    %%% Salintiy
    ibad = [SWIFT.salinity] > 40 | [SWIFT.salinity] < 20;
    if ~isempty(ibad)
        [SWIFT(ibad).salinity] = deal(NaN);
        [SWIFT(ibad).salinitystddev] = deal(NaN);
    end

    %%% Temperature
    ibad = [SWIFT.watertemp] > 18 | [SWIFT.watertemp] < 8;
    if ~isempty(ibad)
        [SWIFT(ibad).watertemp] = deal(NaN);
        [SWIFT(ibad).watertempstddev] = deal(NaN);
    end

    %%% Air Temperature
    if isfield(SWIFT,'airtemp')
        ibad = [SWIFT.airtemp] > 25;
        if ~isempty(ibad)
            [SWIFT(ibad).airtemp] = deal(NaN);
            [SWIFT(ibad).airtempstddev] = deal(NaN);
        end
    end

    %%% Humidity
    if isfield(SWIFT,'relhumidity')
        ibad = [SWIFT.relhumidity] < 70;
        if ~isempty(ibad)
            [SWIFT(ibad).relhumidity] = deal(NaN);
            [SWIFT(ibad).relhumiditystddev] = deal(NaN);
        end
    end

    %%% Bad Position
    if isfield(SWIFT,'lon')
        ibad = [SWIFT.lat] < 46 | [SWIFT.lat] > 48;
        [SWIFT(ibad).lon] = deal(NaN);
        [SWIFT(ibad).lat] = deal(NaN);
    end


    %%% SWIFT24 between Jun 20 and 21, and moving off site from Jun 25
    %%% 18:20 until its redeployment
    if strcmp(SWIFT(1).ID,'24')
        icut = [SWIFT.time] > datenum([2025 06 20 20 00 00]) & [SWIFT.time] < datenum([2025 06 21 06 00 00]);
        SWIFT = SWIFT(~icut);
        icut = [SWIFT.time] >= datenum([2025 06 25 18 20 00]) & [SWIFT.time] < datenum([2025 06 25 22 30 00]);
        SWIFT = SWIFT(~icut);

    end

    %%% Position outliers: off-site records at either end of the deployment
    %%% (transit/recovery not caught by ACS) are dropped; isolated GPS spikes
    %%% lose their position.
    [SWIFT,positionqc] = QC_mooredPositions(SWIFT);
    disp(['  dropped ' num2str(nnz(positionqc.dropped)) ' off-site record(s), ' ...
        'cleared ' num2str(nnz(positionqc.spike)) ' GPS spike(s)'])

    % Remove isolated wave-energy spikes coherently from the L3 source used
    % to make L4. This clears the bulk wave fields and all spectral fields
    % while preserving the frequency coordinate.
    [SWIFT,waveqc] = QC_isolatedWaveSpikes(SWIFT);
    if any(waveqc.flag)
        disp(['  removed ' num2str(nnz(waveqc.flag)) ...
            ' isolated L3 wave spike(s)'])
    end

    % Log in sinfo
    if isfield(sinfo,'postproc')
    ip = length(sinfo.postproc)+1; 
    else
        sinfo.postproc = struct;
        ip = 1;
    end
    sinfo.postproc(ip).type = 'AdHocQC';
    sinfo.postproc(ip).usr = getenv('username');
    sinfo.postproc(ip).time = string(datetime('now'));
    sinfo.postproc(ip).params = struct('waveSpikeQC',waveqc.params, ...
        'positionQC',positionqc.params,'signatureDeclination',declination);
    sinfo.postproc(ip).flags = struct('waveoutlier',waveqc.flag);

    % Save L4 product
    save(fullfile(L3files(im).folder,[L3files(im).name(1:end-6) 'L4.mat']),'SWIFT','sinfo')

    
end

