% script to plot multiple SWIFTs as time series (with IDs in legend)
% J. Thomson, Sep 2025


clear all, close all

fpath = './';

filelist = dir('*SWIFT*.mat');


for fi=1:length(filelist)

    load(filelist(fi).name)

    subplot(4,1,1)
    if isfield(SWIFT, 'windspd')
        plot([SWIFT.time],[SWIFT.windspd],'x'), hold on
    else
        plot([SWIFT.time],NaN,'x'), hold on
    end
    datetick
    ylabel('Wind spd [m/s]')

    subplot(4,1,2)
    plot([SWIFT.time],[SWIFT.sigwaveheight],'x'), hold on
    datetick
    ylabel('Wave height [m]')

    subplot(4,1,3)
    if isfield(SWIFT,'watertemp')
        plot([SWIFT.time],[SWIFT.watertemp],'x'), hold on
    else
        plot([SWIFT.time],NaN,'x'), hold on
    end
    datetick
    ylabel('Water temp [C]')

    subplot(4,1,4)
    if isfield(SWIFT,'salinity')
        plot([SWIFT.time],[SWIFT.salinity],'x'), hold on
    else
        plot([SWIFT.time],NaN,'x'), hold on
    end
    datetick
    ylabel('Salinity [PSS]')

    ID(fi,:) = SWIFT(1).ID;

end

legend(ID)

