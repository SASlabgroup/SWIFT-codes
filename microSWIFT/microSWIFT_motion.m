function ENU = microSWIFT_motion(IMU);
% Matlab for for microSWIFT motion processing,
% transforming onboard IMU to motion in earth reference frame
%
% IMU local coordinates and associated Euler angles are:
%   x: along bottle (towards cap), roll around this axis
%   y: accross bottle (right hand sys), pitch around this axis
%   z: up (skyward, same as GPS), yaw around this axis
%
%   ENU = microSWIFT_motion(IMU);
%
% using data already in IMU structure from function "readmicroSWIFT_IMU.m"
%
% Key step is usinh a complimentary filter to
% combines static estimates of orientation from accelerometer data
% with dynamic estimates of orientation from gyro data
% then rotates everything into the horizontal earth plane
% then uses horizontal magnememeter components to determine heading 
% and rotate again to geographic yaw, 
% then integrates the ENU accelerations to get XYZ wave displacements
%
% all makes heavy use of a high-pass RC filter (embedded function) 
% which reduces drift in the time integration of gryos and accelerations
%
%
% J. Thomson, 10/2020
%              1/2021 add heading from magnetometers, fix roll-pitch confusions
%
%
%

%% constants

RC = 4;  % high pass RC filter constant, T > 2 * pi * RC

M = [-0.076;  -0.013;  0; ]; % position vector of IMU relative to buoy center [meters]

MagOffsets = [60; 60; 120;]; % magnetometer offsets

Wd = 0; % weighting (0 to 1) of dynamic angles in complimentary filter
Ws = 1-Wd; % weighting (0 to 1) for static angles in complimentary filter

fs =  length(IMU.acc)./512; % sampling freq (Hz)
dt = 1./fs;


%% despike (might be uneccesary)

IMU.acc = filloutliers(IMU.acc,'linear');
IMU.angles = filloutliers(IMU.angles,'linear');
IMU.gyro = filloutliers(IMU.gyro,'linear');

%% data from structure

ax = IMU.acc(:,1); % acc in x [m/s]
ay = IMU.acc(:,2); % acc in y [m/s]
az = IMU.acc(:,3); % acc in z [m/s]
gx = IMU.gyro(:,1); % gryo in x [deg/s]
gy = IMU.gyro(:,2); % gryo in y [deg/s]
gz = IMU.gyro(:,3); % gryo in z [deg/s]
mx = IMU.mag(:,1); % magnetometer in x [uT]
my = IMU.mag(:,2); % magnetometer in y [uT]
mz = IMU.mag(:,3); % magnetometer in z [uT]


%% estimate pitch and roll with complementary filter

staticroll = mean( atan2d(ay, az) ); % roll around x axis [deg] in absence of linear acceleration
staticpitch = mean( atan2d(-ax, sqrt(ay.^2 + az.^2 ) ) ); % pitch around y axis [deg] in absence of linear acceleration 
staticyaw = 0; % yaw around z axis [deg], zero for now... it's relative until applying the magnetometer 

dynamicroll = cumtrapz(gx)*dt; % time integrate to get dynamic roll
dynamicroll = RCfilter(dynamicroll, RC, fs); % high-pass filter to reduce drift
dynamicpitch = cumtrapz(gy)*dt; % time integrate to get dynamic roll
dynamicpitch = RCfilter(dynamicpitch, RC, fs); % high-pass filter to reduce drift
dynamicyaw = cumtrapz(gz)*dt; % time integrate to get dynamic yaw
dynamicyaw = RCfilter(dynamicyaw, RC, fs); % high-pass filter to reduce drift

% combine orientation estimates (using weighted complementary filter)
roll = Wd*dynamicroll + Ws*staticroll;
pitch = Wd*dynamicpitch + Ws*staticpitch;
yaw = Wd*dynamicyaw + Ws*staticyaw;

ENU.angles(:,1) = roll;
ENU.angles(:,2) = pitch;
ENU.angles(:,3) = yaw;

%% make rotation matrix
% careful here, order of Euler angles matters, see Zippel 2018 (JPO) and Edson 1998 for clues

for ii=1:length(IMU.clock)
    
    r = roll(ii); 
    p = pitch(ii);
    y = yaw(ii);
    
    % yaw matrix
    Y = [cosd(y) -sind(y) 0;...
         sind(y) cosd(y)  0;...
         0       0        1;];
    
    % pitch matrix
    P = [cosd(p) 0  sind(p);...
        0        1  0      ;...
        -sind(p) 0  cosd(p);];
    
    % roll matrix
    R = [1   0        0       ;...
         0   cosd(r)  -sind(r);...
         0   sind(r)  cosd(r);];
    
    
    % transformation matrix from buoy to earth reference frame
    T = Y * (P * R);
    %T = R * P * Y;
    %T = inv(T);
    
    
    %% rotate linear accelerations and magnetomer readings to horizontal (earth frame)
    ENU.acc(ii,:) = T * IMU.acc(ii,:)';
    ENU.mag(ii,:) = T * IMU.mag(ii,:)';
    
    %% create the angular rate matrix in earth frame
    % (rotate the "strapped-down" gyro measurements from body to earth frame)
    
    Omega = [0; 0; gz(ii);]  +    Y*[0; gy(ii); 0;]    +  Y*P*[gx(ii); 0; 0;];
    
    Omega = deg2rad(Omega);
    
    
    %% calc velocities from rotation (to remove before wave processing)
    % this has negligible effect, because M distances are so small
    % probably should exclude in onboard processing (for computational speed)
    
    ROT.vel(ii,:) = cross(Omega, T*M);
    
end % close loop thru time steps

disp('mean acceleration values in Earth reference frame')
mean(ENU.acc)

%% filter and integrate linear accelerations to get linear velocities

ENU.acc = detrend(ENU.acc);

ENU.acc = RCfilter(ENU.acc, RC, fs);

ENU.vel = cumtrapz(ENU.acc)*dt; % m/s


%% remove rotation-induced velocities from total velocity

ENU.vel = ENU.vel - ROT.vel; % doesn't seem to matter much, because M distance are small

%% determine geographic heading and correct horizontal velocities to East, North

ENU.heading = (atan2d( ENU.mag(:,2) + MagOffsets(2) , ENU.mag(:,1) + MagOffsets(1) ));
ENU.heading(ENU.heading<0) = 360+ENU.heading(ENU.heading<0);
theta = -(ENU.heading - 90); % cartesian CCW heading from geographic CW heading

u = ENU.vel(:,1); % x dir (horizontal in earth frame, but relative in azimuth)
v = ENU.vel(:,2); % y dir (horizontal in earth frame, but relative in azimuth)
ENU.vel(:,1) = u.*cosd(theta) - v.*sind(theta); % east component
ENU.vel(:,2) = u.*sind(theta) + v.*cosd(theta); % north compoent

%% filter and integrate velocity for displacements, and filter again

ENU.vel = detrend(ENU.vel);

ENU.vel = RCfilter(ENU.vel, RC, fs);

ENU.pos = cumtrapz(ENU.vel)*dt;

ENU.pos = detrend(ENU.pos);

ENU.pos = RCfilter(ENU.pos, RC, fs);

%% remove first portion, which can has initial oscillations from filtering

ENU.pos(1:round(RC./dt*10),:) = NaN;



%% EMBEDDED RC FILTER function (high pass filter) %%

    function a = RCfilter(b, RC, fs);
        
        alpha = RC / (RC + 1./fs);
        a(1,:) = b(1,:);
        
        for ui = 2:length(b)
            a(ui,:) = alpha * a(ui-1,:) + alpha * ( b(ui,:) - b(ui-1,:) );
        end
        
    end

end
