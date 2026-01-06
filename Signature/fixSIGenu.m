function [avgout, cparams, fh] = fixSIGenu(avg, burst, sbgData, hoffgiven)
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
if nargin < 4 || isempty(hoffgiven)
    compute_offset = true;
else
    compute_offset = false;
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

% Good timestamps
[~,iuekf] = unique(sbgData.EkfEuler.time_stamp);
[~,iuutc] = unique(sbgData.UtcTime.time_stamp);
[~,iuimu] = unique(sbgData.ImuData.time_stamp);

% Build SBG UTC time
sbgtime = [sbgData.UtcTime.year(iuutc)' sbgData.UtcTime.month(iuutc)' sbgData.UtcTime.day(iuutc)'...
    sbgData.UtcTime.hour(iuutc)' sbgData.UtcTime.min(iuutc)' sbgData.UtcTime.sec(iuutc)'];
sbgtime = datenum(sbgtime);
sbgtime = sbgtime' + sbgData.UtcTime.nanosec(iuutc)./((10^9)*60*60*24);

% SBG orientation data (convert from radians to degrees)
sbgpitch = interp1(sbgData.EkfEuler.time_stamp(iuekf), sbgData.EkfEuler.pitch(iuekf), ...
                   sbgData.UtcTime.time_stamp(iuutc)) * 180/pi;
sbgroll = interp1(sbgData.EkfEuler.time_stamp(iuekf), sbgData.EkfEuler.roll(iuekf), ...
                  sbgData.UtcTime.time_stamp(iuutc)) * 180/pi;
sbgyaw = interp1(sbgData.EkfEuler.time_stamp(iuekf), sbgData.EkfEuler.yaw(iuekf), ...
                 sbgData.UtcTime.time_stamp(iuutc)) * 180/pi;

% Force SBG roll to 180 to match ADCP
sbgroll = sbgroll + 180;
sbgroll = wrapToPi(sbgroll*pi/180)*180/pi;

% SBG gyroscope data (convert from radians/s to degrees/s)
sbggyrox = interp1(sbgData.ImuData.time_stamp(iuimu), sbgData.ImuData.gyro_x(iuimu), ...
                   sbgData.UtcTime.time_stamp(iuutc)) * 180/pi;
sbggyroy = interp1(sbgData.ImuData.time_stamp(iuimu), sbgData.ImuData.gyro_y(iuimu), ...
                   sbgData.UtcTime.time_stamp(iuutc)) * 180/pi;
sbggyroz = interp1(sbgData.ImuData.time_stamp(iuimu), sbgData.ImuData.gyro_z(iuimu), ...
                   sbgData.UtcTime.time_stamp(iuutc)) * 180/pi;

% Compute angular velocity
sbgangv = sqrt(sbggyrox.^2 + sbggyroy.^2 + sbggyroz.^2);

%% Fix SBG time
sbgdt = (1/5)/(60*60*24);
tmin = min(sigtime) - 1/24;
tmax = max(sigtime) + 1/24;
istart = find(sbgtime >= tmin & sbgtime <=tmax,1,'first');
sbgtime = sbgdt*((1:length(sbgtime))-istart) + sbgtime(istart);

% Skip burst if times are way off...
toff = min(sbgtime)-min(sigtime);
if toff > 12/(24*60)
    disp('No timeseries overlap...')
    avgout = [];
    cparams = [];
    fh = [];
    return
end

%% Compute time lag via cross-correlation

% Interpolate to high res time grid (10 Hz)
dt = (1/10)/(24*60*60); % days
ctime = max([min(sbgtime) min(sigtime)]):dt:min([max(sbgtime) max(sigtime)]);
csbgangv = interp1(sbgtime, sbgangv, ctime);
csigangv = interp1(sigtime, sigangv, ctime);

% Cross-correlate to find lag (max lag 100 s)
[r,lags] = xcorr(csbgangv,csigangv,1000,'unbiased');
[~, imaxr] = max(r);
tlag = lags(imaxr) * dt; % days

% Apply time shift to SBG data
sbgtime_corrected = sbgtime - tlag;

%% Interpolate SBG orientation to ADCP timestamps

adcp_time = avg.time;
heading = interp1(sbgtime_corrected, unwrap(sbgyaw*pi/180)*180/pi, adcp_time);
heading = wrapToPi(heading*pi/180)*180/pi;
pitch = interp1(sbgtime_corrected, sbgpitch, adcp_time);
roll = interp1(sbgtime_corrected, sbgroll, adcp_time);

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

% Scalar speed
bavgspd = mean(squeeze(velENU_new(:,:,1).^2 + velENU_new(:,:,2).^2),'omitnan');

%% Create output structure

avgout = avg;
avgout.VelocityData = velENU_new;

%% Create diagnostics structure
cparams.toff = toff;
cparams.tlag = tlag;
cparams.hoff = hoffdata;
cparams.mheading = meandir(sbgyaw);
cparams.mpitch = meandir(sbgpitch);
cparams.mroll = meandir(sbgroll);

%% Plot diagnostics
fh = figure('Color', 'w');
fullscreen

% Subplot 1: Cross-correlation
subplot(7,1,1)
plot(lags * dt*24*60*60, r, 'b-', 'LineWidth', 1.5);
hold on;
plot(lags(imaxr) * dt*24*60*60, max(r), 'ro', 'MarkerSize', 10, 'MarkerFaceColor', 'r');
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

end