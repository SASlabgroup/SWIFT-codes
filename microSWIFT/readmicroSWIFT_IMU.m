function IMU = readmicroSWIFT_IMU(filename, plotflag)
% function to read microSWIFT raw IMU data (stored in .dat files, by burst)
%
%   IMU = readmicroSWIFT_IMU(filename, plotflag)
%
% columns of raw data are: 
% elapsedTime(s), accelX(m/s^2), accelY(m/s^2) , accelZ(m/s^2) , 
%   magX(uTesla), magY(uTesla), magZ(uTesla), 
%       gyroX(deg/s), gyroY(deg/s), gyroZ(deg/s), 
% 
% J. Thomson,  7/2020
%               5/2021 covert timestamps to datenums

data = importdata(filename);

IMU.clock = data.textdata;
IMU.acc = data.data(:,1:3);
IMU.mag = data.data(:,4:6);
IMU.gyro = data.data(:,7:9);
%IMU.angles = data.data(:,10:12);  % removed in fall 2020

%% timestamps
IMU.time= datenum(IMU.clock); % modified 12/2021

%%% J. Davis 12/2021:
%%% Leaving this chunk of code here temporarily if you're interested in 
%%% doing the time test yourself. Added the new statement to line 23 above.
%%% also: please check if a transposition is needed; the original statement
%%% outputs a row vector, but the new statement outputs a column vector
%%% (which matches the remaining IMU fields anyway).

% tic
% for i=1:length(IMU.clock)
%     IMU.time(i) = datenum(IMU.clock(i));
% end
% toc
% % takes ~32s on my machine
% tic
% IMU.time2= datenum(IMU.clock);
% toc
% % takes ~2s on my machine
% sum(IMU.time.'-IMU.time2) % will be zero if equivalent

%%% (end of test)

%% plots

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

