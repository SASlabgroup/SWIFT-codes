#! /usr/bin/python2.7
#
# This program contains all necessary functions used in record_send_gps.py
# in order to perform fully.
#
#-------------------------------------------------------------------------

#standard imports
import os
import numpy as np
from logging import *
import datetime
from datetime import datetime
import time
import pynmea2
import glob
import subprocess

##########################################################################
#----------------------------------------------------------------------------------------
# Names files created with current date and time and return it
#----------------------------------------------------------------------------------------
def currentTimeString(): 	
    # Name the file according to the current time and date  
    dataFile = datetime.strftime(datetime.now(), "%Y%m%d%H%M%S")
    return dataFile

#----------------------------------------------------------------------------------------
# Gets the latest temp and volt files created and return it
#----------------------------------------------------------------------------------------
def getLatestFile(name,dataDir,floatID,projectName):
    file = os.path.join(dataDir + "microswift_" + floatID + "_" + projectName + name)
    meanFile = glob.glob(file)
    latestFile = max(meanFile, key=os.path.getctime)
    return latestFile

#----------------------------------------------------------------------------------------
# Calculate the elapsed time and return it
#----------------------------------------------------------------------------------------
def getElapsedTime(tStart,elapsed):
    tNow = time.time()
    elapse = tNow-tStart
    elapsedTime = elapsed+elapse
    return elapsedTime

#----------------------------------------------------------------------------------------
# gets the mean data from latest file and return it. If the time on the file is 3 hours
# or more difference than the current time, then the value is converted to a
# bad value 999.0
#----------------------------------------------------------------------------------------
def getMean(data,maxHours,badValue):
    mean = badValue
    now = datetime.now()
    yearNow = now.year
    monthNow = now.month
    dayNow = now.day
    hourNow = now.hour
                    
    yearDiff = abs(int(data[0]) - yearNow)
    monthDiff = abs(int(data[1]) - monthNow)
    dayDiff = abs(int(data[2]) - dayNow)
    hourDiff = abs(int(data[3]) - hourNow)
    print (hourNow)
    print (data[3])
    #give correct value if time is correct, otherwise give bad value 
    if (yearDiff == 0 and monthDiff == 0 and dayDiff == 0):
        print ("time is correct")
        if (hourDiff < maxHours or hourDiff == 0): 
            print (hourDiff)
            print (maxHours)
            mean = data[6]
            mean = mean.rstrip();
            print (mean)
            
    return mean

#----------------------------------------------------------------------------------------
# gets the mean u,v,z means. It account for bad values (999.0) and 'nan' values.
# If value is 'nan', it is turned into a bad value and then returned.
#----------------------------------------------------------------------------------------
def getuvzMean(badValue,resultType):
    mean = badValue     #set values to 999 initially and fill if valid values  
    nan = float('nan')  #account for nan values
    idgood = np.where(resultType != badValue)[0]
    idgoodnan = np.where(resultType != nan)[0]
            
    if(len(idgood) > 0):
        mean = np.mean(resultType[idgood])
    elif(len(idgoodnan) > 0):
        mean = np.mean(resultType[idgoodnan])
        
    return mean

#----------------------------------------------------------------------------------------
# parse out the gpgga sentences collected form the gps and return the parsed data
# fields in GPGGA from pynmea2:
#       ('Timestamp', 'timestamp', timestamp),
#       ('Latitude', 'lat'),
#       ('Latitude Direction', 'lat_dir'),
#       ('Longitude', 'lon'),
#       ('Longitude Direction', 'lon_dir'),
#       ('GPS Quality Indicator', 'gps_qual', int),
#       ('Number of Satellites in use', 'num_sats'),
#       ('Horizontal Dilution of Precision', 'horizontal_dil'),
#       ('Antenna Alt above sea level (mean)', 'altitude', float),
#       ('Units of altitude (meters)', 'altitude_units'),
#       ('Geoidal Separation', 'geo_sep'),
#       ('Units of Geoidal Separation (meters)', 'geo_sep_units'),
#       ('Age of Differential GPS Data (secs)', 'age_gps_data'),
#       ('Differential Reference Station ID', 'ref_station_id'))
#----------------------------------------------------------------------------------------
def parse_nmea_gpgga(gpgga_stc,
                     eventLog,
                     elapsedTime):

    eventLog.info('[%.3f] - Parse nmea GGA' % elapsedTime)
    
    msg = pynmea2.parse(gpgga_stc, check=True)  #parse gpgga sentence
    print ('[%.3f] - GGA: %s' % (elapsedTime,msg))

    latlon = str(msg.latitude) + ', ' + str(msg.longitude)  #save lat and lon as a list
    eventLog.info('[%.3f] - latlon = %s' % (elapsedTime,latlon))
    
    lat = msg.latitude
    lat_dir = msg.lat_dir
    lon = msg.longitude
    
    lon_dir = msg.lon_dir
    date = msg.timestamp
    num_sats = msg.num_sats
    gps_qual = msg.gps_qual
    altitude = msg.altitude 
    altitude_units = msg.altitude_units
    
    parse_data = {'date':date,'lat':lat,'lat_dir':lat_dir,'lon':lon,'lon_dir':lon_dir,
                  'num_sats':num_sats,'gps_qual':gps_qual,
                   'altitude':altitude,'altitude_units':altitude_units}
    eventLog.info('[%.3f] - parse_data: %s' % (elapsedTime, str(parse_data)))
    
    return parse_data  

#----------------------------------------------------------------------------------------
# parse out the gpvtg sentences collected form the gps and return the parsed data
#   Track Made Good and Ground Speed fields:
#       ("True Track made good", "true_track", float),
#       ("True Track made good symbol", "true_track_sym"),
#       ("Magnetic Track made good", "mag_track", Decimal),
#       ("Magnetic Track symbol", "mag_track_sym"),
#       ("Speed over ground knots", "spd_over_grnd_kts", Decimal),
#       ("Speed over ground symbol", "spd_over_grnd_kts_sym"),
#       ("Speed over ground kmph", "spd_over_grnd_kmph", float),
#       ("Speed over ground kmph symbol", "spd_over_grnd_kmph_sym"),
#       ("FAA mode indicator", "faa_mode"))
#----------------------------------------------------------------------------------------
def parse_nmea_gpvtg(gpvtg_stc,
                     eventLog,
                     elapsedTime):

    eventLog.info('[%.3f] - Parse nmea VTG' % elapsedTime)

    msg = pynmea2.parse(gpvtg_stc, check=True)  #parse gpvtg sentence
    print ('[%.3f] - VTG: %s' % (elapsedTime,msg))

    speed_over_grnd_kmph = msg.spd_over_grnd_kmph
    print ('[%.3f] - Speed_over_grnd_kmph: %s' % (elapsedTime, speed_over_grnd_kmph))
    true_track = msg.true_track
    print ('[%.3f] - True_track: %s' % (elapsedTime,true_track))
    mag_track=msg.mag_track
    print ('[%.3f] - Mag_track: %s' % (elapsedTime,mag_track))

    u_vel = speed_over_grnd_kmph*np.cos(true_track)
    v_vel = speed_over_grnd_kmph*np.sin(true_track)
    
    parse_data = {'speed':speed_over_grnd_kmph,'true_track':true_track,
                  'mag_track':mag_track,'u_vel':u_vel,'v_vel':v_vel}
    
    eventLog.info('[%.3f] - Parse_data: %s' % (elapsedTime, str(parse_data)))
    
    return parse_data

#---------------------------------------------------------------------------------------
# get the average temperaure over the span of the burse interval and save to a file
# if temp is valid, otherwise save as 999.0
#---------------------------------------------------------------------------------------
def GetMeanTemp(maxHours,
                badValue,
                floatID,
                projectName,
                dataDir,
                eventLog,
                elapsedTime):

    # reads in mean temperature data 
    eventLog.info('[%.3f] - Get mean temp' % elapsedTime)

    #meanTemp = ('%.3f ' % float(badValue))
    try:
        txName = ("_TempMean_New.dat")
        latestFile = getLatestFile(txName,dataDir,floatID,projectName)

    except:
        print ('[%.3f] - No mean temp file found' % elapsedTime)
    
    eventLog.info('[%.3f] - Mean temp file to open: %s' % (elapsedTime, latestFile))

    if (os.path.exists(latestFile)):
        fid = open(latestFile,'r')
        TempLine = fid.readline()
        TempData = TempLine.split(',')
        
        meanTemp = getMean(TempData,maxHours,badValue)
        
    return meanTemp
#-----------------------------------------------------------------------------------
# get the average voltage over the span of the burse interval and save to a file
# if voltage is valid, otherwise save as 999.0
#-----------------------------------------------------------------------------------
def GetMeanVolt(maxHours,
                badValue,
                floatID,
                projectName,
                dataDir,
                eventLog,
                elapsedTime):
    
    # reads in mean temperature data 
    eventLog.info('[%.3f] - Get mean volt' % elapsedTime)

    #meanVolt = ('%.3f ' % float(badValue))
    try:
        txName = ("_VoltMean_New.dat")
        latestFile = getLatestFile(txName,dataDir,floatID,projectName)

    except:
        print ('[%.3f] - No mean volt file found' % elapsedTime)
 
    eventLog.info('[%.3f] - Mean volt to read: %s' % (elapsedTime, latestFile))

    if (os.path.exists(latestFile)):
        fid = open(latestFile,'r')
        VoltLine = fid.readline()
        VoltData = VoltLine.split(',')
        
        meanVolt = getMean(VoltData,maxHours,badValue)

    return meanVolt

#-----------------------------------------------------------------------------------
#-----------------------------------------------------------------------------------
def myRound2(value, N):
    value = np.asarray(value).copy()
    zero_mask = (value == 0)
    value[zero_mask] = 1.0
    sign_mask = (value < 0)
    value[sign_mask] *= -1
    exponent = np.ceil(np.log10(value))
    result = 10**exponent*np.round(value*10**(-exponent), N)
    #result[sign_mask] *= -1
    result[zero_mask] = 0.0
    return result

#-----------------------------------------------------------------------------------
#Log time from GPS to a file and then set the raspberry pi time from the file
#file with time is located in data dir 
#calls a bashsript located in utils directory that sets the time to the pi 
#-----------------------------------------------------------------------------------
def setPiTime(timePort):
    print ("open port?")
    #timePort.open()
    print ("going into loop")
    while True:
        line = timePort.readline()
        print (line)
	if "GPRMC" in line:
            splitLine = line.split(',')
            UTCTime = splitLine[1]
            date = splitLine[9]
            
            splitTime = list(UTCTime)
            hour = (splitTime[0] + splitTime[1])
            minute = splitTime[2] + splitTime[3]
            sec = splitTime[4] + splitTime[5]
            second = (int(sec) + 2)
            print (second)
            dateSplit = list(date)
            day = dateSplit[0] + dateSplit[1]
            month = dateSplit[2] + dateSplit[3]
            year = dateSplit[4] + dateSplit[5]
            
            if (hour >= 7 and hour >= 19 or hour == 0):
                hour = int(hour) - 7
            elif (hour >= 20 and hour <= 24):
                hour = int(hour) - 19
            else:
                hour = int(hour) + 5
                
            hour = format(hour, "02")
            second = format(second, "02")
            
            file = open('/home/pi/microSWIFT/data/' + 'setTime', 'w')
            file.write(str(month) + str(day) + str(hour) + str(minute) + str(second) + "20" + str(year))
            file.flush()
            subprocess.call('/home/pi/microSWIFT/utils/setTime')
            file.close()
            break

    
    
