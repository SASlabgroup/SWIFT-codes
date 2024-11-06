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
fmin = 0.25; % could be set dyanmically, based on multiple of Tp
fmax = 0.5; % max freq

if isfield(SWIFT,'wavespectra'),

    for si = 1:length(SWIFT)

        findices = find( SWIFT(si).wavespectra.freq > fmin & SWIFT(si).wavespectra.freq < fmax );

        if length(findices) > 1
            fit = polyfit(log( SWIFT(si).wavespectra.freq(findices) ), log(SWIFT(si).wavespectra.energy(findices)), 1);
            fitexponent(si) = fit(1);

            df = nanmean( abs( diff(SWIFT(si).wavespectra.freq) ) );

            ustar(si) = nansum( SWIFT(si).wavespectra.energy(findices) .* SWIFT(si).wavespectra.freq(findices).^4 .* 2 .* pi^3 ./ ...
                ( beta .* Ip .* 9.8 *(fmax - fmin) ) )*df;  % Iyer et al, JGR 2022a, Eq 3
        else
            ustar(si) = NaN;
            fitexponent(si) = NaN;
        end
    end

else
end

%% QC 
bad = find( abs(fitexponent+4) > 1 ); 

ustar(bad) = NaN;

