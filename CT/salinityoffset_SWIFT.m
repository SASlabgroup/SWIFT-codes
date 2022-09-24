% matlab script to correct for offsets in SWIFT CT data at different depths
%
% J. Thomson, Sep 2022

%% load data files

%% loop thru and find means, then adjust to shared mean

numCT = length(SWIFT(1).salinity);  % number of CT sensors (1,2, or 3)

clear salinity

for si=1:length(SWIFT)
    salinity(si,:) = SWIFT(si).salinity(:); 
end

smean = nanmedian(salinity);

%offsets = [1.15 0.3 0]; % steady offsets (for SWIFT 16 during play 4)
%offsets = [1.3 0.3 0]; % steady offsets (for SWIFT 17 during play 4)
%offsets = [NaN 0.18 0]; % steady offsets (for SWIFT 15 during play 4)
%offsets = [0.18 0]; % steady offsets (for SWIFT 12 during play 4)
offsets = median(smean)-smean; % consistent mean
%offsets = max(smean)-smean; % consistent max

for si=1:length(SWIFT)
    SWIFT(si).salinity(:) = SWIFT(si).salinity + offsets; 
end

%% plot and save corrected data

plotSWIFT(SWIFT)