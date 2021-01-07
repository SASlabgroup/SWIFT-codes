function ENU = microSWIFT_motion(IMU);
% Matlab for for microSWIFT motion processing
% transform onboard IMU to motion in earth reference frame
% which has local coordinates and associated Euler angles
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
%

%% constants

RC = 4;  % high pass RC filter constant, T > 2 * pi * RC

M = [-0.076;  -0.013;  0; ]; % position vector of IMU relative to buoy center [meters]

fs =  length(IMU.acc)./512; % sampling freq (Hz)
dt = 1./fs;

%% despike

IMU.acc = filloutliers(IMU.acc,'linear');
IMU.angles = filloutliers(IMU.angles,'linear');
IMU.gyro = filloutliers(IMU.gyro,'linear');


%% loop thru timesteps, going from body frame to earth frame

for ii=1:length(IMU.clock) 
    
%% make rotation matrix
% careful here, order of Euler angles matters, see Zippel 2018 (JPO) and Edson 1998 for clues
% IMU reports roll, pitch, yaw from onboard processing of raw gyro and acc
% lingering question is if pitch is measured in the yawed reference frame,
% and roll is measured in the yawed and pitch frame?  Probably yes.
% ** in testing, yaw is pegged around 45 deg... maybe ignore (set to zero)

% need to understand these definitions better... p and r might be switched
p = IMU.angles(ii,1);
r = IMU.angles(ii,2);
y = IMU.angles(ii,3);

% yaw matrix
Y = [cosd(y) sind(y) 0;...
    -sind(y) cosd(y) 0;...
        0       0    1;];
    
% pitch matrix
P = [cosd(p) 0 -sind(p);...
        0    1    0    ;...
     sind(p) 0  cosd(p);];
       
% roll matrix
R = [   1     0         0   ;...    
        0   cosd(r) -sind(r);...
        0   sind(r)  cosd(r);];
        

% full transformation from buoy to earth reference frame
T = Y * (P * R);
%T = T'; % try tranform from earth to body, instead of body to earth

%% rotate linear accelerations and angles to earth frame
ENU.acc(ii,:) = T * IMU.acc(ii,:)'; 
%ENU.angles(ii,:) = T * IMU.angles(ii,:)';

%% create the angular rate matrix in earth frame
% (rotate the "strapped-down" gyro measurements from body to earth frame)
% lingering issue is units... gyro supposed to be rad/s, 
% but suspect is might be deg/s based on spec sheet with range -/+ 250 
% (which is min/max on x channel)

% need to understand these definitions better... p and r might be switched
prate = IMU.gyro(ii,1);
rrate = IMU.gyro(ii,2);
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
