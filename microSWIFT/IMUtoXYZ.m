function [x, y, z, roll, pitch, yaw, heading] = IMUtoXYZ(ax, ay, az, gx, gy, gz, mx, my, mz, mxo, myo, mzo, Wd, fs );
%
% Matlab function to calculate wave displacements in earth reference frame
% from microSWIFT IMU measurements in body reference frame
%
% Inputs are raw accelerometer, gyro, and magnotometer readings (3 axis each)
% along with magnetometer offsets (3), a weight coef for filtering the gyro,
% and the sampling frequency of the raw data
%
%   [x, y, z, roll, pitch, yaw, heading] = IMUtoXYZ(ax, ay, az, gx, gy, gz, mx, my, mz, mxo, myo, mzo, Wd, fs );
%
% Outputs are displacements x (east), y (north), and z (up),
% along with Euler angles and geographic heading for debugging
%
% The weight coef Wd must be between 0 and 1, with 0 as default
% (this controls importantce dynamic angles in a complimentary filter)
%
% The default magnetomoter offsets are mxo = 60, myo = 60, mzo = 120
%
% The sampling rate is usually 4 Hz
%
% The body reference frame for the inputs is
%   x: along bottle (towards cap), roll around this axis
%   y: accross bottle (right hand sys), pitch around this axis
%   z: up (skyward, same as GPS), yaw around this axis
%
%
% J. Thomson, Feb 2021
%
%#codegen

Ws = 1-Wd; % weighting (0 to 1) for static angles in complimentary filter

dt = 1./fs; % time step

RC = 4;  % high pass RC filter constant, T > (2 * pi * RC)

samples = length(ax);

%% estimate Euler angles with complementary filter

staticroll = mean( atan2d(ay, az) ); % roll around x axis [deg] in absence of linear acceleration
staticpitch = mean( atan2d(-ax, sqrt(ay.^2 + az.^2 ) ) ); % pitch around y axis [deg] in absence of linear acceleration
staticyaw = 0; % yaw around z axis [deg], zero for now... it's relative until applying the magnetometer

if Wd~=0,
    dynamicroll = cumtrapz(gx)*dt; % time integrate to get dynamic roll
    dynamicroll = RCfilter(dynamicroll, RC, fs); % high-pass filter to reduce drift
    dynamicpitch = cumtrapz(gy)*dt; % time integrate to get dynamic roll
    dynamicpitch = RCfilter(dynamicpitch, RC, fs); % high-pass filter to reduce drift
    dynamicyaw = cumtrapz(gz)*dt; % time integrate to get dynamic yaw
    dynamicyaw = RCfilter(dynamicyaw, RC, fs); % high-pass filter to reduce drift
else
    dynamicroll=zeros(size(gx));
    dynamicpitch=zeros(size(gx));
    dynamicyaw=zeros(size(gx));
end

% combine orientation estimates (using weighted complementary filter)
roll = Wd*dynamicroll + Ws*staticroll; 
pitch = Wd*dynamicpitch + Ws*staticpitch;
yaw = Wd*dynamicyaw + Ws*staticyaw;


%% make rotation matrix for every time step
% careful here, order of Euler angles matters, see Zippel 2018 (JPO) and Edson 1998 for clues

for ii=1:samples
    
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
    
    
    %% rotate linear accelerations and magnetomer readings to horizontal (earth frame)
    
    a = T * [ax(ii); ay(ii); az(ii); ];
    ax(ii) = a(1); 
    ay(ii) = a(2); 
    az(ii) = a(3);
    
    m = T * [mx(ii); my(ii); mz(ii); ];
    mx(ii) = m(1); 
    my(ii) = m(2); 
    mz(ii) = m(3); 
    
    %% create the angular rate matrix in earth frame and determine projected speeds
    % (rotate the "strapped-down" gyro measurements from body to earth frame)
    % skip this in onboard processing, effects are negligible,
    % because IMU is close to center (M is small)
    
    %     M = [-0.076;  -0.013;  0; ]; % position vector of IMU relative to buoy center [meters]
    %     Omega = [0; 0; gz(ii);]  +    Y*[0; gy(ii); 0;]    +  Y*P*[gx(ii); 0; 0;];
    %     Omega = deg2rad(Omega);
    %     [vxr(ii); vyr(ii); vzr(ii);] = cross(Omega, T*M);
    
    
end % close loop thru time steps


%% filter and integrate linear accelerations to get linear velocities

ax = detrend(ax);
ay = detrend(ay);
az = detrend(az);

ax = RCfilter(ax, RC, fs);
ay = RCfilter(ay, RC, fs);
az = RCfilter(az, RC, fs);

vx = cumtrapz(ax)*dt; % m/s
vy = cumtrapz(ay)*dt; % m/s
vz = cumtrapz(az)*dt; % m/s



%% remove rotation-induced velocities from total velocity (skip for onboard processing)

% vx = vx - vxr;
% vy = vy - vyr;
% vz = vz - vzr;

%% determine geographic heading and correct horizontal velocities to East, North

heading = atan2d( my + myo, mx + mxo );
heading(heading<0) = 360+heading(heading<0);
theta = -(heading - 90); % cartesian CCW heading from geographic CW heading

u = vx; % x dir (horizontal in earth frame, but relative in azimuth)
v = vy; % y dir (horizontal in earth frame, but relative in azimuth)
vx = u.*cosd(theta) - v.*sind(theta); % east component
vy = u.*sind(theta) + v.*cosd(theta); % north compoent

%% filter and integrate velocity for displacements, and filter again

vx = detrend(vx);
vy = detrend(vy);
vz = detrend(vz);

vx = RCfilter(vx, RC, fs);
vy = RCfilter(vy, RC, fs);
vz = RCfilter(vz, RC, fs);

x = cumtrapz(vx)*dt;
y = cumtrapz(vy)*dt;
z = cumtrapz(vz)*dt;

x = detrend(x);
y = detrend(y);
z = detrend(z);

x = RCfilter(x, RC, fs);
y = RCfilter(y, RC, fs);
z = RCfilter(z, RC, fs);


%% remove first portion, which can has initial oscillations from filtering

x(1:round(RC./dt*10),:) = 0;
y(1:round(RC./dt*10),:) = 0;
z(1:round(RC./dt*10),:) = 0;



%% EMBEDDED RC FILTER function (high pass filter) %%

    function a = RCfilter(b, RC, fs);
        
        alpha = RC / (RC + 1./fs);
        a = b;
        
        for ui = 2:length(b)
            a(ui) = alpha * a(ui-1) + alpha * ( b(ui) - b(ui-1) );
        end
        
    end

end
