function [nomz, truez] = correctSIGdepths(burst) 
% correctSIGdepths Correct Sig1000 HR ADCP vertical (i.e. center beam) bin depths using AHRS pitch, roll, pressure
%
% Input:
%   data - either 'burst' or 'avg', gleans beam angle .

% Outputs:
%   corrected_depths - Corrected bin depths (m), size [n_bins, n_times].

% Beam angle (vertical beam)
beam_angle = 0; % left in so could modify for slant beams if desired.

% Transducer depth
xz = 0.2;

% Bobbing induced changes in depth
pressure = burst.Pressure;
bobz = pressure - mean(pressure,'omitnan');

% Pitch and Roll
pitch = burst.Pitch;
roll = burst.Roll;
if mean(abs(roll)) > 100
    roll(roll<0) = roll(roll<0)+360;
    roll = roll-180;
end

% Number of bins
nbin = size(burst.VelocityData,2);

% Nominal bin depths
nomz = xz + burst.Blanking + burst.CellSize*(1:nbin)';

% Calculate total tilt angle (magnitude of pitch and roll)
tilt = sqrt(pitch.^2 + roll.^2);

% Effective angle for depth correction: tilt + beam angle
trueangle = tilt + beam_angle;

% Correct depths: add pressure-derived depth and adjust for effective angle
% truez = (nomz + bobz) .* cosd(trueangle);
truez = bobz + nomz*cosd(trueangle);

end