% Evaluate the wind stress estimates from a SWIFT or Waveglider
% using a SWIFT compatible data structure and optional reference wind
% (from Airmar or otherwise)
%
% screens for head-to-wind conditions, then
% compares to drag laws and wind-wave equilibrium
%
% J. Thomson, 4/2017
%

clear all, close all

load('./WaveGlider.mat','WaveGlider');
%load('~/Desktop/SV3-153/SV3-153_Winter2017.mat')


%% QC limits 

% alignment: u is aligned and negative when head-to-wind, so a big negative number means head to wind
% this is by far the most important screen; it removes about 70% for the Southern Ocean 2017 dataset
maxuvratio = -0.6;  % usually -0.6, which is +/- 60 deg from head-to-wind, something like 10 would let everything thru

% spectra: this is the ratio of horizontal TKE to vertical in the inertial sub-range
% this is almost always greater than one.  
maxanisotropy = 1.5; % usually 2, something like 5 would let everything thru

% fit quality: this is the relative error in fitting to f^-5/3 slopes
% typical values are 0.5, lower values are better... sort of
maxquality = 0.6;  % usually 0.6, something like 1 would let everything thru


%% Apply Quality control
bad = false(length(WaveGlider),1);

uvratio = [WaveGlider.windmeanu] ./ abs( [WaveGlider.windmeanv] );

for wg = 1:length(WaveGlider),
    if  uvratio(wg) > maxuvratio | WaveGlider(wg).windanisotropy > maxanisotropy | WaveGlider(wg).windustarquality > maxquality,
        bad(wg) = true;
        Waveglider(wg).windustar = NaN;
    else
    end
end

%WaveGlider(bad) = [];

%% estimate true wind spd and direction from the sonic relative direction
for wg = 1:length(WaveGlider),
   relative = atan2d(WaveGlider(wg).windmeanv, WaveGlider(wg).windmeanu);
   %WaveGlider(wg).windspd = WaveGlider(wg).windspd + cosd(relative).*WaveGlider(wg).driftspd;
   WaveGlider(wg).winddirT = WaveGlider(wg).driftdirT - relative + 180;
   if WaveGlider(wg).winddirT > 360,
       WaveGlider(wg).winddirT = WaveGlider(wg).winddirT-360;
   elseif WaveGlider(wg).winddirT < 0, 
       WaveGlider(wg).winddirT = WaveGlider(wg).winddirT+360;
   end
end


%% U10 estimates (from log layer) and time series

for wg = 1:length(WaveGlider),
    
    WaveGlider(wg).U10 = 1.55 .* WaveGlider(wg).windspd; % empirical
    
    if isfield(WaveGlider(wg),'referencewindspd'),
        
        WaveGlider(wg).referenceU10 = 1.25 .* WaveGlider(wg).referencewindspd; % (Benschop, 1996).
    else
        WaveGlider(wg).referenceU10 = NaN;
    end
    
end

figure(1), clf
subplot(2,1,1)
plot([WaveGlider.time],[WaveGlider.U10],'g-o',[WaveGlider.time],[WaveGlider.referenceU10],'m-s')
set(gca,'fontweight','demi','fontsize',16)
datetick('x','ddmmm')
ylabel('Wind Speed [m/s]'),

subplot(2,1,2)
plot([WaveGlider.time],[WaveGlider.winddirT],'g-o',[WaveGlider.time],[WaveGlider.referencewinddirT],'m-s')
set(gca,'fontweight','demi','fontsize',16)
datetick('x','ddmmm')
ylabel('Wind Dir [deg]'),

figure(2), clf
scatter([WaveGlider.referenceU10],[WaveGlider.U10],'k.')
hold on, plot([0 20],[0 20],'k--')
set(gca,'fontweight','demi','fontsize',16)
xlabel('[m/s]'),ylabel('[m/s]')
title('Adjusted wind speed, U_{10} [m/s]')
axis square

good = ~isnan( [WaveGlider.U10] - [WaveGlider.referenceU10]); % & [WaveGlider.U10] > 10;

U10Rsq = corrcoef([WaveGlider(good).U10],[WaveGlider(good).referenceU10])
U10bias = mean( [WaveGlider(good).U10] - [WaveGlider(good).referenceU10] )
U10rmserror = rms( [WaveGlider(good).U10] - [WaveGlider(good).referenceU10] - U10bias)


%% bin-averaged spectra

dw = 2;
windbins = [0:dw:18];

f = WaveGlider(1).windspectra.freq;
spectra = zeros( length(windbins),length(f) );
n = zeros(length(windbins),1);

for wg = 1:length(WaveGlider),
    
    %figure(10), loglog(f , WaveGlider(wg).windspectra.energy .* f.^(5/3) ), drawnow
    
    [m bin] = min( abs( WaveGlider(wg).U10 - windbins) );
    if ~isnan( WaveGlider(wg).windspectra.energy ) & ~bad(wg);
        spectra(bin,:) = spectra(bin,:) + WaveGlider(wg).windspectra.energy;
        n(bin) = n(bin) + 1;
    else
    end
    
end

meanspectra = spectra ./ ( n * ones(1,length(f)) );

figure(3), clf
loglog(f,meanspectra,'linewidth',2)
set(gca,'fontweight','demi','fontsize',16)
ylabel('TKE [m^2/s^2/Hz]')
xlabel('Frequency [Hz]')
for wi=1:length(windbins),
    text(1.01*max(f), min(meanspectra(wi,:)), [num2str(windbins(wi)+dw/2) ' m/s'],'fontweight','demi','fontsize',12)
end
hold on, loglog([1.5 3],3*[1.5 3].^(-5/3),'k--','linewidth',1.5)
text(2.2,2.2,'f^{-5/3}','fontweight','demi','fontsize',14)

%% recalc ustar from spectra

fmin = 1.5; % Hz
fmax = 3; % Hz
K = 0.55 ; % Kolmogorov const, factor by 4/3 for vertical or cross-flow component
kv = 0.4 ; % von Karman const  
z = 0.77; % meters above sea level, 0.77 for Gill on Waveglider, 0.95 for RM Young on SWIFT

for wg = 1:length(WaveGlider),
    if ~bad(wg),
        inertialrange = find( WaveGlider(wg).windspectra.freq > fmin & WaveGlider(wg).windspectra.freq < fmax);
        inertiallevel = nanmean( WaveGlider(wg).windspectra.energy(inertialrange) .* (WaveGlider(wg).windspectra.freq(inertialrange)).^(5/3) ) ;
        epsilon =  ( inertiallevel ./ ( ( WaveGlider(wg).windspd ./ (2*pi) ).^(2/3)  .* K ) ).^(3/2);
        WaveGlider(wg).windustar = (kv * epsilon * z ).^(1/3);  % assumes neutral
        WaveGlider(wg).windustar = WaveGlider(wg).windustar;
    else
        WaveGlider(wg).windustar = NaN;
    end
end


%% Wave equilibrium estimates
beta = 0.012;
%Ip = 2.5; % option to calc below
g = 9.8;

for wg = 1:length(WaveGlider),
    eqrange = find( WaveGlider(wg).wavespectra.freq > 0.3 & WaveGlider(wg).wavespectra.freq < 0.4);
    Theta = deg2rad( abs(WaveGlider(wg).referencewinddirT - nanmean(WaveGlider(wg).wavespectra.dir(eqrange))) ); % difference between wind and wave direction (both given as dir FROM)
    Ip = 3.14 - Theta - deg2rad( nanmean(WaveGlider(wg).wavespectra.spread(eqrange)) ./ 2 );
    if   Ip > 1.9   &   Ip < 3.1   &   Theta < deg2rad(25) & ~bad(wg),
        WaveGlider(wg).equilustar = 8 * (3.14)^4 * nanmean( WaveGlider(wg).wavespectra.energy(eqrange) .* (WaveGlider(wg).wavespectra.freq(eqrange)).^4 ) ./ (2*3.14*beta*Ip*g);
    else
         WaveGlider(wg).equilustar = NaN;
    end
end

figure(4), clf
%scatter([WaveGlider.equilustar],[WaveGlider.windustar],10,uvratio,'filled'), caxis([-2 2])
scatter([WaveGlider.equilustar],[WaveGlider.windustar],10,[WaveGlider.windanisotropy],'filled'), caxis([1 2])
%scatter([WaveGlider.equilustar],[WaveGlider.windustar],10,[WaveGlider.windustarquality],'filled'), caxis([0.4 0.7])
hold on, plot([0 1],[0 1],'k--')
set(gca,'fontweight','demi','fontsize',16)
xlabel('u_{*eq} [m/s]'),
ylabel('u_* [m/s]')
axis square

good = ~isnan( [WaveGlider.windustar] - [WaveGlider.equilustar]);

equstarRsq = corrcoef([WaveGlider(good).windustar],[WaveGlider(good).equilustar])
equstarbias = mean( [WaveGlider(good).windustar] - [WaveGlider(good).equilustar] )
equstarrmserror = rms( [WaveGlider(good).windustar] - [WaveGlider(good).equilustar] - equstarbias)



%% compare with drag law
dw = 1;
windbins = [0:dw:20];

a = 1.4e-3;
b = 1e-6;
Cd = a  +  b * windbins.^2; % ad hoc version of Smith, 1980 
ustarcurve = ( Cd .* windbins.^2 ).^.5;

for wg = 1:length(WaveGlider),
    WaveGlider(wg).bulkustar = ( (a  +  b * WaveGlider(wg).U10.^2) .* WaveGlider(wg).U10.^2 ).^.5;
end

% stats
good = ~isnan( [WaveGlider.windustar] - [WaveGlider.bulkustar]);
buklustarRsq = corrcoef([WaveGlider(good).windustar],[WaveGlider(good).bulkustar])
bulkustarbias = mean( [WaveGlider(good).windustar] - [WaveGlider(good).bulkustar] )
bulkustarrmserror = rms( [WaveGlider(good).windustar] - [WaveGlider(good).bulkustar] - bulkustarbias)


figure(5), clf
hold on, plot(windbins,ustarcurve,'m-','linewidth',2)
%scatter([WaveGlider.U10],[WaveGlider.windustar],10,uvratio,'filled'), caxis([-2 2])
%scatter([WaveGlider.U10],[WaveGlider.windustar],10,[WaveGlider.windanisotropy],'filled'), caxis([1 2])
%scatter([WaveGlider.U10],[WaveGlider.windustar],10,[WaveGlider.airtemp]-[WaveGlider.watertemp],'filled'), %caxis([0.4 0.7])
%scatter([WaveGlider.U10],[WaveGlider.windustar],10,[WaveGlider.driftspd],'filled'), %caxis([0.4 0.7])
%scatter([WaveGlider.U10],[WaveGlider.windustar],10,[WaveGlider.driftdirT]-[WaveGlider.referencewinddirT],'filled'), %caxis([0.4 0.7])
%scatter([WaveGlider.U10],[WaveGlider.windustar],10,[WaveGlider.driftdirT]-[WaveGlider.sigwaveheight],'filled'), %caxis([0.4 0.7])
%hold on, plot([WaveGlider.U10],[WaveGlider.equilustar],'k.')
plot([WaveGlider.U10],[WaveGlider.equilustar],'bo','markersize',4), hold on
plot([WaveGlider.U10],[WaveGlider.windustar],'g.','markersize',16), hold on
hold on, plot(windbins,ustarcurve,'m-','linewidth',2)
set(gca,'fontweight','demi','fontsize',16)
xlabel('U_{10} [m/s]'), ylabel('u_* [m/s]')
legend('Smith, 1980','Wave Equilibrium','Inertial Dissipation','Location','NorthEastOutside')



