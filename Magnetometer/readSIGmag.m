function [m,d,heading] = readSIGmag(avg)
%READSIGMAG Raw Signature magnetometer samples with the accelerometer direction.
%
%   [m,d,heading] = readSIGmag(avg)
%
%   avg      the averaged-data struct of a Signature burst file.
%   m        avg.Magnetometer, the raw body-frame field (n x 3). The
%            Signature stores the raw field so that the hard iron can be
%            calibrated in post-processing (Nortek Signature Operations
%            manual).
%   d        avg.Accelerometer normalized. With levelMagField, this is the
%            convention that reproduces the onboard avg.Heading as
%            atan2d(-Y,X); it points up, so the inclination in this frame
%            is negative.
%   heading  onboard avg.Heading, deg (magnetic if the instrument
%            declination, DECL, is 0).
%
%   Samples are kept if the field and acceleration are finite.

m = zeros(0,3); d = zeros(0,3); heading = zeros(0,1);
if ~all(isfield(avg,{'Magnetometer','Accelerometer','Heading'})); return; end
field = double(avg.Magnetometer);
accel = double(avg.Accelerometer);
onboard = double(avg.Heading(:));
if size(field,2) ~= 3 || ~isequal(size(field),size(accel)) || ...
        numel(onboard) ~= size(field,1)
    return
end
valid = all(isfinite([field accel]),2) & vecnorm(accel,2,2) > 0;
m = field(valid,:);
d = accel(valid,:)./vecnorm(accel(valid,:),2,2);
heading = onboard(valid);
end
