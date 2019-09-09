% script to look through at collection of SWIFT files and add wind products
% to any SWIFTs that do not have wind, based on closest SWIFT with wind
%

clear all, close all

%pwd

flist = dir('SWIFT*.mat');

counter = 0;

%% loop through and find all valid wind products first, accumulate array
for fi = 1:length(flist),
    
    load(flist(fi).name)
    
    if isfield(SWIFT,'windspd') && ~all(isnan([SWIFT.windspd]))
        windspd(counter + [1:length(SWIFT)])  = [SWIFT.windspd];
        lat(counter + [1:length(SWIFT)])  = [SWIFT.lat];
        lon(counter + [1:length(SWIFT)])  = [SWIFT.lon];
        time(counter + [1:length(SWIFT)])  = [SWIFT.time];
        
        if isfield(SWIFT,'windustar')
            windustar(counter + [1:length(SWIFT)])  = [SWIFT.windustar];
        else
            windustar(counter + [1:length(SWIFT)])  = NaN;    
        end
        
        counter = length(time);
    end
    
end

figure(1),
plot(time,windspd,'bx')
datetick
ylabel('Wind Spd [m/s]')

%% loop again and fill missing winds using the collocate function for find the nearest wind

 for fi = 1:length(flist),
    
    load(flist(fi).name)
    
    if ~isfield(SWIFT,'windspd') | all(isnan([SWIFT.windspd]))
        
        [i_other, otherDist,TimeDiff] = collocateSWIFT(SWIFT, time, lat, lon);
        
        for i=1:length(SWIFT), 
            SWIFT(i).windspd = windspd( i_other(i) );
            SWIFT(i).windustar = windustar( i_other(i) );
        end

    save([ flist(fi).name(1:(end-4)) '_windadded'],'SWIFT')
    hold on, plot([SWIFT.time],[SWIFT.windspd],'r+')
    
    end
    
 end

 legend('original','added')


