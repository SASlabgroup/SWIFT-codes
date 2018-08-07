function [GPS] = GPS_Read_Payload_func(fid, GPS_field_array, GPS, GPSi, PayloadLength)
   %% Initialize byte counter
   bytesum = 0;
   while(bytesum < PayloadLength)
      %% Get field descriptor and field length (in bytes)
      [FieldInfo count] = fread(fid,[2],'uint8','ieee-be');
      %% Skip the field if the identifer is not present in GPS_field_array
      if sum(FieldInfo(2) == GPS_field_array) == 0 % GPS field descriptor doesn't match any value in GPS_field_array
         fseek(fid,[FieldInfo(1)-2],'cof');
      elseif sum(FieldInfo(2) == GPS_field_array) > 0 % GPS field descriptor matches atleast one value in GPS_field_array
         if (FieldInfo(2) == 3) % LLH Position (Geodetic)
            if (FieldInfo(1) == 44)
               [Lat_Lon count] = fread(fid,[2],'float64','ieee-be'); % Decimal Degrees
               [Height count] = fread(fid,[2],'float64','ieee-be'); % m
               [Accuracy count] = fread(fid,[2],'float32','ieee-be'); % m
               [Geodetic_Flags count] = fread(fid,[1],'uint16','ieee-be');
               GPS.Geodetic_Pos.Lat_Lon(GPSi,1:2) = Lat_Lon;
               GPS.Geodetic_Pos.H_above_ellipsoid(GPSi,1) = Height(1);
               GPS.Geodetic_Pos.H_above_MSL(GPSi,1) = Height(2);
               GPS.Geodetic_Pos.AccuracyHorz(GPSi,1) = Accuracy(1);
               GPS.Geodetic_Pos.AccuracyVert(GPSi,1) = Accuracy(2);
               GPS.Geodetic_Pos.Flags(GPSi,1) = Geodetic_Flags;
            else
               disp('Packet composed of incorrect number of bytes');
               break
            end %if
         elseif (FieldInfo(2) == 4) % ECEF Position (Earth Centered Earth Fixed)
            if (FieldInfo(1) == 32)
               [Pos_XYZ count] = fread(fid,[3],'float64','ieee-be'); % m
               [Pos_Accuracy count] = fread(fid,[1],'float32','ieee-be'); % m
               [ECEF_Flags count] = fread(fid,[1],'uint16','ieee-be');
               GPS.ECEF_Pos.XYZ(GPSi,1:3) = Pos_XYZ;
               GPS.ECEF_Pos.Accuracy(GPSi,1) = Pos_Accuracy;
               GPS.ECEF_Pos.Flags(GPSi,1) = ECEF_Flags;
            else
               disp('Packet composed of incorrect number of bytes');
               break
            end %if
         elseif (FieldInfo(2) == 5) % NED Velocity (North-East-Down)
            if (FieldInfo(1) == 36)
               [Velocity_NED count] = fread(fid,[3],'float32','ieee-be'); % m/s
               [Speed count] = fread(fid,[1],'float32','ieee-be'); % m/s
               [Grnd_Spd count] = fread(fid,[1],'float32','ieee-be'); % m/s
               [Heading count] = fread(fid,[1],'float32','ieee-be'); % Decimal Degrees
               [Spd_Accuracy count] = fread(fid,[1],'float32','ieee-be'); % m/s
               [Heading_Accuracy count] = fread(fid,[1],'float32','ieee-be'); % Decimal Degrees
               [NED_Vel_Flags count] = fread(fid,[1],'uint16','ieee-be');
               GPS.NED_Vel.Velocity_NED(GPSi,1:3) = Velocity_NED;
               GPS.NED_Vel.Speed(GPSi,1) = Speed;
               GPS.NED_Vel.Grnd_Spd(GPSi,1) = Grnd_Spd;
               GPS.NED_Vel.Heading(GPSi,1) = Heading;
               GPS.NED_Vel.Spd_Accuracy(GPSi,1) = Spd_Accuracy;
               GPS.NED_Vel.Heading_Accuracy(GPSi,1) = Heading_Accuracy;
               GPS.NED_Vel.Flags(GPSi,1) = NED_Vel_Flags;
            else
               disp('Packet composed of incorrect number of bytes');
               break
            end %if
         elseif (FieldInfo(2) == 6) % ECEF Velocity (Earth Centered Earth Fixed)
            if (FieldInfo(1) == 20)
               [Vel_XYZ count] = fread(fid,[3],'float32','ieee-be'); % m/s
               [Vel_Accuracy count] = fread(fid,[1],'float32','ieee-be'); % m/s
               [ECEF_Vel_Flags count] = fread(fid,[1],'uint16','ieee-be');
               GPS.ECEF_Vel.Velocity_XYZ(GPSi,1:3) = Vel_XYZ;
               GPS.ECEF_Vel.Vel_Accuracy(GPSi,1) = Vel_Accuracy;
               GPS.ECEF_Vel.Flags(GPSi,1) = ECEF_Vel_Flags;
            else
               disp('Packet composed of incorrect number of bytes');
               break
            end %if
         elseif (FieldInfo(2) == 7) % Dilution of Precision Data
            if (FieldInfo(1) == 32)
               [DOP_GPHVTNE count] = fread(fid,[7],'float32','ieee-be'); % n/a
               [DOP_Flags count] = fread(fid,[1],'uint16','ieee-be');
               GPS.DOP.Geometric(GPSi,1) = DOP_GPHVTNE(1);
               GPS.DOP.Position(GPSi,1) = DOP_GPHVTNE(2);
               GPS.DOP.Horizontal(GPSi,1) = DOP_GPHVTNE(3);
               GPS.DOP.Vertical(GPSi,1) = DOP_GPHVTNE(4);
               GPS.DOP.Time(GPSi,1) = DOP_GPHVTNE(5);
               GPS.DOP.Northing(GPSi,1) = DOP_GPHVTNE(6);
               GPS.DOP.Easting(GPSi,1) = DOP_GPHVTNE(7);
               GPS.DOP.Flags(GPSi,1) = DOP_Flags;
            else
               disp('Packet composed of incorrect number of bytes');
               break
            end %if
         elseif (FieldInfo(2) == 8) % UTC Time
            if (FieldInfo(1) == 15)
               [UTC_Yr count] = fread(fid,[1],'uint16','ieee-be');
               [UTC_Mo count] = fread(fid,[1],'uint8','ieee-be');
               [UTC_Da count] = fread(fid,[1],'uint8','ieee-be');
               [UTC_Hr count] = fread(fid,[1],'uint8','ieee-be');
               [UTC_Mn count] = fread(fid,[1],'uint8','ieee-be');
               [UTC_Sec count] = fread(fid,[1],'uint8','ieee-be');
               [UTC_mSec count] = fread(fid,[1],'uint32','ieee-be');
               [UTC_Flags count] = fread(fid,[1],'uint16','ieee-be');
               GPS.UTC.Yr(GPSi,1) = UTC_Yr;
               GPS.UTC.Mo(GPSi,1) = UTC_Mo;
               GPS.UTC.Da(GPSi,1) = UTC_Da;
               GPS.UTC.Hr(GPSi,1) = UTC_Hr;
               GPS.UTC.Mn(GPSi,1) = UTC_Mn;
               GPS.UTC.Sec(GPSi,1) = UTC_Sec;
               GPS.UTC.mSec(GPSi,1) = UTC_mSec;
               GPS.UTC.Flags(GPSi,1) = UTC_Flags;
            else
               disp('Packet composed of incorrect number of bytes');
               break
            end %if
         elseif (FieldInfo(2) == 9) % GPS Time
            if (FieldInfo(1) == 14)
               [GPS_TimeOfWeek count] = fread(fid,[1],'float64','ieee-be');
               [GPS_WeekNum count] = fread(fid,[1],'uint16','ieee-be');
               [GPS_Time_Flags count] = fread(fid,[1],'uint16','ieee-be');
               GPS.Time.TimeOfWeek(GPSi,1) = GPS_TimeOfWeek;
               GPS.Time.WeekNum(GPSi,1) = GPS_WeekNum;
               GPS.Time.Flags(GPSi,1) = GPS_Time_Flags;
            else
               disp('Packet composed of incorrect number of bytes');
               break
            end %if
         elseif (FieldInfo(2) == 10) % Clock Information
            if (FieldInfo(1) == 28)
               [GPS_Clock_Bias count] = fread(fid,[1],'float64','ieee-be');
               [GPS_Clock_Drift count] = fread(fid,[1],'float64','ieee-be');
               [GPS_Clock_Accuracy count] = fread(fid,[1],'float64','ieee-be');
               [GPS_Clock_Flags count] = fread(fid,[1],'uint16','ieee-be');
               GPS.Clock.Bias(GPSi,1) = GPS_Clock_Bias; % Seconds
               GPS.Clock.Drift(GPSi,1) = GPS_Clock_Drift; % Seconds/Second
               GPS.Clock.Accuracy(GPSi,1) = GPS_Clock_Accuracy; % Seconds
               GPS.Clock.Flags(GPSi,1) = GPS_Clock_Flags;
            else
               disp('Packet composed of incorrect number of bytes');
               break
            end %if
         elseif (FieldInfo(2) == 11) % GPS Fix
            if (FieldInfo(1) == 8)
               [GPS_Fix_Type count] = fread(fid,[1],'uint8','ieee-be'); % n/a
               [GPS_Fix_nSats count] = fread(fid,[1],'uint8','ieee-be'); % n/a
               [GPS_Fix_Flags1 count] = fread(fid,[1],'uint16','ieee-be'); % n/a
               [GPS_Fix_Flags2 count] = fread(fid,[1],'uint16','ieee-be'); % n/a
               GPS.Fix.Type(GPSi,1) = GPS_Fix_Type;
               GPS.Fix.nSats(GPSi,1) = GPS_Fix_nSats;
               GPS.Fix.Flags1(GPSi,1) = GPS_Fix_Flags1;
               GPS.Fix.Flags2(GPSi,1) = GPS_Fix_Flags2;      
            else
               disp('Packet composed of incorrect number of bytes');
               break
            end %if
         elseif (FieldInfo(2) == 12) % Sat 
            if (FieldInfo(1) == 14)
               [GPS_SatInfo_Channel count] = fread(fid,[1],'uint8','ieee-be'); % n/a
               [GPS_SatInfo_ID count] = fread(fid,[1],'uint8','ieee-be'); % n/a
               [GPS_SatInfo_SigNoiseRat count] = fread(fid,[1],'uint16','ieee-be'); % dBHz
               [GPS_SatInfo_Azimuth count] = fread(fid,[1],'int16','ieee-be'); % Integer degrees
               [GPS_SatInfo_Elevation count] = fread(fid,[1],'int16','ieee-be'); % Integer degrees
               [GPS_SatInfo_SatFlags count] = fread(fid,[1],'uint16','ieee-be');
               [GPS_SatInfo_Flags count] = fread(fid,[1],'uint16','ieee-be');
               GPS.SatInfo.Channel(GPSi,1) = GPS_SatInfo_Channel;
               GPS.SatInfo.ID(GPSi,1) = GPS_SatInfo_ID;
               GPS.SatInfo.SigNoiseRat(GPSi,1) = GPS_SatInfo_SigNoiseRat;
               GPS.SatInfo.Azimuth(GPSi,1) = GPS_SatInfo_Azimuth;
               GPS.SatInfo.Elevation(GPSi,1) = GPS_SatInfo_Elevation;
               GPS.SatInfo.SatFlags(GPSi,1) = GPS_SatInfo_SatFlags;
               GPS.SatInfo.Flags(GPSi,1) = GPS_SatInfo_Flags;
            else
               disp('Packet composed of incorrect number of bytes');
               break
            end %if
         elseif (FieldInfo(2) == 13) % Sat Info
            if (FieldInfo(1) == 7)
               [GPS_HardwareStatus_SensorState count] = fread(fid,[1],'uint8','ieee-be'); % n/a
               [GPS_HardwareStatus_AntennaState count] = fread(fid,[1],'uint8','ieee-be'); % n/a
               [GPS_HardwareStatus_AntennaPower count] = fread(fid,[1],'uint8','ieee-be'); % n/a
               [GPS_HardwareStatus_Flags count] = fread(fid,[1],'uint16','ieee-be'); % n/a
               GPS.HardwareStatus.SensorState(GPSi,1) = GPS_HardwareStatus_SensorState;
               GPS.HardwareStatus.AntennaState(GPSi,1) = GPS_HardwareStatus_AntennaState;
               GPS.HardwareStatus.AntennaPower(GPSi,1) = GPS_HardwareStatus_AntennaPower;
               GPS.HardwareStatus.Flags(GPSi,1) = GPS_HardwareStatus_Flags;
            else
               disp('Packet composed of incorrect number of bytes');
               break
            end %if
         else
            disp('Unrecognized GPS data field present in file')
            if (FieldInfo(1)>0)
               fseek(fid,FieldInfo(1),'cof');
            end %if
            unread_fields = unread_fields + 1;
            break
         end %if
         %% Add the field size to the total byte sum
      else % Should never happen, if it does, you broke it!  Not my fault!
         disp('Something went wrong during AHRS read-in');
         break
      end %if
      %% Add the field size to the total byte sum
      bytesum = bytesum + FieldInfo(1);
   end %while
   %% Read the last two checksum bytes of the packet to advance file stream location.
   %% The Checksum algorithm shown in the manual is NOT Implemented-------------------
   [MSB_LSB count] = fread(fid,[2],'uint8','ieee-be');
end %function