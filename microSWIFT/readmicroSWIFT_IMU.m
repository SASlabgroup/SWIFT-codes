function IMU = readmicroSWIFT_IMU(filename, plotflag)
% function to read microSWIFT raw IMU data (stored in .dat files, by burst)
%
%   IMU = readmicroSWIFT_IMU(filename, plotflag)
%
% J. Thomson,  7/2020

% columns of raw data are
% elapsedTime(s), accelX(m/s^2), accelY(m/s^2) , accelZ(m/s^2) , magX(uTesla), magY(uTesla), magZ(uTesla), gyroX(radians/s), gyroY(radians/s), gyroZ(radians/s), roll(deg), pitch(deg), yaw(deg)

data = importdata(filename);

IMU.clock = data(:,1);
IMU.acc = data(:,2:4);
IMU.mag = data(:,5:7);
IMU.gyro = data(:,8:10);
IMU.angles = data(:,11:13);

save(filename(1:end-4),'IMU');

if plotflag, 
    
    figure(1), clf
    plot(IMU.clock-min(IMU.clock),IMU.acc)
    ylabel('Acceleration [m/s^2]')
    xlabel('seconds')
    
    figure(2), clf
    plot(IMU.clock-min(IMU.clock),IMU.mag)
    ylabel('magnetometer [uTesla]')
    xlabel('seconds')

    figure(3), clf
    plot(IMU.clock-min(IMU.clock),IMU.gyro)
    ylabel('Gyro [rad/s]')
    xlabel('seconds')

    figure(4), clf
    plot(IMU.clock-min(IMU.clock),IMU.angles)
    ylabel('Euler angles [deg]')
    xlabel('seconds')
    
end


end

