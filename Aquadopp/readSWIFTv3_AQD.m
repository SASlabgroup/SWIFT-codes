function [time VelE VelN VelU Amp1 Amp2 Amp3 Pressure pitch roll heading ] = readSWIFTv3_AQD( filename );
%SWIFT v.3 RAW AQD reader
% read Nortek Aquadopp Profiler .dat files
% downloaded from the CF card
% collected from Surface Wave Instrument Floats With Tracking (SWIFT) v3
%
%   [time VelE VelN VelU Amp1 Amp2 Amp3 Pres Pitch Roll Heading ] = readSWIFTv3_AQD( filename );
%
% M. Smith 10/2015 based on SWIFTv3_RawAQH_readin by Jim Thomson and adapted by Seth Zippel
% J. Thomson 12/2015, remove hard-wired directories, so that can call from reprocess_AQD.m
% J. Thomson 6/2016, convert to function

fid = fopen([filename]);

for ii = 1:512; %512 is length of burst
    
    PacketStartPos(ii) = ftell(fid); %Marks the byte position at start of packet read in
    a5(ii) = fread(fid,1,'uint8','ieee-le'); %sync byte a5(hex)
    
    id(ii) = fread(fid,1,'uint8','ieee-le'); %ID byte 2a(hex)
    %'ieee-le' is little endian ordering
    %uint8 is unsigned integer of 1 byte
    
    
    %Size in number of words (1 word = 2 bytes)
    fSize(ii) = fread(fid,1,'uint16','ieee-le');
    
    %times in BCD format
        [minute1(ii) count] = fread(fid,1,'ubit4','ieee-le');     %4 bit
    [minute2(ii) count] = fread(fid,1,'ubit4','ieee-le');     %minute 1 byte
    minute(ii) = 10*minute2(ii) + minute1(ii);                %4 bit
    [second1(ii) count] = fread(fid,1,'ubit4','ieee-le');     %4 bit
    [second2(ii) count] = fread(fid,1,'ubit4','ieee-le');     %4 bit
    second(ii) = 10*second2(ii) + second1(ii);
    %[d count] = fread(fid,1,'uint8','ieee-le');     %day    1 byte
    [day1(ii) count] = fread(fid,1,'ubit4','ieee-le');     %day    1 byte
    [day2(ii) count] = fread(fid,1,'ubit4','ieee-le');     %day    1 byte
    day(ii) = 10*day2(ii)+day1(ii);
    
    [hour1(ii) count] = fread(fid,1,'ubit4','ieee-le');     %hour   1 byte
    [hour2(ii) count] = fread(fid,1,'ubit4','ieee-le');     %hour   1 byte
    hour(ii) = 10*hour2(ii) + hour1(ii);

    y1(ii) = fread(fid,1,'ubit4','ieee-le');     %year    1 byte
    y2(ii) = fread(fid,1,'ubit4','ieee-le');     %year    1 byte
    year(ii) = 2000 + 10*y2(ii) + y1(ii);
    
    %[month(ii) count] = fread(fid,1,'uint8','ieee-le'); %Month  1 byte
    m1(ii) = fread(fid,1,'ubit4','ieee-le');     %year    1 byte
    m2(ii) = fread(fid,1,'ubit4','ieee-le');     %year    1 byte
    month(ii) = 10*m2(ii) + m1(ii);
    
    time = datenum([ year' month' day' hour' minute' second' ] );
    
    errorCode(ii) = fread(fid,1,'uint16','ieee-le'); %error code 2 bytes
    %0=OK, 1 = error
    Analn1(ii) = fread(fid,1,'uint16','ieee-le'); %Analouge input 1, 2 byte
    battery(ii) = fread(fid,1,'uint16','ieee-le');  %battery    2 bytes
    battery(ii) = battery(ii)/10; %records in 10ths of volts, convert to volts
    Sspd(ii) = fread(fid,1,'uint16','ieee-le');  %Sound Spd  2 bytes
    Sspd(ii) = Sspd(ii)/10; %records in 10ths of m/s, convert to m/s
    
    heading(ii) = fread(fid,1,'int16','ieee-le');  %Heading  2 bytes
    pitch(ii) = fread(fid,1,'int16','ieee-le');  %Pitch    2 bytes
    roll(ii) = fread(fid,1,'int16','ieee-le');  %Roll     2 bytes
    %'int16' is 2 byte signed integer
    
    %convert from 0.1 degs to degrees
    heading(ii) = heading(ii)/10;
    pitch(ii) = pitch(ii)/10;
    roll(ii) = roll(ii)/10;
    
    PressureMSB(ii) = fread(fid,1,'uint8','ieee-le');  %Pressure MSB  1 bytes
    %(Pressure = 65536×PressureMSB + PressureLSW)
    status(ii) = fread(fid,1,'uint8','ieee-le'); %Status 1 byte
    PressureLSW(ii) = fread(fid,1,'uint16','ieee-le'); %Pressure LSW 2 bytes
    Pressure(ii) = 65536.*PressureMSB(ii) + PressureLSW(ii);
    
    Temp(ii) = fread(fid,1,'int16','ieee-le'); %Temp 2 bytes, 0.01C
    Temp(ii) = Temp(ii)./100;
    
    %Vel[n Beams][n Cells] 2bytes per beam per cell
    VelE(ii,:) = fread(fid,40,'int16','ieee-le'); %hard set at 1 beam, 40 cells
    VelN(ii,:) = fread(fid,40,'int16','ieee-le'); %hard set at 1 beam, 40 cells
    VelU(ii,:) = fread(fid,40,'int16','ieee-le'); %hard set at 1 beam, 40 cells
    %in mm/s
    VelE(ii,:) = VelE(ii,:)./1000;
    VelN(ii,:) = VelN(ii,:)./1000;
    VelU(ii,:) = VelU(ii,:)./1000;
    
    Amp1(ii,:) = fread(fid,40,'uint8','ieee-le');
    Amp2(ii,:) = fread(fid,40,'uint8','ieee-le');
    Amp3(ii,:) = fread(fid,40,'uint8','ieee-le');
    
    %Spare 1
    %[fill(ii)] = fread(fid,1,'uint8','ieee-le');
    
    
    hC_checksum(ii) = fread(fid,1,'uint16','ieee-le');
    %hC = b58c(hex) + sum of all bytes in structure
    
    %disp('Yikes!')
    %datestr([year(ii),month(ii),day(ii),hour(ii),minute(ii),second(ii)])
    %ii = ii+1;
end
fclose (fid);

save([filename(1:end-4) '.mat'])

batteryVoltage = mean(battery)
