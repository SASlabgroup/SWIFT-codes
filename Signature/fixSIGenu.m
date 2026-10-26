function [avgout, cparams, fh] = fixSIGenu(avg, burst, sbgData, mountyaw, worldyaw, plotburst, relativebursttime, forcedtimelag, allowrelativeyaw, requirevalidorientation)
% Recompute ENU velocity profiles from beam velocities using SBG Ellipse
% motion sensor orientation data with automatic time-lag correction.
% 
% Inputs:
%   avg             - Structure containing ADCP avg data from Signature 1000
%   burst           - Structure containing ADCP burst data (for AHRS gyro)
%   sbgData         - SBG Ellipse structure, or a cell array of neighboring
%                     structures. Records are combined on reconstructed UTC.
%                     If relativebursttime is true, the first cell must be
%                     the exact record matched to this Signature burst.
%   mountyaw        - Signature-to-SBG yaw in degrees, a body-frame rotation
%                     about the instrument z axis (how the two sensors are
%                     mounted relative to each other). Measure it from the
%                     gyros (rotation fit Signature AHRS gyro -> SBG gyro).
%   worldyaw        - Earth-frame yaw in degrees added to the SBG heading
%                     (e.g. declination if the SBG heading were magnetic).
%                     0 when the SBG yaw is already true north.
%   plotburst       - (Optional) Plot burst diagnostics (default true)
%   relativebursttime - (Optional) Permit the exact matched SIG/SBG pair to
%                     use its native relative clock when merged UTC is empty,
%                     non-overlapping, or insufficient for gyro correlation.
%                     This avoids reliance on SBG UTC (default false).
%   forcedtimelag    - (Optional) Use this lag in seconds after calculating
%                     xcorr diagnostics. Intended for a locally interpolated
%                     lag when this burst's gyro correlation is weak.
%   allowrelativeyaw - (Optional, default false) Rotate even when the SBG EKF
%                     has no absolute heading (vertical-gyro mode). Set only
%                     if the caller has given the SBG yaw a world reference
%                     itself; otherwise such bursts are not rotated
%                     (avgout empty, cparams.relativeyaw true).
%   requirevalidorientation - (Optional, default false) Use only SBG Euler
%                     samples carrying both SBG_ECOM_SOL_ATTITUDE_VALID and
%                     SBG_ECOM_SOL_HEADING_VALID. Invalid intervals remain
%                     NaN through interpolation and profile averaging.
%
% Outputs:
%   avg_out  - Input structure with updated VelocityData (ENU velocities)
%   diag     - Diagnostic structure with intermediate results
%
% Based on fixSIGenu by K. Zeiden, Dec 2025
% Extended to use SBG data with automatic lag correction
% mleclair (using claude), Oct 2026: mount yaw as a body rotation and
%   world yaw as an earth-frame rotation (R = Rz_world*R_SBG*Rz_mount),
%   replacing the heading offset and auto offset; neighbouring SBG records
%   combined on UTC; relative-time fallback; forced lag; bursts with
%   vertical-gyro SBG yaw skipped unless allowrelativeyaw; optional
%   valid-orientation mask

% Matrix names use R_destination_T_source: v_destination =
% R_destination_T_source * v_source. Adjacent frames therefore cancel:
%   R_earth_T_sig = R_earth_T_sbg * R_sbg_T_sig
% worldyaw is included in R_earth_T_sbg; mountyaw defines R_sbg_T_sig.
% The mount is a body rotation, so it is not the same as adding mountyaw to
% the SBG heading once the buoy tilts (see the ENU step below).
%
% Willapa (Jun 2025) moored SWIFTs: the gyro fit gives a Signature-to-SBG
% frame offset of -45 deg (-45.0 +/- 0.5 on most buoys), plus a per-buoy
% clocking of the SBG in multiples of 90 deg (one buoy +90, i.e. +45
% total). Expect the same -45 frame offset with possible mod-90 clocking on
% other SWIFTs with this Signature/SBG layout, but measure it. Willapa SBG
% yaw is true north (magnetometer-aided EKF applies declination), so
% worldyaw = 0 there; the onboard Signature heading is magnetic (DECL=0), so
% its compass minus SBG yaw is mountyaw minus declination, not the mount.
if nargin < 5 || isempty(worldyaw)
    worldyaw = 0;
end

if nargin < 6 || isempty(plotburst)
    plotburst = true;
end

if nargin < 7
    relativebursttime = false;
end
if nargin < 8
    forcedtimelag = [];
end
if nargin < 9 || isempty(allowrelativeyaw)
    allowrelativeyaw = false;
end
if nargin < 10 || isempty(requirevalidorientation)
    requirevalidorientation = false;
end

%% ADCP AHRS gyroscope data

sigtime = burst.time;
siggyrox = burst.AHRS_GyroX;
siggyroy = burst.AHRS_GyroY;
siggyroz = burst.AHRS_GyroZ;

% Compute total angular velocity magnitude
sigangv = sqrt(siggyrox.^2 + siggyroy.^2 + siggyroz.^2);

[~,iu] = unique(sigtime);
sigtime = sigtime(iu);
sigangv = sigangv(iu);

%% SBG Euler + gyroscope data

if iscell(sbgData)
    nSBGrecords = length(sbgData);
else
    nSBGrecords = 1;
end
sbgInput = sbgData;
usedrelativefallback = false;
[sbgData,sbgtimeinfo] = mergeSBGdata(sbgInput,median(sigtime,'omitnan'));
hasmergedtime = ~isempty(sbgData.ImuData.time) && ...
    ~isempty(sbgData.EkfEuler.time);
hasmergedoverlap = hasmergedtime && ...
    timeRangesOverlap(sbgData.ImuData.time,sigtime) && ...
    timeRangesOverlap(sbgData.EkfEuler.time,sigtime);
% A neighboring record can provide valid UTC and make the merged result
% nonempty even when the exact record has no UTC packets. At transitions
% into or out of such an outage, the neighboring UTC data do not overlap
% this burst. Retry the already-matched exact record on its native clock;
% callers opt into this behavior with relativebursttime, and put that
% record first when sbgInput is a cell array.
if relativebursttime && (~hasmergedtime || ~hasmergedoverlap)
    exactrecord = sbgInput;
    if iscell(exactrecord); exactrecord = exactrecord{1}; end
    [relativedata,relativeinfo] = relativeSBGdata(exactrecord,min(sigtime));
    if ~isempty(relativedata.ImuData.time) && ...
            ~isempty(relativedata.EkfEuler.time)
        sbgData = relativedata;
        sbgtimeinfo = relativeinfo;
        usedrelativefallback = true;
    end
end
if isempty(sbgData.ImuData.time) || isempty(sbgData.EkfEuler.time)
    disp('No valid SBG UTC clock anchor...')
    avgout = [];
    cparams = [];
    fh = [];
    return
end

sbgimutime = sbgData.ImuData.time;
sbgekftime = sbgData.EkfEuler.time;
sbgpitch = sbgData.EkfEuler.pitch * 180/pi;
sbgroll = sbgData.EkfEuler.roll * 180/pi;
sbgyaw = sbgData.EkfEuler.yaw * 180/pi;
sbgstatus = double(sbgData.EkfEuler.solution_status);
finitestatus = isfinite(sbgstatus);
attitudevalid = finitestatus & bitget(uint32(sbgstatus),5) ~= 0;
headingvalid = finitestatus & bitget(uint32(sbgstatus),6) ~= 0;
orientationvalid = attitudevalid & headingvalid;

if requirevalidorientation
    sbgpitch(~orientationvalid) = NaN;
    sbgroll(~orientationvalid) = NaN;
    sbgyaw(~orientationvalid) = NaN;
end

% Force SBG roll to 180 to match ADCP
sbgroll = sbgroll + 180;
sbgroll = wrapToPi(sbgroll*pi/180)*180/pi;

% SBG gyroscope data (convert from radians/s to degrees/s)
sbggyrox = sbgData.ImuData.gyro_x * 180/pi;
sbggyroy = sbgData.ImuData.gyro_y * 180/pi;
sbggyroz = sbgData.ImuData.gyro_z * 180/pi;

% Compute angular velocity
sbgangv = sqrt(sbggyrox.^2 + sbggyroy.^2 + sbggyroz.^2);

%% Fix SBG time
if usedrelativefallback
    timesource = "relative_native_fallback";
elseif relativebursttime && nSBGrecords == 1
    % Backward-compatible fallback for a single already-matched record. Keep
    % the native sample intervals; only align the starts of the two clocks.
    shift = min(sigtime)-min(sbgimutime);
    sbgimutime = sbgimutime+shift;
    sbgekftime = sbgekftime+shift;
    timesource = "relative_native";
else
    timesource = "utc_reconstructed";
end
toff = min(sbgimutime)-min(sigtime);
if ~timeRangesOverlap(sbgimutime,sigtime)
    disp('No timeseries overlap...')
    avgout = [];
    cparams = [];
    fh = [];
    return
end

%% Compute time lag via cross-correlation

% Interpolate to high res time grid (10 Hz), but never invent motion across
% missing acquisition intervals.
dt = (1/10)/(24*60*60); % days
ctime = (max([min(sbgimutime) min(sigtime)]):dt: ...
    min([max(sbgimutime) max(sigtime)]))';
csbgangv = interpWithGaps(sbgimutime,sbgangv,ctime,1);
csigangv = interpWithGaps(sigtime,sigangv,ctime,1);

% Cross-correlate to find lag (max lag 100 s). Robust scaling prevents an
% isolated corrupt gyro sample from controlling the match, while 'coeff'
% avoids the edge preference of the original unbiased normalization.
csbgangv_xc = robustXCsignal(csbgangv);
csigangv_xc = robustXCsignal(csigangv);
[r,lags,noverlap] = maskedXCorr(csbgangv_xc,csigangv_xc,1000,300);
[~, imaxr] = max(r,[],'omitnan');
if isempty(imaxr) || ~isfinite(r(imaxr))
    % A sliver of neighboring UTC data can overlap the burst while still
    % providing too few continuous samples for the timing correlation.
    % Retry the exact matched record on its native relative clock. Limit
    % this recursive retry to multi-record input so it cannot repeat.
    if relativebursttime && nSBGrecords > 1 && ~usedrelativefallback
        exactrecord = sbgInput{1};
        [avgout,cparams,fh] = fixSIGenu(avg,burst,exactrecord,mountyaw, ...
            worldyaw,plotburst,true,forcedtimelag,allowrelativeyaw, ...
            requirevalidorientation);
        if ~isempty(cparams) && isfield(cparams,'timesource')
            cparams.timesource = "relative_native_fallback";
        end
        return
    end
    disp('No usable gyro overlap...')
    avgout = [];
    cparams = [];
    fh = [];
    return
end
tlag = lags(imaxr) * dt; % days
usedinterpolatedlag = false;
if ~isempty(forcedtimelag)
    tlag = forcedtimelag/(24*60*60);
    usedinterpolatedlag = true;
end

% Apply time shift to SBG data
sbgimutime_corrected = sbgimutime - tlag;
sbgtime_corrected = sbgekftime - tlag;

%% Require an absolute SBG heading

% SBG EKF solution mode occupies bits 0--3; mode 1 is
% SBG_ECOM_SOL_MODE_VERTICAL_GYRO: "the Kalman filter only rely on a
% vertical reference to compute roll and pitch angles. Heading and
% navigation data drift freely" (sbgECom src/logs/sbgEComLogEkf.h,
% github.com/SBG-Systems/sbgECom). Its yaw is relative, so rotating with it
% gives arbitrary directions. Skip a burst when most of its EKF samples are
% in that mode, unless the caller has referenced the yaw itself. A unit can
% sit in this mode for a whole deployment with good GNSS and a calibrated
% magnetometer if those aids are not used by the EKF (a configuration
% problem, not conditions), so check rather than assume.
inburst = sbgtime_corrected >= min(avg.time) & sbgtime_corrected <= max(avg.time);
burststatus = sbgstatus(inburst);
burststatus = burststatus(isfinite(burststatus));
solutionmode = double(bitand(uint32(burststatus),uint32(15)));
verticalgyrofraction = mean(solutionmode == 1); % NaN if no status
if verticalgyrofraction > 0.5 && ~allowrelativeyaw
    disp('SBG yaw is relative (EKF vertical-gyro mode); not rotating...')
    avgout = [];
    cparams = struct('relativeyaw',true, ...
        'verticalgyrofraction',verticalgyrofraction);
    fh = [];
    return
end

%% Interpolate SBG orientation to ADCP timestamps

adcp_time = avg.time;
heading = interpAngleWithGaps(sbgtime_corrected,sbgyaw,adcp_time,1);
pitch = interpWithGaps(sbgtime_corrected,sbgpitch,adcp_time,1);
roll = interpAngleWithGaps(sbgtime_corrected,sbgroll,adcp_time,1);
if requirevalidorientation
    % interpWithGaps may bridge an isolated invalid SBG sample when the
    % surrounding valid samples are less than one second apart. Apply the
    % nearest native status again so no invalid interval is reconstructed.
    validatping = interp1(sbgtime_corrected,double(orientationvalid), ...
        adcp_time,'nearest',0) ~= 0;
    heading(~validatping) = NaN;
    pitch(~validatping) = NaN;
    roll(~validatping) = NaN;
end

%% Heading offsets

% Signature compass minus SBG heading (diagnostic only: equals mountyaw
% only when both headings use the same north reference and are unbiased)
[mean_adcp, ~] = meandir(avg.Heading);
[mean_sbg, ~] = meandir(heading);
hoffdata = mean_adcp - mean_sbg;

% Handle wrapping to keep offset in -180 to 180 range
if hoffdata > 180
    hoffdata = hoffdata - 360;
    elseif hoffdata < -180
        hoffdata = hoffdata + 360;
end

% Signature heading for the diagnostics (exact for a level buoy). The ENU
% step applies worldyaw to the SBG heading and mountyaw as a body rotation.
sbgheading = heading + worldyaw;
heading = sbgheading + mountyaw;


%% Recompute ENU velocities using SBG orientation

% Signature 1000 beam coordinates -> Signature Cartesian coordinates.
T_sig_T_beam = [1.1831         0   -1.1831         0;
                     0   -1.1831         0    1.1831;
                0.5518         0    0.5518         0;
                     0    0.5518         0    0.5518];

% Onboard ENU velocities
velENU = avg.VelocityData;
[nping, nbin, ~] = size(velENU);

% Onboard AHRS rotation: Signature Cartesian coordinates -> earth ENU.
R_earth_T_sig_onboard = NaN(nping, 3, 3);
R_earth_T_sig_onboard(:,1,1) = avg.AHRS_M11;
R_earth_T_sig_onboard(:,1,2) = avg.AHRS_M12;
R_earth_T_sig_onboard(:,1,3) = avg.AHRS_M13;
R_earth_T_sig_onboard(:,2,1) = avg.AHRS_M21;
R_earth_T_sig_onboard(:,2,2) = avg.AHRS_M22;
R_earth_T_sig_onboard(:,2,3) = avg.AHRS_M23;
R_earth_T_sig_onboard(:,3,1) = avg.AHRS_M31;
R_earth_T_sig_onboard(:,3,2) = avg.AHRS_M32;
R_earth_T_sig_onboard(:,3,3) = avg.AHRS_M33;

% Step 1) Revert ENU velocities back to beam velocities
velBEAM = NaN(size(velENU));
validmatrix = false(nping,1);
for iping = 1:nping
    R_earth_T_sig = squeeze(R_earth_T_sig_onboard(iping, :, :));
    R_earth4_T_sig4 = [R_earth_T_sig(1,1) R_earth_T_sig(1,2) R_earth_T_sig(1,3)/2 R_earth_T_sig(1,3)/2;
                       R_earth_T_sig(2,1) R_earth_T_sig(2,2) R_earth_T_sig(2,3)/2 R_earth_T_sig(2,3)/2;
                       R_earth_T_sig(3,1) R_earth_T_sig(3,2) R_earth_T_sig(3,3)   0;
                       R_earth_T_sig(3,1) R_earth_T_sig(3,2) 0                    R_earth_T_sig(3,3)];

    % A few affected files contain isolated corrupted matrices. Do not let
    % an unstable inversion contaminate the burst-average profile.
    if any(~isfinite(R_earth_T_sig),'all') || ...
            rcond(R_earth4_T_sig4) < 1e-8 || ...
            abs(det(R_earth_T_sig)-1) > 0.1 || ...
            norm(R_earth_T_sig*R_earth_T_sig'-eye(3),'fro') > 0.1
        continue
    end

    enu_p  = squeeze(velENU(iping, :, :)).';   % 4 x nbin
    sig_p  = R_earth4_T_sig4 \ enu_p;
    beam_p = T_sig_T_beam \ sig_p;
    velBEAM(iping, :, :) = beam_p.';
    validmatrix(iping) = true;
end

% Step 2) Compute new ENU velocities using SBG orientation. Down-looking
% orientation is already represented by roll near 180 degrees. Reusing the
% same beam transform makes this step a no-op when the replacement HPR is
% identical to the onboard HPR.
velENU_new = NaN(size(velENU));

% The Signature is rotated by mountyaw about its own z axis relative to the
% SBG, so R_earth_T_sig = R_earth_T_sbg * R_sbg_T_sig. Adding mountyaw to the SBG
% Euler heading instead (an earth-frame yaw) is the same only for a level
% buoy: it reuses the SBG pitch/roll as the Signature's, misplacing the tilt
% by 2*sin(mountyaw/2)*tilt (~0.77*tilt at 45 deg). worldyaw is an
% earth-frame yaw, so it is added to the Euler heading.
% Test case: Willapa SWIFT22 before 23 Jun 2025, the one buoy with both a
% healthy SBG and a healthy Signature AHRS. Against the Signature's own AHRS
% matrix, the instrument z axis (gravity in the body frame) was 16 deg off at
% 20-25 deg tilt with the Euler-heading form and ~3 deg at all tilts with
% R_earth_T_sbg * R_sbg_T_sig.
R_sbg_T_sig = [cosd(mountyaw) -sind(mountyaw) 0;
               sind(mountyaw)  cosd(mountyaw) 0;
               0               0              1];

for iping = 1:nping
    % Nortek's stored AHRS matrix uses heading clockwise from north and
    % pitch with the opposite sign to a Cartesian y rotation. This identity
    % reproduces the raw AHRS matrices to stored precision. The previous
    % hh = heading, pp = pitch form (with T rows 2:4 negated) mirrored flow
    % directions about the 45 degree line (new = 90 - old); it is not a
    % constant yaw
    hh = 90 - sbgheading(iping);
    pp = -pitch(iping);
    rr = roll(iping);
    
    R_earth_T_yawframe = [cosd(hh) -sind(hh) 0;
                          sind(hh)  cosd(hh) 0;
                          0         0        1];

    R_yawframe_T_pitchframe = [cosd(pp)  0  sind(pp);
                               0         1  0;
                              -sind(pp)  0  cosd(pp)];
    R_pitchframe_T_sbg = [1  0         0;
                          0  cosd(rr) -sind(rr);
                          0  sind(rr)  cosd(rr)];

    R_earth_T_sbg = R_earth_T_yawframe * ...
        R_yawframe_T_pitchframe * R_pitchframe_T_sbg;
    R_earth_T_sig = R_earth_T_sbg * R_sbg_T_sig;
    R_earth4_T_sig4 = [R_earth_T_sig(1,1) R_earth_T_sig(1,2) R_earth_T_sig(1,3)/2 R_earth_T_sig(1,3)/2;
                       R_earth_T_sig(2,1) R_earth_T_sig(2,2) R_earth_T_sig(2,3)/2 R_earth_T_sig(2,3)/2;
                       R_earth_T_sig(3,1) R_earth_T_sig(3,2) R_earth_T_sig(3,3)   0;
                       R_earth_T_sig(3,1) R_earth_T_sig(3,2) 0                    R_earth_T_sig(3,3)];

    beam_p = squeeze(velBEAM(iping, :, :)).';  % 4 x nbin
    velENU_new(iping, :, :) = ...
        (R_earth4_T_sig4 * T_sig_T_beam * beam_p).';
end

% Swap signs in ENU
% velENU_new(:, :, 2:4) = -velENU_new(:, :, 2:4);

%% Create output structure

avgout = avg;
avgout.VelocityData = velENU_new;

%% Create diagnostics structure
cparams.toff = toff;
cparams.tlag = tlag;
cparams.timesource = timesource;
cparams.effectivetimeoffset = (toff-tlag)*24*60*60;
cparams.lagcorrelation = r(imaxr);
cparams.lagoverlapsamples = noverlap(imaxr);
cparams.usedinterpolatedlag = usedinterpolatedlag;
cparams.orientationcoverage = mean(isfinite(heading) & isfinite(pitch) & ...
    isfinite(roll));
cparams.attitudevalidfraction = mean(attitudevalid(inburst));
cparams.headingvalidfraction = mean(headingvalid(inburst));
cparams.validorientationfraction = mean(orientationvalid(inburst));
cparams.validityflagsrequired = requirevalidorientation;
cparams.sbgtimeinfo = sbgtimeinfo;
cparams.relativeyaw = false;
cparams.verticalgyrofraction = verticalgyrofraction;
cparams.hoff = hoffdata;
cparams.mheading = meandir(heading);
cparams.mpitch = mean(pitch,'omitnan');
cparams.mroll = meandir(roll);
cparams.nbadmatrix = sum(~validmatrix);

%% Plot diagnostics
if plotburst
fh = figure('Color', 'w');
fullscreen

% Subplot 1: Cross-correlation
subplot(7,1,1)
plot(lags * dt*24*60*60, r, 'b-', 'LineWidth', 1.5);
hold on;
plot(tlag*24*60*60, interp1(lags*dt,r,tlag,'linear','extrap'), ...
    'ro', 'MarkerSize', 10, 'MarkerFaceColor', 'r');
grid on;
ylabel('XC');
title(sprintf('Cross-correlation (lag = %.2f s)', tlag*24*60*60));

% Subplot 2: Angular velocity comparison
subplot(7,1,2)
plot(sigtime, sigangv, 'b-', 'LineWidth', 1);
hold on;
plot(sbgimutime_corrected, sbgangv, 'r-', 'LineWidth', 1);
grid on;
ylabel('[\Omega [degs^{-1}]');
legend('ADCP', 'SBG', 'Location', 'best');
title('Angular Velocity');
datetick('x', 'HH:MM:SS', 'keeplimits');

% Subplot 3: Heading comparison
subplot(7,1,3)
plot(adcp_time, wrapToPi(avg.Heading*pi/180)*180/pi, 'b.-');
hold on;
plot(sbgtime_corrected, sbgyaw, 'r-');
grid on;
ylabel('H [deg]');ylim([-180 180])
[mean_adcp, std_adcp] = meandir(avg.Heading);
[mean_sbg, std_sbg] = meandir(sbgyaw);
title(sprintf('Heading | ADCP: %.1f±%.1f° | SBG: %.1f±%.1f°', mean_adcp, std_adcp, mean_sbg, std_sbg));
datetick('x', 'HH:MM:SS', 'keeplimits');

% Subplot 4: Pitch comparison
subplot(7,1,4)
plot(adcp_time, avg.Pitch, 'b.-');
hold on;
plot(sbgtime_corrected, sbgpitch, 'r-');
grid on;
ylabel('P [deg]');ylim([-180 180])
[mean_adcp, std_adcp] = meandir(avg.Pitch);
[mean_sbg, std_sbg] = meandir(sbgpitch);
title(sprintf('Pitch | ADCP: %.1f±%.1f° | SBG: %.1f±%.1f°', mean_adcp, std_adcp, mean_sbg, std_sbg));

% Subplot 5: Roll comparison
subplot(7,1,5)
plot(adcp_time, avg.Roll, 'b.-');
hold on;
scatter(sbgtime_corrected, sbgroll,1,'r','filled');
grid on;
ylabel('R [deg]');ylim([-180 180])
[mean_adcp, std_adcp] = meandir(avg.Roll);
[mean_sbg, std_sbg] = meandir(sbgroll);
title(sprintf('Roll | ADCP: %.1f±%.1f° | SBG: %.1f±%.1f°', mean_adcp, std_adcp, mean_sbg, std_sbg));

% Subplot 6: East velocity (original)
subplot(7,1,6)
pcolor(adcp_time, 1:nbin, squeeze(velENU(:,:,1))');
shading flat;
colorbar;
colormap(cmocean('balance'));
ylabel('Bin');
title('East Velocity - Original (m/s)');
clim([-1 1])

% Subplot 7: East velocity (corrected)
subplot(7,1,7)
pcolor(adcp_time, 1:nbin, squeeze(velENU_new(:,:,1))');
shading flat;
colorbar;
colormap(cmocean('balance'));
ylabel('Bin');
title('East Velocity - SBG Corrected (m/s)');
datetick('x', 'HH:MM:SS', 'keeplimits');
clim([-1 1])
axis tight

% Link x-axes of subplots 2–7
h = findall(gcf,'Type','Axes');
linkaxes(h(1:end-1), 'x');
linkaxes(h(1:2),'y');
set(h(2:end-1),'XTickLabel',[])
axis tight

% === Quick tightening: adjust this factor for more/less space ===
sf = 2;  % Try 1.3–1.6; higher = taller plots, less vertical gap

for i = 1:7
    pos = get(h(i), 'Position');
    delta_h = pos(4) * (sf - 1);  % Extra height added
    pos(2) = pos(2) - delta_h;              % Move bottom down by extra amount
    pos(4) = pos(4) * sf;         % Increase height
    set(h(i), 'Position', pos);
end
% ==============================================================

else
    fh = [];
end
end

function y = robustXCsignal(x)
% Center, scale, and clip only for timing correlation. The unmodified gyro
% and orientation data continue through the rest of the calculation.
x = double(x);
missing = ~isfinite(x);
xmedian = median(x,'omitnan');
xscale = 1.4826*median(abs(x-xmedian),'omitnan');
if ~isfinite(xscale) || xscale == 0
    xscale = std(x,'omitnan');
end
if ~isfinite(xscale) || xscale == 0
    y = zeros(size(x));
    y(missing) = NaN;
    return
end
y = min(max(x,xmedian-10*xscale),xmedian+10*xscale);
y(missing) = NaN;
y = y-mean(y,'omitnan');
yscale = std(y,'omitnan');
if isfinite(yscale) && yscale > 0
    y = y/yscale;
end
end

function y = interpWithGaps(time,x,newtime,maxgapseconds)
% Linear interpolation within continuous records only.
[time,iu] = unique(double(time(:)));
x = double(x(:));
x = x(iu);
good = isfinite(time) & isfinite(x);
time = time(good);
x = x(good);
y = NaN(size(newtime));
if length(time) < 2; return; end
y = interp1(time,x,newtime);
gaps = find(diff(time)*86400 > maxgapseconds);
for igap = gaps(:)'
    y(newtime > time(igap) & newtime < time(igap+1)) = NaN;
end
end

function angle = interpAngleWithGaps(time,angle,newtime,maxgapseconds)
s = interpWithGaps(time,sind(angle),newtime,maxgapseconds);
c = interpWithGaps(time,cosd(angle),newtime,maxgapseconds);
angle = atan2d(s,c);
end

function [r,lags,n] = maskedXCorr(x,y,maxlag,minoverlap)
% Pearson correlation at each lag using only real overlapping samples.
mx = isfinite(x);
my = isfinite(y);
x(~mx) = 0;
y(~my) = 0;
lags = (-maxlag:maxlag)';
n = xcorr(double(mx),double(my),maxlag);
sx = xcorr(x,double(my),maxlag);
sy = xcorr(double(mx),y,maxlag);
sxx = xcorr(x.^2,double(my),maxlag);
syy = xcorr(double(mx),y.^2,maxlag);
sxy = xcorr(x,y,maxlag);
covxy = sxy-sx.*sy./n;
varx = sxx-sx.^2./n;
vary = syy-sy.^2./n;
r = covxy./sqrt(varx.*vary);
r(n < minoverlap | varx <= 0 | vary <= 0) = NaN;
end

function [out,info] = relativeSBGdata(record,referencetime)
% Preserve the legacy single-record fallback when no UTC anchor is usable.
out.ImuData.time = zeros(0,1);
out.ImuData.gyro_x = zeros(0,1);
out.ImuData.gyro_y = zeros(0,1);
out.ImuData.gyro_z = zeros(0,1);
out.EkfEuler.time = zeros(0,1);
out.EkfEuler.pitch = zeros(0,1);
out.EkfEuler.roll = zeros(0,1);
out.EkfEuler.yaw = zeros(0,1);
out.EkfEuler.solution_status = zeros(0,1);
info.records = 1;
info.recordsused = 0;
info.anchorresidualseconds = NaN;
info.imusamples = 0;
info.ekfsamples = 0;
imuFields = {'time_stamp','gyro_x','gyro_y','gyro_z'};
ekfFields = {'time_stamp','pitch','roll','yaw'};
if ~isfield(record,'ImuData') || ~isfield(record,'EkfEuler') || ...
        ~all(isfield(record.ImuData,imuFields)) || ...
        ~all(isfield(record.EkfEuler,ekfFields))
    return
end
nimu = numel(record.ImuData.time_stamp);
nekf = numel(record.EkfEuler.time_stamp);
if nimu == 0 || nekf == 0 || ...
        any(cellfun(@(f) numel(record.ImuData.(f)) < nimu,imuFields)) || ...
        any(cellfun(@(f) numel(record.EkfEuler.(f)) < nekf,ekfFields))
    return
end
[stamp,iu] = unique(double(record.ImuData.time_stamp(:))/1e6);
if isempty(stamp); return; end
out.ImuData.time = referencetime+(stamp-stamp(1))/86400;
out.ImuData.gyro_x = double(record.ImuData.gyro_x(iu));
out.ImuData.gyro_y = double(record.ImuData.gyro_y(iu));
out.ImuData.gyro_z = double(record.ImuData.gyro_z(iu));
[stamp,iu] = unique(double(record.EkfEuler.time_stamp(:))/1e6);
if isempty(stamp); return; end
angle = double([record.EkfEuler.pitch(iu) record.EkfEuler.roll(iu) ...
    record.EkfEuler.yaw(iu)]);
angle = reshape(angle,length(iu),3);
% Some records contain corrupt finite Euler angles (e.g. 1e21 rad).
keep = all(abs(angle) <= pi,2);
time = referencetime+(stamp-stamp(1))/86400;
out.EkfEuler.time = time(keep);
out.EkfEuler.pitch = angle(keep,1);
out.EkfEuler.roll = angle(keep,2);
out.EkfEuler.yaw = angle(keep,3);
if isfield(record.EkfEuler,'solution_status') && ...
        numel(record.EkfEuler.solution_status) == numel(record.EkfEuler.time_stamp)
    status = double(record.EkfEuler.solution_status(:));
    status = status(iu);
else
    status = NaN(length(iu),1);
end
out.EkfEuler.solution_status = status(keep);
info.records = 1;
info.recordsused = 1;
info.anchorresidualseconds = NaN;
info.imusamples = length(out.ImuData.time);
info.ekfsamples = length(out.EkfEuler.time);
end

function tf = timeRangesOverlap(a,b)
% True when two finite time vectors have a positive-duration intersection.
a = a(isfinite(a));
b = b(isfinite(b));
tf = ~isempty(a) && ~isempty(b) && ...
    min(max(a),max(b)) > max(min(a),min(b));
end
