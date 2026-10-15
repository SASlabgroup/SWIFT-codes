function [center,shape] = magCalibrationAt(cal,time)
%MAGCALIBRATIONAT Hard-iron center and soft-iron shape at one time.
%
%   [center,shape] = magCalibrationAt(cal,time)
%
%   cal is from fitMagCalibration2D or fitMagCalibration3D; the corrected
%   field is shape*(field - center). Only windows on the same side of
%   cal.breaks are used: the center is interpolated linearly in time (held
%   constant beyond the first/last window) and the shape is that of the
%   nearest window. NaN if that side has no window.
segment = discretize(time,[-Inf; cal.breaks; Inf]);
in = find(cal.segment == segment);
ndim = size(cal.center,2);
center = NaN(1,ndim);
shape = NaN(ndim);
if isempty(in); return; end
t = min(max(time,cal.time(in(1))),cal.time(in(end)));
if isscalar(in)
    center = cal.center(in,:);
else
    center = interp1(cal.time(in),cal.center(in,:),t);
end
[~,nearest] = min(abs(cal.time(in)-t));
shape = cal.shape(:,:,in(nearest));
end
