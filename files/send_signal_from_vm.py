#!/usr/bin/env python

import socket


TCP_IP = '10.0.2.2'
TCP_PORT = 5005
BUFFER_SIZE = 1024
MESSAGE = u"I'm alive"

s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
s.connect((TCP_IP, TCP_PORT))
s.send(MESSAGE)
data = s.recv(BUFFER_SIZE)
s.close()

print("received data: %s" % data)
