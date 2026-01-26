function [shear, eps, z] = lawofthewallSWIFT(SWIFT, ustar, plotflag, opts) 
%lawofthewallSWIFT Makes an estimate of the Law of the Wall shear and tke
%dissipation given SWIFT data. Model is of same grid as SWIFT data and
%bases this grid on signature 1000 bins. 
%   [shear, eps, z] = lawofthewallSWIFT(SWIFT, plotflag) 
%   Takes in SWIFT structure with fields:
%   SWIFT.signature.HRprofile
%   and calculates a model law of the wall prediction based on Zeiden et.
%   al. 2024 DOI:10.1029/2024JC021399
% 
%   Depth (z) is defined as POSITIVE DOWN
% 
%   M. James 01/2026


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Parse and init
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

p = inputParser;
p.FunctionName = mfilename;

% Validation functions
isMatrixNumeric = @(v) isnumeric(v) && ismatrix(v);
isMatrixStructure = @(v) isstruct(v) && ismatrix(v);
isFlag = @(v) isscalar(v) && v == 0 | v == 1 | v == true | v == false;

% Required arguments (A and x listed in the call)
addRequired(p, 'SWIFT', isMatrixStructure);
addRequired(p, 'ustar', isMatrixNumeric);

% Optionals(third argument)
addOptional(p, 'plotflag', 0 ,isFlag);
addOptional(p, 'opts', struct(), @(v) isstruct(v))

% Parse
parse(p, SWIFT, ustar, varargin);
opts = p.Results.opts;
plotflag = p.Results.plotflag;

% depth grid decision tree

if isfield(SWIFT(1),"signature") && ~isempty(SWIFT(1).signature.HRprofile)
    
    % Create grid
    for k = 1:length(SWIFT)
        sz(k) = length(SWIFT(k).signature.HRprofile.tkedissipationrate(:));
    end
    
    % dummy array
    z = nan(max(sz),length(SWIFT));
    
    % loop to grab signature data
    for k = 1:length(SWIFT)
        z(1:sz(k),k) = SWIFT(k).signature.HRprofile.z(:);
    end
else
   warning("No signature 1000 on this SWIFT") 
   if isfield(opts, "z")
        z = opts.z; % User defined
   else
        z = repmat([O:20]', 1,length(SWIFT)); % Default [m positive down]
   end
end

% Air Density option
if isfield(opts, "rhoa")
    rhoa = opts.rhoa; % User defined
else
    rhoa = 1.225 % Default [kg/m^3]
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Impliment scaling based off of Zeiden et. al. 2024
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
tau = ustar.^2.*fluxes.rhoa;

% General density of SW (might need to change)
rho_water = 1025; % kg/m^3

ustar_water = sqrt(tau./rho_water)';

shear = ustar_water ./ (0.41 .* z);
eps = (ustar_water.^3) ./ (0.41.*z);

end