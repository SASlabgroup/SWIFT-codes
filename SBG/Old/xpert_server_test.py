# -*- coding: utf-8 -*-
import socket
import sys

# Open file for writing
fileOut = open(r"D:\Dropbox\SWIFT_v4.x\SBG Systems\Python\binaryFileOutput.dat",'wb')
try:

    # Create a TCP/IP socket
    sock = socket.socket(socket.AF_INET,socket.SOCK_STREAM)
    
    # Bind the socket to the port
    server_address = ('0.0.0.0',3001)
    print('starting up on %s port %s' % server_address,file=sys.stderr)
    #fileOut.write('starting up on %s port %s\n' % server_address)
    sock.bind(server_address)

    # List for incoming connections
    sock.listen(1)
    
    while True:
        # Wait for a conecction
        print('waiting for a connection',file=sys.stderr)
        #fileOut.write('waiting for a connection\n')
        connection, client_address = sock.accept()
        
        try:
            print('connection from', client_address,file=sys.stderr)
            #fileOut.write('connection from ' + " ".join(map(str,client_address)) + "\n")
            
            # Receive the data in small chunks and retransmit it
            while True:
                data = connection.recv(1024)
                #print('received "%s"' % repr(data),file=sys.stderr)   
                fileOut.write(data)
                #fileOut.write(repr(data))
                if not data:
                    print('no more data from' + str(client_address),file=sys.stderr)
                    break

        finally:
            # Clean up the connection
            connection.close()
finally:
    fileOut.close()
