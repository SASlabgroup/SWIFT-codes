function ustar = equilibriumustar( SWIFT );
% function to calculate the equilibrium ustar (Phillips 1985)
% based on the fourth moment of the high frequency tail of scalar surface wave spectra
% stored in a SWIFT-compliant matlab structure
%
% ustar = equilibriumustar( SWIFT );
%
%
% J. Thomson, 9/2018

ustar = NaN(1,length([SWIFT.time]));
Ip = 2.5;
beta = 0.012;
fmin = 0.2; % could be set dyanmically, based on multiple of Tp
fmax = 0.4; % max freq

if isfield(SWIFT,'wavespectra'),
    
    for si = 1:length(SWIFT)
        
        findices = find( SWIFT(si).wavespectra.freq > fmin & SWIFT(si).wavespectra.freq < fmax );
        ustar(si) = nanmean( SWIFT(si).wavespectra.energy(findices) .* SWIFT(si).wavespectra.freq(findices).^4 .* 16 .* pi^4 )...
            ./ ( beta .* Ip .* 9.8 .* 2 .* pi );
    end
    
else
end

ustar = ustar./2; % fix typo in 2013 paper?