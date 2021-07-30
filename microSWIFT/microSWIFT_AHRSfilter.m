function ENU = microSWIFT_AHRSfilter( IMU );
% function to apply Matlab AHRSfilter to microSWIFT IMU data
% where IMU data is in structure, and output is ENU structure
%
%   ENU = microSWIFT_AHRSfilter( IMU );
%
%   J. Thomson, July 2020
%       ** still need sensivity testing for noise settings***
%

fs =  length(IMU.acc)./((max(IMU.time)-min(IMU.time))*24*3600); % Hz (usually 12)
dt = 1/fs;
RC = 3; % seconds, effect passband is 2*pi*RC 

%% quaternion (orientation) from sensor fusion
% noise levels specifed by uSWIFT 025 static test on 15 Jun 2021 (Mobile Bay) 
% solution is very sensitive to noise levels 

fuse = ahrsfilter('SampleRate', fs,'ReferenceFrame','ENU','DecimationFactor',1);
fuse.AccelerometerNoise = 1e-4; % 1e-5 (m/s²)² 
fuse.GyroscopeNoise = deg2rad(5e0); % deg2rad(5e-2) (rad/s)²
fuse.MagnetometerNoise = 1; % 0.5 (µT)²
%fuse.GyroscopeDriftNoise = 1e-5; %(rad/s)²
%fuse.LinearAccelerationNoise = 1e-8; % (m/s²)² 
[ q , rotv ] = fuse( IMU.acc, deg2rad(IMU.gyro), IMU.mag );


%% euler angles

ENU.angles = eulerd(q,'XYZ','point');
ENU.time = IMU.time;

figure(11), clf, 
plot(ENU.time,ENU.angles,'.'), ylabel('Euler angles [deg]'), datetick
print('-dpng',[datestr(IMU.time(1)) '_EulerAngles.png'])

%% rotate accelerations
R = rotmat(q,'point');
for ri=1:length(IMU.time)
    ENU.acc(ri,:) = squeeze(R(:,:,ri)) * IMU.acc(ri,:)';
end

figure(12), clf
subplot(1,2,1), plot(ENU.acc),  ylabel('ENU acceleration [m/s^2]'),
subplot(1,2,2), pwelch(detrend(ENU.acc(round(60*fs):end,:)),[],[],[],fs), set(gca,'XScale','log')
print('-dpng',[datestr(IMU.time(1)) '_ENUacc.png'])

%% kinematic trajectory
% ** this accumulates huge integration errors, do not use this approach **

% trajectory = kinematicTrajectory('SampleRate',fs);
% [position,orientation,velocity,acceleration,angularVelocity] = trajectory(IMU.acc, deg2rad(IMU.gyro));


%% filter and integrate linear accelerations to get linear velocities

ENU.acc = detrend(ENU.acc);

ax = RCfilter(ENU.acc(:,1), RC, fs);
ay = RCfilter(ENU.acc(:,2), RC, fs);
az = RCfilter(ENU.acc(:,3), RC, fs);

vx = cumtrapz(ax)*dt; % m/s
vy = cumtrapz(ay)*dt; % m/s
vz = cumtrapz(az)*dt; % m/s


%% remove rotation-induced velocities from total velocity (negligible)

M = [-0.076;  -0.013;  0; ]; % microSWIFT offset lengths [m]

% vxr = rotv(:,1)*M(1);
% vyr = rotv(:,2)*M(2);
% vzr = rotv(:,3)*M(3);
% 
% vx = vx - vxr;
% vy = vy - vyr;
% vz = vz - vzr;


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

ENU.xyz(:,1) = RCfilter(x, RC, fs);
ENU.xyz(:,2) = RCfilter(y, RC, fs);
ENU.xyz(:,3) = RCfilter(z, RC, fs);


%% remove first portion, which can has initial oscillations from filtering

ENU.xyz(1:round(fs*60),:) = 0;

figure(13),clf
plot(ENU.time,ENU.xyz),datetick
subplot(1,2,1), plot(ENU.xyz),  ylabel('ENU displacements [m]'),
subplot(1,2,2), pwelch(ENU.xyz,[],[],[],fs), set(gca,'XScale','log')
    hold on, semilogx([0.05 0.05],[-70 30],'k--',[0.5 0.5],[-70 30],'k--')
print('-dpng',[datestr(IMU.time(1)) '_displacements.png'])


%% EMBEDDED RC FILTER function (high pass filter) %%

function a = RCfilter(b, RC, fs)

alpha = RC / (RC + 1./fs);
a = b;

for ui = 2:length(b)
    a(ui,:) = alpha * a(ui-1,:) + alpha * ( b(ui,:) - b(ui-1,:) );
end

end

end
