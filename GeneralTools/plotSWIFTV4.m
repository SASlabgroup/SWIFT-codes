function fh = plotSWIFTV4(swift)

if size(swift,2)>1
    swift = catSWIFT(swift);
end

lw = 2;
nt = length(swift.time);

fh = figure('color','w');
MP = get(0,'monitorposition');
set(fh,'outerposition',MP(1,:));
if exist('tight_subplot','file')
    % https://www.mathworks.com/matlabcentral/fileexchange/27991-tight_subplot-nh-nw-gap-marg_h-marg_w
    h = tight_subplot(8,3,[0.035 0.05],[0.1 0.075],0.075);
else
    h = gobjects(24,1);
    for ii = 1:24
        h(ii) = subplot(8,3,ii);
    end
end
% tight_subplot(Nh, Nw, [gap_h gap_w], [lower upper], [left right] )

% Anemometer
axes(h(1))
plot(swift.time,swift.windu,'-rx','LineWidth',lw)
ylabel('U [ms^{-1}]')
title('Wind Speed')
ylim([0 15])
set(gca,'Clipping','off')
axes(h(4))
plot(swift.time,swift.tair,'-rx','LineWidth',lw)
%ylim([10 20])
ylabel('T_{air} [^{\circ}C]')
title('Air Temperature')

%IMU/GPS
axes(h(7))
plot(swift.time,swift.wavesigH,'-bx','LineWidth',lw)
ylabel('H_s [m]')
title('Significant Wave Height')
ylim([0 5])
axes(h(10))
plot(swift.time,swift.wavepeakT,'-bx','LineWidth',lw)
ylabel('T_p [s]')
title('Peak Wave Period')
ylim([0 10])
axes(h(13))
plot(swift.time,swift.wavepeakdir,'-bx','LineWidth',lw)
ylabel('\Theta [^{\circ}]')
title('Peak Wave Direction')
ylim([0 360])
axes(h(16))
plot(swift.time,swift.tsea,'-bx','LineWidth',lw)
ylabel('T_{sea} [^{\circ}C]')
title('Sea Temperature')
axes(h(19))
plot(swift.time,swift.sal,'-bx','LineWidth',lw)
ylabel('S [psu]')
title('Salinity')

axes(h(22))
if isfield(swift,'battery')
plot(swift.time,swift.battery,'-kx','linewidth',lw)
else
    plot(swift.time,NaN(1,nt),'-kx','linewidth',lw)
end
ylabel('[V]')
title('Battery Level')

% Middle-column geometry: stack the three pcolor panels (relu, relv,
% dissipation) deterministically so they fill the column with even gaps.
% Derived from the untouched middle-column axes so it works regardless of
% whether tight_subplot or plain subplot laid out the grid.
p2  = get(h(2),'Position');    % middle column, top row
p23 = get(h(23),'Position');   % middle column, bottom row
midx = p2(1);  midw = p2(3);
gtop = p2(2) + p2(4);          % top of column
gbot = p23(2);                 % bottom of column
vgap = 0.05;                   % gap between panels
unit = ((gtop - gbot) - 2*vgap) / 4;   % relu:relv:diss heights = 1:1:2

% ADCP
axes(h(5))
set(h(5),'Position',[midx, gtop-unit, midw, unit])
pcolor(swift.time,-swift.depth,swift.relu);shading flat
c = colorbar;
c.Label.String = 'U_r [ms^{-1}]';
cmocean('balance')
clim([-0.25 0.25])
ylabel('Z [m]')
title('Zonal Velocity (Relative)')

axes(h(11))
set(h(11),'Position',[midx, gtop-2*unit-vgap, midw, unit])
pcolor(swift.time,-swift.depth,swift.relv);shading flat
c = colorbar;
c.Label.String = 'V_r [ms^{-1}]';
cmocean('balance')
clim([-0.25 0.25])
ylabel('Z [m]')
title('Merid. Velocity (Relative)')

axes(h(23))
set(h(23),'Position',[midx, gbot, midw, 2*unit])
if isfield(swift,'surftke')
pcolor(swift.time,-swift.surfz,log10(swift.surftke));shading flat
    if median(log10(swift.surftke(:)),'omitnan')<-5.5
        clim([-8 -5])
    else
        clim([-6 -3])
    end
end
colormap(gca,'jet')
c = colorbar;
c.Label.String = '\epsilon [m^2s^{-3}]';
c.Location = 'NorthOutside';
ylabel('Z [m]')
title('Dissipation Rate (0-5 m, Wave Biased)')

% Right-column geometry: trajectory on top (2 units), the two wave-spectra
% panels below (1 unit each), mirroring the middle column. Derived from the
% untouched right-column axes so it is independent of the layout engine.
p3  = get(h(3),'Position');    % right column, top row
p24 = get(h(24),'Position');   % right column, bottom row
rx = p3(1);  rw = p3(3);
rtop = p3(2) + p3(4);
rbot = p24(2);
runit = ((rtop - rbot) - 2*vgap) / 4;

% Trajectory
axes(h(12))
set(h(12),'Position',[rx, rtop-2*runit, rw, 2*runit])
lonscale = mean(cos(swift.lat*pi/180),'omitnan');
scatter(swift.lon(:),swift.lat(:),36,swift.time(:),'filled');
set(gca,'YAxisLocation','right')
hold on
quiver(swift.lon,swift.lat,swift.driftu./lonscale,swift.driftv,'k')
c = colorbar;
c.Location = 'South';
c.TickLabels = datestr(c.Ticks,'mmm-dd');
ylabel('Lat [^{\circ}N]')
xlabel('Lon [^{\circ}E]')
set(gca,'XAxisLocation','top')
axis equal square

% Waves Spectra
% Shared axis ranges so the line and pcolor panels are directly comparable.
freqlim = [0.05 1];          % Hz, frequency range for both wave panels
powlim  = [-5 1];            % log10(P) range, amplitude for both wave panels
wmax    = 18;                % m/s, top of the wind-speed colour scale
cwind   = cmocean('matter',18);
ubin    = linspace(0,wmax,size(cwind,1)+1);  % uniform bins matching the colours

axes(h(18))
set(h(18),'Position',[rx, rtop-3*runit-vgap, rw, runit])
hold on   % keep every burst's spectrum, not just the last one
for it = 1:length(swift.time)
    if isnan(swift.windu(it))
        plot(swift.wavefreq,swift.wavepower(:,it),'k','LineWidth',2)
    else
        ibin = discretize(swift.windu(it),ubin);
        if isnan(ibin)                 % wind above range -> top colour
            ibin = size(cwind,1);
        end
        plot(swift.wavefreq,swift.wavepower(:,it),'color',cwind(ibin,:),'LineWidth',2)
    end
end
xlim(freqlim)
ylim(10.^powlim)
set(gca,'YScale','log','XScale','log')
colormap(gca,cwind)
clim([0 wmax])               % colourbar now reads directly in wind units
c = colorbar;
c.Label.String = 'U [ms^{-1}]';
xlabel('F [Hz]')
ylabel('P [m^2Hz^{-1}]')
title('Wave Spectra')
set(gca,'YTick',10.^(-4:2:0))

axes(h(24))
set(h(24),'Position',[rx, rbot, rw, runit])
pcolor(swift.time,swift.wavefreq,log10(swift.wavepower))
shading flat
set(gca,'YScale','log')
c = colorbar;
c.Label.String = 'P [m^2Hz^{-1}]';
set(gca,'YDir','Reverse')
clim(powlim)
c.Ticks = powlim(1):powlim(2);
c.TickLabels = arrayfun(@(p) sprintf('10^{%d}',p), c.Ticks, 'UniformOutput', false);
ylim(freqlim)
set(gca,'YTick',[0.1 0.5 1])
ylabel('F [Hz]')
% title('Wave Spectra')
cmocean('thermal')

% Hide the unused background grid cells in columns 2 and 3 (the tall
% repositioned panels above replace them).
set(h([2 8 14 17 20  3 6 9 15 21]),'Visible','off')

linkaxes(h([1:3:end 2:3:end 24]),'x')
set(h([1:3:end-3 2:3:end-3]),'XTickLabel',[])
axes(h(1))
xlim([min(swift.time) max(swift.time)])
axes(h(22))
datetick('x','KeepLimits')
xlabel('Time')
axes(h(23))
datetick('x','KeepLimits')
xlabel('Time')
axes(h(24))
datetick('x','KeepLimits')
xlabel('Time')

set(h,'FontSize',12)
%rmemptysub  % THIS BREAKS FOR JIM

end