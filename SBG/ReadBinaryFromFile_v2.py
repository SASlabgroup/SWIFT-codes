# -*- coding: utf-8 -*-
"""
Created on Wed Dec  7 22:10:25 2016

@author: JTalbert
"""
import sys
import sbgMessageParse
###### INPUT FILE NAMES #######
inputFileName = r"/Users/mike/Dropbox/SWIFT_v4.x/Test Data/LakeWA_Test_14Dec2016/SWIFTv4_14Dec2016/SBG/Raw/20161214/SWIFT11_SBG_14Dec2016_20_02.dat"
outputFileName = r"/Users/mike/Dropbox/SWIFT_v4.x/Test Data/LakeWA_Test_14Dec2016/SWIFTv4_14Dec2016/SBG/Raw/20161214/SWIFT11_SBG_14Dec2016_20_02_ASCII.txt"

                    
with open(inputFileName, "rb") as fIn, open(outputFileName, "w") as fOut:
    # use of "with" ensures input and output files are closed at completion (even if error)
    byte = b'\x00' # arbitrary non-empty value to start while loop
    while byte:    # check that haven't reached end of file    
        byte = fIn.read(1)  
        if byte == b'\xff':  # check for first sync byte (see Firmware Reference Manual Section 2: sbgECom Binary Protocal)
            byte = fIn.read(1)
            if byte == b'\x5a':  # check for second sync byte 
                msgID = fIn.read(1)  # message ID (see Section 2.3 in Firmware Reference Manual)
                msgClass = fIn.read(1) # message class (see Section 2.1.2 in Firmware Reference Manual)
                sbgMessageParse.parseSbgMessage(msgClass,msgID,readFromFile=True,inputFile=fIn,printFlag=True,outputFile=fOut)