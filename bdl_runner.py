#!/usr/bin/python3

import os
import sys
import subprocess
import platform

#project_dir_path = "projects"

#argument1_path = "test_sdf_matrix_2022_04_12_15_41_11"
#argument2_path = "test_sdf_matrix"

generated_dir_path="generated"

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

def buildOSTarget():
    os.environ["PKG_CONFIG_LIBDIR"] = "/home/caplab/cross_env/usr/local/lib/arm-linux-gnueabihf/pkgconfig:/home/caplab/cross_env/usr/lib/arm-linux-gnueabihf/pkgconfig:/home/caplab/cross_env/usr/share/pkgconfig"
    os.system("chmod +x ./preinstall.sh")
    os.system("./preinstall.sh")
    os.system("./configure CFLAGS=\"--sysroot=/home/caplab/cross_env -O2\"  CXXFLAGS=\"--sysroot=/home/caplab/cross_env -O2\" --host=arm-linux-gnueabihf")
    os.system("make -j")

def buildNonOSTarget():
    os.environ["PKG_CONFIG_LIBDIR"] = ""
    os.system("make -j")

def buildAllDevices(projectDirPath):
    working_dir_path = os.getcwd()
    os.chdir(projectDirPath)
    for file_name in os.listdir("."):
        if os.path.isdir(file_name):
            os.chdir(file_name)
            target = checkBuildTarget()
            if target == "OS":
                buildOSTarget()
            elif target == "NonOS":
                buildNonOSTarget()
            os.chdir("..")

    os.chdir(working_dir_path)



if platform.system() == "Windows":
    class_path_separator = ";"
else:
    class_path_separator = ":"

project_name = sys.argv[2].rstrip('.bdl')

print("argument: " + sys.argv[1] + "," + sys.argv[2])

print ("BIO SW Code generation is started!")
process = subprocess.Popen(["java", "-jar", "semo.jar", sys.argv[2], sys.argv[1]])
                    # stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL can be added to remove HOPES-style messages from UEM Code generator

process.wait()
print ("BIO SW Code generation is done!")

print ("BIO SW Build is started!")

target_project = getLatestDirectory(generated_dir_path, project_name)

project_dir_path = os.path.join(generated_dir_path, target_project)

buildAllDevices(project_dir_path)

print ("BIO SW Build is done!")

