% script to explore microSWIFT raw data
%
% J. Thomson, 10/2020

clear all,

GPSflist = dir('*GPS*.dat')
%ID = '006';
%burstname = '24Sep2020_11%3A48%3A00UTC_burst_12';

for gi = 1:length(GPSflist)
    
    %% GPS
    [ lat lon sog cog depth time] = readNMEA([GPSflist(gi).name]);
    u = sog .* sind(cog);
    v = sog .* cosd(cog);
    z = []; % need to update readNEMA to include altitude
    
    figure(5), clf
    plot(lon,lat,'.')
    xlabel('lon'), ylabel('lat')
    print('-dpng',[ GPSflist(gi).name(1:end-4) '_positions.png'])
    
    
    figure(6), clf
    plot(u), hold on
    plot(v), hold on
    xlabel('index'), ylabel('m/s')
    legend('east','north')
    print('-dpng',[ GPSflist(gi).name(1:end-4) '_speeds.png'])
    
    
    %% GPS post-processing
    GPSsamplingrate = 2; % Hz
    [ Hs, Tp, Dp, E, f, a1, b1, a2, b2 ] = GPSwaves(u,v,z,GPSsamplingrate);
    
    figure(7), clf
    loglog(f,E), hold on
    legend('GPS')
    xlabel('frequency [Hz]')
    ylabel('Energy density [m^2/Hz]')
    print('-dpng',[ GPSflist(gi).name(1:end-4) '_spectra.png'])
    
end


IMUflist = dir('*Imu*.dat')


for ii = 1:length(IMUflist)
    
    %% IMU (with 4 embedded figures)
    
    IMU = readmicroSWIFT_IMU([IMUflist(ii).name], true);
    
    figure(1), print('-dpng',[ [IMUflist(ii).name(1:end-4)] '_accelerations.png'])
    figure(2), print('-dpng',[ [IMUflist(ii).name(1:end-4)] '_magnetometer.png'])
    figure(3), print('-dpng',[ [IMUflist(ii).name(1:end-4)] '_gyro.png'])
    figure(4), print('-dpng',[ [IMUflist(ii).name(1:end-4)] '_Euler.png'])
    
    
    %% IMU post-processing
    
    IMUsamplingrate =  1./median(diff(IMU.clock));
    [Ezz fzz] = pwelch(detrend(IMU.acc(:,3)),[],[],[], IMUsamplingrate );
    dfzz = (fzz(2)-fzz(1));
    Ezz = var(IMU.acc(:,3)) ./ (sum(Ezz).*dfzz) * Ezz; % preserve variance
    Ezz = Ezz.*fzz.^-4; % convert acceleration to evelation
    
    figure(8), clf
    loglog(fzz, Ezz,'r')
    %legend('GPS','IMU')
    xlabel('frequency [Hz]')
    ylabel('Energy density [m^2/Hz]')
    print('-dpng',[ [IMUflist(ii).name(1:end-4)] '_spectra.png'])
    
end

