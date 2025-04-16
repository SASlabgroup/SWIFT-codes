function [xyspd,xyshear] = scalarshearSIG(avg)
% Estimate burst-averaged scalar shear from velocity data in 
%  instrument coordinates. Revert to XYZ using AHRS rotation matrix.
%  Motivated by bad motion data in Sig1000.
% Assumes pitch & roll are negligible.

% [X;Y;Z] = inv(R)*[E;N;U];

% K. Zeiden Apr 2025

% Onboard ENU velocities
velENU = avg.VelocityData;
[nping,nbin,~] = size(velENU);

% Bin size
dz = avg.CellSize;

% AHRS rotation matrix used in onboard ENU calculation
R_ahrs = NaN(nping,3,3);
R_ahrs(:,1,1) = avg.AHRS_M11;
R_ahrs(:,1,2) = avg.AHRS_M12;
R_ahrs(:,1,3) = avg.AHRS_M13;
R_ahrs(:,2,1) = avg.AHRS_M21;
R_ahrs(:,2,2) = avg.AHRS_M22;
R_ahrs(:,2,3) = avg.AHRS_M23;
R_ahrs(:,3,1) = avg.AHRS_M31;
R_ahrs(:,3,2) = avg.AHRS_M32;
R_ahrs(:,3,3) = avg.AHRS_M33;

% Revert ENU velocities back to XYZ coordinates -------------------
velXYZ = NaN(size(velENU));
for iping = 1:nping

    % Use onboard AHRS matrix & convert to 4-beam
    R = squeeze(R_ahrs(iping,:,:));
    R = [R(1,1) R(1,2) R(1,3)/2 R(1,3)/2;
          R(2,1) R(2,2) R(2,3)/2 R(2,3)/2;
          R(3,1) R(3,2) R(3,3)   0;
          R(3,1) R(3,2) 0        R(3,3)];

    % ENU to Beam
    for ibin = 1:nbin
        velXYZ(iping,ibin,:) = R\squeeze(velENU(iping,ibin,:));
    end

end

% Compute scalar speed in beam coordinates
spdXY = squeeze(sqrt(velXYZ(:,:,1).^2 + velXYZ(:,:,2).^2));

% Burst-average and compute shear
xyspd = mean(spdXY,'omitnan')';
xyshear = gradient(xyspd)./dz;

end