% Matlab script to convert a batch of SWIFT matlab structures into NetCDF
%
% J. Thomson, May 2021

close all, clear all

flist = dir('*SWIFT*.mat')

for fi=1:length(flist), 

    load(flist(fi).name,'SWIFT')
    
    SWIFT2NC(SWIFT,[ flist(fi).name(1:end-4) '.nc'] )
    
end