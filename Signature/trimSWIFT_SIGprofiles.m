function counter = trimSWIFT_SIGprofiles( maxz );
% functoin to trim SWIFT signature profiles to a maximum depth 
% (input to function) from a directory of SWIFT mat files
% could also use altimeter (if enabled) in future versions
%
%   counter = trimSWIFT_SIGprofiles( zmax );
%
% returns the number of profiles coutned
%
% J. Thomson, 9/2017

%maxz = 15;

counter = 0;

flist = dir('*SWIFT*.mat');


for fi=1:length(flist),
    
    load(flist(fi).name)
    if isfield(SWIFT,'signature'),
        for si=1:length(SWIFT),
            
            SWIFT(si).signature.profile.east( SWIFT(si).signature.profile.z > maxz  ) = NaN;
            SWIFT(si).signature.profile.north( SWIFT(si).signature.profile.z > maxz  ) = NaN;
            SWIFT(si).signature.profile.z( SWIFT(si).signature.profile.z > maxz  ) = NaN;
            counter = counter + 1;
        end
        
        %
        % maxz = 4;
        %
        % for si=1:length(SWIFT),
        %     SWIFT(si).signature.HRprofile.tkedissipationrate( SWIFT(si).signature.HRprofile.z > maxz  ) = NaN;
        %     SWIFT(si).signature.HRprofile.z( SWIFT(si).signature.HRprofile.z > maxz  ) = NaN;
        %
        % end
        
        save(flist(fi).name,'SWIFT')
        
    else
    end
end