%function [BEAM,ENU,XYZ] = coordtransSIG(v1,v2,v3,v4,T,coord,head,pitch,roll)

% Function first inverts the projection of the true velocity onto beam
% coordinates, to recover the 3D velocities.
%   (e.g. |B1| = |Ux|cos(90-bangle), |B2| = |Uy|cos(90-bangle), 
%   then |Ux| = (1/2)(|B1|/cos(90-bangle) + |B2|/cos(90-bangle))
% Then rotates into the ENU coordinate system using known attitude (pitch,
% roll heading).

    % (Beam-to-XYZ transformation matrix). You can derive by thinking about the projection of Ux onto
    %               the beam directions (i.e. B1 = |Ux|cos(bangle), so Ux =
    %               B1/cos(bangle). Then average between the two beams in
    %               that plane.

% Input: Data + Configuration information, e.g.:
    % coord = Config.Average_CoordSystem; (i.e. 'ENU','BEAM' or 'XYZ')
    % v1 = double(Data.Average_VelBeam1); (e.g. if in 'BEAM' coordinates, and using the broadbeam data)
    % v2 = double(Data.Average_VelBeam2);
    % v3 = double(Data.Average_VelBeam3);
    % v4 = double(Data.Average_VelBeam4);
    % head = double(Data.Average_Heading);
    % pitch = double(Data.Average_Pitch);
    % roll = double(Data.Average_Roll);
    % B2X = Config.Average_Beam2xyz; 

% Output: Matrices of velocities in ENU, XYZ and BEAM coorinates:
    % X = XYZ(:,:,1); 
    % Y = XYZ(:,:,2);
    % Z1 = XYZ(:,:,3); 
    % Z2 = XYZ(:,:,4);
    % B1 = BEAM(:,:,1); 
    % B2 = BEAM(:,:,2);
    % B3 = BEAM(:,:,3); 
    % B4 = BEAM(:,:,4);
    % E = ENU(:,:,1); 
    % N = ENU(:,:,2);
    % U1 = ENU(:,:,3); 
    % U2 = ENU(:,:,4);

% Testing
load('WW_Sig_30Apr2024.mat')
coord = Config.Burst_CoordSystem; 
v1 = Data.BurstHR_VelBeam1;
v2 = Data.BurstHR_VelBeam2;
v3 = Data.BurstHR_VelBeam3;
v4 = Data.BurstHR_VelBeam4;
head = double(Data.BurstHR_Heading);
pitch = double(Data.BurstHR_Pitch);
roll = double(Data.BurstHR_Roll);
B2X = Config.Burst_Beam2xyz; 

%% Create Transformation Matrix

% Duplicate B2X for all pings
[nping,nbin] = size(v1);
B2X = repmat(B2X,[1 1 nping]);

% Convert attitude angles from degrees to radians
head = pi*(head-90)/180;
pitch = pi*pitch/180;
roll = pi*roll/180;

% Make heading and tilt transformation matrices
H = zeros(3,3,nping);
PR = zeros(3,3,nping);
for i = 1:nping

    H(:,:,i) = [cos(head(i)) sin(head(i)) 0; ...
                -sin(head(i)) cos(head(i)) 0; ...
                            0 0 1];

    PR(:,:,i) = [cos(pitch(i)) -sin(pitch(i))*sin(roll(i)) -cos(roll(i))*sin(pitch(i)); ...
                                        0 cos(roll(i)) -sin(roll(i)); ...
                sin(pitch(i)) sin(roll(i))*cos(pitch(i)) cos(pitch(i))*cos(roll(i))];
end

% Full XYZ-to-ENU transformation matrix
X2E = zeros(4,4,nping);
for i = 1:nping
    X2E(1:3,1:3,i) = H(:,:,i)*PR(:,:,i);
    X2E(4,1:4,i) = X2E(3,1:4,i);
    X2E(1:4,4,i) = X2E(1:4,3,i);
end
X2E(3,4,:) = 0; X2E(4,3,:) = 0;

% Combine Beam-to-XYZ, with XYZ-to-ENU to get total Transformation Matrix
TMAT = zeros(4,4,nping);
for i = 1:nping
    TMAT(:,:,i) = X2E(:,:,i)*B2X(:,:,i);
end

%% Perform  Coordinate Transformation
if strcmp(coord,'ENU')

    ENU = NaN(nping,nbin,4);
    ENU(:,:,1) = v1;
    ENU(:,:,2) = v2;
    ENU(:,:,3) = v3;
    ENU(:,:,4) = v4;
    
    BEAM = zeros(nping,nbin,4);% ENU to BEAM [B1; B2; B3; B4] = inv(TMAT) * [E; N; U1; U2] 
    XYZ = zeros(nping,nbin,4);% ENU to XYZ [X; Y; Z1; Z2] = TMAT * inv(X2E) * [E; N; U1; U2];
    for i = 1:nping
        for j = 1:nbin
            BEAM(i,j,:) = inv(TMAT(:,:,i)) * [v1(i,j); v2(i,j); v3(i,j); v4(i,j)]; %#ok<*MINV>
            XYZ(i,j,:) = B2X(:,:,i) * inv(TMAT(:,:,i)) * [v1(i,j); v2(i,j); v3(i,j); v4(i,j)];
        end
    end
    
elseif strcmp(coord,'XYZ')

    XYZ = NaN(nping,nbin,4);
    XYZ(:,:,1) = v1;
    XYZ(:,:,2) = v2;
    XYZ(:,:,3) = v3;
    XYZ(:,:,4) = v4;
    
    ENU = zeros(nping,nbin,4);% XYZ to ENU [E; N; U1; U2] = X2E * inv(TMAT) * [X; Y; Z1; Z2]
    BEAM = zeros(nping,nbin,4);% ENU to BEAM [B1; B2; B3; B4] = inv(TMAT) * [E; N; U1; U2]
    for i = 1:nping
        for j = 1:nbin
            ENU(i,j,:) = TMAT(:,:,i) * inv(B2X(:,:,i)) * [v1(i,j); v2(i,j); v3(i,j); v4(i,j)];
            BEAM(i,j,:) = inv(TMAT(:,:,i)) * [v1(i,j); v2(i,j); v3(i,j); v4(i,j)];
        end
    end
    
elseif strcmp(coord,'BEAM')

    BEAM = NaN(nping,nbin,4);
    BEAM(:,:,1) = v1;
    BEAM(:,:,2) = v2;
    BEAM(:,:,3) = v3;
    BEAM(:,:,4) = v4;
    
    ENU = zeros(nping,nbin,4);% BEAM to ENU [E; N; U1; U2] = TMAT * [B1; B2; B3; B4]
    XYZ = zeros(nping,nbin,4);% ENU to XYZ [X; Y; Z1; Z2] = B2I * inv(TMAT) * [E; N; U1; U2];
    for i = 1:nping
        for j = 1:nbin
            ENU(i,j,:) = TMAT(:,:,i) * [v1(i,j); v2(i,j); v3(i,j); v4(i,j)];
            XYZ(i,j,:) = B2X(:,:,i) * inv(TMAT(:,:,i)) * [v1(i,j); v2(i,j); v3(i,j); v4(i,j)];
        end
    end
    
end

%%

%end


