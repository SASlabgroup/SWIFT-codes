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
    pp = hh(2);
    rr = hh(3);
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
for iping = 1:nping

    % Use onboard AHRS matrix & convert to 4-beam
    R = squeeze(R_AHRS(iping,:,:));
    R = [R(1,1) R(1,2) R(1,3)/2 R(1,3)/2;
          R(2,1) R(2,2) R(2,3)/2 R(2,3)/2;
          R(3,1) R(3,2) R(3,3)   0;
          R(3,1) R(3,2) 0        R(3,3)];

    % ENU to Beam
    for ibin = 1:nbin
        velXYZ(iping,ibin,:) = inv(R)*squeeze(velENU(iping,ibin,:));
        velBEAM(iping,ibin,:) = inv(T_AHRS)*squeeze(velXYZ(iping,ibin,:));
    end

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
bavgvelENU_alt = NaN(size(bavgvelBEAM));
for ibin = 1:nbin
    bavgvelENU_alt(ibin,:) = R*T*bavgvelBEAM(ibin,:)';
end

% Swap signs in ENU
bavgvelENU_alt(:,2:4) = -bavgvelENU_alt(:,2:4);

% Scalar speed in XY coordinates --------------------------
dz = avg.CellSize;
spdXY = squeeze(sqrt(velXYZ(:,:,1).^2 + velXYZ(:,:,2).^2));
bavgspdXY = mean(spdXY,'omitnan')';
shearXY = gradient(bavgspdXY)./dz;

end