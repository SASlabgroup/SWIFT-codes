function [ x, y ] = GenericCoordinateTransform(lat,lon,latoffset,lonoffset, rotation)

% function to convert from lat & lon (decimal degrees, negative longitude)
% to local x,y for a given lat/lon field and the SWIFT's location
% (latoffset,lonoffset).
%
%
% S. Kastner, 7/2016, adapted from J. Thomosn 1/2011.
%       J. Thomson made rotation an input (deg CCW from True north)
%           and fixed bug so that local radius at a given latitude is used


%rotation = -180;                    % deg CCW from True north
radius = 6371*cosd(latoffset);

north = 1000*deg2km( lat - latoffset );
east = 1000*deg2km(lonoffset - lon , radius );

x = east .* cosd(rotation)   -   north .* sind(rotation);

y = east .* sind(rotation)   +   north .* cosd(rotation);

% x = x;
% 
 y= -y;

end