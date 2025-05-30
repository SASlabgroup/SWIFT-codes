% Evaluate the wind stress estimates from a SWIFT or SWIFT
% using a SWIFT compatible data structure and optional reference wind
% (from Airmar or otherwise)
%
% screens for head-to-wind conditions, then
% compares to drag laws and wind-wave equilibrium
%
% J. Thomson, 4/2017
%               9/2017 version without a reference wind
%


%% QC limits 

applyQC = true; % binary flag

% alignment: u is aligned and negative when head-to-wind, so a big negative number means head to wind
% this is by far the most important screen; it removes about 70% for the Southern Ocean 2017 dataset
maxuvratio = 10;  % usually -0.6, which is +/- 60 deg from head-to-wind, something like 10 would let everything thru

% spectra: this is the ratio of horizontal TKE to vertical in the inertial sub-range
% this is almost always greater than one.  
maxanisotropy = 5; % usually 2, something like 5 would let everything thru

% fit quality: this is the relative error in fitting to f^-5/3 slopes
% typical values are 0.5, lower values are better... sort of
maxquality = 0.6;  % usually 0.6, something like 1 would let everything thru


%% Apply Quality control

bad = false(length(SWIFT),1);

if applyQC

uvratio = [SWIFT.windmeanu] ./ abs( [SWIFT.windmeanv] );

for wg = 1:length(SWIFT),
    if  uvratio(wg) > maxuvratio | SWIFT(wg).windanisotropy > maxanisotropy | SWIFT(wg).windustarquality > maxquality,
        bad(wg) = true;
        SWIFT(wg).windustar = NaN;
    else
    end
end

SWIFT(bad) = [];

end

%% estimate true wind spd and direction from the sonic relative direction
for wg = 1:length(SWIFT),
   relative = atan2d(SWIFT(wg).windmeanv, SWIFT(wg).windmeanu);
   %SWIFT(wg).windspd = SWIFT(wg).windspd + cosd(relative).*SWIFT(wg).driftspd;
   SWIFT(wg).winddirT = SWIFT(wg).driftdirT - relative + 180;
   if SWIFT(wg).winddirT > 360,
       SWIFT(wg).winddirT = SWIFT(wg).winddirT-360;
   elseif SWIFT(wg).winddirT < 0, 
       SWIFT(wg).winddirT = SWIFT(wg).winddirT+360;
   end
end


%% U10 estimates (from log layer) and time series

for wg = 1:length(SWIFT),
    
    SWIFT(wg).U10 = 1.55 .* SWIFT(wg).windspd; % empirical
    
    if isfield(SWIFT(wg),'referencewindspd'),
        
        SWIFT(wg).referenceU10 = 1.25 .* SWIFT(wg).referencewindspd; % (Benschop, 1996).
    else
        SWIFT(wg).referenceU10 = NaN;
    end
    
end

figure(1), clf
subplot(2,1,1)
plot([SWIFT.time],[SWIFT.U10],'g-o',[SWIFT.time],[SWIFT.referenceU10],'m-s')
set(gca,'fontweight','demi','fontsize',16)
datetick('x','ddmmm')
ylabel('Wind Speed [m/s]'),

% subplot(2,1,2)
% plot([SWIFT.time],[SWIFT.winddirT],'g-o',[SWIFT.time],[SWIFT.referencewinddirT],'m-s')
% set(gca,'fontweight','demi','fontsize',16)
% datetick('x','ddmmm')
% ylabel('Wind Dir [deg]'),

figure(2), clf
scatter([SWIFT.referenceU10],[SWIFT.U10],'k.')
hold on, plot([0 20],[0 20],'k--')
set(gca,'fontweight','demi','fontsize',16)
xlabel('[m/s]'),ylabel('[m/s]')
title('Adjusted wind speed, U_{10} [m/s]')
axis square

good = ~isnan( [SWIFT.U10] - [SWIFT.referenceU10]); % & [SWIFT.U10] > 10;

U10Rsq = corrcoef([SWIFT(good).U10],[SWIFT(good).referenceU10])
U10bias = mean( [SWIFT(good).U10] - [SWIFT(good).referenceU10] )
U10rmserror = rms( [SWIFT(good).U10] - [SWIFT(good).referenceU10] - U10bias)


%% bin-averaged spectra

dw = 2;
windbins = [2:dw:18];

f = SWIFT(1).windspectra.freq;
spectra = zeros( length(windbins),length(f) );
n = zeros(length(windbins),1);

for wg = 1:length(SWIFT),
    
    %figure(10), loglog(f , SWIFT(wg).windspectra.energy .* f.^(5/3) ), drawnow
    
    [m bin] = min( abs( SWIFT(wg).U10 - windbins) );
    if ~isnan( SWIFT(wg).windspectra.energy ) & ~bad(wg);
        spectra(bin,:) = spectra(bin,:) + SWIFT(wg).windspectra.energy';
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
hold on, loglog([2 4],3*[2 4].^(-5/3),'k--','linewidth',1.5)
text(2.5,2.,'f^{-5/3}','fontweight','demi','fontsize',14)

%% recalc ustar from spectra

fmin = 2; % Hz
fmax = 5; % Hz
K = 0.55 ; % Kolmogorov const, factor by 4/3 for vertical or cross-flow component
kv = 0.4 ; % von Karman const  
z = 0.95; % meters above sea level, 0.77 for Gill on WG, 0.95 for RM Young on SWIFT

for wg = 1:length(SWIFT),
    if ~bad(wg),
        inertialrange = find( SWIFT(wg).windspectra.freq > fmin & SWIFT(wg).windspectra.freq < fmax);
        inertiallevel = nanmean( SWIFT(wg).windspectra.energy(inertialrange) .* (SWIFT(wg).windspectra.freq(inertialrange)).^(5/3) ) ;
        epsilon =  ( inertiallevel ./ ( ( SWIFT(wg).windspd ./ (2*pi) ).^(2/3)  .* K ) ).^(3/2);
        %epsilon =  ( inertiallevel ./ ( ( SWIFT(wg).windspd ).^(2/3)  .* K ) ).^(3/2);
        SWIFT(wg).windustar = (kv * epsilon * z ).^(1/3);  % assumes neutral
        SWIFT(wg).windustar = .5 * SWIFT(wg).windustar;
    else
        SWIFT(wg).windustar = NaN;
    end
end


%% Wave equilibrium estimates
beta = 0.012;
%Ip = 2.5; % option to calc below
g = 9.8;

for wg = 1:length(SWIFT),
    eqrange = find( SWIFT(wg).wavespectra.freq > 0.3 & SWIFT(wg).wavespectra.freq < 0.4);
    Theta = 0; %deg2rad( abs(SWIFT(wg).referencewinddirT - nanmean(SWIFT(wg).wavespectra.dir(eqrange))) ); % difference between wind and wave direction (both given as dir FROM)
    Ip = 2.5; % 3.14 - Theta - deg2rad( nanmean(SWIFT(wg).wavespectra.spread(eqrange)) ./ 2 );
    if   Ip > 1.9   &   Ip < 3.1   &   Theta < deg2rad(25) & ~bad(wg),
        SWIFT(wg).equilustar = 8 * (3.14)^4 * nanmean( SWIFT(wg).wavespectra.energy(eqrange) .* (SWIFT(wg).wavespectra.freq(eqrange)).^4 ) ./ (2*3.14*beta*Ip*g);
    else
         SWIFT(wg).equilustar = NaN;
    end
end

figure(4), clf
%scatter([SWIFT.equilustar],[SWIFT.windustar],10,uvratio,'filled'), caxis([-2 2])
scatter([SWIFT.equilustar],[SWIFT.windustar],10,[SWIFT.windanisotropy],'filled'), caxis([1 2])
%scatter([SWIFT.equilustar],[SWIFT.windustar],10,[SWIFT.windustarquality],'filled'), caxis([0.4 0.7])
hold on, plot([0 1],[0 1],'k--')
set(gca,'fontweight','demi','fontsize',16)
xlabel('u_{*eq} [m/s]'),
ylabel('u_* [m/s]')
axis square

good = ~isnan( [SWIFT.windustar] - [SWIFT.equilustar]);

equstarRsq = corrcoef([SWIFT(good).windustar],[SWIFT(good).equilustar])
equstarbias = mean( [SWIFT(good).windustar] - [SWIFT(good).equilustar] )
equstarrmserror = rms( [SWIFT(good).windustar] - [SWIFT(good).equilustar] - equstarbias)



%% compare with drag law
dw = 1;
windbins = [0:dw:20];

a = 1.4e-3;
b = 1e-6;
Cd = a  +  b * windbins.^2; % ad hoc version of Smith, 1980 
ustarcurve = ( Cd .* windbins.^2 ).^.5;

for wg = 1:length(SWIFT),
    SWIFT(wg).bulkustar = ( (a  +  b * SWIFT(wg).U10.^2) .* SWIFT(wg).U10.^2 ).^.5;
end

% stats
good = ~isnan( [SWIFT.windustar] - [SWIFT.bulkustar]);
buklustarRsq = corrcoef([SWIFT(good).windustar],[SWIFT(good).bulkustar])
bulkustarbias = mean( [SWIFT(good).windustar] - [SWIFT(good).bulkustar] )
bulkustarrmserror = rms( [SWIFT(good).windustar] - [SWIFT(good).bulkustar] - bulkustarbias)


figure(5), clf
hold on, plot(windbins,ustarcurve,'m-','linewidth',2)
%scatter([SWIFT.U10],[SWIFT.windustar],10,uvratio,'filled'), caxis([-2 2])
%scatter([SWIFT.U10],[SWIFT.windustar],10,[SWIFT.windanisotropy],'filled'), caxis([1 2])
%scatter([SWIFT.U10],[SWIFT.windustar],10,[SWIFT.airtemp]-[SWIFT.watertemp],'filled'), %caxis([0.4 0.7])
%scatter([SWIFT.U10],[SWIFT.windustar],10,[SWIFT.driftspd],'filled'), %caxis([0.4 0.7])
%scatter([SWIFT.U10],[SWIFT.windustar],10,[SWIFT.driftdirT]-[SWIFT.referencewinddirT],'filled'), %caxis([0.4 0.7])
%scatter([SWIFT.U10],[SWIFT.windustar],10,[SWIFT.driftdirT]-[SWIFT.sigwaveheight],'filled'), %caxis([0.4 0.7])
%hold on, plot([SWIFT.U10],[SWIFT.equilustar],'k.')
plot([SWIFT.U10],[SWIFT.equilustar],'bo','markersize',4), hold on
plot([SWIFT.U10],[SWIFT.windustar],'g.','markersize',16), hold on
hold on, plot(windbins,ustarcurve,'m-','linewidth',2)
set(gca,'fontweight','demi','fontsize',16)
xlabel('U_{10} [m/s]'), ylabel('u_* [m/s]')
legend('Smith, 1980','Wave Equilibrium','Inertial Dissipation','Location','NorthEastOutside')



