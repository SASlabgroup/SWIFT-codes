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
%
clear all; close all

tic

parentdir = pwd;
readraw = false; % reading the binaries doubles the run time
makesmoothwHR = true; % make (and save) a smoothed, but not averaged w
plotflag = true;
altimetertrim = true;
spectraldissipation = false;
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
    filelist = dir('*.dat');
    
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
            
            %% quality control HR velocity data
            wraw = burst.VelocityData;
            exclude = burst.CorrelationData < mincor ;
            burst.VelocityData(exclude)  = NaN;
            exclude = burst.AmplitudeData < minamp ;
            burst.VelocityData(exclude)  = NaN;
            if sum( exclude(:,1:3) ) > 500,
                outofwater = true;
            else
                outofwater = false;
            end
            
            %% motion
            z = xcdrdepth + burst.Blanking + burst.CellSize * [1:size(burst.VelocityData,2)];
            wxrot =(deg2rad(burst.AHRS_GyroX))'*z; % no projection, just scalar tangent velocity
            wxrotz = (deg2rad(burst.AHRS_GyroX).*sind(burst.Pitch))'*z; % projected onto vertical
            wyrot =(deg2rad(burst.AHRS_GyroY))'*z;  % no projection, just tangent velocity
            wyrotz = (deg2rad(burst.AHRS_GyroY).*sind(burst.Roll))'*z; % projected onto vertical
            
            %% recalc dissipation
            clear epsilon
            if spectraldissipation, % use method from Tennekes '75 (and Zippel 2018)
                windowlength=64;
                fs = length( burst.VelocityData(:,1) )./ ( range(burst.time)*24*3000 );
                
                parfor HRbin=1:size(burst.VelocityData,2),
                    wraw(:,HRbin) = filloutliers(wraw(:,HRbin), 'linear');
                    [wpsd f] = pwelch(detrend( wraw(:,HRbin) ),windowlength, [], [], fs);
                    [wxpsd f] = pwelch(detrend( wxrotz(:,HRbin) ),windowlength, [], [], fs);
                    [wypsd f] = pwelch(detrend( wxrotz(:,HRbin) ),windowlength, [], [], fs);
                    inertial = find(f>1);
                    tkepsd = wpsd - wxpsd - wypsd; % option to remove motion variance from inertial subrange
                    compwpsd = mean( tkepsd(inertial) .* ( 2*3.14* f(inertial)).^(5/3) )./ 8; 
                    %advect = ( var(wraw(:,HRbin)) - var(wxrotz(:,HRbin)) - var(wyrotz(:,HRbin)) ).^.5;
                    advect = std(wraw(:,HRbin)); %most consistent with Tennekes '75
                    %advect = mean((mean(avg.VelocityData(:,1:2,1)).^2 + mean(avg.VelocityData(:,1:2,2)).^2).^.5); % horizontal advection from BB profiles
                    %advect = 0.1; % constant
                    
                    if advect>0 & compwpsd > 0
                        epsilon(HRbin) = ( compwpsd .* advect.^(-2/3) ).^(3/2);
                    else
                        epsilon(HRbin) = NaN;
                    end
                end
                epsilon = epsilon';
                
            else
                deltar = z*std(cosd(burst.Pitch)); %zeros(size(z));
                [tke , epsilon , residual, A, Aerror, N, Nerror] = dissipation(burst.VelocityData', z, size(burst.VelocityData,1), 0, deltar);
            end
            %epsilon = epsilon./1024;
            
            %% calculate mean vertical velocities
            HRwbar = -nanmean(burst.VelocityData); % these are beam velocities, so positive is away from xcdr (which is negative in earth frame)
            HRwvar = nanvar(burst.VelocityData);
            avgwbar = mean(avg.VelocityData(:,:,3));  % these are already ENU
            avgwvar = var(avg.VelocityData(:,:,3));
            
            %% make a smoothed version of vertical velocities within the burst (for display)
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
            
            
            %% use altimeter dist, if present, to trim profiles
            profilez = xcdrdepth + avg.Blanking + avg.CellSize./2 + ( avg.CellSize * [1:size(avg.VelocityData,2)] );
            if isfield(avg,'AltimeterDistance') && altimetertrim,
                maxz = median(avg.AltimeterDistance);
                trimbin = find( profilez > maxz, 1) - 1;
                if trimbin < 1, trimbin = 1; end
                avgwbar(trimbin:end) = NaN;
                avgwvar(trimbin:end) = NaN;
            else
                maxz = inf;
                trimbin = length(profilez);
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
                SWIFT(tindex).signature.HRprofile.tkedissipationrate = epsilon;
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
            
            
            if plotflag & ~isempty(SWIFT)  && tdiff < 1/(24*5) && ~outofwater && length(SWIFT)>=tindex ,
                figure(1), clf
                plot(HRwbar,SWIFT(tindex).signature.HRprofile.z,'b-'), hold on
                plot(HRwbar+sqrt(HRwvar),SWIFT(tindex).signature.HRprofile.z,'b:'),
                plot(HRwbar-sqrt(HRwvar),SWIFT(tindex).signature.HRprofile.z,'b:'),
                plot(avgwbar,SWIFT(tindex).signature.profile.z,'g-')
                plot(avgwbar+sqrt(avgwvar),SWIFT(tindex).signature.profile.z,'g:'),
                plot(avgwbar-sqrt(avgwvar),SWIFT(tindex).signature.profile.z,'g:'),
                plot([0 0],[0 20],'k--')
                xlabel('w [m/s]'),ylabel('z [m]')
                set(gca,'Ydir','reverse')
                drawnow,
                print('-dpng',[filelist(fi).name(1:end-4) '_verticalvelocity.png'])
                
                figure(2), clf
                semilogx(SWIFT(tindex).signature.HRprofile.tkedissipationrate_onboard,SWIFT(tindex).signature.HRprofile.z,'k-'), hold on
                semilogx(epsilon,z,'rx'), hold on
                legend('onboard','post-processed','Location','NorthEastOutside')
                xlabel('\epsilon [W/Kg]'),ylabel('z [m]')
                set(gca,'Ydir','reverse')
                drawnow,
                print('-dpng',[filelist(fi).name(1:end-4) '_disspation.png'])
                
                if makesmoothwHR
                    figure(3), clf
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
                
                if ~isempty(echo)
                    figure(4), clf
                    
                    subplot(4,1,1)
                    plot(echo.time,echo.Accelerometer)
                    datetick
                    legend('a_x','a_y','a_z')
                    ylabel('Accel [cm^2/s]')
                    title([filelist(fi).name(1:end-4) '_echosounder'],'interpreter','none'),
                    
                    subplot(4,1,2)
                    plot(echo.time,echo.Pitch)
                    hold on
                    plot(echo.time,abs(echo.Roll)-180,'.')
                    set(gca,'YLim',[-20 20])
                    set(gca,'YLim',[-30 30])
                    legend('pitch','|roll|-180')
                    datetick
                    ylabel('[deg]')
                    
                    subplot(2,1,2),
                    echo.z = xcdrdepth + echo.Blanking + echo.CellSize .* [1:size([echo.EchoSounder],2)];
                    pcolor(echo.time,echo.z,echo.EchoSounder'), shading flat
                    colormap bone
                    datetick
                    set(gca,'YDir','reverse')
                    ylabel('Depth [m]')
                    print('-dpng',[filelist(fi).name(1:end-4) '_echosounder.png'])
                    
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