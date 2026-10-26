function m_in_level = levelMagField(m_in_body,level_in_body)
%LEVELMAGFIELD Express magnetometer samples in the levelled frame.
%
%   m_in_level = levelMagField(m_in_body,level_in_body)
%
%   m_in_body      field samples in a sensor body frame (n x 3).
%   level_in_body  unit vertical axis in the same body frame (n x 3): down
%                  from an attitude solution (readSBGmag), or up from the
%                  accelerometer (readSIGmag).
%
%   The levelled frame turns with the sensor's heading but not its tilt:
%   x is the horizontal projection of the body x axis, y = level x x (to
%   the right, as in NED, when level is down) and z is along level.
%   m_in_level = [X Y Z] (n x 3). With hard and soft iron removed, the
%   magnetic heading of the body x axis is atan2d(-Y,X) and the inclination
%   is atan2d(Z,hypot(X,Y)).
%
% M. LeClair w/ claude, Oct 2026

% Body x axis and the field, each split into its horizontal part
x_in_body = repmat([1 0 0],size(m_in_body,1),1);
xh_in_body = x_in_body - sum(x_in_body.*level_in_body,2).*level_in_body;
xh_in_body = xh_in_body./vecnorm(xh_in_body,2,2);
mh_in_body = m_in_body - sum(m_in_body.*level_in_body,2).*level_in_body;
m_in_level = [sum(mh_in_body.*xh_in_body,2) ...
    sum(mh_in_body.*cross(level_in_body,xh_in_body,2),2) ...
    sum(m_in_body.*level_in_body,2)];
end
