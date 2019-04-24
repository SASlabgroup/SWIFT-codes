% reprocess SWIFT v4 Signature results
% loop thru raw data for a given SWIFT deployment, then
% replace values in the SWIFT data structure of results
% (from onboard processing)
%
%
% J. Thomson, Sept 2017 (modified from AQH reprocessing)
%       7/2018, fix bug in the burst time stamp applied 
%       4/2019, apply altimeter results to trim profiles
%               and plot echograms

clear all; close all

tic

parentdir = pwd;
readraw = false; % reading the binaries doubles the run time
altimetertrim = true;
xcdrdepth = 0.2; % depth of transducer [m]

mincor = 50; % correlation cutoff, 50 recommended (max value recorded in air), 30 if single beam acq


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
            
            % read or load raw data
            if isempty(dir([filelist(fi).name(1:end-4) '.mat'])) | readraw,
                [burst avg ] = readSWIFTv4_SIG( filelist(fi).name );
            else
                load([filelist(fi).name(1:end-4) '.mat']),
            end
            
            % quality control HR velocity data
            exclude = burst.CorrelationData < mincor ;
            burst.VelocityData(exclude)  = NaN;
            
            % recalc dissipation
            z = xcdrdepth + burst.Blanking + burst.CellSize * [1:size(burst.VelocityData,2)];
            deltar = zeros(size(z));
            [tke , epsilon , residual, A, Aerror, N, Nerror] = dissipation(burst.VelocityData', z, size(burst.VelocityData,1), 0, deltar);
            %epsilon = epsilon./1024;
            
            % calculate mean vertical velocities
            HRwbar = -nanmean(burst.VelocityData);
            HRwvar = nanvar(burst.VelocityData);
            avgwbar = mean(avg.VelocityData(:,:,3));
            avgwvar = var(avg.VelocityData(:,:,3));
            
            % use altimeter dist, if present, to trim profiles
            profilez = xcdrdepth + avg.Blanking + avg.CellSize./2 + ( avg.CellSize * [1:size(avg.VelocityData,2)] );
            if isfield(avg,'AltimeterDistance') && altimetertrim, 
                maxz = median(avg.AltimeterDistance);
                trimbin = find( profilez > maxz, 1) - 1;
                if trimbin < 1, trimbin = 1; end
                avgwbar(trimbin:end) = NaN;
                avgwvar(trimbin:end) = NaN;
            else
                maxz = inf;
            end
            
            % match time to SWIFT structure and replace values
            time=datenum(filelist(fi).name(13:21))+datenum(0,0,0,str2num(filelist(fi).name(23:24)),(str2num(filelist(fi).name(26:27))-1)*12,0);            
            [tdiff tindex] = min(abs([SWIFT.time]-time));
            SWIFT(tindex).signature.HRprofile.wbar = HRwbar;
            SWIFT(tindex).signature.HRprofile.wvar = HRwvar;
            SWIFT(tindex).signature.HRprofile.tkedissipationrate_pp = epsilon;
            SWIFT(tindex).signature.profile.wbar = avgwbar;
            SWIFT(tindex).signature.profile.wvar = avgwvar;
            SWIFT(tindex).signature.profile.east(trimbin:end) = NaN;
            SWIFT(tindex).signature.profile.north(trimbin:end) = NaN;
            SWIFT(tindex).signature.profile.altimeter = maxz;
   
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
            
            figure(3), clf
            subplot(2,1,1)
            pcolor(burst.time,z,burst.AmplitudeData'),shading flat
            set(gca,'Ydir','reverse')
            colorbar
            drawnow, 
            datetick
            ylabel('z [m]')
            title([filelist(fi).name(1:end-4) '   backscatter'],'interpreter','none'),
            ax = axis;
            subplot(2,1,2)
            pcolor(avg.time,profilez,mean(avg.AmplitudeData,3)'), shading flat, hold on
            plot(avg.time,avg.AltimeterDistance,'k.'), 
            set(gca,'Ydir','reverse')
            colorbar
            drawnow, 
            datetick
            axis([ax(1) ax(2) min(profilez) max(profilez)])
            ylabel('z [m]')
            print('-dpng',[filelist(fi).name(1:end-4) '_backscatter.png'])
        else
        end
        
    end
    
    cd('../')
end

cd(parentdir)


save([ wd '_reprocessedSIG.mat'],'SWIFT')

toc