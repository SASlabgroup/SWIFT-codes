function fh = plotSWIFTV4(swift)

if size(swift,2)>1
    swift = catSWIFT(swift);
end

lw = 2;
nt = length(swift.time);

fh = figure('color','w');
MP = get(0,'monitorposition');
set(fh,'outerposition',MP(1,:));
h = tight_subplot(8,3,[0.035 0.05],[0.1 0.075],0.075);
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

% ADCP
axes(h(5))
ax = gca;ax.Position = ax.Position.*[1 1 1 2.1]+[-0.01 0.025 0 0];
pcolor(swift.time,-swift.depth,swift.relu);shading flat
c = colorbar;
c.Label.String = 'U_r [ms^{-1}]';
cmocean('balance')
clim([-0.25 0.25])
ylabel('Z [m]')
title('Zonal Velocity (Relative)')

axes(h(11))
ax = gca;ax.Position = ax.Position.*[1 1 1 2.1]+[-0.01 0.03 0 0];
pcolor(swift.time,-swift.depth,swift.relv);shading flat
c = colorbar;
c.Label.String = 'V_r [ms^{-1}]';
cmocean('balance')
clim([-0.25 0.25])
ylabel('Z [m]')
title('Merid. Velocity (Relative)')

axes(h(23))
ax = gca;ax.Position = ax.Position.*[1 1 1 4.2]+[-0.01 0 0 0];
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
axes(h(12))
ax = gca;ax.Position = ax.Position.*[1 1 1 5];
lonscale = mean(cos(swift.lat*pi/180),'omitnan');
scatter(swift.lon,swift.lat,[],swift.time,'filled');
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
axes(h(18))
ax = gca;ax.Position = ax.Position.*[1 1 1 2];
cwind = cmocean('matter',18);
ubin = [0 2:18 50];
for it = 1:length(swift.time)
    if ~isnan(swift.windu(it))
    [~,~,ibin] = histcounts(swift.windu(it),ubin);
    if ibin ~= 0
    plot(swift.wavefreq,swift.wavepower(:,it),'color',cwind(ibin,:),'LineWidth',2)
    hold on
    else
        plot(swift.wavefreq,swift.wavepower(:,it),'k','LineWidth',2)
    end
    else
        plot(swift.wavefreq,swift.wavepower(:,it),'k','LineWidth',2)
    end
end
ylim(10.^([-5 2]))
xlim([0.1 1])
set(gca,'YScale','log','XScale','log')
colormap(gca,cwind)
c = colorbar;
c.Label.String = 'U [ms^{-1}]';
c.Ticks = 0:0.25:1;
c.TickLabels = num2str((c.Ticks*16 + 2)');
xlabel('F [Hz]')
ylabel('P [m^2Hz^{-1}]')
title('Wave Spectra')
set(gca,'YTick',10.^(-4:2:1))

axes(h(24))
ax = gca;ax.Position = ax.Position.*[1 1 1 2];
pcolor(swift.time,swift.wavefreq,log10(swift.wavepower))
shading flat
set(gca,'YScale','log')
c = colorbar;
c.Label.String = 'P [m^2Hz^{-1}]';
set(gca,'YDir','Reverse')
clim([-5 0])
c.Ticks = -5:1:0;
c.TickLabels = {'10^{-3}','10^{-2}','10^{-1}','10^0'};
ylim([0.05 1])
set(gca,'YTick',[0.1 0.5 1])
cmocean('thermal')

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