% Matlab script to convert a batch of SWIFT matlab structures into NetCDF
%
% J. Thomson, May 2021

close all, clear all

flist = dir('SWIFT*.mat')

for fi=1:length(flist), 

    load(flist(fi).name)

    if exist('SWIFT') == 1

        badindex = false( length(SWIFT),1);
        for si = 1 : length(SWIFT) 
            if isempty(SWIFT(si).ID)
                badindex(si) = true;
            elseif isfield(SWIFT(si).wavespectra, 'energy_alt') && length(SWIFT(si).wavespectra.energy_alt) == 1 ...
                    && SWIFT(si).wavespectra.energy_alt == 9999
                badindex(si) = true;
            end
        end
        SWIFT(badindex) = [];
        disp(flist(fi).name(1:end-4))
        try
            SWIFT2NC(SWIFT,[ flist(fi).name(1:end-4) '.nc'] )
        catch error
            fig=uifigure
            uialert(fig,getReport(error),"Error Message","Interpreter","html");
        end
    else

    end

end