#!/usr/bin/python3

import os
import pickle

from ssh_manager import SSHManager

from threading import Thread
import sys, select
from random import shuffle
import time
import argparse

parser = argparse.ArgumentParser()
parser.add_argument('-r', '--robot_to_be_failed', help=' : robots to kill', default='') 
parser.add_argument('-n', '--number_of_robot_to_be_failed', help=' : number of robots to kill (default=len(list of robot to be failed))', type=int, default=-1) 
parser.add_argument('-t', '--time_to_be_failed', help=' : time', type=int, default=0)
args = parser.parse_args()

UPLOAD_TARGET_DIR = "~/workspace/uploaded_binary"
TARGET_OS_BINARY_NAME = "proc_os"
TARGET_NONOS_BINARY_NAME = "proc_nonos.bin"

def setBIORobot(client):
    out = client.send_command("cd " + UPLOAD_TARGET_DIR + " && rm -f output.txt")  

def runCommands(client, commands):
    for command in commands:
        if len(command.strip()) > 0 and command.strip()[-1] == '&':
            client.send_command_by_channel(command)
        else :
            out = client.send_command(command) 

def pkillBinary(client):
    out = client.send_command("pkill " + TARGET_OS_BINARY_NAME) 

def runThreads(thread_list):
    for thread in thread_list:
        thread.start()

    for thread in thread_list:
        thread.join()

def sendCommandListWithThreads(ssh_manager_map, robot_addr_map, command_key):
    thread_list = []
    for addr, client in ssh_manager_map.items():
        thread = Thread(target=runCommands, args=(client, robot_addr_map[addr][command_key], ))
        thread_list.append(thread)
    runThreads(thread_list)


def sendCommandWithThreads(ssh_manager_map, function):
    thread_list = []
    for addr, client in ssh_manager_map.items():
        thread = Thread(target=function, args=(client, ))
        thread_list.append(thread)
    runThreads(thread_list)


def main():
    robot_address_map = {}
    ssh_manager_map = {}
    device_client_map = {}
    
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
        device_client_map[info['deviceName']] = ssh_manager_map[addr]
    
    print ("### Connected to BIO Robots! ########")
    
    print ("### Setting BIO Robots! #############")
    sendCommandWithThreads(ssh_manager_map, setBIORobot)
    sendCommandListWithThreads(ssh_manager_map, robot_address_map, 'PreRunCommands')
    print ("### Completed Setting BIO Robots ! ##")
    
    
    print ("### Running BIO Robots ! ############")
    
    for addr, client in ssh_manager_map.items():
        client.send_command_by_channel("cd " + UPLOAD_TARGET_DIR + " && ./" + TARGET_OS_BINARY_NAME + " &> output.txt &")
    
    print("To stop all the robots, press 's' key, then enter")
    start_time = time.time()
    killed = False
    while True:
        i, o, e = select.select( [sys.stdin], [], [], 1 )
        if i:
            input_data = sys.stdin.readline().strip()
            if input_data == "s":
                break
        else:
            current_time = time.time()
            if args.time_to_be_failed > 0 and args.time_to_be_failed < current_time - start_time and killed is False:
                robot_list = args.robot_to_be_failed.split(',')
                shuffle(robot_list)
                number_of_robot_to_be_killed = args.number_of_robot_to_be_failed if args.number_of_robot_to_be_failed > 0 else len(robot_list)
                for index in range(number_of_robot_to_be_killed):
                    print("Kill " + robot_list[index])
                    pkillBinary(device_client_map[robot_list[index]])
                killed = True
    
    print ("### Stopping BIO Robots ! ############")
    sendCommandWithThreads(ssh_manager_map, pkillBinary)
    sendCommandListWithThreads(ssh_manager_map, robot_address_map, 'PostRunCommands')
    print ("### BIO Robots are Stopped ! #########")
     
    for addr in robot_address_map:
        ssh_manager_map[addr].close_ssh_client()

if __name__ == "__main__":
    main()
