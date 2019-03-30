function counter = fixSWIFT_SIGHRdepths( zoffset, zmax );
% functoin to add an offset to SWIFT signature HR profiles  
% (input to function) from a directory of SWIFT mat files
%
% the HR depths were incorrectly set in early versions of processing code
% first HR bin should be 0.32 once corrected
%
% can also apply a cutoff for the max z (becaues data noisy at large range)
%
%   counter = fixSWIFT_SIGHRdepths( zoffset, zmax );
%
% returns the number of profiles coutned
%
% J. Thomson, 3/2019

counter = 0;

flist = dir('*SWIFT2*.mat');


for fi=1:length(flist),
    
    load(flist(fi).name)
    if isfield(SWIFT,'signature'),
        
        for si=1:length(SWIFT),
            
            z = SWIFT(si).signature.HRprofile.z; 
            SWIFT(si).signature.HRprofile.z = z + zoffset;
            SWIFT(si).signature.HRprofile.tkedissipationrate( SWIFT(si).signature.HRprofile.z > zmax  ) = NaN;
            counter = counter + 1;
        end 
        
        save(flist(fi).name,'SWIFT')
        
    else
    end
end