function [shear, eps, z_shear, z_eps] = lawofthewallSWIFT(SWIFT, ustar, varargin) 
%lawofthewallSWIFT Makes an estimate of the Law of the Wall shear and tke
%dissipation given SWIFT data. Model is of same grid as SWIFT data and
%bases this grid on signature 1000 bins. 
%   [shear, eps, z_shear, z_eps] = lawofthewallSWIFT(SWIFT, ustar, 'key_i', value_i) 
%   Takes in SWIFT structure with fields:
%   SWIFT.signature.HRprofile
%   SWIFT.signature.profile
%   and calculates a model law of the wall prediction based on Zeiden et.
%   al. 2024 DOI:10.1029/2024JC021399
% 
%   INPUTS
%   SWIFT - SWIFT buoy structure
%   ustar - user defined friction velocity of wind on the air-sea
%   interface, MUST BE DEFINED BY USER EXPLICITELY and same length as SWIFT
%   'key_i', value_i: example of extra inputs including add defined as parameters below:
%       'plotflag', 0 1 true or false ; bool to give option of plotting results
%       'rhoa', [scaler or vector quantity] ; user inputted air density,
%       default is 1.225 kg/m^3
%       'rhow', [scaler or vector quantity] ; user inputted water density,
%       default is 1025 kg/m^3 for seawater
%       'z', [depth vector] ; user defined and will override
%       function which grabs this to match SWIFT.signature bins.
%   
% 
%   Depth (z) is defined as POSITIVE DOWN. Option for different z's based
%   on each mode. Can be overridden by declaring 'z' key/value pair in 
%   the varargin input.
%
% 
%   M. James 01/2026

name = 'Law of the Wall Output Summary';


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Parse and init
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

p = inputParser;
p.FunctionName = mfilename;

% Validation functions
isMatrixNumeric   = @(v) isnumeric(v) && ismatrix(v);
isMatrixStructure = @(v) isstruct(v) && ismatrix(v);
isFlag            = @(v) isscalar(v) && (islogical(v) || v == 0 || v == 1);

% Required arguments
addRequired(p, 'SWIFT', isMatrixStructure);
addRequired(p, 'ustar', isMatrixNumeric);

% Optional name-value parameters
addParameter(p, 'plotflag', 0, isFlag);
addParameter(p, 'rhoa', 1.225, isMatrixNumeric);
addParameter(p, 'rhow', 1025, isMatrixNumeric);
addParameter(p, 'z', [0:20]', isMatrixNumeric);

% Parse inputs  (IMPORTANT FIX)
parse(p, SWIFT, ustar, varargin{:});

% Extract results
rhoa     = p.Results.rhoa(:);
rhow     = p.Results.rhow(:);
plotflag = p.Results.plotflag;

% Check for optional z input which overrides other calculations
hasz = any(strcmpi(varargin, 'z'));

% Depth grids decision tree

if isfield(SWIFT(1),"signature") && ... % both profile and HRprofile
        ~isempty(SWIFT(1).signature.HRprofile) & ~isempty(SWIFT(1).signature.profile) ...
        & ~hasz
    % Create grid
    for k = 1:length(SWIFT)
        sz_eps(k) = length(SWIFT(k).signature.HRprofile.z(:));
        sz_shear(k) = length(SWIFT(k).signature.profile.z(:));
    end
    
    % dummy array
    z_eps = nan(max(sz_eps),length(SWIFT));
    z_shear = nan(max(sz_shear),length(SWIFT));
    
    % loop to grab signature data
    for k = 1:length(SWIFT)
        z_eps(1:sz_eps(k),k) = SWIFT(k).signature.HRprofile.z(:);
        z_shear(1:sz_shear(k),k) = SWIFT(k).signature.profile.z(:);
    end

elseif isfield(SWIFT(1),"signature") && ~isempty(SWIFT(1).signature.HRprofile)...
        & ~hasz % only HRprofile

    warning("No HR mode on sig1000 on this SWIFT") 
    
    % Create grid
    for k = 1:length(SWIFT)
        sz_eps(k) = length(SWIFT(k).signature.HRprofile.tkedissipationrate(:));
    end
    
    % dummy array
    z_eps = nan(max(sz_eps),length(SWIFT));
    
    % loop to grab signature data
    for k = 1:length(SWIFT)
        z_eps(1:sz_eps(k),k) = SWIFT(k).signature.HRprofile.z(:);
    end
    
    z_shear = p.Results.z;

elseif isfield(SWIFT(1),"signature") && ~isempty(SWIFT(1).signature.profile)...
        & ~hasz % only profile
    
    warning("No profile mode on sig1000 on this SWIFT") 

    % Create grid
    for k = 1:length(SWIFT)
        sz_shear(k) = length(SWIFT(k).signature.HRprofile.tkedissipationrate(:));
    end
    
    % dummy array
    z_shear = nan(max(sz_shear),length(SWIFT));
    
    % loop to grab signature data
    for k = 1:length(SWIFT)
        z_shear(1:sz_shear(k),k) = SWIFT(k).signature.HRprofile.z(:);
    end
    
    z_eps = p.Results.z;

else % none or z user inputted
   warning("No signature 1000 on this SWIFT") 
   z_eps = repmat(p.Results.z(:), 1, length(SWIFT)); % Setting each to a default or user defined
   z_shear = repmat(p.Results.z(:), 1, length(SWIFT));
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Impliment scaling based off of Zeiden et. al. 2024
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
tau = ustar.^2 .*rhoa; % Assumption tau_water == tau_air, stress is opposite and equal at the surface

ustar_water = sqrt(tau./rhow)';

shear = ustar_water ./ (0.41 .* z_shear);
eps = (ustar_water.^3) ./ (0.41.*z_eps);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Optional Plotting (set plotflag to 1)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 
if plotflag;
    figure(Position=[10 10 1000 800])

    tiledlayout('vertical');
    nexttile;
    yyaxis left
    plot([SWIFT.time], ustar, 'LineWidth', 2, 'DisplayName','air');
    hold on
    plot([SWIFT.time], ustar_water, 'LineWidth', 2,'DisplayName','water');
    ylabel('u* [m/s]');
    datetick('x');    
    legend('location', 'best')
 
    yyaxis right
    plot([SWIFT.time], tau, 'LineWidth', 2, 'DisplayName','Wind Stress');
    ylabel('\tau [N/m^2]')
    datetick('x')

    nexttile;
    pcolor([SWIFT.time], z_shear, shear)
    axis ij; shading flat;
    ylabel('depth [m]')
    ylabel(colorbar, 'Shear [1/s]')
    datetick('x')
    clim([ 0 0.1]) % typical scale shear mag

    nexttile;
    pcolor([SWIFT.time], z_eps, eps)
    axis ij; shading flat;
    ylabel('depth [m]')
    ylabel(colorbar, '\epsilon [m^2/s^3]')
    set(gca,'ColorScale','log')
    clim([1e-8 1e-4]); % typical eps scale
    datetick('x')

    sgtitle(name);
    savefig(name);

end

save(name);

end