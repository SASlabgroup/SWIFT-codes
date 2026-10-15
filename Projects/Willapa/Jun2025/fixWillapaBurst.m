function [result,profile] = fixWillapaBurst(swiftburst,source,opts,forcedtimelag)
%FIXWILLAPABURST Recompute one Willapa Signature profile using SBG HPR.
%
%   [result,profile] = fixWillapaBurst(swiftburst,source,opts,forcedtimelag)
%
%   source  matched files for this burst: sig (path), sbg (nearest SBG
%           paths, nearest first), sbgkey (their nominal slot times),
%           burstkey (this burst's slot time), exactsbg (the burst's own SBG
%           file or "") and status ("" or a matching failure).
%   opts    mountyaw (Signature-to-SBG body yaw, deg), worldyaw (earth-frame
%           yaw added to the SBG heading, deg), allowrelativeyaw (rotate
%           even if the SBG EKF has no absolute heading), sigopt (processSIGavg
%           options), requirevalidorientation (mask SBG Euler samples unless
%           both attitude and heading are valid), magcalibration (3D SBG
%           magnetometer calibration, fitMagCalibration3D),
%           magneticdeclination (deg east).
%   forcedtimelag  [] or a neighbor-interpolated lag in seconds.
%
%   result is one row of the L5 source audit; profile is the corrected
%   Signature profile (empty unless result.status is "corrected").

result = emptyResult(source);
profile = [];
if result.status ~= ""; return; end

% L5 corrects the L4 coordinate transform; it must not resurrect a profile
% rejected by the standard Signature processing/QC used to create L4.
l4profile = swiftburst.signature.profile;
if ~any(isfinite(l4profile.east) & isfinite(l4profile.north))
    result.status = "invalid_l4_profile";
    return
end

sigdata = load(source.sig,'avg','burst');
if ~isfield(sigdata,'avg') || ~isfield(sigdata,'burst') || ...
        isempty(sigdata.avg) || isempty(sigdata.burst)
    result.status = "empty_sig";
    return
end
avg = sigdata.avg;
burst = sigdata.burst;

sbgData = cell(0,1);
ownslot = false;
malformed = 0;
short = 0;
unanchored = 0;
for isource = 1:length(source.sbg)
    sbgdata = load(source.sbg(isource),'sbgData');
    if ~isfield(sbgdata,'sbgData') || isempty(sbgdata.sbgData)
        continue
    elseif ~validSBGdata(sbgdata.sbgData)
        malformed = malformed+1;
        continue
    end
    if length(sbgdata.sbgData.EkfEuler.yaw) < 10
        short = short+1;
        continue
    end
    [sbgdata.sbgData,offset] = anchorSBGyawToMagnetometer(sbgdata.sbgData, ...
        opts.magcalibration,source.sbgkey(isource),opts.magneticdeclination);
    % Without its anchor a record's yaw may be relative (vertical-gyro EKF)
    % or squeezed by a stale onboard magnetometer calibration: drop it.
    if ~isfinite(offset)
        unanchored = unanchored+1;
        continue
    end
    result.mag_anchored_records = result.mag_anchored_records+1;
    result.mag_yaw_offset = meandir([result.mag_yaw_offset offset]);
    % fixSIGenu's relative-time fallback uses the first record, which must
    % be the burst's own file.
    if isempty(sbgData); ownslot = source.sbgkey(isource) == source.burstkey; end
    sbgData{end+1,1} = sbgdata.sbgData;
end
if isempty(sbgData)
    if malformed > 0
        result.status = "malformed_sbg";
    elseif unanchored > 0
        result.status = "no_mag_anchor";
    elseif short > 0
        result.status = "short_sbg";
    else
        result.status = "empty_sbg";
    end
    return
end
result.mean_broadband_correlation = mean(avg.CorrelationData,'all','omitnan');
if (max(burst.time)-min(burst.time))*24*60 < 4.25
    result.status = "short_sig";
    return
end
if sum(cellfun(@(x) length(x.EkfEuler.yaw),sbgData)) < 10
    result.status = "short_sbg";
    return
end

[avgout,cparams] = fixSIGenu(avg,burst,sbgData,opts.mountyaw,opts.worldyaw,false, ...
    ownslot,forcedtimelag,opts.allowrelativeyaw,opts.requirevalidorientation);
if isempty(avgout) && ~isempty(cparams) && cparams.relativeyaw
    result.status = "relative_sbg_yaw";
    result.vertical_gyro_fraction = cparams.verticalgyrofraction;
    return
elseif isempty(avgout)
    result.status = "no_time_overlap";
    return
end

% Retain orientation diagnostics even when validity masking leaves too few
% pings to form a profile.
result.time_offset = cparams.toff;
result.time_lag = cparams.tlag;
result.effective_time_offset_seconds = cparams.effectivetimeoffset;
result.time_source = cparams.timesource;
result.lag_correlation = cparams.lagcorrelation;
result.lag_overlap_samples = cparams.lagoverlapsamples;
result.orientation_coverage = cparams.orientationcoverage;
result.attitude_valid_fraction = cparams.attitudevalidfraction;
result.heading_valid_fraction = cparams.headingvalidfraction;
result.valid_orientation_fraction = cparams.validorientationfraction;
result.sbg_records_used = cparams.sbgtimeinfo.recordsused;
result.used_interpolated_lag = cparams.usedinterpolatedlag;
result.heading_offset = cparams.hoff;
result.mean_heading = cparams.mheading;
result.mean_pitch = cparams.mpitch;
result.mean_roll = cparams.mroll;
result.bad_ahrs_matrix_pings = cparams.nbadmatrix;
result.vertical_gyro_fraction = cparams.verticalgyrofraction;

% processSIGavg applies beam-specific correlation/fish masks to the rotated
% ENU component slots. East and north can therefore use slightly different
% ping populations, so this step is not perfectly rotation invariant.
sigprofile = processSIGavg(avgout,opts.sigopt);
if isempty(sigprofile) || ~any(isfinite(sigprofile.u) & isfinite(sigprofile.v))
    result.status = "profile_failed";
    return
end
[~,spd_alt] = altSIGenu(avgout,cparams.mheading);
profile = struct('east',sigprofile.u,'north',sigprofile.v,'w',sigprofile.w, ...
    'uvar',sigprofile.uvar,'vvar',sigprofile.vvar,'wvar',sigprofile.wvar, ...
    'z',sigprofile.z,'spd_alt',spd_alt);

% Near-zero values identify bursts for which the HPR correction is a no-op.
dprofile = [profile.east(:)-l4profile.east(:); profile.north(:)-l4profile.north(:)];
result.status = "corrected";
result.profile_rms_change = sqrt(mean(dprofile.^2,'omitnan'));
result.profile_max_change = max(abs(dprofile),[],'omitnan');
end

function result = emptyResult(source)
result.burstID = source.burstID;
result.status = source.status;
result.sig_source = source.sig;
result.sbg_source = source.exactsbg;
result.sbg_source_count = length(source.sbg);
result.sbg_source_files = strjoin(source.sbg,';');
result.exact_sbg_missing = source.exactsbg == "";
result.profile_rms_change = NaN;
result.profile_max_change = NaN;
result.time_offset = NaN;
result.time_lag = NaN;
result.effective_time_offset_seconds = NaN;
result.time_source = "";
result.lag_correlation = NaN;
result.lag_overlap_samples = NaN;
result.orientation_coverage = NaN;
result.attitude_valid_fraction = NaN;
result.heading_valid_fraction = NaN;
result.valid_orientation_fraction = NaN;
result.sbg_records_used = NaN;
result.used_interpolated_lag = false;
result.heading_offset = NaN;
result.mean_heading = NaN;
result.mean_pitch = NaN;
result.mean_roll = NaN;
result.bad_ahrs_matrix_pings = NaN;
result.vertical_gyro_fraction = NaN;
result.mean_broadband_correlation = NaN;
result.mag_yaw_offset = NaN;
result.mag_anchored_records = 0;
end

function [sbgData,offset] = anchorSBGyawToMagnetometer(sbgData,cal,sbgkey, ...
        declination)
% Give the SBG record an absolute heading from its own magnetometer. The
% onboard magnetometer calibration is stale on the Willapa SBGs and several
% EKFs ran without a magnetic reference (vertical-gyro mode), so the EKF yaw
% is either squeezed or relative. Keep the record's relative yaw motion and
% shift it so its median matches the magnetometer heading after the
% mission's 3D hard- and soft-iron calibration (fitMagCalibration3D, at the
% record's slot time sbgkey) plus the declination. NaN if the record has no
% usable magnetometer samples or no calibration covers it.
offset = NaN;
[m,d,yaw] = readSBGmag(sbgData);
if size(m,1) < 10; return; end
[center,shape] = magCalibrationAt(cal,sbgkey);
if ~isfinite(center(1)); return; end
[X,Y] = levelMagField((m-center)*shape',d);     % shape is symmetric
heading = atan2d(-Y,X) + declination;
offset = median(mod(heading-yaw+180,360)-180);
sbgData.EkfEuler.yaw = shiftYaw(sbgData.EkfEuler.yaw,offset);
end

function yaw = shiftYaw(yaw,offset)
% Add offset (deg) to SBG yaw (rad), wrapped to [-pi,pi]: mergeSBGdata and
% relativeSBGdata drop any Euler sample outside that range as corrupt
% (e.g. 1e21 rad), so an unwrapped shift would silently discard samples.
% Corrupt samples are left out of range so they are still dropped.
inrange = abs(yaw) <= pi;
yaw(inrange) = wrapToPi(yaw(inrange)+offset*pi/180);
end

function tf = validSBGdata(sbgData)
groups.EkfEuler = ["time_stamp","pitch","roll","yaw"];
groups.UtcTime = ["time_stamp","year","month","day","hour","min","sec","nanosec"];
groups.ImuData = ["time_stamp","gyro_x","gyro_y","gyro_z"];
tf = false;
for group = string(fieldnames(groups))'
    if ~isfield(sbgData,group) || ~isfield(sbgData.(group),'time_stamp')
        return
    end
    ntime = length(sbgData.(group).time_stamp);
    for field = groups.(group)
        if ~isfield(sbgData.(group),field) || ...
                length(sbgData.(group).(field)) < ntime
            return
        end
    end
end
tf = true;
end
