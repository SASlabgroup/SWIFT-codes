function [shear, eps, z] = lawofthewallSWIFT(SWIFT, plotflag) 
%lawofthewallSWIFT Makes an estimate of the Law of the Wall shear and tke
%dissipation given SWIFT data. Model is of same grid as SWIFT data and
%bases this grid on signature 1000 bins. 
%   [shear, eps, z] = lawofthewallSWIFT(SWIFT, plotflag) 
%   Takes in SWIFT structure with fields:
%   SWIFT.signature.HRprofile
%   and calculates a model law of the wall prediction based on Zeiden et.
%   al. 2024 DOI:10.1029/2024JC021399

arguments (Input)
    inputArg1
    inputArg2
end

arguments (Output)
    outputArg1
    outputArg2
end

outputArg1 = inputArg1;
outputArg2 = inputArg2;
end