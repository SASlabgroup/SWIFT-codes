% Matlab script to convert a batch of SWIFT matlab structures into NetCDF
%
% J. Thomson, May 2021

close all, clear all

flist = dir('SWIFT*.mat');

for fi=1:length(flist)
    try
        load(flist(fi).name)
        SWIFT2NC(SWIFT,[ flist(fi).name(1:end-4) '.nc'] )
        fprintf('Successfully processed: %s\n', flist(fi).name);
    catch ME
        fprintf('Error processing %s: %s\n', flist(fi).name, ME.message);
        fprintf('  at line %d in %s\n', ME.stack(1).line, ME.stack(1).name);
        continue;
    end
end