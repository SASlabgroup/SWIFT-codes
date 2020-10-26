#! /usr/bin/python3
#
# This program records GPS data at a burst interval for a specified amount
# of time. It then parses out the necessary data and sends that data to be
# converted into binary form to send out through iridium 
#
# Also takes Temp and volt data that are being logged sepretly and
# includes those data into the message sent to be converted
#---------------------------------------------------------------------------
#standard imports
import serial, io, sys, os
import numpy as np
from struct import *
from logging import *
import logging
import datetime
from datetime import datetime
import time
import RPi.GPIO as GPIO
import pynmea2
import glob
import struct
from time import sleep

#my imports
import send_sbd_binary_data
from rec_send_funcs import *
import GPSwavesC
from config2 import Config

#set gpio
GPIO.setmode(GPIO.BCM)
GPIO.setwarnings(False)
##########################################################################
#Load config file 
configDat =  sys.argv[1]
configFilename = configDat #Load config file/parameters needed
config = Config() # Create object and load file
ok = config.loadFile( configFilename )
if( not ok ):
	sys.exit(0)

#system parameters
floatID = config.getString('System', 'floatID') 
projectName = config.getString('System', 'projectName')
payLoadType = config.getInt('System', 'payLoadType')
badValue = config.getInt('System', 'badValue')
numCoef = config.getInt('System', 'numCoef')
Port = config.getInt('System', 'port')
payloadVersion = config.getInt('System', 'payloadVersion')
#Log parameters
dataDir = config.getString('LogLocation', 'dataDir')
logDir = config.getString('LogLocation', 'logDir')

#GPS parameters 
gpsPort = config.getString('GPS', 'port')
baud = config.getInt('GPS', 'baud')
startBaud = config.getInt('GPS', 'startBaud')
GPSfrequency = config.getInt('GPS', 'GPSfrequency')
numSamplesConst = config.getInt('System', 'numSamplesConst')
gpsNumSamples = GPSfrequency*numSamplesConst
numLines = config.getInt('GPS', 'numLines')
gpsGpio = config.getInt('GPS', 'gpsGpio')
getFix = config.getInt('GPS', 'getFix') # min before rec gps

#temp and volt params 
maxHoursTemp = config.getInt('Temp', 'maxHours')
maxHoursVolt = config.getInt('Voltage', 'maxHours')

#Iridium parameters
modemPort = config.getString('Iridium', 'port')
modemBaud = config.getInt('Iridium', 'baud')
modemGpio = config.getInt('Iridium', 'iridiumGpio')
formatType = config.getInt('Iridium', 'formatType')
callInt = config.getInt('Iridium', 'callInt')
burst_num = config.getInt('Iridium', 'burstNum')


#hard coded parameters to change 
IfHourlyCall = config.getString('Iridium', 'IfHourlyCall')
IfHourlyCall = eval(IfHourlyCall) #boolean
MakeCall = config.getString('Iridium', 'MakeCall') 
MakeCall = eval(MakeCall) #boolean

#create idStr for naming convention 
idStr = floatID[2:4]
decInt = int(idStr,16)
decStr = str((decInt)).zfill(2)

##LOGGING
dataFile = str(currentTimeString()) #file name
#EVENT Log
LOG_FORMAT = ('[%(levelname)s] %(message)s')
LOG_LEVEL = logging.INFO 
EVENT_LOG_FILE = (logDir + '/' + 'microSWIFTEvent' + dataFile + '.log')
eventLog = logging.getLogger("Event")
eventLog.setLevel(LOG_LEVEL)
eventLogFileHandler = FileHandler(EVENT_LOG_FILE)
eventLogFileHandler.setLevel(LOG_LEVEL)
eventLogFileHandler.setFormatter(Formatter(LOG_FORMAT))
eventLog.addHandler(eventLogFileHandler)

#time keeping
tMain = time.time()
nowStart = datetime.utcnow()
########################################################################
#initialize gpio pins
GPIO.setup(modemGpio,GPIO.OUT)
GPIO.setup(gpsGpio,GPIO.OUT)

#-----------------------------------------------------------------------
#set time initially
#-----------------------------------------------------------------------
GPIO.output(gpsGpio,GPIO.HIGH)
print ("getting a fix")
time.sleep(30)
success = True

timePort = serial.Serial(gpsPort, startBaud, timeout=1)
read = timePort.readline()
print ("THIS IS TIMEPORT", read)
if not "GP" in read:
    print ("No NMEA")
    timePort.close()
    success = False

if (success == False):
    timePort = serial.Serial(gpsPort,baud,timeout=1)
    if (timePort.isOpen() == False):
        timePort.open()
    print ("baud")
    success = True
	
if (success == True):
    print ("Going into set time")
    setPiTime(timePort)
#----------------------------------------------------------------------
#turn off gps and iridium modem 
turnOff = 0
if turnOff == 0:
    #turn modem and GPS off untill needed 
    eventLog.info('Turn iridium modem and GPS off until ready to use')
    print ('Turn iridium modem and GPS off until ready to use')
    GPIO.output(modemGpio,GPIO.LOW)
    GPIO.output(gpsGpio,GPIO.LOW)
    turnOff = 1

# Open serial connection and new file for writing.
# Grab incoming lines and write to file.
def record_serial(fname,
                  badValue,
                  gpsNumSamples,
                  dataDir,
                  numlines,
                  gpsPort,
                  baud,
                  eventLog,
                  elapsed,
                  gpsGpio,
                  startBaud):
    
    tStart = time.time()
    global burst_num
    
    burst_num += 1
    eventLog.info('[%.3f] - Record_serial' % elapsed)
    print ('[%.3f] - Record_serial' % elapsed)
    eventLog.info('[%.3f] - Burst number: %s' %  (elapsed,str(burst_num)))
    print ('[%.3f] - Burst number: %s' %  (elapsed,str(burst_num)))

    u = np.empty(gpsNumSamples)
    u.fill(badValue)
    v = np.empty(gpsNumSamples)
    v.fill(badValue)
    z = np.empty(gpsNumSamples)
    z.fill(badValue)
    lat = np.empty(gpsNumSamples)
    lat.fill(badValue)
    lon = np.empty(gpsNumSamples)
    lon.fill(badValue)

    eventLog.info('[%.3f] - Create empty array for u,v,z,lat,lon,temp,volt with number of samples' %  elapsed)
    
    #calculate elapsed time here
    elapsedTime = getElapsedTime(tStart,elapsed)
    setTimeAtEnd = False
    try:
        
        with serial.Serial('/dev/ttyS0',115200,timeout=.25) as pt, open(fname, 'a') as gpsOut: 
            ser = io.TextIOWrapper(io.BufferedRWPair(pt,pt,1), encoding='ascii',
                    errors='ignore', newline='\r', line_buffering=True)
            
            eventLog.info('[%.3f] - Open GPS port and file name: %s, %s' %  (elapsed, gpsPort,fname))

            #test for incoming data over serial port
            for i in range(1):
                newline = ser.readline()
                print('[%.3f] - New GPS output: %s' % (elapsedTime,newline))
                eventLog.info('[%.3f] - New GPS output' % elapsedTime)
                #sleep(1)   

            gpgga_stc = ''
            gpvtg_stc = ''
            ipos = 0
            ivel = 0

            if newline != '':
            #while loop record n seconds of serial data
                isample = 0
                while ((ipos < gpsNumSamples or ivel < gpsNumSamples) and
                      (ivel < (gpsNumSamples +10) and ipos< (gpsNumSamples+10))):
                    # calculate elapsed time here
                    elapsedTime = getElapsedTime(tStart,elapsed)
                    
                    # get new line from gps and write to file 
                    newline = ser.readline()
                    gpsOut.write(newline)    
                    gpsOut.flush()           
                    
                    if "GPGGA" in newline:
                        gpgga_stc = newline   #grab gpgga sentence to return
                        parse_data_pos = parse_nmea_gpgga(gpgga_stc,eventLog,elapsedTime)
                        eventLog.info('parse_nmea %s',str(parse_data_pos));
                        if ipos < gpsNumSamples:
                            z[ipos] = parse_data_pos['altitude']
                            print ('[%.3f] - z[ipos]: %s' % (elapsedTime, z[ipos]))
                            lat[ipos] = parse_data_pos['lat']
                            print ('[%.3f] - lat[ipos]: %s' % (elapsedTime, lat[ipos]))
                            lon[ipos] = parse_data_pos['lon']
                            print ('[%.3f] - lon[ipos]: %s' % (elapsedTime, lon[ipos]))
                        ipos = ipos + 1
              
                    if "GPVTG" in newline:
                        gpvtg_stc = newline   #grab gpvtg sentence
                        parse_data_vel = parse_nmea_gpvtg(gpvtg_stc,eventLog,elapsedTime)
                        eventLog.info('parse_nmea %s',str(parse_data_vel));
                        if ivel < gpsNumSamples:
                            u[ivel] = parse_data_vel['u_vel']
                            print ('[%.3f] - u[ivel]: %s' % (elapsedTime, u[ivel]))
                            v[ivel] = parse_data_vel['v_vel']
                        print ('[%.3f] - v[ivel]: %s' % (elapsedTime,v[ivel]))
                        ivel = ivel + 1
                    #isample = isample + 1
                    #print('[%.3f] - isample:%d,ivel:%d,ipos:%d' %(elapsedTime,isample,ivel,ipos))
                    #eventLog.info('[%.3f] - isample:%d,ivel:%d,ipos:%d' %(elapsedTime,isample,ivel,ipos))
                    	if (ivel > gpsNumSamples) and (setTimeAtEnd == False): 
				if ("GPRMC" in newline): 
                    			splitLine = newline.split(',')
                    			UTCTime = splitLine[1]
                    			date = splitLine[9]
                        
                    			splitTime = list(UTCTime)
                   			hour = (splitTime[0] + splitTime[1])
                    			minute = splitTime[2] + splitTime[3]
                    			sec = splitTime[4] + splitTime[5]
                    			second = (int(sec) + 2)
                        
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
                        
                    			timeStr = (year,month,day,hour,minute,sec)
                    			subprocess.call(['/home/pi/microSWIFT/utils/setTimeAgain'] + [str(n) for n in timeStr])
                    			setTimeAtEnd = True
		    isample = isample + 1

            else:
                print("[%.3f] - No serial data" % elapsedTime)
                eventLog.info('[%.3f] - No serial data' % elapsedTime)
                
        print('IN SERIAL:',(elapsedTime,u,v,z,lat,lon))
        return u,v,z,lat,lon

    except Exception as e1:
        print('[%.3f] - Error: %s' % (elapsedTime,str(e1 )))
        eventLog.error('[%.3f] - Error: %s' % (elapsedTime,str(e1 )))
        return u,v,z,lat,lon
    
#--------------------------------------------------------------------------------------------
#MAIN 
#--------------------------------------------------------------------------------------------
def main():
    #timePort = serial.Serial(gpsPort, startBaud, timeout=1)

    #setPiTime(timePort)
    
    #time keeping 
    tStart = time.time()
    elapsed = tStart - tMain
    
    #set values 
    u = np.empty(gpsNumSamples)
    v = np.empty(gpsNumSamples)
    z = np.empty(gpsNumSamples)
    lat = np.empty(gpsNumSamples)
    lon = np.empty(gpsNumSamples)
    temp = np.empty(gpsNumSamples)
    volt = np.empty(gpsNumSamples)

    WaveSpectra_Energy = np.array(numCoef) #,dtype='int64')
    WaveSpectra_Freq = np.array(numCoef) #,dtype='int64')
    WaveSpectra_a1 = np.array(numCoef) #,dtype='int64')
    WaveSpectra_b1 = np.array(numCoef) #,dtype='int64')
    WaveSpectra_a2 = np.array(numCoef) #,dtype='int64')
    WaveSpectra_b2 = np.array(numCoef) #,dtype='int64')
    
    burstInt = config.getInt('Iridium', 'burstInt')

    TimeBetweenBurst_Call = (burstInt - callInt)
    print('[%.3f] - Time between burst and call: %f' % (elapsed,TimeBetweenBurst_Call))
    eventLog.info('[%.3f] - Time between burst and call: %f' % (elapsed,TimeBetweenBurst_Call))
    
    if(TimeBetweenBurst_Call < 0):
        print('[%.3f] - Error callInt larger than burst interval' % elasped)
        eventLog.error('[%.3f] - Error - callInt larger than burst interval' % elasped)
        
    gpsOn = False        #GPS is off
    recordGps = False    #don't start recording
    iridiumCall = False  #dont send over iridium
    doneSampling = False #GPS sampling
    
    while True:
            
        tNow = time.time()
        elapsedTime = tNow-tStart
        now = datetime.utcnow()
        
        #make SBD call at call interval as long as there has been at least one burst
        print('[%.3f] - systime min= %d' % (elapsedTime,now.minute))
        print('[%.3f] - call interval= %d'% (elapsedTime,callInt))
        print('[%.3f] - burst interval = %d' % (elapsedTime,burstInt))
        print('[%.3f] - systime sec= %d'% (elapsedTime,now.second))

        #check if at every call interval or hourly at callInt
        HowManyBurstsThisHour = now.minute // burstInt
        
        MinuteWantForCall = (callInt*(HowManyBurstsThisHour+1) + HowManyBurstsThisHour*TimeBetweenBurst_Call)
        
        print('[%.3f] - Burst this hour: %d' % (elapsedTime, HowManyBurstsThisHour))
        print('[%.3f] - Minute need for call: %d' % (elapsedTime, MinuteWantForCall))
        print ("[%.3f] - Call hourly: %s" % (elapsedTime, IfHourlyCall))
        print ("[%.3f] - Time(min): %d" % (elapsedTime, now.minute))
        print ("[%.3f] - Burst number: %d" % (elapsedTime, burst_num))
        print ("[%.3f] - Call interval: %d" % (elapsedTime,callInt))
        gpsOnTime = (MinuteWantForCall-1)
        print ("gpsOnTime = ", gpsOnTime)
        
        # turn on GPS specified number of min before the time to start burst interval in order to get
        # a fix before recording data. Can't currently be in a burst and this will only happen if
        # burst is not hourly
        #If call is only hourly, GPS will turn on specifiec min(getFix) before the hour starts
        # Can't currently be in a burst as well.
        # 1) Call is not hourly, at any interval, recording at 8 min interval
        # 2) Call is hourly, at the top of the hour and reording for more than 8 min
        # 3) Call is hourly, at any interval, recording at 8 min interval
        if (gpsOn == False):
            if ( (IfHourlyCall == False and now.minute % gpsOnTime == 0 and numSamplesConst == 360) or
                 (IfHourlyCall == True  and now.minute == 57 and numSamplesConst == 360) or
                 (IfHourlyCall == True and now.minute == 57 and numSamplesConst > 360)):

                GPIO.output(gpsGpio,GPIO.LOW)
                eventLog.info('[%.3f] - Turn GPS off' % elapsedTime)
                print ('[%.3f] - Turn GPS off' % elapsedTime)
                doneGPS = False
                
                time.sleep(5)
                GPIO.output(gpsGpio,GPIO.HIGH)
                eventLog.info('[%.3f] - Turn GPS on' % elapsedTime)
                print ('[%.3f] - Turn GPS on' % elapsedTime)
                    
                bootPort = serial.Serial(gpsPort, startBaud, timeout=1)

                time.sleep(5)
                bootPort.write('$PMTK251,115200*1F\r\n'.encode())
                eventLog.info('[%.3f] - Set GPS to 115200 baud' % elapsedTime)
                print ('[%.3f] - Set GPS to 115200 baud' % elapsedTime)

                bootPort.flush()

                time.sleep(5)

                wantedPort = serial.Serial(gpsPort, baud, timeout=1)
                wantedPort.write('$PMTK220,250*29\r\n'.encode())
                eventLog.info('[%.3f] - Set sampling rate' % elapsedTime)
                
                print ('[%.3f] - Set sampling rate' % elapsedTime)
                data = wantedPort.readline()
                print ('[%.3f] - Serial output: %s' % (elapsedTime,data))
                eventLog.info('[%.3f] - Serial output: %s' % (elapsedTime,data))

                recordGps = True  #record GPS next 
                gpsOn = True      #gps is on
                doneGPS = True    #done turning on GPS
                
        #run record_serial function over burst interval recording num_samples and create new timestamped file with fname
        #burst int and time now equals, in a burst int and the recordGps is true
        if (recordGps == True and doneGPS == True):
            if ( (IfHourlyCall == False and now.minute % burstInt == 0 and numSamplesConst == 360) or
                 (IfHourlyCall == True and now.minute % burstInt == 0 and numSamplesConst == 360) or
                 (IfHourlyCall == True and now.minute % burstInt == 0 and numSamplesConst > 360) ):
                
                doneSampling = False 
                print('[%.3f] - Prepping to read GPS lines' % elapsedTime)
                # save lines with position and velocity'
                gdname = now.strftime('%d%b%Y')
                gtname = now.strftime('%H:%M:%S') 
                fname = (dataDir + floatID + '_GPS_' + gdname + '_' + gtname +'UTC_burst_' + str(burstInt) + '.dat')
            
                eventLog.info('[%.3f] - GPS file: %s' % (elapsedTime, fname))
                eventLog.info('[%.3f] - Beginning to record serial' % elapsedTime)
                u,v,z,lat,lon= record_serial(fname,
                                             badValue,
                                             gpsNumSamples,
                                             dataDir,
                                             numLines,
                                             gpsPort,
                                             baud,
                                             eventLog,
                                             elapsedTime,
                                             gpsGpio,
                                             startBaud)
                print('[%.3f] - In loop , u=%s, v=%s, z=%s' % (elapsedTime,u,v,z)) 
                eventLog.info('[%.3f] - In loop , u=%s, v=%s, z=%s' % (elapsedTime,u,v,z))
                
                burstInt = config.getInt('Iridium', 'burstInt')
    
                if (IfHourlyCall == True):
                    GPIO.output(gpsGpio,GPIO.LOW)
                    eventLog.info('[%.3f] - Turn GPS off' % elapsedTime)
                    print ('[%.3f] - Turn GPS off' % elapsedTime)
                    iridiumCall = True
                    gpsOn = False 
                    recordGps = False
                else: 
                    gpsOn = True
                    recordGps = True
                    iridiumCall = True
                    
                doneSampling = True
        # Always need to be done with GPS burst before sending to Iridium and burst number
        # needs to be greater than 0
        if (burst_num > 0 and iridiumCall == True and doneSampling == True):
            # at any interval
            # at top of hour but for extended burst int 
            # at top of hour but for reg burst int
            if ( (IfHourlyCall == True and now.minute == MinuteWantForCall and numSamplesConst == 360) or
                 (IfHourlyCall == False and now.minute == MinuteWantForCall and numSamplesConst == 360) or
                 (IfHourlyCall == True and now.minute == MinuteWantForCall and numSamplesConst > 360) ):
                
                doneIridium = False 
 
                if (IfHourlyCall == True):
                    iridiumCall = False

                eventLog.info('[%.3f] - Condition met to get GPS data' % elapsedTime)
    
                GPS_waves_results = GPSwavesC.main_GPSwaves(gpsNumSamples,
                                u,v,z,GPSfrequency)
            
                print('[%.3f] - GPS_waves_results: %s' % (elapsedTime, GPS_waves_results))
                eventLog.info('[%.3f] - GPS_waves_results: %s' % (elapsedTime, GPS_waves_results))
            
                #TO ACTUALLY RUN
                SigwaveHeight = GPS_waves_results[0]
                print ('[%.3f] WAVEHEIGHT: %f'% (elapsedTime,SigwaveHeight))
                
                Peakwave_Period = GPS_waves_results[1]
                Peakwave_dirT = GPS_waves_results[2]

                WaveSpectra_Energy = np.squeeze(GPS_waves_results[3])
                WaveSpectra_Energy = np.where(WaveSpectra_Energy>=18446744073709551615, 999.00000, WaveSpectra_Energy)
                
                WaveSpectra_Freq = np.squeeze(GPS_waves_results[4])
                WaveSpectra_Freq = np.where(WaveSpectra_Freq>=18446744073709551615, 999.00000, WaveSpectra_Freq)

                WaveSpectra_a1 = np.squeeze(GPS_waves_results[5])
                WaveSpectra_a1 = np.where(WaveSpectra_a1>=18446744073709551615, 999.00000, WaveSpectra_a1)
                
                WaveSpectra_b1 = np.squeeze(GPS_waves_results[6])
                WaveSpectra_b1 = np.where(WaveSpectra_b1>=18446744073709551615, 999.00000, WaveSpectra_b1)
                
                WaveSpectra_a2 = np.squeeze(GPS_waves_results[7])
                WaveSpectra_a2 = np.where(WaveSpectra_a2>=18446744073709551615, 999.00000, WaveSpectra_a2)

                WaveSpectra_b2 = np.squeeze(GPS_waves_results[8])
                WaveSpectra_b2 = np.where(WaveSpectra_b2>=18446744073709551615, 999.00000, WaveSpectra_b2)
                
                checkdata = np.full(numCoef,1)
                
                np.set_printoptions(formatter={'float_kind':'{:.5f}'.format})
                np.set_printoptions(formatter={'float_kind':'{:.2e}'.format})
                time.sleep(5)
                #----------------------------
                print('U=',u)
                print('V=',v)
                print('Z=',z)
                print('RESULTS',GPS_waves_results)
            
                uMean = getuvzMean(badValue,u)
                vMean = getuvzMean(badValue,v)
                zMean = getuvzMean(badValue,z)
                
                dname = now.strftime('%d%b%Y')
                tname = now.strftime('%H:%M:%S') 
                tempMean = GetMeanTemp(maxHoursTemp,
                                    badValue,
                                    floatID,
                                    projectName,
                                    dataDir,
                                    eventLog,
                                    elapsedTime)
                
                temp = float(tempMean)
                print('[%.3f] - Mean Temperature = %f' % (elapsedTime, temp))
                eventLog.info('[%.3f] - Get mean Temperature = %f' % (elapsedTime, temp))
            
                voltMean = GetMeanVolt(maxHoursVolt,
                                    badValue,
                                    floatID,
                                    projectName,
                                    dataDir,
                                    eventLog,
                                    elapsedTime)
                
                volt = float(voltMean)
                print('[%.3f] - Mean Voltage = %s' % (elapsedTime, volt))
                eventLog.info('[%.3f] - Get mean Voltage = %s' % (elapsedTime, volt))
            
                fbinary = (dataDir + floatID + 'SWIFT' + '_' + projectName + '_' + 
                            dname + '_' + tname + '.sbd')
                eventLog.info('[%.3f] - SBD file: %s' %(elapsedTime, fbinary ))
            
                if payLoadType == 50:
                    payLoadSize = (16 + 7*42)*4
                    eventLog.info('[%.3f] - Payload type: %d' % (elapsedTime, payLoadType))
                    eventLog.info('[%.3f] - payLoadSize: %d' % (elapsedTime, payLoadSize))
                else:
                    payLoadSize =  (5 + 7*42)*4
                    eventLog.info('[%.3f] - Payload type: %d' % (elapsedTime, payLoadType))
                    eventLog.info('[%.3f] - payLoadSize: %d' % (elapsedTime, payLoadSize))
        
                try:
                    fbinary = open(fbinary, 'wb')
                    
                except:
                    print ('[%.3f] - To write binary file is already open' % elapsedTime)
                
                SigwaveHeight = round(SigwaveHeight,6)
                Peakwave_Period = round(Peakwave_Period,6)
                Peakwave_dirT = round(Peakwave_dirT,6)
                
                lat[0] = round(lat[0],6)
                lon[0] = round(lon[0],6)
                uMean= round(uMean,6)
                vMean= round(vMean,6)
                zMean= round(zMean,6)
                
                fbinary.write(struct.pack('<sbbhfff', 
                                         str(payloadVersion),payLoadType,Port,
                                         payLoadSize,SigwaveHeight,Peakwave_Period,Peakwave_dirT))
         
                fbinary.write(struct.pack('<42f', *WaveSpectra_Energy))
                fbinary.write(struct.pack('<42f', *WaveSpectra_Freq))
                fbinary.write(struct.pack('<42f', *WaveSpectra_a1))
                fbinary.write(struct.pack('<42f', *WaveSpectra_b1))
                fbinary.write(struct.pack('<42f', *WaveSpectra_a2))
                fbinary.write(struct.pack('<42f', *WaveSpectra_b2))
                fbinary.write(struct.pack('<42f', *checkdata))
                fbinary.write(struct.pack('<f', lat[0]))
                fbinary.write(struct.pack('<f', lon[0]))
                fbinary.write(struct.pack('<f', temp))
                fbinary.write(struct.pack('<f', volt))
                fbinary.write(struct.pack('<f', uMean))
                fbinary.write(struct.pack('<f', vMean))
                fbinary.write(struct.pack('<f', zMean))
                fbinary.write(struct.pack('<i', int(now.year)))
                fbinary.write(struct.pack('<i', int(now.month)))
                fbinary.write(struct.pack('<i', int(now.day)))
                fbinary.write(struct.pack('<i', int(now.hour)))
                fbinary.write(struct.pack('<i', int(now.minute)))
                fbinary.write(struct.pack('<i', int(now.second)))
                fbinary.flush()
                fbinary.close()

                eventLog.info('[%.3f] - Calling send_sbd_binary_data' % elapsedTime)
                send_sbd_binary_data.main(formatType,
                                            Port,
                                          SigwaveHeight,
                                          Peakwave_Period,
                                          Peakwave_dirT,
                                          WaveSpectra_Energy,
                                          WaveSpectra_Freq,
                                          WaveSpectra_a1,
                                          WaveSpectra_b1,
                                          WaveSpectra_a2,
                                          WaveSpectra_b2,
                                         checkdata,
                                          lat[0],lon[0],
                                         temp,
                                          uMean,vMean,zMean,
                                          now,
                                          modemPort,
                                          modemBaud,
                                          payLoadType,
                                          payloadVersion,
                                          MakeCall,
                                          eventLog,
                                          elapsedTime,
                                          decStr,
                                          volt,
                                          modemGpio)

                eventLog.info('[%.3f] - Send sbd_binary_data' % elapsedTime)
                print('[%.3f] - Sending sbd binary data' % elapsedTime)
                doneIridium = True
                doneSampling = False
        else: 
            time.sleep(0.50)

                        
                


#run main function unless importing as a module
if __name__ == "__main__":
    main()
