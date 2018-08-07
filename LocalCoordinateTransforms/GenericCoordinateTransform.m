function [ x, y ] = GenericCoordinateTransform(lat,lon,latoffset,lonoffset)

% function to convert from lat & lon (decimal degrees, negative longitude)
% to local x,y for a given lat/lon field and the SWIFT's location
% (latoffset,lonoffset).
%
%
% S. Kastner, 7/2016, adapted from J. Thomosn 1/2011.


rotation = -180;                    % deg CCW from True north
radius = 6371*cos(deg2rad(36));

north = 1000*deg2km( lat - latoffset );
east = 1000*deg2km(lonoffset - lon , radius );

x = east .* cos(deg2rad(rotation))   -   north .* sin (deg2rad(rotation));;

y = east .* sin(deg2rad(rotation))   +   north .* cos (deg2rad(rotation));

% x = x;
% 
 y= -y;

end