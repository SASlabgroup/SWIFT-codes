function fh = plotSWIFTV4(swift)

if size(swift,2)>1
    swift = catSWIFT(swift);
end

lw = 2;
nt = length(swift.time);

fh = figure('color','w','Visible','off');  % build hidden, render once at the end
MP = get(0,'monitorposition');
set(fh,'outerposition',MP(1,:));
hastight = logical(exist('tight_subplot','file'));
if hastight
    % https://www.mathworks.com/matlabcentral/fileexchange/27991-tight_subplot-nh-nw-gap-marg_h-marg_w
    h = tight_subplot(8,3,[0.035 0.05],[0.1 0.075],0.075);
    % tight_subplot(Nh, Nw, [gap_h gap_w], [lower upper], [left right] )
else
    h = gobjects(24,1);
    for ii = 1:24
        h(ii) = subplot(8,3,ii);
    end
end

% Anemometer
set(fh,'CurrentAxes',h(1))
plot(swift.time,swift.windu,'-rx','LineWidth',lw)
ylabel('U [ms^{-1}]')
title('Wind Speed')
ylim([0 15])
set(gca,'Clipping','off')
set(fh,'CurrentAxes',h(4))
plot(swift.time,swift.tair,'-rx','LineWidth',lw)
%ylim([10 20])
ylabel('T_{air} [^{\circ}C]')
title('Air Temperature')

%IMU/GPS
set(fh,'CurrentAxes',h(7))
plot(swift.time,swift.wavesigH,'-bx','LineWidth',lw)
ylabel('H_s [m]')
title('Significant Wave Height')
ylim([0 5])
set(fh,'CurrentAxes',h(10))
plot(swift.time,swift.wavepeakT,'-bx','LineWidth',lw)
ylabel('T_p [s]')
title('Peak Wave Period')
ylim([0 10])
set(fh,'CurrentAxes',h(13))
plot(swift.time,swift.wavepeakdir,'-bx','LineWidth',lw)
ylabel('\Theta [^{\circ}]')
title('Peak Wave Direction')
ylim([0 360])
set(fh,'CurrentAxes',h(16))
plot(swift.time,swift.tsea,'-bx','LineWidth',lw)
ylabel('T_{sea} [^{\circ}C]')
title('Sea Temperature')
set(fh,'CurrentAxes',h(19))
plot(swift.time,swift.sal,'-bx','LineWidth',lw)
ylabel('S [psu]')
title('Salinity')

set(fh,'CurrentAxes',h(22))
if isfield(swift,'battery')
plot(swift.time,swift.battery,'-kx','linewidth',lw)
else
    plot(swift.time,NaN(1,nt),'-kx','linewidth',lw)
end
ylabel('[V]')
title('Battery Level')

% Positions for the six tall middle/right-column panels (relu, relv,
% dissipation; trajectory, wave-line, wave-pcolor). With tight_subplot present
% we keep the original relative transforms; without it the plain-subplot
% margins make those overflow, so stack the panels deterministically instead.
if hastight
    pos.relu = get(h(5), 'Position').*[1 1 1 2.1] + [-0.01 0.025 0 0];
    pos.relv = get(h(11),'Position').*[1 1 1 2.1] + [-0.01 0.03  0 0];
    pos.diss = get(h(23),'Position').*[1 1 1 4.2] + [-0.01 0     0 0];
    pos.traj = get(h(12),'Position').*[1 1 1 5];
    pos.wsp1 = get(h(18),'Position').*[1 1 1 2];
    pos.wsp2 = get(h(24),'Position').*[1 1 1 2];
else
    vgap = 0.05;
    % middle column: relu / relv / dissipation stacked 1:1:2
    p2 = get(h(2),'Position');  p23 = get(h(23),'Position');
    midx = p2(1);  midw = p2(3);
    gtop = p2(2)+p2(4);  gbot = p23(2);
    unit = ((gtop-gbot) - 2*vgap)/4;
    pos.relu = [midx, gtop-unit,        midw, unit];
    pos.relv = [midx, gtop-2*unit-vgap, midw, unit];
    pos.diss = [midx, gbot,             midw, 2*unit];
    % right column: trajectory / wave-line / wave-pcolor stacked 2:1:1
    p3 = get(h(3),'Position');  p24 = get(h(24),'Position');
    rx = p3(1);  rw = p3(3);
    rtop = p3(2)+p3(4);  rbot = p24(2);
    runit = ((rtop-rbot) - 2*vgap)/4;
    pos.traj = [rx, rtop-2*runit,      rw, 2*runit];
    pos.wsp1 = [rx, rtop-3*runit-vgap, rw, runit];
    pos.wsp2 = [rx, rbot,              rw, runit];
end

% ADCP
set(fh,'CurrentAxes',h(5))
set(h(5),'Position',pos.relu)
pcolor(swift.time,-swift.depth,swift.relu);shading flat
c = colorbar;
c.Label.String = 'U_r [ms^{-1}]';
cmocean('balance')
clim([-0.25 0.25])
ylabel('Z [m]')
title('Zonal Velocity (Relative)')

set(fh,'CurrentAxes',h(11))
set(h(11),'Position',pos.relv)
pcolor(swift.time,-swift.depth,swift.relv);shading flat
c = colorbar;
c.Label.String = 'V_r [ms^{-1}]';
cmocean('balance')
clim([-0.25 0.25])
ylabel('Z [m]')
title('Merid. Velocity (Relative)')

set(fh,'CurrentAxes',h(23))
set(h(23),'Position',pos.diss)
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

% Trajectory
set(fh,'CurrentAxes',h(12))
set(h(12),'Position',pos.traj)
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

set(fh,'CurrentAxes',h(18))
set(h(18),'Position',pos.wsp1)
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

set(fh,'CurrentAxes',h(24))
set(h(24),'Position',pos.wsp2)
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
cmocean('thermal')

delete(h([2 8 14 17 20  3 6 9 15 21]))

% Downstream calls skip any deleted handles (no-op under tight_subplot, where
% nothing was deleted, so the original behavior is preserved there).
xlinked = h([1:3:end 2:3:end 24]);
linkaxes(xlinked(isgraphics(xlinked)),'x')
noxlbl = h([1:3:end-3 2:3:end-3]);
set(noxlbl(isgraphics(noxlbl)),'XTickLabel',[])
set(fh,'CurrentAxes',h(1))
xlim([min(swift.time) max(swift.time)])
set(fh,'CurrentAxes',h(22))
datetick('x','KeepLimits')
xlabel('Time')
set(fh,'CurrentAxes',h(23))
datetick('x','KeepLimits')
xlabel('Time')
set(fh,'CurrentAxes',h(24))
datetick('x','KeepLimits')
xlabel('Time')

set(h(isgraphics(h)),'FontSize',12)
%rmemptysub  % THIS BREAKS FOR JIM

set(fh,'Visible','on')   % reveal and render the fully-built figure in one pass
drawnow

end
