function [echogram,fh] = processSIGecho(echo,S,opt)
% Adaptation of A. Shcherbina 'Nortek_CorrectEcho.m' and 
% C. Bassett 'sigecho_vol.m' by K. Zeiden (10/2023)

% This script corrects for geometric spreading in Nortek Sig1000 ADCP 
% acoustic backscatter data (recorded in counts) to give relative amplitude in dB. 

% Sonar Equation: Nortek Signature 1000 Principles of Operation
% Near-feild Correction: Gartner 2004, http://dx.doi.org/10.1016/j.margeo.2004.07.001
% General: Deines, K.L., 1999, followed by Gostiaux and Haren, 2010;

% Inputs:       echo: structure from burst file containing echo data
% Output:       echo: echogram corrected for spread/atten. loss[dB]

% Notes: 
% Configuration is currently assumed for the center beam, 
% but can be modified to account for slanted beam by changing the beam angle
% (default value of 'bangle') accordingly. 
% Also, Nortek reporedtly records in 100ths of a dB, although this has been 
% thrown into question by results of correction using this value.
% 'echo' will be converted to [dB] if mean echo too low.

% K.Zeiden 06/2024

% Default: Signature 1000 Parameters
a = 0.015; % [m] Transducer radius
f0 = 1e6; %[Hz] Center frequency
fbw = 0.25; % [%] Bandwidth (percentage)
f = (1-fbw/2)*f0:1e3:(1+fbw/2)*f0;% Full Bandwidth
PL = -10; % [dB] Transmit power level, relative to maximum
bangle = 0; % [deg] Beam angle in degrees!
c0 = 1500; % [ms^{-1}] Assumed sound speed

% Get echo and range data
echo0 = echo.EchoSounder';
[~,nbine] = size(echo.EchoSounder);
r = (echo.Blanking + echo.CellSize*(0:nbine-1))';

% Temperature + Pressure
T = mean(echo.Temperature,'omitnan');
P = mean(echo.Pressure,'omitnan');

% Unit correction: convert to [dB] if still in [0.01 dB -- this has been thrown into question]
if mean(echo0(:),'omitnan') > 1e3
        echo0 = 2*echo0./100; % [dB]
end

% Range correction: true sound speed and beam slant 
c = sw_svel(S,T,P);
r = r*c./c0;
r = r/cos(bangle*pi/180);

%%% Geometric correction terms %%%

    % Near field correction for spreading loss (Gartner 2004)
    lambda0 = c./f0;
    rc = pi*(a.^2)./lambda0;
    z = r/rc;
    g = 1.35*z + (2.5*z).^3.2;
    nfc =  (1+g)./g;
    Nfc = 20*log10(nfc);

    % Beam spreading (referenced to 1 m)
    Sp = 20*log10(r);% 10log10(r^2/(1 m)^2), so unitless?

    % Attenuation
    alphaf = absorption(S,T,P,f./1e3);% [dB/m]
    alpha = 10*log10(mean(10.^(alphaf./10))); % Average over bandwidth
    At = 2*alpha*r;%

    % Ensonafied Volume
    lambdaf = c./f;
    kf = 2*pi./lambdaf;
    Psif = 10.*log10(5.78./(kf.*a).^2);% ka is unitless
    Psi = 10*log10(mean(10.^(Psif./10)));% Average over bandwidth
    dr = r(2)-r(1);
    Dr = 10*log10(dr); % Units?
    Ens = Psi + Dr;
    
    % Calibrated Gain (SWIFT_CalGains_June2023.mat, Bassett)
    Gint = -150;

%%% Apply Correction %%%
echoc = echo0 + Sp + At;% + Nfc - Ens + PL + Gint;

% Save in structure
echogram.echo0 = mean(echo0,2,'omitnan');
echogram.echoc = mean(echoc,2,'omitnan');
echogram.r = r;


% Plot Burst 
if opt.plotburst
    
     % Visualize Data
    fh(1) = figure('color','w');
    clear c
    MP = get(0,'monitorposition');
    set(gcf,'outerposition',MP(1,:).*[1 1 1 1]);
    subplot(2,1,1)
    imagesc(echo0)
    clim([40 150]); cmocean('thermal')
    title('Raw Echogram Data');
    ylabel('Bin #')
    c = colorbar;c.Label.String = 'E (dB)';
    subplot(2,1,2)
    imagesc(echoc)
    clim([40 150]); cmocean('thermal')
    ylabel('Bin #')
    c = colorbar;c.Label.String = 'E (dB)';
    xlabel('Ping #')
    title('Range Corrected');
    drawnow

else
    fh = [];
end
