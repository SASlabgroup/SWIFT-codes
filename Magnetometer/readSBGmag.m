function [m,d,yaw] = readSBGmag(sbgData)
%READSBGMAG Healthy SBG magnetometer samples with the EKF attitude.
%
%   [m,d,yaw] = readSBGmag(sbgData)
%
%   m    Mag samples in the SBG body frame (n x 3), as logged (already
%        corrected by the onboard calibration, if any).
%   d    unit down vectors in the body frame from the EKF roll/pitch at the
%        mag samples (NED convention).
%   yaw  EKF yaw at the mag samples, deg.
%
%   Samples are kept if the mag status passes (X/Y/Z BIT, in range,
%   calibration OK; sbgECom 5.8 sbgEComLogMag.h) and the values are finite
%   and plausible: some records contain corrupt finite Euler angles (e.g.
%   1e21 rad) and mag values (e.g. 1e37) that pass the status flags.
%
% mleclair (using claude), Oct 2026

m = zeros(0,3); d = zeros(0,3); yaw = zeros(0,1);
if ~all(isfield(sbgData,{'Mag','EkfEuler'})); return; end
ekf = sbgData.EkfEuler;
mag = sbgData.Mag;
angle = double([ekf.roll(:) ekf.pitch(:) ekf.yaw(:)]);
good = all(abs(angle) <= pi,2);
% interp1 needs unique sample times.
[ekftime,iu] = unique(double(ekf.time_stamp(good))/1e6);
angle = angle(good,:);
angle = angle(iu,:);
[magtime,im] = unique(double(mag.time_stamp(:))/1e6);
if numel(ekftime) < 2 || numel(magtime) < 2; return; end
field = double([mag.mag_x(:) mag.mag_y(:) mag.mag_z(:)]);
field = field(im,:);
status = uint16(mag.mag_status(:));
status = status(im);

roll = circularInterp(ekftime,angle(:,1),magtime);
pitch = interp1(ekftime,angle(:,2),magtime);
heading = circularInterp(ekftime,angle(:,3),magtime)*180/pi;
down = [-sin(pitch) sin(roll).*cos(pitch) cos(roll).*cos(pitch)];

valid = healthyMagStatus(status) & all(abs(field) < 10,2) & ...
    all(isfinite([field down heading]),2);
m = field(valid,:);
d = down(valid,:);
yaw = heading(valid);
end

function tf = healthyMagStatus(status)
% X/Y/Z magnetometer BIT, magnetometers in range, and calibration OK.
required = uint16(2^0+2^1+2^2+2^6+2^8);
tf = bitand(status,required) == required;
end

function angleout = circularInterp(time,angle,newtime)
% Interpolate an angle (rad) as a unit vector so it does not jump at +/-pi.
angleout = atan2(interp1(time,sin(angle),newtime),interp1(time,cos(angle),newtime));
end
