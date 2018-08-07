# -*- coding: utf-8 -*-
import socket
import sys

# Create a TCP/IP socket
sock = socket.socket(socket.AF_INET,socket.SOCK_STREAM)

# Bind the socket to the port
server_address = ('localhost',10000)
print('starting up on %s port %s' % server_address,file=sys.stderr)
sock.bind(server_address)

# List for incoming connections
sock.listen(1)

while True:
    # Wait for a conecction
    print('waiting for a connection',file=sys.stderr)
    connection, client_address = sock.accept()
    
    try:
        print('connection from', client_address,file=sys.stderr)
        
        # Recieve the data in small chunks and retransmit it
        while True:
            data = connection.recv(16)
            print('received "%s"' % data,file=sys.stderr)
            if data:
                print('sending data back to the clinet',file=sys.stderr)
                connection.sendall(data)
            else:
                print('no more data from', client_address,file=sys.stderr)
                break
    finally:
        # Clean up the connection
        connection.close()

