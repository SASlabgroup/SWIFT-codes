################################################################################
# configuration file for:
#  record_and_send_gps.py 
#  record_temperature.py

# 4 digit string for float id
float_id = '0001'        #float id

# 2 digit string for project id
project_name = 'TX'

float_data_dir = '/home/pi/Data/'
burst_interval = 12     #time between calls to record_serial, in minutes
call_interval = 10      #interval between SBD calls, in minutes

GPSfrequency = 4        #sampling rate
GPS_num_samples = GPSfrequency*512  #frequency * 512

Tempfrequency = 1
Temp_num_samples = Tempfrequency*512
bad = 9999

#PayLoadType either 7 or the new type 50
PayLoadType = 7
#PayLoadType = 50

#if set to true than calls are made on the hour when the minute == call_interval
#otherwise calls are made every call_interval
IfHourlyCall = False

#if set to true then calls are made
MakeCall = False
################################################################################
