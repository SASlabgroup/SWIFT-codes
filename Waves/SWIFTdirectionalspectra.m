function [Etheta theta E f dir spread spread2 spread2alt] = SWIFTdirectionalspectra(SWIFT, varargin);
% make directional spectra from a SWIFT data structure
% which can have multiple spectral results 
% (and the results will average it)
% using MEM estimator from direction moments (call to function MEM_directionalestimator.m)
% and rotating from cartesion directions to nautical convention
% compass direction FROM which waves are coming
% also reports the dominant direction at each frequency and the spread
%
% this is intended to be used after post-processing wave data with
% "reprocess_IMU.m" which uses "XYZwaves.m" to get coefficients
%
%    [Etheta theta E f dir spread spread2 spread2alt ] = SWIFTdirectionalspectra(SWIFT, plotflag, recip);
%
% J. Thomson, 10/2015, based on NCEX codes (J. Thomson, 2002)
%             4/2016 editted by Fabrice Ardhuin to energy weight coefs in determining average
%             5/2016 corrected typo in spread1
%             8/2016 enable reciprocal flag, for post-procesing vs onboard processing
%             1/2017 output multiple estimates of spread and add binary plotting flag
%             12/2018   add plots of directional distributions distinct freqs
%             3/2019 add second binary varargin to control reciprocal direction
%            

if isempty(varargin),
    plotflag = true;
    recip = false;
elseif length(varargin) == 1,
    plotflag = varargin{1};
    recip = false;
elseif length(varargin) == 2,
    plotflag = varargin{1};
    recip = varargin{2};
    %disp(['recip set to ' num2str(recip)] )
end

wd = pwd;
wdi = find(wd == '/',1,'last');
wd = wd((wdi+1):length(wd));

%% average the spectra in the input SWIFT structure (if more than one). 

f = SWIFT(1).wavespectra.freq;
df = median(diff(f));
E = zeros(size(f));%zeros(length(f),1);
a1 = zeros(size(f));%zeros(length(f),1);
a2 = zeros(size(f));%zeros(length(f),1);
b1 = zeros(size(f));%zeros(length(f),1);
b2 = zeros(size(f));%zeros(length(f),1);
counter = 0;


for ai = 1:length(SWIFT),
    
    SWIFT(ai).wavespectra.energy( SWIFT(ai).wavespectra.energy==9999 | isnan(SWIFT(ai).wavespectra.energy) ) = 0;
    SWIFT(ai).wavespectra.a1( SWIFT(ai).wavespectra.a1==9999 | isnan(SWIFT(ai).wavespectra.a1) ) = 0;
    SWIFT(ai).wavespectra.a2( SWIFT(ai).wavespectra.a2==9999 | isnan(SWIFT(ai).wavespectra.a2) ) = 0;
    SWIFT(ai).wavespectra.b1( SWIFT(ai).wavespectra.b1==9999 | isnan(SWIFT(ai).wavespectra.b1) ) = 0;
    SWIFT(ai).wavespectra.b2( SWIFT(ai).wavespectra.b2==9999 | isnan(SWIFT(ai).wavespectra.b2) ) = 0;

    
    if SWIFT(ai).sigwaveheight > 0 & SWIFT(ai).sigwaveheight < 20 & all(~isnan(SWIFT(ai).wavespectra.a1)),
        E = E + SWIFT(ai).wavespectra.energy;
        a1 = a1 + SWIFT(ai).wavespectra.a1.*SWIFT(ai).wavespectra.energy;
        a2 = a2 + SWIFT(ai).wavespectra.a2.*SWIFT(ai).wavespectra.energy;
        b1 = b1 + SWIFT(ai).wavespectra.b1.*SWIFT(ai).wavespectra.energy;
        b2 = b2 + SWIFT(ai).wavespectra.b2.*SWIFT(ai).wavespectra.energy;
        counter = counter + 1;
    else end
end

I=find(E > 0 & isnan(E) ==0);
E = E./counter;
a1(I) = a1(I)./(E(I)*counter);
b1(I) = b1(I)./(E(I)*counter);
a2(I) = a2(I)./(E(I)*counter);
b2(I) = b2(I)./(E(I)*counter);
%Hs = 4 * sqrt(nansum(E.*df))
Hs = 4 * sqrt(sum(E(I).*df));


%% calc MEM estimate of full dir distribution spectrum, then convert to nautical convention (compass dir FROM)
[Ethetanorm Etheta ] = MEM_directionalestimator(a1,a2,b1,b2,E,0);
dtheta = 2;
theta = -[-180:dtheta:179];  % start with cartesion (a1 is positive east velocities, b1 is positive north)

% rotate, flip and sort
theta = theta + 90;
theta(theta < 0) = theta( theta < 0 ) + 360;

if recip == true, 
    disp('taking reciprical directions (sanity check results)')
    westdirs = theta > 180;
    eastdirs = theta < 180;
    theta( westdirs ) = theta ( westdirs ) - 180; % take reciprocal such wave direction is FROM, not TOWARDS
    theta( eastdirs ) = theta ( eastdirs ) + 180; % take reciprocal such wave direction is FROM, not TOWARDS
else
end

[theta dsort] = sort(theta);
Etheta = Etheta(:,dsort);

%% spectral directions and spread, converted to nautical convention

dir1 = atan2(b1,a1) ;  % [rad], 4 quadrant
dir2 = atan2(b2,a2)/2 ; % [rad], only 2 quadrant
spread1 = sqrt( 2 * ( 1 - sqrt(a1.^2 + b1.^2) ) ); % radians?
% this is the usual definitionn e.g. OReilly et al. 1996
spread2 = sqrt( abs( 0.5 - 0.5 .* ( a2.*cos(2.*dir2) + b2.*sin(2.*dir2) )  )); % radians?
% Alternatively one can use (this is what is coded in WW3), and can be compared to tiltmeter data (Ardhuin et al. GRL 2016)
spread2alt = sqrt( abs( 0.5 - 0.5 .* ( a2.^2 + b2.^2 )  )); % radians?

% rotate and flip
dir = - 180 ./ pi * dir1;  % switch from rad to deg, and CCW to CW (negate)
dir = dir + 90;  % rotate from eastward = 0 to northward  = 0
dir( dir < 0 ) = dir( dir < 0 ) + 360;  % take NW quadrant from negative to 270-360 range
if recip == false, 
westdirs = dir > 180;
eastdirs = dir < 180;
dir( westdirs ) = dir ( westdirs ) - 180; % take reciprocal such wave direction is FROM, not TOWARDS
dir( eastdirs ) = dir ( eastdirs ) + 180; % take reciprocal such wave direction is FROM, not TOWARDS
else
end

if isreal(spread1),
    spread = 180 ./ 3.14 .* spread1;
else 
    spread = NaN(size(spread1));
end

spread2 = 180 ./ 3.14 .* spread2;
spread2alt = 180 ./ 3.14 .* spread2alt;


if plotflag == true, 

figure(3), clf
% 
% subplot(2,1,1)
% plot(f,E,'k',f,sum(Etheta*dtheta,2),'k--','linewidth',2), hold on
% ylabel('Energy [m^2/Hz')
% set(gca,'xlim',[0.05 0.5])
% %title(['SWIFT   ' datestr(mean([SWIFT.time]),1) ', Hs = ' num2str(Hs,2) ' m'])

%subplot(2,1,2)
%pcolor(f,theta,log10(Etheta')), shading flat;
if iscolumn(f),
    polarPcolor(f',theta(1:180),log10(Etheta(:,1:180)'));
elseif isrow(f), 
    polarPcolor(f,theta(1:180),log10(Etheta(:,1:180)'));
else
    disp('Problem with the size of frequency vector')
end
%ylabel('Direction [deg T]')
%xlabel('freq [Hz]')
%colorbar('peer',gca,'west')
%legend('log_{10} (E)')
title([ wd ', Hs = ' num2str(Hs,2) ' m'],'interpreter','none')


print('-dpng',[ wd '_directionalspectra.png'])
%print('-dpng',['SWIFT_dirwavespectra_' datestr(mean([SWIFT.time]),1) '.png'])

%% debugging plots

figure(4),clf

subplot(3,1,1)
plot(f,E,'k',f,sum(Etheta*dtheta,2),'k--','linewidth',2), hold on
set(gca,'Fontsize',14,'fontweight','demi')
ylabel('Energy [m^2/Hz]')
set(gca,'xlim',[0.05 max(f)])
title([ wd ', Hs = ' num2str(Hs,2) ' m'],'interpreter','none')


subplot(3,1,2)
errorbar(f,dir,spread,'k','markersize',16,'linewidth',2), hold on
set(gca,'Fontsize',14,'fontweight','demi')
ylabel('Dir [deg T]')
set(gca,'xlim',[0.05 max(f)])
set(gca,'ylim',[0 360],'YTick',[0 90 180 270 360])


subplot(3,1,3)
plot(f,a1,f,a2,f,b1,f,b2,'linewidth',2);
set(gca,'Fontsize',14,'fontweight','demi')
hold on
plot([min(f) max(f)],[0 0],'k:')
legend('a1','a2','b1','b2')
set(gca,'xlim',[0.05 max(f)])
set(gca,'ylim',[-1 1])
xlabel('Frequency [Hz]')
ylabel('Moments []')

print('-dpng',[ wd '_directionalmoments.png'])


%% distributions at freqs

figure(5), clf

r = 3; c = 3;
n = r * c;

for fi=1:n,
    subplot(r,c,fi)
    thisf = fi * ( ceil( length(f) / n ) - 1 );
    plot( theta , Etheta(thisf, :) ), hold on
    plot( [dir(thisf) dir(thisf)],[0 max(Etheta(thisf, :))], 'r-' )
    plot( [dir(thisf) + spread(thisf); dir(thisf) - spread(thisf); ],[max(Etheta(thisf, :))/2 max(Etheta(thisf, :))/2], 'r:' )
    title(['f = ' num2str( f(thisf) ) 'Hz' ] )
    set(gca,'XLim',[0 360])
    xlabel('\theta [deg]')
    ylabel('E')
end

print('-dpng',[ wd '_directiondistributions.png'])


else 
end
