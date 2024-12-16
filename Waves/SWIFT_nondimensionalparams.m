function nondim=SWIFT_nondimensionalparams(SWIFT,plotbool)
%%%%%%%%%%%%%%%%%SWIFT_nondimensionalparams.m
%
%   Calculates nondimensional fetch, energy, frequency, and waveheight and
%   puts each into an table. Will also filter for wave age < 1 based off of
%   pkfrequency. "plotbool" signifies the action to either plot or not plot
%   the results in a comparision. 
%
%   Created: M. James, December 2024

if ~exist('plotbool', 'var')
    plotbool = 0;
end

