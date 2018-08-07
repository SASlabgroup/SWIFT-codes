function SWIFT = SWIFTdoppler(SWIFT);
% function to adjust SWIFT scalar wave spectra from intrinsic reference frame to
% absolute referece frame, but applying u*k adjustment 
% This is approximate, because k only known from assuming deep-water dispersion
% (it would be better to itterate until a consistent k is found)
% input and output are standard SWIFT structures 
% 
% J. Thomson Feb 2017
%

for si=1:length(SWIFT); 
    
    
    % determine compoents of drift
    ueast = SWIFT(si).driftspd .* cosd(SWIFT(si).driftdirT);
    unorth = SWIFT(si).driftspd .* sind(SWIFT(si).driftdirT);
    
    % determine components of vector k
    k = (6.28 .* SWIFT(si).wavespectra.freq).^2 ./ 9.8; % deep water dispersion
    
    [Etheta theta f dir spread spread2 spread2alt ] = SWIFTdirectionalspectra(SWIFT(si), 0);

    keast  = k .* cosd(dir);
    knorth = k .* cosd(dir);
    
    % Doppler shift
    shift = ueast.*keast + unorth.*knorth;
    
    SWIFT(si).wavespectra.omega = 6.28*SWIFT(si).wavespectra.freq + shift;
    
end

    
   

