function [avgout, corrparams, fh] = fixSIGenu(avg, burst, sbgData, headoff)
% Recompute ENU velocity profiles from beam velocities using SBG Ellipse
% motion sensor orientation data with automatic time-lag correction.
% 
% Inputs:
%   avg             - Structure containing ADCP avg data from Signature 1000
%   burst           - Structure containing ADCP burst data (for AHRS gyro)
%   sbgData         - Structure containing SBG Ellipse motion sensor data
%   heading_offset  - (Optional) Heading offset in degrees to add to SBG heading
%                     If not provided or empty, will be auto-computed from data
%
% Outputs:
%   avg_out  - Input structure with updated VelocityData (ENU velocities)
%   diag     - Diagnostic structure with intermediate results
%
% Based on fixSIGenu by K. Zeiden, Dec 2025
% Extended to use SBG data with automatic lag correction

% Handle optional heading offset
if nargin < 4 || isempty(headoff)
    compute_offset = true;
else
    compute_offset = false;
end

%% Extract and prepare SBG data

% Build SBG UTC time
sbgtime = [sbgData.UtcTime.year(:) sbgData.UtcTime.month(:) sbgData.UtcTime.day(:)...
    sbgData.UtcTime.hour(:) sbgData.UtcTime.min(:) sbgData.UtcTime.sec(:)];
sbgtime = datenum(sbgtime);
sbgtime = sbgtime + sbgData.UtcTime.nanosec'./((10^9)*60*60*24);

% Extract SBG orientation data (convert from radians to degrees)
sbgpitch = interp1(sbgData.EkfEuler.time_stamp, sbgData.EkfEuler.pitch, ...
                   sbgData.UtcTime.time_stamp) * 180/pi;
sbgroll = interp1(sbgData.EkfEuler.time_stamp, sbgData.EkfEuler.roll, ...
                  sbgData.UtcTime.time_stamp) * 180/pi;
sbgyaw = interp1(sbgData.EkfEuler.time_stamp, sbgData.EkfEuler.yaw, ...
                 sbgData.UtcTime.time_stamp) * 180/pi;

% Adjust yaw to 0-360 range
sbgyaw(sbgyaw < 0) = sbgyaw(sbgyaw < 0) + 360;

% Extract SBG gyroscope data (convert from radians/s to degrees/s)
sbggyrox = interp1(sbgData.ImuData.time_stamp, sbgData.ImuData.gyro_x, ...
                   sbgData.UtcTime.time_stamp) * 180/pi;
sbggyroy = interp1(sbgData.ImuData.time_stamp, sbgData.ImuData.gyro_y, ...
                   sbgData.UtcTime.time_stamp) * 180/pi;
sbggyroz = interp1(sbgData.ImuData.time_stamp, sbgData.ImuData.gyro_z, ...
                   sbgData.UtcTime.time_stamp) * 180/pi;

% Compute total angular velocity magnitude
sbgangv = sqrt(sbggyrox.^2 + sbggyroy.^2 + sbggyroz.^2);

% Trim SBG data to within 12 minutes of ADCP data
sig_tmin = min(burst.time) - 12/(24*60);
sig_tmax = max(burst.time) + 12/(24*60);
igood = sbgtime >= sig_tmin & sbgtime <= sig_tmax;
sbgtime = sbgtime(igood);
sbgpitch = sbgpitch(igood);
sbgroll = sbgroll(igood);
sbgyaw = sbgyaw(igood);
sbggyrox = sbggyrox(igood);
sbggyroy = sbggyroy(igood);
sbggyroz = sbggyroz(igood);
sbgangv = sbgangv(igood);

%% Extract ADCP AHRS gyroscope data

sigtime = burst.time;
siggyrox = burst.AHRS_GyroX;
siggyroy = burst.AHRS_GyroY;
siggyroz = burst.AHRS_GyroZ;

% Compute total angular velocity magnitude
sigangv = sqrt(siggyrox.^2 + siggyroy.^2 + siggyroz.^2);

%% Compute time lag via cross-correlation

% Interpolate SBG angular velocity to ADCP timestamps
sbgangv_int = interp1(sbgtime, sbgangv, sigtime);
sbgangv_int(isnan(sbgangv_int)) = 0;

% Cross-correlate to find lag
[r, lags] = xcorr(sbgangv_int, sigangv, 'coeff');

% Find peak correlation and convert to time
sigdt = median(diff(sigtime)) * 24 * 60 * 60; % seconds
[~, imaxr] = max(r);
tlag = lags(imaxr) * sigdt / (24 * 60 * 60); % days

% Apply time correction to SBG data
sbgtime_corrected = sbgtime - tlag;

%% Interpolate SBG orientation to ADCP timestamps

adcp_time = avg.time;
heading = interp1(sbgtime_corrected, sbgyaw, adcp_time);
pitch = interp1(sbgtime_corrected, sbgpitch, adcp_time);
roll = interp1(sbgtime_corrected, sbgroll, adcp_time);

%% Apply heading offset

if compute_offset
    % Auto-compute heading offset from data
    [mean_adcp, ~] = meandir(avg.Heading);
    [mean_sbg, ~] = meandir(heading);
    
    % Compute circular difference
    headoff = mean_adcp - mean_sbg;
    
    % Handle wrapping to keep offset in -180 to 180 range
    if headoff > 180
        headoff = headoff - 360;
    elseif headoff < -180
        headoff = headoff + 360;
    end
    
    fprintf('Auto-computed heading offset: %.2f degrees\n', headoff);
end

% Apply offset to SBG heading
heading = heading + headoff;

% Wrap to 0-360 range
heading(heading >= 360) = heading(heading >= 360) - 360;
heading(heading < 0) = heading(heading < 0) + 360;

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

% Step 1) Revert ENU velocities back to beam velocities
velBEAM = NaN(size(velENU));
for iping = 1:nping
    R = squeeze(R_AHRS(iping, :, :));
    R_4beam = [R(1,1) R(1,2) R(1,3)/2 R(1,3)/2;
               R(2,1) R(2,2) R(2,3)/2 R(2,3)/2;
               R(3,1) R(3,2) R(3,3)   0;
               R(3,1) R(3,2) 0        R(3,3)];
    
    for ibin = 1:nbin
        velXYZ_temp = R_4beam \ squeeze(velENU(iping, ibin, :));
        velBEAM(iping, ibin, :) = T_AHRS \ velXYZ_temp;
    end
end

% Step 2) Compute new ENU velocities using SBG orientation
T = T_AHRS;
T(2:4, :) = -T(2:4, :);

velENU_new = NaN(size(velENU));

for iping = 1:nping
    hh = heading(iping);
    pp = pitch(iping);
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
    
    for ibin = 1:nbin
        velXYZ_temp = T * squeeze(velBEAM(iping, ibin, :));
        velENU_new(iping, ibin, :) = R_4beam * velXYZ_temp;
    end
end

% Swap signs in ENU
velENU_new(:, :, 2:4) = -velENU_new(:, :, 2:4);

%% Create output structure

avgout = avg;
avgout.VelocityData = velENU_new;

%% Create diagnostics structure

corrparams.sbgtime_original = sbgtime;
corrparams.sbgtime_corrected = sbgtime_corrected;
corrparams.adcp_time = adcp_time;
corrparams.tlag_seconds = tlag * 24 * 60 * 60;
corrparams.tlag_days = tlag;
corrparams.heading_offset = headoff;
corrparams.max_correlation = max(r);
corrparams.xcorr_r = r;
corrparams.xcorr_lags = lags * sigdt;
corrparams.heading_sbg = heading;
corrparams.pitch_sbg = pitch;
corrparams.roll_sbg = roll;
corrparams.heading_adcp = avg.Heading;
corrparams.pitch_adcp = avg.Pitch;
corrparams.roll_adcp = avg.Roll;

%% Plot diagnostics
fh = figure('Color', 'w');
fullscreen

% Subplot 1: Cross-correlation
subplot(7,1,1)
plot(lags * sigdt, r, 'b-', 'LineWidth', 1.5);
hold on;
plot(lags(imaxr) * sigdt, max(r), 'ro', 'MarkerSize', 10, 'MarkerFaceColor', 'r');
grid on;
ylabel('XC');
title(sprintf('Cross-correlation (lag = %.2f s)', tlag*24*60*60));

% Subplot 2: Angular velocity comparison
subplot(7,1,2)
plot(sigtime, sigangv, 'b-', 'LineWidth', 1);
hold on;
plot(sbgtime_corrected, sbgangv, 'r-', 'LineWidth', 1);
grid on;
ylabel('[\Omega [degs^{-1}]');
legend('ADCP', 'SBG', 'Location', 'best');
title('Angular Velocity');
datetick('x', 'HH:MM:SS', 'keeplimits');

% Subplot 3: Heading comparison
subplot(7,1,3)
plot(adcp_time, avg.Heading, 'b.-');
hold on;
plot(adcp_time, heading, 'r.-');
grid on;
ylabel('H [deg]');
[mean_adcp, std_adcp] = meandir(avg.Heading);
[mean_sbg, std_sbg] = meandir(heading);
legend('ADCP', 'SBG', 'Location', 'best');
title(sprintf('Heading | ADCP: %.1f±%.1f° | SBG: %.1f±%.1f°', mean_adcp, std_adcp, mean_sbg, std_sbg));
datetick('x', 'HH:MM:SS', 'keeplimits');

% Subplot 4: Pitch comparison
subplot(7,1,4)
plot(adcp_time, avg.Pitch, 'b.-');
hold on;
plot(adcp_time, pitch, 'r.-');
grid on;
ylabel('P [deg]');
[mean_adcp, std_adcp] = meandir(avg.Pitch);
[mean_sbg, std_sbg] = meandir(pitch);
legend('ADCP', 'SBG', 'Location', 'best');
title(sprintf('Pitch | ADCP: %.1f±%.1f° | SBG: %.1f±%.1f°', mean_adcp, std_adcp, mean_sbg, std_sbg));

% Subplot 5: Roll comparison
subplot(7,1,5)
plot(adcp_time, avg.Roll, 'b.-');
hold on;
plot(adcp_time, roll, 'r.-');
grid on;
ylabel('R [deg]');
[mean_adcp, std_adcp] = meandir(avg.Roll);
[mean_sbg, std_sbg] = meandir(roll);
title(sprintf('Roll | ADCP: %.1f±%.1f° | SBG: %.1f±%.1f°', mean_adcp, std_adcp, mean_sbg, std_sbg));

% Subplot 6: East velocity (original)
subplot(7,1,6)
pcolor(adcp_time, 1:nbin, squeeze(velENU(:,:,1))');
shading flat;
colorbar;
colormap(cmocean('balance'));
ylabel('Bin');
title('East Velocity - Original (m/s)');
clim([-1 1] * max(abs(velENU(:,:,1)), [], 'all'));

% Subplot 7: East velocity (corrected)
subplot(7,1,7)
pcolor(adcp_time, 1:nbin, squeeze(velENU_new(:,:,1))');
shading flat;
colorbar;
colormap(cmocean('balance'));
ylabel('Bin');
title('East Velocity - SBG Corrected (m/s)');
datetick('x', 'HH:MM:SS', 'keeplimits');
clim([-1 1] * max(abs(velENU_new(:,:,1)), [], 'all'));
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

end