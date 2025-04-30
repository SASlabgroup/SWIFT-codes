function dir = meandir(heading)
% AVGHEAD Calculates the mean direction from a timeseries of heading angles
% Input: heading - vector of heading angles in degrees
% Output: meandir - mean heading angle in degrees

% Grok AI 04/2025

% Convert degrees to radians
heading = deg2rad(heading);

% Compute mean of sine and cosine components
meanx = mean(sin(heading),'omitnan');
meany = mean(cos(heading),'omitnan');

% Compute mean angle using atan2
dir = rad2deg(atan2(meanx, meany));

% Ensure output is in [0, 360)
if dir < 0
    dir = dir + 360;
end

end