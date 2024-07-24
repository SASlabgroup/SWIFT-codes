% aggregate, concat, and read all onboard processed SWIFT data (once offloaded from SD card) 
% run this in a dedicated directory for the results
% 
% (this fills in the results not sent by Iridium when running more than 1 burst per hour) 
%
% J. Thomson, 4/2014
%               9/2015  v3.3, use com names but currently only pulls one ACS file (out of three), because they are not uniquely named. 
%               1/2016  v3.3, so up to 3 ACS files can be included
%               6/2016 v 3.4, includ sdi coms (Vasaila 536)
%               1/2017  v4.0, include SBG, Nortek Signature and RM Young 8100 sonic, plus index on SBG, not AQ
%               9/2017  add oxygen optode and sea owl fluorometer
%               9/2019  changed time convention to use start of the burst,rather than end
%

clear all, close all, clc

plotflag = 1;  % binary flag for plotting
burstinterval = 12; % minutes between bursts
burstlength = 512/60; % minutes of sampling during each burst

dirpath = './'%'~/Desktop/'; '~/Dropbox/SWIFT_v3.x/TestData/';
sourcedir = ''%'SWIFT11_02Oct2014_SDcard';%'SWIFT15_Test_19Jun2014'%'SWIFTdata_27Apr2014' %'SWIFT15_LakeWA_Stereo_09May2014';

%%  glob all processed files (per instrument) 
% and put these all in one directory (skip if already in one directory)

eval(['!cp -r ' dirpath sourcedir '/*/Processed/*/*PRC*.dat  . ' ]) % use for single
%eval(['!cp -r ' dirpath sourcedir '/*/*/Processed/*/*PRC*  . ' ]) % use for multiple SWIFTs


%% use directory listing to find all files,
% using the IMU or SBG files as reference to find each burst and the other sensors
% (b/c either IMU or SBG is always present)

refnames = dir('*IMU*_PRC*.dat');
if isempty(refnames), 
    refnames = dir('*SBG*_PRC*.dat');
else
    disp('NO IMU (or SBG) files found');
end

for ai = 1:length(refnames),
   
    disp([ num2str(ai) ' of ' num2str(length(refnames)) ])
    
    ID = refnames(ai).name(1:7);
    date = refnames(ai).name(13:21);
    hour = refnames(ai).name(23:24);
    burst = refnames(ai).name(26:27);
    
    %AQtype = AQnames(ai).name(11);
    
    payloadtype = '7'; % v3.3 (2015) and up 
    
    fid = fopen('payload','wb');
    fwrite(fid,payloadtype,'uint8');
    fclose(fid);
    
    %% look for multiple ACS fils (on different com ports)
    eval(['!cp -r ' dirpath sourcedir '/COM-7/Processed/*/' ID '_ACS_' date '_' hour '_' burst '_PRC.dat  '   ID '_ACStop_' date '_' hour '_' burst '_PRC.dat' ])
    eval(['!cp -r ' dirpath sourcedir '/COM-8/Processed/*/' ID '_ACS_' date '_' hour '_' burst '_PRC.dat  '   ID '_ACSmid_' date '_' hour '_' burst '_PRC.dat' ])
    eval(['!cp -r ' dirpath sourcedir '/COM-9/Processed/*/' ID '_ACS_' date '_' hour '_' burst '_PRC.dat  '   ID '_ACSbottom_' date '_' hour '_' burst '_PRC.dat' ])
    
    
    %% concatenate files (to make fake SBD telemetry files)
    
    AQHfile = [ID '_AQH_' date '_' hour '_' burst '_PRC.dat'];
    AQDfile = [ID '_AQD_' date '_' hour '_' burst '_PRC.dat'];
    Metfile = [ID '_PB2_' date '_' hour '_' burst '_PRC.dat'];
    %Metfile = [ID '_536_' date '_' hour '_' burst '_PRC.dat'];
    IMUfile = [ID '_IMU_' date '_' hour '_' burst '_PRC.dat'];
    SBGfile = [ID '_SBG_' date '_' hour '_' burst '_PRC.dat'];
    %ACSfile = [ID '_ACS_' date '_' hour '_' burst '_PRC.dat'];
    ACSfiletop = [ID '_ACStop_' date '_' hour '_' burst '_PRC.dat'];
    ACSfilemid = [ID '_ACSmid_' date '_' hour '_' burst '_PRC.dat'];
    ACSfilebottom = [ID '_ACSbottom_' date '_' hour '_' burst '_PRC.dat'];
    Y81file = [ID '_Y81_' date '_' hour '_' burst '_PRC.dat'];
    SIGfile = [ID '_SIG_' date '_' hour '_' burst '_PRC.dat'];
    ACOfile = [ID '_ACO_' date '_' hour '_' burst '_PRC.dat'];
    SWLfile = [ID '_SWL_' date '_' hour '_' burst '_PRC.dat'];
    
    
    minute = num2str( (str2num(burst(2))-1) * burstinterval );
    if length(minute)==1, minute = ['0' minute]; else end
    outputfile = ['buoy-SWIFT_' ID(6:7) '-' date '_' hour  minute '000.sbd']; % name concat file same as if pulled from swiftserver
    
    %eval(['!cat payload ' AQHfile ' ' AQDfile ' ' Metfile ' ' IMUfile ' ' SBGfile ' ' Y81file ' ' SIGfile '  ' ACSfilemid '  > ' outputfile]) % create the file
    eval(['!cat payload ' AQHfile ' ' AQDfile ' ' Metfile ' ' IMUfile ' ' SBGfile ' ' Y81file ' ' SIGfile ' ' ACSfiletop '  ' ACSfilemid ' ' ACSfilebottom ' ' ACOfile ' ' SWLfile ' > ' outputfile]) % create the file
    %eval(['!cat payload ' AQHfile ' ' AQDfile ' ' Metfile ' ' IMUfile ' ' SBGfile ' ' Y81file ' ' SIGfile '  ' ACSfilemid ' ' ACSfilebottom ' > ' outputfile]) % create the file


end % close


%% read the resulting sbd files (as if they had come from the server)

sbdlist = dir('*.sbd');
if ~isempty(sbdlist),
    run('compileSWIFT_SBDservertelemetry.m') % includes a plotting call
else 
end


%% clean up, move burst files to new directory

mkdir ConcatProcessed
eval(['!mv *.dat ConcatProcessed/'])
eval(['!mv *.sbd ConcatProcessed/'])
eval(['!mv buoy*.mat ConcatProcessed/'])

!rm payload

%% apply QC and rename results (not telemetry)
%[flist removed] = SWIFT_QC( 25, 0.5, 2 );

if isfield(SWIFT(1),'ID')
    load(['SWIFT' SWIFT(1).ID '_telemetry.mat'])
    save(['SWIFT' SWIFT(1).ID '_' datestr(min([SWIFT.time]),'ddmmmyyyy') '_L1.mat'  ], 'SWIFT')
    eval(['!rm *telemetry.mat'])
else
end

plotSWIFT(SWIFT)

