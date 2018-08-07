function sbgData = sbgBinaryToMatlab(filename, varargin)
% Matlab read-in of SWIFT v4.0 binary SBG data
%   usage is 
%       sbgData = sbgBinaryToMatlab(filename);
%   where ouput is data structure with several fields
%
% M. Schwendeman, 01/2017
%       10/2017, J. Thomson added fclose at end
%       12/2017, J. Thomson added varargin to read only the last portion of a file

fid = fopen(filename,'rb'); % open file for reading

if nargin==2,%length(varargin{1})==1,
    lastbytes = varargin{1};
    fseek(fid, -lastbytes, 'eof');
else
end

Status = struct('time_stamp',[],'general_status',[],'reserved1',[],'com_status',[],'aiding_status',[],'reserved2',[],'reserved3',[]);
UtcTime = struct('time_stamp',[],'clock_status',[],'year',[],'month',[],'day',[],'hour',[],'min',[],'sec',[],'nanosec',[],'gps_tow',[]);
ImuData = struct('time_stamp',[],'imu_status',[],'accel_x',[],'accel_y',[],'accel_z',[],'gyro_x',[],'gyro_y',[],'gyro_z',[],'temp',[],'delta_vel_x',[],'delta_vel_y',[],'delta_vel_z',[],'delta_angle_x',[],'delta_angle_y',[],'delta_angle_z',[]);
Mag = struct('time_stamp',[],'mag_status',[],'mag_x',[],'mag_y',[],'mag_z',[],'accel_x',[],'accel_y',[],'accel_z',[]);
EkfEuler = struct('time_stamp',[],'roll',[],'pitch',[],'yaw',[],'roll_acc',[],'pitch_acc',[],'yaw_acc',[],'solution_status',[]);
EkfQuat = struct('time_stamp',[],'q0',[],'q1',[],'q2',[],'q3',[],'roll_acc',[],'pitch_acc',[],'yaw_acc',[],'solution_status',[]);
EkfNav = struct('time_stamp',[],'velocity_n',[],'velocity_e',[],'velocity_d',[],'velocity_n_acc',[],'velocity_e_acc',[],'velocity_d_acc',[],'latitude',[],'longitude',[],'altitude',[],'undulation',[],'latitude_acc',[],'longitude_acc',[],'altitude_acc',[],'solution_status',[]);
ShipMotion = struct('time_stamp',[],'heave_period',[],'surge',[],'sway',[],'heave',[],'accel_x',[],'accel_y',[],'accel_z',[],'vel_x',[],'vel_y',[],'vel_z',[],'heave_status',[]);
GpsPos = struct('time_stamp',[],'gps_pos_status',[],'gps_tow',[],'lat',[],'long',[],'alt',[],'undulation',[],'pos_acc_lat',[],'pos_acc_long',[],'pos_acc_alt',[],'num_sv_used',[],'base_station_id',[],'diff_age',[]);
GpsVel = struct('time_stamp',[],'gps_vel_status',[],'gps_tow',[],'vel_n',[],'vel_e',[],'vel_d',[],'vel_acc_n',[],'vel_acc_e',[],'vel_acc_d',[],'course',[],'course_acc',[]);

byte = 0;
while ~isempty(byte)
    byte = fread(fid,1,'uint8');
    if byte == 255
        byte = fread(fid,1,'uint8');
        if byte == 90
            msgID = fread(fid,1,'uint8');
            msgClass = fread(fid,1,'uint8');
            msgLen = fread(fid,1,'uint16');
            if msgID == 1  % Status
                Status.time_stamp = [Status.time_stamp, fread(fid,1,'uint32')];
                Status.general_status = [Status.general_status, fread(fid,1,'uint16')];
                Status.reserved1 = [Status.reserved1, fread(fid,1,'uint16')];
                Status.com_status = [Status.com_status, fread(fid,1,'uint32')];
                Status.aiding_status = [Status.aiding_status, fread(fid,1,'uint32')];
                Status.reserved2 = [Status.reserved2, fread(fid,1,'uint32')];
                Status.reserved3 = [Status.reserved3, fread(fid,1,'uint16')];
            elseif msgID == 2 % UtcTime
                UtcTime.time_stamp = [UtcTime.time_stamp ,fread(fid,1,'uint32')];
                UtcTime.clock_status = [UtcTime.clock_status ,fread(fid,1,'uint16')];
                UtcTime.year = [UtcTime.year ,fread(fid,1,'uint16')];
                UtcTime.month = [UtcTime.month ,fread(fid,1,'uint8')];
                UtcTime.day = [UtcTime.day ,fread(fid,1,'uint8')];
                UtcTime.hour = [UtcTime.hour ,fread(fid,1,'uint8')];
                UtcTime.min = [UtcTime.min ,fread(fid,1,'uint8')];
                UtcTime.sec = [UtcTime.sec ,fread(fid,1,'uint8')];
                UtcTime.nanosec = [UtcTime.nanosec ,fread(fid,1,'uint32')];
                UtcTime.gps_tow = [UtcTime.gps_tow ,fread(fid,1,'uint32')];
            elseif msgID == 3 % ImuData
                ImuData.time_stamp = [ImuData.time_stamp ,fread(fid,1,'uint32')];
                ImuData.imu_status = [ImuData.imu_status ,fread(fid,1,'uint16')];
                ImuData.accel_x = [ImuData.accel_x ,fread(fid,1,'single')];
                ImuData.accel_y = [ImuData.accel_y ,fread(fid,1,'single')];
                ImuData.accel_z = [ImuData.accel_z ,fread(fid,1,'single')];
                ImuData.gyro_x = [ImuData.gyro_x ,fread(fid,1,'single')];
                ImuData.gyro_y = [ImuData.gyro_y ,fread(fid,1,'single')];
                ImuData.gyro_z = [ImuData.gyro_z ,fread(fid,1,'single')];
                ImuData.temp = [ImuData.temp ,fread(fid,1,'single')];
                ImuData.delta_vel_x = [ImuData.delta_vel_x ,fread(fid,1,'single')];
                ImuData.delta_vel_y = [ImuData.delta_vel_y ,fread(fid,1,'single')];
                ImuData.delta_vel_z = [ImuData.delta_vel_z ,fread(fid,1,'single')];
                ImuData.delta_angle_x = [ImuData.delta_angle_x ,fread(fid,1,'single')];
                ImuData.delta_angle_y = [ImuData.delta_angle_y ,fread(fid,1,'single')];
                ImuData.delta_angle_z = [ImuData.delta_angle_z ,fread(fid,1,'single')];
            elseif msgID == 4 % Mag
                Mag.time_stamp = [Mag.time_stamp ,fread(fid,1,'uint32')];
                Mag.mag_status = [Mag.mag_status ,fread(fid,1,'uint16')];
                Mag.mag_x = [Mag.mag_x ,fread(fid,1,'single')];
                Mag.mag_y = [Mag.mag_y ,fread(fid,1,'single')];
                Mag.mag_z = [Mag.mag_z ,fread(fid,1,'single')];
                Mag.accel_x = [Mag.accel_x ,fread(fid,1,'single')];
                Mag.accel_y = [Mag.accel_y ,fread(fid,1,'single')];
                Mag.accel_z = [Mag.accel_z ,fread(fid,1,'single')];
            elseif msgID == 6 % EkfEuler
                EkfEuler.time_stamp = [EkfEuler.time_stamp ,fread(fid,1,'uint32')];
                EkfEuler.roll = [EkfEuler.roll ,fread(fid,1,'single')];
                EkfEuler.pitch = [EkfEuler.pitch ,fread(fid,1,'single')];
                EkfEuler.yaw = [EkfEuler.yaw ,fread(fid,1,'single')];
                EkfEuler.roll_acc = [EkfEuler.roll_acc ,fread(fid,1,'single')];
                EkfEuler.pitch_acc = [EkfEuler.pitch_acc ,fread(fid,1,'single')];
                EkfEuler.yaw_acc = [EkfEuler.yaw_acc ,fread(fid,1,'single')];
                EkfEuler.solution_status = [EkfEuler.solution_status ,fread(fid,1,'uint32')];                
            elseif msgID == 7 % EkfQuat
                EkfQuat.time_stamp = [EkfQuat.time_stamp ,fread(fid,1,'uint32')];
                EkfQuat.q0 = [EkfQuat.q0 ,fread(fid,1,'single')];
                EkfQuat.q1 = [EkfQuat.q1 ,fread(fid,1,'single')];
                EkfQuat.q2 = [EkfQuat.q2 ,fread(fid,1,'single')];
                EkfQuat.q3 = [EkfQuat.q3 ,fread(fid,1,'single')];
                EkfQuat.roll_acc = [EkfQuat.roll_acc ,fread(fid,1,'single')];
                EkfQuat.pitch_acc = [EkfQuat.pitch_acc ,fread(fid,1,'single')];
                EkfQuat.yaw_acc = [EkfQuat.yaw_acc ,fread(fid,1,'single')];
                EkfQuat.solution_status = [EkfQuat.solution_status ,fread(fid,1,'uint32')];
            elseif msgID == 8 % EkfNav
                EkfNav.time_stamp = [EkfNav.time_stamp ,fread(fid,1,'uint32')];
                EkfNav.velocity_n = [EkfNav.velocity_n ,fread(fid,1,'single')];
                EkfNav.velocity_e = [EkfNav.velocity_e ,fread(fid,1,'single')];
                EkfNav.velocity_d = [EkfNav.velocity_d ,fread(fid,1,'single')];
                EkfNav.velocity_n_acc = [EkfNav.velocity_n_acc ,fread(fid,1,'single')];
                EkfNav.velocity_e_acc = [EkfNav.velocity_e_acc ,fread(fid,1,'single')];
                EkfNav.velocity_d_acc = [EkfNav.velocity_d_acc ,fread(fid,1,'single')];
                EkfNav.latitude = [EkfNav.latitude ,fread(fid,1,'double')];
                EkfNav.longitude = [EkfNav.longitude ,fread(fid,1,'double')];
                EkfNav.altitude = [EkfNav.altitude ,fread(fid,1,'double')];
                EkfNav.undulation = [EkfNav.undulation ,fread(fid,1,'single')];
                EkfNav.latitude_acc = [EkfNav.latitude_acc ,fread(fid,1,'single')];
                EkfNav.longitude_acc = [EkfNav.longitude_acc ,fread(fid,1,'single')];
                EkfNav.altitude_acc = [EkfNav.altitude_acc ,fread(fid,1,'single')];
                EkfNav.solution_status = [EkfNav.solution_status ,fread(fid,1,'uint32')];
            elseif msgID == 9 % ShipMotion
                ShipMotion.time_stamp = [ShipMotion.time_stamp ,fread(fid,1,'uint32')];
                ShipMotion.heave_period = [ShipMotion.heave_period ,fread(fid,1,'single')];
                ShipMotion.surge = [ShipMotion.surge ,fread(fid,1,'single')];
                ShipMotion.sway = [ShipMotion.sway ,fread(fid,1,'single')];
                ShipMotion.heave = [ShipMotion.heave ,fread(fid,1,'single')];
                ShipMotion.accel_x = [ShipMotion.accel_x ,fread(fid,1,'single')];
                ShipMotion.accel_y = [ShipMotion.accel_y ,fread(fid,1,'single')];
                ShipMotion.accel_z = [ShipMotion.accel_z ,fread(fid,1,'single')];
                ShipMotion.vel_x = [ShipMotion.vel_x ,fread(fid,1,'single')];
                ShipMotion.vel_y = [ShipMotion.vel_y ,fread(fid,1,'single')];
                ShipMotion.vel_z = [ShipMotion.vel_z ,fread(fid,1,'single')];
                ShipMotion.heave_status = [ShipMotion.heave_status ,fread(fid,1,'uint16')];
            elseif msgID == 13 % GpsVel
                GpsVel.time_stamp = [GpsVel.time_stamp ,fread(fid,1,'uint32')];
                GpsVel.gps_vel_status = [GpsVel.gps_vel_status ,fread(fid,1,'uint32')];
                GpsVel.gps_tow = [GpsVel.gps_tow ,fread(fid,1,'uint32')];
                GpsVel.vel_n = [GpsVel.vel_n ,fread(fid,1,'single')];
                GpsVel.vel_e = [GpsVel.vel_e ,fread(fid,1,'single')];
                GpsVel.vel_d = [GpsVel.vel_d ,fread(fid,1,'single')];
                GpsVel.vel_acc_n = [GpsVel.vel_acc_n ,fread(fid,1,'single')];
                GpsVel.vel_acc_e = [GpsVel.vel_acc_e ,fread(fid,1,'single')];
                GpsVel.vel_acc_d = [GpsVel.vel_acc_d ,fread(fid,1,'single')];
                GpsVel.course = [GpsVel.course ,fread(fid,1,'single')];
                GpsVel.course_acc = [GpsVel.course_acc ,fread(fid,1,'single')];
            elseif msgID == 14 % GpsPos
                GpsPos.time_stamp = [GpsPos.time_stamp ,fread(fid,1,'uint32')];
                GpsPos.gps_pos_status = [GpsPos.gps_pos_status ,fread(fid,1,'uint32')];
                GpsPos.gps_tow = [GpsPos.gps_tow ,fread(fid,1,'uint32')];
                GpsPos.lat = [GpsPos.lat ,fread(fid,1,'double')];
                GpsPos.long = [GpsPos.long ,fread(fid,1,'double')];
                GpsPos.alt = [GpsPos.alt ,fread(fid,1,'double')];
                GpsPos.undulation = [GpsPos.undulation ,fread(fid,1,'single')];
                GpsPos.pos_acc_lat = [GpsPos.pos_acc_lat ,fread(fid,1,'single')];
                GpsPos.pos_acc_long = [GpsPos.pos_acc_long ,fread(fid,1,'single')];
                GpsPos.pos_acc_alt = [GpsPos.pos_acc_alt ,fread(fid,1,'single')];
                GpsPos.num_sv_used = [GpsPos.num_sv_used ,fread(fid,1,'uint8')];
                GpsPos.base_station_id = [GpsPos.base_station_id ,fread(fid,1,'uint16')];
                GpsPos.diff_age = [GpsPos.diff_age ,fread(fid,1,'uint16')];  
            end
            crc = fread(fid,1,'uint16');
            byte = fread(fid,1,'uint8');
        end
    end
end
    
sbgData.Status = Status;
sbgData.UtcTime = UtcTime;
sbgData.ImuData = ImuData;
sbgData.Mag = Mag;
sbgData.EkfEuler = EkfEuler;
sbgData.EkfQuat = EkfQuat;
sbgData.EkfNav = EkfNav;
sbgData.ShipMotion = ShipMotion;
sbgData.GpsPos = GpsPos;    
sbgData.GpsVel = GpsVel; 

fclose(fid);