function crc = sbgCalcCRC(pBytesArray)
% 16 bit CRC of sbgECom frame bytes (ID, class, length and payload): calcCRC
% from the sbgECom Firmware Reference Manual SBGFWM 2.4, 2.1.3 CRC
% definition, line for line. Bit by bit and slow: sbgBinaryToMatlab uses it
% to build its lookup table, test_sbgBinaryToMatlab as the reference CRC.
%   crc = sbgCalcCRC(bytes)   bytes: vector of byte values 0-255
%
% Changelog:
% M. LeClair w/ claude, Nov 2026

pBytesArray = double(pBytesArray);
poly = 33800; % 0x8408
crc = 0;
for j = 1:numel(pBytesArray)
    crc = bitxor(crc,pBytesArray(j));
    for i = 1:8
        carry = bitand(crc,1);
        crc = floor(crc/2); % integer division, as in C
        if carry
            crc = bitxor(crc,poly);
        end
    end
end
end
