function [ x, y ] = FRFtransform(lat,lon);

% function to convert from lat & lon (decimal degrees, negative longitude)
% to FRF x,y (meters)
%
% function [ x y ] = FRFtransform(lat,lon);
%
% J. Thomson, 1/2011
 
latoffset = 36.178039; 
lonoffset = -75.749672;


rotation = 19; % deg CCW from True north
radius = 6371*cos(deg2rad(36));

north = 1000*deg2km( lat - latoffset );
east = 1000*deg2km(lonoffset - lon , radius );

x = east .* cos(deg2rad(rotation))   -   north .* sin (deg2rad(rotation));;

y = east .* sin(deg2rad(rotation))   +   north .* cos (deg2rad(rotation));

x = - x;
