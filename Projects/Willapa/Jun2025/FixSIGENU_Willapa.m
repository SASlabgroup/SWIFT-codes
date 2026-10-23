% Fix Signature ENU data on Willapa SWIFTs
%
% One-off processing for the June 2025 Willapa moorings. L4 products and raw
% SIG/SBG burst files are read from the local archive; L5 products, a
% per-burst source/failure audit, and mission review plots are written next
% to them in each mission folder (outdir defaults to the archive). Each
% burst is corrected by fixWillapaBurst; plots come from plotWillapaL5Review.
%
% Optional workspace overrides: expdir (the archive read from), outdir
% (e.g. a staging directory), missionnames (a subset of the missions
% below), and validorientationmissions (missions for which both the SBG
% attitude-valid and heading-valid flags are required). Requires the
% Parallel Computing Toolbox.

if ~exist('expdir','var')
    expdir = '/Volumes/PortableSSD/MooredSWIFTS';
end
if ~exist('outdir','var')
    outdir = expdir;
end
if ~exist('missionnames','var')
    missionnames = ["SWIFT22_17-26Jun2025","SWIFT23_17-26Jun2025", ...
        "SWIFT24_16-20Jun2025","SWIFT24_20-25Jun2025","SWIFT24_25-27Jun2025", ...
        "SWIFT25_16-27Jun2025","SWIFT26_16-27Jun2025","SWIFT28_20-21Jun2025"];
end
if ~exist('validorientationmissions','var')
    validorientationmissions = strings(0,1);
end
sentinelfile = ['/Users/mleclair/Dropbox/phd/code/willapa_prep/data/sentinel/' ...
    'S2B_MSIL2A_20250608T190909_N0511_R056_T10TDS_20250608T212948.SAFE/' ...
    'GRANULE/L2A_T10TDS_A043125_20250608T191625/IMG_DATA/R10m/' ...
    'T10TDS_20250608T190909_TCI_10m.jp2'];

%% Orientation offsets
%
% fixSIGenu orients the Signature as
%   R = Rz_world(worldyaw) * R_SBG(yaw,pitch,roll) * Rz_body(mountyaw).
%
% Body frame (mountyaw = frameoffset + clocking). Measured by fitting a
% rotation (Kabsch) from the Signature AHRS gyro to the SBG gyro: bursts
% corrected in the L5 audit with a direct gyro lag and lag correlation > 0.9;
% SBG gyro shifted by the audit lag and interpolated to the Signature
% samples; burst means removed. The fit is a pure yaw (pitch/roll ~0, axis
% correlations 0.98--0.99):
%   SWIFT23, all SWIFT24 deployments, SWIFT25  -45.0 +/- 0.5 deg
%   SWIFT26                                    -48.6 deg (21/60 bursts)
%   SWIFT22                                    +45.4 deg (59/60 bursts,
%                                              unchanged across the 23 June
%                                              AHRS failure)
% i.e. one Signature-to-SBG frame offset of -45 deg on every buoy, plus a
% clocking of the SBG in multiples of 90 deg: +90 on SWIFT22.
frameoffset = -45;
clocking = dictionary(["22","23","24","25","26","28"],[90 0 0 0 0 0]);
%
% World frame. worldyaw = 0: the SBG yaw is given an absolute, true
% heading from the SBG's own magnetometer (below). The onboard Signature
% heading is magnetic (DECL=0 in every raw header); the L4 Signature
% currents are rotated to true in AdHocQC_WillapaMoored.
worldyaw = 0;
%
%% SBG yaw from the magnetometer
%
% The SBG EKF yaw cannot be used as logged. The onboard magnetometer
% calibrations are stale: the Mag log's leveled field circle sits up to ~2
% radii from the origin (SWIFT25), which squeezes the magnetic heading, and
% the EKF follows it (EKF yaw - magnetic heading = declination). SWIFT26
% and SWIFT28 ran in vertical-gyro mode (EkfEuler.solution_status
% bitand(.,15) = 1 for 99.6% / 100% of samples, magnetometer used in 0.2% /
% 0%; sbgECom sbgEComLogEkf.h), so their yaw is relative only.
%
% Each mission's Mag log is therefore recalibrated (fitMagCalibration3D):
% hard iron and soft iron in the body frame, in 24.84 h windows (two M2
% cycles) every 3 h, by RANSAC scored on heading coverage, with the
% corrected field held to the WMM inclination so the vertical is
% constrained despite the small tilts of a moored buoy. No window spans a
% battery change (servicetimes). fixWillapaBurst then shifts each SBG
% record's yaw so its median matches the calibrated magnetometer heading
% plus the declination, keeping the EKF's relative yaw motion; records with
% no usable magnetometer anchor are not used. With every record anchored,
% vertical-gyro yaw can be rotated (allowrelativeyaw).
%
% Checks (Projects/Willapa/Jun2025/WILLAPA_L5_FINAL.md;
% plotSBGmagCalibration3D for a mission's debug plots): after calibration
% the field magnitude is constant to 2-5% and the inclination is 67.5 +/- 1-3 deg on
% every SBG; the raw Signature magnetometer, calibrated the same way,
% gives the same absolute heading to within ~4 deg; and L5 currents
% follow the anchor-drag-corrected watch-circle bearing with smaller
% scatter than with a levelled 2D calibration, notably on SWIFT22/23, where
% the 2D fit left a +/-30 deg tidal oscillation from body-frame hard iron
% leaking in with tilt. The watch circle is used only for these checks.
magneticdeclination = 15.10;     % WMM2025, deg east
magneticinclination = 67.6;      % WMM, deg
magcalibrationwindow = 2*12.42/24;
magcalibrationstep = 3/24;
% Battery change and data offload: the new pack is a new hard and soft iron.
servicetimes = dictionary("SWIFT25_16-27Jun2025",datenum(2025,6,21));
%
% SWIFT28 has a healthy Signature AHRS: its original heading follows the
% watch circle and its L4 currents retain a strong, channelized M2 signal.
% The SBG correction still runs for the audit, but L4 is kept unchanged.

%% Timing
%
% Reconstruct the SBG clock from valid UTC packets, then combine nearby
% files and select their samples by physical time. Exact filenames do not
% always contain the same acquisition minutes on this deployment. When no
% SBG UTC anchor is usable, or neighboring UTC records do not provide enough
% overlap, fixSIGenu's relative-time fallback stamps the burst's own SBG file
% onto the burst start. It is restricted to the burst's own 10-min slot,
% since the gyro lag search (~100 s) cannot recover a file from another slot
% (the SWIFT25 outage had neighbors hours away), and its bursts must pass the
% direct lag test. Relative-clock lag outliers are compared only with other
% relative-clock lags because UTC-clock lags include the recorder offset.
mintimecorrelation = 0.8;
maxtimelagdeparture = 3;

% Broadband options used by reprocess_SIG.
sigopt.xz = 0.2;
sigopt.plotburst = false;
sigopt.avg.QCbin = true;
sigopt.avg.mincorr = 50;
sigopt.avg.QCfish = true;

if isempty(gcp('nocreate')); parpool('Processes',8); end

% Index raw files once; recursive searches per burst are much slower.
sigfiles = dir(fullfile(expdir,'**','SWIFT*_SIG_*.mat'));
sbgfiles = dir(fullfile(expdir,'**','SWIFT*_SBG_*.mat'));
sigfiles = sigfiles(~startsWith({sigfiles.name},'._'));
sbgfiles = sbgfiles(~startsWith({sbgfiles.name},'._'));

% A 40 m overview of the Sentinel-2 tile is ample for the review maps.
sentinel.image = imread(sentinelfile,'ReductionLevel',2);
sentinelref = georasterinfo(sentinelfile).RasterReference;
sentinel.x = linspace(sentinelref.XWorldLimits(1), ...
    sentinelref.XWorldLimits(2),size(sentinel.image,2));
sentinel.y = linspace(sentinelref.YWorldLimits(2), ...
    sentinelref.YWorldLimits(1),size(sentinel.image,1));

set(0,'DefaultFigureVisible','off')

%% Recalculate the broadband profiles of each mission

for mission = string(missionnames)

    missiondir = fullfile(expdir,mission);
    reviewdir = fullfile(outdir,mission,'L5_review');
    if ~exist(reviewdir,'dir'); mkdir(reviewdir); end

    load(fullfile(missiondir,mission + "_L4.mat"),'SWIFT','sinfo');
    SWIFTL4 = SWIFT;
    platform = SWIFT(1).ID;
    nburst = length(SWIFT);
    opts.mountyaw = frameoffset + clocking(string(platform));
    opts.worldyaw = worldyaw;
    % Every record is anchored to the magnetometer, so relative
    % (vertical-gyro) yaw is usable.
    opts.allowrelativeyaw = true;
    % Optional validity masking of the SBG Euler samples (off by default).
    % Vertical-gyro EKFs never set the heading-valid flag, so do not mask
    % SWIFT26/28 on it; their yaw is referenced by the magnetometer anchor.
    opts.requirevalidorientation = ismember(mission,validorientationmissions);
    opts.sigopt = sigopt;
    breaks = [];
    if isKey(servicetimes,mission); breaks = servicetimes(mission); end
    magrecords = loadSBGmagRecords(missiondir);
    opts.magcalibration = fitMagCalibration3D(magrecords.key,magrecords.m, ...
        magrecords.d,magcalibrationwindow,magcalibrationstep,breaks, ...
        magneticinclination);
    opts.magneticdeclination = magneticdeclination;
    % Watch-circle bearing, for the review plots only
    [~,watchheading] = watchBearingDrag(SWIFT,At=[SWIFT.time]');
    sources = matchSources(SWIFT,missiondir,sigfiles,sbgfiles);

    disp("Processing " + mission + " (" + nburst + " bursts)")
    results = cell(nburst,1);
    profiles = cell(nburst,1);
    parfor iburst = 1:nburst
        [results{iburst},profiles{iburst}] = fixWillapaBurst(SWIFT(iburst), ...
            sources(iburst),opts,[]);
    end
    results = vertcat(results{:});

    % A weak or corrupt gyro record can still give xcorr a false peak. Use
    % the neighboring high-correlation bursts to estimate only those lags.
    % This follows platform/deployment timing changes instead of assuming a
    % fixed recorder offset. A relative-time burst has no clock of its own to
    % fall back on, so a neighbor lag would be a guess: it must pass directly.
    rawlag = [results.time_lag]'*86400;
    lagcorrelation = [results.lag_correlation]';
    timesource = string([results.time_source]');
    relativetime = startsWith(timesource,"relative_native");
    localmedianlag = movmedian(rawlag,13,'omitnan');
    % Relative-clock lags are measured after aligning the starts of the
    % matched files; UTC-clock lags include the recorder-clock offset. Do
    % not classify a valid relative lag as an outlier against numerically
    % incomparable UTC lags at the edges of a UTC-packet outage.
    relativelag = rawlag;
    relativelag(~relativetime) = NaN;
    localrelativelag = movmedian(relativelag,13,'omitnan');
    localmedianlag(relativetime) = localrelativelag(relativetime);
    lagdeparture = abs(rawlag-localmedianlag);
    haslag = isfinite(rawlag);
    goodtime = lagcorrelation >= mintimecorrelation & ...
        lagdeparture <= maxtimelagdeparture;
    lowcorr = haslag & lagcorrelation < mintimecorrelation;
    lagoutlier = haslag & lagdeparture > maxtimelagdeparture;
    lagmethod = strings(nburst,1);
    lagreason = strings(nburst,1);
    lagmethod(goodtime) = "direct";
    lagreason(goodtime) = "accepted";
    lagreason(lowcorr) = "low_correlation";
    lagreason(lagoutlier) = "local_outlier";
    lagreason(lowcorr & lagoutlier) = "low_correlation+local_outlier";
    rejected = haslag & ~goodtime & relativetime;
    lagmethod(rejected) = "relative_time_rejected";
    for iburst = find(rejected)'
        results(iburst).status = "relative_time_weak_lag";
    end
    extrapolatedlag = false(nburst,1);
    retry = find(haslag & ~goodtime & ~relativetime);
    good = find(goodtime);
    if length(good) >= 2 && ~isempty(retry)
        neighborlag = interp1(good,rawlag(good),(1:nburst)','linear','extrap');
        disp("Using neighboring gyro lags for " + length(retry) + ...
            " weak-correlation bursts")
        for iburst = retry'
            [result,profile] = fixWillapaBurst(SWIFT(iburst),sources(iburst), ...
                opts,neighborlag(iburst));
            if result.status ~= "corrected"
                lagmethod(iburst) = "direct_retry_failed";
                continue
            end
            results(iburst) = result;
            profiles{iburst} = profile;
            extrapolatedlag(iburst) = iburst < good(1) || iburst > good(end);
            lagmethod(iburst) = "interpolated";
            if extrapolatedlag(iburst); lagmethod(iburst) = "extrapolated"; end
        end
    elseif ~isempty(retry)
        lagmethod(retry) = "direct_insufficient_neighbors";
    end

    % Unavailable profiles are NaN, never a mixture of old and corrected
    % coordinate transforms. A validated no-op mission keeps every L4
    % profile; its candidate correction is still audited.
    noop = platform == "28";
    if noop
        action = "kept_original_valid_ahrs";
    else
        action = "applied_sbg_hpr_mag_yaw";
    end
    for iburst = find(~noop & [results.status]' == "corrected")'
        SWIFT(iburst).signature.profile = profiles{iburst};
    end
    for iburst = find(~noop & [results.status]' ~= "corrected")'
        SWIFT(iburst).signature.profile = ...
            nanSIGprofile(SWIFT(iburst).signature.profile);
    end

    % Failures stay missing; the audit records what was actually available.
    % In the accepted SWIFT26 run, 1221/1420 bursts were corrected. The
    % remaining records were short/empty SBG files (mostly a real zero-byte
    % outage), bursts after the Signature offload ended, profiles already
    % rejected for poor acoustic correlation, and indefensible time
    % matches. The CSV is authoritative.
    audit = struct2table(results);
    audit.action = repmat(action,nburst,1);
    audit.raw_time_lag_seconds = rawlag;
    audit.local_median_lag_seconds = localmedianlag;
    audit.raw_lag_departure_seconds = lagdeparture;
    audit.extrapolated_lag = extrapolatedlag;
    audit.lag_method = lagmethod;
    audit.lag_reason = lagreason;
    writetable(audit,fullfile(reviewdir,mission + "_L5_source_audit.csv"))

    params = table2struct(audit,'ToScalar',true);
    params.mount_yaw = opts.mountyaw;
    params.frame_offset = frameoffset;
    params.clocking = clocking(string(platform));
    params.world_yaw = opts.worldyaw;
    params.allow_relative_yaw = opts.allowrelativeyaw;
    params.require_valid_orientation = opts.requirevalidorientation;
    params.mag_calibration = opts.magcalibration.method;
    params.magnetic_declination = magneticdeclination;
    params.magnetic_inclination = magneticinclination;
    params.mag_calibration_window_days = magcalibrationwindow;
    params.mag_calibration_breaks = breaks;
    params.min_time_correlation = mintimecorrelation;
    params.max_time_lag_departure = maxtimelagdeparture;
    ip = length(sinfo.postproc)+1;
    sinfo.postproc(ip).type = 'fix_enu';
    sinfo.postproc(ip).usr = getenv('USER');
    sinfo.postproc(ip).time = string(datetime('now'));
    sinfo.postproc(ip).flags.status = audit.status;
    sinfo.postproc(ip).params = params;
    save(fullfile(outdir,mission,mission + "_L5.mat"),'SWIFT','sinfo');

    plotWillapaL5Review(SWIFTL4,SWIFT,audit,watchheading, ...
        opts.mountyaw,mintimecorrelation,sentinel,mission,reviewdir)
    fprintf('%s: corrected %d of %d bursts\n',mission, ...
        sum(audit.status == "corrected"),nburst)
end

set(0,'DefaultFigureVisible','on')

function sources = matchSources(SWIFT,missiondir,sigfiles,sbgfiles)
% For each burst: its Signature file, its own SBG file, and the five SBG
% files of this deployment nearest in nominal slot time. Prefer the largest
% file when both a partial and full file exist.
prefix = "SWIFT" + SWIFT(1).ID;
sigfiles = sigfiles(startsWith({sigfiles.name},prefix + "_SIG_"));
sbgfiles = sbgfiles(startsWith({sbgfiles.name},prefix + "_SBG_"));
sigpaths = string(fullfile({sigfiles.folder},{sigfiles.name}));
sbgpaths = string(fullfile({sbgfiles.folder},{sbgfiles.name}));
missionsbg = sort(sbgpaths(startsWith(sbgpaths,missiondir)));
% Nominal slot times only find nearby files; physical matching uses the
% reconstructed SBG UTC.
sbgkey = arrayfun(@burstNameToDatenum,missionsbg);

for iburst = length(SWIFT):-1:1
    burstID = string(SWIFT(iburst).burstID);
    source = struct('burstID',burstID,'status',"",'sig',"",'exactsbg',"", ...
        'sbg',strings(1,0),'sbgkey',[],'burstkey',burstNameToDatenum(burstID));
    issig = contains(sigpaths,burstID);
    issbg = contains(sbgpaths,burstID);
    [~,ibig] = max([sigfiles(issig).bytes]);
    sig = sigpaths(issig);
    sig = sig(ibig);
    [~,ibig] = max([sbgfiles(issbg).bytes]);
    sbg = sbgpaths(issbg);
    sbg = sbg(ibig);
    if isempty(sig) && isempty(sbg)
        source.status = "missing_sig_sbg";
    elseif isempty(sig)
        source.status = "missing_sig";
    elseif isempty(missionsbg)
        source.sig = sig;
        source.status = "missing_sbg";
    else
        source.sig = sig;
        if ~isempty(sbg); source.exactsbg = sbg; end
        [~,ineighbor] = sort(abs(sbgkey-source.burstkey));
        ineighbor = ineighbor(1:min(5,end));
        source.sbg = missionsbg(ineighbor);
        source.sbgkey = sbgkey(ineighbor);
    end
    sources(iburst,1) = source;
end
end

function profile = nanSIGprofile(profile)
blank = NaN(size(profile.w));
for field = ["east","north","w","uvar","vvar","wvar","spd_alt"]
    profile.(field) = blank;
end
end
