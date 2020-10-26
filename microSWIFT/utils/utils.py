import datetime
from datetime import datetime
import time

# Names files created with current date and time and return it
def currentTimeString():    
    # Name the file according to the current time and date  
    dataFile = datetime.strftime(datetime.now(), "%Y%m%d%H%M%S")
    return dataFile

def ConvertVolts(data,places):
  volts = data * (3300 / 1023.0)
  volts = round(volts,places)
  return volts

#----------------------------------------------------------------
# Function to calculate temperature from
# TMP36 data, rounded to specified
# number of decimal places.
# ADC Value
# (approx)  Temp  Volts
#    0      -50    0.00
#   78      -25    0.25
#  155        0    0.50
#  233       25    0.75
#  310       50    1.00
#  465      100    1.50
#  775      200    2.50
# 1023      280    3.30
#--------------------------------------------------------------
def ConvertTemp(volts,places): 
  temp = ((volts-100)/10)-40.0
  temp = round(temp,places)
  return temp
# Channel must be an integer 0-7
def ReadChannel(channel):
  adc = spi.xfer2([1,(8+channel)<<4,0])
  data = ((adc[1]&3) << 8) + adc[2]
  return data