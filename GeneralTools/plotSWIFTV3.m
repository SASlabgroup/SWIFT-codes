function fh = plotSWIFTV3(swift)

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
ylabel('T_{air} [^{\circ}C]')
title('Air Temperature')

% IMU/GPS
axes(h(7))
plot(swift.time,swift.wavesigH,'-bx','LineWidth',lw)
ylabel('H_s [m]')
title('Significant Wave Height')
ylim([0 5])
set(gca,'Clipping','off')
axes(h(10))
plot(swift.time,swift.wavepeakT,'-bx','LineWidth',lw)
ylabel('T_p [s]')
title('Peak Wave Period')
ylim([0 10])
set(gca,'Clipping','off')
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

% Battery
axes(h(22))
if isfield(swift,'battery')
plot(swift.time,swift.battery,'-kx','linewidth',lw)
else
    plot(swift.time,NaN(1,nt),'-kx','linewidth',lw)
end
ylabel('[V]')
title('Battery Level')

% Additional Met (humidity, rain, raddiance, skin temp)
axes(h(2))
if isfield(swift,'rain')
plot(swift.time,swift.rain,'-x','color',rgb('grey'),'LineWidth',lw)
else
    plot(swift.time,NaN(1,nt),'-x','color',rgb('grey'),'LineWidth',lw)
end
ylabel('Rain [mm]')
title('Rainfall')

axes(h(5))
if isfield(swift,'humid')
plot(swift.time,swift.humid,'-rx','LineWidth',lw)
else
    plot(swift.time,NaN(1,nt),'-rx','LineWidth',lw)
end
ylabel('RH [%]')
ylim([0 100])
title('Relative Humidity')

% Radiometers
axes(h(8))
if isfield(swift,'IRtemp')
    plot(swift.time,swift.IRtemp,'-bx','LineWidth',lw);
    if size(swift.IRtemp,2)==2
        hold on
        plot(swift.time,swift.IRtemp(:,2),'-rx','LineWidth',lw)
    end
else
    plot(swift.time,NaN(1,nt),'-bx','LineWidth',lw);
end
ylabel('T [^{\circ}C]')
title('Brightness Temperature')
axis tight
datetick('x','KeepLimits')

axes(h(11))
if isfield(swift,'AMBtemp')
    plot(swift.time,swift.AMBtemp,'-bx','LineWidth',lw);
    if size(swift.AMBtemp,2)==2
        hold on
        plot(swift.time,swift.AMBtemp(:,2),'-rx','LineWidth',lw)
    end
else
    plot(swift.time,NaN(1,nt),'-bx','LineWidth',lw);
end
ylabel('T [^{\circ}C]')
title('Jacket Temperature')
axis tight
datetick('x','KeepLimits')

% Location
axes(h(12))
ax = gca;ax.Position = ax.Position.*[1 1 1 5];
lonscale = mean(cos(swift.lat*pi/180),'omitnan');
scatter(swift.lon,swift.lat,[],swift.time,'filled');
set(gca,'YAxisLocation','right')
hold on
quiver(swift.lon,swift.lat,swift.driftu./lonscale,swift.driftv,'k')
c = slimcolorbar;
c.Location = 'South';
c.TickLabels = datestr(c.Ticks,'mmm-dd');
ylabel('Lat [^{\circ}N]')
xlabel('Lon [^{\circ}E]')
set(gca,'XAxisLocation','top')
axis equal square

% Wind Spectra
axes(h(17))
ax = gca;ax.Position = ax.Position.*[1 1 1 2];
cwind = cmocean('matter',18);
ubin = [0 2:18 50];
if isfield(swift,'windpower')
    for it = 1:length(swift.time)
        if ~isnan(swift.windu(it))
        [~,~,ibin] = histcounts(swift.windu(it),ubin);
        if ibin ~= 0
        plot(swift.windfreq,swift.windpower(:,it),'color',cwind(ibin,:),'LineWidth',2)
        hold on
        else
            plot(swift.windfreq,swift.windpower(:,it),'k','LineWidth',2)
        end
        else
            plot(swift.windfreq,swift.windpower(:,it),'k','LineWidth',2)
        end
    end
end
xlim([0.05 5])
ylim(10.^([-4 2]))
set(gca,'YScale','log','XScale','log')
colormap(gca,cwind)
xlabel('F [Hz]')
ylabel('P [m^2s^{-2}Hz^{-1}]')
title('Wind Spectra')
set(gca,'YTick',10.^(-5:2:2))
set(gca,'XTick',10.^(-2:2))
set(gca,'XTickLabel',{'10^{-2','10^0','10^2'})

axes(h(23))
ax = gca;ax.Position = ax.Position.*[1 1 1 2];
if isfield(swift,'windpower') && any(~isnan(swift.windpower(:)))
pcolor(swift.time,swift.windfreq,log10(swift.windpower))
shading flat
end
ylim([0.05 5])
set(gca,'YScale','log')
c = slimcolorbar;
set(gca,'YDir','Reverse')
ylabel('F [Hz]')
cmocean('thermal')
clim([-3 2])
c.Ticks = -3:2:2;
c.TickLabels = {'10^{-3}','10^{-1}','10^1'};
 c.Position = c.Position+[-0.01 0 0 0];

% Waves Spectra
axes(h(18))
ax = gca;ax.Position = ax.Position.*[1 1 1 2];
cwind = cmocean('matter',18);
ubin = [0 2:18 50];
if isfield(swift,'wavepower')
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
end
xlim([0.05 1])
ylim(10.^([-5 0]))
set(gca,'YScale','log','XScale','log')
colormap(gca,cwind)
c = slimcolorbar;
c.Label.String = 'U [ms^{-1}]';
c.Ticks = 0:0.25:1;
c.TickLabels = num2str((c.Ticks*16 + 2)');
xlabel('F [Hz]')
ylabel('P [m^2Hz^{-1}]')
title('Wave Spectra')
set(gca,'YTick',10.^(-4:2:1))

axes(h(24))
ax = gca;ax.Position = ax.Position.*[1 1 1 2];
if isfield(swift,'wavepower')
pcolor(swift.time,swift.wavefreq,log10(swift.wavepower))
end
shading flat
set(gca,'YScale','log')
c = slimcolorbar;
c.Label.String = 'P [m^2Hz^{-1}]';
set(gca,'YDir','Reverse')
c.Ticks = -3:1:0;
c.TickLabels = {'10^{-3}','10^{-2}','10^{-1}','10^0'};
ylim([0.05 1])
set(gca,'YTick',[0.1 0.5 1])
cmocean('thermal')
 c.Position = c.Position+[-0.01 0 0 0];

linkaxes(h([1:3:end 2:3:11 23 24]),'x')
set(h([1:3:end-3 2:3:8]),'XTickLabel',[])
axes(h(1))
axis tight
axes(h(11))
datetick('x','KeepLimits')
xlabel('Time')
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
rmemptysub

end