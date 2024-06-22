
function [swift,fh] = catSWIFT(SWIFT)
% Returns concatenated swift data in structure format

%Time, lat, lon, battery
swift.time = [SWIFT.time];
nt = length(swift.time);
swift.lon = 360 + [SWIFT.lon];
swift.lat = [SWIFT.lat];
swift.driftspd = [SWIFT.driftspd];
if isfield(SWIFT,'battery')
swift.battery = [SWIFT.battery];
end

% Air & sea temperature & pressure & salinity
if isfield(SWIFT,'airtemp')
swift.tair = [SWIFT.airtemp];
else
    swift.tair = NaN(1,nt);
end
for it = 1:nt
swift.tsea(it) = max(SWIFT(it).watertemp);
end
if isfield(SWIFT,'airtemp')
swift.tair = [SWIFT.airtemp];
else
    swift.tair = NaN(1,nt);
end
if isfield(SWIFT,'salinity')
    swift.sal = [SWIFT.salinity];
else
    swift.sal = NaN(1,nt);
end
if isfield(SWIFT,'airpres')
    swift.press = [SWIFT.airpres];
end

% Drift velocity
dx = NaN(1,nt);
dy = NaN(1,nt);
dt = NaN(1,nt);
dx(1:end-1) = diff(swift.lon).*111.12*10^3; %m
dx = dx.*cosd(swift.lat);
dy(1:end-1) = diff(swift.lat).*111.12*10^3; %m
dt(1:end-1) = diff(swift.time*24*60*60); %s
driftu = dx./dt;
driftv = dy./dt;
driftu(abs(driftu)>0.5) = NaN;
driftv(abs(driftv)>0.5) = NaN;
swift.driftu = driftu;
swift.driftv = driftv;

% Relative Velocity
if isfield(SWIFT,'signature') && isstruct(SWIFT(1).signature.profile)
    swift.depth = SWIFT(round(nt/2)).signature.profile.z';
    nz = length(swift.depth);
    swift.relu = NaN(nz,nt);
    swift.relv = NaN(nz,nt);
    swift.relw = NaN(nz,nt);
    swift.reluerr = NaN(nz,nt);
    swift.relverr = NaN(nz,nt);
    swift.relwerr = NaN(nz,nt);
    for it = 1:nt
        if isfield(SWIFT(it).signature.profile,'east') && ~isempty(SWIFT(it).signature.profile.east)
            swift.relu(:,it) = SWIFT(it).signature.profile.east;
            swift.relv(:,it) = SWIFT(it).signature.profile.north;
            if isfield(SWIFT(it).signature.profile,'w')
            swift.relw(:,it) = SWIFT(it).signature.profile.w;
            end
        elseif isfield(SWIFT(it).signature.profile,'u')  && ~isempty(SWIFT(it).signature.profile.u)
            swift.relu(:,it) = SWIFT(it).signature.profile.u;
            swift.relv(:,it) = SWIFT(it).signature.profile.v;
            swift.relw(:,it) = SWIFT(it).signature.profile.w;
            if isfield(SWIFT(it).signature.profile,'uvar')
            swift.reluerr(:,it) = SWIFT(it).signature.profile.uvar;
            swift.relverr(:,it) = SWIFT(it).signature.profile.vvar;
            swift.relwerr(:,it) = SWIFT(it).signature.profile.wvar;
            else
            swift.reluerr(:,it) = SWIFT(it).signature.profile.uerr;
            swift.relverr(:,it) = SWIFT(it).signature.profile.verr;
            swift.relwerr(:,it) = SWIFT(it).signature.profile.werr;
            end

        end
    end
elseif isfield(SWIFT,'downlooking')
    swift.depth = SWIFT(1).downlooking.z';
    nz = length(swift.depth);
    swift.relu = NaN(nz,nt);
    swift.relv = NaN(nz,nt);
    swift.relw = NaN(nz,nt);
    swift.reluerr = NaN(nz,nt);
    swift.relverr = NaN(nz,nt);
    swift.relwerr = NaN(nz,nt);       
elseif isfield(SWIFT,'uplooking')
    swift.depth = SWIFT(1).uplooking.z;
    nz = length(swift.depth);
    swift.relu = NaN(nz,nt);
    swift.relv = NaN(nz,nt);
    swift.relw = NaN(nz,nt);
    swift.reluerr = NaN(nz,nt);
    swift.relverr = NaN(nz,nt);
    swift.relwerr = NaN(nz,nt); 
else
    swift.depth = [0:0.5:20]';
    nz = length(swift.depth);
    swift.relu = NaN(nz,nt);
    swift.relv = NaN(nz,nt);
    swift.relw = NaN(nz,nt);
    swift.reluerr = NaN(nz,nt);
    swift.relverr = NaN(nz,nt);
    swift.relwerr = NaN(nz,nt); 
end
% Absolute velocity
swift.subu = swift.relu + swift.driftu;
swift.subv = swift.relv + swift.driftv;

%Waves
% SWIFT = SWIFT_Stokes(SWIFT);
for it = 1:nt
    wavepower = SWIFT(it).wavespectra.energy;
    wavefreq = SWIFT(it).wavespectra.freq;
    if length(wavepower) ~= length(wavefreq)
        wavepower = NaN(size(wavefreq));
    end
    if isempty(wavepower) || isempty(wavefreq)
        swift.wavepower(:,it) = 0;
        swift.wavefreq(:,it) = NaN;
    else
 swift.wavepower(:,it) = wavepower;
 swift.wavefreq(:,it) = wavefreq;
    end
end
swift.wavepower(swift.wavepower<0) = 0;
swift.wavefreq = mean(swift.wavefreq,2,'omitnan');
swift.wavesigH = [SWIFT.sigwaveheight];
swift.wavepeakT = [SWIFT.peakwaveperiod];
swift.wavepeakdir = [SWIFT.peakwavedirT];
% Calculate new Stokes drift (Us = omega*k*(Hs/4)^2)
om = 2*pi./swift.wavepeakT;
k = om.^2./9.81;
swift.waveustokes = (swift.wavesigH./4).^2.*om.*k;
% Re-calculate peak wave period (via centroid method)
wavepower = swift.wavepower;
wavefreq = swift.wavefreq;
wavevar = sum(wavepower,1,'omitnan');
waveweight = sum(wavepower.*repmat(wavefreq,1,size(wavepower,2)),1,'omitnan');
swift.wavepeakT = 1./(waveweight./wavevar);
% Directional Wave Spectra
% [~,swift.wavedir,~,~,~,~,~,~] = SWIFTdirectionalspectra(SWIFT(1),0);
% ndir = length(swift.wavedir);
% nf = length(wavefreq);
% swift.dirwavepower = NaN(nf,ndir,nt);
% for it = 1:nt
%     [swift.dirwavepower(:,:,it),~,~,~,~,~,~,~] = SWIFTdirectionalspectra(SWIFT(it),0);
% end

 % Wind
 if isfield(SWIFT,'windspd')
    swift.windu = [SWIFT.windspd];
 else
    swift.windu = NaN(size(swift.driftspd));
 end
 if isfield(SWIFT,'winddirT')
     swift.winddir = [SWIFT.winddirT];
 elseif isfield(SWIFT,'windmeanu')
    swift.winddir = atan2d([SWIFT.windmeanv],[SWIFT.windmeanu]);
 else
     swift.winddir = NaN(size(swift.driftspd));
 end
 if isfield(SWIFT,'windspectra')
    swift.windfreq = SWIFT(1).windspectra.freq;
    nf = length(swift.windfreq);
    swift.windpower = NaN(nf,nt);
    for it = 1:nt
     swift.windpower(:,it) = SWIFT(it).windspectra.energy;
    end
 else
    swift.windfreq = NaN(116,1);
    swift.windpower = NaN(116,nt);
 end

% TKE Dissipation Rate and HR vertical velocity
if isfield(SWIFT,'signature')
    swift.surfz = SWIFT(round(nt/2)).signature.HRprofile.z';
    nz = length(swift.surfz);
    swift.surftke = NaN(nz,nt);
    for it = 1:nt
        if isfield(SWIFT(it).signature.HRprofile,'tkedissipationrate')
        tke = SWIFT(it).signature.HRprofile.tkedissipationrate;
            if ~isempty(tke)
                swift.surftke(1:length(tke),it) = tke;
            else
                swift.surftke(:,it) = NaN(nz,1);
            end
        else
            swift.surftke(:,it) = NaN(nz,1);
        end
    end
elseif isfield(SWIFT,'uplooking')
    swift.surfz = SWIFT(1).uplooking.z';
    nz = length(swift.surfz);
    swift.surftke = NaN(nz,nt);
    for it = 1:nt
        swift.surftke(:,it) = SWIFT(it).uplooking.tkedissipationrate;
    end
    swift.surftke(1:4,:) = NaN;% Deepest three bins are bad 
end

%% Plot 

fh = figure('color','w','Name',['SWIFT' SWIFT(1).ID]);
lw = 2;
fullscreen
h = tight_subplot(8,3,[0.03 0.05],[0.125 0.1],0.075);

% Anemometer
axes(h(1))
plot(swift.time,swift.windu,'-rx','LineWidth',lw)
ylabel('U [ms^{-1}]')
title('Wind Speed')
axes(h(4))
plot(swift.time,swift.tair,'-rx','LineWidth',lw)
ylabel('T_{air} [^{\circ}C]')
title('Air Temperature')

%IMU/GPS
axes(h(7))
plot(swift.time,swift.wavesigH,'-bx','LineWidth',lw)
ylabel('H_s [m]')
title('Significant Wave Height')
axes(h(10))
plot(swift.time,swift.wavepeakT,'-bx','LineWidth',lw)
ylabel('T_p [s]')
title('Peak Wave Period')
axes(h(13))
plot(swift.time,swift.wavepeakdir,'-bx','LineWidth',lw)
ylabel('\Theta [^{\circ}]')
title('Peak Wave Direction')
axes(h(16))
plot(swift.time,swift.tsea,'-gx','LineWidth',lw)
ylabel('T_{sea} [^{\circ}C]')
title('Sea Temperature')
axes(h(19))
plot(swift.time,swift.sal,'-gx','LineWidth',lw)
ylabel('S [psu]')
title('Salinity')
axes(h(22))
plot([SWIFT.time],[SWIFT.battery],'-kx','linewidth',lw)
ylabel('[V]')
title('Battery Level')

% ADCP
axes(h(5))
ax = gca;ax.Position = ax.Position.*[1 1 1 2.1]+[-0.01 0.025 0 0];
imagesc(swift.time,swift.depth,swift.relu);
c = slimcolorbar;
c.Label.String = 'U_r [ms^{-1}]';
cmocean('balance')
clim([-0.25 0.25])
ylabel('Z [m]')
title('Zonal Velocity (Relative)')
axes(h(11))
ax = gca;ax.Position = ax.Position.*[1 1 1 2.1]+[-0.01 0.03 0 0];
imagesc(swift.time,swift.depth,swift.relv);
c = slimcolorbar;
c.Label.String = 'V_r [ms^{-1}]';
cmocean('balance')
clim([-0.25 0.25])
ylabel('Z [m]')
title('Merid. Velocity (Relative)')

if isfield(swift,'surftke')
axes(h(23))
ax = gca;ax.Position = ax.Position.*[1 1 1 4.2]+[-0.01 0 0 0];
imagesc(swift.time,swift.surfz,log10(swift.surftke))
c = slimcolorbar;
c.Label.String = '\epsilon [m^2s^{-3}]';
c.Location = 'NorthOutside';
clim([-6 -3])
ylabel('Z [m]')
title('Dissipation Rate (0-5 m, Wave Biased)')
end

% Trajectory
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
textlab(['SWIFT ' SWIFT(1).ID],'topleft')

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
xlim([0.05 0.5])
set(gca,'YScale','log')
colormap(gca,cwind)
c = slimcolorbar;
c.Label.String = 'U [ms^{-1}]';
c.Ticks = 0:0.25:1;
c.TickLabels = num2str((c.Ticks*16 + 2)');
xlabel('F [Hz]')
ylabel('P_{w} [m^2Hz^{-1}]')
title('Wave Spectra')
set(gca,'YTick',10.^([-4:2:1]))

axes(h(24))
ax = gca;ax.Position = ax.Position.*[1 1 1 2];
pcolor(swift.time,swift.wavefreq,log10(swift.wavepower))
shading flat
set(gca,'YScale','log')
c = slimcolorbar;
c.Label.String = 'P_{w} [m^2Hz^{-1}]';
set(gca,'YDir','Reverse')
ylim([0.05 0.5])
set(gca,'YTick',0.1:0.1:0.5)
ylabel('F [Hz]')

linkaxes(h([1:3:end 2:3:end 24]),'x')
set(h([1:3:end-3 2:3:end-3]),'XTickLabel',[])
axes(h(22))
axis tight
datetick('x','KeepLimits')
axes(h(23))
datetick('x','KeepLimits')
axes(h(24))
datetick('x','KeepLimits')

set(h,'FontSize',12)
rmemptysub

