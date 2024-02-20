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

#ARDUINO_DIR = "/home/caplab/arduino-ide_2.0.1_Linux_64bit"
#PKG_CONFIG_DIR = "/home/caplab/cross_env/usr/local/lib/arm-linux-gnueabihf/pkgconfig:/home/caplab/cross_env/usr/lib/arm-linux-gnueabihf/pkgconfig:/home/caplab/cross_env/usr/share/pkgconfig"
#PKG_CONFIG_DIR = "/home/caplab/cross_env_aarch64/usr/lib/aarch64-linux-gnu/pkgconfig:/home/caplab/cross_env_aarch64/usr/lib/aarch64-linux-gnu/openmpi/lib/pkgconfig:/home/caplab/cross_env_aarch64/usr/lib/aarch64-linux-gnu/open-coarrays/openmpi/pkgconfig:/home/caplab/cross_env_aarch64/usr/lib/pkgconfig:/home/caplab/cross_env_aarch64/usr/share/pkgconfig"
#SYSROOT_DIR = "/home/caplab/cross_env"
#SYSROOT_DIR = "/home/caplab/cross_env_aarch64"
#COMPILER_TARGET = "arm-linux-gnueabihf"
#COMPILER_TARGET = "aarch64-linux-gnu"

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


def getCompileOptionDB(device_name, db_handle, yaml_info):
    if "environment" in yaml_info and yaml_info['environment'] == "simulation":  # simulation
        simulDevice_collection = db_handle['SimulationDevice']
        simul_device = simulDevice_collection.find_one({"DeviceId": device_name}) 
        archi_name = simul_device['Architecture']
####################################
    else: # real robot
        robotImpl_collection = db_handle['RobotImpl']
        robot_name = getMatchedRobotFromDirName(device_name, yaml_info['robotList'])
        archi_name = device_name[len(robot_name)+1:]
        #robot_impl = robotImpl_collection.find_one({"RobotId": robot_name})
        #robot = robot_impl['RobotClass']
        #robot['Architecture']['architectureList']
    compile_option = db_handle['CompileOption'].find_one({"DeviceName": archi_name})
    return compile_option

def setBuildEnvironment(device_name, db_handle, yaml_info):
    compile_option = getCompileOptionDB(device_name, db_handle, yaml_info)
    if bool(compile_option['CrossCompile']) is True:
        #compile_option['CrossCompile']['EnvironmentVariable']
        if 'PkgConfigDir' in compile_option['CrossCompile']:
            os.environ["PKG_CONFIG_LIBDIR"] =  ':'.join(compile_option['CrossCompile']['PkgConfigDir'])
        if 'SysRoot' in compile_option['CrossCompile']:
            os.environ["SYSROOT_DIR"] =  compile_option['CrossCompile']['SysRoot']

        for env_item in compile_option['CrossCompile']['EnvironmentVariable']:
            os.environ[env_item['name']] = env_item['value']
    else:
        os.environ["PKG_CONFIG_LIBDIR"] = ""
        os.environ["SYSROOT_DIR"] =  ""

    return compile_option

def buildOSTarget(device_name, db_handle, yaml_info):
    compile_option = setBuildEnvironment(device_name, db_handle, yaml_info)

    include_list = compile_option['IncludePaths']
    library_list = compile_option['LibraryPaths']
    extra_cxxflags = compile_option['ExtraCXXFlags']
    include_flags = " -I".join(include_list)
    library_flags = " -L".join(library_list)
    cxx_flags = " ".join(extra_cxxflags)
    if len(include_flags) > 0:
        include_flags = "-I" + include_flags
    if len(library_flags) > 0:
        library_flags = "-L" + library_flags

    sysroot_dir = ""
    compiler_host = ""

    if bool(compile_option['CrossCompile']) is True:
        cross_compile_option = compile_option['CrossCompile']
        
        if 'SysRoot' in cross_compile_option:
            sysroot_dir = "--sysroot=${SYSROOT_DIR}"
        if 'CompilerTarget' in cross_compile_option:
            compiler_host = "--host=" + cross_compile_option['CompilerTarget']
 
    full_cflags = "CFLAGS=\"-O2 -g " + sysroot_dir + " " + include_flags  +  "\""
    full_cxxflags = "CXXFLAGS=\"-O2 -g " + sysroot_dir +  " " + include_flags + " " + cxx_flags + "\""
    if len(library_flags) > 0:
        full_ldflags = "LDFLAGS=\"" + library_flags + "\""
    else:
        full_ldflags = ""

    runCommand("chmod +x ./preinstall.sh")
    runCommand("./preinstall.sh")
    runCommand("./configure " + full_cflags + " " + full_cxxflags + " " + full_ldflags +  " " + compiler_host)
       
    runCommand("make -j")

def buildNonOSTarget():
    setBuildEnvironment(device_name, db_handle, yaml_info)
    runCommand("make -j")

def buildAllDevices(projectDirPath, yaml_info, db_handle):
    working_dir_path = os.getcwd()
    os.chdir(projectDirPath)
    for file_name in os.listdir("."):
        if os.path.isdir(file_name):
            os.chdir(file_name)
            target = checkBuildTarget()
            try:
                if target == "OS":
                    buildOSTarget(file_name, db_handle, yaml_info)
                elif target == "NonOS":
                    buildNonOSTarget(file_name, db_handle, yaml_info)
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


def getUploadInfo(device_info, device_name, db_handle, yaml_info):
    if device_info['UploadInfo']['type'] == "ssh":
        ip_address = device_info['UploadInfo']['address']['ip']
        user_name = device_info['UploadInfo']['address']['username']
        compile_option = getCompileOptionDB(device_name, db_handle, yaml_info)
        pre_run_commands = compile_option['PreRunCommands']
        post_run_commands = compile_option['PostRunCommands']
        return ip_address, user_name, pre_run_commands, post_run_commands


def getInfoOfUploadTarget(robotName, device_name, db_handle, yaml_info):
    robotImpl_collection = db_handle['RobotImpl']
    robot_comm = robotImpl_collection.find_one({"RobotId": robotName})

    return getUploadInfo(robot_comm, device_name, db_handle, yaml_info)


def getInfoOfUploadSimulation(simulationDeviceName, db_handle, yaml_info):
    simulDevice_collection = db_handle['SimulationDevice']
    simul_comm = simulDevice_collection.find_one({"DeviceId": simulationDeviceName})

    return getUploadInfo(simul_comm, simulationDeviceName, db_handle, yaml_info)


class BinaryUploader:
    def __init__(self, dir_name, target, ip_address, user_name):
        self.dir_name = dir_name
        self.target = target
        self.ip_address = ip_address
        self.user_name = user_name


def uploadSingleBinary(binary_uploader):
    print("upload binary start: " + binary_uploader.dir_name + "," + binary_uploader.ip_address)
    ssh_manager = SSHManager()
    ssh_manager.create_ssh_client(binary_uploader.ip_address, binary_uploader.user_name)
    #ssh_manager.create_ssh_client("192.168.50.5")
    out = ssh_manager.send_command("mkdir " + UPLOAD_TARGET_DIR) 
    if binary_uploader.target == "OS":
        out = ssh_manager.send_file(os.path.join(binary_uploader.dir_name, "./proc"), os.path.join(UPLOAD_TARGET_DIR, TARGET_OS_BINARY_NAME))
    elif binary_uploader.target == "NonOS":
        out = ssh_manager.send_file(os.path.join(binary_uploader.dir_name, "./build-" + NONOS_BOARD_NAME, binary_uploader.dir_name + ".bin"), os.path.join(UPLOAD_TARGET_DIR, TARGET_NONOS_BINARY_NAME))
        out = ssh_manager.send_command("~/tools/opencr_ld /dev/ttyACM0 115200 " + os.path.join(UPLOAD_TARGET_DIR, TARGET_NONOS_BINARY_NAME) + " 1") 
    ssh_manager.close_ssh_client()
    print("upload binary end: " + binary_uploader.dir_name)
   

def updateUploadedRobotAddrMap(uploaded_robot_addr_map, ip_address, user_name, pre_run_commands, post_run_commands):
    if ip_address not in uploaded_robot_addr_map:
        exec_info_map = {}
        exec_info_map['username'] = user_name
        exec_info_map['PreRunCommands'] = pre_run_commands
        exec_info_map['PostRunCommands'] = post_run_commands
        uploaded_robot_addr_map[ip_address] = exec_info_map
    else:
        uploaded_robot_addr_map[ip_address]['PreRunCommands'].extend(pre_run_commands)
        uploaded_robot_addr_map[ip_address]['PostRunCommands'].extend(post_run_commands)
    return uploaded_robot_addr_map


def makeBinaryUploaderFromSimulationDeviceList(db_handle, yaml_info):
    uploaded_robot_addr_map = {}
    binary_uploader_list = []
    for file_name in os.listdir("."):
        if os.path.isdir(file_name): 
            os.chdir(file_name)
            target = checkBuildTarget()
            # file_name is a simulation device name
            ip_address, user_name, pre_run_commands, post_run_commands = getInfoOfUploadSimulation(file_name, db_handle, yaml_info)
            binary_uploader = BinaryUploader(file_name, target, ip_address, user_name)
            binary_uploader_list.append(binary_uploader)
            uploaded_robot_addr_map = updateUploadedRobotAddrMap(uploaded_robot_addr_map, ip_address, user_name, pre_run_commands, post_run_commands)
            os.chdir("..")
    return binary_uploader_list, uploaded_robot_addr_map


def makeBinaryUploaderFromRobotList(db_handle, robotList, yaml_info):
    uploaded_robot_addr_map = {}
    binary_uploader_list = []
    for file_name in os.listdir("."):
        if os.path.isdir(file_name): 
            os.chdir(file_name)
            robot_name = getMatchedRobotFromDirName(file_name, robotList)
            target = checkBuildTarget()
            ip_address, user_name, pre_run_commands, post_run_commands = getInfoOfUploadTarget(robot_name, file_name, db_handle, yaml_info)
            binary_uploader = BinaryUploader(file_name, target, ip_address, user_name)
            binary_uploader_list.append(binary_uploader)
            uploaded_robot_addr_map = updateUploadedRobotAddrMap(uploaded_robot_addr_map, ip_address, user_name, pre_run_commands, post_run_commands)
            os.chdir("..")
    return binary_uploader_list, uploaded_robot_addr_map


def uploadDeploymentBinary(projectDirPath, db_handle, uploadIdList, isSimulation, yaml_info):
    working_dir_path = os.getcwd()
    os.chdir(projectDirPath)
    if isSimulation is True:
        binary_uploader_list, uploaded_robot_addr_map = makeBinaryUploaderFromSimulationDeviceList(db_handle, yaml_info)
    else:
        binary_uploader_list, uploaded_robot_addr_map = makeBinaryUploaderFromRobotList(db_handle, uploadIdList, yaml_info)

    thread_list = []
    for uploader in binary_uploader_list:
        thread = Thread(target=uploadSingleBinary, args=(uploader,))
        thread_list.append(thread)

    for thread in thread_list:
        thread.start()

    for thread in thread_list:
        thread.join()

    os.chdir(working_dir_path)
    return uploaded_robot_addr_map

def writeRobotIpMap(robotAddrMap):
    with open(ROBOT_ADDDR_FILE_NAME,'wb') as f:
        pickle.dump(robotAddrMap, f)


if platform.system() == "Windows":
    class_path_separator = ";"
else:
    class_path_separator = ":"

project_name = sys.argv[2].rstrip('.bdl')

print("arguments: " + sys.argv[1] + "," + sys.argv[2])


# remove old robot address file
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

yaml_info = getYamlConfig(sys.argv[1])
db_handle = getMongoDB(yaml_info)

print ("### BIO SW Build is started! #############")
target_project = getLatestDirectory(generated_dir_path, project_name)

project_dir_path = os.path.join(generated_dir_path, target_project)

buildAllDevices(project_dir_path, yaml_info, db_handle)
print ("### BIO SW Build is done! ################")


print ("### BIO SW Upload is started! ############")

if "environment" in yaml_info and yaml_info['environment'] == "simulation":
    upload_list = [] # simulation list is obtained by the file name, not from configuration
    isSimulation = True
else:
    upload_list = yaml_info['robotList']
    isSimulation = False

robot_addr_map = uploadDeploymentBinary(project_dir_path, db_handle, upload_list, isSimulation, yaml_info)

writeRobotIpMap(robot_addr_map)
print ("### BIO SW Upload is done! ###############")


# list 
# internal : dictionary

# "ip" 
# "username"
# "PreRunCommands"
# "PostRunCommands"












