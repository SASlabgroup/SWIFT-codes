function [ Hs, Tp, Dp, E, f, a1, b1, a2, b2, check ] = processIMU(ax, ay, az, gx, gy, gz, mx, my, mz, mxo, myo, mzo, Wd, fs );
% 
% Matlab function to process microSWIFT IMU measurements 
% 
% Inputs are raw accelerometer, gyro, and magnotometer readings (3 axis each)
% along with magnetometer offsets (3), a weight coef for filtering the gyro, 
% and the sampling frequency of the raw data
%
%   [ Hs, Tp, Dp, E, f, a1, b1, a2, b2, check ] = processIMU(ax, ay, az, gx, gy, gz, mx, my, mz, mxo, myo, mzo, Wd, fs );
%
% Outputs are significat wave height [m], dominant period [s], dominant direction 
% [deg T, using meteorological from which waves are propagating], spectral 
% energy density [m^2/Hz], frequency [Hz], and 
% the normalized spectral moments a1, b1, a2, b2, 
%
% Outputs will be '9999' for invalid results.
%
% The input weight coef Wd must be between 0 and 1, with 0 as default 
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


%% check data sizes

samples = [length(ax) length(ay) length(az) length(gx) length(gy) length(gz) length(mx) length(my) length(mz)];

if samples(1) > (fs*256) & fs > 1 & diff(samples)==0,

%% despike

nstd = 5; 

ax = despike(ax, nstd);
ay = despike(ay, nstd);
az = despike(az, nstd);
gx = despike(gx, nstd);
gy = despike(gy, nstd);
gz = despike(gz, nstd);
mx = despike(mx, nstd);
my = despike(my, nstd);
mz = despike(mz, nstd);


%% rotate, filter, and integrate to get wave displacements

[x, y, z, roll, pitch, yaw, heading] = IMUtoXYZ(ax, ay, az, gx, gy, gz, mx, my, mz, mxo, myo, mzo, Wd, fs );
%plot(z)

%% wave calcs

[ Hs, Tp, Dp, E, f, a1, b1, a2, b2, check ] = XYZwaves(x, y, z, fs) ;


%% error codes if not enough points or sufficent sampling rate or data, give 9999

else 
  
     Hs = 9999;
     Tp = 9999; 
     Dp = 9999; 
     E = 9999; 
     f = 9999;
     a1 = 9999;
     b1 = 9999;
     a2 = 9999;
     b2 = 9999;
     check = 9999;

end


%% EMBEDDED despike function

    function clean = despike(raw, nstd);
        % find spikes greater than n standard deviations 
        % and replace with mean

        spikes = abs(detrend(raw)) > nstd*std(raw);
        clean = raw;
        clean(spikes) = mean( raw(~spikes) );         
        
    end

end
