# -*- coding: utf-8 -*-
"""
Created on Wed Dec  7 00:01:43 2016

@author: MSchwendeman
"""

import struct
import sys
from collections import OrderedDict

### Dictionary relating SBG msgID to name, length, data fields, etc
sbgMessages = {b'\x01': {'name':'Status','intLength':22,'binLength': b'\x16\x00','unpackString':'<LHHLLLH','fields':('time_stamp','general_status','reserved1','com_status','aiding_status','reserved2','reserved3')},
b'\x02': {'name':'UtcTime','intLength':21,'binLength': b'\x15\x00','unpackString':'<LHHBBBBBLL','fields':('time_stamp','clock_status','year','month','day','hour','min','sec','nanosec','gps_tow')},
b'\x03': {'name':'ImuData','intLength':58,'binLength':b'\x3a\x00','unpackString': '<LH13f','fields':('time_stamp','imu_status','accel_x','accel_y','accel_z','gyro_x','gyro_y','gyro_z','temp','delta_vel_x','delta_vel_y','delta_vel_z','delta_angle_x','delta_angle_y','delta_angle_z')},
b'\x04': {'name':'Mag','intLength':30,'binLength':b'\x1e\x00','unpackString':'<LH6f','fields':('time_stamp','mag_status','mag_x','mag_y','mag_z','accel_x','accel_y','accel_z')},
b'\x06': {'name':'EkfEuler','intLength':32,'binLength':b'\x20\x00','unpackString':'<L6fL','fields':('time_stamp','roll','pitch','yaw','roll_acc','pitch_acc','yaw_acc','solution_status')},
b'\x07': {'name':'EkfQuat','intLength':36,'binLength':b'\x24\x00','unpackString':'<L7fL','fields':('time_stamp','q0','q1','q2','q3','roll_acc','pitch_acc','yaw_acc','solution_status')},
b'\x08': {'name':'EkfNav','intLength':72,'binLength':b'\x48\x00','unpackString':'<L6f3d4fL','fields':('time_stamp','velocity_n','velocity_e','velocity_d','velocity_n_acc','velocity_e_acc','velocity_d_acc','latitude','longitude','altitude','undulation','latitude_acc','longitude_acc','altitude_acc','solution_status')},
b'\x09': {'name':'ShipMotion','intLength':46,'binLength':b'\x2e\x00','unpackString':'<L10fH','fields':('time_stamp','heave_period','surge','sway','heave','accel_x','accel_y','accel_z','vel_x','vel_y','vel_z','heave_status')},
b'\x0d': {'name':'GpsVel','intLength':44,'binLength':b'\x2c\x00','unpackString':'<LLL8f','fields':('time_stamp','gps_vel_status','gps_tow','vel_n','vel_e','vel_d','vel_acc_n','vel_acc_e','vel_acc_d','course','course_acc')},
b'\x0e': {'name':'GpsPos','intLength':57,'binLength':b'\x39\x00','unpackString':'<LLL3d4fBHH','fields':('time_stamp','gps_pos_status','gps_tow','lat','long','alt','undulation','pos_acc_lat','pos_acc_long','pos_acc_alt','num_sv_used','base_station_id','diff_age')}}
          

### Main SBG message parser
def parseSbgMessage(msgClass,msgID,connection=None,printFlag=False,outputFile=sys.stdout,readFromFile=False,inputFile=None):
    if msgClass == b'\x00': # if SBG_ECOM_LOG class
        if readFromFile:
            binData,crc,etx = readSbgData_FromFile(msgID,inputFile)
        else:
            binData,crc,etx = readSbgData_TCPIP(msgID,connection)
        if binData:
            dataStruct = parseSbgData(msgID,binData)
            if printFlag:
                printSbgData(msgID,dataStruct,outputFile)
            checkEndBytes(msgID,binData,crc,etx)
        else:
            dataStruct = None
        return dataStruct

### Subroutine for reading sbg data from TCPIP socket
def readSbgData_TCPIP(msgID,connection):
    if msgID in sbgMessages:
        msgLen = bytes()
        while len(msgLen)<2:
            msgLen += connection.recv(1)
        if msgLen != sbgMessages[msgID]['binLength']:
            raise ValueError('msgLen does not equal correct message length')
        data = bytes()
        while len(data)<sbgMessages[msgID]['intLength']:
            data += connection.recv(1)
        crc = bytes()
        while len(crc)<2:
            crc += connection.recv(1)     
        etx = connection.recv(1)
        return data,crc,etx
    else: return None,None,None

### Subroutine for reading sbg data from binary file
def readSbgData_FromFile(msgID,inputFile):
    if msgID in sbgMessages:
        msgLen = inputFile.read(2)
        if msgLen != sbgMessages[msgID]['binLength']:
            raise ValueError('msgLen does not equal correct message length')
        data = inputFile.read(sbgMessages[msgID]['intLength'])
        crc = inputFile.read(2)     
        etx = inputFile.read(1)
        return data,crc,etx
    else: return None,None,None

### Function for parsing binary SBG messages into dictionaries     
def parseSbgData(msgID,binData):
    parsedData = struct.unpack(sbgMessages[msgID]['unpackString'],binData)
    dataStruct = OrderedDict(zip(sbgMessages[msgID]['fields'],parsedData))
    return dataStruct

### Function for printing SBG data
def printSbgData(msgID,dataStruct,filename):
    print("{:<12s}".format(sbgMessages[msgID]['name']),file=filename,end='')
    for key,data in dataStruct.items():
        print('{}: {}, '.format(key,data),file=filename,end='')
    print('\n',file=filename,end='')


### Function to check that SBG messages contain correct crc and end-of-frame bytes
def checkEndBytes(msgID,data,crc,etx):
    #checkCrc(crc,input_bitstring,polynomial_bitstring,0)
    checkEtx(etx)    

### CRC check to be written...
def checkCrc(crc,input_bitstring, polynomial_bitstring, initial_filler):
	pass

### Check that etx byte equals end of frame value
def checkEtx(etx):
    if etx != b'\x33':
        raise ValueError('etx does not equal end of frame value')


            
 
