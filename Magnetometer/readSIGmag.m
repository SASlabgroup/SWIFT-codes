function [m_in_sig,up_in_sig,heading] = readSIGmag(avg)
%READSIGMAG Raw Signature magnetometer samples with the accelerometer direction.
%
%   [m_in_sig,up_in_sig,heading] = readSIGmag(avg)
%
%   avg      the averaged-data struct of a Signature burst file.
%   m_in_sig   avg.Magnetometer, the raw field in the Signature body frame
%              (n x 3). The Signature stores the raw field so that the hard
%              iron can be calibrated in post-processing (Nortek Signature
%              Operations manual).
%   up_in_sig  avg.Accelerometer normalized: the up axis in the Signature
%              body frame. Used as the levelling vector (levelMagField), it
%              reproduces the onboard avg.Heading as atan2d(-Y,X); because
%              it points up, the inclination in this frame is negative.
%   heading  onboard avg.Heading, deg (magnetic if the instrument
%            declination, DECL, is 0).
%
%   Samples are kept if the field and acceleration are finite.
%
% M. LeClair w/ claude, Oct 2026

m_in_sig = zeros(0,3); up_in_sig = zeros(0,3); heading = zeros(0,1);
if ~all(isfield(avg,{'Magnetometer','Accelerometer','Heading'})); return; end
field = double(avg.Magnetometer);
accel = double(avg.Accelerometer);
onboard = double(avg.Heading(:));
if size(field,2) ~= 3 || ~isequal(size(field),size(accel)) || ...
        numel(onboard) ~= size(field,1)
    return
end
valid = all(isfinite([field accel]),2) & vecnorm(accel,2,2) > 0;
m_in_sig = field(valid,:);
up_in_sig = accel(valid,:)./vecnorm(accel(valid,:),2,2);
heading = onboard(valid);
end
