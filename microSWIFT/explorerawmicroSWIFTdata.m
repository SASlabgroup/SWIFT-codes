% script to explore microSWIFT raw data
% intended to be run in directory with mission data from a single buoy
% loops thru GPS files and then IMU files; reading, plotting, processing each
%
% J. Thomson, 10/2020

clear all,

useAHRStoolbox = true; % binary flag to use Navigation toolbox for AHRS (required toolbox, Matlab 2019 and later)
readraw = false;  % binary flag to force re-read of raw txt data (otherwise use converted mat file)

%%% GPS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

GPSflist = dir('*GPS*.dat');

if ~isempty(GPSflist)
    
    for gi = 1:length(GPSflist)
        
        disp(['GPS file ' num2str(gi) ' of ' num2str(length(GPSflist))])
        
        matfile = dir([GPSflist(gi).name(1:end-4) '.mat']);
        
        if readraw | isempty(matfile),
            [ lat lon sog cog depth time altitude] = readNMEA([GPSflist(gi).name]);
            GPS.lat = lat;
            GPS.lon = lon;
            GPS.sog = sog;
            GPS.time = time;
            GPS.u = sog .* sind(cog);
            GPS.v = sog .* cosd(cog);
            GPS.z = altitude;
            shortest = min( [ length(GPS.u), length(GPS.v), length(GPS.z) ] );
            GPS.u(shortest:end) = []; GPS.v(shortest:end) = []; GPS.z(shortest:end) = [];
            bad = isnan(GPS.z);
            save([GPSflist(gi).name(1:end-4)],'GPS')
            
            GPSsamplingrate = length(GPS.time)./((max(GPS.time)-min(GPS.time))*24*3600); % Hz
            save([GPSflist(gi).name(1:end-4) '.mat'],'GPS','GPSsamplingrate');
            
        else
            load([GPSflist(gi).name(1:end-4) '.mat']);
            disp('loading existing mat file')
        end
        
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
        
        if ~isempty(GPS.z) && length(GPS.z)>256 && all(~isnan(detrend(GPS.z))),
            figure(6), clf
            subplot(1,2,1), plot(GPS.z), xlabel('index'), ylabel('elevation [m]'),
            subplot(1,2,2), pwelch(detrend(GPS.z),[],[],[], GPSsamplingrate ); set(gca,'Xscale','log')
            print('-dpng',[ GPSflist(gi).name(1:end-4) '_elevation.png'])
        else
        end
        
        %% GPS post-processing
        
        if length(GPS.time) > 2048,
            
            % raw position spectra
            [Elat fgps] = pwelch(detrend(deg2km(GPS.lat)*1000),[],[],[], GPSsamplingrate );
            [Elon fgps] = pwelch(detrend(deg2km(GPS.lon,cosd(median(GPS.lat))*6371)*1000),[],[],[], GPSsamplingrate );
            [Ezz fgps] = pwelch(detrend(GPS.z),[],[],[], GPSsamplingrate );
            
            % raw velocity spectra (sanity check)
            [Esog fgps] = pwelch(detrend(GPS.sog),[],[],[], GPSsamplingrate );
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
            GPSresults(gi).time = median(GPS.time);
            GPSresults(gi).lat = median(GPS.lat);
            GPSresults(gi).lon = median(GPS.lon);
            GPSresults(gi).ID =  [GPSflist(gi).name(11:13)];
            
            figure(7), clf
            loglog(fgps,Ezz,fgps,Elat+Elon,fgps,Esog,fgps,Euu+Evv,fgps,Exx+Eyy,f,E), hold on
            legend('alt','lat+lon','sog','uu+vv','xx+yy','sse')
            title(['GPS spectra, H_s = ' num2str(Hs,2) ', T_p = ' num2str(Tp,2)])
            xlabel('frequency [Hz]')
            ylabel('Energy density [m^2/Hz]')
            print('-dpng',[ GPSflist(gi).name(1:end-4) '_spectra.png'])
            
        else
            disp([num2str(gi) ', GPS record not long enough'])
        end
        
    end
    
    save([GPSflist(end).name(1:13) '_' GPSflist(end).name(19:27) '_results'],'GPSresults');
    
else
    GPSresults = [];
end


%%% IMU %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

IMUflist = dir('*IMU*.dat');

for ii = 1:length(IMUflist)
    
    disp(['IMU file ' num2str(ii) ' of ' num2str(length(IMUflist))])
    
    if IMUflist(ii).bytes > 0,
        
        matfile = dir([IMUflist(ii).name(1:end-4) '.mat']);
        
        if readraw | isempty(matfile),
            
            IMU = readmicroSWIFT_IMU([IMUflist(ii).name], false);
            
            IMUsamplingrate =  length(IMU.acc)./((max(IMU.time)-min(IMU.time))*24*3600); % usually 12 Hz
            IMU.acc(end,:) = []; % trim last entry
            IMU.mag(end,:) = []; % trim last entry
            IMU.gyro(end,:) = []; % trim last entry
            IMU.clock(end) = [];  % trim last entry
            IMU.time(end) = [];   % trim last entry
            save([IMUflist(ii).name(1:end-4) '.mat'],'IMU*')
        else
            load([IMUflist(ii).name(1:end-4) '.mat'])
            disp('loading existing mat file')
        end
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
        
        if length(IMU.clock) == length(IMU.acc) && length(IMU.clock)/IMUsamplingrate > 512, % check data was read properly
            
            %% post-processing in body reference from (simple)
            
            [Ezz fzz] = pwelch(IMU.acc(:,3),[],[],[],IMUsamplingrate);
            Ezz = Ezz ./ ( (2*pi*fzz).^4);
            Hs_simple = 4 * sqrt( nansum( Ezz( fzz > 0.05 & fzz < 0.5 ) ) * (fzz(3)-fzz(2)));
            
         
            if useAHRStoolbox, %%  post-processing with Matlab navigation toolbox %%%%%%%%%%%%
                
                ENU = microSWIFT_AHRSfilter( IMU );
                save([IMUflist(ii).name(1:end-4) '_ENU.mat'],'ENU*','useAHRStoolbox')
                
                [ Hs, Tp, Dp, E, f, a1, b1, a2, b2, check ] = XYZwaves(ENU.xyz(:,1), ENU.xyz(:,2), ENU.xyz(:,3), IMUsamplingrate) ;
                                
            else  %% onboard processing with custom code (beta) %%%%%%%%%%%%%%%%%%%%%
                mxo = 60; myo = 60; mzo = 120; % magnetometer offsets
                Wd = 0.0;  % weighting in complimentary filter, 0 to 1
                [x, y, z, roll, pitch, yaw, heading] = ...
                    IMUtoXYZ(IMU.acc(:,1), IMU.acc(:,2), IMU.acc(:,3), IMU.gyro(:,1), IMU.gyro(:,2), ...
                    IMU.gyro(:,3), IMU.mag(:,1), IMU.mag(:,2), IMU.mag(:,3), mxo, myo, mzo, Wd, IMUsamplingrate);
                [ Hs, Tp, Dp, E, f, a1, b1, a2, b2, check ] = XYZwaves(x, y, z, IMUsamplingrate) ;
                clear ENU
                ENU.xyz(:,1) = x;
                ENU.xyz(:,2) = y;
                ENU.xyz(:,3) = z;
                ENU.time = IMU.time;
                save([IMUflist(ii).name(1:end-4) '_ENU.mat'],'ENU*','useAHRStoolbox')
            end
            
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
            
            IMUresults(ii).x = ENU.xyz(:,1); % raw wave displacements
            IMUresults(ii).y = ENU.xyz(:,2); % raw wave displacements
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
            disp([num2str(ii) ', IMU not processed'])
        end
        
    end
    
end

if useAHRStoolbox
    save([IMUflist(1).name(1:13) '_' IMUflist(1).name(19:27) '_XYZresults_simple'],'GPSresults','IMUresults');
else
    save([IMUflist(1).name(1:13) '_' IMUflist(1).name(19:27) '_XYZresults_AHRS'],'GPSresults','IMUresults');
end

%% summary plot

skip = 0; % bursts to skip (beginning)
crop = 0; % bursts to skip (end)

index = 0; % cummulative index for raw heave
figure(10), clf
for bi = (1+skip):(length(IMUresults)-crop),
    matchburst = find(abs(IMUresults(bi).time-[GPSresults.time]) < 10/60/24);
    if ~isempty(matchburst) && length(matchburst)==1,
        subplot(2,2,1),
        plot(GPSresults(matchburst).lon,GPSresults(matchburst).lat,'.','markersize',18), hold on
        ylabel('lat'),xlabel('lon')
        subplot(2,2,2),
        loglog(IMUresults(bi).wavespectra.freq, IMUresults(bi).wavespectra.energy,'-','linewidth',2), hold on
        ylabel('Energy [m^2/Hz]'), xlabel('f [Hz]')
        subplot(2,1,2),%subplot(2,length(IMUresults),bi+length(IMUresults)),
        plot(index+[1:length(IMUresults(bi).z)], IMUresults(bi).z), hold on
        index = index + length(IMUresults(bi).z);
    end
end
set(gca,'YLim',[-3 3])
ylabel('heave [m]')
xlabel('index []')
if useAHRStoolbox
    print('-dpng',[IMUflist(end).name(1:13) '_' IMUflist(end).name(19:27) '_map_spectra_AHRSheave.png']);
else
    print('-dpng',[IMUflist(end).name(1:13) '_' IMUflist(end).name(19:27) '_map_spectra_simpleheave.png']);
end

%% combine GPS and IMU raw data to post-process together
% this is not very robust yet... will fail if there are not same number of
% GPS and IMU files (for same bursts)

if length(GPSflist) == length(IMUflist)
    
    for ii = 1:length(GPSflist)
        
        disp(['GPS and IMU merge ' num2str(ii) ' of ' num2str(length(GPSflist))])
        
        load([GPSflist(ii).name(1:end-4) '.mat']);
        
        %%%%%%%%  use vertical accelerations %%%%%%%%%%%%%%%%%%%%
        load([IMUflist(ii).name(1:end-4) '.mat']);
        
        faketime = linspace(min(IMU.time),max(IMU.time),length(IMU.time));
        u = interp1(GPS.time(1:length(GPS.u)),GPS.u,faketime);
        v = interp1(GPS.time(1:length(GPS.v)),GPS.v,faketime);
        az = IMU.acc(:,3);
        u( isnan(u) ) = 0; % nans from interp
        v( isnan(v) ) = 0; % nans from interp
        trim = find( az == 0);
        u( trim ) = [];
        v( trim ) = [];
        az( trim ) = [];
        faketime( trim ) = [];
        
        figure(20),
        plot(faketime,u,faketime,v,faketime,az)
        datetick
        legend('u','v','az')
        print('-dpng',[ [IMUflist(gi).name(1:end-4)] '_UVaz.png'])
             
        [ Hs, Tp, Dp, E, f, a1, b1, a2, b2, check ] = GPSandIMUwaves(u, v, -az./9.8, [], [], IMUsamplingrate); % az units must be g
        
        % store results in SWIFT structure
        GPSandIMUresults(ii).sigwaveheight = Hs;
        GPSandIMUresults(ii).peakwaveperiod = Tp;
        GPSandIMUresults(ii).peakwavedirT = Dp;
        GPSandIMUresults(ii).wavespectra.energy = E;
        GPSandIMUresults(ii).wavespectra.freq = f;
        GPSandIMUresults(ii).wavespectra.a1 = a1;
        GPSandIMUresults(ii).wavespectra.b1 = b1;
        GPSandIMUresults(ii).wavespectra.a2 = a2;
        GPSandIMUresults(ii).wavespectra.b2 = b2;
        GPSandIMUresults(ii).wavespectra.check = check;
        GPSandIMUresults(ii).x = ENU.xyz(:,1); % raw wave displacements
        GPSandIMUresults(ii).y = ENU.xyz(:,2); % raw wave displacements
        GPSandIMUresults(ii).z = ENU.xyz(:,3); % raw wave displacements
        GPSandIMUresults(ii).time = median(ENU.time(:)); %datenum(IMU.clock((round(end/2))));
        GPSandIMUresults(ii).ID =  [IMUflist(ii).name(11:13)];
        
        
        %%%%%%%%  use heave estimates %%%%%%%%%%%%%%%%%%%%
        load([IMUflist(ii).name(1:end-4) '_ENU.mat']);
        
        faketime = linspace(min(ENU.time),max(ENU.time),length(ENU.time));
        u = interp1(GPS.time(1:length(GPS.u)),GPS.u,faketime);
        v = interp1(GPS.time(1:length(GPS.v)),GPS.v,faketime);
        z = ENU.xyz(:,3);
        u( isnan(u) ) = 0; % nans from interp
        v( isnan(v) ) = 0; % nans from interp
        trim = find( z == 0);
        u( trim ) = [];
        v( trim ) = [];
        z( trim ) = [];
        faketime( trim ) = [];
        z = RCfilter(z, RC, IMUsamplingrate);
        
        figure(21),
        plot(faketime,u,faketime,v,faketime,z)
        datetick
        legend('u','v','z')
        print('-dpng',[ [IMUflist(gi).name(1:end-4)] '_UVZ.png'])
             
        [ Hs, Tp, Dp, E, f, a1, b1, a2, b2, check ] = UVZwaves(u,v,z, IMUsamplingrate);
        
        % store results in SWIFT structure
        UVZresults(ii).sigwaveheight = Hs;
        UVZresults(ii).peakwaveperiod = Tp;
        UVZresults(ii).peakwavedirT = Dp;
        UVZresults(ii).wavespectra.energy = E;
        UVZresults(ii).wavespectra.freq = f;
        UVZresults(ii).wavespectra.a1 = a1;
        UVZresults(ii).wavespectra.b1 = b1;
        UVZresults(ii).wavespectra.a2 = a2;
        UVZresults(ii).wavespectra.b2 = b2;
        UVZresults(ii).wavespectra.check = check;
        UVZresults(ii).x = ENU.xyz(:,1); % raw wave displacements
        UVZresults(ii).y = ENU.xyz(:,2); % raw wave displacements
        UVZresults(ii).z = ENU.xyz(:,3); % raw wave displacements
        UVZresults(ii).time = median(ENU.time(:)); %datenum(IMU.clock((round(end/2))));
        UVZresults(ii).ID =  [IMUflist(ii).name(11:13)];
        
    end
    
save([IMUflist(end).name(1:13) '_' IMUflist(end).name(19:27) '_GPSandIMUresults'],'GPSandIMUresults');

if useAHRStoolbox
    save([IMUflist(end).name(1:13) '_' IMUflist(end).name(19:27) '_UVZresults_simple'],'UVZresults');
else
    save([IMUflist(end).name(1:13) '_' IMUflist(end).name(19:27) '_UVZresults_AHRS'],'UVZresults');
end

else
end


%% EMBEDDED RC FILTER function (high pass filter) %%

function a = RCfilter(b, RC, fs);

alpha = RC / (RC + 1./fs);
a = b;

for ui = 2:length(b)
    a(ui) = alpha * a(ui-1) + alpha * ( b(ui) - b(ui-1) );
end

end

