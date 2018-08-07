function [] = plotSWIFT_wavesonly(SWIFT);

wd = pwd;
wdi = find(wd == '/',1,'last');
wd = wd((wdi+1):length(wd));

% wave parameter timeseries plot
figure(10), clf, n = 3; 

ax(2) = subplot(n,1,1);
plot( [SWIFT.time],[SWIFT.sigwaveheight],'g+','linewidth',2) 
datetick
ylabel([ 'waveheight [m]'])
set(gca,'Ylim',[0 10])


ax(3) = subplot(n,1,2);
plot( [SWIFT.time],[SWIFT.peakwaveperiod],'g+','linewidth',2) 
datetick
ylabel([ 'waveperiod [s]'])
set(gca,'Ylim',[0 18])

ax(4) = subplot(n,1,3);
plot([SWIFT.time],[SWIFT.peakwavedirT],'g+','linewidth',2), hold on
datetick
ylabel('directions [^\circ T]')
set(gca,'Ylim',[0 360])
set(gca,'YTick',[0 180 360])


linkaxes(ax,'x')
set(gca,'XLim',[min([SWIFT.time]) max([SWIFT.time])] )
print('-dpng',[wd  '_waveparameters.png'])
        
% wave spectra plot
figure(4), clf
for ai = 1:length(SWIFT), 

        loglog(SWIFT(ai).wavespectra.freq,SWIFT(ai).wavespectra.energy,'linewidth',2), hold on
        xlabel('freq [Hz]')
        ylabel('Energy [m^2/Hz')
end
print('-dpng',[ wd '_wavespectra.png'])
 
% drift plot
figure(6), clf
%quiver(lon,lat,dlondt,dlatdt,1), hold on
quiver([SWIFT.lon],[SWIFT.lat],[SWIFT.driftspd].*sind([SWIFT.driftdirT]),[SWIFT.driftspd].*cosd([SWIFT.driftdirT]),1,'r','linewidth',2), hold on
xlabel('longitude'), ylabel('latitude')
axlims = axis;
%quiver(axlims(1) +(axlims(2)-axlims(1))./10, axlims(3)+(axlims(4)-axlims(3))./10, .1, 0,0 );
%text(axlims(1) +(axlims(2)-axlims(1))./9, axlims(3)+(axlims(4)-axlims(3))./8,'0.1 m/s')
plot([SWIFT.lon],[SWIFT.lat],'bo','markersize',2), hold on
%plot(lon(length(lon)),lat(length(lon)),'r.','markersize',20), hold on
print('-dpng',[wd '_drift.png'])


