% reprocess SWIFT v4 Signature results
% loop thru raw data for a given SWIFT deployment, then
% replace values in the SWIFT data structure of results
% (from onboard processing)
%
%
% J. Thomson, Sept 2017 (modified from AQH reprocessing)
%       7/2018, fix bug in the burst time stamp applied
%       4/2019, apply altimeter results to trim profiles
%               and plot echograms, with vertical velocities
%       12/2019 add option for spectral dissipation,
%               with screening for too much rotational variance
%       Sep 2020 corrected bug in advective velocity applied to spectra
%       Nov 2021 clean up and add more plotting for burst, avg, and echo
%
clear all; close all

tic

parentdir = pwd;
readraw = true; % reading the binaries doubles the run time
makesmoothwHR = false; % make (and save) a smoothed, but not averaged w
plotflag = true;
altimetertrim = true;
xcdrdepth = 0.2; % depth of transducer [m]

mincor = 50; % correlation cutoff, 50 recommended (max value recorded in air), 30 if single beam acq
minamp = 60; % min amplitude (backscatter) for HR


%% load existing SWIFT structure created during concatSWIFT_offloadedDcard, replace only the new results
cd(parentdir);
wd = pwd;
wdi = find(wd == '/',1,'last');
wd = wd((wdi+1):length(wd));

load([wd '.mat'])

cd('SIG/Raw/')


%% loop thru raw data

dirlist = dir('20*');

for di = 1:length(dirlist),
    
    cd([dirlist(di).name])
    filelist = dir('*SIG*.dat');
    
    for fi=1:length(filelist),
        
        disp(['file ' num2str(fi) ' of ' num2str(length(filelist)) ' in ' dirlist(di).name ])
        
        if filelist(fi).bytes > 1e6%2e6,
            
            %% read or load raw data
            if isempty(dir([filelist(fi).name(1:end-4) '.mat'])) | readraw,
                [burst avg battery echo ] = readSWIFTv4_SIG( filelist(fi).name );
                disp('reading raw data')
            else
                load([filelist(fi).name(1:end-4) '.mat']),
                if ~isstruct('echo')
                    [burst avg battery echo ] = readSWIFTv4_SIG( filelist(fi).name );
                end
            end
            
            
            %% reprocess HR (burst) data
            
            z = xcdrdepth + burst.Blanking + burst.CellSize * [1:size(burst.VelocityData,2)];
            dt = (max(burst.time)-min(burst.time))./length(burst.time)*24*3600;
            fs = 1/dt;
            windowlength=64;
            
            % quality control burst (HR) velocity data
            clear wdespiked;
            wraw = burst.VelocityData;
            for HRbin=1:size(burst.VelocityData,2)
                wdespiked(:,HRbin) = filloutliers( wraw(:,HRbin), 'linear');
            end
            wclean = wdespiked;
            exclude = burst.CorrelationData < mincor ;
            wclean(exclude)  = NaN;
            exclude = burst.AmplitudeData < minamp ;
            wclean(exclude)  = NaN;
            if sum( exclude(:,1:3) ) > 500,
                outofwater = true;
            else
                outofwater = false;
            end
            
            % burst (HR) motion (in body reference frame, *not* corrected to earth frame)
            urot =(deg2rad(burst.AHRS_GyroX))'*z; % motion tangent to beam in body frame
            vrot =(deg2rad(burst.AHRS_GyroY))'*z; % motion tangent to beam in body frame
            dpdt = gradient(burst.Pressure,dt); % bobbling motion
            [bobbing f] = pwelch(detrend( dpdt), windowlength, [], [], fs);
            rescaleacc = -9.8/nanmean(burst.Accelerometer(:,3));
            [acczpsd f] = pwelch(detrend( burst.Accelerometer(:,3)*rescaleacc ), windowlength, [], [], fs);
                        
            % spectral dissipation of self-advected turbulence ( Tennekes '75 )
            for HRbin=1:size(burst.VelocityData,2),
                [wpsd f] = pwelch(detrend( wdespiked(:,HRbin) ), windowlength, [], [], fs);
                inertial = find(f>1);
                tkepsd = wpsd;
                compwpsd = mean( tkepsd(inertial) .* ( 2*3.14* f(inertial)).^(5/3) )./ 8;
                advect = ( var(urot(:,HRbin)) + var(vrot(:,HRbin)) + var(wdespiked(:,HRbin)) ).^.5; % body rotations AND self advection
                
                if advect>0 & compwpsd > 0
                    epsilon_spec(1,HRbin) = ( compwpsd .* advect.^(-2/3) ).^(3/2);
                else
                    epsilon_spec(1,HRbin) = NaN;
                end
                if plotflag & ~outofwater
                    if HRbin==1,
                        figure(1), clf
                        cmap = colormap;
                    end
                    cind = round(64 * HRbin/length(z));
                    loglog(f,wpsd,'color',cmap(cind,:)), hold on
                    if HRbin==length(z),
                        loglog(f,bobbing,'k')
                        loglog(f,acczpsd.*f.^-2,'k:')
                        loglog([1 3],1e-1*[1 3].^(-5/3),'--','color',[.7 .7 .7],'linewidth',3)
                        xlabel('Frequency [Hz]')
                        ylabel('TKE [m^2/s^2/Hz]')
                        title('Signature HR Spectra at each range bin, with buoy motion (black)')
                        cb=colorbar('peer',gca,'EastOutside','YTickLabel',linspace(min(z),max(z),5),'Ytick',[0:.25:1],'ydir','reverse');
                        cb.Label.String = 'z [m]';
                        print('-dpng',[filelist(fi).name(1:end-4) '_burstHRspectra.png'])
                        
                    end
                end
            end
            
            % structure function dissipation
            deltar = zeros(size(z));
            figure(2), clf
            [tke , epsilon , residual, A, Aerror, N, Nerror] = dissipation(wclean', z, size(wclean,1), 1, deltar);
            print('-dpng',[filelist(fi).name(1:end-4) '_burstHRstrfcn.png'])
            
            % calculate mean vertical velocities, not positive is away from xcdr (which is negative in earth frame)
            HRwbar = -nanmean(burst.VelocityData);
            HRwvar = nanvar(burst.VelocityData);
            
            % make a smoothed version of vertical velocities within the burst (for display)
            if makesmoothwHR
                smoothpts = 256;  % should be at least 4 x wave period
                tstep = 32;
                zstep = 8;
                clear wHR
                for wi=1:length(z),
                    wHR(:,wi) = smooth( -burst.VelocityData(:,wi),smoothpts);
                end
                wHR = wHR(1:tstep:end,:);
                wHR = wHR(:,1:zstep:end);
                wHR(1,:) = NaN;
            else
            end
            
            % plot burst (HR) results
            if plotflag & ~outofwater
                
                figure(3), clf
                
                subplot(1,4,1)
                errorbar(z ,nanmean(burst.AmplitudeData), nanstd(burst.AmplitudeData))%,'linewidth','1.5')
                set(gca,'CameraUpVector',[-6 0 0])
                ylabel('Amp [-]')
                xlabel('z [m]')
                grid
                
                subplot(1,4,2)
                errorbar(z ,nanmean(burst.CorrelationData), nanstd(burst.CorrelationData))%,'linewidth','1.5')
                set(gca,'CameraUpVector',[-6 0 0])
                ylabel('Cor [%]')
                grid
                
                subplot(1,4,3)
                errorbar(z ,nanmean(burst.VelocityData), nanstd(burst.VelocityData))%,'linewidth','1.5')
                set(gca,'CameraUpVector',[-6 0 0])
                ylabel('w [m/s]')
                grid
                
                subplot(1,4,4)
                semilogx(epsilon,z,epsilon_spec,z),
                set(gca,'ydir','reverse')%'YLim',[0 3])
                ylabel('z [m]')
                xlabel('\epsilon [W/Kg]')
                set(gca,'XAxisLocation','top')
                legend('str fcn','spectral')
                grid
                
                print('-dpng',[filelist(fi).name(1:end-4) '_burstHRprofiles.png'])
                
            end
            
            %% reprocess avg data
            
            avg.z = xcdrdepth + avg.Blanking + avg.CellSize.* [1:size([avg.AmplitudeData],2)];

            % vertical velocities
            avgwbar = mean(avg.VelocityData(:,:,3));  % these are already ENU
            avgwvar = var(avg.VelocityData(:,:,3));
            
            % use altimeter dist, if present, to trim profiles
            if isfield(avg,'AltimeterDistance') && altimetertrim,
                maxz = median(avg.AltimeterDistance);
                trimbin = find( avg.z > maxz, 1) - 1;
                if trimbin < 1, trimbin = 1; end
                avgwbar(trimbin:end) = NaN;
                avgwvar(trimbin:end) = NaN;
            else
                maxz = inf;
                trimbin = length(avg.z);
            end
            
            figure(4), clf
            subplot(1,4,1)
            plot( squeeze( nanmean(avg.AmplitudeData) ), avg.z ,'linewidth',1.5), hold on
            plot(0, avg.AltimeterDistance,'kx')            
            xlabel('Amp [-]')
            ylabel('z [m]')
            set(gca,'ydir','reverse')
            grid
            
            subplot(1,4,2)
            plot( squeeze( nanmean(avg.CorrelationData) ), avg.z ,'linewidth',1.5), hold on
            plot(0, avg.AltimeterDistance,'kx')            
            xlabel('Corr [%]')
            ylabel('z [m]')
            set(gca,'ydir','reverse')
            grid
            
            
            subplot(1,4,3)
            plot( squeeze( nanmean(avg.VelocityData(:,:,1:2)) ), avg.z ,'linewidth',1.5), hold on
            plot(0, avg.AltimeterDistance,'kx')            
            xlabel('u,v [m/s]')
            ylabel('z [m]')
            set(gca,'ydir','reverse')
            grid
            
            subplot(1,4,4)
            plot( squeeze( nanmean(avg.VelocityData(:,:,3:4)) ), avg.z ,'linewidth',1.5), hold on
            plot(0, avg.AltimeterDistance,'kx')            
            xlabel('w [m/s]')
            ylabel('z [m]')
            set(gca,'ydir','reverse')
            grid
            
            print('-dpng',[filelist(fi).name(1:end-4) '_avgprofiles.png'])
            
            
            
            %% echo sounder processing
            
            if ~isempty(echo)
                echo.z = xcdrdepth + echo.Blanking + echo.CellSize .* [1:size([echo.EchoSounder],2)];
                rescaleacc = -9.8/nanmean(echo.Accelerometer(:,3));
            end

            if ~isempty(echo) & plotflag
                
                figure(5), clf
                
                subplot(4,1,1)
                plot(echo.time,rescaleacc.*echo.Accelerometer)
                datetick
                legend('a_x','a_y','a_z')
                ylabel('Accel [m^2/s]')
                %title([filelist(fi).name(1:end-4) '_echosounder'],'interpreter','none'),
                
                subplot(4,1,2)
                plot(echo.time,echo.AHRS_GyroX)
                hold on
                plot(echo.time,echo.AHRS_GyroY,'.')
                set(gca,'YLim',[-50 50])
                legend('gyro x','gyro y')
                datetick
                ylabel('[deg/s]')
                
                subplot(2,1,2),
                pcolor(echo.time,echo.z,echo.EchoSounder'), shading flat
                colormap bone
                datetick
                set(gca,'YDir','reverse')
                ylabel('Depth [m]')
                print('-dpng',[filelist(fi).name(1:end-4) '_echosounder.png'])
                
            end
            
            
            %% match time to SWIFT structure and replace values
            
            time=datenum(filelist(fi).name(13:21))+datenum(0,0,0,str2num(filelist(fi).name(23:24)),(str2num(filelist(fi).name(26:27))-1)*12,0);
            [tdiff tindex] = min(abs([SWIFT.time]-time));
            bad(tindex) = false;
            
            if ~isempty(tdiff) && tdiff < 1/(24*5) && ~outofwater,
                SWIFT(tindex).signature.HRprofile.wbar = HRwbar;
                SWIFT(tindex).signature.HRprofile.wvar = HRwvar;
                SWIFT(tindex).signature.HRprofile.z = z;
                SWIFT(tindex).signature.HRprofile.tkedissipationrate_onboard = SWIFT(tindex).signature.HRprofile.tkedissipationrate;
                SWIFT(tindex).signature.HRprofile.tkedissipationrate_strfcn = epsilon;
                SWIFT(tindex).signature.HRprofile.tkedissipationrate_spectral = epsilon_spec;
                SWIFT(tindex).signature.profile.wbar = avgwbar;
                SWIFT(tindex).signature.profile.wvar = avgwvar;
                SWIFT(tindex).signature.profile.east(trimbin:end) = NaN;
                SWIFT(tindex).signature.profile.north(trimbin:end) = NaN;
                SWIFT(tindex).signature.profile.altimeter = maxz;
            elseif ~isempty(tdiff) && tdiff < 1/(24*5) && outofwater,
                SWIFT(tindex) = [];
                bad(tindex) = true;
            else
            end
            
            
            %% more plotting
            
            if plotflag & ~isempty(SWIFT)  && tdiff < 1/(24*5) && ~outofwater && length(SWIFT)>=tindex ,
                
%                 figure(8), clf % vertical velocities
%                 plot(HRwbar,SWIFT(tindex).signature.HRprofile.z,'b-'), hold on
%                 plot(HRwbar+sqrt(HRwvar),SWIFT(tindex).signature.HRprofile.z,'b:'),
%                 plot(HRwbar-sqrt(HRwvar),SWIFT(tindex).signature.HRprofile.z,'b:'),
%                 plot(avgwbar,SWIFT(tindex).signature.profile.z,'g-')
%                 plot(avgwbar+sqrt(avgwvar),SWIFT(tindex).signature.profile.z,'g:'),
%                 plot(avgwbar-sqrt(avgwvar),SWIFT(tindex).signature.profile.z,'g:'),
%                 plot([0 0],[0 20],'k--')
%                 xlabel('w [m/s]'),ylabel('z [m]')
%                 set(gca,'Ydir','reverse')
%                 drawnow,
%                 print('-dpng',[filelist(fi).name(1:end-4) '_verticalvelocities.png'])
                
                figure(9), clf
                semilogx(SWIFT(tindex).signature.HRprofile.tkedissipationrate_onboard,SWIFT(tindex).signature.HRprofile.z,'k-'), hold on
                semilogx(epsilon,z,'rx'), hold on
                semilogx(epsilon_spec,z,'bo'), hold on
                legend('onboard','str func','spectral','Location','NorthEastOutside')
                xlabel('\epsilon [W/Kg]'),ylabel('z [m]')
                set(gca,'Ydir','reverse')
                drawnow,
                print('-dpng',[filelist(fi).name(1:end-4) '_disspation.png'])
                
                if makesmoothwHR
                    figure(10), clf
                    burstsec = (burst.time - min(burst.time))*24*3600;
                    subplot(2,1,1)
                    pcolor(burstsec,z,burst.AmplitudeData'),shading flat
                    hold on, quiver(burstsec([1:tstep:end])'*ones(1,size(wHR,2)), ones(size(wHR,1),1)*z([1:zstep:end]),...
                        zeros(size(wHR)), -wHR,0,'k','linewidth',2)
                    set(gca,'Ydir','reverse')
                    quiver(530,.5,0,.1,0,'k','linewidth',2)
                    text(540,.55,'10 cm/s')
                    axis([0 600 0 max(z)])
                    colorbar
                    drawnow,
                    ylabel('z [m]'), xlabel('t [s]')
                    title([filelist(fi).name(1:end-4) '   HR backscatter'],'interpreter','none'),
                    
                    subplot(2,1,2)
                    avgsec = ( avg.time - min(avg.time) ) * 24 * 3600;
                    pcolor(avgsec,profilez,mean(avg.AmplitudeData,3)'), shading flat, hold on
                    if isfield(avg,'AltimeterDistance')
                        plot(avgsec,avg.AltimeterDistance,'k.'),
                    end
                    set(gca,'Ydir','reverse')
                    colorbar
                    drawnow,
                    axis([0 600 0 max(profilez)]);
                    ylabel('z [m]'), xlabel('t [s]')
                    title([filelist(fi).name(1:end-4) '   BB backscatter'],'interpreter','none'),
                    
                    print('-dpng',[filelist(fi).name(1:end-4) '_backscatter.png'])
                    
                    HRbackscatter = burst.AmplitudeData;
                    save([filelist(fi).name(1:end-4) '_smoothwHR'],'wHR','HRbackscatter','burstsec','tstep','zstep','z')
                else
                end
                   
                
            else
            end
            
        else
        end
        
    end
    
    cd('../')
end

cd(parentdir)


save([ wd '_reprocessedSIG.mat'],'SWIFT')

toc