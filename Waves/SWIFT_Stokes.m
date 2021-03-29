function SWIFT_Stokes = SWIFT_Stokes(SWIFT, varargin)
%
% function SWIFT_Stokes = SWIFT_Stokes(SWIFT, varargin)
%
% This function estimates Stokes drift profiles and wave-following bias velocities
%
%   INPUTS: SWIFT: SWIFT data structure
%           depth: water depth at SWIFT (length is number of SWIFT bursts)
%   
%   OUTPUTS: SWIFT_Stokes: SWIFT structure with added fields:
%               stokesdrift: Stokes drift profile estimates
%                   bulk: using bulk wave parameters
%                       surface: east, north components (m/s) at surface
%                       profile: east, north components (m/s) at z (m)
%                   spectral: using Fourier moments
%                       surface: east, north components (m/s) at surface
%                       profile: east, north components (m/s) at z (m)
%               wavebias: Wave-following bias estimates
%                   bulk: using bulk wave parameters
%                       bias: east, north components (m/s) of wave-following
%                               bias estimate at z (m)
%                       profile: east, north components of absolute
%                              velocity without removing wave-following bias
%                              (drift + adcp relative velocity)
%                       profile_biasremoved: east, north components (m/s) of
%                               corrected absolute velocity at z (m)
%                              (profile - bias)
%                   spectral: using Fourier moments
%                       bias: east, north components (z) of wave-following
%                               bias estimate at z (m)
%                       profile: east, north components of absolute
%                              velocity without removing wave-following bias
%                              (drift + adcp relative velocity)
%                              (note: same as profile stored under bulk)
%                       profile_biasremoved: east, north components (m/s) of
%                               corrected absolute velocity at z (m)
%                              (profile - bias)
%
% M. Moulton,        revised by J. Thomson in Mar 2021 to include factor of 2 at lines 176-183

% Get water depth or assume deep water waves
if ~isempty(varargin)
	depth = varargin{1};
    depthflag = 'intermediate'; % Flag for using intermediate wave code
    if numel(depth)==1 % If single constant depth input, make vector
        depth = depth*ones(length(SWIFT),1);
    end
else
    depthflag = 'deep'; % Flag for using deep water wave code
end

% Loop through SWIFT bursts
for ii = 1:length(SWIFT)

% If there is Signature velocity component data, get Signature z bins.
% If no Signature data, use hard-coded z bins (same as standard for Signature),
% and also write NaNs into Signature field east and north components, for
% ease of applying SWIFT_Stokes code to all SWIFT types.
if isfield(SWIFT(ii),'signature')
    if isfield(SWIFT(ii).signature,'profile')
        if isfield(SWIFT(ii).signature.profile,'east')
        % Get z bins
        zsave = SWIFT(ii).signature.profile.z; if isrow(zsave), zsave = zsave'; end
        z = -zsave; % Sign convention: z decreasing downward
            if isempty(SWIFT(ii).signature.profile.east)
                zsave = (.35:.5:19.85)';
                z = -zsave; % Sign convention: z decreasing downward 
                SWIFT(ii).signature.profile.east = NaN*zsave;
                SWIFT(ii).signature.profile.north = NaN*zsave;      
            end
        else
        	zsave = (.35:.5:19.85)';
            z = -zsave; % Sign convention: z decreasing downward  
            SWIFT(ii).signature.profile = []; % set empty field
            SWIFT(ii).signature.profile.east = NaN*zsave;
            SWIFT(ii).signature.profile.north = NaN*zsave;
        end
    else
    	SWIFT(ii).signature.profile.east = NaN*zsave;
        SWIFT(ii).signature.profile.north = NaN*zsave;            
    end
else
    zsave = (.35:.5:19.85)';
	z = -zsave; % Sign convention: z decreasing downward  
	SWIFT(ii).signature.profile.east = NaN*zsave;
	SWIFT(ii).signature.profile.north = NaN*zsave;
end

% Water depth for this burst
if strcmp(depthflag,'intermediate')==1
    h = depth(ii);
end

% Get drift speed and direction
driftdirT = SWIFT(ii).driftdirT;
driftspd = SWIFT(ii).driftspd;

% Load bulk wave information
sigwaveheight = SWIFT(ii).sigwaveheight;
peakwaveperiod = SWIFT(ii).peakwaveperiod;

% Change peak wave dir to direction TO for plotting/analysis
peakwavedirT = SWIFT(ii).peakwavedirT;
peakwavedirT(peakwavedirT>9000) = NaN;
peakwavedirT = peakwavedirT+180;
peakwavedirT(peakwavedirT>360) = peakwavedirT(peakwavedirT>360)-360;

% Load spectral information
energy = SWIFT(ii).wavespectra.energy;
frequency = SWIFT(ii).wavespectra.freq;
a1 = SWIFT(ii).wavespectra.a1;
b1 = SWIFT(ii).wavespectra.b1;

% Compute angular frequency
om = 2*pi./peakwaveperiod;

% Compute Bulk Stokes drift and Wave-Following Bias at Signature z bins
if strcmp(depthflag,'intermediate')==1
    k = wavenumber(1/peakwaveperiod, h); % Compute wavenumber
    Stokes0=sigwaveheight.^2/(16)*om*k.*cosh(2*k*h)./(sinh(k*h).^2); % Surface value
    Stokes = sigwaveheight.^2/(16)*om*k.*cosh(2*k*(z+h))./(sinh(k*h).^2);
    WaveBias = sigwaveheight.^2/(16)*om*k.*cosh(k*z+2*k*h)./(sinh(k*h).^2);
else
    k = om.^2/9.81; % Compute wavenumber
    Stokes0=sigwaveheight.^2/(16)*om*k; % Surface value
    Stokes = sigwaveheight.^2/(16)*om*k.*exp(2*k*z);
    WaveBias = sigwaveheight.^2/(16)*om*k.*exp(k*z);
end

% Compute east and north components
SWIFT(ii).stokesdrift.bulk.surface.east = Stokes0.*sind(peakwavedirT);
SWIFT(ii).stokesdrift.bulk.surface.north = Stokes0.*cosd(peakwavedirT);
SWIFT(ii).stokesdrift.bulk.profile.east = Stokes.*sind(peakwavedirT);
SWIFT(ii).stokesdrift.bulk.profile.north = Stokes.*cosd(peakwavedirT);
SWIFT(ii).stokesdrift.bulk.surface.z = zsave;
SWIFT(ii).wavebias.bulk.bias.east = WaveBias.*sind(peakwavedirT);
SWIFT(ii).wavebias.bulk.bias.north = WaveBias.*cosd(peakwavedirT);
SWIFT(ii).wavebias.bulk.bias.z = zsave;


% Compute Spectral Stokes and Wave Bias Estimates (using Fourier moments)

% Initialize with zero value prior to summing component-wise over freq
Stokes_spectral_east_0 = 0; % Surface value
Stokes_spectral_north_0 = 0; % Surface value
Stokes_spectral_east = zeros(size(z)); % At mean z of Signature bins
Stokes_spectral_north = zeros(size(z)); % At mean z of Signature bins
WaveBias_spectral_east_0 = 0; % Surface value
WaveBias_spectral_north_0 = 0; % Surface value
WaveBias_spectral_east = zeros(size(z)); % At mean z of Signature bins
WaveBias_spectral_north = zeros(size(z)); % At mean z of Signature bins

% Frequency resolution (*assumes constant*)
df = mean(abs(diff(frequency)));

% Loop over frequency
for jj=1:length(frequency)
    
    om = 2*pi.*frequency(jj);
    
    % Compute Stokes drift and Wave Bias for this frequency
    if strcmp(depthflag,'intermediate')==1
        k = wavenumber(frequency(jj), h);
        Stokes_jj_0 = om*k*cosh(2*k*h)./(sinh(k*h).^2)*energy(jj);
        Stokes_jj = om*k*cosh(2*k*(z+h))./(sinh(k*h).^2)*energy(jj);
        WaveBias_jj_0 = om*k*cosh(2*k*h)./(sinh(k*h).^2)*energy(jj);        
        WaveBias_jj = om*k*cosh(k*z+2*k*h)./(sinh(k*h).^2)*energy(jj);
    else
        Stokes_jj_0 = om*k*energy(jj);
        Stokes_jj = om*k*energy(jj)*exp(2*k*z);
        WaveBias_jj_0 = om*k*energy(jj);        
        WaveBias_jj = om*k*energy(jj)*exp(k*z);
    end
    
    % Sum component-wise with contributions from other frequencies ** added factors of 2 in Mar 2021
    Stokes_spectral_east_0 = Stokes_spectral_east_0+2*Stokes_jj_0.*(-a1(jj))*df; 
    Stokes_spectral_north_0 = Stokes_spectral_north_0+2*Stokes_jj_0.*(-b1(jj))*df; 
    Stokes_spectral_east = Stokes_spectral_east+2*Stokes_jj.*(-a1(jj))*df; 
    Stokes_spectral_north = Stokes_spectral_north+2*Stokes_jj.*(-b1(jj))*df; 
    WaveBias_spectral_east = WaveBias_spectral_east+2*WaveBias_jj.*(-a1(jj))*df;
    WaveBias_spectral_north = WaveBias_spectral_north+2*WaveBias_jj.*(-b1(jj))*df;
    WaveBias_spectral_east_0 = WaveBias_spectral_east_0+2*WaveBias_jj_0.*(-a1(jj))*df;
    WaveBias_spectral_north_0 = WaveBias_spectral_north_0+2*WaveBias_jj_0.*(-b1(jj))*df;    
end

% Save Stokes and Wave Bias profiles
SWIFT(ii).stokesdrift.spectral.surface.east = Stokes_spectral_east_0;
SWIFT(ii).stokesdrift.spectral.surface.north = Stokes_spectral_north_0;
SWIFT(ii).stokesdrift.spectral.profile.east = Stokes_spectral_east;
SWIFT(ii).stokesdrift.spectral.profile.north = Stokes_spectral_north;
SWIFT(ii).stokesdrift.spectral.profile.z = zsave;

SWIFT(ii).wavebias.spectral.bias.east = WaveBias_spectral_east;
SWIFT(ii).wavebias.spectral.bias.north = WaveBias_spectral_north;
SWIFT(ii).wavebias.spectral.bias.z = zsave;

% Compute uncorrected and corrected absolute velocity profiles:

% Bulk
% Absolute velocity profile (note: same as saved under spectral)
SWIFT(ii).wavebias.bulk.profile.east = driftspd.*sind(driftdirT)+[SWIFT(ii).signature.profile.east];
SWIFT(ii).wavebias.bulk.profile.north = driftspd.*cosd(driftdirT)+[SWIFT(ii).signature.profile.north];
SWIFT(ii).wavebias.bulk.profile.z = zsave;
% With bias removed
SWIFT(ii).wavebias.bulk.profile_biasremoved.east = SWIFT(ii).wavebias.bulk.profile.east-[SWIFT(ii).wavebias.bulk.bias.east];
SWIFT(ii).wavebias.bulk.profile_biasremoved.north = SWIFT(ii).wavebias.bulk.profile.north-[SWIFT(ii).wavebias.bulk.bias.north];
SWIFT(ii).wavebias.bulk.profile_biasremoved.z = zsave;

% Spectral
% Absolute velocity profile (note: same as saved under spectral)
SWIFT(ii).wavebias.spectral.profile.east = driftspd.*sind(driftdirT)+[SWIFT(ii).signature.profile.east];
SWIFT(ii).wavebias.spectral.profile.north = driftspd.*cosd(driftdirT)+[SWIFT(ii).signature.profile.north];
SWIFT(ii).wavebias.spectral.profile.z = zsave;
% With bias removed
SWIFT(ii).wavebias.spectral.profile_biasremoved.east = SWIFT(ii).wavebias.spectral.profile.east-[SWIFT(ii).wavebias.spectral.bias.east];
SWIFT(ii).wavebias.spectral.profile_biasremoved.north = SWIFT(ii).wavebias.spectral.profile.north-[SWIFT(ii).wavebias.spectral.bias.north];
SWIFT(ii).wavebias.spectral.profile_biasremoved.z = zsave;

end

SWIFT_Stokes = SWIFT;

end