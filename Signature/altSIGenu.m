function [bavgvelENU_alt,bavgspdXY,shearXY] = altSIGenu(avg,hh)
% Alternate estimate of burst-averaged ENU velocity profiles from beam velocities using
% mean-heading (hh). Motivated by bad motion in Signature data.
% Can input just mean heading (hh is a scalar), or mean heading, pitch and
% roll (hh is a 3x1 vector);
% Also compute 'scalar shear' from burst-averaged profile of speed in XY
% coordinates. Gives a lower bound for shear when motion data is bad,
% assuming relatively (not quantified..) small amplituded pitch & roll.

% NOTE: ENU alt doesn't work well. Profiles of scalar spd are reasonable. 

% [E;N;U1;U2] = xyz2enu*beam2xyz*[B1;B2;B3;B4];
% [X;Y;Z1;Z2] = xyz2enu\[E;N;U1;U2];
% [B1;B2;B3;B4] = beam2xyz\[X;Y;Z1;Z2];
%
% Names follow Craig (Introduction to Robotics): a_R_b rotates frame b into
% frame a (v_in_a = a_R_b*v_in_b); vectors are <quantity>_rt_<reference>
% _in_<frame> (vel_rt_sig_in_beam: water velocity relative to the
% Signature, in beam coordinates). The two 4 x 4 maps keep Nortek's names
% (Config.avg_beam2xyz); they are linear maps, not rotations: beam2xyz (beam
% -> [X Y Z1 Z2], fixed by the beam geometry) and xyz2enu (a rotation in
% 4-component form, expandToBeamPairs).

% Changelog:
% K. Zeiden Apr 2025
% M. LeClair w/ claude, Oct 2026: vectorized over bins, beam2xyz inverted
%   once, invalid AHRS matrices skipped

% Beam to XYZ4 matrix for Signature 1000. 
%    Can double check by looking at Config.avg_beam2xyz from SD software.
beam2xyz = [1.1831         0   -1.1831         0;
                    0   -1.1831         0    1.1831;
               0.5518         0    0.5518         0;
                    0    0.5518         0    0.5518];

% Assume burst-averaged pitch = 0, roll = 180 if not provided
if length(hh) == 3
    [hh,pp,rr] = deal(hh(1),hh(2),hh(3));
elseif length(hh) == 1
    pp = 0;
    rr = 180;
else
  warning('Wrong number of orientation angles.')
  hh = hh(1);
  pp = 0;
  rr = 180;
end

% Onboard ENU velocities
vel_rt_sig_in_earth4 = avg.VelocityData;
[nping,nbin,~] = size(vel_rt_sig_in_earth4);

% AHRS rotation matrix used in onboard ENU calculation
earth_R_sig_onboard = NaN(nping,3,3);
earth_R_sig_onboard(:,1,1) = avg.AHRS_M11;
earth_R_sig_onboard(:,1,2) = avg.AHRS_M12;
earth_R_sig_onboard(:,1,3) = avg.AHRS_M13;
earth_R_sig_onboard(:,2,1) = avg.AHRS_M21;
earth_R_sig_onboard(:,2,2) = avg.AHRS_M22;
earth_R_sig_onboard(:,2,3) = avg.AHRS_M23;
earth_R_sig_onboard(:,3,1) = avg.AHRS_M31;
earth_R_sig_onboard(:,3,2) = avg.AHRS_M32;
earth_R_sig_onboard(:,3,3) = avg.AHRS_M33;

% Step 1) Revert ENU velocities back to beam velocities -------------------
vel_rt_sig_in_beam = NaN(size(vel_rt_sig_in_earth4));
vel_rt_sig_in_sig4 = NaN(size(vel_rt_sig_in_earth4));
xyz2beam = inv(beam2xyz); % XYZ4 to beam; constant, so inverted once
for iping = 1:nping

    % Expand the 3-D attitude rotation for [X Y Z1 Z2] velocities (XYZ4).
    earth_R_sig = squeeze(earth_R_sig_onboard(iping,:,:));
    xyz2enu = expandToBeamPairs(earth_R_sig);

    % Validate the matrix first
    if any(~isfinite(earth_R_sig),'all') || ... % finite
            rcond(xyz2enu) < 1e-8 || ... % invertible
            abs(det(earth_R_sig)-1) > 0.1 || ... % non-scaling transform
            norm(earth_R_sig*earth_R_sig'-eye(3),'fro') > 0.1 % orthogonal
        continue
    end

    % ENU4 to XYZ4, then XYZ4 to beam coordinates.
    %   ENU4 = [E N U1 U2] and XYZ4 = [X Y Z1 Z2] carry two vertical
    %   components, one per beam pair: Z1 from beams 1 & 3, Z2 from beams
    %   2 & 4 (rows 3-4 of beam2xyz).
    %   Here each ping is nbin x 4 with bins as rows, so the same transforms
    %   are right-multiplies by the transposed inverses, vectorized over bins
    v_rt_sig_in_earth4 = reshape(vel_rt_sig_in_earth4(iping,:,:),nbin,4); % nbin x [E N U1 U2]
    v_rt_sig_in_sig4 = v_rt_sig_in_earth4*inv(xyz2enu)';                  % nbin x [X Y Z1 Z2]
    v_rt_sig_in_beam = v_rt_sig_in_sig4*xyz2beam';                        % nbin x [B1 B2 B3 B4]
    vel_rt_sig_in_sig4(iping,:,:) = reshape(v_rt_sig_in_sig4,1,nbin,4);
    vel_rt_sig_in_beam(iping,:,:) = reshape(v_rt_sig_in_beam,1,nbin,4);

end

% Step 2) Compute burst-average beam velocities --------------------------
bavgvel_rt_sig_in_beam = squeeze(mean(vel_rt_sig_in_beam,1,'omitnan'));

% Step 3) Rotation from the given heading, pitch and roll ----------------
% Z-Y-X Euler angles (Craig) in Nortek's convention: heading clockwise from
% north, pitch with the opposite sign to a Cartesian y rotation (the identity
% fixSIGenu uses, which reproduces the stored AHRS matrices).
earth_R_sig_mean = rotz(90 - hh) * roty(-pp) * rotx(rr);
xyz2enu_mean = expandToBeamPairs(earth_R_sig_mean);

% Step 4) Rotate burst-averaged beam velocities to ENU ------------------
%   For one bin as a column vector, enu4 = xyz2enu_mean*beam2xyz*beam.
%   bavgvel_rt_sig_in_beam is nbin x [B1 B2 B3 B4] with bins as rows, so
%   right-multiply by the transpose.
bavgvelENU_alt = bavgvel_rt_sig_in_beam*(xyz2enu_mean*beam2xyz)'; % nbin x [E N U1 U2]

% Scalar speed in XY coordinates --------------------------
dz = avg.CellSize;
spdXY = squeeze(sqrt(vel_rt_sig_in_sig4(:,:,1).^2 + vel_rt_sig_in_sig4(:,:,2).^2));
bavgspdXY = mean(spdXY,'omitnan')';
shearXY = gradient(bavgspdXY)./dz;

end

function R = rotz(angle)
% Rotation about z by angle (deg), Craig's R_Z.
R = [cosd(angle) -sind(angle) 0;
     sind(angle)  cosd(angle) 0;
     0            0           1];
end

function R = roty(angle)
% Rotation about y by angle (deg), Craig's R_Y.
R = [ cosd(angle) 0 sind(angle);
      0           1 0;
     -sind(angle) 0 cosd(angle)];
end

function R = rotx(angle)
% Rotation about x by angle (deg), Craig's R_X.
R = [1 0            0;
     0 cosd(angle) -sind(angle);
     0 sind(angle)  cosd(angle)];
end

function xyz2enu = expandToBeamPairs(earth_R_sig)
% earth_R_sig in 4-component form, acting on [X Y Z1 Z2] -> [E N U1 U2]: each
% vertical component (one per beam pair) contributes half to E and N.
xyz2enu = [earth_R_sig(1,1) earth_R_sig(1,2) earth_R_sig(1,3)/2 earth_R_sig(1,3)/2;
           earth_R_sig(2,1) earth_R_sig(2,2) earth_R_sig(2,3)/2 earth_R_sig(2,3)/2;
           earth_R_sig(3,1) earth_R_sig(3,2) earth_R_sig(3,3)   0;
           earth_R_sig(3,1) earth_R_sig(3,2) 0                  earth_R_sig(3,3)];
end
