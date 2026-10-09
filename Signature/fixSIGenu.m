function [avgout, cparams, fh] = fixSIGenu(avg, burst, sbgData, hoffgiven, plotburst, relativebursttime, forcedtimelag)
% Recompute ENU velocity profiles from beam velocities using SBG Ellipse
% motion sensor orientation data with automatic time-lag correction.
% 
% Inputs:
%   avg             - Structure containing ADCP avg data from Signature 1000
%   burst           - Structure containing ADCP burst data (for AHRS gyro)
%   sbgData         - SBG Ellipse structure, or a cell array of neighboring
%                     structures. Records are combined on reconstructed UTC.
%   heading_offset  - (Optional) Heading offset in degrees to add to SBG heading
%                     If not provided or empty, will be auto-computed from data
%   plotburst       - (Optional) Plot burst diagnostics (default true)
%   relativebursttime - (Optional) Align the starts of an already matched
%                     SIG/SBG burst pair before gyro cross-correlation.
%                     This avoids reliance on SBG UTC (default false).
%   forcedtimelag    - (Optional) Use this lag in seconds after calculating
%                     xcorr diagnostics. Intended for a locally interpolated
%                     lag when this burst's gyro correlation is weak.
%
% Outputs:
%   avg_out  - Input structure with updated VelocityData (ENU velocities)
%   diag     - Diagnostic structure with intermediate results
%
% Based on fixSIGenu by K. Zeiden, Dec 2025
% Extended to use SBG data with automatic lag correction

% Handle optional heading offset
if nargin < 4 || isempty(hoffgiven)
    compute_offset = true;
else
    compute_offset = false;
end

if nargin < 5 || isempty(plotburst)
    plotburst = true;
end

if nargin < 6
    relativebursttime = false;
end
if nargin < 7
    forcedtimelag = [];
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
if (isempty(sbgData.ImuData.time) || isempty(sbgData.EkfEuler.time)) && ...
        relativebursttime
    if iscell(sbgInput); sbgInput = sbgInput{1}; end
    [sbgData,sbgtimeinfo] = relativeSBGdata(sbgInput,min(sigtime));
    usedrelativefallback = true;
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
if min(max(sbgimutime),max(sigtime))-max(min(sbgimutime),min(sigtime)) <= 0
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

%% Interpolate SBG orientation to ADCP timestamps

adcp_time = avg.time;
heading = interpAngleWithGaps(sbgtime_corrected,sbgyaw,adcp_time,1);
pitch = interpWithGaps(sbgtime_corrected,sbgpitch,adcp_time,1);
roll = interpAngleWithGaps(sbgtime_corrected,sbgroll,adcp_time,1);

%% Apply heading offset

% Compute heading offset from data
[mean_adcp, ~] = meandir(avg.Heading);
[mean_sbg, ~] = meandir(heading);
hoffdata = mean_adcp - mean_sbg;

% Handle wrapping to keep offset in -180 to 180 range
if hoffdata > 180
    hoffdata = hoffdata - 360;
    elseif hoffdata < -180
        hoffdata = hoffdata + 360;
end

% Apply offset to SBG heading
if compute_offset
    heading = heading + hoffdata;
    fprintf('Auto-computed heading offset: %.2f degrees\n', hoffdata);
else
    heading = heading + hoffgiven;
end


%% Recompute ENU velocities using SBG orientation

% Beam to XYZ transformation matrix for Signature 1000
T_AHRS = [1.1831         0   -1.1831         0;
               0   -1.1831         0    1.1831;
          0.5518         0    0.5518         0;
               0    0.5518         0    0.5518];

% Onboard ENU velocities
velENU = avg.VelocityData;
[nping, nbin, ~] = size(velENU);

% AHRS rotation matrix used in onboard ENU calculation
R_AHRS = NaN(nping, 3, 3);
R_AHRS(:,1,1) = avg.AHRS_M11;
R_AHRS(:,1,2) = avg.AHRS_M12;
R_AHRS(:,1,3) = avg.AHRS_M13;
R_AHRS(:,2,1) = avg.AHRS_M21;
R_AHRS(:,2,2) = avg.AHRS_M22;
R_AHRS(:,2,3) = avg.AHRS_M23;
R_AHRS(:,3,1) = avg.AHRS_M31;
R_AHRS(:,3,2) = avg.AHRS_M32;
R_AHRS(:,3,3) = avg.AHRS_M33;

T_AHRS_inv = inv(T_AHRS);

% Step 1) Revert ENU velocities back to beam velocities
velBEAM = NaN(size(velENU));
validmatrix = false(nping,1);
for iping = 1:nping
    R = squeeze(R_AHRS(iping, :, :));
    R_4beam = [R(1,1) R(1,2) R(1,3)/2 R(1,3)/2;
               R(2,1) R(2,2) R(2,3)/2 R(2,3)/2;
               R(3,1) R(3,2) R(3,3)   0;
               R(3,1) R(3,2) 0        R(3,3)];

    % A few affected files contain isolated corrupted matrices. Do not let
    % an unstable inversion contaminate the burst-average profile.
    if any(~isfinite(R),'all') || rcond(R_4beam) < 1e-8 || ...
            abs(det(R)-1) > 0.1 || norm(R*R'-eye(3),'fro') > 0.1
        continue
    end

    enu_p  = squeeze(velENU(iping, :, :)).';   % 4 x nbin
    xyz_p  = R_4beam \ enu_p;
    beam_p = T_AHRS_inv * xyz_p;
    velBEAM(iping, :, :) = beam_p.';
    validmatrix(iping) = true;
end

% Step 2) Compute new ENU velocities using SBG orientation. Down-looking
% orientation is already represented by roll near 180 degrees. Reusing the
% same beam transform makes this step a no-op when the replacement HPR is
% identical to the onboard HPR.
T = T_AHRS;

velENU_new = NaN(size(velENU));

for iping = 1:nping
    % Nortek's stored AHRS matrix uses heading clockwise from north and
    % pitch with the opposite sign to a Cartesian y rotation. This identity
    % reproduces the raw AHRS matrices to stored precision.
    hh = 90 - heading(iping);
    pp = -pitch(iping);
    rr = roll(iping);
    
    Rz = [cosd(hh) -sind(hh) 0;
          sind(hh)  cosd(hh) 0;
          0         0        1];

    Ry = [cosd(pp)  0  sind(pp);
          0         1  0;
         -sind(pp)  0  cosd(pp)];
    Rx = [1  0         0;
          0  cosd(rr) -sind(rr);
          0  sind(rr)  cosd(rr)];
    
    R = Rz * Ry * Rx;
    R_4beam = [R(1,1) R(1,2) R(1,3)/2 R(1,3)/2;
               R(2,1) R(2,2) R(2,3)/2 R(2,3)/2;
               R(3,1) R(3,2) R(3,3)   0;
               R(3,1) R(3,2) 0        R(3,3)];

    beam_p = squeeze(velBEAM(iping, :, :)).';  % 4 x nbin
    velENU_new(iping, :, :) = (R_4beam * (T * beam_p)).';
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
cparams.sbgtimeinfo = sbgtimeinfo;
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
[stamp,iu] = unique(double(record.ImuData.time_stamp(:))/1e6);
out.ImuData.time = referencetime+(stamp-stamp(1))/86400;
out.ImuData.gyro_x = double(record.ImuData.gyro_x(iu));
out.ImuData.gyro_y = double(record.ImuData.gyro_y(iu));
out.ImuData.gyro_z = double(record.ImuData.gyro_z(iu));
[stamp,iu] = unique(double(record.EkfEuler.time_stamp(:))/1e6);
out.EkfEuler.time = referencetime+(stamp-stamp(1))/86400;
out.EkfEuler.pitch = double(record.EkfEuler.pitch(iu));
out.EkfEuler.roll = double(record.EkfEuler.roll(iu));
out.EkfEuler.yaw = double(record.EkfEuler.yaw(iu));
info.records = 1;
info.recordsused = 1;
info.anchorresidualseconds = NaN;
info.imusamples = length(out.ImuData.time);
info.ekfsamples = length(out.EkfEuler.time);
end
