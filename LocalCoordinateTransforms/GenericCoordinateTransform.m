function [ x, y ] = GenericCoordinateTransform(lat,lon,latorigin,lonorigin,rotation)

% function to convert from lat & lon (decimal degrees, negative longitude)
% to local x,y for a given lat/lon field and local origin [latorigin,lonorigin].
% with rotation that is deg CCW from east (i.e. cartesian)
% ** note that rotation from a geographic axis (CW from north) requires the user input rotation as 90 - geographic angle
%
% [ x, y ] = GenericCoordinateTransform(lat,lon,latorigin,lonorigin,rotation)
%
% S. Kastner, 7/2016, adapted from J. Thomosn 1/2011.
%       sometime later J. Thomson made rotation an input 
%           and fixed bug so that local earth radius at a given latitude is used

radius = 6371*cosd(latorigin);

north = 1000*deg2km( lat - latorigin );
east = 1000*deg2km( lon - lonorigin  , radius );

x = east .* cosd(rotation)   -   north .* sind(rotation);

y = east .* sind(rotation)   +   north .* cosd(rotation);

end