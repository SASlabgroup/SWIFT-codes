function [enu, xyz, err] = beam2enu(beam, heading, pitch, roll)
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

% enforce row vectors
heading = heading(:)';
pitch = pitch(:)';
roll = roll(:)';

% Beam angle (degrees)
theta = 25;

% Beam to instrument transformation coefficients
a = 1 / (2 * sind(theta)); % ≈ 1.1832
b = 1 / (4 * cosd(theta)); % ≈ 0.2759
d = a / sqrt(2);           % ≈ 0.8365

% Beam-to-instrument transformation matrix
beam2xyz = [ a, -a,  0,  0; ...
             0,  0, -a,  a; ...
             b,  b,  b,  b; ...
             d,  d, -d, -d];

% Initialize outputs
[nt, nbin, ~] = size(beam);
xyz = zeros(nt, nbin, 4); % [X, Y, Z, err]
enu = zeros(nt, nbin, 3); % [East, North, Up]

% Step 1: Beam to XYZ for each time and bin
for it = 1:nt
    for bin = 1:nbin
        xyz(it, bin, :) = beam2xyz * squeeze(beam(it, bin, :));
    end
end
err = xyz(:,:,4); % Extract error velocity
xyz = xyz(:,:,1:3);

% Step 2: XYZ to ENU
for it = 1:nt
    % Convert angles to radians
    H = deg2rad(heading(it));
    P = deg2rad(pitch(it));
    R = deg2rad(roll(it) + 180); % Uplooking: adjust roll by 180°

    % Rotation matrices
    heading_matrix = [cos(H), sin(H), 0; ...
                    -sin(H), cos(H), 0; ...
                     0,      0,      1];
    pitch_matrix = [cos(P),  0, -sin(P); ...
                    0,       1,  0;      ...
                    sin(P),  0,  cos(P)];
    roll_matrix = [1, 0,       0;      ...
                   0, cos(R), -sin(R); ...
                   0, sin(R),  cos(R)];

    % Combined rotation matrix
    M = heading_matrix * pitch_matrix * roll_matrix;

    % Apply rotation to XYZ velocities for all bins
    for bin = 1:nbin
        enu(it, bin, :) = M * squeeze(xyz(it, bin, :));
    end
end

% End function
end