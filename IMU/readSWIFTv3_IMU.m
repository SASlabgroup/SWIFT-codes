function [ AHRS GPS ] = readSWIFTv3_IMU( filename );

%Read in Raw IMU binary data from SWIFT v3
% input is string with filename, including extension
% output is AHRS and GPS structures
% automatically saves output as .mat file
%
%   [ AHRS GPS ] = readSWIFTv3_IMU( filename );
%
%   binary Packet structure described in:
%   3DM-GX3-35-Data-Communications-Protocol.pdf
% Binary Format Description
%   The file is composed of packets of data.  Each binary packet begins
%   with the two ascii characters, 'ue'.  The next byte of data is a sensor
%   descriptor. AHRS is pointed to by an int value of 128 or hex number 0x80.
%   The GPS is pointed to by an int value of 129 or a hex number of 0x81.d
%   The final byte of the packet header provides a length of the packet payload.
%   The packet payload is comprised of a number of data fields.  Each data field
%   begins with a field length byte, is followed by a field descriptor byte, and
%   concludes with the remainder of the field bytes being data.  This format is
%   repeated for each field.  The packet concludes with two checksum bytes.
%   The checksum algorithm is described in the document listed above.
%
% Packet descriptors:
%   0x80 = 128 -> AHRS
%   0x81 = 129 -> GPS
%
% AHRS Field descriptors:
%   0x01 = 1 -> Raw Accelerometer Output -> [raw_ax raw_ay raw_az] -> mV
%   0x02 = 2 -> Raw Gyro Output -> [raw_gx raw_gy raw_gz] -> mV
%   0x03 = 3 -> Raw Magnetometer Output -> [raw_mx raw_my raw_mz] -> mV
%   0x04 = 4 -> Corrected Accelerometer Data -> [ax ay az] -> g = 9.80665 m/s^2
%   0x05 = 5 -> Corrected Gyro Data -> [gx gy gz] -> rad/s
%   0x06 = 6 -> Corrected Magnetometer Data -> [mx my mz]-> gauss
%   0x07 = 7 -> Delta Theta Vector -> [dtheta_x dtheta_y dtheta_z] -> rad
%   0x08 = 8 -> Velocity Vector -> [vx vy vz] -> m/s
%   0x09 = 9 -> Orientation Matrix -> 3x3 matrix -> n/a
%   0x0A = 10 -> Quaternion -> [q0 q1 q2 q3] -> n/a
%   0x0B = 11 -> Delta Orientation Matrix -> 3x3 matrix -> n/a
%   0x0C = 12 -> Euler Angles -> [roll, pitch, yaw] -> rad
%   0x0E = 14 -> IMU timestamp -> ticks -> U32 value*16us = seconds
%   0x0F = 15 -> GPS synced timestamp -> [U8 status, U32 Seconds, U32 nanoseconds]
%   0x10 = 16 -> Stabilized North Vector -> [Nx Ny Nz] -> gauss
%   0x11 = 17 -> Stabilized Up Vector -> [grav_x grav_y grav_z] -> g
%   0x12 = 18 -> GPS Correlation timestamp -> [double GPS_TimeOfWeek, U16 GPS_WeekNum, U16Flags]
%
% GPS Field descriptors:
%   0x03 = 3 -> LLH Position (Geodetic RF)
%   0x04 = 4 -> ECEF Position (Earth Centered, Earth Fixed RF)
%   0x05 = 5 -> North East Down Velocity
%   0x06 = 6 -> ECEF Velocity
%   0x07 = 7 -> Dilution of Precision Data
%   0x08 = 8 -> UTC Time
%   0x09 = 9 -> GPS Time
%   0x0A = 10 -> Clock Information
%   0x0B = 11 -> GPS Fix Information
%   0x0C = 12 -> Satellite Information
%   0x0D = 13 -> Hardware Status
%
% Output variables:
%   AHRS -> Structure including all parsed variables from the AHRS Sensor
%   GPS  -> Structure including all parsed variables from the GPS Sensor
%
%   A. Brown Dec 2014
%   Edited by M. Smith aboard RV Sikuliaq, Nov 2015
%   converted to function by J. Thomson, June 2016



fid = fopen(filename);

% Determine file size (n bytes)
fseek(fid, 0, 'eof');
EOF_pos = ftell(fid);
fseek(fid, 0, 'bof');
file_pos = ftell(fid);

% Initialize AHRS and GPS variable structures
AHRS = {};
GPS = {};

% Choose AHRS fields to save, use NaN if you don't want any fields
AHRS_field_array = [4 5 6 8 10 12 14 15 18];

% Choose GPS fields to save, use NaN if you don't want any fields
GPS_field_array = [3 5 8 9];

% IMU Data conversion binary to text
AHRSi = 1; %Start indexing for ahrs matricies
GPSi = 1; %Start indexing for gps matricies
Skipped_Packet_Cnt = 0;

% Each iteration of the while-loop will read a single packet of data
% In case of partial packet 4 insures proper header read-in
% Find the beginning of the next data packet
while (file_pos < EOF_pos-4)
    [u, read_count] = fread(fid,1,'char','ieee-le');
    if (u == uint8('u'))
        [e, read_count] = fread(fid,1,'char','ieee-le');
        if (e == uint8('e'))
            % Read in remainder of 4 byte header (2 bytes), fields are
            % 1) Sensor descriptor byte, 2) Payload length byte
            [PacketInfo read_count] = fread(fid,[2],'uint8','ieee-be'); %header
            DataType = PacketInfo(1);
            PayloadLength = PacketInfo(2);
            
            % Marks the start position of the packet payload
            PayloadStartPos = ftell(fid);
            
            % Check to make sure the final packet was fully recorded
            if ( (PayloadStartPos + PayloadLength) > EOF_pos )
                disp('Final packet payload is incomplete');
                fseek(fid, 0, 'eof');
                break;
            end %if
            
            % Determine sensor type and complete packet read
            % AHRS Packet is headed with the int 128
            if (DataType == 128) && ~isempty(AHRS_field_array) %Packet contains AHRS Data
                % Initialize field variables so that if field is missing...
                % A NaN is added to the data matrix
                [AHRS] = AHRS_Init_Var_func(AHRS_field_array, AHRS, AHRSi);
                % Read data fields from AHRS packet
                [AHRS] = AHRS_Read_Payload_func(fid, AHRS_field_array, AHRS, AHRSi, PayloadLength);
                % Increment AHRS sample index
                AHRSi = AHRSi+1;
                % Determine end of packet payload location, measured in bytes.
                PayloadEndPos = ftell(fid);
                % Check Packet Length
                if (PayloadEndPos - PayloadStartPos) ~= (PayloadLength + 2)
                    disp('Minor error: AHRS Packet did not read in correct number of bytes')
                end %if
                
                % GPS Packet is headed with the int 129
            elseif DataType == 129 && ~isempty(GPS_field_array) %Packet contains GPS Data
                % Initialize field variables so that if field is missing...
                % A NaN is added to the data matrix
                [GPS] = GPS_Init_Var_func(GPS_field_array, GPS, GPSi);
                % Read data fields from GPS packet
                [GPS] = GPS_Read_Payload_func(fid, GPS_field_array, GPS, GPSi, PayloadLength);
                % Increment GPS packet index
                GPSi = GPSi+1;
                % Determine end of packet payload location, measured in bytes.
                PayloadEndPos = ftell(fid);
                % Check Packet Length
                if (PayloadEndPos - PayloadStartPos) ~= (PayloadLength + 2)
                    disp('Minor error: GPS Packet did not read in correct number of bytes')
                end %if
                
            else
                Skipped_Packet_Cnt = Skipped_Packet_Cnt + 1;
                % Read the payload into the skip variable and
                fseek(fid,[PayloadLength+2],'cof');
            end % if
        end % if
    end % if
    file_pos = ftell(fid);
end % while

fclose(fid);

save([ filename(1:end-4) '.mat'], 'AHRS', 'GPS');