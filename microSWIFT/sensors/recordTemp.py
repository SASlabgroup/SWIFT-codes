#! /usr/bin/python2.7

#Read and record temp from sensors
# Partial code by Author: Tony DiCola
#--------------------------------------------------------------
#standard imports
import time,spidev,sys,socket, os
from datetime import datetime
import numpy as np
import logging
from logging import *

# Import SPI library (for hardware SPI) and MCP3008 library.
import Adafruit_GPIO.SPI as SPI
import Adafruit_MCP3008

#my imports
from utils import *
from config2 import Config
#---------------------------------------------------------------
configDat = sys.argv[1]
configFilename = configDat #Load config file/parameters needed

config = Config() # Create object and load file
ok = config.loadFile( configFilename )
if( not ok ):
    sys.exit(0)

# Software SPI configuration:
CLK  = config.getInt('Temp', 'CLK')
MISO = config.getInt('Temp', 'MISO')
MOSI = config.getInt('Temp', 'MOSI')
CS   = config.getInt('Temp', 'CS')
mcp = Adafruit_MCP3008.MCP3008(clk=CLK, cs=CS, miso=MISO, mosi=MOSI)

#temp configuration 
tempFreq=config.getInt('Temp', 'tempFreq')
numSamplesConst=config.getInt('System', 'numSamplesConst')
tempNumSamples = tempFreq*numSamplesConst

recRate = config.getInt('Temp', 'recRate')
recInterval = 1./recRate

#when to record according to burst interval
burstInterval = config.getInt('Iridium', 'burstInt')
burstNum = config.getInt('Iridium', 'burstNum')

#logging params
dataDir = config.getString('LogLocation', 'dataDir')
logDir = config.getString('LogLocation', 'logDir')
floatID = config.getString('System', 'floatID')
bad = config.getInt('System', 'badValue')
projectName = config.getString('System', 'projectName')

##LOGGING
dataFile = str(currentTimeString()) #file name
#EVENT Log
LOG_FORMAT = ('[%(levelname)s] %(message)s')
LOG_LEVEL = logging.INFO 
EVENT_LOG_FILE = (logDir + '/' + 'tempEvent' + dataFile + '.log')
eventLog = logging.getLogger("Event")
eventLog.setLevel(LOG_LEVEL)
eventLogFileHandler = FileHandler(EVENT_LOG_FILE)
eventLogFileHandler.setLevel(LOG_LEVEL)
eventLogFileHandler.setFormatter(Formatter(LOG_FORMAT))
eventLog.addHandler(eventLogFileHandler)

#-------------------------------------------------------------------
#Loop Begins
#-------------------------------------------------------------------
def main():
    temp = np.empty(tempNumSamples) #make empty numpy array to write to
    #eventLog.info('[%.3f] - Start new burst interval' % elapsedTime)
    tStart = time.time()
    tLastRead = time.time()
    while True:
        #time.sleep(1)
        # at burst time interval
        now = datetime.utcnow()
        if (now.minute % burstInterval == 0 and now.second == 0):
            #time.sleep(1)
            tNow = time.time()
            elapsedTime = tNow - tStart

            dname = now.strftime('%d%b%Y')
            tname = now.strftime('%H:%M:%S')
            fname = (dataDir + floatID +
                '_Temp_' + dname + '_' + tname +'UTC_burst_' + str(burstInterval) + '.dat')
            fname_dir = os.path.join(dataDir)
            eventLog.info('[%.3f] - FileName: %s' % (elapsedTime,fname))

            fid=open(fname,'w')
            print('filename = ',fname)
            for isample in range(tempNumSamples):
                #time.sleep(1)
                tNow = time.time()
                elapsedTime = tNow - tStart
                
                analog_output = mcp.read_adc(0)
                output_volt = ConvertVolts(analog_output,2)
                eventLog.info('[%.3f] - num sample: %d, num sample needed: %d' % (elapsedTime,isample,tempNumSamples))
                temperature = ConvertTemp(output_volt,2)
                print("Temp: %f" % temperature)
                
                time.sleep(recInterval)
                tSinceLastRead = tNow - tLastRead
                if (tSinceLastRead >= recInterval):
                    fnow = datetime.utcnow()
                    fdname = fnow.strftime('%d%b%Y')
                    ftname = fnow.strftime('%H:%M:%S')
                
                    temp[isample] = temperature
                
                    print('temp',temp[isample],isample, tempNumSamples)
                    timestring = ("%d,%d,%d,%d,%d,%d" % (fnow.year,
                                                     fnow.month,
                                                     fnow.day,
                                                     fnow.hour,
                                                     fnow.minute,
                                                     fnow.second))
                    timestring = str(timestring)
                    print('TIME ',timestring,fdname,ftname)
                    fid.write('%s,%15.10f\n' %(timestring,temp[isample]))
                    fid.flush()
                    #time.sleep(1)
                    tLastRead = tNow

                #fid.close()
            mean_temperature = np.mean(temp)

            eventLog.info('[%.3f] - Mean temp: %s' % (elapsedTime,mean_temperature))
                
            print('mean temp ',mean_temperature)
            fnameMean = ('microswift_' + floatID +'_' + projectName +'_TempMean.dat')
            eventLog.info('[%.3f] - Mean temp file: %s' % (elapsedTime,fnameMean))
            
            fnameMeanNew = ('microswift_' + floatID +'_' + projectName +'_TempMean_New.dat')
            eventLog.info('[%.3f] - New mean temp file: %s' % (elapsedTime,fnameMeanNew))

            #go to 
            fnameMean_dir = os.path.join(dataDir)
            fnameMeanFile = os.path.join(fnameMean_dir,fnameMean)
            fnameMeanNewFile = os.path.join(fnameMean_dir,fnameMeanNew)
            
            if not (os.path.exists(fnameMeanFile)):
                fid = open(fnameMeanFile,'w')
            else:
                fid = open(fnameMeanFile,'a')
                

            fidNew = open(fnameMeanNewFile,'w')
            print (fnameMean)
            
            #set file permissions to write to 
            os.chmod(fnameMeanFile, 0777)
            os.chmod(fnameMeanNewFile, 0777)
            
            fid.write('%s,%15.10f\n'%(timestring,mean_temperature))
            fidNew.write('%s,%.10f\n'%(timestring,mean_temperature))
            fid.flush()
            fidNew.flush()
            fidNew.close()
            eventLog.info('[%.3f] - End burst interval' % elapsedTime)
            fid.close()
        time.sleep(1)
        
    
#run main function unless importing as a module
if __name__ == "__main__":
    main()
