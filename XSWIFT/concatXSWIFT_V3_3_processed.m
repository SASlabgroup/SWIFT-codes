% aggregate, concat, and read all onboard processed X-SWIFT data (once offloaded via serial cable or SD card) 
% run this in a dedicated directory for the results
% 
% (this fills in the results not sent by Iridium when running more than 1x6 duty cycle) 
%
% J. Thomson, 4/2014
%               9/2015 rework for v3.3, but currently only pulls one ACS
%               file (out of three), because they are not uniquely named. 

clear all, close all, clc

plotflag = 1;  % binary flag for plotting

dirpath = './'%'~/Desktop/'; '~/Dropbox/SWIFT_v3.x/TestData/';
sourcedir = ''%'SWIFT11_02Oct2014_SDcard';%'SWIFT15_Test_19Jun2014'%'SWIFTdata_27Apr2014' %'SWIFT15_LakeWA_Stereo_09May2014';

% uncomment and revise a line below to file glob processed files (per instrument) 
% and put these all in one directory (skip if already in one directory)

eval(['!cp -r ' dirpath sourcedir '/*/Processed/*/*PRC*  . ' ]) % use for single
%eval(['!cp -r ' dirpath sourcedir '/*/*/Processed/*/*PRC*  . ' ]) % use for multiple SWIFTs


%% use directory listing to find all files,
% using the aquadopp files as reference to find each burst and the other sensors

%AQnames = dir('*AQ*_PRC*');
AQnames = dir('*IMU*_PRC*');

for ai = 1:length(AQnames),
   
    disp([ num2str(ai) ' of ' num2str(length(AQnames)) ])
    
ID = AQnames(ai).name(1:7);
date = AQnames(ai).name(13:21);
hour = AQnames(ai).name(23:24);
burst = AQnames(ai).name(26:27);

%AQtype = AQnames(ai).name(11);

payloadtype = '6'; % v3.3 

fid = fopen('payload','wb');
fwrite(fid,payloadtype,'uint8');
fclose(fid);

%% concatenate files (to make fake SBD telemetry files)

%AQfile = AQnames(ai).name;
AQfile = [];
%PB2file = [ID '_PB2_' date '_' hour '_' burst '_PRC.dat'];
PB2file = [];
%IMUfile = [ID '_IMU_' date '_' hour '_' burst '_PRC.dat'];
IMUfile = AQnames(ai).name;
%ACSfile = [ID '_ACS_' date '_' hour '_' burst '_PRC.dat'];
ACSfile = [];
%outputfile = [ID '_TX_' date '_' hour  burst(2) '000.sbd']; % name concat file same as in the telemetry directory on the SD card
outputfile = ['buoy-SWIFT_' ID(6:7) '-' date '_' hour  burst(2) '000.sbd']; % name concat file same as if pulled from swiftserver


eval(['!cat payload ' AQfile ' ' PB2file ' ' IMUfile ' ' ACSfile ' > ' outputfile])
    %!cat SWIFT12_AQH_27Apr2014_09_03_PRC.dat SWIFT12_PB2_27Apr2014_09_03_PRC.dat SWIFT12_IMU_27Apr2014_09_03_PRC.dat 

end % close


%% read files individually (later) with readSWIFTv3_1_SBD
% or call compileSWIFTv3_1_SBD to read everything in the directory and save as one structure

run('compileSWIFT_V3_3_telemetry.m')

%% clean up, move burst files to new directory

mkdir ConcatProcessed
eval(['!mv *.dat ConcatProcessed/'])
eval(['!mv *.sbd ConcatProcessed/'])
eval(['!mv buoy*.mat ConcatProcessed/'])



%% OLD PLOTTING STUFF... now in compile script (above)

% %oneSWIFT = readSWIFTv3_1_SBD( outputfile , 0);
% 
% oneSWIFT.date = date;
% oneSWIFT.hour = hour;
% oneSWIFT.ID = ID;
% 
% if oneSWIFT.time ~= 0  & oneSWIFT.sigwaveheight ~= 9999, 
% 
% SWIFT(ai) = oneSWIFT;
% 
% if plotflag == 1, 
%     
%    figure(1), n = 5; 
%    
%        ax(1) = subplot(n,1,1); 
%        plot(oneSWIFT.time,oneSWIFT.windspd,'x'), hold on
%        datetick
%        ylabel('wind spd [m/s]')
% 
%        ax(2) = subplot(n,1,2); 
%        plot(oneSWIFT.time,oneSWIFT.winddirT,'x'), hold on
%        datetick
%        ylabel('wind dir [^\circ]')
%        set(gca,'Ylim',[0 360])
% 
% 
%        ax(3) = subplot(n,1,3); 
%        plot(oneSWIFT.time,oneSWIFT.sigwaveheight,'x'), hold on
%        datetick
%        ylabel('wave height [m]')
% 
%        ax(4) = subplot(n,1,4); 
%        plot(oneSWIFT.time,oneSWIFT.peakwaveperiod,'x'), hold on
%        datetick
%        ylabel('wave period [s]')
% 
%        ax(5) = subplot(n,1,5); 
%        plot(oneSWIFT.time,oneSWIFT.peakwavedirT,'x'), hold on
%        datetick
%        ylabel('wave dir [^\circ T]')
%        set(gca,'Ylim',[0 360])
%        
%        linkaxes(ax,'x')
%    
%    figure(2), n = 3; 
%    
%        tax(1) = subplot(n,1,1); 
%        plot(oneSWIFT.time,oneSWIFT.airtemp,'x'), hold on
%        datetick
%        ylabel('air temp [C]')
% 
%        tax(2) = subplot(n,1,2); 
%        plot(oneSWIFT.time,oneSWIFT.watertemp,'x'), hold on
%        datetick
%        ylabel('wwater temp [C]')
% 
%        tax(3) = subplot(n,1,3); 
%        plot(oneSWIFT.time,oneSWIFT.salinity,'x'), hold on
%        datetick
%        ylabel('salinity [PSU]')
% 
%        linkaxes(tax,'x')
%        
%     figure(3),
%     
%         plot(oneSWIFT.uplooking.tkedissipationrate,oneSWIFT.uplooking.z), hold on
%         set(gca,'YDir','reverse')
%         ylabel('z [m]')
%         xlabel('\epsilon [W/kg]')
%         
%     figure(4),
%     
%         loglog(oneSWIFT.wavespectra.freq,oneSWIFT.wavespectra.energy), hold on
%         xlabel('freq [Hz]')
%         ylabel('Energy [m^2/Hz')
%         
%     figure(5), 
%         
%         plot(oneSWIFT.downlooking.velocityprofile,oneSWIFT.downlooking.z), hold on
%         set(gca,'YDir','reverse')
%         ylabel('z [m]')
%         xlabel('velocity [m/s]')
%     
%     
% else 
% end % close plot statement
% 
% else
% end  % close valid data statement (based on Hsig)
% 
% end
% 
% %% save and post-process
% % post-processing could include calculation of drift velocity (based on
% % positions)
% save([ sourcedir '.mat'], 'SWIFT')
% 
