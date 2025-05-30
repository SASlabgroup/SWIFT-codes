function [mdir,stddir] = meandir(heading)
% AVGHEAD Calculates the mean direction from a timeseries of heading angles
% Input: heading - vector of heading angles in degrees
% Output: meandir - mean heading angle in degrees

% Grok AI 04/2025

% Convert degrees to radians
heading = deg2rad(heading);

% Compute mean of sine and cosine components
meany = mean(sin(heading),'omitnan');
meanx = mean(cos(heading),'omitnan');

% Mean resultant length 
r = sqrt(meanx.^2 + meany.^2);

% Compute mean angle using atan2
mdir = rad2deg(atan2(meany, meanx));

% Ensure output is in [0, 360]
if mdir < 0
    mdir = mdir + 360;
end

% Standard deviation
stddir = sqrt(-2*log(r));

end
