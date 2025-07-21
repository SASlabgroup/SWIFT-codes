function [truez,deltax] = correctADCPdepths(nomz,pressure,pitch,roll) 
% correctSIGdepths Correct Sig1000 HR ADCP vertical (i.e. center beam) bin depths using AHRS pitch, roll, pressure
%
% Input:
% nominal bin depths (no rotation or displacement), pressure (dbar), pitch & roll

% Outputs:
%   true bin depths

% Bobbing induced changes in depth
bobz = pressure - mean(pressure,'omitnan');

% Pitch and Roll
if mean(abs(roll)) > 100
    roll(roll<0) = roll(roll<0)+360;
    roll = roll-180;
end

% Calculate total tilt angle (magnitude of pitch and roll)
tilt = sqrt(pitch.^2 + roll.^2);

% Correct depths: add pressure-derived depth and adjust for effective angle
truez = bobz + nomz*cosd(tilt);

% Horizontal displacement
deltax = nomz*sind(tilt);

end