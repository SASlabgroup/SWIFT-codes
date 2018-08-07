function [AHRS] = AHRS_Init_Var_func(AHRS_field_array, AHRS, AHRSi)
%% This function initializes the variables called for in the variable field array.
%% Field array is a row array populated with the desired field identifiers
%% for the AHRS sensor.
  if sum(AHRS_field_array == 1) > 0
    AHRS.Raw_Accel(AHRSi,1:3) = [NaN,NaN,NaN];
  end %if
  if sum(AHRS_field_array == 2) > 0
    AHRS.Raw_Gyro(AHRSi,1:3) = [NaN,NaN,NaN];
  end %if
  if sum(AHRS_field_array == 3) > 0
    AHRS.Raw_Mag(AHRSi,1:3) = [NaN,NaN,NaN];
  end %if
  if sum(AHRS_field_array == 4) > 0
    AHRS.Accel(AHRSi,1:3) = [NaN,NaN,NaN];
  end %if
  if sum(AHRS_field_array == 5) > 0
    AHRS.Gyro(AHRSi,1:3) = [NaN,NaN,NaN];
  end %if
  if sum(AHRS_field_array == 6) > 0
    AHRS.Mag(AHRSi,1:3) = [NaN,NaN,NaN];
  end %if
  if sum(AHRS_field_array == 7) > 0
    AHRS.dTheta(AHRSi,1:3) = [NaN,NaN,NaN];
  end %if
  if sum(AHRS_field_array == 8) > 0
    AHRS.Vel(AHRSi,1:3) = [NaN,NaN,NaN];
  end %if
  if sum(AHRS_field_array == 9) > 0
    AHRS.Orient_Matrix(1:3,1:3,AHRSi) = [NaN,NaN,NaN;NaN,NaN,NaN;NaN,NaN,NaN];
  end %if
  if sum(AHRS_field_array == 10) > 0
    AHRS.Quat(AHRSi,1:4) = [NaN,NaN,NaN,NaN];
  end %if
  if sum(AHRS_field_array == 11) > 0
    AHRS.dOrient_Matrix(1:3,1:3,AHRSi) = [NaN,NaN,NaN;NaN,NaN,NaN;NaN,NaN,NaN];
  end %if
  if sum(AHRS_field_array == 12) > 0
    AHRS.Euler_RPY(AHRSi,1:3) = [NaN,NaN,NaN];
  end %if
  if sum(AHRS_field_array == 14) > 0
    AHRS.Timestamp(AHRSi,1) = NaN;
    AHRS.Timestamp_sec(AHRSi,1) = NaN;
  end %if
  if sum(AHRS_field_array == 15) > 0
    AHRS.GPS_Stopwatch.Flags(AHRSi,1) = NaN;
    AHRS.GPS_Stopwatch.Seconds(AHRSi,1) = NaN;
    AHRS.GPS_Stopwatch.Nanoseconds(AHRSi,1) = NaN;
  end %if
  if sum(AHRS_field_array == 16) > 0
    AHRS.North_vec(AHRSi,1:3) = NaN;
  end %if
  if sum(AHRS_field_array == 17) > 0
    AHRS.Up_vec(AHRSi,1:3) = NaN;
  end %if
  if sum(AHRS_field_array == 18) > 0
    AHRS.GPS_Time.TimeOfWeek(AHRSi,1) = NaN;
    AHRS.GPS_Time.WeekNum(AHRSi,1) = NaN;
    AHRS.GPS_Time.Flags(AHRSi,1) = NaN;
  end %if
  end %function