% script to explore microSWIFT raw data
%
% J. Thomson, 10/2020

clear all,

GPSflist = dir('*GPS*.dat')

for gi = 1:length(GPSflist)
    
    %% GPS
    [ lat lon sog cog depth time] = readNMEA([GPSflist(gi).name]);
    GPS.lat = lat;
    GPS.lon = lon;
    GPS.time = time;
    GPS.u = sog .* sind(cog);
    GPS.v = sog .* cosd(cog);
    GPS.z = []; % need to update readNEMA to include altitude
    save([GPSflist(gi).name(1:end-4)],'GPS')
    
    figure(5), clf
    plot(GPS.lon,GPS.lat,'.')
    xlabel('lon'), ylabel('lat')
    print('-dpng',[ GPSflist(gi).name(1:end-4) '_positions.png'])
    
    
    figure(6), clf
    plot(GPS.u), hold on
    plot(GPS.v), hold on
    xlabel('index'), ylabel('m/s')
    legend('east','north')
    print('-dpng',[ GPSflist(gi).name(1:end-4) '_speeds.png'])
    
    
    %% GPS post-processing
    GPSsamplingrate = 2; % Hz
    [ Hs, Tp, Dp, E, f, a1, b1, a2, b2 ] = GPSwaves(GPS.u,GPS.v,GPS.z,GPSsamplingrate);
    
    figure(7), clf
    loglog(f,E), hold on
    title(['GPS spectra, H_s = ' num2str(Hs,2) ', T_p = ' num2str(Tp,2)])
    xlabel('frequency [Hz]')
    ylabel('Energy density [m^2/Hz]')
    print('-dpng',[ GPSflist(gi).name(1:end-4) '_spectra.png'])
    
end


IMUflist = dir('*Imu*.dat')


for ii = 1:length(IMUflist)
    
    %% IMU (with 4 embedded figures)
    
    if IMUflist(ii).bytes > 0, 
    IMU = readmicroSWIFT_IMU([IMUflist(ii).name], true);
    
    figure(1), print('-dpng',[ [IMUflist(ii).name(1:end-4)] '_accelerations.png'])
    figure(2), print('-dpng',[ [IMUflist(ii).name(1:end-4)] '_magnetometer.png'])
    figure(3), print('-dpng',[ [IMUflist(ii).name(1:end-4)] '_gyro.png'])
    figure(4), print('-dpng',[ [IMUflist(ii).name(1:end-4)] '_Euler.png'])
    
    
    %% IMU post-processing
    
    IMUsamplingrate =  1./median(diff(IMU.clock));
    [Ezz fzz] = pwelch(detrend(IMU.acc(:,3)),[],[],[], IMUsamplingrate );
    Ezz(1) = []; fzz(1) = [];
    dfzz = (fzz(2)-fzz(1));
    %Ezz = var(IMU.acc(:,3)) ./ (sum(Ezz).*dfzz) * Ezz; % preserve variance
    Ezz = Ezz.*(6.28*fzz).^-4; % convert acceleration to evelation
    
    ENU = microSWIFT_motion(IMU);
    notNaN = ~isnan(ENU.pos(:,1));
    [ Hs, Tp, Dp, E, f, a1, b1, a2, b2, check ] = XYZwaves(ENU.pos(notNaN,1), ENU.pos(notNaN,2), ENU.pos(notNaN,3), IMUsamplingrate) ;

    figure(8), clf
    loglog(fzz, Ezz,f,E)
    legend('Body frame','Earth frame')
    xlabel('frequency [Hz]')
    ylabel('Energy density [m^2/Hz]')
    title(['IMU spectra, H_s = ' num2str(Hs,2) ', T_p = ' num2str(Tp,2)])    
    print('-dpng',[ [IMUflist(ii).name(1:end-4)] '_spectra.png'])
    
    end
    
end

