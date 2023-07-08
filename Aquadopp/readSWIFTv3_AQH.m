function [time Vel Amp Cor Pressure pitch roll heading ] = readSWIFTv3_AQH(filename);
% SWIFT v.3 RAW AQD processing
% input is string of filename with extension
% output is data, also automatically saves mat file%
%
%   [time Vel Amp Cor Pressure pitch roll heading ] = readSWIFTv3_AQH(filename); 
%
% Matlab script to read uplooking Nortek Aquadopp HR Profiler .dat files
% downloaded from the CF card
% collected from Surface Wave Instrument Floats With Tracking (SWIFT) v3
%
% S. Zippel, 08/2014 original, adapted from J. Thomson 2009 code.
%Revisions:
%       12/2014, fix bug in reading timestamp BCD format (Thomson)
%       6/2016, convert to function (J. Thomson)
%

fid = fopen([filename]);

ii = 1;
while (~feof(fid))
    
    PacketStartPos(ii) = ftell(fid); %Marks the byte position at start of packet read in
    [a5 count] = fread(fid,[1],'uint8','ieee-le'); %sync byte a5(hex)
    
    if strcmp('A5',dec2hex(a5))
    else
        continue
    end
    
    [id(ii) count] = fread(fid,1,'uint8','ieee-le'); %ID byte 2a(hex)
    %check for AQD HR
    if strcmp('2A',dec2hex(id(ii)))
    else
        disp('Not AQD HR')
        continue
    end
    
    %Size in number of words (1 word = 2 bytes)
    [fSize(ii) count] = fread(fid,1,'uint16','ieee-le');
    
    
    %times in BCD format (4 bit integers, two each, making 1 byte)
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
    %[y count] = fread(fid,1,'uint8','ieee-le');     %year    1 byte
    [y1(ii) count] = fread(fid,1,'ubit4','ieee-le');     %year    1 byte
    [y2(ii) count] = fread(fid,1,'ubit4','ieee-le');     %year    1 byte
    year(ii) = 2000 + 10*y2(ii) + y1(ii);
    
    [month1(ii) count] = fread(fid,1,'ubit4','ieee-le'); %Month  1 byte
    [month2(ii) count] = fread(fid,1,'ubit4','ieee-le'); %Month  1 byte
    month(ii) = 10*month2(ii) + month1(ii);
    %[milisec(ii) count] = fread(fid,1,'uint16','ieee-le');%millisecond 2 bytes
    
    time = datenum([ year' month' day' hour' minute' second' ] );
    
    [errorCode(ii) count] = fread(fid,1,'uint16','ieee-le'); %error code 2 bytes
    %0=OK, 1 = error
    
    [analog(ii)   count] = fread(fid,1,'uint16','ieee-le');  %analog input    2 bytes
    
    [battery(ii)   count] = fread(fid,1,'uint16','ieee-le');  %battery    2 bytes
    battery(ii) = battery(ii)/10; %records in 10ths of volts, convert to volts
    [Sspd(ii)      count] = fread(fid,1,'uint16','ieee-le');  %Sound Spd  2 bytes
    Sspd(ii) = Sspd(ii)/10; %records in 10ths of m/s, convert to m/s
    
    [heading(ii) count] = fread(fid,1,'int16','ieee-le');  %Heading  2 bytes
    [pitch(ii)   count] = fread(fid,1,'int16','ieee-le');  %Pitch    2 bytes
    [roll(ii)    count] = fread(fid,1,'int16','ieee-le');  %Roll     2 bytes
    
    %convert from 0.1 degs to degrees
    heading(ii) = heading(ii)/10;
    pitch(ii) = pitch(ii)/10;
    roll(ii) = roll(ii)/10;
    
    [PressureMSB(ii)  count] = fread(fid,1,'uint8','ieee-le');  %Pressure MSB  1 bytes
    %(Pressure = 65536×PressureMSB + PressureLSW)
    [status(ii) count] = fread(fid,1,'uint8','ieee-le'); %Status 1 byte
    [PressureLSW(ii)  count] = fread(fid,1,'uint16','ieee-le'); %Pressure LSW 2 bytes
    Pressure(ii) = PressureMSB(ii) + PressureLSW(ii)./4096;
    
    [Temp(ii) count] = fread(fid,1,'int16','ieee-le'); %Temp 2 bytes, 0.01C
    Temp(ii) = Temp(ii)./100;
    
    [Analn1(ii) count] = fread(fid,1,'uint16','ieee-le'); %Analouge input 1, 2 byte
    [Analn2(ii) count] = fread(fid,1,'uint16','ieee-le'); %Analouge input 2, 2 byte
    
    [beams(ii) count] = fread(fid,1,'uint8','ieee-le'); %number of beams 1 byte
    [cells(ii) count] = fread(fid,1,'uint8','ieee-le'); %number of cells 1 byte
    
    %Velocity Lag 2 - array of 3 - 1 per beam
    [VelLag2(ii,:) count] = fread(fid,3,'uint16','ieee-le');
    %Amplitude Lag 2 - array of 3 - 1 per beam
    [AmpLag2(ii,:) count] = fread(fid,3,'uint8','ieee-le');
    %Correlation Lag 2 - array of 3 - 1 per beam
    [CorLag2(ii,:) count] = fread(fid,3,'uint8','ieee-le');
    
    %Spare 1
    [Spare1(ii)] = fread(fid,1,'uint16','ieee-le');
    %Spare 2
    [Spare2(ii)] = fread(fid,1,'uint16','ieee-le');
    %Spare 1
    [Spare1(ii)] = fread(fid,1,'uint16','ieee-le');
    
    %Vel[n Beams][n Cells] 2bytes per beam per cell
    
    Vel(ii,:) = fread(fid,16,'int16','ieee-le'); %hard set at 1 beam, 16 cells
    %in mm/s
    Vel(ii,:) = Vel(ii,:)./1000;
    
    Amp(ii,:) = fread(fid,16,'uint8','ieee-le');
    Cor(ii,:) = fread(fid,16,'uint8','ieee-le');
    
    hC_checksum(ii) = fread(fid,1,'uint16','ieee-le');
    %hC = b58c(hex) + sum of all bytes in structure
    
    %disp('Yikes!')
    %datestr([year(ii),month(ii),day(ii),hour(ii),minute(ii),second(ii)])
    ii = ii+1;
    
    %ftell(fid)
    
end

fclose (fid);

save([filename(1:end-4) '.mat'])

batteryVoltage = mean(battery)