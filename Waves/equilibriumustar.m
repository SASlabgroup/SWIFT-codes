function [ustar, U10] = equilibriumustar( SWIFT )
% function to calculate the equilibrium ustar (Phillips 1985)
% based on the fourth moment of the high frequency tail of scalar surface wave spectra
% stored in a SWIFT-compliant matlab structure
%
% [ustar, U10 ] = equilibriumustar( SWIFT );
%
%
% J. Thomson, 9/2018
%           12/2024 include estimate of 10 m wind speed

exponenttolerance = 2; % 0.5
errortolerance = 20; % 3
maxwind = 23; 

ustar = NaN(1,length([SWIFT.time]));
Ip = 2.5;
beta = 0.012;
%fmin = 0.25 * ones(1,length(SWIFT)); % fixed
fmin = 1.1 * 1./[SWIFT.peakwaveperiod]; % dyanmic, based on multiple of Tp
fmax = 0.45 * ones(1,length(SWIFT)); % max freq

if isfield(SWIFT,'wavespectra'),

    for si = 1:length(SWIFT)

        findices = find( SWIFT(si).wavespectra.freq > fmin(si) & SWIFT(si).wavespectra.freq < fmax(si) );

        if length(findices) > 1
            [fit, err] = polyfit(log( SWIFT(si).wavespectra.freq(findices) ), log(SWIFT(si).wavespectra.energy(findices)), 1);
            fitexponent(si) = fit(1);
            fiterror(si) = err.normr;

            df = nanmean( abs( diff(SWIFT(si).wavespectra.freq) ) );

            ustar(si) = nansum( SWIFT(si).wavespectra.energy(findices) .* SWIFT(si).wavespectra.freq(findices).^4 .* 2 .* pi^3 ./ ...
                ( beta .* Ip .* 9.8 *(fmax(si) - fmin(si)) ) )*df;  % Iyer et al, JGR 2022a, Eq 3
        else
            ustar(si) = NaN;
            fitexponent(si) = NaN;
            fiterror(si) = NaN;
        end
    end

else
end

%% QC 
bad = find( abs(fitexponent+4) > exponenttolerance | fiterror > errortolerance ); 

ustar(bad) = NaN;


%% estimate 10 m wind speed
g = 9.8; 
Kappa = 0.41;
nu = 1.48e-5; % m^2/s
alpha = 0.012; % fixed charnock
c_p = g .* [SWIFT.peakwaveperiod] ./ 6.28;
alpha = 0.14 .* (ustar./c_p).^0.61; % wave Charnock
z0 = 0.11 .* nu ./ ustar + alpha .* ustar.^2 ./g; 
U10 = ustar ./ Kappa .* log( 10 ./ z0);

U10 ( U10 > maxwind) = NaN;