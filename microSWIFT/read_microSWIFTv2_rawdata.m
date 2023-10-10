function [north east down] = read_microSWIFTv2_rawdata( filename, plotflag )
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

north = fread(fid,8192,'single'); % mm/s
east  = fread(fid,8192,'single'); % mm/s
down  = fread(fid,8192,'single'); % mm/s

if plotflag

    figure,
    plot(north), hold on, plot(east), plot(down)
    ylabel('velocity [mm/s]')
    legend('north','east','down')
    xlabel('index')
    print('-dpng',[filename(1:end-4) '_plot.png'])

end