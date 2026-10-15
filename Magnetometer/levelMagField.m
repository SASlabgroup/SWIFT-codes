function [X,Y,Z] = levelMagField(m,d)
%LEVELMAGFIELD Express magnetometer samples in the levelled body frame.
%
%   [X,Y,Z] = levelMagField(m,d)
%
%   m   body-frame field samples (n x 3).
%   d   unit "down" vectors in the same body frame (n x 3), e.g. from an
%       attitude solution or minus the normalized accelerometer.
%
%   X is the field along the horizontal projection of the body x axis, Y
%   along d x X (to the right, as in NED), Z = m.d (down). With hard and
%   soft iron removed, the magnetic heading of the body x axis is
%   atan2d(-Y,X) and the inclination is atan2d(Z,hypot(X,Y)).
x = repmat([1 0 0],size(m,1),1);
xh = x - sum(x.*d,2).*d;
xh = xh./vecnorm(xh,2,2);
h = m - sum(m.*d,2).*d;
X = sum(h.*xh,2);
Y = sum(h.*cross(d,xh,2),2);
Z = sum(m.*d,2);
end
