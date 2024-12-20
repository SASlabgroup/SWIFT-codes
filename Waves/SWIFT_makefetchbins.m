function [fetchbins,degbincenter]=SWIFT_makefetchbins(obslat, obslon, coastlinelatlon)
%%%%%%%%%%%%%%%%%SWIFT_makefetchbins.m
%
%   Uses lat/lon vector data from GSHHG of alaska to make 9 degree bins for
%   fetch up to range r. These bins can be fitted to wind direction data. 
%   
%   coastline input data must be in table form with .lat and .lon columns
%   obslat - observation latitude
%   obslon - observation longitude
% 
%   output 
%       fetchbins = array 0:binwidth:360 size units in km
%       degbincenter = in deg, centers of bins for direction of fetch
%
%   Created: M. James, December 2024


%% Fetch calculation from lat lon line data 
% (calculate distance to intersection for given deg)
clc
%Initial vars
winddir = [0:9:360]'; % all winddirs 9 degree bins
lat = repmat(obslat,[1,length(winddir)])';
lon = repmat(obslon,[1,length(winddir)])';

%Define radius of fetch calc
r = 1000; %km
r = km2deg(r);

% Set up wind vector
windvx = [lon, lon + sind(winddir).*r]; % x ccw from north
windvy = [lat, lat + cosd(winddir).*r]; % y ccw from north

% Pre-allocate fetch array
fetchbins = NaN(size(winddir));

for k =1:length(winddir);
    % 1 --> 2 first line, 3 --> 4 second line
    % Find intersection points
    [xi, yi] = polyxpoly(windvx(k,:), windvy(k,:), ...
        coastlinelatlon.lon, coastlinelatlon.lat);

    % Check if there is an intersection
    isIntersect = ~isempty(xi);

    if isIntersect
        distance = sqrt((xi-lon(k)).^2 + (yi-lat(k)).^2);
        fetchbins(k) = deg2km(min(distance)); % kmclear
    else
        fetchbins(k) =NaN;
    end
end

degbincenter = winddir(1:end-1) + diff(winddir)/2;