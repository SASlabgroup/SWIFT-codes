% Fix Signature ENU data on Willapa SWIFTs
%
% One-off processing for the June 2025 Willapa moorings. Input data are
% read from the local archive; L5 products, a per-burst source/failure audit,
% and mission review plots are written to the Willapa analysis repository.
% The source archive is not modified. This mission-specific script keeps its
% processing options local so it does not depend on the SEAFAC options file.

if ispc
    slash = '\';
else
    slash = '/';
end

%% Willapa paths and options

if ~exist('expdir','var') || isempty(expdir)
    if ispc
        expdir = 'S:\Willapa\Jun2025\MooredSWIFTS';
    else
        archivepaths = {'/Volumes/PortableSSD/MooredSWIFTS', ...
            '/Volumes/PortableSSD/Willapa/MooredSWIFTS'};
        iexp = find(cellfun(@isfolder,archivepaths),1);
        if isempty(iexp)
            error('Local Willapa MooredSWIFTS archive is not mounted.')
        end
        expdir = archivepaths{iexp};
    end
end
if ~exist('outdir','var') || isempty(outdir)
    outdir = '/Users/mleclair/Dropbox/phd/code/willapa_analysis/data/moorings/SWIFT';
end

% Common SBG-to-Signature mounting correction supplied to fixSIGenu.
if ~exist('hoffgiven','var'); hoffgiven = 45; end
% SWIFT24's raw SBG heading is consistently about 90--110 degrees from its
% deployment-specific watch-circle bearing, unlike SWIFT22/23. Add a
% provisional 90-degree platform correction on top of the common 45-degree
% mounting correction, but root cause the SWIFT24 mounting/configuration
% difference before reusing it.
if ~exist('swift24extra','var'); swift24extra = 90; end
% SWIFT26's SBG stayed almost entirely in vertical-gyro mode, so its yaw is
% anchored to the watch circle below rather than treated as geographic.
% Apply one clockwise mounting quadrant in addition to the common built-in
% offset: +45 - 90 = -45 degrees. Sensors can be installed in 90-degree
% increments; retain this as a mission-specific provisional mounting choice
% until the SWIFT26 installation is independently confirmed.
% The accepted 9 Oct 2026 validation gave L4 PC1 = 156.2 degrees, watch-circle
% axial mean = 159.2 degrees, and L5 PC1 = 163.6 degrees (84% of variance).
if ~exist('swift26extra','var'); swift26extra = -90; end
% Future SWIFT26 SBG-outage recovery (not implemented here): synchronized
% good bursts give a stable Signature-gyro to SBG-gyro rotation of about
% [-48.5 -0.5 0.9] degrees (ZYX), with held-out axis correlations of
% 0.98--0.99. A new attitude filter could rotate the raw Signature gyro and
% accelerometer into the SBG frame, then anchor yaw to the watch circle.
% Do not simply rotate the onboard Signature AHRS: a held-out trial retained
% large heading outliers because that is the faulty solution being replaced.

% Reconstruct the SBG clock from valid UTC packets, then combine nearby
% files and select their samples by physical time. Exact filenames do not
% always contain the same acquisition minutes on this deployment.
if ~exist('relativebursttime','var'); relativebursttime = true; end
if ~exist('mintimecorrelation','var'); mintimecorrelation = 0.8; end
if ~exist('maxtimelagdeparture','var'); maxtimelagdeparture = 3; end

% Handling for an SBG operating without absolute heading. The
% low nibble of EkfEuler.solution_status is the SBG solution mode. SWIFT26
% is in mode 1 (vertical gyro) for 99.5% of samples and SWIFT28 for 100%,
% while the other usable Willapa SBGs mostly reach modes 2/4
% (AHRS/navigation). In mode 1, roll/pitch remain useful, but yaw restarts
% near zero in each record and has no absolute reference. This correction
% retains the relative yaw motion (which still requires validation) and
% anchors each record's circular-mean yaw to the GPS watch-circle bearing.
% Apply this to SWIFT26 by default; SWIFT28 retains its valid Signature AHRS.
if ~exist('watchanchormissions','var')
    watchanchormissions = {'SWIFT26_16-27Jun2025'};
end
if ~exist('watchanchormethod','var'); watchanchormethod = 'mean'; end

% Burst diagnostic plots: -1 disables them, 1 plots every burst, and N>1
% plots the first burst and every Nth burst after it. Mission summaries are
% always saved.
if ~exist('plotevery','var'); plotevery = -1; end

% Process independent bursts on the local parallel pool when available.
% Debug plotting remains serial because figure creation/export dominates the
% burst runtime and is not reliable on workers.
if ~exist('parallelbursts','var'); parallelbursts = true; end
if ~exist('parallelworkers','var'); parallelworkers = 8; end
if ~exist('requirecomplete','var'); requirecomplete = true; end

% SWIFT28 has a healthy Signature AHRS: its original heading follows the
% watch circle and its L4 currents retain a strong, channelized M2 signal.
% Still run the candidate correction for the audit, but keep L4 unchanged.
if ~exist('noopmissions','var')
    noopmissions = {'SWIFT28_20-21Jun2025'};
end
hasparallel = ~isempty(ver('parallel')) && ...
    license('test','Distrib_Computing_Toolbox');
useparallel = parallelbursts && hasparallel && plotevery < 0;
if parallelbursts && ~hasparallel
    warning('Parallel toolbox unavailable; processing bursts serially.')
elseif parallelbursts && plotevery > 0
    warning('Burst plotting requested; processing bursts serially.')
end
if useparallel
    pool = gcp('nocreate');
    if isempty(pool)
        parpool('Processes',parallelworkers);
    elseif pool.NumWorkers ~= parallelworkers
        warning('Using existing parallel pool with %d workers.',pool.NumWorkers)
    end
end

% These are the broadband options used by reprocess_SIG. Defining them
% here removes the old mission-external SIGopt_SEAFAC dependency.
sigopt.xz = 0.2;
sigopt.plotburst = true;
sigopt.avg.QCbin = true;
sigopt.avg.mincorr = 50;
sigopt.avg.QCfish = true;

missions = dir([expdir slash 'SWIFT2*']);
missions = missions([missions.isdir]);
missions = missions(~contains({missions.name},'directoffload'));
if exist('missionnames','var') && ~isempty(missionnames)
    missions = missions(ismember({missions.name},missionnames));
end

% Index raw files once. Repeating recursive directory searches for every
% burst is much slower and does not change the processing itself.
sigfiles = dir([expdir slash '**' slash 'SWIFT*_SIG_*.mat']);
sbgfiles = dir([expdir slash '**' slash 'SWIFT*_SBG_*.mat']);
sigfiles = sigfiles(~startsWith({sigfiles.name},'._'));
sbgfiles = sbgfiles(~startsWith({sbgfiles.name},'._'));
sigpaths = string(fullfile({sigfiles.folder},{sigfiles.name}));
sbgpaths = string(fullfile({sbgfiles.folder},{sbgfiles.name}));

set(0,'DefaultFigureVisible','off')

%% Loop through missions and recalculate broadband profiles

for im = 1:length(missions)

    missiondir = [missions(im).folder slash missions(im).name];
    missionout = [outdir slash missions(im).name];
    reviewdir = [missionout slash 'L5_review'];
    if ~exist(missionout,'dir'); mkdir(missionout); end
    if ~exist(reviewdir,'dir'); mkdir(reviewdir); end

    % L4 file
    L4file = dir([missiondir slash '*L4.mat']);
    L4file = L4file(~startsWith({L4file.name},'._'));
    if isempty(L4file)
        disp(['No L4 file for ' missions(im).name '. Skipping...'])
        continue
    end
    load([L4file.folder slash L4file.name],'SWIFT','sinfo');
    SWIFTL4 = SWIFT;
    noopmission = ismember(missions(im).name,noopmissions);
    watchanchoryaw = ismember(missions(im).name,watchanchormissions);
    platformhoff = 0;
    if strcmp(SWIFT(1).ID,'24'); platformhoff = swift24extra; end
    missionhoff = hoffgiven + platformhoff;
    if watchanchoryaw && strcmp(SWIFT(1).ID,'26')
        missionhoff = hoffgiven + swift26extra;
    end
    watchtime = [SWIFT.time]';
    watchheading = watchCircleBearing(watchtime,[SWIFT.lat]',[SWIFT.lon]', ...
        missions(im).name);

    % Match source files before processing. This is fast, avoids broadcasting
    % the archive-wide file index to every worker, and preserves audit rows
    % for bursts that cannot be processed.
    nburst = length(SWIFT);
    toff = NaN(nburst,1);
    tlag = NaN(nburst,1);
    hoff = NaN(nburst,1);
    mheading = NaN(nburst,1);
    mpitch = NaN(nburst,1);
    mroll = NaN(nburst,1);
    nbadmatrix = NaN(nburst,1);
    timesource = strings(nburst,1);
    effectivetimeoffset = NaN(nburst,1);
    lagcorrelation = NaN(nburst,1);
    lagoverlapsamples = NaN(nburst,1);
    orientationcoverage = NaN(nburst,1);
    sbgrecordsused = NaN(nburst,1);
    usedinterpolatedlag = false(nburst,1);
    rawtimelagseconds = NaN(nburst,1);
    localmedianlagseconds = NaN(nburst,1);
    rawlagdepartureseconds = NaN(nburst,1);
    extrapolatedlag = false(nburst,1);
    lagmethod = strings(nburst,1);
    lagreason = strings(nburst,1);
    profile_rms_change = NaN(nburst,1);
    profile_max_change = NaN(nburst,1);
    meanquality = NaN(nburst,1);
    qualityprofile = cell(nburst,1);
    watchyawoffset = NaN(nburst,1);
    watchanchoredrecords = zeros(nburst,1);
    status = strings(nburst,1);
    sigsource = strings(nburst,1);
    sbgsource = strings(nburst,1);
    sbgsources = cell(nburst,1);
    sbgsourcecount = zeros(nburst,1);
    sbgsourcefiles = strings(nburst,1);
    exactsbgmissing = false(nburst,1);

    missionSBG = sbgfiles(startsWith(string({sbgfiles.folder}), ...
        string(missiondir)));
    [~,isort] = sort(string(fullfile({missionSBG.folder},{missionSBG.name})));
    missionSBG = missionSBG(isort);

    disp(['Processing ' missions(im).name ' (' num2str(nburst) ' bursts)'])

    for iburst = 1:nburst
        burstID = SWIFT(iburst).burstID;
        sigmatch = contains(sigpaths,['SWIFT' SWIFT(iburst).ID '_SIG_']) & ...
            contains(sigpaths,burstID);
        sbgmatch = contains(sbgpaths,['SWIFT' SWIFT(iburst).ID '_SBG_']) & ...
            contains(sbgpaths,burstID);
        sigfile = sigfiles(sigmatch);
        sbgfile = sbgfiles(sbgmatch);

        % Prefer the largest file when both a partial and full file exist.
        if length(sigfile) > 1
            [~,ibig] = max([sigfile.bytes]);
            sigfile = sigfile(ibig);
        end
        if length(sbgfile) > 1
            [~,ibig] = max([sbgfile.bytes]);
            sbgfile = sbgfile(ibig);
        end

        if isempty(sigfile)
            if isempty(sbgfile); status(iburst) = "missing_sig_sbg";
            else; status(iburst) = "missing_sig";
            end
            continue
        end

        sigsource(iburst) = string([sigfile.folder slash sigfile.name]);
        if isempty(sbgfile)
            exactsbgmissing(iburst) = true;
        else
            sbgsource(iburst) = string([sbgfile.folder slash sbgfile.name]);
        end
        platformSBG = missionSBG(contains({missionSBG.name}, ...
            ['SWIFT' SWIFT(iburst).ID '_SBG_']));
        platformpaths = string(fullfile({platformSBG.folder},{platformSBG.name}));
        if isempty(platformpaths)
            status(iburst) = "missing_sbg";
            continue
        end
        platformkey = arrayfun(@(x) sourceBurstKey(x),string({platformSBG.name}));
        targetkey = sourceBurstKey(string(burstID));
        [~,ineighbor] = sort(abs(platformkey-targetkey));
        ineighbor = ineighbor(1:min(5,length(ineighbor)));
        sbgsources{iburst} = platformpaths(ineighbor);
        sbgsourcecount(iburst) = length(sbgsources{iburst});
        sbgsourcefiles(iburst) = strjoin(sbgsources{iburst},';');
    end

    action = repmat("applied_sbg_hpr",nburst,1);
    if watchanchoryaw
        action(:) = "applied_sbg_hpr_watch_yaw";
        disp('Anchoring relative SBG yaw to the GPS watch circle')
    end
    if noopmission
        action(:) = "kept_original_valid_ahrs";
        disp(['Keeping original Signature AHRS profiles for ' ...
            missions(im).name ' (validated no-op mission)'])
    end

    burstresult = cell(nburst,1);
    if useparallel
        parfor iburst = 1:nburst
            makeplot = false;
            burstresult{iburst} = processBurst(SWIFT(iburst),status(iburst), ...
                sigsource(iburst),sbgsources{iburst},sigopt,missionhoff, ...
                relativebursttime,[],makeplot,reviewdir,slash,false, ...
                watchanchoryaw,watchtime,watchheading,watchanchormethod);
        end
    else
        for iburst = 1:nburst
            makeplot = plotevery > 0 && mod(iburst-1,plotevery) == 0;
            burstresult{iburst} = processBurst(SWIFT(iburst),status(iburst), ...
                sigsource(iburst),sbgsources{iburst},sigopt,missionhoff, ...
                relativebursttime,[],makeplot,reviewdir,slash,true, ...
                watchanchoryaw,watchtime,watchheading,watchanchormethod);
        end
    end

    % A weak or corrupt gyro record can still give xcorr a false peak. Use
    % the neighboring high-correlation bursts to estimate only those lags.
    % This follows platform/deployment timing changes instead of assuming a
    % fixed recorder offset.
    firstlag = NaN(nburst,1);
    firstcorr = NaN(nburst,1);
    for iburst = 1:nburst
        if ~isempty(burstresult{iburst}.cparams)
            firstlag(iburst) = burstresult{iburst}.cparams.tlag*24*60*60;
            firstcorr(iburst) = burstresult{iburst}.cparams.lagcorrelation;
        end
    end
    localmedianlag = movmedian(firstlag,13,'omitnan');
    goodtime = firstcorr >= mintimecorrelation & ...
        abs(firstlag-localmedianlag) <= maxtimelagdeparture;
    retry = find(isfinite(firstlag) & ~goodtime);
    rawtimelagseconds = firstlag;
    localmedianlagseconds = localmedianlag;
    rawlagdepartureseconds = abs(firstlag-localmedianlag);
    lagmethod(goodtime) = "direct";
    lagreason(goodtime) = "accepted";
    lowcorr = isfinite(firstlag) & firstcorr < mintimecorrelation;
    lagoutlier = isfinite(firstlag) & ...
        rawlagdepartureseconds > maxtimelagdeparture;
    lagreason(lowcorr) = "low_correlation";
    lagreason(lagoutlier) = "local_outlier";
    lagreason(lowcorr & lagoutlier) = "low_correlation+local_outlier";
    if length(find(goodtime)) >= 2 && ~isempty(retry)
        goodindices = find(goodtime);
        localtimelag = interp1(goodindices,firstlag(goodtime), ...
            (1:nburst)','linear','extrap');
        disp(['Using neighboring gyro lags for ' num2str(length(retry)) ...
            ' weak-correlation bursts'])
        retryresult = cell(length(retry),1);
        % Keep this small corrective pass serial. Starting a second parfor
        % against the same source files can leave process-pool workers idle.
        for ir = 1:length(retry)
            iburst = retry(ir);
            makeplot = ~useparallel && plotevery > 0 && ...
                mod(iburst-1,plotevery) == 0;
            retryresult{ir} = processBurst(SWIFT(iburst),status(iburst), ...
                sigsource(iburst),sbgsources{iburst},sigopt,missionhoff, ...
                relativebursttime,localtimelag(iburst),makeplot, ...
                reviewdir,slash,~useparallel,watchanchoryaw,watchtime, ...
                watchheading,watchanchormethod);
        end
        for ir = 1:length(retry)
            if retryresult{ir}.status == "corrected"
                burstresult{retry(ir)} = retryresult{ir};
                if retry(ir) < goodindices(1) || retry(ir) > goodindices(end)
                    lagmethod(retry(ir)) = "extrapolated";
                    extrapolatedlag(retry(ir)) = true;
                else
                    lagmethod(retry(ir)) = "interpolated";
                end
            else
                lagmethod(retry(ir)) = "direct_retry_failed";
            end
        end
    elseif ~isempty(retry)
        lagmethod(retry) = "direct_insufficient_neighbors";
    end

    % Merge in burst order so parallel and serial runs create the same L5.
    for iburst = 1:nburst
        result = burstresult{iburst};
        status(iburst) = result.status;
        meanquality(iburst) = result.meanquality;
        qualityprofile{iburst} = result.qualityprofile;
        if result.status ~= "corrected"
            % Match the original one-off behavior for explicitly requested
            % partial/debug products: unavailable profiles are NaN, never a
            % mixture of old and corrected coordinate transforms.
            SWIFT(iburst).signature.profile = ...
                nanSIGprofile(SWIFT(iburst).signature.profile);
            continue
        end

        profile = result.profile;
        SWIFT(iburst).signature.profile = [];
        SWIFT(iburst).signature.profile.east = profile.u;
        SWIFT(iburst).signature.profile.north = profile.v;
        SWIFT(iburst).signature.profile.w = profile.w;
        SWIFT(iburst).signature.profile.uvar = profile.uvar;
        SWIFT(iburst).signature.profile.vvar = profile.vvar;
        SWIFT(iburst).signature.profile.wvar = profile.wvar;
        SWIFT(iburst).signature.profile.z = profile.z;
        SWIFT(iburst).signature.profile.spd_alt = profile.spd_alt;

        profile_rms_change(iburst) = result.profile_rms_change;
        profile_max_change(iburst) = result.profile_max_change;
        toff(iburst) = result.cparams.toff;
        tlag(iburst) = result.cparams.tlag;
        hoff(iburst) = result.cparams.hoff;
        mheading(iburst) = result.cparams.mheading;
        mpitch(iburst) = result.cparams.mpitch;
        mroll(iburst) = result.cparams.mroll;
        nbadmatrix(iburst) = result.cparams.nbadmatrix;
        timesource(iburst) = result.cparams.timesource;
        effectivetimeoffset(iburst) = result.cparams.effectivetimeoffset;
        lagcorrelation(iburst) = result.cparams.lagcorrelation;
        lagoverlapsamples(iburst) = result.cparams.lagoverlapsamples;
        orientationcoverage(iburst) = result.cparams.orientationcoverage;
        sbgrecordsused(iburst) = result.cparams.sbgtimeinfo.recordsused;
        usedinterpolatedlag(iburst) = result.cparams.usedinterpolatedlag;
        watchyawoffset(iburst) = result.watchyawoffset;
        watchanchoredrecords(iburst) = result.watchanchoredrecords;
    end

    % Keep the candidate metrics above for the audit, but a validated no-op
    % mission must retain every original L4 Signature profile.
    if noopmission; SWIFT = SWIFTL4; end

    if isfield(sinfo,'postproc')
        ip = length(sinfo.postproc)+1;
    else
        sinfo.postproc = struct;
        ip = 1;
    end
    sinfo.postproc(ip).type = 'fix_enu';
    sinfo.postproc(ip).usr = getenv('USER');
    sinfo.postproc(ip).time = string(datetime('now'));
    sinfo.postproc(ip).flags.status = status;
    sinfo.postproc(ip).params.action = action;
    sinfo.postproc(ip).params.toff = toff;
    sinfo.postproc(ip).params.tlag = tlag;
    sinfo.postproc(ip).params.hoff = hoff;
    sinfo.postproc(ip).params.hoffgiven = missionhoff;
    sinfo.postproc(ip).params.base_heading_offset = hoffgiven;
    sinfo.postproc(ip).params.platform_heading_offset = platformhoff;
    sinfo.postproc(ip).params.mheading = mheading;
    sinfo.postproc(ip).params.mpitch = mpitch;
    sinfo.postproc(ip).params.mroll = mroll;
    sinfo.postproc(ip).params.nbadmatrix = nbadmatrix;
    sinfo.postproc(ip).params.relativebursttime = relativebursttime;
    sinfo.postproc(ip).params.mintimecorrelation = mintimecorrelation;
    sinfo.postproc(ip).params.maxtimelagdeparture = maxtimelagdeparture;
    sinfo.postproc(ip).params.timesource = timesource;
    sinfo.postproc(ip).params.effectivetimeoffset = effectivetimeoffset;
    sinfo.postproc(ip).params.lagcorrelation = lagcorrelation;
    sinfo.postproc(ip).params.lagoverlapsamples = lagoverlapsamples;
    sinfo.postproc(ip).params.orientationcoverage = orientationcoverage;
    sinfo.postproc(ip).params.sbgrecordsused = sbgrecordsused;
    sinfo.postproc(ip).params.usedinterpolatedlag = usedinterpolatedlag;
    sinfo.postproc(ip).params.watchanchoryaw = watchanchoryaw;
    sinfo.postproc(ip).params.watchanchormethod = watchanchormethod;
    sinfo.postproc(ip).params.watchyawoffset = watchyawoffset;
    sinfo.postproc(ip).params.watchanchoredrecords = watchanchoredrecords;
    sinfo.postproc(ip).params.rawtimelagseconds = rawtimelagseconds;
    sinfo.postproc(ip).params.localmedianlagseconds = localmedianlagseconds;
    sinfo.postproc(ip).params.rawlagdepartureseconds = rawlagdepartureseconds;
    sinfo.postproc(ip).params.extrapolatedlag = extrapolatedlag;
    sinfo.postproc(ip).params.lagmethod = lagmethod;
    sinfo.postproc(ip).params.lagreason = lagreason;
    sinfo.postproc(ip).params.profile_rms_change = profile_rms_change;
    sinfo.postproc(ip).params.profile_max_change = profile_max_change;
    sinfo.postproc(ip).params.meanquality = meanquality;
    sinfo.postproc(ip).source.sig = sigsource;
    sinfo.postproc(ip).source.sbg = sbgsource;
    sinfo.postproc(ip).source.sbgfiles = sbgsourcefiles;

    % Preserve failures as missing and record what was actually available;
    % do not manufacture profiles from an unverified fallback. In the
    % accepted SWIFT26 run, 1226/1420 bursts were corrected. The remaining
    % records were 113 short/empty SBG files (mostly a real zero-byte outage),
    % 52 bursts after the Signature offload ended, 16 profiles already
    % rejected for poor acoustic correlation, and 13 indefensible time
    % matches. Re-running may change these counts, so the CSV is authoritative.
    audit = table(string({SWIFT.burstID})',status,action,sigsource,sbgsource, ...
        sbgsourcecount,sbgsourcefiles,exactsbgmissing, ...
        profile_rms_change,profile_max_change,toff,tlag,effectivetimeoffset, ...
        timesource,lagcorrelation,lagoverlapsamples,orientationcoverage, ...
        sbgrecordsused,usedinterpolatedlag,rawtimelagseconds, ...
        localmedianlagseconds,rawlagdepartureseconds,extrapolatedlag, ...
        lagmethod,lagreason,hoff,mheading,nbadmatrix,meanquality, ...
        watchyawoffset,watchanchoredrecords, ...
        'VariableNames',{'burstID','status','action','sig_source','sbg_source', ...
        'sbg_source_count','sbg_source_files','exact_sbg_missing', ...
        'profile_rms_change','profile_max_change','time_offset', ...
        'time_lag','effective_time_offset_seconds','time_source', ...
        'lag_correlation','lag_overlap_samples','orientation_coverage', ...
        'sbg_records_used','used_interpolated_lag','raw_time_lag_seconds', ...
        'local_median_lag_seconds','raw_lag_departure_seconds', ...
        'extrapolated_lag','lag_method','lag_reason','heading_offset','mean_heading', ...
        'bad_ahrs_matrix_pings','mean_broadband_correlation', ...
        'watch_yaw_offset','watch_anchored_records'});
    writetable(audit,[reviewdir slash missions(im).name '_L5_source_audit.csv'])

    if requirecomplete && ~noopmission && any(status ~= "corrected")
        error('%s is incomplete: corrected %d of %d bursts. Audit written; L5 not saved.', ...
            missions(im).name,sum(status == "corrected"),nburst)
    end

    L5file = [missionout slash missions(im).name '_L5.mat'];
    save(L5file,'SWIFT','sinfo');

    % Save mission-level comparison plots for review
    swiftL4 = catSWIFT(SWIFTL4);
    swiftL5 = catSWIFT(SWIFT);
    sigquality = NaN(size(swiftL4.relu));
    for iburst = 1:nburst
        nq = min(size(sigquality,1),length(qualityprofile{iburst}));
        if nq > 0
            sigquality(1:nq,iburst) = qualityprofile{iburst}(1:nq);
        end
    end
    if noopmission
        l5easttitle = 'L5 East Velocity (Original Retained)';
        l5northtitle = 'L5 North Velocity (Original Retained)';
        l5speedtitle = 'L5 Burst-Avg Speed (Original Retained)';
    else
        l5easttitle = 'Fixed East Velocity';
        l5northtitle = 'Fixed North Velocity';
        l5speedtitle = 'Fixed Burst-Avg Speed';
    end

    fh = figure('Color','w','Position',[50 50 1400 1700]);
    theme(fh,'light')
    ax(1) = subplot(9,1,1);
    finaltimelagseconds = tlag*24*60*60;
    yyaxis left
    hold on
    hraw = plot(swiftL5.time,rawtimelagseconds,'.', ...
        'Color',[0.7 0.7 0.7],'DisplayName','Raw lag estimate');
    hmedian = plot(swiftL5.time,localmedianlagseconds,'-k', ...
        'LineWidth',0.8,'DisplayName','Local median');
    directlag = startsWith(lagmethod,"direct");
    hinterpolated = lagmethod == "interpolated";
    hextrapolated = lagmethod == "extrapolated";
    hdirect = plot(swiftL5.time(directlag), ...
        finaltimelagseconds(directlag),'.','Color',[0 0.45 0.74], ...
        'DisplayName','Applied direct lag');
    hinterp = plot(swiftL5.time(hinterpolated), ...
        finaltimelagseconds(hinterpolated),'o','MarkerSize',3, ...
        'Color',[0.85 0.33 0.1],'DisplayName','Applied interpolated lag');
    hextrap = plot(swiftL5.time(hextrapolated), ...
        finaltimelagseconds(hextrapolated),'x','MarkerSize',4, ...
        'Color',[0.64 0.08 0.18],'DisplayName','Applied extrapolated lag');
    ylabel('lag [s]')
    yyaxis right
    hcorr = plot(swiftL5.time,lagcorrelation,'.','MarkerSize',3, ...
        'Color',[0.35 0.35 0.35],'DisplayName','Gyro correlation');
    hthreshold = yline(mintimecorrelation,':','Color',[0.45 0.45 0.45], ...
        'DisplayName','Correlation threshold');
    ylabel('correlation'); ylim([-0.05 1.05])
    title([missions(im).name ' SIG/SBG Gyro Lag'],'Interpreter','none')
    legend([hraw hmedian hdirect hinterp hextrap hcorr hthreshold], ...
        'Location','best','NumColumns',4)

    ax(2) = subplot(9,1,2);
    if isfield(swiftL4,'echo') && isfield(swiftL4,'echoz')
        pcolor(swiftL4.time,swiftL4.echoz,swiftL4.echo); shading flat
        ylabel('Z [m]');
        ylim([0 max(swiftL4.depth,[],'all','omitnan')]);
        finiteecho = swiftL4.echo(isfinite(swiftL4.echo));
        if ~isempty(finiteecho); clim(prctile(finiteecho,[5 99])); end
        colormap(ax(2),cmocean('amp')); c = colorbar;
        c.Label.String = 'A [dB]';
    else
        text(0.5,0.5,'No echo data','Units','normalized', ...
            'HorizontalAlignment','center')
        ylabel('Z [m]')
    end
    title('Echo Intensity');

    ax(3) = subplot(9,1,3);
    pcolor(swiftL4.time,swiftL4.depth,sigquality); shading flat
    ylabel('Z [m]'); title('Mean Broadband Correlation'); clim([40 100]);
    colormap(ax(3),cmocean('amp')); c = colorbar; c.Label.String = 'C [%]';
    if any(isfinite(sigquality),'all')
        hold on; contour(swiftL4.time,swiftL4.depth,sigquality,[50 50], ...
            'k','LineWidth',0.5);
    end

    ax(4) = subplot(9,1,4);
    pcolor(swiftL4.time,swiftL4.depth,swiftL4.relu); shading flat
    ylabel('Z [m]'); title('Original East Velocity'); clim([-1 1]);
    colormap(ax(4),cmocean('balance')); c = colorbar;
    c.Label.String = 'U [ms^{-1}]';

    ax(5) = subplot(9,1,5);
    pcolor(swiftL4.time,swiftL4.depth,swiftL4.relv); shading flat
    ylabel('Z [m]'); title('Original North Velocity'); clim([-1 1]);
    colormap(ax(5),cmocean('balance')); c = colorbar;
    c.Label.String = 'V [ms^{-1}]';

    ax(6) = subplot(9,1,6);
    pcolor(swiftL4.time,swiftL4.depth,swiftL4.spd_alt); shading flat
    ylabel('Z [m]'); title('Original Burst-Avg Speed'); clim([0 1]);
    c = colorbar; c.Label.String = '|U| [ms^{-1}]';

    ax(7) = subplot(9,1,7);
    pcolor(swiftL5.time,swiftL5.depth,swiftL5.relu); shading flat
    ylabel('Z [m]'); title(l5easttitle); clim([-1 1]);
    colormap(ax(7),cmocean('balance')); c = colorbar;
    c.Label.String = 'U [ms^{-1}]';

    ax(8) = subplot(9,1,8);
    pcolor(swiftL5.time,swiftL5.depth,swiftL5.relv); shading flat
    ylabel('Z [m]'); title(l5northtitle); clim([-1 1]);
    colormap(ax(8),cmocean('balance')); c = colorbar;
    c.Label.String = 'V [ms^{-1}]';

    ax(9) = subplot(9,1,9);
    pcolor(swiftL5.time,swiftL5.depth,swiftL5.spd_alt); shading flat
    ylabel('Z [m]'); title(l5speedtitle); clim([0 1]);
    c = colorbar; c.Label.String = '|U| [ms^{-1}]';

    % Overlay the burst altimeter return on every depth-resolved panel. A
    % black underlay keeps the thin white line visible on every colormap.
    if isfield(swiftL4,'altz')
        altzplot = swiftL4.altz;
    else
        altzplot = NaN(size(swiftL4.time));
    end
    altzplot(altzplot <= 0) = NaN;
    for iax = 2:9
        hold(ax(iax),'on')
        plot(ax(iax),swiftL4.time,altzplot,'k-','LineWidth',1.5)
        plot(ax(iax),swiftL4.time,altzplot,'w-','LineWidth',0.7)
    end

    set(ax(2:9),'YDir','Reverse')
    set(ax(1:8),'XTickLabel',[])
    linkaxes(ax,'x'); set(ax,'XLim',[min(swiftL5.time) max(swiftL5.time)])
    datetick(ax(9),'x','mm/dd','keeplimits')
    print(fh,[reviewdir slash missions(im).name '_L4_L5_comparison'], ...
        '-dpng','-r150')
    close(fh)

    % Geographic principal axes and 10-degree direction histograms of the
    % depth-median flow. The inner heatmap ring is L4 and the outer is L5;
    % both watch-circle heading clusters are overlaid on Sentinel-2 imagery.
    maplon = mod(swiftL5.lon+180,360)-180;
    watchheading = watchCircleBearing(swiftL5.time,swiftL5.lat,swiftL5.lon, ...
        missions(im).name);
    goodwatch = isfinite(watchheading);
    watchmeans = NaN(2,1);
    if sum(goodwatch) >= 2
        watchvalues = watchheading(goodwatch);
        watchxy = [sind(watchvalues(:)) cosd(watchvalues(:))];
        [~,watchcenters] = kmeans(watchxy,2,'Replicates',20);
        watchcenters = watchcenters./vecnorm(watchcenters,2,2);
        watchmeans = sort(mod(atan2d(watchcenters(:,1), ...
            watchcenters(:,2)),360));
        fprintf('%s watch-circle heading k-means: %.1f, %.1f degrees\n', ...
            missions(im).name,watchmeans(1),watchmeans(2))
    end
    currentu = [median(swiftL4.relu,1,'omitnan'); ...
        median(swiftL5.relu,1,'omitnan')];
    currentv = [median(swiftL4.relv,1,'omitnan'); ...
        median(swiftL5.relv,1,'omitnan')];
    pcvectors = NaN(2,2,2);
    pcstd = NaN(2,2);
    pcpercent = NaN(2,2);
    for iproduct = 1:2
        goodcurrent = isfinite(currentu(iproduct,:)) & ...
            isfinite(currentv(iproduct,:));
        [pcvectors(:,:,iproduct),pcvariance] = eig(cov( ...
            currentu(iproduct,goodcurrent),currentv(iproduct,goodcurrent)), ...
            'vector');
        [pcvariance,isort] = sort(pcvariance,'descend');
        pcvectors(:,:,iproduct) = pcvectors(:,isort,iproduct);
        pcstd(iproduct,:) = sqrt(pcvariance);
        pcpercent(iproduct,:) = 100*pcvariance/sum(pcvariance);
    end
    directionedges = 0:10:360;
    directionfraction = NaN(2,length(directionedges)-1);
    for iproduct = 1:2
        direction = mod(atan2d(currentu(iproduct,:), ...
            currentv(iproduct,:)),360);
        directionfraction(iproduct,:) = 100*histcounts(direction, ...
            directionedges,'Normalization','probability');
    end

    mapradius = 4000;
    mapxlimits = [-mapradius-10000 mapradius];
    mapylimits = [-mapradius-4000 mapradius+3000];
    ringradius = [500 700];
    pcscale = 0.25*mapradius/max(pcstd,[],'all');
    heatcolors = turbo(256);
    heatmax = max(directionfraction,[],'all');
    if ~exist('sentinelfile','var') || isempty(sentinelfile)
        analysisdir = fileparts(fileparts(fileparts(outdir)));
        sentinelfile = [fileparts(analysisdir) slash 'willapa_prep' slash 'data' ...
            slash 'sentinel' slash ...
            'S2B_MSIL2A_20250608T190909_N0511_R056_T10TDS_20250608T212948.SAFE' ...
            slash 'GRANULE' slash 'L2A_T10TDS_A043125_20250608T191625' slash ...
            'IMG_DATA' slash 'R10m' slash 'T10TDS_20250608T190909_TCI_10m.jp2'];
    end
    if ~exist('sentinelimage','var') || ~exist('sentinelx','var') || ...
            ~exist('sentinely','var')
        % A 40 m overview is ample at this map scale and avoids loading the
        % entire 10 m, 10980-by-10980 true-color tile for every mission.
        sentinelimage = imread(sentinelfile,'ReductionLevel',2);
        sentinelinfo = georasterinfo(sentinelfile);
        sentinelref = sentinelinfo.RasterReference;
        sentinelx = linspace(sentinelref.XWorldLimits(1), ...
            sentinelref.XWorldLimits(2),size(sentinelimage,2));
        sentinely = linspace(sentinelref.YWorldLimits(2), ...
            sentinelref.YWorldLimits(1),size(sentinelimage,1));
    end
    [mapx,mapy] = projfwd(projcrs(32610),swiftL5.lat,maplon);
    meanx = mean(mapx,'omitnan');
    meany = mean(mapy,'omitnan');
    sentinelcolumns = sentinelx >= meanx+mapxlimits(1) & ...
        sentinelx <= meanx+mapxlimits(2);
    sentinelrows = sentinely >= meany+mapylimits(1) & ...
        sentinely <= meany+mapylimits(2);
    fh = figure('Color','w','Position',[50 50 1000 850]);
    theme(fh,'light')
    image(([min(sentinelx(sentinelcolumns)) max(sentinelx(sentinelcolumns))] ...
        -meanx)/1000,([min(sentinely(sentinelrows)) ...
        max(sentinely(sentinelrows))]-meany)/1000, ...
        flipud(sentinelimage(sentinelrows,sentinelcolumns,:)));
    set(gca,'YDir','normal'); hold on
    plot((mapx-meanx)/1000,(mapy-meany)/1000,'k.', ...
        'MarkerSize',7,'HandleVisibility','off')
    htrack = plot((mapx-meanx)/1000,(mapy-meany)/1000,'.', ...
        'Color',[0.95 0.95 0.95], ...
        'MarkerSize',4,'DisplayName','GPS track');

    for iproduct = 1:2
        for ibin = 1:length(directionedges)-1
            theta = linspace(directionedges(ibin)+0.4, ...
                directionedges(ibin+1)-0.4,12);
            ringx = ringradius(iproduct)*sind(theta)/1000;
            ringy = ringradius(iproduct)*cosd(theta)/1000;
            icolor = 1+round(255*directionfraction(iproduct,ibin)/heatmax);
            plot(ringx,ringy,'Color',heatcolors(icolor,:), ...
                'LineWidth',9,'HandleVisibility','off')
        end
    end

    pccolors = [0.85 0.1 0.1; 0 0.75 1];
    pclines = {'-','--'};
    for iproduct = 1:2
        for ipc = 1:2
            pcxy = pcscale*pcstd(iproduct,ipc)*pcvectors(:,ipc,iproduct);
            hpc(iproduct,ipc) = plot([-pcxy(1) pcxy(1)]/1000, ...
                [-pcxy(2) pcxy(2)]/1000,pclines{ipc}, ...
                'Color',pccolors(iproduct,:),'LineWidth',3-(ipc-1), ...
                'DisplayName',sprintf('L%d PC%d',iproduct+3,ipc));
        end
    end
    hmean = plot(0,0,'w+','MarkerSize',12, ...
        'LineWidth',2,'DisplayName','Mean position');
    watchradius = 1000;
    watchcolors = [1 0.25 0.8; 0.65 0 0.85];
    hwatch = gobjects(2,1);
    for iw = 1:2
        hwatch(iw) = plot([0 watchradius*sind(watchmeans(iw))]/1000, ...
            [0 watchradius*cosd(watchmeans(iw))]/1000,'-o', ...
            'Color',watchcolors(iw,:),'LineWidth',2.5,'MarkerSize',5, ...
            'MarkerFaceColor',watchcolors(iw,:), ...
            'DisplayName',sprintf('Watch k-mean %.0f%c', ...
            watchmeans(iw),char(176)));
    end
    axis equal; xlim(mapxlimits/1000); ylim(mapylimits/1000)
    xlabel('East of mean position [km]'); ylabel('North of mean position [km]')
    colormap(heatcolors); clim([0 heatmax])
    cb = colorbar; cb.Label.String = 'Samples per 10-degree bin [%]';
    title({[missions(im).name ' depth-median current principal axes'], ...
        sprintf(['L4 PC1 %.0f%%; L5 PC1 %.0f%% of variance; ' ...
        'inner ring = L4, outer ring = L5; Sentinel-2 2025-06-08'], ...
        pcpercent(1,1),pcpercent(2,1))},'Interpreter','none')
    legend([htrack hmean hwatch' hpc(1,1) hpc(1,2) hpc(2,1) hpc(2,2)], ...
        'Location','best')
    print(fh,[reviewdir slash missions(im).name '_L4_L5_principal_axes'], ...
        '-dpng','-r150')
    close(fh)

    fh = figure('Color','w','Position',[50 50 1400 700]);
    theme(fh,'light')
    plot(swiftL5.time,watchheading,'-k.'); hold on
    signatureheading = mod(mheading+180,360)-180;
    bodyheading = mod(signatureheading-missionhoff+180,360)-180;
    plot(swiftL5.time,bodyheading,'-r.');
    plot(swiftL5.time,signatureheading,'--','Color',[0 0.45 0.9]);
    axis tight; ylim([-180 180]); datetick('x','mm/dd','keeplimits')
    legend('Watch-circle bearing','Corrected SBG/body heading', ...
        'Applied Signature heading','Location','best')
    title([missions(im).name ' heading validation'],'interpreter','none')
    print(fh,[reviewdir slash missions(im).name '_heading_validation'], ...
        '-dpng','-r150')
    close(fh)

    fprintf('%s: corrected %d of %d bursts\n',missions(im).name, ...
        sum(status == "corrected"),nburst)

end

set(0,'DefaultFigureVisible','on')

function heading = watchCircleBearing(time,lat,lon,missionname)
% Estimate bearing from the anchor separately for each mooring interval.
% SWIFT24 20--25 June contains three anchor locations and a final recovery
% transit, so a single mean position cannot represent its watch circle.
heading = NaN(size(time));
if strcmp(missionname,'SWIFT24_20-25Jun2025')
    edges = [datenum(2025,6,21),datenum(2025,6,24,3,0,0), ...
        datenum(2025,6,25,4,30,0),datenum(2025,6,25,19,0,0)];
else
    edges = [min(time,[],'omitnan') max(time,[],'omitnan')+eps];
end
for iseg = 1:length(edges)-1
    use = time >= edges(iseg) & time < edges(iseg+1) & ...
        isfinite(lat) & isfinite(lon);
    if sum(use) < 3; continue; end
    lat0 = median(lat(use),'omitnan');
    lon0 = median(lon(use),'omitnan');
    x = (lon(use)-lon0).*cosd(lat0)*111320;
    y = (lat(use)-lat0)*110540;
    xy = [x(:) y(:)];
    xy0 = median(xy,1);
    [coeff,score] = pca(xy-xy0,'Centered',false);
    alongcenter = mean(prctile(score(:,1),[5 95]));
    crosscenter = median(score(:,2));
    center = xy0 + alongcenter*coeff(:,1)' + crosscenter*coeff(:,2)';
    heading(use) = atan2d(x-center(1),y-center(2));
end
end

function [sbgData,offset] = anchorSBGyaw(sbgData,referencetime, ...
        fallbacktime,watchtime,watchheading,anchormethod)
% Give a relative-yaw SBG record one absolute mean geographic heading.
offset = NaN;
stamp = double(sbgData.EkfEuler.time_stamp(:))/1e6;
yaw = double(sbgData.EkfEuler.yaw(:))*180/pi;
valid = isfinite(stamp) & isfinite(yaw);
if sum(valid) < 2; return; end
stamp = stamp(valid);
yaw = yaw(valid);
if strcmpi(anchormethod,'initial')
    anchorstamp = min(stamp);
    [recordheading,~] = meandir(yaw(stamp <= anchorstamp+5));
else
    anchorstamp = median(stamp);
    [recordheading,~] = meandir(yaw);
end

[merged,~] = mergeSBGdata(sbgData,referencetime);
if isempty(merged.EkfEuler.time)
    anchortime = fallbacktime+(anchorstamp-min(stamp))/86400;
elseif strcmpi(anchormethod,'initial')
    anchortime = min(merged.EkfEuler.time);
else
    anchortime = median(merged.EkfEuler.time);
end
goodwatch = isfinite(watchtime) & isfinite(watchheading);
if ~isfinite(recordheading) || ~isfinite(anchortime) || sum(goodwatch) < 2
    return
end
[uniquetime,iu] = unique(watchtime(goodwatch));
unwrappedheading = unwrap(watchheading(goodwatch)*pi/180);
targetheading = interp1(uniquetime,unwrappedheading(iu),anchortime, ...
    'linear',NaN)*180/pi;
if ~isfinite(targetheading); return; end

offset = mod(targetheading-recordheading+180,360)-180;
sbgData.EkfEuler.yaw = sbgData.EkfEuler.yaw+offset*pi/180;
end

function result = processBurst(swiftburst,status,sigsource,sbgsources, ...
        sigopt,hoffgiven,relativebursttime,forcedtimelag,makeplot,reviewdir, ...
        slash,showprogress,watchanchoryaw,watchtime,watchheading,watchanchormethod)
result.status = status;
result.profile = [];
result.cparams = [];
result.profile_rms_change = NaN;
result.profile_max_change = NaN;
result.meanquality = NaN;
result.qualityprofile = [];
result.watchyawoffset = NaN;
result.watchanchoredrecords = 0;

if showprogress
    disp(['Processing burst ' swiftburst.burstID])
end
if status ~= ""
    if showprogress; disp(['Skipping: ' char(status)]); end
    return
end

% L5 corrects the L4 coordinate transform; it must not resurrect a profile
% rejected by the standard Signature processing/QC used to create L4.
l4profile = swiftburst.signature.profile;
if ~any(isfinite(l4profile.east) & isfinite(l4profile.north))
    result.status = "invalid_l4_profile";
    if showprogress; disp('Skipping: L4 Signature profile is invalid'); end
    return
end

sigdata = load(char(sigsource),'avg','burst');
if ~isfield(sigdata,'avg') || ~isfield(sigdata,'burst') || ...
        isempty(sigdata.avg) || isempty(sigdata.burst)
    result.status = "empty_sig";
    if showprogress; disp('Skipping: SIG avg or burst data are empty'); end
    return
end

avg = sigdata.avg;
burst = sigdata.burst;
sbgData = cell(0,1);
malformedSBG = 0;
for isource = 1:length(sbgsources)
    sbgdata = load(char(sbgsources(isource)),'sbgData');
    if ~isfield(sbgdata,'sbgData') || isempty(sbgdata.sbgData)
        continue
    elseif ~validSBGdata(sbgdata.sbgData)
        malformedSBG = malformedSBG+1;
        continue
    end
    if watchanchoryaw
        referencetime = median(burst.time,'omitnan');
        fallbacktime = sourceBurstKey(sbgsources(isource));
        [sbgdata.sbgData,thisoffset] = anchorSBGyaw(sbgdata.sbgData, ...
            referencetime,fallbacktime,watchtime,watchheading,watchanchormethod);
        if isfinite(thisoffset)
            result.watchanchoredrecords = result.watchanchoredrecords+1;
            if isnan(result.watchyawoffset)
                result.watchyawoffset = thisoffset;
            else
                result.watchyawoffset = meandir([result.watchyawoffset thisoffset]);
            end
        end
    end
    sbgData{end+1,1} = sbgdata.sbgData;
end
if isempty(sbgData)
    if malformedSBG > 0
        result.status = "malformed_sbg";
    else
        result.status = "empty_sbg";
    end
    if showprogress; disp('Skipping: no usable SBG records'); end
    return
end
result.meanquality = mean(avg.CorrelationData,'all','omitnan');
result.qualityprofile = squeeze(mean(avg.CorrelationData,[1 3],'omitnan'));
if (max(burst.time)-min(burst.time))*24*60 < 4.25
    result.status = "short_sig";
    if showprogress; disp('Skipping: burst is too short'); end
    return
end
if sum(cellfun(@(x) length(x.EkfEuler.yaw),sbgData)) < 10
    result.status = "short_sbg";
    if showprogress; disp('Skipping: SBG timeseries is too short'); end
    return
end

[~,bname] = fileparts(char(sigsource));
profile_before = swiftburst.signature.profile;

% Recalculate ENU using SBG HPR.
[avgout,cparams,fh] = fixSIGenu(avg,burst,sbgData,hoffgiven,makeplot, ...
    relativebursttime,forcedtimelag);
if isempty(avgout)
    result.status = "no_time_overlap";
    return
end
if ~isempty(fh)
    theme(fh,'light')
    set(fh,'Name',[bname '_HPR_sbgfix'])
    exportgraphics(fh,[reviewdir slash get(fh,'Name') '.png'], ...
        'Resolution',100)
    close(fh)
end

% Reprocess broadband data using the standard Signature options. Note that
% processSIGavg applies beam-specific correlation/fish masks to the rotated
% ENU component slots. East and north can therefore use slightly different
% ping populations, so this step is not perfectly rotation invariant. Leave
% that general processing behavior unchanged in this Willapa one-off.
sigopt.plotburst = makeplot;
[profile,fh] = processSIGavg(avgout,sigopt);
if isempty(profile) || ~any(isfinite(profile.u) & isfinite(profile.v))
    result.status = "profile_failed";
    if ~isempty(fh); close(fh); end
    return
end
if ~isempty(fh)
    theme(fh,'light')
    set(fh,'Name',[bname '_bband_data_sbgfix'])
    exportgraphics(fh,[reviewdir slash get(fh,'Name') '.png'], ...
        'Resolution',100)
    close(fh)
end

% Recalculate alternate speed from SBG mean heading.
[~,profile.spd_alt,~] = altSIGenu(avgout,cparams.mheading);

% Near-zero values identify bursts for which the HPR correction is a no-op.
de = profile.u(:) - profile_before.east(:);
dn = profile.v(:) - profile_before.north(:);
dprofile = [de; dn];
result.profile_rms_change = sqrt(mean(dprofile.^2,'omitnan'));
result.profile_max_change = max(abs(dprofile),[],'omitnan');
result.profile = profile;
result.cparams = cparams;
result.status = "corrected";
end

function tf = validSBGdata(sbgData)
groups.EkfEuler = {'time_stamp','pitch','roll','yaw'};
groups.UtcTime = {'time_stamp','year','month','day','hour','min','sec','nanosec'};
groups.ImuData = {'time_stamp','gyro_x','gyro_y','gyro_z'};
tf = true;
names = fieldnames(groups);
for ig = 1:length(names)
    group = names{ig};
    fields = groups.(group);
    if ~isfield(sbgData,group) || ~isfield(sbgData.(group),'time_stamp')
        tf = false;
        return
    end
    ntime = length(sbgData.(group).time_stamp);
    for jf = 1:length(fields)
        if ~isfield(sbgData.(group),fields{jf}) || ...
                length(sbgData.(group).(fields{jf})) < ntime
            tf = false;
            return
        end
    end
end
end

function key = sourceBurstKey(name)
token = regexp(char(name), ...
    '(\d{2}[A-Za-z]{3}\d{4})_(\d{2})_(\d{2})','tokens','once');
if isempty(token)
    key = NaN;
    return
end
% Willapa used six nominal acquisition slots per hour. This key is only for
% finding nearby files; physical matching uses reconstructed SBG UTC.
key = datenum(token{1},'ddmmmyyyy') + str2double(token{2})/24 + ...
    (str2double(token{3})-1)/(6*24);
end

function profile = nanSIGprofile(profile)
if isfield(profile,'w')
    blank = NaN(size(profile.w));
elseif isfield(profile,'east')
    blank = NaN(size(profile.east));
else
    blank = [];
end
fields = {'east','north','w','uvar','vvar','wvar','spd_alt'};
for i = 1:length(fields)
    profile.(fields{i}) = blank;
end
end
