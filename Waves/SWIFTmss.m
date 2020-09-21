function [mss, mssnorm] = SWIFTmss( SWIFT )
% function to calculate mean square slope from the wave spectra in a SWIFT data structure
% outputs are mss, and mss normalize by the width of the frequency range 
%
%   [mss, mssnorm] = SWIFTmss( SWIFT );
%
% J. Thomson, Sept 2020

fmin = 0.3; % could be set dyanmically, based on multiple of Tp
fmax = 0.45; % max freq

if isfield(SWIFT,'wavespectra'),
    for si = 1:length(SWIFT), 
        df = mean(diff( SWIFT(si).wavespectra.freq ));
        findices = find( SWIFT(si).wavespectra.freq > fmin & SWIFT(si).wavespectra.freq < fmax );
        mss(si) = nansum( (2*3.14*SWIFT(si).wavespectra.freq(findices)).^4 .* SWIFT(si).wavespectra.energy(findices) ) .* df ./ (9.8^2);
    end
else
    mss = NaN(length(SWIFT));
end

mssnorm = mss ./ (fmax-fmin);


end

