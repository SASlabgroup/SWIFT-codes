#! /usr/bin/python2.7 
#
#Record lines of GPS serial data and send lat lon over satellite modem

import serial, io
import numpy as np
from gpiozero import OutputDevice
import time
import pynmea2
import logging
import struct
logging.basicConfig()

import send_sbd_binary_data
import GPSwavesC
##########################################################################

sbd_addr = '/dev/ttyUSB1'
usb_addr = '/dev/ttyUSB0'
float_id = '0001'        #float id
float_id_short = '01'    #short float id number
project_name = 'TX'
float_data_dir = '/home/pi/Data/'
baud = 9600           #baud rate of serial device
burst_seconds = 10      #number of seconds to record data
burst_interval = 2      #time between calls to record_serial, in minutes
burst_num = 0           #counter
call_interval = 10       #interval between SBD calls, in minutes
frequency = 4           #sampling rate
num_samples = 2048      #frequency * 512
#num_samples = 10
bad = 9999.9
PayLoadType = 7
FormatType = 10
SizeInBytes = 1196
Port = 6


def configure_logging():
 
   # set up logger
   logger = logging.getLogger('record_and_send_gps')
   # set logging level
   logger.setLevel(logging.DEBUG)

   # create file handler which logs messages
   # appends to file if it already exists
   fh = logging.FileHandler('record_and_send_gps.log',mode='a')
   fh.setLevel(logging.DEBUG)

   # create console handler with a higher log level
   ch = logging.StreamHandler()
   ch.setLevel(logging.DEBUG)

   # create formatter and add it to the handlers
   formatter = logging.Formatter('%(asctime)s - %(name)s - %(levelname)s - %(message)s')
   fh.setFormatter(formatter)
   ch.setFormatter(formatter)
   # add the handlers to the logger
   logger.addHandler(fh)
   logger.addHandler(ch)
   return logger

#open serial connection and new file for writing.  Grab incoming lines and write to file
def record_serial( t_end, fname):
    logger = logging.getLogger('record_serial')
    global burst_num
    burst_num += 1
    logger.info('record_serial')
    logger.info('Burst number: ' + str(burst_num))
    #print('Burst number: ' + str(burst_num))
    #print('usb_adr =',usb_addr)
    #print('fname =',fname)
    try:
        with serial.Serial(usb_addr,baud,timeout=.25) as pt, open(fname, 'a') as outf: 
            ser = io.TextIOWrapper(io.BufferedRWPair(pt,pt,1), encoding='ascii',
                    errors='ignore', newline='\r', line_buffering=True)

            #test for incoming data over serial port
            for i in range(5):
               newline = ser.readline()
               print(newline)
               time.sleep(1)   

            gpgga_stc = ''
            gpvtg_stc = ''
            if newline != '':   #make sure there is data
            
                #while loop record n seconds of serial data
                while time.time() <= t_end:
                    newline = ser.readline()  #read one line of text from serial port
                    #print(newline,end='')     #echo line of text on the screen
                    outf.write(newline)       #write the line of text to the file
                    outf.flush()        #make sure it actually gets written out
                    if "GPGGA" in newline:
                        gpgga_stc = newline   #grab gpgga sentence to return
                    if "GPVTG" in newline:
                        gpvtg_stc = newline   #grab gpvtg sentence
            else:
                print("No serial data")
                logger.info('No serial data')
        return gpgga_stc,gpvtg_stc  
            
    except Exception as e1:
        print('error: ' + str(e1 ))
        logger.error('error: ' + str(e1 ))
        return '' ,''
        
def parse_nmea_gpgga(gpgga_stc):
# fields in GPGGA from pynmea2:
#       ('Timestamp', 'timestamp', timestamp),
#       ('Latitude', 'lat'),
#       ('Latitude Direction', 'lat_dir'),
#       ('Longitude', 'lon'),
#       ('Longitude Direction', 'lon_dir'),
#       ('GPS Quality Indicator', 'gps_qual', int),
#       ('Number of Satellites in use', 'num_sats'),
#       ('Horizontal Dilution of Precision', 'horizontal_dil'),
#       ('Antenna Alt above sea level (mean)', 'altitude', float),
#       ('Units of altitude (meters)', 'altitude_units'),
#       ('Geoidal Separation', 'geo_sep'),
#       ('Units of Geoidal Separation (meters)', 'geo_sep_units'),
#       ('Age of Differential GPS Data (secs)', 'age_gps_data'),
#       ('Differential Reference Station ID', 'ref_station_id'))


    # parser for the position line
    logger = logging.getLogger('parse_nmea_gga')

    msg = pynmea2.parse(gpgga_stc, check=True)  #parse gpgga sentence
    
    latlon = str(msg.latitude) + ', ' + str(msg.longitude)     #save lat and lon as a list
    logger.info('latlon = %s',latlon)
    
    lat = msg.latitude
    lat_dir = msg.lat_dir
    lon = msg.longitude
    lon_dir = msg.lon_dir
    date = msg.timestamp
    num_sats = msg.num_sats
    gps_qual = msg.gps_qual
    altitude = msg.altitude 
    altitude_units = msg.altitude_units
    parse_data = {'date':date,'lat':lat,'lat_dir':lat_dir,'lon':lon,'lon_dir':lon_dir,
                  'num_sats':num_sats,'gps_qual':gps_qual,
                   'altitude':altitude,'altitude_units':altitude_units}
    logger.info('parse_data %s',str(parse_data))
    return parse_data #return parse information   

def parse_nmea_gpvtg(gpvtg_stc):
#   Track Made Good and Ground Speed fields:
#       ("True Track made good", "true_track", float),
#       ("True Track made good symbol", "true_track_sym"),
#       ("Magnetic Track made good", "mag_track", Decimal),
#       ("Magnetic Track symbol", "mag_track_sym"),
#       ("Speed over ground knots", "spd_over_grnd_kts", Decimal),
#       ("Speed over ground symbol", "spd_over_grnd_kts_sym"),
#       ("Speed over ground kmph", "spd_over_grnd_kmph", float),
#       ("Speed over ground kmph symbol", "spd_over_grnd_kmph_sym"),
#       ("FAA mode indicator", "faa_mode"))


    # parser for the velocity line
    logger = logging.getLogger('parse_nmea_vtg')

    msg = pynmea2.parse(gpvtg_stc, check=True)  #parse gpvtg sentence

    speed_over_grnd_kmph = msg.spd_over_grnd_kmph
    true_track = msg.true_track
    mag_track=msg.mag_track

    u_vel = speed_over_grnd_kmph*np.cos(true_track)
    v_vel = speed_over_grnd_kmph*np.sin(true_track)
    parse_data = {'speed':speed_over_grnd_kmph,'true_track':true_track,
                  'mag_track':mag_track,'u_vel':u_vel,'v_vel':v_vel}
    logger.info('parse_data',str(parse_data))
    return parse_data #return parse information

        
def main():

    logger = configure_logging()
    irun =0

    u = np.empty(num_samples)
    v = np.empty(num_samples)
    z = np.empty(num_samples)
    lat = np.empty(num_samples)
    lon = np.empty(num_samples)

    numCoef = 42
    WaveSpectra_Energy = np.array(numCoef)
    WaveSpectra_Freq   = np.array(numCoef)
    WaveSpectra_a1 = np.array(numCoef)
    WaveSpectra_b1 = np.array(numCoef)
    WaveSpectra_a2 = np.array(numCoef)
    WaveSpectra_b2 = np.array(numCoef)
    isample = 0
    while True:    
        systime = time.gmtime()
        time.sleep(1)
    
        irun = irun+1

        #make SBD call at call interval as long as there has been at least one burst
        print('systime min= ',systime.tm_min)
        print('call interval= ',call_interval)
        print('burst interval = ',burst_interval)
        print('systime sec= ',systime.tm_sec)
        if systime.tm_min % call_interval == 0 and systime.tm_sec ==0 and burst_num > 0:
            print('--------------- isample = ',isample)
            if isample > 0:
                GPS_waves_results = GPSwavesC.main_GPSwaves(isample,u[0:isample],v[0:isample],z[0:isample],frequency)
                SigwaveHeight = GPS_waves_results[0]
                Peakwave_Period = GPS_waves_results[1]
                Peakwave_dirT = GPS_waves_results[2]
                WaveSpectra_Energy = np.squeeze(GPS_waves_results[3])
                WaveSpectra_Freq   = np.squeeze(GPS_waves_results[4])
                WaveSpectra_a1 = np.squeeze(GPS_waves_results[5])
                WaveSpectra_b1 = np.squeeze(GPS_waves_results[6])
                WaveSpectra_a2 = np.squeeze(GPS_waves_results[7])
                WaveSpectra_b2 = np.squeeze(GPS_waves_results[8])
                checkdata = np.full(numCoef,1)
                print 'RESULTS',GPS_waves_results
                print type(WaveSpectra_a2)

                if(abs(SigwaveHeight) > 1000 or abs(SigwaveHeight) < .000001):
                    print 'Set to BAD',numCoef
                    SigwaveHeight = bad
                    Peakwave_Period = bad
                    Peakwave_dirT = bad
                    WaveSpectra_Energy = np.full(numCoef,bad)
                    WaveSpectra_Freq   = np.full(numCoef,bad)
                    WaveSpectra_a1 = np.full(numCoef,bad)
                    WaveSpectra_b1 = np.full(numCoef,bad)
                    WaveSpectra_a2 = np.full(numCoef,bad)
                    WaveSpectra_b2 = np.full(numCoef,bad)
                    checkdata = np.full(numCoef,0)

                umean = np.mean(u[0:isample])
                vmean = np.mean(v[0:isample])
                zmean = np.mean(z[0:isample])
                print('--- isample = ',isample)
                print('SigwaveHeight, Peakwave_Period, Peakwave_dirT = ',
                       SigwaveHeight, Peakwave_Period, Peakwave_dirT)
                print('umean, vmean, zmean =',umean,vmean,zmean)
                print('u , v , z = ',u[0:isample],v[0:isample],z[0:isample])
                print 'DATE from GPS =',parse_data_pos['date']
                print 'Energy',WaveSpectra_Energy
                                  

            else:
               SigwaveHeight   = bad
               Peakwave_Period = bad
               Peakwave_dirT = bad
               
               umean = bad
               vmean = bad
               zmean = bad

            #send_sbd_data.main(latlon)
            dname = time.strftime('%d%b%Y',systime)
            tname = time.strftime('%H%M%S',systime)

            fbinary_name = (float_data_dir + 'SWIFT'+float_id_short + '_' + 
                       project_name + '_' + 
                       dname + '_' + tname + '.sbd')
            SizeInBytes = (5+7*42)*4

            print 'binary file name',fbinary_name
            logger.info('binary file name = %s',fbinary_name)
            print  'a1',WaveSpectra_a1[0]
            fbinary = open(fbinary_name, 'wb')

            fbinary.write(struct.pack('<sbbhfff',
                str(PayLoadType),FormatType,
                Port,SizeInBytes,SigwaveHeight,Peakwave_Period,Peakwave_dirT))
            fbinary.write(struct.pack('<42f', *WaveSpectra_Energy*0))
            fbinary.write(struct.pack('<42f', *WaveSpectra_Freq*0))
            fbinary.write(struct.pack('<42f', *WaveSpectra_a1*0))
            fbinary.write(struct.pack('<42f', *WaveSpectra_b1*0))
            fbinary.write(struct.pack('<42f', *WaveSpectra_a2*0))
            fbinary.write(struct.pack('<42f', *WaveSpectra_b2*0))
            fbinary.write(struct.pack('<42f', *checkdata))
            fbinary.write(struct.pack('<f',lat[0]))
            fbinary.write(struct.pack('<f',lon[0]))

            fbinary.close()

            logger.info('calling send_sbd_binary_data')
            send_sbd_binary_data.main(float_id_short,PayLoadType,FormatType,
                Port,SizeInBytes,SigwaveHeight,Peakwave_Period,Peakwave_dirT,
                WaveSpectra_Energy,WaveSpectra_Freq, WaveSpectra_a1,
                WaveSpectra_b1,WaveSpectra_a2,WaveSpectra_b2,checkdata,
                lat[0],lon[0])
            logger.info('send sbd_binary_data')
            print('sending sbd data')

        #run record_serial function over burst interval for burst_seconds and create new timestamped file with fname
        elif systime.tm_min % burst_interval == 0:
        # and systime.tm_sec == 0:
            dname = time.strftime('%d%b%Y',systime)
            tname = time.strftime('%H:%M:%S',systime) 
            fname = float_data_dir + float_id + '_GPS_' + dname + '_' + tname +'UTC_burst_' + str(burst_interval) + '.dat'
            logger.info('file name: %s',fname)
            t_end = time.time() + burst_seconds 

            print('reading lines')
            # save lines with position and velocity
            gpgga_stc, gpvtg_stc = record_serial(t_end, fname)

            # do we have any data for position
            numLine=len(gpgga_stc)
            if numLine > 0: 
                parse_data_pos = parse_nmea_gpgga(gpgga_stc)
                logger.info('parse_nmea %s',str(parse_data_pos));
                z[isample] = parse_data_pos['altitude']
                lat[isample] = parse_data_pos['lat']
                lon[isample] = parse_data_pos['lon']
            
            else:
                logger.info('GPS Position error')

            # do we have any data for velocity
            numLine=len(gpvtg_stc)
            if numLine > 0:
                parse_data_vel = parse_nmea_gpvtg(gpvtg_stc)
                logger.info('parse_nmea %s',str(parse_data_vel));
                u[isample] = parse_data_vel['u_vel']
                v[isample] = parse_data_vel['v_vel']
                
            else:
                logger.info('GPS Velocity error')

            print('in loop ',isample,', u=',u[isample],', v=',v[isample],', z = ',z[isample])
            if not u[isample] == bad and not v[isample] == bad and not z[isample] ==  bad:
                isample = isample+1

        logger.info('number of samples = %s',str(isample));

#run main function unless importing as a module
if __name__ == "__main__":
    main()
