function [AHRS] = AHRS_Read_Payload_func(fid, AHRS_field_array, AHRS, AHRSi, PayloadLength)
%% This function reads the packet payload for the AHRS sensor.  AHRS_field_array
%% is a row vector comprised of the payload field identifiers of interest.  If the
%% identifier isn't listed, that field will be skipped.

%% Loop through packet bytes based on known structure.
%% The structure is outlined above, and fully described in:
%% 3DM-GX3-35-Data-Communications-Protocol.pdf

%% Initialize byte counter
   bytesum = 0;
   while(bytesum < PayloadLength) %Loop through packet bytes
      %% Get field descriptor and field length (in bytes)
      [FieldInfo read_count] = fread(fid,[2],'uint8','ieee-be');
      %% Skip the field if the identifer is not present in AHRS_field_array
      if sum(FieldInfo(2) == AHRS_field_array) == 0 % AHRS field descriptor doesn't match any value in AHRS_field_array
         fseek(fid,[FieldInfo(1)-2],'cof');
         %% If the field is listed in AHRS_field_array, retrieve the data
      elseif sum(FieldInfo(2) == AHRS_field_array) > 0 % AHRS field descriptor matches atleast one value in AHRS_field_array
         if (FieldInfo(2) == 1) % Raw Accel
            if FieldInfo(1) == 14
               [raw_Accel count] = fread(fid,[3],'float32','ieee-be'); % mV
               AHRS.raw_Accel(AHRSi,1:3) = raw_Accel;
            else
               disp('AHRS 0x01 composed of incorrect number of bytes');
               break
            end %if
         elseif (FieldInfo(2) == 2) % Raw Gyro
            if FieldInfo(1) == 14
               [raw_Gyro count] = fread(fid,[3],'float32','ieee-be'); % mV
               AHRS.raw_Gyro(AHRSi,1:3) = raw_Gyro;
            else
               disp('AHRS 0x02 composed of incorrect number of bytes');
               break
            end %if
         elseif (FieldInfo(1) == 14) && (FieldInfo(2) == 3) % Raw Magnetometer
            if (FieldInfo(1) == 14)
               [raw_Mag count] = fread(fid,[3],'float32','ieee-be'); % mV
               AHRS.raw_Mag(AHRSi,1:3) = raw_Mag;
            else
               disp('AHRS 0x03 composed of incorrect number of bytes');
               break
            end %if
         elseif (FieldInfo(2) == 4) % Corrected Accel
            if (FieldInfo(1) == 14)
               [Accel count] = fread(fid,[3],'float32','ieee-be'); % g
               AHRS.Accel(AHRSi,1:3) = Accel;
            else
               disp('AHRS 0x04 composed of incorrect number of bytes');
               break
            end %if
         elseif  (FieldInfo(2) == 5) % Corrected Gyro
            if (FieldInfo(1) == 14)
               [Gyro count] = fread(fid,[3],'float32','ieee-be'); % rad/s
               AHRS.Gyro(AHRSi,1:3) = Gyro;
            else
               disp('AHRS 0x05 composed of incorrect number of bytes');
               break
            end %if
         elseif (FieldInfo(2) == 6) % Corrected Magnetometer
            if (FieldInfo(1) == 14)
               [Mag count] = fread(fid,[3],'float32','ieee-be'); % gauss
               AHRS.Mag(AHRSi,1:3) = Mag;
            else
               disp('AHRS 0x06 composed of incorrect number of bytes');
               break
            end %if
         elseif (FieldInfo(2) == 7) % Delta Theta
            if (FieldInfo(1) == 14)
               [dTheta count] = fread(fid,[3],'float32','ieee-be'); % rad
               AHRS.dTheta(AHRSi,1:3) = dTheta;
            else
               disp('AHRS 0x07 composed of incorrect number of bytes');
               break
            end %if
         elseif (FieldInfo(2) == 8) % Velocity Vector
            if (FieldInfo(1) == 14)
               [Vel count] = fread(fid,[3],'float32','ieee-be'); % g*sec
               AHRS.Vel(AHRSi,1:3) = Vel*9.8066; % m/s
            else
               disp('AHRS 0x08 composed of incorrect number of bytes');
               break
            end %if
         elseif (FieldInfo(2) == 9) % Orientation Matrix
            if (FieldInfo(1) == 38)
               [Orient_matrix count] = fread(fid,[9],'float32','ieee-be'); % n/a
               Orient_matrix = reshape(Orient_matrix, [3,3]);
               AHRS.Orient_matrix(1:3,1:3,AHRSi) = Orient_matrix;
            else
               disp('AHRS 0x09 composed of incorrect number of bytes');
               break
            end %if
         elseif (FieldInfo(2) == 10) % Orientation Quaternion
            if (FieldInfo(1) == 18)
               [Quat count] = fread(fid,[4],'float32','ieee-be'); % n/a
               AHRS.Quat(AHRSi,1:4) = Quat;
            else
               disp('AHRS 0x0A composed of incorrect number of bytes');
               break
            end %if
         elseif (FieldInfo(2) == 11) % Delta Orientation Matrix
            if (FieldInfo(1) == 38)
               [dOrient_matrix count] = fread(fid,[9],'float32','ieee-be'); % n/a
               dOrient_matrix = reshape(dOrient_matrix, [3,3]);
               AHRS.dOrient_matrix(1:3,1:3,AHRSi) = dOrient_matrix;
            else
               disp('AHRS 0x0B composed of incorrect number of bytes');
               break
            end %if
         elseif (FieldInfo(2) == 12) % Euler Angles
            if (FieldInfo(1) == 14)
               [Euler_RPY count] = fread(fid,[3],'float32','ieee-be'); % rad
               AHRS.Euler_RPY(AHRSi,1:3) = Euler_RPY;
            else
               disp('AHRS 0x0C composed of incorrect number of bytes');
               break
            end %if
         elseif (FieldInfo(2) == 14) % IMU Time-stamp
            if (FieldInfo(1) ==  6)
               [Timestamp count] = fread(fid,[1],'uint32','ieee-be'); % 16us*value=sec
               AHRS.Timestamp(AHRSi,1) = Timestamp;
               AHRS.Timestamp_sec(AHRSi,1) = Timestamp*0.000016; % sec
            else
               disp('AHRS 0x0E composed of incorrect number of bytes');
               break
            end %if
         elseif (FieldInfo(2) == 15) % GPS Stopwatch
            if (FieldInfo(1) == 11)
               [GPS_Stopwatch_flags count] = fread(fid,[1],'uint8','ieee-be');        
               [GPS_sec count] = fread(fid,[1],'uint32','ieee-be'); % seconds        
               [GPS_nsec count] = fread(fid,[1],'uint32','ieee-be'); % nanoseconds
               AHRS.GPS_Stopwatch.Flags(AHRSi,1) = GPS_Stopwatch_flags;
               AHRS.GPS_Stopwatch.Seconds(AHRSi,1) = GPS_sec;
               AHRS.GPS_Stopwatch.Nanoseconds(AHRSi,1) = GPS_nsec;
            else
               disp('Field composed of incorrect number of bytes');
               break
            end %if
         elseif (FieldInfo(2) == 16) % Stabilized North Vector
            if (FieldInfo(1) == 14)
               [North_vec count] = fread(fid,[3],'float32','ieee-be'); % gauss
               AHRS.North_vec(AHRSi,1:3) = North_vec;
            else
               disp('Field composed of incorrect number of bytes');
               break
            end %if
         elseif (FieldInfo(2) == 17) % Stabilized Up Vector
            if (FieldInfo(1) == 14)
               [Up_vec count] = fread(fid,[3],'float32','ieee-be'); % g
               AHRS.Up_vec(AHRSi,1:3) = Up_vec;
            else
               disp('Field composed of incorrect number of bytes');
            break
            end %if
         elseif (FieldInfo(2) == 18) % GPS Time for IMU
            if (FieldInfo(1) == 14)
               [GPS_TimeOfWeek count] = fread(fid,[1],'float64','ieee-be'); % seconds
               [GPS_WeekNum count] = fread(fid,[1],'uint16','ieee-be'); % num of week
               [GPS_Flags count] = fread(fid,[1],'uint16','ieee-be');
               AHRS.GPS_Time.TimeOfWeek(AHRSi,1) = GPS_TimeOfWeek;
               AHRS.GPS_Time.WeekNum(AHRSi,1) = GPS_WeekNum;
               AHRS.GPS_Time.Flags(AHRSi,1) = GPS_Flags;
            else
               disp('Field composed of incorrect number of bytes');
               break
            end %if
         else
            disp('Unrecognized AHRS data field present in file')
            if (FieldInfo(1)>0)
               fseek(fid,FieldInfo(1),'cof');
            end %if
            unread_fields = unread_fields + 1;
            break
         end %if
      else % Should never happen, if it does, you broke it!  Not my fault!
         disp('Something went wrong during AHRS read-in');
         break
      end %if
      %% Add the field size to the total byte sum
      bytesum = bytesum + FieldInfo(1);
   end %while
   %% Read the last two checksum bytes of the packet to advance file stream location.
   %% The Checksum algorith shown in the manual is NOT Implemented-------------------
   [MSB_LSB count] = fread(fid,[2],'uint8','ieee-be');   
end %function