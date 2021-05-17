% script to explore microSWIFT raw data
%
% J. Thomson, 10/2020

clear all,

%%% GPS %%%

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
    
    GPSresults(gi).time = median(GPS.time); % ** not a full time stamp ***
    GPSresults(gi).ID =  [GPSflist(gi).name(11:13)];
    
    GPSsamplingrate = length(GPS.time)./((max(GPS.time)-min(GPS.time))*24*3600); % Hz

    
    figure(4), clf
    plot(GPS.lon,GPS.lat,'.')
    xlabel('lon'), ylabel('lat')
    print('-dpng',[ GPSflist(gi).name(1:end-4) '_positions.png'])
    
    
    figure(5), clf
    subplot(1,2,1), plot(GPS.u), hold on, plot(GPS.v), hold on
    xlabel('index'), ylabel('m/s'), legend('east','north')
    subplot(1,2,2), pwelch(detrend([GPS.u; GPS.v;]'),[],[],[], GPSsamplingrate ); set(gca,'Xscale','log')
    print('-dpng',[ GPSflist(gi).name(1:end-4) '_speeds.png'])
    
    if ~isempty(GPS.z),
        figure(6), clf
        subplot(1,2,1), plot(GPS.z), xlabel('index'), ylabel('elevation [m]'), 
        subplot(1,2,2), pwelch(detrend(GPS.z),[],[],[], GPSsamplingrate ); set(gca,'Xscale','log')
        print('-dpng',[ GPSflist(gi).name(1:end-4) '_elevation.png'])
    else
    end
    
    %% GPS post-processing
    if length(GPS.time) > 512, 
        
   
    % raw velocities
     [Euu fuu] = pwelch(detrend(GPS.u),[],[],[], GPSsamplingrate );
     [Evv fvv] = pwelch(detrend(GPS.v),[],[],[], GPSsamplingrate );
         
    % full process
    [ Hs, Tp, Dp, E, f, a1, b1, a2, b2 ] = GPSwaves(GPS.u,GPS.v,GPS.z,GPSsamplingrate);
    GPSresults(gi).sigwaveheight = Hs;
    GPSresults(gi).peakwaveperiod = Tp;
    GPSresults(gi).peakwavedirT = Dp;
    GPSresults(gi).wavespectra.energy = E;
    GPSresults(gi).wavespectra.freq = f;
    GPSresults(gi).wavespectra.a1 = a1;
    GPSresults(gi).wavespectra.b1 = b1;
    GPSresults(gi).wavespectra.a2 = a2;
    GPSresults(gi).wavespectra.b2 = b2;
    
    figure(7), clf
    loglog(fuu,Euu+Evv,f,E), hold on
    legend('vel','sse')
    title(['GPS spectra, H_s = ' num2str(Hs,2) ', T_p = ' num2str(Tp,2)])
    xlabel('frequency [Hz]')
    ylabel('Energy density [m^2/Hz]')
    print('-dpng',[ GPSflist(gi).name(1:end-4) '_spectra.png'])
    
    else
    end
    
end

save([GPSflist(1).name(1:13) '_results'],'GPSresults');


%%% IMU %%%%

IMUflist = dir('*IMU*.dat')


for ii = 1:length(IMUflist)
    
    %% IMU (with 4 embedded figures)

    
    if IMUflist(ii).bytes > 0, 
        
    IMU = readmicroSWIFT_IMU([IMUflist(ii).name], false);
    
    IMUsamplingrate =  length(IMU.acc)./((max(IMU.time)-min(IMU.time))*24*3600); % Hz

    IMUresults(ii).time = median(IMU.time(:)); %datenum(IMU.clock((round(end/2))));
    IMUresults(ii).ID =  [IMUflist(ii).name(11:13)];
    
    IMU.acc(isnan(IMU.acc)) = 0;
    IMU.mag(isnan(IMU.mag)) = 0;
    IMU.gyro(isnan(IMU.gyro)) = 0;
    
    figure(1), 
    subplot(1,2,1), plot(IMU.acc),  ylabel('Acceleration [m/s^2]'), 
    subplot(1,2,2), pwelch(detrend(IMU.acc),[],[],[], IMUsamplingrate ); set(gca,'Xscale','log')
    print('-dpng',[ [IMUflist(ii).name(1:end-4)] '_accelerations.png'])
    
    figure(2), 
    subplot(1,2,1), plot(IMU.mag), ylabel('magnetometer [uTesla]'), 
    subplot(1,2,2), pwelch(detrend(IMU.mag),[],[],[], IMUsamplingrate ); set(gca,'Xscale','log')
    print('-dpng',[ [IMUflist(ii).name(1:end-4)] '_magnetometer.png'])
    
    figure(3), 
    subplot(1,2,1), plot(IMU.gyro), ylabel('Gyro [deg/s]'), 
    subplot(1,2,2), pwelch(detrend(IMU.gyro),[],[],[], IMUsamplingrate ); set(gca,'Xscale','log')
    print('-dpng',[ [IMUflist(ii).name(1:end-4)] '_gyro.png'])
%    figure(4), plot(IMU.angles), ylabel('Euler angles [deg]'), print('-dpng',[ [IMUflist(ii).name(1:end-4)] '_Euler.png'])
    
    
    %% IMU post-processing
    
    if length(IMU.clock) == length(IMU.acc), % check data was read properly
    
    [Ezz fzz] = pwelch(detrend(IMU.acc(:,3)),[],[],[], IMUsamplingrate );
    Ezz(1) = []; fzz(1) = [];
    dfzz = (fzz(2)-fzz(1));
    %Ezz = var(IMU.acc(:,3)) ./ (sum(Ezz).*dfzz) * Ezz; % preserve variance
    Ezz = Ezz.*(6.28*fzz).^-4; % convert acceleration to evelation
   
%% beta post-processing

%     ENU = microSWIFT_motion(IMU);
%     disp('---------------------')
%     disp(IMUflist(ii).name)
%     disp('ENU.acc')
%     nanmean(ENU.acc)
%     disp('ENU.angles')
%     nanmean(ENU.angles)
%     disp('ENU.heading')
%     nanmean(ENU.heading)
%     disp('Hs (x,y,z)')
%     4*nanstd(ENU.pos)
%     notNaN = ~isnan(ENU.pos(:,1));
%     [ Hs, Tp, Dp, E, f, a1, b1, a2, b2, check ] = XYZwaves(ENU.pos(notNaN,1), ENU.pos(notNaN,2), ENU.pos(notNaN,3), IMUsamplingrate) ;

%% beta onboard processing 

ax = IMU.acc(:,1); % acc in x [m/s]
ay = IMU.acc(:,2); % acc in y [m/s]
az = IMU.acc(:,3); % acc in z [m/s]
gx = IMU.gyro(:,1); % gryo in x [deg/s]
gy = IMU.gyro(:,2); % gryo in y [deg/s]
gz = IMU.gyro(:,3); % gryo in z [deg/s]
mx = IMU.mag(:,1); % magnetometer in x [uT]
my = IMU.mag(:,2); % magnetometer in y [uT]
mz = IMU.mag(:,3); % magnetometer in z [uT]
 mxo = 60; myo = 60; mzo = 120;
 Wd = 0.0;  % 0 to 1
 fs = IMUsamplingrate;
[ Hs, Tp, Dp, E, f, a1, b1, a2, b2, check ] = processIMU(ax, ay, az, gx, gy, gz, mx, my, mz, mxo, myo, mzo, Wd, fs );

    IMUresults(ii).sigwaveheight = Hs;
    IMUresults(ii).peakwaveperiod = Tp;
    IMUresults(ii).peakwavedirT = Dp;
    IMUresults(ii).wavespectra.energy = E;
    IMUresults(ii).wavespectra.freq = f;
    IMUresults(ii).wavespectra.a1 = a1;
    IMUresults(ii).wavespectra.b1 = b1;
    IMUresults(ii).wavespectra.a2 = a2;
    IMUresults(ii).wavespectra.b2 = b2;
    IMUresults(ii).wavespectra.check = check;
    
    figure(8), clf
    loglog(fzz, Ezz,f,E)
    legend('Body frame','Earth frame')
    xlabel('frequency [Hz]')
    ylabel('Energy density [m^2/Hz]')
    title(['IMU spectra, H_s = ' num2str(Hs,2) ', T_p = ' num2str(Tp,2) ', D_p = ' num2str(Dp,3)])    
    print('-dpng',[ [IMUflist(ii).name(1:end-4)] '_spectra.png'])
    
%     figure(9), clf
%     plot(z), ylabel('Displacements [m]'), print('-dpng',[ [IMUflist(ii).name(1:end-4)] '_Displacements.png'])
%     figure(10), clf
%     plot(heading,'.'), ylabel('heading [deg M]'), print('-dpng',[ [IMUflist(ii).name(1:end-4)] '_Heading.png'])

    
    else 
    end
    
    end
    
end

save([GPSflist(1).name(1:13) '_results'],'GPSresults','IMUresults');

