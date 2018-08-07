% script for near-realtime display of SBG heave data (SWIFT v4)
% recorded as binary files using Autopoll and ethernet bridge
%
% J. Thomson, 12/2017

filename = 'SWIFT24_AutoPollBinaryLog_Test3.txt'; % use full path, or run in local directory
lastbytes = 1e5; % only read this many most recent bytes from SBG binary, 1e5 is ~ 40 seconds
samplerate = 5; % Hz
updaterate = 1; % Hz

while 1 
    disp('Crtl-C to terminate')
    sbgData = sbgBinaryToMatlab(filename, lastbytes);
    lasttime = datenum(sbgData.UtcTime.year(end), sbgData.UtcTime.month(end), sbgData.UtcTime.day(end),sbgData.UtcTime.hour(end),sbgData.UtcTime.min(end),sbgData.UtcTime.sec(end));
    points = length(sbgData.ShipMotion.heave);
    seconds = [1:points]./samplerate;  
    plot(seconds,sbgData.ShipMotion.heave)
    drawnow
    title(['PC time: ' datestr(now) ', SWIFT time (UTC): ' datestr(lasttime)] )
    xlabel('seconds')
    ylabel('heave [m]')
    pause(1/updaterate);
end