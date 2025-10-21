function [enu, xyz] = beam2enu(beam, heading, pitch, roll)
% Convert ADCP beam velocities to ENU coordinates
% Inputs:
%   beam    - Beam velocities (Ntime x Nbin x Nbeam, Nbeam=4)
%   heading - Heading in degrees (1 x Ntime)
%   pitch   - Pitch in degrees (1 x Ntime)
%   roll    - Roll in degrees (1 x Ntime)
% Outputs:
%   enu     - ENU velocities [East, North, Up] (Ntime x Nbin x 3)
%   err     - Error velocity (Ntime x Nbin)
%   xyz     - Intermediate instrument coordinates
%
% Assumes uplooking ADCP, 4 beams at 25 degrees from vertical, convex head,
% beam order: 3-1-4-2 (clockwise), positive velocity toward transducer.

%% Instrument Orientation

% Beam angle (degrees)
theta = 25;

% Uplooking or downlooking
uplooking = false;

%% Convert to ENU

% enforce row vectors
heading = heading(:)';
pitch = pitch(:)';
roll = roll(:)';

% Beam to instrument transformation coefficients
a = 1 / (2 * sind(theta)); % ≈ 1.1832
b = 1 / (2 * cosd(theta)); % ≈ 0.5518

% Beam-to-instrument transformation matrix
T = [ a   0  -a   0; ...
      0  -a   0   a; ...
      b   0   b   0; ...
      0   b   0   b];

% Initialize outputs
[nping, nbin, nbeam] = size(beam);
if nbeam ~= 4
    error('Expecting 4-beam data (nping x nbin x nbeam).')
end
xyz = zeros(nping, nbin, 4); % [X, Y, Z1, Z2]
enu = zeros(nping, nbin, 4); % [East, North, Up1, Up2]

% Step 1: Beam to XYZ for each time and bin
for iping = 1:nping
    for ibin = 1:nbin
        xyz(iping, ibin, :) = T * squeeze(beam(iping, ibin, :));
    end
end

% Step 2: XYZ to ENU
for iping = 1:nping
    % Convert angles to radians
    H = deg2rad(heading(iping));
    P = deg2rad(pitch(iping));
    R = deg2rad(roll(iping))+pi; % Uplooking: adjust roll by 180°

    % Rotation matrices
    Rz = [cos(H) -sin(H)  0; ...
         sin(H)   cos(H)  0; ...
          0       0       1];

    Ry = [cos(P)  0   sin(P); ...
          0       1        0; ...
         -sin(P)  0   cos(P)];

    Rx = [1       0        0;  ...
          0   cos(R)  -sin(R); ...
          0   sin(R)   cos(R)];

    % Combined rotation matrix
    R = Rz * Ry * Rx;

    % Convert to 4-beam
    R4 = [R(1,1) R(1,2) R(1,3)/2 R(1,3)/2;
          R(2,1) R(2,2) R(2,3)/2 R(2,3)/2;
          R(3,1) R(3,2) R(3,3)   0;
          R(3,1) R(3,2) 0        R(3,3)];

    % Apply rotation to XYZ velocities for all bins
    for ibin = 1:nbin
        enu(iping, ibin, :) = R4 * squeeze(xyz(iping, ibin, :));
    end
end

% Adjust sign of velocities if downlooking
if ~uplooking
enu(:,:,2:4) = -enu(:,:,2:4);
end


% End function
end