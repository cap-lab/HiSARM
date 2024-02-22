#!/usr/bin/python3

import os
import pickle

from ssh_manager import SSHManager

from robotsw_executer import runCommands, pkillBinary, sendCommandListWithThreads, sendCommandWithThreads

UPLOAD_TARGET_DIR = "~/workspace/uploaded_binary"
TARGET_OS_BINARY_NAME = "proc_os"
TARGET_NONOS_BINARY_NAME = "proc_nonos.bin"


robot_address_map = {}
ssh_manager_map = {}

ssh_manager = SSHManager()

#ssh_manager.create_ssh_client("192.168.50.5")
#out = ssh_manager.send_command("ls")
#print(out)

with open("robot_address.pickle",'rb') as f:
    robot_address_map = pickle.load(f)

print ("### Connecting to BIO Robots! #######")

for addr,info in robot_address_map.items():
    ssh_manager_map[addr] = SSHManager()
    ssh_manager_map[addr].create_ssh_client(addr, info['username'], info['port'])

print ("### Connected to BIO Robots! ########")

print ("### Stopping BIO Robots ! ############")
sendCommandWithThreads(ssh_manager_map, pkillBinary)
sendCommandListWithThreads(ssh_manager_map, robot_address_map, 'PostRunCommands')
print ("### BIO Robots are Stopped ! #########")
 
for addr in robot_address_map:
    ssh_manager_map[addr].close_ssh_client()

