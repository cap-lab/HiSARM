#!/usr/bin/python3

import os
import pickle

from ssh_manager import SSHManager

from threading import Thread


UPLOAD_TARGET_DIR = "~/workspace/uploaded_binary"
TARGET_OS_BINARY_NAME = "proc_os"
TARGET_NONOS_BINARY_NAME = "proc_nonos.bin"

def setBIORobot(client):
    out = client.send_command("~/tools/opencr_reset /dev/ttyACM0 115200") 
    out = client.send_command("cd " + UPLOAD_TARGET_DIR + " && rm -f output.txt")  


def runV4lServer(client):
    client.send_command_by_channel("v4l2rtspserver -W 480 -H 480 -F 15 -P 8554 /dev/video0 &")


def pkillBinary(client):
    out = client.send_command("pkill " + TARGET_OS_BINARY_NAME) 

def pkillV4l(client):
    out = client.send_command("pkill v4l2rtspserver")

def resetOpenCR(client):
    out = client.send_command("~/tools/opencr_reset /dev/ttyACM0 115200") 


def runThreads(thread_list):
    for thread in thread_list:
        thread.start()

    for thread in thread_list:
        thread.join()

def sendCommandsWithThreads(ssh_manager_map, function):
    thread_list = []
    for addr, client in ssh_manager_map.items():
        thread = Thread(target=function, args=(client, ))
        thread_list.append(thread)
    runThreads(thread_list)

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
sendCommandsWithThreads(ssh_manager_map, setBIORobot)
sendCommandsWithThreads(ssh_manager_map, runV4lServer)
print ("### Completed Setting BIO Robots ! ##")


print ("### Running BIO Robots ! ############")

for addr, client in ssh_manager_map.items():
    client.send_command_by_channel("cd " + UPLOAD_TARGET_DIR + " && ./" + TARGET_OS_BINARY_NAME + " &> output.txt &")

while True:
    input_data = input("To stop all the robots, press 's' key, then enter: ")
    if input_data == "s":
        break


print ("### Stopping BIO Robots ! ############")
sendCommandsWithThreads(ssh_manager_map, pkillBinary)
sendCommandsWithThreads(ssh_manager_map, pkillV4l)
sendCommandsWithThreads(ssh_manager_map, resetOpenCR)
print ("### BIO Robots are Stopped ! #########")
 
for addr in robot_address_list:
    ssh_manager_map[addr].close_ssh_client()

