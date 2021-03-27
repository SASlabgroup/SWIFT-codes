function IMU = readmicroSWIFT_IMU(filename, plotflag)
% function to read microSWIFT raw IMU data (stored in .dat files, by burst)
%
%   IMU = readmicroSWIFT_IMU(filename, plotflag)
%
% J. Thomson,  7/2020

% columns of raw data are: 
% elapsedTime(s), accelX(m/s^2), accelY(m/s^2) , accelZ(m/s^2) , 
%   magX(uTesla), magY(uTesla), magZ(uTesla), 
%       gyroX(radians/s), gyroY(radians/s), gyroZ(radians/s), 
%           roll(deg), pitch(deg), yaw(deg)
% 
% suspect that gyro values are really deg/s, not rad/s

data = importdata(filename);

IMU.clock = data.textdata;
IMU.acc = data.data(:,1:3);
IMU.mag = data.data(:,4:6);
IMU.gyro = data.data(:,7:9);
%IMU.angles = data.data(:,10:12);

save(filename(1:end-4),'IMU');

if plotflag, 
    
    figure(1), clf
    plot(IMU.acc)
    ylabel('Acceleration [m/s^2]')
    xlabel('index')
    
    figure(2), clf
    plot(IMU.mag)
    ylabel('magnetometer [uTesla]')
    xlabel('index')

    figure(3), clf
    plot(IMU.gyro)
    ylabel('Gyro [deg/s]')
    xlabel('index')

%     figure(4), clf
%     plot(IMU.angles)
%     ylabel('Euler angles [deg]')
%     xlabel('index')
    
    
end


end

