function [flist, removed] = SWIFT_QC( minsalinity, minwave, maxdrift )
% Matlab function to apply quality control to SWIFT data
% by listing all SWIFT .mat files in directory and screening for 
% low salinity, low wave heights, or fast speeds 
% (all of which indicate a buoy on deck / on shore (i.e., not in the ocean)
%
%   [flist removed] = SWIFT_QC( minsalinity, minwave, maxdrift )
%
%   J. Thomson, Nov 2023

flist = dir('*SWIFT*.mat');

for fi = 1:length(flist)

    load(flist(fi).name)
    original = length(SWIFT);

    if isfield(SWIFT,'salinity')
        badsal = [SWIFT.salinity] < minsalinity | [SWIFT.salinity]>=9999;  % this will break if multiple salinity values (salty SWIFTs)
        SWIFT(badsal) = [];
    end


    if isfield(SWIFT,'sigwaveheight')
        badwave = [SWIFT.sigwaveheight] < minwave | [SWIFT.sigwaveheight]>=9999; 
        SWIFT(badwave) = [];
    end

    if isfield(SWIFT,'driftspd')
        baddrift = [SWIFT.driftspd] > maxdrift; 
        SWIFT(baddrift) = [];
    end

    removed(fi) = original - length(SWIFT);

    save(flist(fi).name,'SWIFT')

end

end