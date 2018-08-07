function sbgData = sbgPythonToMatlab(filename)
% Matlab read-in of SWIFT v4.0 SBG data, as output from python
% readBinaryFromFile.py module
%
% M. Schwendeman, 12/2016

fid = fopen(filename,'rt'); % open file for reading
Status = struct('time_stamp',[],'general_status',[],'reserved1',[],'com_status',[],'aiding_status',[],'reserved2',[],'reserved3',[]);
UtcTime = struct('time_stamp',[],'clock_status',[],'year',[],'month',[],'day',[],'hour',[],'minute',[],'sec',[],'nanosec',[],'gps_tow',[]);
ImuData = struct('time_stamp',[],'imu_status',[],'accel_x',[],'accel_y',[],'accel_z',[],'gyro_x',[],'gyro_y',[],'gyro_z',[],'temp',[],'delta_vel_x',[],'delta_vel_y',[],'delta_vel_z',[],'delta_angle_x',[],'delta_angle_y',[],'delta_angle_z',[]);
EkfEuler = struct('time_stamp',[],'roll',[],'pitch',[],'yaw',[],'roll_acc',[],'pitch_acc',[],'yaw_acc',[],'solution_status',[]);
EkfQuat = struct('time_stamp',[],'q0',[],'q1',[],'q2',[],'q3',[],'roll_acc',[],'pitch_acc',[],'yaw_acc',[],'solution_status',[]);
EkfNav = struct('time_stamp',[],'velocity_n',[],'velocity_e',[],'velocity_d',[],'velocity_n_acc',[],'velocity_e_acc',[],'velocity_d_acc',[],'latitude',[],'longitude',[],'altitude',[],'undulation',[],'latitude_acc',[],'longitude_acc',[],'altitude_acc',[],'solution_status',[]);
ShipMotion = struct('time_stamp',[],'heave_period',[],'surge',[],'sway',[],'heave',[],'accel_x',[],'accel_y',[],'accel_z',[],'vel_x',[],'vel_y',[],'vel_z',[],'heave_status',[]);
GpsPos = struct('time_stamp',[],'gps_pos_status',[],'gps_tow',[],'lat',[],'long',[],'alt',[],'undulation',[],'pos_acc_lat',[],'pos_acc_long',[],'pos_acc_alt',[],'num_sv_used',[],'base_station_id',[],'diff_age',[]);
StatusFields = fieldnames(Status);
UtcTimeFields = fieldnames(UtcTime);
ImuDataFields = fieldnames(ImuData);
EkfEulerFields = fieldnames(EkfEuler);
EkfQuatFields = fieldnames(EkfQuat);
EkfNavFields = fieldnames(EkfNav);
ShipMotionFields = fieldnames(ShipMotion);
GpsPosFields = fieldnames(GpsPos);

while true
    line = fgetl(fid);
    if ~ischar(line)
        break
    end
    lineElements = textscan(line,'%s');
    msgID = lineElements{1}{1};
    if strcmp(msgID,'Status')
        lineElements = textscan(line,'%*s %*s%u %*s%u %*s%u %*s%u %*s%u %*s%u %*s%u %*s%u %*s%u %*s%u','Delimiter',{':',',',' ','\b','\t'},'MultipleDelimsAsOne',1);
        for i = 1:length(StatusFields)
            Status.(StatusFields{i}) = [Status.(StatusFields{i}), lineElements{i}];
        end
    elseif strcmp(msgID,'UtcTime')
        lineElements = textscan(line,'%*s %*s%u %*s%u %*s%u %*s%u %*s%u %*s%u %*s%u %*s%u %*s%u %*s%u','Delimiter',{':',',',' ','\b','\t'},'MultipleDelimsAsOne',1);
        for i = 1:length(UtcTimeFields)
            UtcTime.(UtcTimeFields{i}) = [UtcTime.(UtcTimeFields{i}), lineElements{i}];
        end        
    elseif strcmp(msgID,'ImuData')
        lineElements = textscan(line,'%*s %*s%u %*s%u %*s%f %*s%f %*s%f %*s%f %*s%f %*s%f %*s%f %*s%f %*s%f %*s%f %*s%f %*s%f %*s%f','Delimiter',{':',',',' ','\b','\t'},'MultipleDelimsAsOne',1);
        for i = 1:length(ImuDataFields)
            ImuData.(ImuDataFields{i}) = [ImuData.(ImuDataFields{i}), lineElements{i}];
        end
    elseif strcmp(msgID,'EkfEuler')
        lineElements = textscan(line,'%*s %*s%u %*s%f %*s%f %*s%f %*s%f %*s%f %*s%f %*s%u','Delimiter',{':',',',' ','\b','\t'},'MultipleDelimsAsOne',1);
        for i = 1:length(EkfEulerFields)
            EkfEuler.(EkfEulerFields{i}) = [EkfEuler.(EkfEulerFields{i}), lineElements{i}];
        end
        elseif strcmp(msgID,'EkfQuat')
        lineElements = textscan(line,'%*s %*s%u %*s%f %*s%f %*s%f %*s%f %*s%f %*s%f %*s%f %*s%u','Delimiter',{':',',',' ','\b','\t'},'MultipleDelimsAsOne',1);
        for i = 1:length(EkfQuatFields)
            EkfQuat.(EkfQuatFields{i}) = [EkfQuat.(EkfQuatFields{i}), lineElements{i}];
        end
        elseif strcmp(msgID,'EkfNav')
        lineElements = textscan(line,'%*s %*s%u %*s%f %*s%f %*s%f %*s%f %*s%f %*s%f %*s%f %*s%f %*s%f %*s%f %*s%f %*s%f %*s%f %*s%u','Delimiter',{':',',',' ','\b','\t'},'MultipleDelimsAsOne',1);
        for i = 1:length(EkfNavFields)
            EkfNav.(EkfNavFields{i}) = [EkfNav.(EkfNavFields{i}), lineElements{i}];
        end
        elseif strcmp(msgID,'ShipMotion')
        lineElements = textscan(line,'%*s %*s%u %*s%f %*s%f %*s%f %*s%f %*s%f %*s%f %*s%f %*s%f %*s%f %*s%f %*s%u','Delimiter',{':',',',' ','\b','\t'},'MultipleDelimsAsOne',1);
        for i = 1:length(ShipMotionFields)
            ShipMotion.(ShipMotionFields{i}) = [ShipMotion.(ShipMotionFields{i}), lineElements{i}];
        end
        elseif strcmp(msgID,'GpsPos')
        lineElements = textscan(line,'%*s %*s%u %*s%u %*s%u %*s%f %*s%f %*s%f %*s%f %*s%f %*s%f %*s%f %*s%u %*s%u %*s%u','Delimiter',{':',',',' ','\b','\t'},'MultipleDelimsAsOne',1);
        for i = 1:length(GpsPosFields)
            GpsPos.(GpsPosFields{i}) = [GpsPos.(GpsPosFields{i}), lineElements{i}];
        end
    end
end
sbgData.Status = Status;
sbgData.UtcTime = UtcTime;
sbgData.ImuData = ImuData;
sbgData.EkfEuler = EkfEuler;
sbgData.EkfQuat = EkfQuat;
sbgData.EkfNav = EkfNav;
sbgData.ShipMotion = ShipMotion;
sbgData.GpsPos = GpsPos;