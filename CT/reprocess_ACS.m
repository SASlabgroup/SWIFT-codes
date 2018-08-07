% reprocess SWIFT v3 ACS results to get raw
% M. Smith 08/2016

clear all; close all
parentdir = ('/Users/msmith/Documents/Sikuliaq2015/SWIFT/Racetrack/SWIFT14_25-27Oct2015/ACS/Raw/20151026');  % change this to be the parent directory of all raw raw data (CF card offload from SWIFT)
cd(parentdir)

filelist = dir('*ACS*.dat');

for fi=1:length(filelist),

    % read or load raw data
    if isempty(dir([filelist(fi).name(1:end-4) '.mat'])),
        [Conductivity, Temperature, Salinity, Density, Soundspeed] = readSWIFTv3_ACS( filelist(fi).name );
    else
        load([filelist(fi).name(1:end-4) '.mat']),
    end
    
    salinity_std(fi)=std(Salinity);
    ACS_time=datenum(2015,10,str2num(filelist(fi).name(13:14)),str2num(filelist(fi).name(23:24)),str2num(filelist(fi).name(26:27))*12,00);

    [tdiff, tindex] = min(abs([SWIFT(1).SWIFT.time]-ACS_time));
    SWIFT(1).SWIFT(tindex).salinityvariance = salinity_std(fi);
end
    
%save([ wd '.mat'],'SWIFT')