#!/usr/bin/python3

import os
import pickle

from ssh_manager import SSHManager

UPLOAD_TARGET_DIR = "~/workspace/uploaded_binary"
TARGET_OS_BINARY_NAME = "proc_os"
TARGET_NONOS_BINARY_NAME = "proc_nonos.bin"


robot_address_list = []
ssh_manager_map = {}

ssh_manager = SSHManager()

#ssh_manager.create_ssh_client("192.168.50.5")
#out = ssh_manager.send_command("ls")
#print(out)

with open("robot_address.pickle",'rb') as f:
    robot_address_list = pickle.load(f)

#robot_address_list = ["192.168.50.5"]

print ("### Connecting to BIO Robots! #######")

for addr in robot_address_list:
    ssh_manager_map[addr] = SSHManager()
    ssh_manager_map[addr].create_ssh_client(addr)

print ("### Connected to BIO Robots! ########")

print ("### Stopping BIO Robots ! ############")
for addr, client in ssh_manager_map.items():
    out = client.send_command("pkill " + TARGET_OS_BINARY_NAME) 

for addr, client in ssh_manager_map.items():
    out = client.send_command("pkill v4l2rtspserver")

for addr, client in ssh_manager_map.items():
    out = client.send_command("~/tools/opencr_reset /dev/ttyACM0 115200") 
print ("### BIO Robots are Stopped ! #########")
 
for addr in robot_address_list:
    ssh_manager_map[addr].close_ssh_client()

