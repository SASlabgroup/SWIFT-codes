#! /usr/bin/python3

# Reads temperaure sensor. Writes date and temperature to file.
# Writes date and mean temperature to file

#standard imports
import serial, io, sys,os, time
from time import sleep
from datetime import datetime
import numpy as np
import logging
from logging import *

#third party imports
from ina219 import INA219
from ina219 import DeviceRangeError

#my imports
from config3 import Config
from utils import *

##########################################################################
#Load config file 
configDat =  sys.argv[1]
configFilename = configDat #Load config file/parameters needed
config = Config() # Create object and load file
ok = config.loadFile( configFilename )
if( not ok ):
	sys.exit(0)

#voltage parameters
voltFreq=config.getInt('Voltage', 'voltFreq')
numSamplesConst=config.getInt('System', 'numSamplesConst')
voltNumSamples = voltFreq*numSamplesConst
shuntOhms=config.getFloat('Voltage', 'shuntOhms')
maxExpectedAmps=config.getFloat('Voltage', 'maxExpectedAmps')

#when to record accoring to burst int 
burstInterval = config.getInt('Iridium', 'burstInt')
burstNum = config.getInt('Iridium', 'burstNum')

#logging params
dataDir = config.getString('LogLocation', 'dataDir')
logDir = config.getString('LogLocation', 'logDir')
floatID = config.getString('System', 'floatID')
bad = config.getInt('System', 'badValue')
projectName = config.getString('System', 'projectName')
recRate = config.getInt('Voltage', 'recRate')
recInterval = 1./recRate

##LOGGING
dataFile = str(currentTimeString()) #file name
#EVENT Log
LOG_FORMAT = ('[%(levelname)s] %(message)s')
LOG_LEVEL = logging.INFO 
EVENT_LOG_FILE = (logDir + '/' + 'voltEvent' + dataFile + '.log')
eventLog = logging.getLogger("Event")
eventLog.setLevel(LOG_LEVEL)
eventLogFileHandler = FileHandler(EVENT_LOG_FILE)
eventLogFileHandler.setLevel(LOG_LEVEL)
eventLogFileHandler.setFormatter(Formatter(LOG_FORMAT))
eventLog.addHandler(eventLogFileHandler)

tStart = time.time()
#------------------------------------------------------------------------
def main():
    volt = np.empty(voltNumSamples)
    
    ina = INA219(shuntOhms, maxExpectedAmps)
    ina.configure(ina.RANGE_16V)
    tLastRead = time.time()
    while True:
        now = datetime.utcnow()
        tNow = time.time()
        elapsedTime = tNow - tStart
        # at burst time interval
        if (now.minute % burstInterval == 0 and now.second == 0):
            eventLog.info('[%.3f] - Start new burst interval' % elapsedTime)
            dname = now.strftime('%d%b%Y')
            tname = now.strftime('%H:%M:%S')
            fname = (dataDir + floatID +'_Volt_' + dname + '_' + tname +'UTC_burst_' +str(burstInterval) + '.dat')
            eventLog.info('[%.3f] - Volt file: %s' % (elapsedTime, fname))
            
            fid=open(fname,'w')
            print('filename = ',fname)
            
            for isample in range(voltNumSamples):
                tNow = time.time()
                elapsedTime = tNow - tStart
                time.sleep(recInterval)
                eventLog.info('[%.3f] - num sample: %d, num sample needed: %d' % (elapsedTime,isample,voltNumSamples))

                fnow = datetime.utcnow()
                tHere = time.time()
                elapsed = tHere - tStart
                tSinceLastRead = tNow - tLastRead
                if (tSinceLastRead >= recInterval):
                    fdname = now.strftime('%d%b%Y')
                    ftname = now.strftime('%H:%M:%S')
                
                    volt[isample] = ina.voltage()
                    print('volt',volt[isample],isample, voltNumSamples)
                    timestring = ("%d,%d,%d,%d,%d,%d" % (fnow.year,
                                                     fnow.month,
                                                     fnow.day,
                                                     fnow.hour,
                                                     fnow.minute,
                                                     fnow.second))
                    timestring = str(timestring)
                    print('TIME ',timestring,fdname,ftname)
                    fid.write('%s,%15.10f\n' %(timestring,volt[isample]))
                    fid.flush()
                    tLastRead = tNow
            
            print (volt)
            meanVolt = np.mean(volt)
            eventLog.info('[%.3f] - Mean Volt: %s' % (elapsedTime,meanVolt))
                
            print('mean volt ',meanVolt)
            fnameMean = ('microswift_' + floatID +'_' + projectName +'_VoltMean.dat')
            eventLog.info('[%.3f] - Mean volt file name: %s' % (elapsedTime,fnameMean))
            
            fnameMeanNew = ('microswift_' + floatID +'_' + projectName +'_VoltMean_New.dat')
            eventLog.info('[%.3f] - New Mean volt file name: %s' % (elapsedTime,fnameMeanNew))
            
            fnameMeanDir = os.path.join(dataDir)
            fnameMeanFile = os.path.join(fnameMeanDir,fnameMean)
            fnameMeanNewFile = os.path.join(fnameMeanDir,fnameMeanNew)
            
            if not (os.path.exists(fnameMeanFile)):
                fid = open(fnameMeanFile,'w')
            else:
                fid = open(fnameMeanFile,'a')
                
            fidNew = open(fnameMeanNewFile,'w')
            
            #set file permissions to write to 
            os.chmod(fnameMeanFile, 0o777)
            os.chmod(fnameMeanNewFile, 0o777)
            
            fid.write('%s,%15.10f\n'%(timestring,meanVolt))
            fidNew.write('%s,%.10f\n'%(timestring,meanVolt))
            fid.flush()
            fidNew.flush()
            fidNew.close()
            eventLog.info('[%.3f] - End burst interval' % elapsedTime)
            fid.close()
        time.sleep(1)

#run main function unless importing as a module
if __name__ == "__main__":
    main()