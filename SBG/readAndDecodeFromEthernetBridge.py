# -*- coding: utf-8 -*-
"""
Created on Tue Dec  6 19:34:23 2016

@author: MSchwendeman
"""

import socket
import sys
import sbgMessageParse

# Open file for writing
fileOut = open(r"D:\Dropbox\SWIFT_v4.x\SBG Systems\Python\pythonRealtimeDecodedOutput.dat",'w')


# Create a TCP/IP socket
sock = socket.socket(socket.AF_INET,socket.SOCK_STREAM)

# Bind the socket to the port
server_address = ('0.0.0.0',3001)
print('starting up on %s port %s' % server_address,file=sys.stderr)
sock.bind(server_address)

# Listen for incoming connections
sock.listen(1)

while True:
    # Wait for a conecction
    print('waiting for a connection',file=sys.stderr)
    connection, client_address = sock.accept()
    
    try:
        print('connection from', client_address,file=sys.stderr)
        # Read SBG data stream (see Firmware Reference Manual Section 2: sbgECom Binary Protocal)
        while True:
            # arbitrary non-empty value to start while loop
            byte = b'\x00'
            # check that haven't reached end of file or stream
            while byte:
                # Receive the data one byte at a time
                byte = connection.recv(1)
                # check for first sync byte
                if byte == b'\xff':
                    byte = connection.recv(1)
                    # check for second sync byte
                    if byte == b'\x5a':
                        # message ID and class
                        msgID = connection.recv(1)
                        msgClass = connection.recv(1)
                        # parse sbg message using sbgMessageParse library
                        sbgMessageParse.parseSbgMessage(msgClass,msgID,connection,printFlag=True,outputFile=sys.stdout)
    finally:
        # Clean up the connection
        connection.close()

