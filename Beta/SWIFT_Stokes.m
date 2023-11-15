function SWIFT_withStokes = SWIFT_Stokes(SWIFT)

% Estimate Stokes profiles and wave-following bias velocities
% Assumes deep water. Will be adapted to intermediate waves.
% Option to compute using a1 and b1 will be added.
% Melissa Moulton, last edited: May 2018

g = 9.81;

% Set z bins to standard for Signature
z = (.35:.5:19.85)'; %z = 0:.05:20;

for ii = 1:length(SWIFT)

% Get drift speed and direction
driftdirT = SWIFT(ii).driftdirT;
driftspd = SWIFT(ii).driftspd;

% Load wave information
sigwaveheight = SWIFT(ii).sigwaveheight;
peakwaveperiod = SWIFT(ii).peakwaveperiod;

% Change peak wave dir to direction TO for plotting/analysis
peakwavedirT = SWIFT(ii).peakwavedirT;
peakwavedirT(peakwavedirT>9000) = NaN;
peakwavedirT = peakwavedirT+180; peakwavedirT(peakwavedirT>360) = peakwavedirT(peakwavedirT>360)-360;

% Spectral information
energy = SWIFT(ii).wavespectra.energy;
frequency = SWIFT(ii).wavespectra.freq;
a1 = SWIFT(ii).wavespectra.a1;
b1 = SWIFT(ii).wavespectra.b1;
a2 = SWIFT(ii).wavespectra.a2;
b2 = SWIFT(ii).wavespectra.b2;

% Compute directions and spreads
dir1 = atan2d(b1,a1);
spread1 = sqrt(2.*(1-sqrt(a1.^2+b1.^2)));
dir2 = atan2d(b2,a2)/2;
spread2 = sqrt(abs(0.5-0.5.*(a2.*cos(2.*deg2rad(dir2))+b2.*cos(2.*deg2rad(dir2)))));

dir = -dir1; %  switch from rad to deg, and CCW to CW (negate)
dir = dir + 90;  % rotate from eastward = 0 to northward  = 0
dir( dir < 0 ) = dir( dir < 0 ) + 360;  % take NW quadrant from negative to 270-360 range
westdirs = dir > 180;
eastdirs = dir < 180;
dir( westdirs ) = dir ( westdirs ) - 180; % take reciprocal such wave direction is FROM, not TOWARDS
dir( eastdirs ) = dir ( eastdirs ) + 180; % take reciprocal such wave direction is FROM, not TOWARDS
dir1=dir;

dir = - dir2;  % switch from rad to deg, and CCW to CW (negate)
dir = dir + 90;  % rotate from eastward = 0 to northward  = 0
dir( dir < 0 ) = dir( dir < 0 ) + 360;  % take NW quadrant from negative to 270-360 range
westdirs = dir > 180;
eastdirs = dir < 180;
dir( westdirs ) = dir ( westdirs ) - 180; % take reciprocal such wave direction is FROM, not TOWARDS
dir( eastdirs ) = dir ( eastdirs ) + 180; % take reciprocal such wave direction is FROM, not TOWARDS
dir2 = dir;

%s = 2./(spread2(find(energy==max(energy))).^2)-1;

% Compute directional spectrum estimate
% dtheta = 2;
% theta = -[-180:dtheta:179]';  % start with cartesion (a1 is positive east velocities, b1 is positive north)
% Spreading function
% Dtheta = 2.^(2*s-1)./pi.*(gamma(s+1).^2)./(gamma(2*s+1)).*cos((theta-peakwavedirT)/2).^(2*s);

plotflag=0;
[Etheta_MEM, theta_MEM, f_MEM, dir_MEM, spread_MEM, spread2_MEM, spread2alt_MEM] = SWIFTdirectionalspectra(SWIFT(ii),plotflag);
% Convert to direction to for plotting
theta_MEM = theta_MEM-180; theta_MEM(theta_MEM<0)=theta_MEM(theta_MEM<0)+360;

% Bulk Stokes estimate
k = 4*pi^2./(g*peakwaveperiod.^2);
om = 2*pi./peakwaveperiod;
% uStokes0=sigwaveheight.^2/(16)*om*k; % Surface value, consider outputting this for analysis
uStokes = sigwaveheight.^2/(16)*om*k*exp(-2*k*z);
uSWIFT = sigwaveheight.^2/(16)*om*k*exp(-k*z);

SWIFT(ii).Stokes.monochrom.profile.east = uStokes.*sind(peakwavedirT);
SWIFT(ii).Stokes.monochrom.profile.north = uStokes.*cosd(peakwavedirT);
SWIFT(ii).Stokes.monochrom_bias.profile.east = uSWIFT.*sind(peakwavedirT);
SWIFT(ii).Stokes.monochrom_bias.profile.north = uSWIFT.*cosd(peakwavedirT);

% Stokes estimate using frequency spectrum ("1d")
% assume direction = peakwavedirT at all frequencies
% Note: this will be replaced with a1, b1 method

% Initialize with zero value prior to summing component-wise over freq
uStokes_spec1d_east = zeros(size(z));
uStokes_spec1d_north = zeros(size(z));
uStokes_spec1d_east_0 = 0; % Surface value
uStokes_spec1d_north_0 = 0; % Surface value
uSemiStokes_spec1d_east = zeros(size(z));
uSemiStokes_spec1d_north = zeros(size(z));
uSemiStokes_spec1d_east_0 = 0; % Surface value
uSemiStokes_spec1d_north_0 = 0; % Surface value
df = mean(abs(diff(frequency)));

for jj=1:length(frequency)
    k = 4*pi^2./(g*(1/frequency(jj)).^2);
    om = 2*pi.*frequency(jj);
    
    uStokes_jj = om*k*energy(jj)*exp(-2*k*z);
    uStokes_jj_0 = om*k*energy(jj);
    addeast = uStokes_jj.*sind(dir1(jj));
    addnorth = uStokes_jj.*cosd(dir1(jj));
    addeast_0 = uStokes_jj_0.*sind(dir1(jj));
    addnorth_0 = uStokes_jj_0.*cosd(dir1(jj));
    uStokes_spec1d_east = uStokes_spec1d_east+addeast*df;
    uStokes_spec1d_north = uStokes_spec1d_north+addnorth*df;
    uStokes_spec1d_east_0 = uStokes_spec1d_east_0+addeast_0*df;
    uStokes_spec1d_north_0 = uStokes_spec1d_north_0+addnorth_0*df;
    
    uSemiStokes_jj = om*k*energy(jj)*exp(-k*z);
    uSemiStokes_jj_0 = om*k*energy(jj);
    addeast = uSemiStokes_jj.*sind(dir1(jj));
    addnorth = uSemiStokes_jj.*cosd(dir1(jj));
    addeast_0 = uSemiStokes_jj_0.*sind(dir1(jj));
    addnorth_0 = uSemiStokes_jj_0.*cosd(dir1(jj));
    uSemiStokes_spec1d_east = uSemiStokes_spec1d_east+addeast*df;
    uSemiStokes_spec1d_north = uSemiStokes_spec1d_north+addnorth*df;
    uSemiStokes_spec1d_east_0 = uSemiStokes_spec1d_east_0+addeast_0*df;
    uSemiStokes_spec1d_north_0 = uSemiStokes_spec1d_north_0+addnorth_0*df;    
end

SWIFT(ii).Stokes.spec1d.profile.east = uStokes_spec1d_east;
SWIFT(ii).Stokes.spec1d.profile.north = uStokes_spec1d_north;
SWIFT(ii).Stokes.spec1d_bias.profile.east = uSemiStokes_spec1d_east;
SWIFT(ii).Stokes.spec1d_bias.profile.north = uSemiStokes_spec1d_north;

% MEM Stokes estimates
uStokes_spectral_east = zeros(size(z));
uStokes_spectral_north = zeros(size(z));
uStokes_spectral_east_0 = 0; % Surface value
uStokes_spectral_north_0 = 0; % Surface value

uSemiStokes_spectral_east = zeros(size(z));
uSemiStokes_spectral_north = zeros(size(z));
uSemiStokes_spectral_east_0 = 0; % Surface value
uSemiStokes_spectral_north_0 = 0; % Surface value

df = mean(abs(diff(f_MEM)));
dtheta = mean(abs(diff(theta_MEM)));

% Integrate MEM over freq and dir 
for jj = 1:length(f_MEM)
    k = 4*pi^2./(g*(1/f_MEM(jj)).^2);
    om = 2*pi.*f_MEM(jj);
    
    for kk = 1:length(theta_MEM)
        
        uStokes_jj_kk = om*k*Etheta_MEM(jj,kk)*exp(-2*k*z);
        uStokes_jj_kk_0 = om*k*Etheta_MEM(jj,kk);
        addeast = uStokes_jj_kk.*sind(theta_MEM(kk));
        addnorth = uStokes_jj_kk.*cosd(theta_MEM(kk));
        addeast_0 = uStokes_jj_kk_0.*sind(theta_MEM(kk));
        addnorth_0 = uStokes_jj_kk_0.*cosd(theta_MEM(kk));
        uStokes_spectral_east = uStokes_spectral_east+addeast*df*dtheta;
        uStokes_spectral_north = uStokes_spectral_north+addnorth*df*dtheta;
        uStokes_spectral_east_0 = uStokes_spectral_east_0+addeast_0*df*dtheta;
        uStokes_spectral_north_0 = uStokes_spectral_north_0+addnorth_0*df*dtheta;
        
        uSemiStokes_jj_kk = om*k*Etheta_MEM(jj,kk)*exp(-k*z);
        uSemiStokes_jj_kk_0 = om*k*Etheta_MEM(jj,kk);
        addeastSemi = uSemiStokes_jj_kk.*sind(theta_MEM(kk));
        addnorthSemi = uSemiStokes_jj_kk.*cosd(theta_MEM(kk));
        addeastSemi_0 = uSemiStokes_jj_kk_0.*sind(theta_MEM(kk));
        addnorthSemi_0 = uSemiStokes_jj_kk_0.*cosd(theta_MEM(kk));
        uSemiStokes_spectral_east = uSemiStokes_spectral_east+addeastSemi*df*dtheta;
        uSemiStokes_spectral_north = uSemiStokes_spectral_north+addnorthSemi*df*dtheta;
        uSemiStokes_spectral_east_0 = uSemiStokes_spectral_east_0+addeastSemi_0*df*dtheta;
        uSemiStokes_spectral_north_0 = uSemiStokes_spectral_north_0+addnorthSemi_0*df*dtheta;
        
    end
end

SWIFT(ii).Stokes.spectral.profile.east = uStokes_spectral_east;
SWIFT(ii).Stokes.spectral.profile.north = uStokes_spectral_north;
SWIFT(ii).Stokes.spectral_bias.profile.east = uSemiStokes_spectral_east;
SWIFT(ii).Stokes.spectral_bias.profile.north = uSemiStokes_spectral_north;

% Save correction:
if isfield(SWIFT,'signature')
    
    if ~isempty(SWIFT(ii).signature.profile.east)
        
        eastabs = driftspd.*sind(driftdirT+180)+[SWIFT(ii).signature.profile.east];
        northabs = driftspd.*cosd(driftdirT+180)+[SWIFT(ii).signature.profile.north];
        eastabscorr = driftspd.*sind(driftdirT+180)+[SWIFT(ii).signature.profile.east]-[SWIFT(ii).Stokes.spec1d_bias.profile.east];
        northabscorr = driftspd.*cosd(driftdirT+180)+[SWIFT(ii).signature.profile.north]-[SWIFT(ii).Stokes.spec1d_bias.profile.north];
        
        SWIFT(ii).Stokes.spec1d_bias.profile.eastabs = eastabs;
        SWIFT(ii).Stokes.spec1d_bias.profile.northabs = northabs;
        
        SWIFT(ii).Stokes.spec1d_bias.profile.eastabscorr = eastabscorr;
        SWIFT(ii).Stokes.spec1d_bias.profile.northabscorr = northabscorr;
        
        SWIFT(ii).Stokes.spec1d_bias.profile.shear = abs(gradient(sqrt(eastabs.^2+northabs.^2),.5));
        SWIFT(ii).Stokes.spec1d_bias.profile.shearcorr = abs(gradient(sqrt(eastabscorr.^2+northabscorr.^2),.5));

        % Smoothed profile
%         SWIFT(ii).Stokes.spec1d_bias.profile.shearsmooth = abs(gradient(runavg(sqrt(eastabs.^2+northabs.^2),3),.5));
%         SWIFT(ii).Stokes.spec1d_bias.profile.shearsmoothcorr = abs(gradient(runavg(sqrt(eastabscorr.^2+northabscorr.^2),3),.5));
        
    else
        SWIFT(ii).Stokes.spec1d_bias.profile.eastabs = NaN*ones(40,1);
        SWIFT(ii).Stokes.spec1d_bias.profile.northabs = NaN*ones(40,1);
        SWIFT(ii).Stokes.spec1d_bias.profile.eastabscorr = NaN*ones(40,1);
        SWIFT(ii).Stokes.spec1d_bias.profile.northabscorr = NaN*ones(40,1);
        SWIFT(ii).Stokes.spec1d_bias.profile.shear = NaN*ones(40,1);
        SWIFT(ii).Stokes.spec1d_bias.profile.shearcorr = NaN*ones(40,1);
%         SWIFT(ii).Stokes.spec1d_bias.profile.shearsmooth = NaN*ones(40,1);
%         SWIFT(ii).Stokes.spec1d_bias.profile.shearsmoothcorr = NaN*ones(40,1);
    end
end

end

SWIFT_withStokes = SWIFT;

end