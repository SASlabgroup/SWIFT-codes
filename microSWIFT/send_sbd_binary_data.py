#!/usr/bin/python2
#
# Opens a serial connection with a RockBlock 9603 SBD modem and
# transmits binary data that is passed to the main function
# Data is converted into binary in this script and then seperated
# into 4 messages send out through iridium in  specified format.
#
# Data include GPS GPGGA,GPVTG sentences, temp and voltage 
#
#------------------------------------------------------------------------

# standard imports 
import serial, sys
from time import sleep
from logging import *
import struct
import numpy as np
import time
import datetime
import RPi.GPIO as GPIO

# my imports
from rec_send_funcs import *

#initialize gpio pins
GPIO.setmode(GPIO.BCM)
GPIO.setwarnings(False)
#------------------------------------------------------------------------

# Takes in message created from GPS, IMU, TEMP, VOLT. Complete message i s
# split up into 4 different messages, all converted into binary form
# messages are sent out through iridium modem 
def send_sbd_msg(message,
                 bytelen,
                 modemPort,
                 modemBaud,
                 MakeCall,
                 eventLog,
                 elapsed,
                 modemGpio):
    
    GPIO.setup(modemGpio,GPIO.OUT)
    tStart = time.time()
    sleepTime = 6
    GPIO.output(modemGpio,GPIO.HIGH) #turn modem on
    
    #calculate elapsed time
    elapsedTime = getElapsedTime(tStart,elapsed)

    print('[%.3f] - Initializing SBD modem' % elapsedTime)
    eventLog.info('[%.3f] - Initializing SBD modem' % elapsedTime)

    #create serial object and open port
    sbd = serial.Serial(modemPort, modemBaud, timeout=1)
    try: 
        sbd.open() # Open port 
    except:
        print ("port already open")
        
    if sbd.isOpen():
        try:
            #calculate elapsed time here
            elapsedTime = getElapsedTime(tStart,elapsed)
            
            eventLog.info('[%.3f] - Start pushing data out iridium modem' % elapsedTime)

            sbd.flushInput()  # clear inpupt buffer
            sbd.flushOutput() # clean output buffer
            
            #sys.stdout.flush()
            #sys.stdin.flush()
            sleep(2)
            #issue AT command and check for OK response
            sbd.write('AT\r'.encode())
            status = sbd.readlines()
            print('[%.3f] - Iridium modem status: %s' % (elapsedTime,status))
            
            #get signal strength
            sbd.write('AT+CSQ\r'.encode())
            signal_strength = sbd.readlines()
            print('[%.3f] - Iridium modem signal strength: %s' % (elapsedTime,signal_strength))
            eventLog.info('[%.3f] - Send AT and AT+CSQ. Response: %s, %s' % (elapsedTime,status,signal_strength))

            #write data to MO buffer
            sleep(sleepTime)
            eventLog.info('[%.3f] - Write data to MO buffer' % elapsedTime)

            print ('[%.3f] - Length in bytes: %d' % (elapsedTime, bytelen))
            eventLog.info('[%.3f] - Length in bytes: %d' % (elapsedTime, bytelen))
            
            sbd.write(('AT+SBDWB='+str(bytelen) + '\r').encode())
            sleep(sleepTime)
            reply = sbd.readlines()
            print('[%.3f] - Write to MO buffer reply: %s' % (elapsedTime,reply))
            eventLog.info('[%.3f] - Write to MO buffer reply: %s' % (elapsedTime, reply))
            
            checksum = sum(bytearray(message))
            print('[%.3f] - Checksum: %s, message: %s' % (elapsedTime,checksum,message))
            eventLog.info('[%.3f] - Checksum: %s, message: %s' % (elapsedTime,checksum,message))

            sbd.write(message)
            sleep(sleepTime)
            print ('[%.3f] - wrote message: %s' % (elapsedTime,reply))
            
            sbd.write(chr(checksum >> 8))
            sbd.write(chr(checksum & 0xFF))
            
            reply = sbd.readlines()
            print('[%.3f] - Wrote message and checksum to modem. Response: %s' % (elapsedTime, reply))
            eventLog.info('[%.3f] - Wrote message and checksum to modem. Response: %s' % (elapsedTime, reply))


            if (MakeCall):
            #send SBD message
                sbd.write('AT+SBDIX\r'.encode())
                eventLog.info('[%.3f] - Send SBD message' % elapsedTime)
                print ('[%.3f] - Send SBD message' % elapsedTime)
                
            sleep(10)
            reply = sbd.readlines()
            eventLog.info('[%.3f] - Reply to send SBD message: %s' %(elapsedTime, reply))
            print('[%.3f] - Reply to send SBD message: %s' %(elapsedTime, reply))
            #sleep(sleepTime)

        except Exception as e1:
            eventLog.error("Error communicating...: " + str(e1))
            
    eventLog.info('[%.3f] - Powering down SBD modem and closing port' % elapsedTime)
    GPIO.output(modemGpio,GPIO.LOW)
    print ("Closing modem port")
    sbd.flushInput()  # clear inpupt buffer
    sbd.flushOutput() # clean output buffer
    sbd.close()
#--------------------------------------------------------------------------------------------
#MAIN
#
#Packet Structure
#<packet-type> <sub-header> <data>
#Sub-header 0:
#    ,<id>,<start-byte>,<total-bytes>:
#Sub-header 1 thru N:
#    ,<id>,<start-byte>:
#--------------------------------------------------------------------------------------------
def main(formatType,
         Port,
         Hs,
         Peakwave_Period,
         Peakwave_dirT,
         WaveSpectra_Energy,
         WaveSpectra_Freq,
         WaveSpectra_a1,
         WaveSpectra_b1,
         WaveSpectra_a2,
         WaveSpectra_b2,
         checkdata,
         lat,lon,
         MeanTemp,
         u,v,z,
         now,
         modemPort,
         modemBaud,
         PayLoadType,
         payloadVersion,
         MakeCall,
         eventLog,
         elapsedTime,
         decStr,
         MeanVoltage,
         modemGpio):
    
    GPIO.output(modemGpio,GPIO.HIGH) #turn modem on

    print ("UNRECORDED VALUES")
    print ("Pay load", PayLoadType)
    print ("voltage", MeanVoltage)
    print ("temp", MeanTemp)
    print ("Hs", Hs)
    print ("lon", lon)
    print ("lat", lat)
    print ("============================")
    #time.sleep(1)
    #f = open("/home/pi/Desktop/newFile.txt","w+")
    
    #-------------------------------------------------------
    if PayLoadType == 50:
        PayLoadSize =  (16 + 7*42)*4 
        eventLog.info('[%.3f] - Payload type: %d' % (elapsedTime, PayLoadType))
        SizeInBytes = struct.calcsize('sbbhfff42f42f42f42f42f42f42ffffffffiiiiii') -3

    else:
        PayLoadSize =  (5 + 7*42)*4
        eventLog.info('[%.3f] - Payload type: %d' % (elapsedTime, PayLoadType))
        SizeInBytes = struct.calcsize('sbbhfff42f42f42f42f42f42f42ffff') -3

    packetType = 1
    packetTypeId = '1,' + decStr + ','
    eventLog.info('[%.3f] - PacketTypeId: %s' % (elapsedTime, packetTypeId))

    print ('[%.3f] - SizeInBytes: %s' % (elapsedTime,str(SizeInBytes)))
    
    # 1st message sent 
    dataToSend0= (struct.pack('<5sss4sssbbhfff',
                                packetTypeId, str(0),',',str(SizeInBytes),':',
                                str(payloadVersion),
                                PayLoadType,Port,PayLoadSize,
                                Hs,Peakwave_Period,Peakwave_dirT) +
                                struct.pack('42f',*WaveSpectra_Energy) +
                                struct.pack('35f\r',*WaveSpectra_Freq[0:35]))
    
    print (struct.unpack('<5sss4sssbbhfff42f35f',dataToSend0))
    bytelen0  = struct.calcsize('sbbhfff42f35f') +9
    print ('bytelen0',bytelen0)

    # 2nd message sent
    bytestart = struct.calcsize('sbbhfff42f35f')-3
    print ('bytestart 1',bytestart)
    dataToSend1=(struct.pack('<5s3ss7f', packetTypeId,str(bytestart),':',
                 *WaveSpectra_Freq[35:42]) +
                 struct.pack('42f',*WaveSpectra_a1) +
                 struct.pack('33f\r',*WaveSpectra_b1[0:33]))
    print (struct.unpack('<5s3ss7f42f33f', dataToSend1))
    
    bytelen1 = struct.calcsize('7f42f33f') +9
    print ('bytelen1',bytelen1)

    # 3rd message sent
    bytestart = struct.calcsize('sbbhfff42f42f42f33f')-3
    print ('bytestart 2',bytestart)
    dataToSend2=(struct.pack('<5s3ss9f', packetTypeId,str(bytestart),':',
                 *WaveSpectra_b1[33:42])+
                 struct.pack('42f',*WaveSpectra_a2) +
                 struct.pack('31f\r',*WaveSpectra_b2[0:31]))
    print (struct.unpack('<5s3ss9f42f31f', dataToSend2))
    
    bytelen2 = struct.calcsize('9f42f31f') +9
    print ('bytelen2',bytelen2)
    
    if PayLoadType==50:
        # 4th message sent
        bytestart = struct.calcsize('sbbhfff42f42f42f42f42f31f')-3 
        dataToSend3=(struct.pack('<5s3ss11f', packetTypeId,str(bytestart),':',
                 *WaveSpectra_b2[31:42])+
                 struct.pack('42f',*checkdata) +
                 struct.pack('fffffffiiiiii\r',lat,lon,MeanTemp,MeanVoltage,u,v,z,
                 int(now.year),int(now.month),int(now.day),
                 int(now.hour),int(now.minute),int(now.second)))
        print (struct.unpack('<5s3ss11f42ffffffffiiiiii', dataToSend3))
        bytelen3 = struct.calcsize('11f42ffffffffiiiiii') +9 
        print ('bytelen3',bytelen3)
    else:
        print ("[%.3f] - ERROR: Incorrect pay load type, try again" % elapsedTime)
        eventLog.error('[%.3f] - ERROR: Incorrect pay load type, try again' % elapsedTime)
        sys.exit()

    print ('----- dataToSend0 =')
    print (dataToSend0)
    send_sbd_msg(dataToSend0,bytelen0,modemPort,modemBaud,MakeCall,eventLog,elapsedTime,modemGpio)

    print ('----- dataToSend1 =')
    print (dataToSend1)
    send_sbd_msg(dataToSend1,bytelen1,modemPort,modemBaud,MakeCall,eventLog,elapsedTime,modemGpio)

    print ('----- dataToSend2 =')
    print (dataToSend2)
    send_sbd_msg(dataToSend2,bytelen2,modemPort,modemBaud,MakeCall,eventLog,elapsedTime,modemGpio)
    
    print ('----- dataToSend3 =')
    print (dataToSend3)
    send_sbd_msg(dataToSend3,bytelen3,modemPort,modemBaud,MakeCall,eventLog,elapsedTime,modemGpio)

#run main function unless importing as a module
if __name__ == "__main__":
    main()

