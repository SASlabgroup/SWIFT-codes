function ENU = microSWIFT_motion(IMU);
% Matlab for for microSWIFT motion processing
% transform onboard IMU to motion in earth reference frame
% which has local coordinates and associated Euler angles: roll, pitch, yaw
% x: along bottle (towards cap)
% y: accross bottle (right hand sys)
% z: up (skyward, same as GPS)
%
%   ENU = microSWIFT_motion(IMU);
%
% using data already in IMU structure from function "readmicroSWIFT_IMU.m"
%
% ** should compare this with "ahrsfilter" from Matlab sensor fusion toolbox 
%
% J. Thomson, 10/2020
%              1/2021 add heading from magnetometers, fix roll-pitch confusions
%
% TO DO: get sampling freq from IMU timestamps directly
%        confirm gyro axes
%        check horizontal x,y motion 
%

%% constants

RC = 4;  % high pass RC filter constant, T > 2 * pi * RC

M = [-0.076;  -0.013;  0; ]; % position vector of IMU relative to buoy center [meters]

MagOffsets = [60; 60; 120;]; % magnetometer offsets

fs =  length(IMU.acc)./512; % sampling freq (Hz)
dt = 1./fs;

%% despike (might be uneccesary)

IMU.acc = filloutliers(IMU.acc,'linear');
IMU.angles = filloutliers(IMU.angles,'linear');
IMU.gyro = filloutliers(IMU.gyro,'linear');


%% loop thru timesteps, going from body frame to earth frame

for ii=1:length(IMU.clock) 
    
%% make rotation matrix
% careful here, order of Euler angles matters, see Zippel 2018 (JPO) and Edson 1998 for clues
% biggest issue is assumption of weak linear accelerations, such that
% gravity is the reference in getting roll and pitch
%
% note that the onboard python code had these Euler angles as follows: 
%   roll = 180 * math.atan(accel_x/math.sqrt(accel_y*accel_y + accel_z*accel_z))/math.pi
%   pitch = 180 * math.atan(accel_y/math.sqrt(accel_x*accel_x + accel_z*accel_z))/math.pi
%   yaw = 180 * math.atan(accel_z/math.sqrt(accel_x*accel_x + accel_y*accel_y))/math.pi
% which swapped roll and pitch... and made a big damn headache

%r = atan2d(IMU.acc(ii,2), IMU.acc(ii,3)); % rotation around x axis
r = atan2d(IMU.acc(ii,2), sqrt(IMU.acc(ii,1)^2 + IMU.acc(ii,3).^2 ) ); % rotation around x axis
p = atan2d(IMU.acc(ii,1), sqrt(IMU.acc(ii,2)^2 + IMU.acc(ii,3).^2 ) ); % rotaion around y axis
y = 0;
% p = IMU.angles(ii,1);
% r = IMU.angles(ii,2);
% y = IMU.angles(ii,3);

% yaw matrix
Y = [cosd(y) -sind(y) 0;...
     sind(y) cosd(y) 0;...
        0       0    1;];
    
% pitch matrix
P = [cosd(p) 0  -sind(p);...
        0    1    0    ;...
     sind(p) 0  cosd(p);];
       
% roll matrix
R = [   1     0         0   ;...    
        0   cosd(r) -sind(r);...
        0   sind(r)  cosd(r);];
        

% transformation matrix from buoy to earth reference frame 
T = Y * (P * R);


%% rotate linear accelerations and magnetomer readings to earth frame (but not heading, that comes later)
ENU.acc(ii,:) = T * IMU.acc(ii,:)'; 
ENU.mag(ii,:) = T * IMU.mag(ii,:)'; 

%% create the angular rate matrix in earth frame
% (rotate the "strapped-down" gyro measurements from body to earth frame)
% lingering issue is units... gyro supposed to be rad/s, 
% but suspect is might be deg/s based on spec sheet with range -/+ 250 
% (which is min/max on x channel)

rrate = IMU.gyro(ii,1);
prate = IMU.gyro(ii,2);
yrate = IMU.gyro(ii,3);

Omega = [0; 0; yrate;]  +    Y*[0; prate; 0;]    +  Y*P*[rrate; 0; 0;];

Omega = deg2rad(Omega);


%% calc velocities from rotation (to remove before wave processing)

ROT.vel(ii,:) = cross(Omega, T*M);

end % close loop thru time steps

disp('mean acceleration values in Earth reference frame')
mean(ENU.acc)

%% filter and integrate linear accelerations to get linear velocities

ENU.acc = detrend(ENU.acc);

ENU.acc = RCfilter(ENU.acc, RC, fs);

ENU.vel = cumtrapz(ENU.acc)*dt; % m/s


%% remove rotation-induced velocities from total velocity

ENU.vel = ENU.vel - ROT.vel;

%% determine geographic heading and correct horizontal velocities to East, North

ENU.heading = (atan2d( ENU.mag(:,2) + MagOffsets(2) , ENU.mag(:,1) + MagOffsets(1) ));
ENU.heading(ENU.heading<0) = 360+ENU.heading(ENU.heading<0);
theta = -(ENU.heading - 90); % cartesian CCW heading from geographic CW heading

u = ENU.vel(:,1); % x dir (horizontal in earth frame, but relative in azimuth)
v = ENU.vel(:,1); % y dir (horizontal in earth frame, but relative in azimuth)
ENU.vel(:,1) = u.*cosd(theta) + v.*cosd(theta); % east component
ENU.vel(:,2) = -u.*cosd(theta) + y.*cosd(theta); % north compoent

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
