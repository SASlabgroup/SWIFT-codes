% matlab script to load and plot raw OpenOBS data from microSWIFTs
%
% J. Thomson, 10/2025

clear all, close all

figure(1), clf

calibrationdirectory =  '/Users/jthomson/Desktop/microSWIFT_realsedimentcals';

dirlist = dir([calibrationdirectory '/microSWIFT*']);

for di = 1:length(dirlist)

    cd([calibrationdirectory '/' dirlist(di).name '/Turbidity/' ])

    flist = dir('*.csv');

    counter = 0; 

    for fi = 1:length(flist)
        
        clear OBS*

        OBS = importdata(flist(fi).name);

        OBSbackscatter(counter + [1:length(OBS.data)]) = OBS.data(:,1); 
        OBSambient(counter + [1:length(OBS.data)]) = OBS.data(:,2);

        for ti = 1:length(OBS.data)
            OBStime(counter + ti) = datenum(string(OBS.textdata(ti+1,1)));  % +1 on the text data index is b/c header line
        end

        counter = counter + length(OBS.data);

    end

    save([dirlist(di).name(1:13) '_OBSrawdata.mat'],'OBS*')

    ax(di) = subplot(length(dirlist),1,di);
    plot(OBStime,OBSbackscatter)
    datetick
    ylabel([dirlist(di).name(11:13)])

end

%linkaxes(ax,'x')

cd(calibrationdirectory)

print('-dpng',['OBSrawdata.png'])