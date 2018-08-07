% SWIFT RM Young and IMU processing
% processing adapted from Edson et. al. 1998
%(1) Translational velocities
%   (a) rotate accelerations, remove gravity vector, highpass filter the
%   remainder (~2min filter)
%   (b) lowpass computed using GPS, but maybe assume drifter tracks surface
%   well such that horizontal motions remain relative to the water
%(2) Rotational velocities and rotation matrix
%       (a) T(U_obs + Omega_obs X R)
%
%
%INPUTS:
%   uvw         - n x 3 double of body coordinate, 10Hz RM young data
%   AHRS        - IMU structure taken from the raw IMU/AHRS readin
%   GPS         - GPS structure taken from the raw IMU/AHRS readin
%
%OUTPUTS:
%   uvw_cor     -nx3 double of motion corrected wind data, u is
%                north positive, v is west positive, w is down positive
%                (aero/Euler convention)


% plots = 1;
% 
% IMU_path = '../Data/08Mar2018/SWIFT13/COM-6/Raw/20180308/';
% IMU_files = dir([IMU_path '*.dat']);
% Sonic_path = '../Data/08Mar2018/SWIFT13/Y81/Raw/20180308/';
% Sonic_files = dir([Sonic_path '*.dat']);
% 
% load([IMU_path IMU_files(8).name(1:end-3) 'mat'])
% load([Sonic_path Sonic_files(8).name(1:end-3) '.mat'])

function [sonic_time, uvw_cor] = RMYoung_motion_correction(uvw, AHRS, GPS, plots)
sonic_time = (1:length(uvw)) ./ 10;

gtime = (GPS.Time.Flags == 3);
gps_time = GPS.Time.WeekNum*7 + GPS.Time.TimeOfWeek/60/60/24 +...
    datenum('06Jan1980','ddmmmYYYY');
gps_time(~gtime) = NaN;

% AHRS.GPS_Time.TimeOfWeek references time in seconds since UTC Sunday @ 00:00:00
% AHRS.GPS_Time.WeekNum references ... Saturday January 5, 1980 to 00:00:00  ???
AHRS_time = AHRS.GPS_Time.WeekNum*7 + AHRS.GPS_Time.TimeOfWeek/60/60/24 + datenum('06Jan1980','ddmmmYYYY');
AHRS_time(~(AHRS.GPS_Time.Flags == 5 | AHRS.GPS_Time.Flags == 7) ) = NaN;

%end times were very close, even though start time varried. As a first
%guess, align the end time of the sonic.
sonic_time = sonic_time/60/60/24 + (-sonic_time(end)/60/60/24 + AHRS_time(end));

%The 10Hz offset is approx 34.9 seconds, determined from XCORR over many busrts
% in LangmuirNotebook.mlx - I will use this offset moving forward
time_offset = 35.1/60/60/24;
gps_time = gps_time+time_offset;
AHRS_time = AHRS_time + time_offset; %I think GPS starts early to get satellites... maybe check w/ Jim on this?

%fill gaps w/ sample rate
for ii = length(AHRS_time):-1:1
    if isnan(AHRS_time(ii))
        AHRS_time(ii) = AHRS_time(ii+1) - 1/25/60/60/24;
    end
end

for ii = length(gps_time):-1:1
    if isnan(gps_time(ii))
        gps_time(ii) = gps_time(ii+1) - 1/5/60/60/24;
    end
end

% %% Complimentary Filtering
% IMU DOES THIS INTERNALLY!!!!!
% 
% %HP filter
% fc = 0.05;
% [b_hi, a_hi] = butter(1, fc/(25/2),'high');
% [b_lo, a_lo] = butter(1, fc/(25/2),'low');
% 
% int_roll = cumtrapz(AHRS_time, AHRS.Gyro(:,1))*60*60*24;
% int_roll_filt = filtfilt(b_hi,a_hi,unwrap(int_roll));
% 
% accel_roll = asin(AHRS.Accel(:,2));
% accel_roll_filt = filtfilt(b_lo,a_lo,unwrap(accel_roll));
% accel_pitch = asin(AHRS.Accel(:,1) ./ cos(accel_roll_filt) );
% accel_pitch_filt = filtfilt(b_lo,a_lo,unwrap(accel_pitch));
% 
% gyro_roll_filt = filtfilt(b_hi,a_hi,unwrap(AHRS.Euler_RPY(:,1)));
% gyro_pitch_filt = filtfilt(b_hi,a_hi,unwrap(AHRS.Euler_RPY(:,2)));
% 
% %roll_complimentary = (accel_roll_filt-pi) + gyro_roll_filt;
% roll_complimentary = (accel_roll_filt-pi) + int_roll_filt;
% pitch_complimentary= accel_pitch_filt + gyro_pitch_filt;
% 
% window_sz = 1024*6;
% noverlap = [];
% [Proll_a,f] = pwelch(detrend(unwrap(accel_roll)), window_sz,noverlap,[],25);
% [Proll_gyro,f] = pwelch(detrend(unwrap(AHRS.Euler_RPY(:,1))), window_sz,noverlap,[],25);
% [Proll_int,f] = pwelch(detrend(unwrap(int_roll)), window_sz,noverlap,[],25);
% [Proll_comp,f] = pwelch(detrend(roll_complimentary), window_sz,noverlap,[],25);
% [Ppitch_a,f] = pwelch(detrend(unwrap(accel_pitch)), window_sz,noverlap,[],25);
% [Ppitch_gyro,f] = pwelch(detrend(unwrap(AHRS.Euler_RPY(:,2))), window_sz,noverlap,[],25);
% [Ppitch_comp,f] = pwelch(detrend(pitch_complimentary), window_sz,noverlap,[],25);
% [Phead_gyro,f] = pwelch(detrend(unwrap(AHRS.Euler_RPY(:,3))), window_sz,noverlap,[],25);
% 
% figure(100),clf
% subplot(3,1,1)
% hold on
% plot(unwrap(AHRS.Euler_RPY(:,1)))
% plot(accel_roll-pi)
% plot(roll_complimentary)
% ylabel('Roll')
% legend({'Gyro','Accel','Complimentary'})
% subplot(3,1,2)
% hold on
% plot(unwrap(AHRS.Euler_RPY(:,2)))
% plot(unwrap(accel_pitch))
% plot(unwrap(pitch_complimentary))
% ylabel('Pitch')
% legend({'Gyro','Accel','Complimentary'})
% 
% subplot(3,1,3)
% hold on
% plot(unwrap(AHRS.Euler_RPY(:,3)))
% ylabel('Heading')
% 
% figure(101),clf
% subplot(3,1,1)
% hold on
% plot(f, Proll_gyro)
% loglog(f, Proll_a)
% loglog(f, Proll_comp,'linewidth',2)
% %legend({'Gyro','Accel','Complimentary'})
% loglog(f, Proll_int)
% legend({'Gyro','Accel','Comp','integrated'})
% set(gca,'yscale','log','xscale','log')
% ylabel('Roll')
% 
% subplot(3,1,2)
% hold on
% plot(f, Ppitch_gyro)
% loglog(f, Ppitch_a)
% loglog(f, Ppitch_comp,'linewidth',2)
% legend({'Gyro','Accel','Complimentary'})
% set(gca,'yscale','log','xscale','log')
% ylabel('Roll')
% 
% subplot(3,1,3)
% plot(f, Phead_gyro)
% legend({'Gyro','Accel','Complimentary'})
% set(gca,'yscale','log','xscale','log')
% ylabel('Roll')
% 
% quat_compl = eul2quat([AHRS.Euler_RPY(:,3), pitch_complimentary, roll_complimentary]);
% %quat_compl = eul2quat([roll_complimentary pitch_complimentary, AHRS.Euler_RPY(:,3)]);

%% Translational motions from integrating accelerations

%rotate and remove gravity vector
accel_ned = quatrotate(AHRS.Quat,AHRS.Accel) + [0,0,1];
%accel_ned = quatrotate(quat_compl, AHRS.Accel) + [0,0,1];

%HP filter
time_constant = 1*60; %2-min time filter
fc = 1/time_constant;
[b, a] = butter(1, fc/(25/2),'high');
%pad w/ zeros to avoid edge bleeding
accel_ned_pad = cat(1,zeros(25*2*60,3),accel_ned,zeros(25*2*60,3));
accel_ned_filt = filtfilt(b,a,accel_ned_pad);
ids = (25*2*60+1):(length(AHRS_time)+25*2*60);
accel_ned_filt = accel_ned_filt(ids,:);

%Try and do this for quaternions too? some low frequency issues...
quat_pad = cat(1,zeros(25*2*60,4),AHRS.Quat,zeros(25*2*60,4));
quat_filt = filtfilt(b,a,quat_pad);
quat_filt = quat_filt(ids,:);

conversion = 60*60*24*9.80665; %g*day to m/s;
%look at integrated accl velocities..
vel_raw = cumtrapz(AHRS_time, accel_ned)*conversion;
vel_filt = cumtrapz(AHRS_time, accel_ned_filt)*conversion;

%repeat high-pass filter
vel_pad = cat(1,zeros(25*2*60,3),vel_filt,zeros(25*2*60,3));
vel_filtfilt = filtfilt(b,a,vel_pad);
ids = (25*2*60+1):(length(AHRS_time)+25*2*60);
vel_filtfilt = vel_filtfilt(ids,:);

if plots == 1
    figure(1),clf
    subplot(3,1,1), hold on
    plot(vel_raw)
    xlabel('Index')
    ylabel('Raw Vel x,y,z [m/s]')
    title('Integrated Accl')
    subplot(3,1,2), hold on
    plot(vel_filt)
    xlabel('Index')
    ylabel('HP filt (2min) Vel x,y,z [m/s]')
    subplot(3,1,3),hold on
    plot(vel_filtfilt)
    xlabel('Index')
    ylabel('HP filt (before and after int) Vel x,y,z [m/s]')
    
    window_sz = 256;
    noverlap = [];
    [Praw,f] = pwelch(vel_raw, window_sz,noverlap,[],25);
    [Pfilt,f] = pwelch(vel_filt, window_sz,noverlap,[],25);
    [Pfiltfilt,f] = pwelch(vel_filtfilt, window_sz,noverlap,[],25);
end


%% Rotational motions and rotation
%(2) Rotational velocities and rotation matrix
%       (a) T(U_obs + Omega_obs X R)

%loop for rotational motions using position vector between sensor and IMU "R"
% in body coordinates
Pos = [-0.062, -0.052, 0.762]; %OFFSET FROM ALEX
%11.5 degree angle between IMU-x and sonic-x
% imu_angle = 11.5 +57;%+17.3;
% R_imu_angle = [cosd(-imu_angle), sind(-imu_angle), 0;...
%               -sind(-imu_angle), cosd(-imu_angle), 0;...
%                          0,           0, 1];
imu_angle = 11.5+20;
R_imu_angle = eul2rotm(deg2rad([imu_angle,180,-1]));
uvw = (R_imu_angle*uvw')';

for ii = 1:length(AHRS_time)
    V_rot_body(ii,:) = cross(AHRS.Gyro(ii,:), Pos); %MATLAB DEFINES CROSS PRODUCT as negative as what is in "attitude"
end

%quat_interp = interp1(AHRS_time, AHRS.Quat, sonic_time,'linear');
quat_interp = interp1(AHRS_time, quat_filt, sonic_time,'nearest');
%quat_interp = interp1(AHRS_time, quat_compl, sonic_time,'nearest');
vel_mot_interp = interp1(AHRS_time, vel_filtfilt, sonic_time,'nearest');
V_rot_interp = interp1(AHRS_time, V_rot_body, sonic_time,'nearest');

V_rot_world = quatrotate(quat_interp, V_rot_interp);
V_meas_world = quatrotate(quat_interp, uvw);
vel_mot_interp_world = quatrotate(quat_interp, vel_mot_interp);

%might do low pass at 3Hz cutoff - interpolating creates strange artifacts
%HP filter
fc = 3;
[b, a] = butter(3, fc/(10/2),'low');
vel_mot_interp_world = filtfilt(b,a,vel_mot_interp_world);
V_rot_world = filtfilt(b,a,V_rot_world);


uvw_cor = V_meas_world - vel_mot_interp_world - V_rot_world;

if plots==1
    figure(3),clf
    subplot(2,1,1)
    plot(uvw)
    ylabel('Body Coords')
    subplot(2,1,2)
    plot(V_meas_world)
    ylabel('Quat Rotated')
    linkaxes([subplot(2,1,1), subplot(2,1,2)])
    
%     figure(501),clf
%     subplot(2,1,1)
%     plot(sonic_time, vel_mot_interp(:,3))
%     hold on
%     plot(sonic_time, V_meas_world(:,3))
%     subplot(2,1,2)
%     plot(V_meas_world(:,3), vel_mot_interp(:,3),'.')
%     xlabel('Meas.')
%     ylabel('Vertical (accl)')
%     axis equal
%     grid on
    
    %SPECTRA OF COMPONENTS
    [P_meas,f10] = pwelch(detrend(V_meas_world), window_sz,noverlap,[],10);
    [P_raw,f10] = pwelch(detrend(uvw), window_sz,noverlap,[],10);
    [Pinterp,f10] = pwelch(vel_mot_interp_world, window_sz,noverlap,[],10);
    [Pfilt,f25] = pwelch(vel_filt, window_sz,noverlap,[],25);
    [Pfiltfilt,f25] = pwelch(vel_filtfilt, window_sz,noverlap,[],25);
    [Protbody,f25] = pwelch(V_rot_body, window_sz,noverlap,[],25);
    [Prot,f10] = pwelch(V_rot_world, window_sz,noverlap,[],10);

    [P_vert_cor, f10] = pwelch(detrend(uvw_cor), window_sz,noverlap,[],10);
    
    figure(4),clf
    hold on
    loglog(f10, P_raw(:,3),'linewidth',2)
    %loglog(f10, P_meas(:,3))
    loglog(f10, Pinterp(:,3),'linewidth',2)
    %loglog(f25, Pfiltfilt(:,3))
    %loglog(f25, Protbody(:,3))
    loglog(f10, Prot(:,3),'linewidth',2)
    loglog(f10, P_vert_cor(:,3), 'k','linewidth',2)
    set(gca,'yscale','log','xscale','log')
    grid on
%     legend({'raw (body) P_{ww}','Measure P_{ww}','Interpolated P_{mot,ww}',...
%         '25Hz P_{mot,ww}','P_{rot,body,ww}','P_{rot,world,ww}','Corrected P_{ww}'},'Location','NorthEastOutside')
     legend({'raw (body) P_{ww}','Translational Motion P_{mot,ww}',...
         'Rotation P_{rot,ww}','Corrected P_{ww}'},'Location','NorthEastOutside')
    xlabel('Frequency [Hz]')
    ylabel('PSD [m^2/s^2/Hz]')
end