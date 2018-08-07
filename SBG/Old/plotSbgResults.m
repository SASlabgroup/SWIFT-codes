% Batch Matlab read-in of SWIFT v4.0 SBG data, as output from python
% readBinaryFromFile_Batch.py module
%
% M. Schwendeman, 12/2016

fileDirectory = '/Users/mike/Dropbox/SWIFT_v4.x/Test Data/LakeWA_Test_14Dec2016/SWIFTv4_14Dec2016/SBG/Raw/20161214';
fileNames = dir([fileDirectory,'/*_ASCII.txt']);
for i = 1:length(fileNames)
    load([fileDirectory '/' fileNames(i).name(1:(end-10)) '.mat'],'sbgData')
    
    %% Plot time series
    f1 = figure(1); clf(f1);
    f1.Position = [1 1 8 16];
    f1.PaperPosition = f1.Position;

    subplot(4,2,3)
    plot(sbgData.ShipMotion.time_stamp,sbgData.ShipMotion.vel_x,'.-')
    set(gca,'ylim',[-0.2 0.2])
    subplot(4,2,5)
    plot(sbgData.ShipMotion.time_stamp,sbgData.ShipMotion.vel_y,'.-')
    set(gca,'ylim',[-0.2 0.2])
    subplot(4,2,7)
    plot(sbgData.ShipMotion.time_stamp,sbgData.ShipMotion.heave,'.-')
    set(gca,'ylim',[-0.5 0.5])
    subplot(4,2,2)
    plot(sbgData.EkfNav.longitude,sbgData.EkfNav.latitude,'.')
    hold('on')
    plot(sbgData.GpsPos.long,sbgData.GpsPos.lat,'.')
    hold('off')
    set(gca,'xlim',[-122.4 -122.2],'ylim',[47.5 47.7])
    subplot(4,2,4)
    plot(sbgData.EkfNav.time_stamp,sbgData.EkfNav.velocity_e,'.-')
    set(gca,'ylim',[-1 1])
    subplot(4,2,6)
    plot(sbgData.EkfNav.time_stamp,sbgData.EkfNav.velocity_n,'.-')
    set(gca,'ylim',[-1 1])
    subplot(4,2,8)
    plot(sbgData.EkfNav.time_stamp,sbgData.EkfNav.altitude,'.-')
    set(gca,'ylim',[-0.5 0.5])
    pause
end