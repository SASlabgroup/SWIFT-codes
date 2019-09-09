% combine SWIFT structures from separate files into a single structure

clear all, close all

fpath = './';

filelist = dir('*.mat');

Sindex = 0;

for fi=1:length(filelist), 
    
    load(filelist(fi).name),
    
    allSWIFT( Sindex + [1:length(SWIFT)] ) = SWIFT;
    
    Sindex = length(allSWIFT);
    
end

clear SWIFT

SWIFT = allSWIFT;

[sortedtimes sti ] = sort([SWIFT.time]);

SWIFT = SWIFT(sti);

%trimSWIFT_SIGprofiles

plotSWIFT(SWIFT)

wd = pwd;
wdi = find(wd == '/',1,'last');
wd = wd((wdi+1):length(wd));

save(wd,'SWIFT')
    