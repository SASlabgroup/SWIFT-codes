function [north east down] = read_microSWIFTv2_rawdata( filename, pts, plotflag )
% function to read the raw binary data recorded on microSWIFT v2
% Sample window is 8192 samples, data elements are single precision floats (32 bit),
% order of arrays is North, East, Down
%
%   [north east down] = read_microSWIFTv2_rawdata( filename , plotflag );
%
% where plotflag is a binary flag for plotting
%
% J. Thomson, Oct 2023

fid = fopen( filename ); % little of big endian?

north = fread(fid,pts,'single'); % mm/s
east  = fread(fid,pts,'single'); % mm/s
down  = fread(fid,pts,'single'); % mm/s

fclose(fid);

if plotflag

    figure(1), clf
    plot(north), hold on, plot(east), plot(down)
    ylabel('velocity [mm/s]')
    legend('north','east','down')
    xlabel('index')
    print('-dpng',[filename(1:end-4) '_plot.png'])

end