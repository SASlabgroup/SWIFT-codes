% reprocess SWIFT v4 Signature results
% loop thru raw data for a given SWIFT deployment, then
% replace values in the SWIFT data structure of results
% (from onboard processing)
%
%
% J. Thomson, Sept 2017
%   modified from AQH reprocessing
% S. Kastner, c. 2018
%   include raw data in SWIFT structures


clear all; close all
parentdir = pwd;
readraw = false;

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
        
        if filelist(fi).bytes > 1e6,
            
%             read or load raw data
            if isempty(dir([filelist(fi).name(1:end-4) '.mat'])) | readraw,
                [burst avg ] = readSWIFTv4_SIG( filelist(fi).name );
            else
                load([filelist(fi).name(1:end-4) '.mat']),
            end

            % force read of raw data 
%             [burst avg ] = readSWIFTv4_SIG( filelist(fi).name );
            
            
            % quality control HR velocity data
            exclude = burst.CorrelationData < mincor ;
            burst.VelocityData(exclude)  = NaN;
            
            % recalc dissipation
            z = 0.2 + burst.Blanking + burst.CellSize * [1:size(burst.VelocityData,2)];
            deltar = zeros(size(z));
            [tke , epsilon , residual, A, Aerror, N, Nerror] = dissipation(burst.VelocityData', z, size(burst.VelocityData,1), 0, deltar);
            %epsilon = epsilon./1024;
            warning('off','last')
            
            % calculate mean vertical velocities
            HRwbar = -nanmean(burst.VelocityData);
            HRwvar = nanvar(burst.VelocityData);
            avgwbar = mean(avg.VelocityData(:,:,3));
            avgwvar = var(avg.VelocityData(:,:,3));
            
          
            
            
            % match time to SWIFT structure and replace values
            
            % signature time comes from filename (using starttime)
            time=datenum(filelist(fi).name(13:21))+datenum(0,0,0,str2num(filelist(fi).name(23:24)),(str2num(filelist(fi).name(26:27))-1)*12,0);
%             time = datenum(filelist(fi).name(13:21)) + str2num(filelist(fi).name(23:24))./24 + str2num(filelist(fi).name(26:27))./(24*6);
            [tdiff tindex(fi)] = min(abs([SWIFT.time]-time));
            t_threshold=datenum(0,0,0,0,6,0);
            
            if tdiff<t_threshold;
                
                %store data, including raw time series
                SWIFT(tindex(fi)).signature.HRprofile.wbar = HRwbar;
                SWIFT(tindex(fi)).signature.HRprofile.wvar = HRwvar;
                SWIFT(tindex(fi)).signature.HRprofile.tkedissipationrate_pp = epsilon;
                SWIFT(tindex(fi)).signature.HRprofile.rawVel=burst.VelocityData;
                SWIFT(tindex(fi)).signature.HRprofile.rawCor=burst.CorrelationData;
                SWIFT(tindex(fi)).signature.HRprofile.rawAmp=burst.AmplitudeData;
                SWIFT(tindex(fi)).signature.HRprofile.time_raw=burst.time;


                SWIFT(tindex(fi)).rawSIGtime=avg.time;
                SWIFT(tindex(fi)).signature.profile.wbar = avgwbar;
                SWIFT(tindex(fi)).signature.profile.wvar = avgwvar;
                SWIFT(tindex(fi)).signature.profile.time_raw=avg.time;
                SWIFT(tindex(fi)).signature.profile.east_raw=avg.VelocityData(:,:,1);
                SWIFT(tindex(fi)).signature.profile.north_raw=avg.VelocityData(:,:,2);
                SWIFT(tindex(fi)).signature.profile.up_raw=avg.VelocityData(:,:,3);
                SWIFT(tindex(fi)).signature.profile.rawAmp=avg.AmplitudeData;
                SWIFT(tindex(fi)).signature.profile.depth_raw=avg.AltimeterDistance;
                SWIFT(tindex(fi)).signature.profile.altimeter_quality=avg.AltimeterQuality;
                SWIFT(tindex(fi)).signature.profile.gyro_raw = avg.AHRS_GyroZ;
                
                % velocity reference
                SWIFT_highres(tindex(fi)).signature.profile.velreference = 'none';


            end
%             figure(1), clf 
%             plot(HRwbar,SWIFT(tindex).signature.HRprofile.z,'b-'), hold on
%             plot(HRwbar+sqrt(HRwvar),SWIFT(tindex).signature.HRprofile.z,'b:'),
%             plot(HRwbar-sqrt(HRwvar),SWIFT(tindex).signature.HRprofile.z,'b:'),
%             plot(avgwbar,SWIFT(tindex).signature.profile.z,'g-')
%             plot(avgwbar+sqrt(avgwvar),SWIFT(tindex).signature.profile.z,'g:'),
%             plot(avgwbar-sqrt(avgwvar),SWIFT(tindex).signature.profile.z,'g:'), 
%             plot([0 0],[0 20],'k--')
%             xlabel('w [m/s]'),ylabel('z [m]')
%             set(gca,'Ydir','reverse')
%             drawnow, 
%             print('-dpng',[filelist(fi).name(1:end-4) '_verticalvelocity.png'])
%             
%             figure(2), clf 
%             semilogx(SWIFT(tindex).signature.HRprofile.tkedissipationrate,SWIFT(tindex).signature.HRprofile.z,'k-'), hold on
%             semilogx(epsilon,z,'rx'), hold on
%             xlabel('\epsilon [W/Kg]'),ylabel('z [m]')
%             legend('onboard','post-processed','Location','NorthEastOutside')
%             set(gca,'Ydir','reverse')
%             drawnow, 
%             print('-dpng',[filelist(fi).name(1:end-4) '_disspation.png'])
            
        else
        end
        
    end
    clear tindex
    cd('../')
end

cd(parentdir)


save([ wd '_reprocessed.mat'],'SWIFT','-v7.3')

