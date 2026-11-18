% Position + altimeter at 1-min resolution on Willapa drifting SWIFTs
% (SWIFT27-29), for high-resolution bathymetry
%
% Runs L3_highresSWIFT (K. Zeiden) on each mission's L1 product and raw
% SIG/SBG burst files, then keeps only time, position (SBG GpsPos when there
% is no PB2; solution fixes only, >= 30 per window, gaps <= 10 min
% interpolated and flagged posinterp) and the Signature altimeter (median of AltimeterDistance with
% AltimeterQuality >= 8000, pings despiked per burst). Writes <mission>_L3_highres_alt.mat into
% outdir/<mission>.
%
% Optional workspace overrides: expdir (the archive read from), outdir
% (e.g. a staging directory), missionnames (a subset of the missions below).
%
% Changelog:
% M. LeClair w/ claude, Nov 2026
% M. LeClair w/ claude, Nov 2026: minposfixes 30, keep npos, interpolate
%   missing positions across gaps <= 10 min (posinterp flag)
% M. LeClair w/ claude, Nov 2026: drop ACS out-of-water windows; iteratively
%   NaN positions with speed in and out > 10 m/s (speedfail), before
%   interpolation; save qc counts
% M. LeClair w/ claude, Nov 2026: maxposacc 10 m, altmindist 0.5 m; keep
%   altngood/altnnear
% M. LeClair w/ claude, Nov 2026: window altimeter NaN if near-field
%   fraction > 0.10 or good fraction < 0.50 (qc.altnear/altfewgood)
% M. LeClair w/ claude, Nov 2026: in-water time limits for the no-ACS
%   missions SWIFT27_18Jun2025 (16:49-22:49) and SWIFT27_19Jun2025 (< 22:30)
%   (qc.outsidetime)
% M. LeClair w/ claude, Nov 2026: SWIFT27_23-25Jun2025 ends 25 Jun 12:00
%   (grounded after)

if ~exist('expdir','var')
    expdir = '/Users/mleclair/Dropbox/phd/code/willapa_analysis/data/drifters/raw';
end
if ~exist('outdir','var')
    outdir = '/Users/mleclair/Dropbox/phd/code/willapa_analysis/data/drifters/processed/SWIFT_highres_alt';
end
if ~exist('missionnames','var')
    missionnames = ["SWIFT27_17Jun2025","SWIFT27_18Jun2025","SWIFT27_19Jun2025", ...
        "SWIFT27_21Jun2025","SWIFT27_22Jun2025","SWIFT27_23-25Jun2025", ...
        "SWIFT28_21Jun2025","SWIFT28_22-23Jun2025","SWIFT28_24Jun2025","SWIFT28_25Jun2025", ...
        "SWIFT29_18-19Jun2025","SWIFT29_20Jun2025","SWIFT29_23-24Jun2025","SWIFT29_25Jun2025"];
end

% Window length and burst length
burstdt = 1/(60*24); % datenum units (days)
sigopt.burstlength = 8.5; % [min]

% Altimeter and window QC
sigopt.altminquality = 8000;
sigopt.minpingfrac = 0.9;
sigopt.altmindist = 0.5; % [m] near-field pings dropped (counted in signature.altnnear)
% Window altimeter NaN when too many near-field pings or too few good pings
% (avg altimeter pings at 1 Hz: 60 per 1-min window)
altpingswin = 60;
altmaxnearfrac = 0.10; % altnnear/altpingswin above this: window read ~20 m shallow vs basemap
altmingoodfrac = 0.50; % altngood/altpingswin below this: scatter vs basemap grows

% Position QC: min good (solution) 5 Hz SBG fixes for a measured window
% position; missing positions are interpolated linearly in time between
% measured windows at most maxinterpgap apart, and flagged (posinterp)
sigopt.minposfixes = 30;
sigopt.maxposacc = 10; % [m] SBG horizontal pos_acc
maxinterpgap = 10/(60*24); % datenum units (days)
maxdriftspd = 10; % [m/s] isolated position jumps above this are removed (speedfail)

% In-water time limits [start end): SWIFT27_18/19 have no ACS (no out-of-water
% flag), SWIFT27_23-25 grounds on 25 Jun (stationary, altimeter constant
% ~0.8 m in salt water); set from per-burst speed, altimeter and basemap elevation
inwater = struct( ...
    'mission',{"SWIFT27_18Jun2025","SWIFT27_19Jun2025","SWIFT27_23-25Jun2025"}, ...
    'tstart',{datenum(2025,6,18,16,49,0),-Inf,-Inf}, ... % before: on deck (altimeter 0.5 m)
    'tend',{datenum(2025,6,18,22,49,0),datenum(2025,6,19,22,30,0), ...
    datenum(2025,6,25,12,0,0)}); % after: grounded/boat/dock

% Signature options used by reprocess_SIG.
sigopt.xz = 0.2;
sigopt.plotburst = false;
sigopt.fastdissipation = true;
sigopt.avg.QCbin = true;
sigopt.avg.mincorr = 50;
sigopt.avg.QCfish = true;
sigopt.HR.mincorr = 40;
sigopt.HR.QCbin = true;
sigopt.HR.pbadmax_bin = 75;
sigopt.HR.QCping = true;
sigopt.HR.pbadmax_ping = 75;
sigopt.HR.NaNbad = false;
sigopt.HR.nsumeof = 3;

for im = 1:length(missionnames)

    missiondir = fullfile(expdir,missionnames(im));
    disp(['Mission ' char(missionnames(im))])
    [SWIFThr,sinfo] = L3_highresSWIFT(char(missiondir),burstdt,sigopt,false);

    % Keep time, position and altimeter
    SWIFT = struct();
    for it = 1:length(SWIFThr)
        SWIFT(it).time = SWIFThr(it).time;
        SWIFT(it).burstID = SWIFThr(it).burstID;
        SWIFT(it).lat = SWIFThr(it).lat;
        SWIFT(it).lon = SWIFThr(it).lon;
        if isempty(SWIFT(it).lat), SWIFT(it).lat = NaN; end
        if isempty(SWIFT(it).lon), SWIFT(it).lon = NaN; end
        SWIFT(it).npos = SWIFThr(it).npos;
        SWIFT(it).posinterp = false;
        SWIFT(it).speedfail = false;
        SWIFT(it).signature.altimeter = NaN;
        SWIFT(it).signature.altngood = 0;
        SWIFT(it).signature.altnnear = 0;
        if isfield(SWIFThr(it).signature,'altimeter')
            SWIFT(it).signature.altimeter = SWIFThr(it).signature.altimeter;
            SWIFT(it).signature.altngood = SWIFThr(it).signature.altngood;
            SWIFT(it).signature.altnnear = SWIFThr(it).signature.altnnear;
        end
    end

    qc = struct('windows',length(SWIFT),'outsidetime',0,'outofwater',0,'altnear',0,'altfewgood',0, ...
        'speedfail',0,'posinterp',0);

    % Drop windows outside the mission's in-water time limits
    ilim = find([inwater.mission] == missionnames(im));
    if ~isempty(ilim) && isfield(SWIFT,'time')
        t = [SWIFT.time];
        keep = t >= inwater(ilim).tstart & t < inwater(ilim).tend;
        qc.outsidetime = nnz(~keep);
        SWIFT = SWIFT(keep);
        if isfield(sinfo,'postproc')
            iacs = find(strcmp({sinfo.postproc.type},'ACS'),1,'last');
            if ~isempty(iacs)
                sinfo.postproc(iacs).flags.outofwater = sinfo.postproc(iacs).flags.outofwater(keep);
            end
        end
    end

    % Drop windows flagged out of water (ACS salinity < 1 for > 10% of window)
    iacs = find(strcmp({sinfo.postproc.type},'ACS'),1,'last');
    if ~isempty(iacs) && isfield(SWIFT,'time')
        outofwater = logical(sinfo.postproc(iacs).flags.outofwater);
        assert(length(outofwater) == length(SWIFT),'outofwater flags do not match windows')
        qc.outofwater = nnz(outofwater);
        SWIFT = SWIFT(~outofwater);
    end

    % Window altimeter QC on ping counts (in-water windows only)
    for it = 1:length(SWIFT)*isfield(SWIFT,'signature')
        if ~isfinite(SWIFT(it).signature.altimeter), continue, end
        if SWIFT(it).signature.altnnear/altpingswin > altmaxnearfrac
            SWIFT(it).signature.altimeter = NaN;
            qc.altnear = qc.altnear + 1;
        elseif SWIFT(it).signature.altngood/altpingswin < altmingoodfrac
            SWIFT(it).signature.altimeter = NaN;
            qc.altfewgood = qc.altfewgood + 1;
        end
    end

    % Speed check: iteratively NaN the measured position whose drift speed
    % into and out of it both exceed maxdriftspd (isolated jumps)
    if isfield(SWIFT,'time') && ~isempty([SWIFT.time])
        [t,isort] = sort([SWIFT.time]);
        lat = [SWIFT.lat]; lon = [SWIFT.lon];
        lat = lat(isort); lon = lon(isort);
        while true
            ipos = find(isfinite(lat) & isfinite(lon));
            if length(ipos) < 3, break, end
            dy = deg2rad(diff(lat(ipos)))*6371e3;
            dx = deg2rad(diff(lon(ipos)))*6371e3.*cosd(lat(ipos(1:end-1)));
            spd = hypot(dx,dy)./(diff(t(ipos))*86400);
            both = min(spd(1:end-1),spd(2:end));
            [worst,k] = max(both);
            if worst <= maxdriftspd, break, end
            j = ipos(k+1);
            lat(j) = NaN; lon(j) = NaN;
            SWIFT(isort(j)).lat = NaN;
            SWIFT(isort(j)).lon = NaN;
            SWIFT(isort(j)).speedfail = true;
            qc.speedfail = qc.speedfail + 1;
        end
    end

    % Interpolate missing positions across gaps <= maxinterpgap
    if isfield(SWIFT,'time') && ~isempty([SWIFT.time])
        t = [SWIFT.time]; lat = [SWIFT.lat]; lon = [SWIFT.lon];
        [t,isort] = sort(t); lat = lat(isort); lon = lon(isort);
        imeas = find(isfinite(lat) & isfinite(lon));
        for j = find(~(isfinite(lat) & isfinite(lon)))
            iprev = imeas(find(imeas < j,1,'last'));
            inext = imeas(find(imeas > j,1,'first'));
            if isempty(iprev) || isempty(inext) || t(inext)-t(iprev) > maxinterpgap
                continue
            end
            w = (t(j)-t(iprev))/(t(inext)-t(iprev));
            it = isort(j);
            SWIFT(it).lat = lat(iprev) + w*(lat(inext)-lat(iprev));
            SWIFT(it).lon = lon(iprev) + w*(lon(inext)-lon(iprev));
            SWIFT(it).posinterp = true;
            qc.posinterp = qc.posinterp + 1;
        end
    end
    disp(qc)

    missionout =fullfile(outdir,missionnames(im));
    if ~exist(missionout,'dir'), mkdir(missionout); end
    save(fullfile(missionout,missionnames(im) + "_L3_highres_alt.mat"),'SWIFT','sinfo','sigopt','burstdt','qc')

end
