#! /usr/bin/env python2.7
'''
Created on May 16, 2014

@author: adioso
'''

import codecs
from struct import unpack_from

# Payload version
_4_0 = '7'


def _checkSize(size, expected, name, p_id):
    if size != expected:
        raise Exception("Payload {} {} size {} expected {}".format(p_id,
                                                                   name,
                                                                   size,
                                                                   expected))


def _getDouble(data, index):
    end = index + 8
    return (unpack_from('d', data[index:end])[0], end)


def _getFloat(data, index):
    end = index + 4
    if end > len(data):
        print('Reached end of data unexpectedly')
    return (unpack_from('f', data[index:end])[0], end)


def _getInt1(data, index):
    end = index + 1
    return (ord(data[index:end]), end)


def _getInt2(data, index):
    end = index + 2
    return (unpack_from('h', data[index:end])[0], end)


def _getInt4(data, index):
    end = index + 4
    return (unpack_from('i', data[index:end])[0], end)


# Get Payload type, current valid types are 2 or 3
def _getPayloadType(data):
    (data_type,) = unpack_from('c', buffer(data[0:1]))
    return (data_type, 1)


def processData(p_id, data):
    # Get Payload type, current valid types are 2 or 3
    (data_type, index) = _getPayloadType(data)
    print("payload type: {}".format(data_type))

    index = 1
    if data_type != _4_0:
        print("Invalid payload type: 0x{}".format(codecs.encode(data_type, 
                                                                "hex")))
        sys.exit(1)

    data_len = len(data)
    while index < data_len:
        print("Index: {}".format(index))
        (sensor_type, index) = _getInt1(data, index)
        (com_port, index) = _getInt1(data, index)
        print("Sensor: {}\tCom Port: {}".format(sensor_type, com_port))

        (size, index) = _getInt2(data, index)
        print("Size: {}".format(size))

        if sensor_type == 50:
            index = _processMicroSWIFT(p_id, data, index, size)

        else:
            raise Exception(
                "Payload {} has unknown sensor type {} at index {}".format(
                    p_id, sensor_type, index))


def _processMicroSWIFT(p_id, data, index, size):
    if size == 0:
        print("MicroSWIFT empty")
        return index

    (hs, index) = _getFloat(data, index)
    print("hs {}".format(hs))
    (tp, index) = _getFloat(data, index)
    print("tp {}".format(tp))
    (dp, index) = _getFloat(data, index)
    print("dp {}".format(dp))

    arrays = [ 'e', 'f', 'a1', 'b1', 'a2', 'b2', 'cf']

    # TODO Get the array data
    for array in arrays:
        # 0 - 41
        for a_index in range(0, 42):
            (val, index) = _getFloat(data, index)
            print("{}{} {}".format(array, a_index, val))

    (lat, index) = _getFloat(data, index)
    print("lat {}".format(lat))
    (lon, index) = _getFloat(data, index)
    print("lon {}".format(lon))
    (mean_temp, index) = _getFloat(data, index)
    print("mean_temp {}".format(mean_temp))
    (mean_voltage, index) = _getFloat(data, index)
    print("mean_voltage {}".format(mean_voltage))
    (mean_u, index) = _getFloat(data, index)
    print("mean_u {}".format(mean_u))
    (mean_v, index) = _getFloat(data, index)
    print("mean_v {}".format(mean_v))
    (mean_z, index) = _getFloat(data, index)
    print("mean_z {}".format(mean_z))
    (year, index) = _getInt4(data, index)
    print("year {}".format(year))
    (month, index) = _getInt4(data, index)
    print("month {}".format(month))
    (day, index) = _getInt4(data, index)
    print("day {}".format(day))
    (hour, index) = _getInt4(data, index)
    print("hour {}".format(hour))
    (min, index) = _getInt4(data, index)
    print("min {}".format(min))
    (sec, index) = _getInt4(data, index)
    print("sec {}".format(sec))

    return index


if __name__ == "__main__":

    import sys

    if len(sys.argv) != 2:
        print("Provide the path to the payload file.")
        sys.exit(1)

    with open(sys.argv[1], "rb") as binfile:
        payload_data = bytearray(binfile.read())

    processData(0, payload_data)
