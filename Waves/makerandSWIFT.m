function randSWIFT = makerandSWIFT( SWIFT , dt );
% function to make a random wave timeseries from SWIFT spectra
% for statistical comparisons and testing
%
%   randSWIFT = makerandSWIFT( SWIFT , dt );
% 
% the input and output are SWIFT-compliant strucutres
% and a timestep dt (in seconds)
%
% requires the WAFO toolbox (v2017.1)
% 
% J. Thomson,  12/2018

for si = 1:length(SWIFT)
    
    if any(~isnan(SWIFT(si).wavespectra.energy)) && ~isempty(SWIFT(si).z),
    % convert SWIFT spectra into WAFO spec struct format
    S_Measured = struct();
    S_Measured.date = NaN;
    S_Measured.type = 'freq';
    S_Measured.S = SWIFT(si).wavespectra.energy;
    S_Measured.f = SWIFT(si).wavespectra.freq;
    S_Measured.phi = 0;
    np = length(SWIFT(si).z);
    % create virtual timeseries consistent with spectra
    % using WAFO toolbox spec2nlsdat.m or spec2sdat.m
    randomsea = spec2sdat(S_Measured,[np 1],dt); % note that first column of output is time
    if length(randomsea ) > np,
        randomsea( (np+1):end, :) = [];
    else
    end
    SWIFT(si).z = randomsea(:,2); % replace actual time series with a random sea
    
    end

end

randSWIFT = SWIFT;

end


