% script to explore microSWIFT raw data
%
% J. Thomson, 10/2020

clear all,

%%% GPS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

GPSflist = dir('*GPS*.dat')

if ~isempty(GPSflist)
    
    for gi = 1:length(GPSflist)
        
        [ lat lon sog cog depth time altitude] = readNMEA([GPSflist(gi).name]);
        GPS.lat = lat;
        GPS.lon = lon;
        GPS.time = time;
        GPS.u = sog .* sind(cog);
        GPS.v = sog .* cosd(cog);
        GPS.z = altitude; 
        save([GPSflist(gi).name(1:end-4)],'GPS')
        
        GPSsamplingrate = length(GPS.time)./((max(GPS.time)-min(GPS.time))*24*3600); % Hz
        
        %% plot raw GPS data
        
        figure(4), clf
        plot(GPS.lon,GPS.lat,'.')
        xlabel('lon'), ylabel('lat')
        print('-dpng',[ GPSflist(gi).name(1:end-4) '_positions.png'])
        
        figure(5), clf
        subplot(1,2,1), plot(GPS.u), hold on, plot(GPS.v), hold on
        xlabel('index'), ylabel('m/s'), legend('east','north')
        if length([GPS.u])>256,
            subplot(1,2,2), pwelch(detrend([GPS.u; GPS.v;]'),[],[],[], GPSsamplingrate ); set(gca,'Xscale','log')
        end
        print('-dpng',[ GPSflist(gi).name(1:end-4) '_speeds.png'])
        
        if ~isempty(GPS.z) && length(GPS.z)>256,
            figure(6), clf
            subplot(1,2,1), plot(GPS.z), xlabel('index'), ylabel('elevation [m]'),
            subplot(1,2,2), pwelch(detrend(GPS.z),[],[],[], GPSsamplingrate ); set(gca,'Xscale','log')
            print('-dpng',[ GPSflist(gi).name(1:end-4) '_elevation.png'])
        else
        end
        
        %% GPS post-processing
        
        if length(GPS.time) > 1024,
            
            % raw position spectra
            [Elat fgps] = pwelch(detrend(deg2km(lat)*1000),[],[],[], GPSsamplingrate );
            [Elon fgps] = pwelch(detrend(deg2km(lon,cosd(median(lat))*6371)*1000),[],[],[], GPSsamplingrate );
            [Ezz fgps] = pwelch(detrend(GPS.z),[],[],[], GPSsamplingrate );
            
            % raw velocity spectra (sanity check)
            [Esog fgps] = pwelch(detrend(sog),[],[],[], GPSsamplingrate );
            [Euu fgps] = pwelch(detrend(GPS.u),[],[],[], GPSsamplingrate );
            [Evv fgps] = pwelch(detrend(GPS.v),[],[],[], GPSsamplingrate );
            
            % standard GPS wave processing
            [ Hs, Tp, Dp, E, f, a1, b1, a2, b2 ] = ...
                GPSwaves(GPS.u,GPS.v,GPS.z,GPSsamplingrate);
            
            % alternate processing by integrating velocites to displacements
            RC = 4;
            u = RCfilter(GPS.u, RC, GPSsamplingrate);
            v = RCfilter(GPS.v, RC, GPSsamplingrate);
            x = cumtrapz(u)*(1/GPSsamplingrate);
            y = cumtrapz(v)*(1/GPSsamplingrate);       
            x = detrend(x);
            y = detrend(y);           
            x = RCfilter(x, RC, GPSsamplingrate);
            y = RCfilter(y, RC, GPSsamplingrate);
            [Exx fgps] = pwelch(x,[],[],[], GPSsamplingrate );
            [Eyy fgps] = pwelch(y,[],[],[], GPSsamplingrate );
            
            % store in SWIFT structure
            GPSresults(gi).sigwaveheight = Hs;
            GPSresults(gi).peakwaveperiod = Tp;
            GPSresults(gi).peakwavedirT = Dp;
            GPSresults(gi).wavespectra.energy = E;
            GPSresults(gi).wavespectra.freq = f;
            GPSresults(gi).wavespectra.a1 = a1;
            GPSresults(gi).wavespectra.b1 = b1;
            GPSresults(gi).wavespectra.a2 = a2;
            GPSresults(gi).wavespectra.b2 = b2;
            GPSresults(gi).time = median(GPS.time); % ** not a full time stamp ***
            GPSresults(gi).ID =  [GPSflist(gi).name(11:13)];
            
            figure(7), clf
            loglog(fgps,Ezz,fgps,Elat+Elon,fgps,Esog,fgps,Euu+Evv,fgps,Exx+Eyy,f,E), hold on
            legend('alt','lat+lon','sog','uu+vv','xx+yy','sse')
            title(['GPS spectra, H_s = ' num2str(Hs,2) ', T_p = ' num2str(Tp,2)])
            xlabel('frequency [Hz]')
            ylabel('Energy density [m^2/Hz]')
            print('-dpng',[ GPSflist(gi).name(1:end-4) '_spectra.png'])
            
        else
        end
        
    end
    
    save([GPSflist(1).name(1:13) '_results'],'GPSresults');
    
else
    GPSresults = [];
end


%%% IMU %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

IMUflist = dir('*IMU*.dat')

for ii = 1:length(IMUflist)
    
    if IMUflist(ii).bytes > 0,
        
        IMU = readmicroSWIFT_IMU([IMUflist(ii).name], false);
        
        IMUsamplingrate =  length(IMU.acc)./((max(IMU.time)-min(IMU.time))*24*3600); % Hz
        
        %% plot IMU raw data
        
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
        
        
        % IMU processing
        
        if length(IMU.clock) == length(IMU.acc), % check data was read properly
            
            %% post-processing in body reference from (simple)
            [Ezz fzz] = pwelch(IMU.acc(:,3),[],[],[],IMUsamplingrate);
            Ezz = Ezz ./ ( (2*pi*fzz).^4);
            Hs_simple = 4 * sqrt( nansum( Ezz( fzz > 0.05 & fzz < 0.5 ) ) * (fzz(3)-fzz(2)));
            
            %%  post-processing with Matlab navigation toolbox
            
            ENU = microSWIFT_AHRSfilter( IMU );
            
            [ Hs, Tp, Dp, E, f, a1, b1, a2, b2, check ] = XYZwaves(ENU.xyz(:,1), ENU.xyz(:,2), ENU.xyz(:,3), IMUsamplingrate) ;
            
            %% onboard processing with custom code (beta)
            
            mxo = 60; myo = 60; mzo = 120; % magnetometer offsets
            Wd = .5;  % weighting in complimentary filter, 0 to 1
            %[ Hs, Tp, Dp, E, f, a1, b1, a2, b2, check ] = ...
            %    processIMU(IMU.acc(:,1), IMU.acc(:,2), IMU.acc(:,3), IMU.gyro(:,1), IMU.gyro(:,2), IMU.gyro(:,3), IMU.mag(:,1), IMU.mag(:,2), IMU.mag(:,3), mxo, myo, mzo, Wd, IMUsamplingrate);
            
            %% store results in SWIFT structure
            
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
            
            IMUresults(ii).z = ENU.xyz(:,3); % raw wave displacements
            
            IMUresults(ii).time = median(IMU.time(:)); %datenum(IMU.clock((round(end/2))));
            IMUresults(ii).ID =  [IMUflist(ii).name(11:13)];
            
            figure(8), clf
            loglog(fzz, Ezz, f,E)
            legend(['Body frame, Hs = ' num2str(Hs_simple)],['Earth frame, H_s = ' num2str(Hs)])
            xlabel('frequency [Hz]')
            ylabel('Energy density [m^2/Hz]')
            title([ IMUflist(ii).name(1:end-4) ' spectra' ],'interp','none')
            %title(['IMU spectra, H_s = ' num2str(Hs,2) ', T_p = ' num2str(Tp,2) ', D_p = ' num2str(Dp,3)])
            print('-dpng',[ [IMUflist(ii).name(1:end-4)] '_spectra.png'])
            
            
        else
        end
        
    end
    
end

save([IMUflist(1).name(1:13) '_results'],'GPSresults','IMUresults');


%% EMBEDDED RC FILTER function (high pass filter) %%

function a = RCfilter(b, RC, fs);

alpha = RC / (RC + 1./fs);
a = b;

for ui = 2:length(b)
    a(ui) = alpha * a(ui-1) + alpha * ( b(ui) - b(ui-1) );
end

end

