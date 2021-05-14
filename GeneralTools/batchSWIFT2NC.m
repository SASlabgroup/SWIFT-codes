% Matlab script to convert a batch of SWIFT matlab structures into NetCDF
%
% J. Thomson, May 2021

close all, clear all

flist = dir('*SWIFT*.mat')

for fi=1:length(flist), 

    load(flist(fi).name)
%     for si=1:length(SWIFT),
%         SWIFT(si).ID = str2num([flist(fi).name(6:7)]);
%     end
    SWIFT = rmfield(SWIFT,'downlooking');
    SWIFT = rmfield(SWIFT,'uplooking');
    SWIFT = rmfield(SWIFT,'puck');
    %rmfield(SWIFT,'signature')
    
    SWIFT2NC(SWIFT,[ flist(fi).name(1:end-4) '.nc'] )
    
end