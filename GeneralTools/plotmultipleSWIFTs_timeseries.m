% script to plot multiple SWIFTs as time series (with IDs in legend)
% J. Thomson, Sep 2025


clear all, close all

fpath = './';

flist = dir('*SWIFT*.mat');

figure(1), clf
cmap = colormap;

for fi=1:length(flist)

    load(flist(fi).name)
    thiscolor = cmap(round(fi/length(flist)*256),:);
    %SWIFT( [SWIFT.sigwaveheight]==0 ) = [];

    ax(1)= subplot(4,1,1);
    if isfield(SWIFT, 'windspd')
        plot([SWIFT.time],[SWIFT.windspd],'x','color',thiscolor,'linewidth',2,'linewidth',2), hold on
    else
        %plot([SWIFT.time],NaN,'x','color',thiscolor,'linewidth',2), hold on
    end
    datetick
    ylabel('Wind spd [m/s]')

    ax(2) = subplot(4,1,2);
    plot([SWIFT.time],[SWIFT.sigwaveheight],'x','color',thiscolor,'linewidth',2), hold on
    datetick
    ylabel('Wave height [m]')

    ax(3) = subplot(4,1,3);
    if isfield(SWIFT,'watertemp')
        plot([SWIFT.time],[SWIFT.watertemp],'x','color',thiscolor,'linewidth',2), hold on
    else
        %plot([SWIFT.time],NaN,'x','color',thiscolor,'linewidth',2), hold on
    end
    datetick
    ylabel('Water temp [C]')

    ax(4) = subplot(4,1,4);
    if isfield(SWIFT,'salinity')
        plot([SWIFT.time],[SWIFT.salinity],'x','color',thiscolor,'linewidth',2), hold on
    else
        %plot([SWIFT.time],NaN,'x','color',thiscolor,'linewidth',2), hold on
    end
    datetick
    ylabel('Salinity [PSS]')

    ID(fi) = str2num(SWIFT(1).ID);

end

%% legend
axes(ax(2))
legend(num2str(ID'))
linkaxes(ax,'x')


