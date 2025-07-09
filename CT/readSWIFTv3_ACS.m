function [Conductivity, Temperature, Salinity, Density, Soundspeed] = readSWIFTv3_ACS( filename )
% function to read in ACS data of temp, salinity, etc raw .dat files from SWIFT v3
% input filename with extension as string, output temp and salinity
%
% [Temperature Salinity ] = readSWIFTv3_CT( filename );
%
% M. Smith aboard RV Sikuliaq
% Adapted from SWIFTv3_PB200raw_readin code
% converted to function by Thomson, June 2016

finfo = dir(filename);

if finfo.bytes == 0
    disp('File is empty.')
    Conductivity = NaN;
    Temperature = NaN;
    Salinity = NaN;
    Density = NaN;
    Soundspeed = NaN;
    Conductance = NaN;
    RawCond0 = NaN;
    RawCond1 = NaN;
    ZAmp = NaN;
    RawTemp = NaN;
else

    linenum = 0;
    
    fid = fopen(filename);
    
    while (~feof(fid))
        
        tline = fgetl(fid);
        linenum = linenum + 1;
        
        acsdata = textscan(tline,'%s%n%n%s%n%s%n%s%n%s%n%s%n%s%n%s%n%s%n%s%n%s%n');
        
        Conductivity(linenum,:) = acsdata(5); %mS/cm
        Temperature(linenum,:) = acsdata(7); %deg C
        Salinity(linenum,:) = acsdata(9); %psu
        Density(linenum,:) = acsdata(11); %kg/m3
        Soundspeed(linenum,:) = acsdata(13); %m/s
        Conductance(linenum,:) = acsdata(15); %mS
        RawCond0(linenum,:) = acsdata(17); %LSB
        RawCond1(linenum,:) = acsdata(19); %LSB
        ZAmp(linenum,:) = acsdata(21); %mV
        RawTemp(linenum,:) = acsdata(23); %mV
        
    end
    Conductivity = cell2mat(Conductivity(1:length(Conductivity)-1));
    Temperature = cell2mat(Temperature(1:length(Conductivity)-1));
    Salinity = cell2mat(Salinity(1:length(Conductivity)-1));
    Density = cell2mat(Density(1:length(Conductivity)-1));
    Soundspeed = cell2mat(Soundspeed(1:length(Conductivity)-1));
    Conductance = cell2mat(Conductance(1:length(Conductivity)-1));
    RawCond0 = cell2mat(RawCond0(1:length(Conductivity)-1));
    RawCond1 = cell2mat(RawCond1(1:length(Conductivity)-1));
    ZAmp = cell2mat(ZAmp(1:length(Conductivity)-1));
    RawTemp = cell2mat(RawTemp(1:length(Conductivity)-1));
    
    fclose(fid);

end

save([filename(1:end-4) '.mat'],'Conductivity','Temperature','Salinity','Density','Soundspeed','Conductance','RawCond0','RawCond1','ZAmp','RawTemp');
