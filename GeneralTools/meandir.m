function [mdir,stddir] = meandir(heading)
% MEANDIR Calculates the mean direction from a timeseries of heading angles
% Input: heading - vector of heading angles in degrees (any range)
% Output: mdir - mean heading angle in degrees
%         stddir - circular standard deviation in degrees
%
% This function works for angles in any range (e.g., -180 to 180, 0 to 360)
% and returns the mean in the same range as the input data.
%
% Modified from original by K. Zeiden, Dec 2025

% Remove NaNs for calculation
valid = ~isnan(heading);
heading_valid = heading(valid);

if isempty(heading_valid)
    mdir = NaN;
    stddir = NaN;
    return;
end

% Compute mean of sine and cosine components
meany = mean(sind(heading_valid));
meanx = mean(cosd(heading_valid));

% Mean resultant length 
r = sqrt(meanx.^2 + meany.^2);

% Compute mean angle using atan2
mdir = atan2d(meany, meanx);

% Convert output to match the range of input data
% If input is mostly negative or spans -180 to 180, keep in that range
% If input is in 0-360 range, convert to that range
min_input = min(heading_valid);
max_input = max(heading_valid);

if min_input < 0 && max_input < 180
    % Data is in -180 to 180 range, keep mdir in that range
    % mdir is already in -180 to 180 from atan2d
elseif min_input >= 0 && max_input > 180
    % Data is in 0 to 360 range
    if mdir < 0
        mdir = mdir + 360;
    end
else
    % Data spans a wide range, use circular distance to determine best representation
    % Check which representation (0-360 or -180 to 180) is closer to the data centroid
    mean_input = mean(heading_valid);
    mdir_360 = mdir;
    if mdir_360 < 0
        mdir_360 = mdir_360 + 360;
    end
    
    % Use the representation closer to the arithmetic mean of inputs
    if abs(mdir - mean_input) < abs(mdir_360 - mean_input)
        % Keep as is (-180 to 180)
    else
        mdir = mdir_360;
    end
end

% Circular standard deviation in degrees
stddir = sqrt(-2*log(r)) * 180/pi;

end