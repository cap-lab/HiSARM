#!/usr/bin/python3

import os
import sys
import subprocess
import platform
import yaml
import pickle

from pymongo import MongoClient
from threading import Thread

from ssh_manager import SSHManager

generated_dir_path="generated"

ARDUINO_DIR = "/home/caplab/arduino-ide_2.0.1_Linux_64bit"
PKG_CONFIG_DIR = "/home/caplab/cross_env/usr/local/lib/arm-linux-gnueabihf/pkgconfig:/home/caplab/cross_env/usr/lib/arm-linux-gnueabihf/pkgconfig:/home/caplab/cross_env/usr/share/pkgconfig"
SYSROOT_DIR = "/home/caplab/cross_env"
UPLOAD_TARGET_DIR = "~/workspace/uploaded_binary"
TARGET_OS_BINARY_NAME = "proc_os"
TARGET_NONOS_BINARY_NAME = "proc_nonos.bin"
NONOS_BOARD_NAME = "OpenCR"
ROBOT_ADDDR_FILE_NAME = "robot_address.pickle"

def getLatestDirectory(generatedDirPath, projectName):
    file_name_time_list = []
    for file_name in os.listdir(generatedDirPath):
        file_path = os.path.join(generatedDirPath, file_name)
        if os.path.isdir(file_path) and file_name.endswith(projectName):
            written_time = os.path.getctime(file_path)
            file_name_time_list.append((file_name, written_time))

    sorted_file_list = sorted(file_name_time_list, key=lambda x: x[1], reverse=True)
    return sorted_file_list[0][0]

def checkBuildTarget():
    os_target_list = ["configure.ac", "Makefile.am", "preinstall.sh", "ltmain.sh"]
    nonos_target_list = ["Arduino.mk", "Common.mk", "Sam.mk", "OpenCR.mk", "Makefile"]
    os_count = 0
    nonos_count = 0
    for file_name in os.listdir("."):
        if file_name in os_target_list:
            os_count += 1
        elif file_name in nonos_target_list:
            nonos_count += 1

    if os_count == len(os_target_list):
        return "OS"
    elif nonos_count == len(nonos_target_list):
        return "NonOS"
    else:
        return "Invalid"

def runCommand(command):
    ret = os.WEXITSTATUS(os.system(command))
    if ret != 0:
        raise Exception("Command - " + command) 

def buildOSTarget():
    os.environ["PKG_CONFIG_LIBDIR"] = PKG_CONFIG_DIR
    runCommand("chmod +x ./preinstall.sh")
    runCommand("./preinstall.sh")
    runCommand("./configure CFLAGS=\"--sysroot=" + SYSROOT_DIR + " -O2 -g\"  CXXFLAGS=\"--sysroot=" + SYSROOT_DIR + " -O2\" --host=arm-linux-gnueabihf")
    runCommand("make -j")

def buildNonOSTarget():
    os.environ["PKG_CONFIG_LIBDIR"] = ""
    os.environ["ARDUINO_DIR"] = ARDUINO_DIR
    runCommand("make -j")

def buildAllDevices(projectDirPath):
    working_dir_path = os.getcwd()
    os.chdir(projectDirPath)
    for file_name in os.listdir("."):
        if os.path.isdir(file_name):
            os.chdir(file_name)
            target = checkBuildTarget()
            try:
                if target == "OS":
                    buildOSTarget()
                elif target == "NonOS":
                    buildNonOSTarget()
            except Exception as e:  
                print("Build error on \"" + file_name + "\": ", e)
                sys.exit(1)
            os.chdir("..")
    os.chdir(working_dir_path)

def getYamlConfig(yamlPath):
    yaml_config = None
    with open(yamlPath) as f:
        yaml_config = yaml.load(f, Loader=yaml.FullLoader)
    return yaml_config

def getMongoDB(yamlInfo):
    mongo_db_info = yamlInfo['dbInfo'][0] 
    client = MongoClient(host=mongo_db_info['ip'], port=mongo_db_info['port'], username=mongo_db_info['userName'], password=mongo_db_info['password'], authSource=mongo_db_info['dbName']) 
    db_handle = client[mongo_db_info['dbName']]
    #collection = db_handle['RobotImpl']
    #print(collection.find_one())

    return db_handle

def getMatchedRobotFromDirName(dirName, robotList):
    matched_name = None
    for robot_name in robotList:
        if dirName.startswith(robot_name + "_"):
            matched_name = robot_name
            break
    return matched_name

def getUploadTargetIP(robotName, robotImplCollection):
    robot_data = robotImplCollection.find_one({"RobotId": robotName})
    for robot_comm in robot_data['CommunicationInfo']:
        if robot_comm['type'] == "EThernet/Wi-Fi":
            ip_address = robot_comm['address']['ip']
            break

    return ip_address


class BinaryUploader:
    def __init__(self, dir_name, target, ip_address):
        self.dir_name = dir_name
        self.target = target
        self.ip_address = ip_address


def uploadSingleRobotBinary(binary_uploader):
    print("upload binary start: " + binary_uploader.dir_name)
    ssh_manager = SSHManager()
    ssh_manager.create_ssh_client(binary_uploader.ip_address)
    #ssh_manager.create_ssh_client("192.168.50.5")
    out = ssh_manager.send_command("mkdir " + UPLOAD_TARGET_DIR) 
    if binary_uploader.target == "OS":
        out = ssh_manager.send_file(os.path.join(binary_uploader.dir_name, "./proc"), os.path.join(UPLOAD_TARGET_DIR, TARGET_OS_BINARY_NAME))
    elif binary_uploader.target == "NonOS":
        out = ssh_manager.send_file(os.path.join(binary_uploader.dir_name, "./build-" + NONOS_BOARD_NAME, binary_uploader.dir_name + ".bin"), os.path.join(UPLOAD_TARGET_DIR, TARGET_NONOS_BINARY_NAME))
        out = ssh_manager.send_command("~/tools/opencr_ld /dev/ttyACM0 115200 " + os.path.join(UPLOAD_TARGET_DIR, TARGET_NONOS_BINARY_NAME) + " 1") 
    ssh_manager.close_ssh_client()
    print("upload binary end: " + binary_uploader.dir_name)
   


def uploadRobotBinary(projectDirPath, dbHandle, robotList):
    uploaded_robot_addr_list = []
    working_dir_path = os.getcwd()
    robotImpl_collection = dbHandle['RobotImpl']
    os.chdir(projectDirPath)
    binary_uploader_list = []
    for file_name in os.listdir("."):
        if os.path.isdir(file_name): 
            os.chdir(file_name)
            robot_name = getMatchedRobotFromDirName(file_name, robotList)
            target = checkBuildTarget()
            ip_address = getUploadTargetIP(robot_name, robotImpl_collection)
            binary_uploader = BinaryUploader(file_name, target, ip_address)
            binary_uploader_list.append(binary_uploader)
            if ip_address not in uploaded_robot_addr_list:
                uploaded_robot_addr_list.append(ip_address)
            os.chdir("..")

    thread_list = []
    for uploader in binary_uploader_list:
        thread = Thread(target=uploadSingleRobotBinary, args=(uploader,))
        thread_list.append(thread)

    for thread in thread_list:
        thread.start()

    for thread in thread_list:
        thread.join()

    os.chdir(working_dir_path)
    return uploaded_robot_addr_list

def writeRobotIpLists(robotAddrList):
    with open(ROBOT_ADDDR_FILE_NAME,'wb') as f:
        pickle.dump(robotAddrList, f)


if platform.system() == "Windows":
    class_path_separator = ";"
else:
    class_path_separator = ":"

project_name = sys.argv[2].rstrip('.bdl')

print("arguments: " + sys.argv[1] + "," + sys.argv[2])


# remove old roboto address file
if os.path.exists(ROBOT_ADDDR_FILE_NAME):
    os.remove(ROBOT_ADDDR_FILE_NAME)


print ("### BIO SW Code generation is started! ###")
process = subprocess.Popen(["java", "-jar", "semo.jar", sys.argv[2], sys.argv[1]])
# stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL can be added to remove HOPES-style messages from UEM Code generator

process.wait()

if process.returncode != 0:
    print("Error is occurred during code generation!")
    sys.exit(1)
print ("### BIO SW Code generation is done! ######")



print ("### BIO SW Build is started! #############")
target_project = getLatestDirectory(generated_dir_path, project_name)

project_dir_path = os.path.join(generated_dir_path, target_project)

buildAllDevices(project_dir_path)
print ("### BIO SW Build is done! ################")


print ("### BIO SW Upload is started! ############")
yaml_info = getYamlConfig(sys.argv[1])
db_handle = getMongoDB(yaml_info)

robot_addr_list = uploadRobotBinary(project_dir_path, db_handle, yaml_info['robotList'])
writeRobotIpLists(robot_addr_list)
print ("### BIO SW Upload is done! ###############")




