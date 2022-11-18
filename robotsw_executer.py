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

print ("### Setting BIO Robots! #############")
for addr, client in ssh_manager_map.items():
    out = client.send_command("~/tools/opencr_reset /dev/ttyACM0 115200") 
    out = client.send_command("cd " + UPLOAD_TARGET_DIR + " && rm -f output.txt")

print ("### Completed Setting BIO Robots ! ##")


print ("### Running BIO Robots ! ############")

for addr, client in ssh_manager_map.items():
    client.send_command_by_channel("cd " + UPLOAD_TARGET_DIR + " && ./" + TARGET_OS_BINARY_NAME + " &> output.txt &")

while True:
    input_data = input("To stop all the robots, press 's' key, then enter: ")
    if input_data == "s":
        break


print ("### Stopping BIO Robots ! ############")
for addr, client in ssh_manager_map.items():
    out = client.send_command("pkill " + TARGET_OS_BINARY_NAME) 

for addr, client in ssh_manager_map.items():
    out = client.send_command("~/tools/opencr_reset /dev/ttyACM0 115200") 
print ("### BIO Robots are Stopped ! #########")
 
for addr in robot_address_list:
    ssh_manager_map[addr].close_ssh_client()

