% plot high-res (post-processed) SWIFT data 
% along track signature and CT results
%
% J. Thomson, Nov 2021

clear all, close all

filename = 'SWIFT22_12Jun2021_highres_dt30s.mat';
load(filename)
nplots = 3;

%% CT data
subplot(nplots,1,1)
plot([SWIFT.time],[SWIFT.salinity],'.'),
set(gca,'FontSize',14,'fontweight','demi')
datetick
ylabel('S [PSU]')
cb=colorbar; cb.Visible='off';
title([filename ],'interpreter','none')


%% drift spd
subplot(nplots,1,2)
plot([SWIFT.time],[SWIFT.driftspd],'.'),
set(gca,'FontSize',14,'fontweight','demi')
datetick
ylabel('drift [m/s]')
cb=colorbar; cb.Visible='off';

%% current profiles
t = [SWIFT.time];
for si=1:length(SWIFT),
    z = SWIFT(si).signature.profile.z;
    current(si,:) = (SWIFT(si).signature.profile.east.^2 + SWIFT(si).signature.profile.north.^2).^.5;
    w(si,:) = SWIFT(si).signature.profile.wbar;
    depth(si) = SWIFT(si).signature.profile.depth;
end
subplot(nplots,1,3)
pcolor(t,z,current'), shading flat
hold on
plot(t,depth,'k.','markersize',14)
set(gca,'YDir','reverse')
set(gca,'FontSize',14,'fontweight','demi')
datetick
ylabel('z [m]')
cb = colorbar; cb.Label.String = '|u| [m/s]';

print('-dpng',[filename '_alongtrack_ubar.png'])

pause(5)

subplot(nplots,1,3)
pcolor(t,z,w'), shading flat
hold on
plot(t,depth,'k.','markersize',14)
set(gca,'YDir','reverse')
set(gca,'FontSize',14,'fontweight','demi')
datetick
ylabel('z [m]')
cb = colorbar; cb.Label.String = 'w [m/s]';
caxis([-.25 .25])

print('-dpng',[filename '_alongtrack_wbar.png'])
