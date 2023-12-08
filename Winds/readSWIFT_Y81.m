function [u,v,w,temp,errorflag] = readSWIFT_Y81(filename)
% function to read RMYoung Sonic Anemometer data (wind in 'Y81' files) from SWIFTs

% K.Zeiden Dec 2023
        
RMYdata = importdata(filename);
u = RMYdata.data(:,1);
v = RMYdata.data(:,2);
w = RMYdata.data(:,3);
temp = RMYdata.data(:,4);
errorflag = RMYdata.data(:,5);  

% %Process
% z = 0.71; % SWIFT.metheight
% fs = 10;
% windspd = mean((uvw(:,1).^2 + uvw(:,2).^2 + uvw(:,3).^2).^.5);
% windspd_alt = (mean(uvw(:,1)).^2 + mean(uvw(:,2).^2)).^.5;
% [ustar,epsilon,meanu,meanv,meanw,meantemp,anisotropy,quality,freq,tkespectrum] = ...
%     inertialdissipation(uvw(:,1), uvw(:,2), uvw(:,3), temp, z, fs);

end