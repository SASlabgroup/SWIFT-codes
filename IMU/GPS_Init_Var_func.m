function [GPS] = GPS_Init_Var_func(GPS_field_array, GPS, GPSi)
%% This function initializes the variables called for in the variable field array.
%% Field array is a row array populated with the desired field identifiers
%% for the GPS sensor.
  if sum(GPS_field_array == 3) > 0
    GPS.Geodetic_Pos.Lat_Lon(GPSi,1:2) = [NaN NaN];
    GPS.Geodetic_Pos.H_above_ellipsoid(GPSi,1) = NaN;
    GPS.Geodetic_Pos.H_above_MSL(GPSi,1) = NaN;
    GPS.Geodetic_Pos.AccuracyHorz(GPSi,1) = NaN;
    GPS.Geodetic_Pos.AccuracyVert(GPSi,1) = NaN;
    GPS.Geodetic_Pos.Flags(GPSi,1) = NaN;
  end %if
  if sum(GPS_field_array == 4) > 0
    GPS.ECEF_Pos.XYZ(GPSi,1:3) = [NaN NaN NaN];
    GPS.ECEF_Pos.Accuracy(GPSi,1) = NaN;
    GPS.ECEF_Pos.Flags(GPSi,1) = NaN;
  end %if
  if sum(GPS_field_array == 5) > 0
    GPS.NED_Vel.Velocity_NED(GPSi,1:3) = [NaN NaN NaN];
    GPS.NED_Vel.Speed(GPSi,1) = NaN;
    GPS.NED_Vel.Grnd_Spd(GPSi,1) = NaN;
    GPS.NED_Vel.Heading(GPSi,1) = NaN;
    GPS.NED_Vel.Spd_Accuracy(GPSi,1) = NaN;
    GPS.NED_Vel.Heading_Accuracy(GPSi,1) = NaN;
    GPS.NED_Vel.Flags(GPSi,1) = NaN;
  end %if
  if sum(GPS_field_array == 6) > 0
    GPS.ECEF_Vel.Velocity_XYZ(GPSi,1:3) = [NaN NaN NaN];
    GPS.ECEF_Vel.Vel_Accuracy(GPSi,1) = NaN;
    GPS.ECEF_Vel.Flags(GPSi,1) = NaN;
  end %if
  if sum(GPS_field_array == 7) > 0
    GPS.DOP.Geometric(GPSi,1) = NaN;
    GPS.DOP.Position(GPSi,1) = NaN;
    GPS.DOP.Horizontal(GPSi,1) = NaN;
    GPS.DOP.Vertical(GPSi,1) = NaN;
    GPS.DOP.Time(GPSi,1) = NaN;
    GPS.DOP.Northing(GPSi,1) = NaN;
    GPS.DOP.Easting(GPSi,1) = NaN;
    GPS.DOP.Flags(GPSi,1) = NaN;
  end %if
  if sum(GPS_field_array == 8) > 0
    GPS.UTC.Yr(GPSi,1) = NaN;
    GPS.UTC.Mo(GPSi,1) = NaN;
    GPS.UTC.Da(GPSi,1) = NaN;
    GPS.UTC.Hr(GPSi,1) = NaN;
    GPS.UTC.Mn(GPSi,1) = NaN;
    GPS.UTC.Sec(GPSi,1) = NaN;
    GPS.UTC.mSec(GPSi,1) = NaN;
    GPS.UTC.Flags(GPSi,1) = NaN;
  end %if
  if sum(GPS_field_array == 9) > 0
    GPS.Time.TimeOfWeek(GPSi,1) = NaN;
    GPS.Time.WeekNum(GPSi,1) = NaN;
    GPS.Time.Flags(GPSi,1) = NaN;
  end %if
  if sum(GPS_field_array == 10) > 0
    GPS.Clock.Bias(GPSi,1) = NaN;
    GPS.Clock.Drift(GPSi,1) = NaN;
    GPS.Clock.Accuracy(GPSi,1) = NaN;
    GPS.Clock.Flags(GPSi,1) = NaN;
  end %if
  if sum(GPS_field_array == 11) > 0
    GPS.Fix.Type(GPSi,1) = NaN;
    GPS.Fix.nSats(GPSi,1) = NaN;
    GPS.Fix.Flags1(GPSi,1) = NaN;
    GPS.Fix.Flags2(GPSi,1) = NaN;
  end %if
  if sum(GPS_field_array == 12) > 0
    GPS.SatInfo.Channel(GPSi,1) = NaN;
    GPS.SatInfo.ID(GPSi,1) = NaN;
    GPS.SatInfo.SigNoiseRat(GPSi,1) = NaN;
    GPS.SatInfo.Azimuth(GPSi,1) = NaN;
    GPS.SatInfo.Elevation(GPSi,1) = NaN;
    GPS.SatInfo.SatFlags(GPSi,1) = NaN;
    GPS.SatInfo.Flags(GPSi,1) = NaN;
  end %if
  if sum(GPS_field_array == 13) > 0
    GPS.HardwareStatus.SensorState(GPSi,1) = NaN;
    GPS.HardwareStatus.AntennaState(GPSi,1) = NaN;
    GPS.HardwareStatus.AntennaPower(GPSi,1) = NaN;
    GPS.HardwareStatus.Flags(GPSi,1) = NaN;
  end %if
end %function