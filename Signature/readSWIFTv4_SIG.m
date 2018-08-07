function [ burst  avg  battery ] = readSWIFTv4_SIG(filename)
% read binary Nortek Signature files recorded onboard SWIFT v4
% input is string of filename with extension
% output is structures with burst and avg data, plus average battery voltage
%
%    [ burst avg battery ] = readSWIFTv4_SIG(filename);
%
% the raw files (.dat) are offloaded from the CF card on the SWIFT
% they begin a log of ASCII commands from the Sutron controller and instrument response
% then binary data follows, always starting with 0xA5 0x0A 0x15 0x10 or
% 0xA5 0x0A 0x16 0x10
%
%
% J. Thomson, 4/2017 (adapted from readSWIFTv3_AQH.m)
%                originally hard-wired for default SWIFT settings (# cells, NC and # beams, NB)
%             9/2017  fixed bugs that were skipping sound speed and reading pressure as 16, not 32 bits
%                also now read NC and NB directly 
%                also fixed velocity scaling and pitch, roll, heading units
%


fid = fopen( filename );

% initialize counters
ensemblecount_burst = 0;
ensemblecount_avg = 0;

while (~feof(fid))
    
    Sync = fread(fid,1,'uint8','ieee-le'); % sync byte A5 (hex = 165)
    
    if strcmp('A5',dec2hex(Sync)), % if found a sync byte, try reading the rest of the header
        
        HeaderSize = fread(fid,1,'uint8','ieee-le'); % header size, usually 10 bytes
        
        if HeaderSize == 10, % if header size correct, try reading data ID and family
            
            ID = fread(fid,1,'uint8','ieee-le'); % ID byte
            Family = fread(fid,1,'uint8','ieee-le');    % instrument family, should be '10' (hex = 16) for AD2CP
            
            %% read burst data
            if  strcmp('15',dec2hex(ID)) &&  strcmp('10',dec2hex(Family)),
                
                % check data to be read is not longer than file
                DataSize = fread(fid,1,'uint16','ieee-le');    % data size (in bytes)
                presentposition = ftell(fid);
                fseek(fid,0,'eof');
                filelength = ftell(fid);
                if (presentposition + DataSize) < filelength,
                    
                    fseek(fid,presentposition,'bof');
                    DataChecksum = fread(fid,1,'uint16','ieee-le');    % data checksum
                    HeaderChecksum = fread(fid,1,'uint16','ieee-le');    % header checksum
                    
                    startposition = ftell(fid);
                    ensemblecount_burst = ensemblecount_burst + 1;
                    
                    Version = fread(fid,1,'uint8','ieee-le');
                    offsetOfData = fread(fid,1,'uint8','ieee-le');
                    
                    Configuration_pressure = fread(fid,1,'ubit1','ieee-le');
                    Configuration_Temperature = fread(fid,1,'ubit1','ieee-le');
                    Configuration_compass = fread(fid,1,'ubit1','ieee-le');
                    Configuration_tilt = fread(fid,1,'ubit1','ieee-le');
                    Configuration_ = fread(fid,1,'ubit1','ieee-le');
                    Configuration_velocity = fread(fid,1,'ubit1','ieee-le');
                    Configuration_amplitude = fread(fid,1,'ubit1','ieee-le');
                    Configuration_correlation = fread(fid,1,'ubit1','ieee-le');
                    Configuration_altimeter = fread(fid,1,'ubit1','ieee-le');
                    Configuration_altimeterraw = fread(fid,1,'ubit1','ieee-le');
                    Configuration_AST = fread(fid,1,'ubit1','ieee-le');
                    Configuration_echosounder = fread(fid,1,'ubit1','ieee-le');
                    Configuration_AHRS = fread(fid,1,'ubit1','ieee-le');
                    Configuration_PG = fread(fid,1,'ubit1','ieee-le');
                    Configuration_SD = fread(fid,1,'ubit1','ieee-le');
                    Configuration_unused = fread(fid,1,'ubit1','ieee-le');
                    
                    SerialNumber = fread(fid,1,'uint32','ieee-le');
                    year = fread(fid,1,'uint8','ieee-le') + 1900;
                    month = fread(fid,1,'uint8','ieee-le') + 1;
                    day = fread(fid,1,'uint8','ieee-le');
                    hour = fread(fid,1,'uint8','ieee-le');
                    minute = fread(fid,1,'uint8','ieee-le');
                    second = fread(fid,1,'uint8','ieee-le');
                    microsecond = fread(fid,1,'uint16','ieee-le');
                    burst.time(ensemblecount_burst) = datenum( year, month, day, hour, minute, second );
                    
                    burst.SoundSpeed(ensemblecount_burst) = fread(fid,1,'uint16','ieee-le')./10;
                    burst.Temperature(ensemblecount_burst) = fread(fid,1,'int16','ieee-le')./100;
                    burst.Pressure(ensemblecount_burst) = fread(fid,1,'uint32','ieee-le')./1000;
                    burst.Heading(ensemblecount_burst) = fread(fid,1,'uint16','ieee-le')./100;
                    burst.Pitch(ensemblecount_burst) = fread(fid,1,'int16','ieee-le')./100;
                    burst.Roll(ensemblecount_burst) = fread(fid,1,'int16','ieee-le')./100;
                    
                    
                    value = fread(fid,1,'uint16','ieee-le');
                    NC = bitand(value, 1023); % cells
                    CY  = bitand(bitshift(value, -10),3);
                    NB = bitand(bitshift(value, -12),15);  % beams
                    
                    burst.CellSize = fread(fid,1,'uint16','ieee-le')./1000;
                    burst.Blanking = fread(fid,1,'uint16','ieee-le')./100;
                    NominalCorrelation = fread(fid,1,'uint8','ieee-le');
                    bursteraturePressureSenor = fread(fid,1,'uint8','ieee-le');
                    BatteryVoltage(ensemblecount_burst) = fread(fid,1,'uint16','ieee-le');
                    burst.Magnetometer(ensemblecount_burst,1) = fread(fid,1,'int16','ieee-le');
                    burst.Magnetometer(ensemblecount_burst,2) = fread(fid,1,'int16','ieee-le');
                    burst.Magnetometer(ensemblecount_burst,3) = fread(fid,1,'int16','ieee-le');
                    burst.Accelerometer(ensemblecount_burst,1) = fread(fid,1,'int16','ieee-le');
                    burst.Accelerometer(ensemblecount_burst,2) = fread(fid,1,'int16','ieee-le');
                    burst.Accelerometer(ensemblecount_burst,3) = fread(fid,1,'int16','ieee-le');
                    AmbiquityVelocity(ensemblecount_burst) = fread(fid,1,'uint16','ieee-le');
                    DataSetDescription(ensemblecount_burst) = fread(fid,1,'uint16','ieee-le');
                    TransmitEnergy(ensemblecount_burst) = fread(fid,1,'uint16','ieee-le');
                    VelocityScaling_burst(ensemblecount_burst) = fread(fid,1,'int8','ieee-le');
                    PowerLevel(ensemblecount_burst) = fread(fid,1,'int8','ieee-le');
                    Magnetometerbursterature(ensemblecount_burst) = fread(fid,1,'int16','ieee-le');
                    RealTimeClockbursterature(ensemblecount_burst) = fread(fid,1,'int16','ieee-le');
                    Error(ensemblecount_burst) = fread(fid,1,'uint16','ieee-le');
                    Status0(ensemblecount_burst) = fread(fid,1,'uint16','ieee-le');
                    Status(ensemblecount_burst) = fread(fid,1,'uint32','ieee-le');
                    EnsembleCounter(ensemblecount_burst) = fread(fid,1,'uint32','ieee-le');
                    
                    if Configuration_velocity==1,
                        for ni=1:NB,
                            burst.VelocityData(ensemblecount_burst,1:NC,ni) = fread(fid,NC,'int16','ieee-le') .* 10^VelocityScaling_burst(ensemblecount_burst);
                        end
                    else
                    end
                    if Configuration_amplitude==1,
                        for ni=1:NB,
                            burst.AmplitudeData(ensemblecount_burst,1:NC,ni) = fread(fid,NC,'uint8','ieee-le');
                        end
                    else
                    end
                    if Configuration_correlation==1,
                        for ni=1:NB,
                            
                            burst.CorrelationData(ensemblecount_burst,1:NC,ni) = fread(fid,NC,'uint8','ieee-le');
                        end
                    else
                    end
                    if Configuration_altimeter==1,
                        burst.AltimeterDistance(ensemblecount_burst) = fread(fid,1,'float32','ieee-le');
                        burst.AltimeterQuality(ensemblecount_burst) = fread(fid,1,'uint16','ieee-le');
                        burst.AltimeterStatus(ensemblecount_burst) = fread(fid,1,'ubit16','ieee-le');
                    else
                    end
                    if Configuration_AST==1,
                        burst.ASTDistance(ensemblecount_burst) = fread(fid,1,'float32','ieee-le');
                        burst.ASTQuality(ensemblecount_burst) = fread(fid,1,'uint16','ieee-le');
                        burst.ASToffsetStatus(ensemblecount_burst) = fread(fid,1,'int16','ieee-le');
                        burst.ASTpressure(ensemblecount_burst) = fread(fid,1,'float32','ieee-le');
                        burst.AltimeterSpare(ensemblecount_burst) = fread(fid,1,'ubit64','ieee-le');
                    else
                    end
                    if Configuration_altimeterraw==1,
                        burst.AltimeterRawNumberSamples(ensemblecount_burst) = fread(fid,1,'uint32','ieee-le');
                        burst.AltimeterRawSampleDistance(ensemblecount_burst) = fread(fid,1,'uint16','ieee-le');
                        burst.AltimeterRawSamples(ensemblecount_burst) = fread(fid,1,'uint16','ieee-le');
                    else
                    end
                    if Configuration_echosounder==1,
                        burst.EchoSounder(ensemblecount_burst,1:NC) = fread(fid,NC,'uint16','ieee-le');
                    else
                    end
                    if Configuration_AHRS==1,
                        burst.AHRS_M11(ensemblecount_burst) = fread(fid,1,'float32','ieee-le');
                        burst.AHRS_M12(ensemblecount_burst) = fread(fid,1,'float32','ieee-le');
                        burst.AHRS_M13(ensemblecount_burst) = fread(fid,1,'float32','ieee-le');
                        burst.AHRS_M21(ensemblecount_burst) = fread(fid,1,'float32','ieee-le');
                        burst.AHRS_M22(ensemblecount_burst) = fread(fid,1,'float32','ieee-le');
                        burst.AHRS_M23(ensemblecount_burst) = fread(fid,1,'float32','ieee-le');
                        burst.AHRS_M31(ensemblecount_burst) = fread(fid,1,'float32','ieee-le');
                        burst.AHRS_M32(ensemblecount_burst) = fread(fid,1,'float32','ieee-le');
                        burst.AHRS_M33(ensemblecount_burst) = fread(fid,1,'float32','ieee-le');
                        burst.AHRS_Dummy(ensemblecount_burst,:) = fread(fid,4,'float32','ieee-le');
                        burst.AHRS_GyroX(ensemblecount_burst) = fread(fid,1,'float32','ieee-le');
                        burst.AHRS_GyroY(ensemblecount_burst) = fread(fid,1,'float32','ieee-le');
                        burst.AHRS_GyroZ(ensemblecount_burst) = fread(fid,1,'float32','ieee-le');
                    else
                    end
                    if Configuration_PG==1,
                        burst.PercentGood(ensemblecount_burst,NC) = fread(fid,NC,'uint8','ieee-le');
                    else
                    end
                    if Configuration_SD==1,
                        burst.SDpitch(ensemblecount_burst) = fread(fid,1,'int16','ieee-le');
                        burst.SDroll(ensemblecount_burst) = fread(fid,1,'int16','ieee-le');
                        burst.SDheading(ensemblecount_burst) = fread(fid,1,'int16','ieee-le');
                        burst.SDpressure(ensemblecount_burst) = fread(fid,1,'int16','ieee-le');
                        burst.SDdummy(ensemblecount_burst) = fread(fid,12,'int16','ieee-le');
                    else
                    end
                    
                    %% make sure that the DataSize from the header was the data read
                    endposition = ftell(fid);
                    if endposition > startposition + DataSize,
                        disp('read too far')
                        fseek(fid, -1, startposition + DataSize)
                    else
                    end
                    
                    
                    % exit if data to be read extends beyond file length
                else
                    fclose (fid);
                    battery = mean(BatteryVoltage) ./ 10;
                    save([filename(1:end-4) '.mat'],'burst','avg','battery')
                    return
                end
                
                
                %% read avg data
            elseif  strcmp('16',dec2hex(ID)) &  strcmp('10',dec2hex(Family)),
                
                                % check data to be read is not longer than file
                DataSize = fread(fid,1,'uint16','ieee-le');    % data size (in bytes)
                presentposition = ftell(fid);
                fseek(fid,0,'eof');
                filelength = ftell(fid);
                if (presentposition + DataSize) < filelength,
                    
                    fseek(fid,presentposition,'bof');
                    DataChecksum = fread(fid,1,'uint16','ieee-le');    % data checksum
                    HeaderChecksum = fread(fid,1,'uint16','ieee-le');    % header checksum
                    
                    startposition = ftell(fid);
                    ensemblecount_avg = ensemblecount_avg + 1;
                    
                    Version = fread(fid,1,'uint8','ieee-le');
                    offsetOfData = fread(fid,1,'uint8','ieee-le');
                    
                    Configuration_pressure = fread(fid,1,'ubit1','ieee-le');
                    Configuration_Temperature = fread(fid,1,'ubit1','ieee-le');
                    Configuration_compass = fread(fid,1,'ubit1','ieee-le');
                    Configuration_tilt = fread(fid,1,'ubit1','ieee-le');
                    Configuration_ = fread(fid,1,'ubit1','ieee-le');
                    Configuration_velocity = fread(fid,1,'ubit1','ieee-le');
                    Configuration_amplitude = fread(fid,1,'ubit1','ieee-le');
                    Configuration_correlation = fread(fid,1,'ubit1','ieee-le');
                    Configuration_altimeter = fread(fid,1,'ubit1','ieee-le');
                    Configuration_altimeterraw = fread(fid,1,'ubit1','ieee-le');
                    Configuration_AST = fread(fid,1,'ubit1','ieee-le');
                    Configuration_echosounder = fread(fid,1,'ubit1','ieee-le');
                    Configuration_AHRS = fread(fid,1,'ubit1','ieee-le');
                    Configuration_PG = fread(fid,1,'ubit1','ieee-le');
                    Configuration_SD = fread(fid,1,'ubit1','ieee-le');
                    Configuration_unused = fread(fid,1,'ubit1','ieee-le');
                    
                    SerialNumber = fread(fid,1,'uint32','ieee-le');
                    year = fread(fid,1,'uint8','ieee-le') + 1900;
                    month = fread(fid,1,'uint8','ieee-le') + 1;
                    day = fread(fid,1,'uint8','ieee-le');
                    hour = fread(fid,1,'uint8','ieee-le');
                    minute = fread(fid,1,'uint8','ieee-le');
                    second = fread(fid,1,'uint8','ieee-le');
                    microsecond = fread(fid,1,'uint16','ieee-le');
                    avg.time(ensemblecount_avg) = datenum( year, month, day, hour, minute, second );
                    
                    avg.SoundSpeed(ensemblecount_burst) = fread(fid,1,'uint16','ieee-le')./10;
                    avg.Temperature(ensemblecount_avg) = fread(fid,1,'int16','ieee-le')./100;
                    avg.Pressure(ensemblecount_avg) = fread(fid,1,'uint32','ieee-le')./1000;
                    avg.Heading(ensemblecount_avg) = fread(fid,1,'uint16','ieee-le')./100;
                    avg.Pitch(ensemblecount_avg) = fread(fid,1,'int16','ieee-le')./100;
                    avg.Roll(ensemblecount_avg) = fread(fid,1,'int16','ieee-le')./100;
                                        
                    value = fread(fid,1,'int16','ieee-le');
                    NC = bitand(value, 1023,'int16'); % number of cells
                    CY  = bitand(bitshift(value, -10),3);
                    NB = bitand(bitshift(value, -12),15);  % number of beams

                    
                    avg.CellSize = fread(fid,1,'uint16','ieee-le')./1000;
                    avg.Blanking = fread(fid,1,'uint16','ieee-le')./100;
                    NominalCorrelation = fread(fid,1,'uint8','ieee-le');
                    avgeraturePressureSenor = fread(fid,1,'uint8','ieee-le');
                    BatteryVoltage(ensemblecount_avg) = fread(fid,1,'uint16','ieee-le');
                    avg.Magnetometer(ensemblecount_avg,1) = fread(fid,1,'int16','ieee-le');
                    avg.Magnetometer(ensemblecount_avg,2) = fread(fid,1,'int16','ieee-le');
                    avg.Magnetometer(ensemblecount_avg,3) = fread(fid,1,'int16','ieee-le');
                    avg.Accelerometer(ensemblecount_avg,1) = fread(fid,1,'int16','ieee-le');
                    avg.Accelerometer(ensemblecount_avg,2) = fread(fid,1,'int16','ieee-le');
                    avg.Accelerometer(ensemblecount_avg,3) = fread(fid,1,'int16','ieee-le');
                    AmbiquityVelocity(ensemblecount_avg) = fread(fid,1,'uint16','ieee-le');
                    DataSetDescription(ensemblecount_avg) = fread(fid,1,'uint16','ieee-le');
                    TransmitEnergy(ensemblecount_avg) = fread(fid,1,'uint16','ieee-le');
                    VelocityScaling_avg(ensemblecount_avg) = fread(fid,1,'int8','ieee-le');
                    PowerLevel(ensemblecount_avg) = fread(fid,1,'int8','ieee-le');
                    Magnetometeravgerature(ensemblecount_avg) = fread(fid,1,'int16','ieee-le');
                    RealTimeClockavgerature(ensemblecount_avg) = fread(fid,1,'int16','ieee-le');
                    Error(ensemblecount_avg) = fread(fid,1,'uint16','ieee-le');
                    Status0(ensemblecount_avg) = fread(fid,1,'uint16','ieee-le');
                    Status(ensemblecount_avg) = fread(fid,1,'uint32','ieee-le');
                    EnsembleCounter(ensemblecount_avg) = fread(fid,1,'uint32','ieee-le');
                    
                    if Configuration_velocity==1,
                        for ni=1:NB,
                            avg.VelocityData(ensemblecount_avg,1:NC,ni) = fread(fid,NC,'int16','ieee-le') .* 10^VelocityScaling_avg(ensemblecount_avg);
                        end
                    else
                    end
                    if Configuration_amplitude==1,
                        for ni=1:NB,
                            avg.AmplitudeData(ensemblecount_avg,1:NC,ni) = fread(fid,NC,'uint8','ieee-le');
                        end
                    else
                    end
                    if Configuration_correlation==1,
                        for ni=1:NB,                      
                            avg.CorrelationData(ensemblecount_avg,1:NC,ni) = fread(fid,NC,'uint8','ieee-le');
                        end
                    else
                    end
                    if Configuration_altimeter==1,
                        avg.AltimeterDistance(ensemblecount_avg) = fread(fid,1,'float32','ieee-le');
                        avg.AltimeterQuality(ensemblecount_avg) = fread(fid,1,'uint16','ieee-le');
                        avg.AltimeterStatus(ensemblecount_avg) = fread(fid,1,'ubit16','ieee-le');
                    else
                    end
                    if Configuration_AST==1,
                        avg.ASTDistance(ensemblecount_avg) = fread(fid,1,'float32','ieee-le');
                        avg.ASTQuality(ensemblecount_avg) = fread(fid,1,'uint16','ieee-le');
                        avg.ASToffsetStatus(ensemblecount_avg) = fread(fid,1,'int16','ieee-le');
                        avg.ASTpressure(ensemblecount_avg) = fread(fid,1,'float32','ieee-le');
                        avg.AltimeterSpare(ensemblecount_avg) = fread(fid,1,'ubit64','ieee-le');
                    else
                    end
                    if Configuration_altimeterraw==1,
                        avg.AltimeterRawNumberSamples(ensemblecount_avg) = fread(fid,1,'uint32','ieee-le');
                        avg.AltimeterRawSampleDistance(ensemblecount_avg) = fread(fid,1,'uint16','ieee-le');
                        avg.AltimeterRawSamples(ensemblecount_avg) = fread(fid,1,'uint16','ieee-le');
                    else
                    end
                    if Configuration_echosounder==1,
                        avg.EchoSounder(ensemblecount_avg) = fread(fid,NC,'uint16','ieee-le');
                    else
                    end
                    if Configuration_AHRS==1,
                        avg.AHRS_M11(ensemblecount_avg) = fread(fid,1,'float32','ieee-le');
                        avg.AHRS_M12(ensemblecount_avg) = fread(fid,1,'float32','ieee-le');
                        avg.AHRS_M13(ensemblecount_avg) = fread(fid,1,'float32','ieee-le');
                        avg.AHRS_M21(ensemblecount_avg) = fread(fid,1,'float32','ieee-le');
                        avg.AHRS_M22(ensemblecount_avg) = fread(fid,1,'float32','ieee-le');
                        avg.AHRS_M23(ensemblecount_avg) = fread(fid,1,'float32','ieee-le');
                        avg.AHRS_M31(ensemblecount_avg) = fread(fid,1,'float32','ieee-le');
                        avg.AHRS_M32(ensemblecount_avg) = fread(fid,1,'float32','ieee-le');
                        avg.AHRS_M33(ensemblecount_avg) = fread(fid,1,'float32','ieee-le');
                        avg.AHRS_Dummy(ensemblecount_avg,:) = fread(fid,4,'float32','ieee-le');
                        avg.AHRS_GyroX(ensemblecount_avg) = fread(fid,1,'float32','ieee-le');
                        avg.AHRS_GyroY(ensemblecount_avg) = fread(fid,1,'float32','ieee-le');
                        avg.AHRS_GyroZ(ensemblecount_avg) = fread(fid,1,'float32','ieee-le');
                    else
                    end
                    if Configuration_PG==1,
                        avg.PercentGood(ensemblecount_avg) = fread(fid,NC,'uint8','ieee-le');
                    else
                    end
                    if Configuration_SD==1,
                        avg.SDpitch(ensemblecount_avg) = fread(fid,1,'int16','ieee-le');
                        avg.SDroll(ensemblecount_avg) = fread(fid,1,'int16','ieee-le');
                        avg.SDheading(ensemblecount_avg) = fread(fid,1,'int16','ieee-le');
                        avg.SDpressure(ensemblecount_avg) = fread(fid,1,'int16','ieee-le');
                        avg.SDdummy(ensemblecount_avg) = fread(fid,12,'int16','ieee-le');
                    else
                    end
                    
                    %% make sure that the DataSize from the header was the data read
                    endposition = ftell(fid);
                    if endposition > startposition + DataSize,
                        disp('read too far')
                        fseek(fid, -1, startposition + DataSize)
                    else
                    end
                    
                    
                    % exit if data to be read extends beyond file length
                else
                    fclose (fid);
                    battery = mean(BatteryVoltage) ./ 10;  % was in 0.1 V, so divide by 10
                    save([filename(1:end-4) '.mat'],'burst','avg','battery')
                    return
                end
                
                
                %% if invalid header, go back to where a sync byte was found and keep trying
            else
                fseek(fid,-3,0);
            end
            
        else
        end
        
        
    else % if the sync byte 'A5' is not found, keep looking
        
        continue
        
    end
    
end % done reading the whole file


