% combine SWIFT structures from separate files into a single structure
% this only works if the structures are the same in each file
% set option to force a "simple SWIFT"


clear all, close all

fpath = './';

filelist = dir('SWIFT*.mat');

forcesimple = true;

Sindex = 0;


for fi=1:length(filelist), 
    
    load(filelist(fi).name),

    if forcesimple
        for ii=1:length(SWIFT)
        simpleSWIFT(ii).time = SWIFT(ii).time;
        simpleSWIFT(ii).lat = SWIFT(ii).lat;
        simpleSWIFT(ii).lon = SWIFT(ii).lon;
        simpleSWIFT(ii).sigwaveheight = SWIFT(ii).sigwaveheight;
        simpleSWIFT(ii).peakwaveperiod = SWIFT(ii).peakwaveperiod;
        simpleSWIFT(ii).peakwavedirT = SWIFT(ii).peakwavedirT;
        simpleSWIFT(ii).wavespectra = SWIFT(ii).wavespectra;
        simpleSWIFT(ii).driftspd = SWIFT(ii).driftspd;
        simpleSWIFT(ii).driftdirT = SWIFT(ii).driftdirT;
        simpleSWIFT(ii).watertemp = SWIFT(ii).watertemp;
        simpleSWIFT(ii).salinity = SWIFT(ii).salinity;
        simpleSWIFT(ii).airtemp = SWIFT(ii).airtemp;
        simpleSWIFT(ii).windspd = SWIFT(ii).windspd;
        end
        
        SWIFT = simpleSWIFT;
    
    end

    names = fieldnames(SWIFT);

    if fi == 1
        
        allSWIFT( Sindex + [1:length(SWIFT)] ) = SWIFT;
        
        allnames = fieldnames(allSWIFT);
        
        Sindex = length(allSWIFT);
        
    elseif fi > 1 && length(names)==length(allnames) && all(all(char(names)==char(allnames)))
        
        allSWIFT( Sindex + [1:length(SWIFT)] ) = SWIFT;
        
        allnames = fieldnames(allSWIFT);
        
        Sindex = length(allSWIFT);
        
    else 
        disp(['skip ' num2str(fi) ' of ' num2str(length(filelist))])
    end
end

clear SWIFT

SWIFT = allSWIFT;

[sortedtimes sti ] = sort([SWIFT.time]);

SWIFT = SWIFT(sti);

%trimSWIFT_SIGprofiles

%plotSWIFT(SWIFT)

wd = pwd;
wdi = find(wd == '/',1,'last');
wd = wd((wdi+1):length(wd));

save([wd '_allSWIFT'],'SWIFT')
    