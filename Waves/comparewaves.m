function [HsRsq Hsrmserror Hsbias Eratio f ] = comparewaves(SWIFT1, SWIFT2, tlimit, rlimit);
% matlab function to compare wave measurements from two SWIFTs, 
% or any platforms using the SWIFT data structure conventions
% using wave results that are with 'tlimit' time (days) and 
% 'xlimit' range distance (km) of each other
% 
% The comparison includes bulk statistics and spectral wave results
%
% [Rsq rmserror bias Eratio f] = comparewaves(SWIFT1, SWIFT2, tdiff, xdiff);
%
% Note that the first structure is used as the master clock 
% (points matching those times are found within the second structure)
%
% Note also that plots of the time series and scatter are automatically generated
%   with titles based on the working directory
%
%
% J. Thomson, 3/2017
%             10/2017 added optional output of energy ratio
% 

%% use working directory as title for plots
wd = pwd; 
for i= 1:length(wd), slash(i) = strcmp('/',wd(i)); end
wd = wd( (max(find(slash))+1):end )

%% match times and calc Te

matchedindex = zeros(length([SWIFT1.time]),1);

for si = 1:length([SWIFT1.time]),
    
    [thistdiff match ] = min( abs( SWIFT1(si).time - [SWIFT2.time] ) );
    tdiff(si) = thistdiff;
    
    % determine separation distance at minimum time difference
    dlon = SWIFT1(si).lon - SWIFT2(match).lon;
    dlat = SWIFT1(si).lat - SWIFT2(match).lat;
    dy = deg2km(dlat);
    dx = deg2km( dlon, 6371 * cosd( SWIFT1(si).lat) );
    rdiff(si) = sqrt( dx.^2 + dy.^2 );
   
    
    % calculate energy period (for later comparison)
    if isfield(SWIFT1(1),'wavespectra'),
        SWIFT1(si).energyperiod = nansum(SWIFT1(si).wavespectra.energy ) ./ nansum(SWIFT1(si).wavespectra.energy .* SWIFT1(si).wavespectra.freq);
    else
        SWIFT1(si).energyperiod = NaN;
    end
    
    % assign a match if within time and distance threshold for comparison
    if tdiff(si) < tlimit & rdiff(si) < rlimit, 
        matchedindex(si) = match;
        if isfield(SWIFT2(1),'wavespectra'),
            SWIFT2(match).energyperiod = nansum(SWIFT2(match).wavespectra.energy ) ./ nansum(SWIFT2(match).wavespectra.energy .* SWIFT2(match).wavespectra.freq);
        else
            SWIFT2(match).energyperiod = NaN;
        end
        
    else
    end
    
end

figure(7), clf 
subplot(2,1,1)
plot([SWIFT1.time],tdiff,'kx'),
datetick,  ylabel('time difference [days]')
subplot(2,1,2)
plot([SWIFT1.time],rdiff,'kx'), hold on
datetick, ylabel('distance difference [km]')
print -dpng time_and_distance.png


% prune whatever did not match
SWIFT1( matchedindex==0 ) = [];
matchedindex( matchedindex==0 ) = [];


%% Wave height stats, with QC bad points (low signal or nan, outliers, etc)

Hcutoff = 0.2;

bad = find( [SWIFT1.sigwaveheight] < Hcutoff | [SWIFT2(matchedindex).sigwaveheight] < Hcutoff);
SWIFT1(bad) = [];
matchedindex(bad) = [];

HsRsq = corrcoef([SWIFT1.sigwaveheight],[SWIFT2(matchedindex).sigwaveheight])
Hsbias = mean( [SWIFT1.sigwaveheight] - [SWIFT2(matchedindex).sigwaveheight] )
Hsrmserror = rms( [SWIFT1.sigwaveheight] - [SWIFT2(matchedindex).sigwaveheight] - Hsbias)

%% Peak period stats, with more QC

Tcutoff = 20;

bad = find( [SWIFT1.peakwaveperiod] > Tcutoff | [SWIFT2(matchedindex).peakwaveperiod] > Tcutoff );
SWIFT1(bad) = [];
matchedindex(bad) = [];

TpRsq = corrcoef([SWIFT1.peakwaveperiod], [SWIFT2(matchedindex).peakwaveperiod])
Tpbias = mean( [SWIFT1.peakwaveperiod] - [SWIFT2(matchedindex).peakwaveperiod] )
Tprmserror = rms( [SWIFT1.peakwaveperiod] - [SWIFT2(matchedindex).peakwaveperiod] - Tpbias)


%% Energy period stats

TeRsq = corrcoef([SWIFT1.energyperiod], [SWIFT2(matchedindex).energyperiod])
Tebias = mean( [SWIFT1.energyperiod] - [SWIFT2(matchedindex).energyperiod] )
Termserror = rms( [SWIFT1.energyperiod] - [SWIFT2(matchedindex).energyperiod] - Tebias)


%% peak direction cutoff, with more QC

Dcutoff = 180; % look for directions that have wrapped around 360 (and thus would have huge rms differences)

bad = find( abs( [SWIFT1.peakwavedirT] - [SWIFT2(matchedindex).peakwavedirT] ) > Dcutoff);
SWIFT1(bad) = [];
matchedindex(bad) = [];

DpRsq = corrcoef([SWIFT1.peakwavedirT], [SWIFT2(matchedindex).peakwavedirT])
Dpbias = mean( [SWIFT1.peakwavedirT] - [SWIFT2(matchedindex).peakwavedirT] )
Dprmserror = rms( [SWIFT1.peakwavedirT] - [SWIFT2(matchedindex).peakwavedirT] - Dpbias)

%% scatter plot
figure(1), clf

subplot(1,3,1)
plot([0 ceil(max([SWIFT1.sigwaveheight]))],[0 ceil(max([SWIFT1.sigwaveheight]))],'--','color',[.5 .5 .5]), hold on
plot([SWIFT2(matchedindex).sigwaveheight],[SWIFT1.sigwaveheight],'k.')
set(gca,'fontsize',12,'fontweight','demi')
title('Wave height')
xlabel('[m]'),ylabel('[m]')
axis square
text(4, ceil(max([SWIFT2(matchedindex).sigwaveheight])) + 3, wd,'interpreter','none','fontsize',12,'fontweight','demi')
text(0.5, 0.8* max([SWIFT2(matchedindex).sigwaveheight]) , '(a)','interpreter','none','fontsize',12,'fontweight','demi')


subplot(1,3,2)
plot([0 18],[0 18],'--','color',[.5 .5 .5]), hold on
plot([SWIFT2(matchedindex).peakwaveperiod],[SWIFT1.peakwaveperiod],'k.'), hold on
plot([SWIFT2(matchedindex).energyperiod],[SWIFT1.energyperiod],'g.'), hold on
set(gca,'fontsize',12,'fontweight','demi')
title('Wave period')
xlabel('[s]'),ylabel('[s]')
axis square
text(1, 18, '(b)','interpreter','none','fontsize',12,'fontweight','demi')


subplot(1,3,3)
plot([0 360],[0 360],'--','color',[.5 .5 .5]), hold on
plot([SWIFT2(matchedindex).peakwavedirT],[SWIFT1.peakwavedirT],'k.'), hold on
set(gca,'fontsize',12,'fontweight','demi')
title('Wave direction')
xlabel('[deg]'),ylabel('[deg]')
axis([0 360 0 360])
set(gca,'YTick',[0 180 360],'XTick',[0 180 360])
axis square
text(20, 340, '(c)','interpreter','none','fontsize',12,'fontweight','demi')


print -dpng scatter.png
savefig('scatter.fig')

%% timeseries plot
figure(2), clf

subplot(3,1,1)
plot([SWIFT1.time],[SWIFT1.sigwaveheight],'b.',[SWIFT2(matchedindex).time],[SWIFT2(matchedindex).sigwaveheight],'r.','markersize',12)
set(gca,'fontsize',14,'fontweight','demi')
datetick('x','ddmmm')
set(gca,'XTickLabel',[])
set(gca,'YLim',[0 (max([SWIFT1.sigwaveheight])+1)])
ylabel('H_s [m]')
title(wd,'interpreter','none')
text(min([SWIFT1.time]), ceil(max([SWIFT2(matchedindex).sigwaveheight])) -1, '(a)','interpreter','none','fontsize',12,'fontweight','demi')


subplot(3,1,2)
plot([SWIFT1.time],[SWIFT1.peakwaveperiod],'b.',[SWIFT2(matchedindex).time],[SWIFT2(matchedindex).peakwaveperiod],'r.','markersize',12)
set(gca,'fontsize',14,'fontweight','demi')
datetick('x','ddmmm')
set(gca,'XTickLabel',[])
ylabel('T_p [s]')
text(min([SWIFT1.time]), ceil(max([SWIFT2(matchedindex).peakwaveperiod])) -1, '(b)','interpreter','none','fontsize',12,'fontweight','demi')


subplot(3,1,3)
plot([SWIFT1.time],[SWIFT1.peakwavedirT],'b.',[SWIFT2(matchedindex).time],[SWIFT2(matchedindex).peakwavedirT],'r.','markersize',12)
set(gca,'fontsize',14,'fontweight','demi')
datetick('x','ddmmm')
set(gca,'YLim',[0 360],'YTick',[0 180 360])
ylabel('D_p [s]')
xlabel(datestr(max([SWIFT1.time]),'yyyy'))
text(min([SWIFT1.time]), 340, '(c)','interpreter','none','fontsize',12,'fontweight','demi')


print -dpng comparetimeseries.png
savefig('comparetimeseries.fig')

%% IF SPECTRA

if isfield(SWIFT1(1),'wavespectra') & isfield(SWIFT2(1),'wavespectra'),


%% spectral energy difference plot
figure(3), clf

allenergy1 = zeros(length(SWIFT1(1).wavespectra.freq), 1 ); 
allenergy2 = zeros(length(SWIFT1(1).wavespectra.freq), 1 );
allenergydiff = zeros(length(SWIFT1(1).wavespectra.freq), 1 );
allenergyratio = ones(length(SWIFT1(1).wavespectra.freq), 1 );


for si=1:length(SWIFT1), 
    
    e1 = SWIFT1(si).wavespectra.energy;
    f = SWIFT1(si).wavespectra.freq;
    f2 = SWIFT2(matchedindex(si)).wavespectra.freq;
    good = ~isnan(SWIFT2(matchedindex(si)).wavespectra.freq) & ~isinf(SWIFT2(matchedindex(si)).wavespectra.freq) &  SWIFT2(matchedindex(si)).wavespectra.energy > 0;
    if sum(good) > 3, 
        e2 = interp1( SWIFT2(matchedindex(si)).wavespectra.freq(good), SWIFT2(matchedindex(si)).wavespectra.energy(good), f);%,'linear',NaN);
    else
        e2 = NaN(size(e1));
    end
    ediff = e1 - e2;
    eratio = e1 ./ e2;
    allenergy1 = nansum( [allenergy1 e1], 2);
    allenergy2 = nansum( [allenergy2 e2], 2);
    allenergydiff = nansum( [allenergydiff ediff], 2);
    allenergyratio = nansum( [allenergyratio eratio], 2);
    
    % make arrays for pcolors
    energy1array(:,si) = e1;
    energy2array(:,si) = e2;
    
end

meanenergy1 = allenergy1 ./ si;
meanenergy2 = allenergy2 ./ si;
meanenergydiff = allenergydiff ./ si;
meanenergyratio = allenergyratio ./ si;
    Eratio = meanenergyratio;

meanenergy1( meanenergy1 == 0 ) = NaN;
meanenergy2( meanenergy2 == 0 ) = NaN;
meanenergydiff( meanenergydiff == 0 ) = NaN;
meanenergyratio( meanenergyratio == 0 ) = NaN;


subplot(2,1,1)
%plot(f,energy1array,'b:',f,energy2array,'r:','linewidth',.5), hold on
plot(f,meanenergy1,'b-',f,meanenergy2,'r-','linewidth',3)
set(gca,'fontsize',14,'fontweight','demi')
title(wd,'interpreter','none')
ylabel('Energy density [m^2/Hz]')
set(gca,'XTickLabel',[])
set(gca,'XLim',[0 0.4])
text(0.02, 6, '(a)','interpreter','none','fontsize',12,'fontweight','demi')


% subplot(3,1,2)
% plot(f,meanenergydiff,'kx'), hold on
% plot(f,zeros(1,length(f)),':','color',[.5 .5 .5])
% ylabel('Energy difference [m^2/Hz]')
% set(gca,'XTickLabel',[])

subplot(2,1,2)
plot(f,meanenergyratio,'kx'), hold on
plot(f,ones(1,length(f)),':','color',[.5 .5 .5])
set(gca,'YLim',[0 5])
set(gca,'fontsize',14,'fontweight','demi')
ylabel('Ratio []')
set(gca,'XLim',[0 0.4])
text(0.02, 3, '(b)','interpreter','none','fontsize',12,'fontweight','demi')


xlabel('Frequency [Hz]')

print -dpng compareenergyspectra.png
savefig('compareenergyspectra.fig')

figure(10), clf
subplot(2,1,1)
pcolor([SWIFT1.time],f,log10(energy1array)), shading interp,  caxis([-1 1]) % log
%pcolor([SWIFT1.time],f,energy1array), shading flat % linear
set(gca,'fontsize',14,'fontweight','demi')
title(wd,'interpreter','none')
datetick
ylabel('Frequency [Hz]')

subplot(2,1,2)
pcolor([SWIFT1.time],f,log10(energy2array)), shading interp,  caxis([-1 1]) % log
%pcolor([SWIFT1.time],f,energy2array), shading flat % linear
set(gca,'fontsize',14,'fontweight','demi')
datetick
ylabel('Frequency [Hz]')

% colormap gray
% cmap = colormap;
% cmap = flipud(cmap);
% colormap(cmap)

print -dpng compareenergyspectrograms.png



%% spectral direction difference plot

if isfield(SWIFT1(1).wavespectra,'dir') & isfield(SWIFT2(1).wavespectra,'dir'), 

figure(4), clf

alldir1 = zeros(length(SWIFT1(1).wavespectra.freq), 1 ); 
alldir2 = zeros(length(SWIFT1(1).wavespectra.freq), 1 );
alldirdiff = zeros(length(SWIFT1(1).wavespectra.freq), 1 );
alldirratio = zeros(length(SWIFT1(1).wavespectra.freq), 1 );


for si=1:length(SWIFT1), 
    
    e1 = SWIFT1(si).wavespectra.dir;
    f = SWIFT1(si).wavespectra.freq;
    good = ~isnan(SWIFT2(matchedindex(si)).wavespectra.freq) & ~isinf(SWIFT2(matchedindex(si)).wavespectra.freq);
    e2 = interp1( SWIFT2(matchedindex(si)).wavespectra.freq(good), SWIFT2(matchedindex(si)).wavespectra.dir(good), f);
    ediff = e1 - e2;
    eratio = e1 ./ e2;
    alldir1 = alldir1 + e1;
    alldir2 = alldir2 + e2;
    alldirdiff = alldirdiff + ediff;
    alldirratio = alldirratio + eratio;
    
end

meandir1 = alldir1 ./ si;
meandir2 = alldir2 ./ si;
meandirdiff = alldirdiff ./ si;
meandirratio = alldirratio ./ si;

meandir1( meandir1 == 0 ) = NaN;
meandir2( meandir2 == 0 ) = NaN;
meandirdiff( meandirdiff == 0 ) = NaN;
meandirratio( meandirratio == 0 ) = NaN;

subplot(2,1,1)
plot(f,meandir1,'b-',f,meandir2,'r-')
set(gca,'fontsize',14,'fontweight','demi')
title(wd,'interpreter','none')
ylabel('Direction [deg]')
set(gca,'YLim',[0 360],'YTick',[0 180 360])
set(gca,'XTickLabel',[])
text(0.02, 340, '(a)','interpreter','none','fontsize',12,'fontweight','demi')


% subplot(3,1,2)
% plot(f,meandirdiff,'kx'), hold on
% plot(f,zeros(1,length(f)),':','color',[.5 .5 .5])
% ylabel('Dir difference [deg]')
% set(gca,'XTickLabel',[])

subplot(2,1,2)
plot(f,meandirratio,'kx'), hold on
plot(f,ones(1,length(f)),':','color',[.5 .5 .5])
set(gca,'fontsize',14,'fontweight','demi')
set(gca,'YLim',[0 2])
ylabel('Ratio []')
text(0.02, 1.5, '(b)','interpreter','none','fontsize',12,'fontweight','demi')

xlabel('Frequency [Hz]')

print -dpng comparedirspectra.png
savefig('comparedirspectra.fig')

else
end

%% spectral spread difference plot

if isfield(SWIFT1(1).wavespectra,'spread') & isfield(SWIFT2(1).wavespectra,'spread'), 


figure(5), clf

allspread1 = zeros(length(SWIFT1(1).wavespectra.freq), 1 ); 
allspread2 = zeros(length(SWIFT1(1).wavespectra.freq), 1 );
allspreaddiff = zeros(length(SWIFT1(1).wavespectra.freq), 1 );
allspreadratio = zeros(length(SWIFT1(1).wavespectra.freq), 1 );


for si=1:length(SWIFT1), 
    
    e1 = SWIFT1(si).wavespectra.spread;
    f = SWIFT1(si).wavespectra.freq;
    good = ~isnan(SWIFT2(matchedindex(si)).wavespectra.freq) & ~isinf(SWIFT2(matchedindex(si)).wavespectra.freq);
    e2 = interp1( SWIFT2(matchedindex(si)).wavespectra.freq(good), SWIFT2(matchedindex(si)).wavespectra.spread(good), f);
    ediff = e1 - e2;
    eratio = e1 ./ e2;
    allspread1 = nansum( [allspread1 e1], 2 );
    allspread2 = nansum( [allspread2 e2], 2 );
    allspreaddiff = nansum( [allspreaddiff ediff], 2);
    allspreadratio = nansum( [allspreadratio eratio], 2);
    
end

meanspread1 = allspread1 ./ si;
meanspread2 = allspread2 ./ si;
meanspreaddiff = allspreaddiff ./ si;
meanspreadratio = allspreadratio ./ si;

meanspread1( meanspread1 == 0 ) = NaN;
meanspread2( meanspread2 == 0 ) = NaN;
meanspreaddiff( meanspreaddiff == 0 ) = NaN;
meanspreadratio( meanspreadratio == 0 ) = NaN;

subplot(2,1,1)
plot(f,meanspread1,'b-',f,meanspread2,'r-')
set(gca,'fontsize',14,'fontweight','demi')
title(wd,'interpreter','none')
ylabel('Spread [deg]')
set(gca,'XTickLabel',[])

% subplot(3,1,2)
% plot(f,meanspreaddiff,'kx'), hold on
% plot(f,zeros(1,length(f)),':','color',[.5 .5 .5])
% ylabel('Spread difference [deg]')
% set(gca,'XTickLabel',[])

subplot(2,1,2)
plot(f,meanspreadratio,'kx'), hold on
plot(f,ones(1,length(f)),':','color',[.5 .5 .5])
set(gca,'fontsize',14,'fontweight','demi')
ylabel('Ratio []')
set(gca,'YLim',[0 4])


xlabel('Frequency [Hz]')

print -dpng comparedirspread.png
savefig('comparedirspread.fig')

else 
end

%% spectral check factors 

if isfield(SWIFT1(1).wavespectra,'check') & isfield(SWIFT2(1).wavespectra,'check'), 

figure(6), clf

allcheck1 = zeros(length(SWIFT1(1).wavespectra.freq), 1 ); 
allcheck2 = zeros(length(SWIFT1(1).wavespectra.freq), 1 );
allcheckdiff = zeros(length(SWIFT1(1).wavespectra.freq), 1 );
allcheckratio = zeros(length(SWIFT1(1).wavespectra.freq), 1 );


for si= find(~isnan([SWIFT1.sigwaveheight])), 
    
    e1 = SWIFT1(si).wavespectra.check';
    f = SWIFT1(si).wavespectra.freq;
    good = ~isnan(SWIFT2(matchedindex(si)).wavespectra.freq) & ~isinf(SWIFT2(matchedindex(si)).wavespectra.freq);
    e2 = interp1( SWIFT2(matchedindex(si)).wavespectra.freq(good), SWIFT2(matchedindex(si)).wavespectra.check(good), f);
    ediff = e1 - e2;
    eratio = e1 ./ e2;
    allcheck1 = nansum( [allcheck1 e1], 2 );
    allcheck2 = nansum( [allcheck2 e2], 2 );
    %allcheckdiff = nansum( [allcheckdiff ediff], 2);
    %allcheckratio = nansum( [allcheckratio eratio], 2);
    
end

meancheck1 = allcheck1 ./ sum((~isnan([SWIFT1.sigwaveheight])));
meancheck2 = allcheck2 ./ sum((~isnan([SWIFT1.sigwaveheight])));
%meancheckdiff = allcheckdiff ./ si;
%meancheckratio = allcheckratio ./ si;


meancheck1( meancheck1 == 0 ) = NaN;
meancheck2( meancheck2 == 0 ) = NaN;

subplot(2,1,1)
plot(f,meancheck1,'b-',f,meancheck2,'r-'), hold on
plot(f,ones(1,length(f)),':','color',[.5 .5 .5])
set(gca,'YLim',[0 3])
set(gca,'fontsize',14,'fontweight','demi')
ylabel('check factor []')
title(wd,'interpreter','none')
% set(gca,'XTickLabel',[])
% 
% subplot(3,1,2)
% plot(f,meancheckdiff,'k-')
% ylabel('check difference [deg]')
% set(gca,'XTickLabel',[])
% 
% subplot(3,1,3)
% plot(f,meancheckratio,'k-')
% ylabel('check ratio []')

xlabel('Frequency [Hz]')

print -dpng comparecheckfactors.png
savefig('comparecheckfactors.fig')

else 
end

%% NO SPECTRA

else 
end

disp(['days of data ' num2str(range([SWIFT1.time])) ])
