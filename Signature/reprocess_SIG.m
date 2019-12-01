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

clear all; close all

tic

parentdir = pwd;
readraw = false; % reading the binaries doubles the run time
makesmoothwHR = true; % make (and save a smoothed, but not averaged w)
plotflag = true; 
altimetertrim = false;
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
        
       disp(['file ' num2str(fi) ' of ' num2str(length(filelist)) ])
        
        if filelist(fi).bytes > 1e6%2e6,
            
            %% read or load raw data
            if isempty(dir([filelist(fi).name(1:end-4) '.mat'])) | readraw,
                [burst avg battery echo ] = readSWIFTv4_SIG( filelist(fi).name );
            else
                load([filelist(fi).name(1:end-4) '.mat']),
            end
            
            %% quality control HR velocity data
            exclude = burst.CorrelationData < mincor ;
            burst.VelocityData(exclude)  = NaN;
            exclude = burst.AmplitudeData < minamp ;
            burst.VelocityData(exclude)  = NaN;
            if sum( exclude(:) ) > 100, 
                outofwater = true;
            else
                outofwater = false;
            end

            
            %% recalc dissipation
            z = xcdrdepth + burst.Blanking + burst.CellSize * [1:size(burst.VelocityData,2)];
            deltar = zeros(size(z));
            [tke , epsilon , residual, A, Aerror, N, Nerror] = dissipation(burst.VelocityData', z, size(burst.VelocityData,1), 0, deltar);
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
            SWIFT(tindex).signature.HRprofile.tkedissipationrate_pp = epsilon;
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
   
            if plotflag & ~isempty(SWIFT),
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
            semilogx(SWIFT(tindex).signature.HRprofile.tkedissipationrate,SWIFT(tindex).signature.HRprofile.z,'k-'), hold on
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
            hold on, quiver(burstsec([1:tstep:end])'*ones(1,size(wHR,2)), ones(size(wHR,1),1)*z([1:zstep:end]), zeros(size(wHR)), -wHR,0,'k','linewidth',2)
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
                echo.z = echo.Blanking + echo.CellSize .* [1:length([echo.EchoSounder])];
                pcolor(echo.time,echo.z,echo.EchoSounder'), shading flat
                datetick
                set(gca,'YDir','reverse')
                ylabel('Depth [m]')
                title([filelist(fi).name(1:end-4) '_echosounder'],'interpreter','none'),
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