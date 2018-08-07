# -*- coding: utf-8 -*-
import socket
import sys


# Create a TCP/IP socket
sock = socket.socket(socket.AF_INET,socket.SOCK_STREAM)

# Bind the socket to the port
server_address = ('0.0.0.0',3001)
print('starting up on %s port %s' % server_address,file=sys.stderr)
#fileOut.write('starting up on %s port %s\n' % server_address)
sock.bind(server_address)

# List for incoming connections
sock.listen(1)


connection, client_address = sock.accept()
print('connection from', client_address,file=sys.stderr)
    #fileOut.write('connection from ' + " ".join(map(str,client_address)) + "\n")
    
    # Receive the data in small chunks and retransmit it
while True:
    data = connection.recv(1024)
    if not data:
        print('no more data from' + str(client_address),file=sys.stderr)
        break
    print('received data:' + repr(data))

    # Clean up the connection
connection.close()

