#! /usr/bin/env python
import socket
from datetime import datetime

TCP_IP = '0.0.0.0'
TCP_PORT = 5005
BUFFER_SIZE = 1024
MESSAGE = u"I'm alive"

s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
s.bind((TCP_IP, TCP_PORT))
s.listen(1)
s.settimeout(360)

print("Waiting the VM")
start = datetime.now()
conn, addr = s.accept()
print('Connection address: %s' % str(addr))
while 1:
    data = conn.recv(BUFFER_SIZE)
    if not data:
      print("No more data, exiting.")
      break
    elif data != MESSAGE:
      print("received unexpected data: %s" % data)
      break
    else:
      print("VM is up and running. Boottime: %s" % (datetime.now()-start))
      conn.send(data)  # echo
conn.close()
