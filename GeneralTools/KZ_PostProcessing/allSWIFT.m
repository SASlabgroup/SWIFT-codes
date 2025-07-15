function swift = allSWIFT(expdir,level,plotall)
% plotallSWIFT: Overview plot of 'level' (e.g. 'L3') processed data from all missions in
% an experiment directory. 'level' is a string.

% K. Zeiden March 2025

if ispc
    slash = '\';
else
    slash = '/';
end

missions = dir([expdir slash 'SWIFT*']);

if isempty(missions)
    disp(['No missions found in ' expdir])
    return
end

swift = struct;

t0 = now;
tf = 0;

for im = 1:length(missions)

    Lfile = dir([missions(im).folder slash missions(im).name slash '*' level '.mat']);

    if isempty(Lfile)
        disp(['No ' level ' product found in ' missions(im).name '. Skipping...'])
    else
        disp(['Loading ' missions(im).name ' ' level ' product(s)...'])
        for ifile = 1:length(Lfile)
        load([Lfile(ifile).folder slash Lfile(ifile).name],'SWIFT');
        oneswift = catSWIFT(SWIFT);
            ID = SWIFT(1).ID;
        stime = oneswift.time;
        sdate = [datestr(min(stime),'mmdd') '_' datestr(max(stime),'mmdd')];
        sname = ['SN' ID '_' sdate];
        swift.(sname) = oneswift;

            if min(stime) < t0
                t0 = min(stime);
            end
            if max(stime) > tf
                tf = max(stime);
            end

        end
    end

end

%% Plotting params
if ~plotall
    return
end
MP = get(0,'monitorposition');
if size(MP,1) > 1
    MP = MP(2,:);
end
mks = 2;
swifts = fieldnames(swift);
nswift = length(swifts);
cswift = jet(nswift);

SNs = cell(nswift,1);
for iswift = 1:nswift
    SNs{iswift} = swifts{iswift}(3:4);
end
SNs = unique(SNs);
nSN = length(SNs);

% if nargin > 0
% end

tlim = [t0 tf];

%% MET

fh = figure('color','w','Name',[expdir  ' ' level ' MET Data']);
set(fh,'outerposition',MP);
for iswift = 1:nswift
    subplot(4,1,1);
    plot(swift.(swifts{iswift}).time,swift.(swifts{iswift}).windu,'-o','color',rgb('grey'),...
        'MarkerEdgeColor',cswift(iswift,:),'MarkerFaceColor',cswift(iswift,:),'MarkerSize',mks)
    hold on
    subplot(4,1,2);
    plot(swift.(swifts{iswift}).time,swift.(swifts{iswift}).tair,'-o','color',rgb('grey'),...
        'MarkerEdgeColor',cswift(iswift,:),'MarkerFaceColor',cswift(iswift,:),'MarkerSize',mks)
    hold on
    subplot(4,1,3);
    if mean(swift.(swifts{iswift}).press,'omitnan') < 10
        sca = 1000;
    else 
        sca = 1;
    end
    plot(swift.(swifts{iswift}).time,swift.(swifts{iswift}).press.*sca,'-o','color',rgb('grey'),...
        'MarkerEdgeColor',cswift(iswift,:),'MarkerFaceColor',cswift(iswift,:),'MarkerSize',mks)
    hold on
    subplot(4,1,4);
    plot(swift.(swifts{iswift}).time,swift.(swifts{iswift}).humid,'-o','color',rgb('grey'),...
        'MarkerEdgeColor',cswift(iswift,:),'MarkerFaceColor',cswift(iswift,:),'MarkerSize',mks)
    hold on
end
subplot(4,1,1);title([level ' Wind Speed']);ylabel('U [ms^{-1}]');axis tight;datetick('x','KeepLimits');ylim([0 30])
subplot(4,1,2);title([level ' Air Temperature']);ylabel('T [C^{\circ}]');axis tight;datetick('x','KeepLimits');ylim([-5 30])
subplot(4,1,3);title([level ' Air Pressure']);ylabel('P [dB]');axis tight;datetick('x','KeepLimits');ylim([950 1050])
subplot(4,1,4);title([level ' Humidity']);ylabel('Rh [%]');axis tight;datetick('x','KeepLimits');ylim([0 100])
h = findall(fh,'Type','axes');
for ih = 1:length(h)
    if isempty(h(ih).Children)
        delete(h(ih))
    end
end
h = findall(fh,'Type','axes');
if isempty(h)
    close(fh)
else
linkaxes(h,'x');
subplot(4,1,1)
axP = get(gca,'Position');
legend(swifts','Interpreter','none','FontSize',8,'Location','EastOutside')
set(gca, 'Position', axP);
ylim([0 30])
xlim(tlim)
end

%% CT & Drift Speed
fh = figure('color','w','Name',[expdir  ' ' level ' CT +  Drift Data']);
set(fh,'outerposition',MP);
for iswift = 1:nswift
    subplot(4,1,1);
    plot(swift.(swifts{iswift}).time,swift.(swifts{iswift}).windu,'-o','color',rgb('grey'),...
        'MarkerEdgeColor',cswift(iswift,:),'MarkerFaceColor',cswift(iswift,:),'MarkerSize',mks)
    hold on
    subplot(4,1,2)
    plot(swift.(swifts{iswift}).time,swift.(swifts{iswift}).tsea,'-o','color',rgb('grey'),...
        'MarkerEdgeColor',cswift(iswift,:),'MarkerFaceColor',cswift(iswift,:),'MarkerSize',mks)
    hold on
    subplot(4,1,3);
    plot(swift.(swifts{iswift}).time,swift.(swifts{iswift}).sal,'-o','color',rgb('grey'),...
        'MarkerEdgeColor',cswift(iswift,:),'MarkerFaceColor',cswift(iswift,:),'MarkerSize',mks)
    hold on
    subplot(4,1,4);
    swifts{iswift}
    plot(swift.(swifts{iswift}).time,swift.(swifts{iswift}).driftspd,'-o','color',rgb('grey'),...
        'MarkerEdgeColor',cswift(iswift,:),'MarkerFaceColor',cswift(iswift,:),'MarkerSize',mks)
    hold on
end
subplot(4,1,1);title([level ' Wind Speed']);ylabel('U [ms^{-1}]');axis tight;datetick('x','KeepLimits');ylim([0 30])
subplot(4,1,2);title([level ' Sea Temperature']);ylabel('T [C^{\circ}]');axis tight;datetick('x','KeepLimits');ylim([-2 25])
subplot(4,1,3);title([level ' Salinity']);ylabel('S [psu]');axis tight;datetick('x','KeepLimits');ylim([34 38])
subplot(4,1,4);title([level ' Drift Speed']);ylabel('U [ms^{-1}]');axis tight;datetick('x','KeepLimits');ylim([0 1])

h = findall(fh,'Type','axes');
for ih = 1:length(h)
    if isempty(h(ih).Children)
        delete(h(ih))
    end
end
h = findall(fh,'Type','axes');
if isempty(h)
    close(fh)
else
linkaxes(h,'x');
axP = get(gca,'Position');
legend(swifts','Interpreter','none','FontSize',8,'Location','EastOutside')
set(gca, 'Position', axP);
xlim(tlim)
end
%% Waves
fh = figure('color','w','Name',[expdir  ' ' level ' Wave Data']);
set(fh,'outerposition',MP);
h = tight_subplot(nSN+1,1,0.025);
for iswift = 1:nswift
    axes(h(1))
    plot(swift.(swifts{iswift}).time,swift.(swifts{iswift}).windu,'-o','color',rgb('grey'),...
        'MarkerEdgeColor',cswift(iswift,:),'MarkerFaceColor',cswift(iswift,:),'MarkerSize',mks)
    hold on

    SN = swifts{iswift}(3:4);
    iSN = find(strcmp(SNs,SN));

    axes(h(iSN+1))
    pcolor(swift.(swifts{iswift}).time,swift.(swifts{iswift}).wavefreq,log10(swift.(swifts{iswift}).wavepower));
    shading flat
    hold on
    title(['SWIFT' SN])
    
end
linkaxes(h,'x');
axes(h(1))
axis tight
xlim(tlim)
ylim([0 20])
legend(swifts','Interpreter','none','FontSize',8,'Location','Northeast')
title([level ' Wave Spectra'])
set(h(1:end-1),'XTickLabel',[])
axes(h(end)); datetick('x','KeepLimits','KeepTicks')
set(h(2:end),'YLim',[0 1],'YDir','Reverse','CLim',[-5 1])
colormap(cmocean('thermal'))

% Delete if empty
for ih = 1:length(h)
    if isempty(h(ih).Children)
        delete(h(ih))
    end
end
h = findall(fh,'Type','axes');
if isempty(h) || length(h) == 1
    close(fh)
        disp('No wave data.')

end


%% ADCP Velocities

fh = figure('color','w','Name',[expdir  ' ' level ' Velocity Data']);
set(fh,'outerposition',MP);
h = tight_subplot(nSN+1,1,0.025);
for iswift = 1:nswift

    if isfield(swift.(swifts{iswift}),'relu')
    axes(h(1))
    plot(swift.(swifts{iswift}).time,swift.(swifts{iswift}).windu,'-o','color',rgb('grey'),...
        'MarkerEdgeColor',cswift(iswift,:),'MarkerFaceColor',cswift(iswift,:),'MarkerSize',mks)
    hold on

    SN = swifts{iswift}(3:4);
    iSN = find(strcmp(SNs,SN));

    axes(h(iSN+1))
    if ~any(isnan(swift.(swifts{iswift}).depth)) && any(~isnan(swift.(swifts{iswift}).relu(:)))
    pcolor(swift.(swifts{iswift}).time,swift.(swifts{iswift}).depth,swift.(swifts{iswift}).relu);
    end
    shading flat
    hold on
    title(['SWIFT' SN])
    end
    
end
linkaxes(h,'x');
axes(h(1))
axis tight
ylim([0 20])
xlim(tlim)
legend(swifts','Interpreter','none','FontSize',8,'Location','Northeast')
title([level ' Zonal Velocity'])
set(h(1:end-1),'XTickLabel',[])
axes(h(end)); datetick('x','KeepLimits','KeepTicks')
set(h(2:end),'YLim',[0 21],'YDir','Reverse','CLim',[-0.2 0.2])
colormap(cmocean('balance'))

% Delete if empty
for ih = 1:length(h)
    if isempty(h(ih).Children)
        delete(h(ih))
    end
end
h = findall(fh,'Type','axes');
if isempty(h) || length(h) == 1
    close(fh)
        disp('No velocity data.')
end


%% Alternative Speed Velocities

fh = figure('color','w','Name',[expdir  ' ' level ' Scalar Shear Data']);
set(fh,'outerposition',MP);
h = tight_subplot(nSN+1,1,0.025);
for iswift = 1:nswift

    if isfield(swift.(swifts{iswift}),'spd_alt')
    axes(h(1))
    plot(swift.(swifts{iswift}).time,swift.(swifts{iswift}).windu,'-o','color',rgb('grey'),...
        'MarkerEdgeColor',cswift(iswift,:),'MarkerFaceColor',cswift(iswift,:),'MarkerSize',mks)
    hold on

    SN = swifts{iswift}(3:4);
    iSN = find(strcmp(SNs,SN));

    axes(h(iSN+1))
    if ~any(isnan(swift.(swifts{iswift}).depth)) && any(~isnan(swift.(swifts{iswift}).spd_alt(:)))
    pcolor(swift.(swifts{iswift}).time,swift.(swifts{iswift}).depth,swift.(swifts{iswift}).spd_alt);
    end
    shading flat
    hold on
    title(['SWIFT' SN])

    end
    
end

linkaxes(h,'x');
axes(h(1))
axis tight
ylim([0 20])
xlim(tlim)
legend(swifts','Interpreter','none','FontSize',8,'Location','Northeast')
title([level ' Scalar Speed'])
set(h(1:end-1),'XTickLabel',[])
axes(h(end)); datetick('x','KeepLimits','KeepTicks')
set(h(2:end),'YLim',[0 21],'YDir','Reverse','CLim',[0 1])

% Delete if empty
for ih = 1:length(h)
    if isempty(h(ih).Children)
        delete(h(ih))
    end
end
h = findall(fh,'Type','axes');
if isempty(h) || length(h) == 1
    close(fh)
    disp('No scalar speed data.')
end

%% ADCP Dissipation Rate

fh = figure('color','w','Name',[expdir  ' ' level ' Turbulence Data']);
set(fh,'outerposition',MP);
h = tight_subplot(nSN+1,1,0.025);

for iswift = 1:nswift
    axes(h(1))
    plot(swift.(swifts{iswift}).time,swift.(swifts{iswift}).windu,'-o','color',rgb('grey'),...
        'MarkerEdgeColor',cswift(iswift,:),'MarkerFaceColor',cswift(iswift,:),'MarkerSize',mks)
    hold on

    SN = swifts{iswift}(3:4);
    iSN = find(strcmp(SNs,SN));

    axes(h(iSN+1))
    if ~any(isnan(swift.(swifts{iswift}).surfz)) && any(~isnan(swift.(swifts{iswift}).surftke(:))) && ~any(swift.(swifts{iswift}).surftke(:)<0)
    pcolor(swift.(swifts{iswift}).time,swift.(swifts{iswift}).surfz,log10(swift.(swifts{iswift}).surftke));
    end
    shading flat
    hold on
    title(['SWIFT' SN])
    
end
linkaxes(h,'x');
axes(h(1))
axis tight
ylim([0 20])
xlim(tlim)
legend(swifts','Interpreter','none','FontSize',8,'Location','Northeast')
title([level ' Dissipation Rate'])
set(h(1:end-1),'XTickLabel',[])
axes(h(end)); datetick('x','KeepLimits','KeepTicks')
set(h(2:end),'YLim',[0 5.5],'YDir','Reverse','CLim',[-7 -4])
colormap(jet)

% Delete if empty
for ih = 1:length(h)
    if isempty(h(ih).Children)
        delete(h(ih))
    end
end
h = findall(fh,'Type','axes');
if isempty(h) || length(h) == 1
    close(fh)
    disp('No scalar speed data.')
end


end