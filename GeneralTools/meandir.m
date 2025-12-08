function [mdir,stddir] = meandir(heading)
% AVGHEAD Calculates the mean direction from a timeseries of heading angles
% Input: heading - vector of heading angles in degrees
% Output: meandir - mean heading angle in degrees

% Grok AI 04/2025

% Compute mean of sine and cosine components
meany = mean(sind(heading),'omitnan');
meanx = mean(cosd(heading),'omitnan');

% Mean resultant length 
r = sqrt(meanx.^2 + meany.^2);

% Compute mean angle using atan2
mdir = atan2d(meany, meanx);

% Ensure output is in [0, 360]
mdir(mdir < 0) = mdir(mdir < 0) + 360;

% Standard deviation
stddir = sqrt(-2*log(r));

end
