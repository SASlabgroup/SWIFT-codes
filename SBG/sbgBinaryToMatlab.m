function sbgData = sbgBinaryToMatlab(filename, varargin)
% Matlab read-in of SWIFT v4.0 binary SBG data
%   usage is 
%       sbgData = sbgBinaryToMatlab(filename);
%   where ouput is data structure with several fields
%
% Changelog:
% M. Schwendeman, 01/2017
%       10/2017, J. Thomson added fclose at end
%       12/2017, J. Thomson added varargin to read only the last portion of a file
% M. LeClair w/ claude, Nov 2026: a frame is read only if it is complete, ends
%   with ETX and its CRC checks out (sbgECom); a damaged frame (bytes lost in
%   logging) is skipped instead of being read into the next one; only class 0
%   logs with a payload of at most 4086 bytes are read
% M. LeClair w/ claude, Nov 2026: fields appended with X.f(end+1) = fread(...) instead of
%   X.f = [X.f, fread(...)], which copied the whole array at each frame (time
%   growing with the square of the frame count): 27 s -> 8 s on a 9 MB log

fid = fopen(filename,'rb','ieee-le'); % open file for reading; sbgECom is little endian (Firmware Reference Manual 2.1.1)

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

sync = [0 0];
while numel(sync) == 2
    sync = fread(fid,2,'uint8')';
    % Check if we are at a sync byte indicating start of a message
    if isequal(sync,[255 90]) % sync bytes 0xFF 0x5A
        msgID = fread(fid,1,'uint8');
        msgClass = fread(fid,1,'uint8');
        msgLen = fread(fid,1,'uint16');
        if isempty(msgLen); break; end
        
        % Check the frame (sbgECom frame format: Firmware Reference Manual 2.1.1)
        payloadStart = ftell(fid);
        fseek(fid,payloadStart-4,'bof'); % back to the message ID
        frame = fread(fid,msgLen+7,'uint8'); % ID, class, length (2), payload, CRC (2), ETX
        if msgLen > 4086 || ...            % Check payload length: at most 4086 bytes (manual 2.1.1)
           numel(frame) < msgLen+7 || ...  % Check length: fread returns fewer bytes if the file ends first
           frame(end) ~= 51 || ...         % Check last byte: ETX 0x33
           sbgCRC(frame(1:end-3)) ~= typecast(uint8(frame(end-2:end-1)),'uint16') % Check CRC over ID to payload, stored little endian
            fseek(fid,payloadStart-4,'bof'); % resync just after these sync bytes
            continue
        end

        % Unpack the payload of class 0 frames only (SBG_ECOM_CLASS_LOG_ECOM_0, the main sbgECom output logs: data and status); other classes reuse these message IDs
        fseek(fid,payloadStart,'bof'); % go to the start of the payload
        if msgClass ~= 0
            % Do nothing
        elseif msgID == 1  % Status
            Status.time_stamp(end+1) = fread(fid,1,'uint32');
            Status.general_status(end+1) = fread(fid,1,'uint16');
            Status.reserved1(end+1) = fread(fid,1,'uint16');
            Status.com_status(end+1) = fread(fid,1,'uint32');
            Status.aiding_status(end+1) = fread(fid,1,'uint32');
            Status.reserved2(end+1) = fread(fid,1,'uint32');
            Status.reserved3(end+1) = fread(fid,1,'uint16');
        elseif msgID == 2 % UtcTime
            UtcTime.time_stamp(end+1) = fread(fid,1,'uint32');
            UtcTime.clock_status(end+1) = fread(fid,1,'uint16');
            UtcTime.year(end+1) = fread(fid,1,'uint16');
            UtcTime.month(end+1) = fread(fid,1,'uint8');
            UtcTime.day(end+1) = fread(fid,1,'uint8');
            UtcTime.hour(end+1) = fread(fid,1,'uint8');
            UtcTime.min(end+1) = fread(fid,1,'uint8');
            UtcTime.sec(end+1) = fread(fid,1,'uint8');
            UtcTime.nanosec(end+1) = fread(fid,1,'uint32');
            UtcTime.gps_tow(end+1) = fread(fid,1,'uint32');
        elseif msgID == 3 % ImuData
            ImuData.time_stamp(end+1) = fread(fid,1,'uint32');
            ImuData.imu_status(end+1) = fread(fid,1,'uint16');
            ImuData.accel_x(end+1) = fread(fid,1,'single');
            ImuData.accel_y(end+1) = fread(fid,1,'single');
            ImuData.accel_z(end+1) = fread(fid,1,'single');
            ImuData.gyro_x(end+1) = fread(fid,1,'single');
            ImuData.gyro_y(end+1) = fread(fid,1,'single');
            ImuData.gyro_z(end+1) = fread(fid,1,'single');
            ImuData.temp(end+1) = fread(fid,1,'single');
            ImuData.delta_vel_x(end+1) = fread(fid,1,'single');
            ImuData.delta_vel_y(end+1) = fread(fid,1,'single');
            ImuData.delta_vel_z(end+1) = fread(fid,1,'single');
            ImuData.delta_angle_x(end+1) = fread(fid,1,'single');
            ImuData.delta_angle_y(end+1) = fread(fid,1,'single');
            ImuData.delta_angle_z(end+1) = fread(fid,1,'single');
        elseif msgID == 4 % Mag
            Mag.time_stamp(end+1) = fread(fid,1,'uint32');
            Mag.mag_status(end+1) = fread(fid,1,'uint16');
            Mag.mag_x(end+1) = fread(fid,1,'single');
            Mag.mag_y(end+1) = fread(fid,1,'single');
            Mag.mag_z(end+1) = fread(fid,1,'single');
            Mag.accel_x(end+1) = fread(fid,1,'single');
            Mag.accel_y(end+1) = fread(fid,1,'single');
            Mag.accel_z(end+1) = fread(fid,1,'single');
        elseif msgID == 6 % EkfEuler
            EkfEuler.time_stamp(end+1) = fread(fid,1,'uint32');
            EkfEuler.roll(end+1) = fread(fid,1,'single');
            EkfEuler.pitch(end+1) = fread(fid,1,'single');
            EkfEuler.yaw(end+1) = fread(fid,1,'single');
            EkfEuler.roll_acc(end+1) = fread(fid,1,'single');
            EkfEuler.pitch_acc(end+1) = fread(fid,1,'single');
            EkfEuler.yaw_acc(end+1) = fread(fid,1,'single');
            EkfEuler.solution_status(end+1) = fread(fid,1,'uint32');                
        elseif msgID == 7 % EkfQuat
            EkfQuat.time_stamp(end+1) = fread(fid,1,'uint32');
            EkfQuat.q0(end+1) = fread(fid,1,'single');
            EkfQuat.q1(end+1) = fread(fid,1,'single');
            EkfQuat.q2(end+1) = fread(fid,1,'single');
            EkfQuat.q3(end+1) = fread(fid,1,'single');
            EkfQuat.roll_acc(end+1) = fread(fid,1,'single');
            EkfQuat.pitch_acc(end+1) = fread(fid,1,'single');
            EkfQuat.yaw_acc(end+1) = fread(fid,1,'single');
            EkfQuat.solution_status(end+1) = fread(fid,1,'uint32');
        elseif msgID == 8 % EkfNav
            EkfNav.time_stamp(end+1) = fread(fid,1,'uint32');
            EkfNav.velocity_n(end+1) = fread(fid,1,'single');
            EkfNav.velocity_e(end+1) = fread(fid,1,'single');
            EkfNav.velocity_d(end+1) = fread(fid,1,'single');
            EkfNav.velocity_n_acc(end+1) = fread(fid,1,'single');
            EkfNav.velocity_e_acc(end+1) = fread(fid,1,'single');
            EkfNav.velocity_d_acc(end+1) = fread(fid,1,'single');
            EkfNav.latitude(end+1) = fread(fid,1,'double');
            EkfNav.longitude(end+1) = fread(fid,1,'double');
            EkfNav.altitude(end+1) = fread(fid,1,'double');
            EkfNav.undulation(end+1) = fread(fid,1,'single');
            EkfNav.latitude_acc(end+1) = fread(fid,1,'single');
            EkfNav.longitude_acc(end+1) = fread(fid,1,'single');
            EkfNav.altitude_acc(end+1) = fread(fid,1,'single');
            EkfNav.solution_status(end+1) = fread(fid,1,'uint32');
        elseif msgID == 9 % ShipMotion
            ShipMotion.time_stamp(end+1) = fread(fid,1,'uint32');
            ShipMotion.heave_period(end+1) = fread(fid,1,'single');
            ShipMotion.surge(end+1) = fread(fid,1,'single');
            ShipMotion.sway(end+1) = fread(fid,1,'single');
            ShipMotion.heave(end+1) = fread(fid,1,'single');
            ShipMotion.accel_x(end+1) = fread(fid,1,'single');
            ShipMotion.accel_y(end+1) = fread(fid,1,'single');
            ShipMotion.accel_z(end+1) = fread(fid,1,'single');
            ShipMotion.vel_x(end+1) = fread(fid,1,'single');
            ShipMotion.vel_y(end+1) = fread(fid,1,'single');
            ShipMotion.vel_z(end+1) = fread(fid,1,'single');
            ShipMotion.heave_status(end+1) = fread(fid,1,'uint16');
        elseif msgID == 13 % GpsVel
            GpsVel.time_stamp(end+1) = fread(fid,1,'uint32');
            GpsVel.gps_vel_status(end+1) = fread(fid,1,'uint32');
            GpsVel.gps_tow(end+1) = fread(fid,1,'uint32');
            GpsVel.vel_n(end+1) = fread(fid,1,'single');
            GpsVel.vel_e(end+1) = fread(fid,1,'single');
            GpsVel.vel_d(end+1) = fread(fid,1,'single');
            GpsVel.vel_acc_n(end+1) = fread(fid,1,'single');
            GpsVel.vel_acc_e(end+1) = fread(fid,1,'single');
            GpsVel.vel_acc_d(end+1) = fread(fid,1,'single');
            GpsVel.course(end+1) = fread(fid,1,'single');
            GpsVel.course_acc(end+1) = fread(fid,1,'single');
        elseif msgID == 14 % GpsPos
            GpsPos.time_stamp(end+1) = fread(fid,1,'uint32');
            GpsPos.gps_pos_status(end+1) = fread(fid,1,'uint32');
            GpsPos.gps_tow(end+1) = fread(fid,1,'uint32');
            GpsPos.lat(end+1) = fread(fid,1,'double');
            GpsPos.long(end+1) = fread(fid,1,'double');
            GpsPos.alt(end+1) = fread(fid,1,'double');
            GpsPos.undulation(end+1) = fread(fid,1,'single');
            GpsPos.pos_acc_lat(end+1) = fread(fid,1,'single');
            GpsPos.pos_acc_long(end+1) = fread(fid,1,'single');
            GpsPos.pos_acc_alt(end+1) = fread(fid,1,'single');
            GpsPos.num_sv_used(end+1) = fread(fid,1,'uint8');
            GpsPos.base_station_id(end+1) = fread(fid,1,'uint16');
            GpsPos.diff_age(end+1) = fread(fid,1,'uint16');  
        end
        fseek(fid,payloadStart+msgLen+3,'bof'); % end of the frame
    else
        fseek(fid,-1,'cof'); % This byte did not start a sync, move forward by one byte
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

end

function crc = sbgCRC(bytes)
% 16 bit CRC of a frame's ID, class, length and payload bytes (sbgECom Firmware Reference Manual SBGFWM 2.4, 2.1.3 CRC definition).
% The same CRC as the manual's calcCRC (sbgCalcCRC), computed a byte at a time with a lookup table as in the sbgECom library
% (github.com/SBG-Systems/sbgECom, common/crc/sbgCrc.c): table(b+1) is sbgCalcCRC of the single byte b, and for each byte
% index = (crc ^ byte) & 0xFF; crc = table[index] ^ (crc >> 8).
% The XOR of two bytes is looked up too (XOR(a+1,b+1) = a ^ b): calling bitxor on single values costs a function call per byte, which is much slower in MATLAB than indexing an array.
% table and XOR are persistent, so they are built on the first call only.
persistent table XOR
if isempty(table)
    table = zeros(256,1);
    for b = 0:255
        table(b+1) = sbgCalcCRC(b);
    end
    XOR = bitxor((0:255)',0:255);
end
crc = 0;
for j = 1:numel(bytes)
    index = XOR(mod(crc,256)+1,bytes(j)+1); % (crc ^ byte) & 0xFF
    t = table(index+1);
    % table[index] ^ (crc >> 8): crc >> 8 is under 256, so only the low byte of table[index] changes
    crc = t - mod(t,256) + XOR(mod(t,256)+1,floor(crc/256)+1);
end
end
