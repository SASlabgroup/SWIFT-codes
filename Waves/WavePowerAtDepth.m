function [P Pratio] = WavePowerAtDepth( Hs , Te, z)
% MATLAB function to determine how much wave power (enegry flux) 
% exists below a given depth for a set of wave conditions
% (note that wave power is usually a depth integrated quantity)
%
% Input is sig wave height, energy period, and depth
% Output is wave power (W/m) and ratio of power below that depth to power above
%
% [P Pratio] = WavePowerAtDepth( Hs , Te, z)
%
% This assumes deep water P = ECg, where Cg = gT / 4pi
% 
% should work for vector entries of Hs, Te, z (if they are all the same size)
% whic might be useful to map out parameter space
%
%  J. Thomson, Jun 2019

rho = 1030; %kg/m^3
g = 9.8; % m/s^2
d = inf; 

Ptotal = (rho * g^2) ./ (64*3.14) .* Hs.^2 .* Te;

ke = (2 .* pi ./ Te).^2  ./ g;

decayrate = exp( -ke .* z); % decay of orbtial velocity AND pressure field

powerdecay = decayrate.^2; % energy flux is the "pressure work" integral of p*u, so account for decay of both fields

P = Ptotal .* powerdecay;
Pratio = P ./ Ptotal;

end

