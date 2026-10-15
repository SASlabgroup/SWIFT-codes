function [bavgvelENU_alt,bavgspdXY,shearXY] = altSIGenu(avg,hh)
% Alternate estimate of burst-averaged ENU velocity profiles from beam velocities using
% mean-heading (hh). Motivated by bad motion in Signature data.
% Can input just mean heading (hh is a scalar), or mean heading, pitch and
% roll (hh is a 3x1 vector);
% Also compute 'scalar shear' from burst-averaged profile of speed in XY
% coordinates. Gives a lower bound for shear when motion data is bad,
% assuming relatively (not quantified..) small amplituded pitch & roll.

% NOTE: ENU alt doesn't work well. Profiles of scalar spd are reasonable. 

% [E;N;U] = R*T*[B1;B2;B3;B4];
% [B1;B2;B3;B4] = inv(T)*inv(R)*[E;N;U];
% [E;N;U] = R*[X;Y;Z];
% [X;Y;Z] = inv(R)*[E;N;U];

% K. Zeiden Apr 2025

% Beam to XYZ transformation matrix for Signature 1000. 
%    Can double check by looking at Config.avg_beam2xyz from SD software.
T_AHRS = [1.1831         0   -1.1831         0;
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
velENU = avg.VelocityData;
[nping,nbin,~] = size(velENU);

% AHRS rotation matrix used in onboard ENU calculation
R_AHRS = NaN(nping,3,3);
R_AHRS(:,1,1) = avg.AHRS_M11;
R_AHRS(:,1,2) = avg.AHRS_M12;
R_AHRS(:,1,3) = avg.AHRS_M13;
R_AHRS(:,2,1) = avg.AHRS_M21;
R_AHRS(:,2,2) = avg.AHRS_M22;
R_AHRS(:,2,3) = avg.AHRS_M23;
R_AHRS(:,3,1) = avg.AHRS_M31;
R_AHRS(:,3,2) = avg.AHRS_M32;
R_AHRS(:,3,3) = avg.AHRS_M33;

% Step 1) Revert ENU velocities back to beam velocities -------------------
velBEAM = NaN(size(velENU));
velXYZ = NaN(size(velENU));
invT_AHRS = inv(T_AHRS); % XYZ4 to beam; constant, so inverted once
for iping = 1:nping

    % Expand the 3-D attitude rotation for [X Y Z1 Z2] velocities (XYZ4).
    R_attitude = squeeze(R_AHRS(iping,:,:));
    R_velocity4 = [R_attitude(1,1) R_attitude(1,2) R_attitude(1,3)/2 R_attitude(1,3)/2;
                   R_attitude(2,1) R_attitude(2,2) R_attitude(2,3)/2 R_attitude(2,3)/2;
                   R_attitude(3,1) R_attitude(3,2) R_attitude(3,3)                   0;
                   R_attitude(3,1) R_attitude(3,2) 0                  R_attitude(3,3)];

    % Validate the matrix first
    if any(~isfinite(R_attitude),'all') || ... % finite
            rcond(R_velocity4) < 1e-8 || ... % invertible
            abs(det(R_attitude)-1) > 0.1 || ... % non-scaling transform
            norm(R_attitude*R_attitude'-eye(3),'fro') > 0.1 % orthogonal
        continue
    end

    % ENU4 to XYZ4, then XYZ4 to beam coordinates.
    %   ENU4 = [E N U1 U2] and XYZ4 = [X Y Z1 Z2] carry two vertical
    %   components, one per beam pair: Z1 from beams 1 & 3, Z2 from beams
    %   2 & 4 (rows 3-4 of T_AHRS).
    %   Here each ping is nbin x 4 with bins as rows, so the same transforms
    %   are right-multiplies by the transposed inverses, vectorized over bins
    pingENU4 = reshape(velENU(iping,:,:),nbin,4); % nbin x [E N U1 U2]
    pingXYZ4 = pingENU4*inv(R_velocity4)';         % nbin x [X Y Z1 Z2]
    pingBEAM = pingXYZ4*invT_AHRS';                % nbin x [B1 B2 B3 B4]
    velXYZ(iping,:,:) = reshape(pingXYZ4,1,nbin,4);
    velBEAM(iping,:,:) = reshape(pingBEAM,1,nbin,4);

end

% Step 2) Compute burst-average beam velocities --------------------------
bavgvelBEAM = squeeze(mean(velBEAM,1,'omitnan'));

% Step 3) Compute HPR rotation matrix  -----------------------------------

% Beam-to-xyz coordinate-transformation matrix
%   Note: sign change to accounting for instrument orientation
T = T_AHRS;
T(2:4,:) = -T(2:4,:);

% HPR rotation matrix
Rz = [cosd(hh) -sind(hh) 0;
      sind(hh) cosd(hh) 0;
      0   0  1 ];
Ry = [cosd(pp) 0 sind(pp);
      0 1 0;
      -sind(pp) 0 cosd(pp)];
Rx = [1 0 0;
      0 cosd(rr) -sind(rr);
      0 sind(rr) cosd(rr)];
R = Rz*Ry*Rx;
R = [R(1,1) R(1,2) R(1,3)/2 R(1,3)/2;
     R(2,1) R(2,2) R(2,3)/2 R(2,3)/2;
     R(3,1) R(3,2) R(3,3)   0;
     R(3,1) R(3,2) 0        R(3,3)];

% Step 4) Rotate burst-averaged beam velocities to ENU ------------------
%   For one bin as a column vector, enu4 = R*T*beam. bavgvelBEAM is
%   nbin x [B1 B2 B3 B4] with bins as rows, so right-multiply by (R*T)'.
bavgvelENU_alt = bavgvelBEAM*(R*T)'; % nbin x [E N U1 U2]

% Swap signs in ENU
bavgvelENU_alt(:,2:4) = -bavgvelENU_alt(:,2:4);

% Scalar speed in XY coordinates --------------------------
dz = avg.CellSize;
spdXY = squeeze(sqrt(velXYZ(:,:,1).^2 + velXYZ(:,:,2).^2));
bavgspdXY = mean(spdXY,'omitnan')';
shearXY = gradient(bavgspdXY)./dz;

end
