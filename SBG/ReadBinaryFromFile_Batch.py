#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Thu Dec 15 11:33:31 2016

@author: mike
"""

#import sys
import sbgMessageParse
import os
import re

###### INPUT FILE DIRECTORY #######
fileDirectory = r"/Users/mike/Dropbox/SWIFT_v4.x/Test Data/LakeWA_Test_14Dec2016/SWIFTv4_14Dec2016/SBG/Raw/20161214"
allFiles =  os.listdir(fileDirectory)
allInputFiles = [filename for filename in allFiles if re.match('^(SWIFT)+.*(\.dat)+$',filename)]

# Loop through files
for inputFileName in allInputFiles: 
    outputFileName = inputFileName[:-4] + "_ASCII.txt"  
    # use of "with" ensures input and output files are closed at completion (even if error)              
    with open(fileDirectory + "/" + inputFileName, "rb") as fIn, open(fileDirectory + "/" + outputFileName, "w") as fOut:
        # arbitrary non-empty value to start while loop
        byte = b'\x00' 
        # check that haven't reached end of file
        while byte:        
            byte = fIn.read(1)  
            # check for first sync byte (see Firmware Reference Manual Section 2: sbgECom Binary Protocal)
            if byte == b'\xff':  
                byte = fIn.read(1)
                # check for second sync byte 
                if byte == b'\x5a':  
                    # message ID (see Section 2.3 in Firmware Reference Manual)
                    msgID = fIn.read(1) 
                    # message class (see Section 2.1.2 in Firmware Reference Manual)
                    msgClass = fIn.read(1)
                    # Parse and print messages
                    sbgMessageParse.parseSbgMessage(msgClass,msgID,readFromFile=True,inputFile=fIn,printFlag=True,outputFile=fOut)