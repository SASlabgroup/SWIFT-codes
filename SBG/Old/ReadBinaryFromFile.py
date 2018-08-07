# -*- coding: utf-8 -*-
"""
This script reads SBG binary files and outputs the data in human-readable format
See Ellipse Ekinox and Apogee Series - Firmware Manual.pdf
Based on SBG v3.5.0
Written for Python 3.5 
"""
from struct import unpack
from math import pi

###### INPUT FILE NAMES #######
inputFileName = r"D:\Dropbox\SWIFT_v4.x\SBG Systems\Python\binaryFileOutput.dat"
outputFileName = r"D:\Dropbox\SWIFT_v4.x\SBG Systems\Python\pythonDecodedOutput.dat"



###### Functions to check that message is read correctly #######
def checkCrc(crc,input_bitstring, polynomial_bitstring, initial_filler):
	'''Calculates the CRC remainder of a string of bits using a chosen polynomial. initial_filler should be '1' or '0'.'''
	len_polynomial = len(polynomial_bitstring)
	range_len_polynomial = range(len_polynomial)
	len_input = len(input_bitstring)
	input_padded_array = list(input_bitstring + initial_filler*(len_polynomial - 1))
	while '1' in input_padded_array[:len_input]:
		cur_shift = input_padded_array.index('1')
		for i in range_len_polynomial:
			input_padded_array[cur_shift + i] = '0' if polynomial_bitstring[i] == input_padded_array[cur_shift + i] else '1'
	return ''.join(input_padded_array)[len_input:]                               

def checkEtx(etx):
    if etx != b'\x33':
        raise ValueError('etx does not equal end of frame value')

def checkEndBytes(fIn,msgID,msgClass,msgLen,data):
    crc = fIn.read(2)
    input_bitstring = msgID+msgClass+msgLen+data
    polynomial_bitstring = b'\x84\x08'
    #checkCrc(crc,input_bitstring,polynomial_bitstring,0)
    etx = fIn.read(1)
    checkEtx(etx)    

###### Functions to parse various SBG messages #######        
def parseStatus(fIn):
    msgLen = fIn.read(2)
    if msgLen != b'\x16\x00':
        raise ValueError('msgLen does not equal correct message length')
    data = fIn.read(22)
    time_stamp,general_status,reserved1,com_status,aiding_status,reserved2,reserved3 = unpack('<LHHLLLH',data)
    fOut.write("Timestamp: {:<12} General Status: {:<5} Com Status: {:<9} Aiding Status: {:0>14b}\n".format(time_stamp,general_status,com_status,aiding_status))
    return msgLen,data
    
def parseUtcTime(fIn):
    msgLen = fIn.read(2)
    if msgLen != b'\x15\x00':
        raise ValueError('msgLen does not equal correct message length')
    data = fIn.read(21)
    time_stamp,clock_status,year,month,day,hour,minute,sec,nanosec,gps_tow = unpack('<LHHBBBBBLL',data)
    fOut.write("Timestamp: {:<12} UTC Time: {:02}/{:02}/{:04}, {:02}:{:02}:{:02}.{:09}\n".format(time_stamp,month,day,year,hour,minute,sec,nanosec))   
    return msgLen,data

def parseImuData(fIn):
    msgLen = fIn.read(2)
    if msgLen != b'\x3a\x00':
        raise ValueError('msgLen does not equal correct message length')
    data = fIn.read(58)
    time_stamp,imu_status,accel_x,accel_y,accel_z,gyro_x,gyro_y,gyro_z,temp,delta_vel_x,delta_vel_y,delta_vel_z,delta_angle_x,delta_angle_y,delta_angle_z = unpack('<LH13f',data)
    fOut.write("Timestamp: {:<12} Accelerations: {:3.3f}, {:3.3f}, {:3.3f}\n".format(time_stamp,accel_x,accel_y,accel_z))   
    return msgLen,data

def parseEkfEuler(fIn):
    msgLen = fIn.read(2)
    if msgLen != b'\x20\x00':
        raise ValueError('msgLen does not equal correct message length')
    data = fIn.read(32)
    time_stamp,roll,pitch,yaw,roll_acc,pitch_acc,yaw_acc,solution_status = unpack('<L6fL',data)
    fOut.write("Timestamp: {:<12} Euler Anges: {:3.1f}, {:3.1f}, {:3.1f}\n".format(time_stamp,180/pi*roll,180/pi*pitch,180/pi*yaw))   
    return msgLen,data

def parseEkfQuat(fIn):
    msgLen = fIn.read(2)
    if msgLen != b'\x24\x00':
        raise ValueError('msgLen does not equal correct message length')
    data = fIn.read(36)
    time_stamp,q0,q1,q2,q3,roll_acc,pitch_acc,Yaw_acc,solution_status = unpack('<L7fL',data)
    fOut.write("Timestamp: {:<12} Quaternions: {:3.1f}, {:3.1f}, {:3.1f}, {:3.1f}\n".format(time_stamp,q0,q1,q2,q3))   
    return msgLen,data

def parseEkfNav(fIn):
    msgLen = fIn.read(2)
    if msgLen != b'\x48\x00':
        raise ValueError('msgLen does not equal correct message length')
    data = fIn.read(72)
    time_stamp,velocity_n,velocity_e,velocity_d,velocity_n_acc,velocity_e_acc,velocity_d_acc,latitude,longitude,altitude,undulation,latitude_acc,longitude_acc,altitude_acc,solution_status = unpack('<L6f3d4fL',data)
    fOut.write("Timestamp: {:<12} EKF Position: {:3.3f}+/-{:3.3f} m, {:3.3f}+/-{:3.3f} m, {:3.3f}+/-{:3.3f} m, Status: {:0>28b}\n".format(time_stamp,latitude,latitude_acc,longitude,longitude_acc,altitude,altitude_acc,solution_status))   
    return msgLen,data

def parseShipMotion(fIn):
    msgLen = fIn.read(2)
    if msgLen != b'\x2e\x00':
        raise ValueError('msgLen does not equal correct message length')
    data = fIn.read(46)
    time_stamp,heave_period,surge,sway,heave,accel_x,accel_y,accel_z,vel_x,vel_y,vel_z,heave_status = unpack('<L10fH',data)
    fOut.write("Timestamp: {:<12} Heave: {:3.8f}\n".format(time_stamp,heave))   
    return msgLen,data

def parseGpsPos(fIn):
    msgLen = fIn.read(2)
    if msgLen != b'\x39\x00':
        raise ValueError('msgLen does not equal correct message length')
    data = fIn.read(57)
    time_stamp,gps_pos_status,gps_tow,lat,long,alt,undulation,pos_acc_lat,poss_acc_long,pos_acc_alt,num_sv_used,base_station_id,diff_age = unpack('<LLL3d4fBHH',data)
    fOut.write("Timestamp: {:<12} GPS Position: {:3.3f}+/-{:3.3f} m, {:3.3f}+/-{:3.3f} m, {:3.3f}+/-{:3.3f} m\n".format(time_stamp,lat,pos_acc_lat,long,poss_acc_long,alt,pos_acc_alt))   
    return msgLen,data  

##################################################
###### Body of code to process binary file #######
################################################## 
                       
with open(inputFileName, "rb") as fIn, open(outputFileName, "w") as fOut:
    # use of "with" ensures input and output files are closed at completion (even if error)
    byte = b'\x00' # arbitrary non-empty value to start while loop
    while byte:    # check that haven't reached end of file    
        byte = fIn.read(1)  
        if byte == b'\xff':  # check for first sync byte (see Firmware Reference Manual Section 2: sbgECom Binary Protocal)
            byte = fIn.read(1)
            if byte == b'\x5a':  # check for second sync byte 
                msgID = fIn.read(1)  # message ID (see Section 2.3 in Firmware Reference Manual)
                msgClass = fIn.read(1) # message class (see Section 2.1.2 in Firmware Reference Manual)
                if msgClass == b'\x00': # if SBG_ECOM_LOG class
                    # Parse data based on msgID
                    if msgID == b'\x01':
                        msgLen,data = parseStatus(fIn)
                        checkEndBytes(fIn,msgID,msgClass,msgLen,data) # always check that frame ends correctly and CRC is correct (see Section 2.1.1.1: CRC definition) 
                    elif msgID == b'\x02':
                        msgLen,data = parseUtcTime(fIn)
                        checkEndBytes(fIn,msgID,msgClass,msgLen,data)
                    elif msgID == b'\x03':
                        msgLen,data = parseImuData(fIn)
                        checkEndBytes(fIn,msgID,msgClass,msgLen,data)
                    elif msgID == b'\x06':
                        msgLen,data = parseEkfEuler(fIn)
                        checkEndBytes(fIn,msgID,msgClass,msgLen,data)
                    elif msgID == b'\x07':
                        msgLen,data = parseEkfQuat(fIn)
                        checkEndBytes(fIn,msgID,msgClass,msgLen,data)                      
                    elif msgID == b'\x08':
                        msgLen,data = parseEkfNav(fIn)
                        checkEndBytes(fIn,msgID,msgClass,msgLen,data)
                    elif msgID == b'\x09':
                        msgLen,data = parseShipMotion(fIn)
                        checkEndBytes(fIn,msgID,msgClass,msgLen,data)                       
                    elif msgID == b'\x0e':
                        msgLen,data = parseGpsPos(fIn)
                        checkEndBytes(fIn,msgID,msgClass,msgLen,data)