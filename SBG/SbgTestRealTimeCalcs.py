# -*- coding: utf-8 -*-
"""
Created on Thu Dec  8 00:20:39 2016

@author: JTalbert
"""


import socket
import sys
import sbgMessageParse
import numpy
from collections import deque
import time

# Open file for writing
fileOut = open(r"D:\Dropbox\SWIFT_v4.x\SBG Systems\Python\pythonRealtimeDecodedOutput_point1Delay.dat",'w')


# Create a TCP/IP socket
sock = socket.socket(socket.AF_INET,socket.SOCK_STREAM)

# Bind the socket to the port
server_address = ('0.0.0.0',3001)
print('starting up on %s port %s' % server_address,file=sys.stderr)
sock.bind(server_address)

# Listen for incoming connections
sock.listen(1)

# Define variables for calculations
tRange = 1 # seconds
heave_mean = 0
heave_var = 0
lat_mean = 0
lat_var = 0
lon_mean = 0
lon_var = 0
heave_list = deque([])
pos_list = deque([])

while True:
    # Wait for a conecction
    print('waiting for a connection',file=sys.stderr)
    connection, client_address = sock.accept()
    
    try:
        print('connection from', client_address,file=sys.stderr)
 
        while True:
            byte = b'\x00' # arbitrary non-empty value to start while loop
            while byte:    # check that haven't reached end of file    
                byte = connection.recv(1)   # Receive the data in small chunks 
                if byte == b'\xff':  # check for first sync byte (see Firmware Reference Manual Section 2: sbgECom Binary Protocal)
                    byte = connection.recv(1)
                    if byte == b'\x5a':  # check for second sync byte 
                        msgID = connection.recv(1)  # message ID (see Section 2.3 in Firmware Reference Manual)
                        msgClass = connection.recv(1) # message class (see Section 2.1.2 in Firmware Reference Manual)
                        dataStruct = sbgMessageParse.parseSbgMessage(msgClass,msgID,connection,printFlag=False,outputFile=sys.stdout)   
                        if sbgMessageParse.sbgMessages[msgID]['name'] is 'UtcTime':
                            print("SBG Time:      {:02}/{:02}/{:04}, {:02}:{:02}:{:02}.{:09}\n".format(dataStruct['month'],dataStruct['day'],dataStruct['year'],dataStruct['hour'],dataStruct['minute'],dataStruct['sec'],dataStruct['nanosec']),file=fileOut)   
                            time.sleep(10)
                            print("Computer Time: {:02}/{:02}/{:04}, {:02}:{:02}:{:02}.{:09}\n".format(*time.gmtime()[:]),file=fileOut)   
                            #numpy.sort(numpy.random.rand(100000000))
                            print('Calculation Done')
                        """  
                        if sbgMessageParse.sbgMessages[msgID]['name'] is 'ShipMotion':
                            heave_list.append([dataStruct['time_stamp'],dataStruct['heave']])
                            current_time = dataStruct['time_stamp']
                            for times in range(len(heave_list)):
                                if current_time - heave_list[0][0] > tRange*1e6 or current_time - heave_list[0][0] < 0:
                                    heave_list.popleft()
                                else:
                                    break
                            if len(heave_list) > 1:
                                heave_mean = numpy.mean(numpy.array(heave_list),axis=0)[1]
                                heave_var = numpy.var(numpy.array(heave_list),axis=0)[1]
                            else:
                                heave_mean = 0
                                heave_var = 0
                            print('{:>12d}, Heave Mean: {:+3.3f}, Heave Variance: {:+3.3f}, Num Elements: {}'.format(current_time,heave_mean,heave_var,len(heave_list)),file=fileOut,end='\n')
                            #print(' '.join(map('{:+3.3f}'.format,[y for x,y in heave_list])),file=fileOut,end='\n')
                        if sbgMessageParse.sbgMessages[msgID]['name'] is 'GpsPos':
                            pos_list.append([dataStruct['time_stamp'],dataStruct['lat'],dataStruct['long']])
                            current_time = dataStruct['time_stamp']
                            for times in range(len(pos_list)):
                                if current_time - pos_list[0][0] > tRange*1e6 or current_time - pos_list[0][0] < 0:
                                    pos_list.popleft()
                                else:
                                    break
                            if len(pos_list) > 1:
                                lat_mean = numpy.mean(numpy.array(pos_list),axis=0)[1]
                                lat_var = numpy.var(numpy.array(pos_list),axis=0)[1]
                                lon_mean = numpy.mean(numpy.array(pos_list),axis=0)[2]
                                lon_var = numpy.var(numpy.array(pos_list),axis=0)[2]
                            else:
                                lat_mean = 0
                                lat_var = 0
                                lon_mean = 0
                                lon_var = 0
                            print('{:>12d}, Lat Mean: {:+3.3f}, Lat Variance: {:+3.3f}, Num Elements: {} '.format(current_time,lat_mean,lat_var,len(pos_list)),file=fileOut,end='\n')
                            #print(' '.join(map('{:+3.3f}'.format,[y for x,y,z in pos_list])),file=fileOut,end='\n')
                            print('{:>12d}, Lon Mean: {:+3.3f}, Lon Variance: {:+3.3f}, Num Elements: {}'.format(current_time,lon_mean,lon_var,len(pos_list)),file=fileOut,end='\n')
                            #print(' '.join(map('{:+3.3f}'.format,[z for x,y,z in pos_list])),file=fileOut,end='\n')  
                            """
    finally:
        # Clean up the connection
        connection.close()

