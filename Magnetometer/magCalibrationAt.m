function [hardiron,softiron] = magCalibrationAt(cal,time)
%MAGCALIBRATIONAT Hard and soft iron at one time.
%
%   [hardiron,softiron] = magCalibrationAt(cal,time)
%
%   cal is from fitMagCalibration2D (levelled frame) or fitMagCalibration3D
%   (sensor body frame); the corrected field is softiron*(field - hardiron)
%   in that frame. Only windows on the same side of cal.breaks are used:
%   the hard iron is interpolated linearly in time (held constant beyond the
%   first/last window) and the soft iron is that of the nearest window. NaN
%   if that side has no window.
%
% M. LeClair w/ claude, Oct 2026
segment = discretize(time,[-Inf; cal.breaks; Inf]);
in = find(cal.segment == segment);
ndim = size(cal.hardiron,2);
hardiron = NaN(1,ndim);
softiron = NaN(ndim);
if isempty(in); return; end
t = min(max(time,cal.time(in(1))),cal.time(in(end)));
if isscalar(in)
    hardiron = cal.hardiron(in,:);
else
    hardiron = interp1(cal.time(in),cal.hardiron(in,:),t);
end
[~,nearest] = min(abs(cal.time(in)-t));
softiron = cal.softiron(:,:,in(nearest));
end
