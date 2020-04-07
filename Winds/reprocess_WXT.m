% reprocess SWIFT Vaisala WXT files
% loop thru raw data for a given SWIFT deployment, then
% replace values in the SWIFT data structure of results
% (assuming concatSWIFTv3_processed.m has already been run.
%
%
% J. Thomson, 4/2020 (derived from reprocess_AQD.m)

clear all; close all
readraw = false;
parentdir = './';
parentdir = pwd;


%% load existing SWIFT structure created during concatSWIFTv3_processed, replace only the new results
cd(parentdir);
wd = pwd;
wdi = find(wd == '/',1,'last');
wd = wd((wdi+1):length(wd));

load([ wd '.mat'])

if isfield(SWIFT(1),'signature'),
    SWIFTversion = 4;
else
    SWIFTversion = 3;
end

cd('WXT/Raw/')


%% loop thru raw data

dirlist = dir('20*');

for di = 1:length(dirlist),
    
    cd([dirlist(di).name])
    filelist = dir('*.dat');
    
    for fi=1:length(filelist),
        
        if filelist(fi).bytes > 0,
            
        % read or load raw data
        if isempty(dir([filelist(fi).name(1:end-4) '.mat'])) | readraw,
            [winddirR windspd airtemp relhumidity airpres rainaccum rainint ] = ...
                readSWIFT_WXT( filelist(fi).name );
        else
            load([filelist(fi).name(1:end-4) '.mat']),
        end
        
        time = datenum(filelist(fi).name(13:21)) + str2num(filelist(fi).name(23:24))./24 ...
            + str2num(filelist(fi).name(26:27))./(24*6);
        % match time to SWIFT structure and replace values
        [tdiff, tindex] = min(abs([SWIFT.time]-time));
        SWIFT_tindex(di,fi) = tindex;
        %tindex
        
        SWIFT(tindex).winddirR = nanmean(winddirR); % mean wind direction (deg relative)
        SWIFT(tindex).winddirRstddev =  nanstd(winddirR); % std dev of wind direction (deg)
        SWIFT(tindex).windspd = nanmean(windspd); % mean wind speed (m/s)
        SWIFT(tindex).windspdstddev = nanstd(windspd);  % std dev of wind spd (m/s)
        SWIFT(tindex).airtemp = nanmean(airtemp); % deg C
        SWIFT(tindex).airtempstddev = nanstd(airtemp); % deg C
        SWIFT(tindex).relhumidity = nanmean(relhumidity); % percent
        SWIFT(tindex).relhumiditystddev = nanstd(relhumidity); % percent
        SWIFT(tindex).airpres = nanmean(airpres); % millibars
        SWIFT(tindex).airpresstddev = nanstd(airpres); % millibars
        SWIFT(tindex).rainaccum = nanmean(rainaccum); % millimeters
        SWIFT(tindex).rainint = nanmean(rainint); % millimeters_per_hour
        
        if ~isempty(SWIFTversion) && SWIFTversion==3,
            SWIFT(tindex).metheight = 0.84; % height of measurement, meters
        elseif ~isempty(SWIFTversion) && SWIFTversion==4,
            SWIFT(tindex).metheight = 0.4; % height of measurement, meters
        else
            SWIFT(tindex).metheight = 0.4; % height of measurement, meters
        end
        
        else
        end
    end
    
    cd('../')
    
end


%If SWIFT structure elements not replaced, fill variables with NaNs
for i = 1:length(SWIFT)
    if ~isfield(SWIFT(i),'windspd') | isempty(SWIFT(i).windspd),
        disp(['bad data at index ' num2str(i)])
        SWIFT(i).winddirR = NaN;
        SWIFT(i).winddirRstddev =  NaN;
        SWIFT(i).windspd = NaN;
        SWIFT(i).windspdstddev = NaN;
        SWIFT(i).airtemp = NaN;
        SWIFT(i).airtempstddev = NaN;
        SWIFT(i).relhumidity = NaN;
        SWIFT(i).relhumiditystddev = NaN;
        SWIFT(i).airpres = NaN;
        SWIFT(i).airpresstddev = NaN;
        SWIFT(i).rainaccum = NaN;
        SWIFT(i).rainint = NaN;
    end
end


cd(parentdir)

save([ wd '_reprocessedWXT.mat'],'SWIFT')

plotSWIFT(SWIFT)


