function allswift = plotallSWIFT(expdir,level,allswift)
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

if isempty(allswift)

allswift = struct;

    for im = 1:length(missions)
    
        Lfile = dir([missions(im).folder slash missions(im).name slash '*' level '.mat']);
    
        if length(missions(im).name) ~= 17
            disp(['Skippping ' missions(im).name])
            continue
        end
    
        ID = missions(im).name(6:7);
        sdate = datestr(datenum(missions(im).name(9:17),'ddmmmyyyy'),'mmdd');
    
        sname = ['SN' ID '_' sdate];
    
        if isempty(Lfile)
            disp(['No ' level ' product found in ' missions(im).name '. Skipping...'])
        else
            disp(['Loading ' missions(im).name ' ' level ' product...'])
            load([Lfile.folder slash Lfile.name],'SWIFT');
            % SWIFT = SWIFT_Stokes(SWIFT);
            swift = catSWIFT(SWIFT);
            allswift.(sname) = swift;
        end
    
    end

end

%% Plotting params
MP = get(0,'monitorposition');
mks = 2;
swifts = fieldnames(allswift);
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

%% MET

fh = figure('color','w','Name',[expdir  ' ' level ' MET Data']);
set(fh,'outerposition',MP(1,:));
for iswift = 1:nswift
    subplot(4,1,1);
    plot(allswift.(swifts{iswift}).time,allswift.(swifts{iswift}).windu,'-o','color',rgb('grey'),...
        'MarkerEdgeColor',cswift(iswift,:),'MarkerFaceColor',cswift(iswift,:),'MarkerSize',mks)
    hold on
    subplot(4,1,2);
    plot(allswift.(swifts{iswift}).time,allswift.(swifts{iswift}).tair,'-o','color',rgb('grey'),...
        'MarkerEdgeColor',cswift(iswift,:),'MarkerFaceColor',cswift(iswift,:),'MarkerSize',mks)
    hold on
    subplot(4,1,3);
    if mean(allswift.(swifts{iswift}).press,'omitnan') < 10
        sca = 1000;
    else 
        sca = 1;
    end
    plot(allswift.(swifts{iswift}).time,allswift.(swifts{iswift}).press.*sca,'-o','color',rgb('grey'),...
        'MarkerEdgeColor',cswift(iswift,:),'MarkerFaceColor',cswift(iswift,:),'MarkerSize',mks)
    hold on
    subplot(4,1,4);
    plot(allswift.(swifts{iswift}).time,allswift.(swifts{iswift}).humid,'-o','color',rgb('grey'),...
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
axis tight
ylim([0 30])
end
%% CT & Drift Speed
fh = figure('color','w','Name',[expdir  ' ' level ' CT +  Drift Data']);
set(fh,'outerposition',MP(1,:));
for iswift = 1:nswift
    subplot(4,1,1);
    plot(allswift.(swifts{iswift}).time,allswift.(swifts{iswift}).windu,'-o','color',rgb('grey'),...
        'MarkerEdgeColor',cswift(iswift,:),'MarkerFaceColor',cswift(iswift,:),'MarkerSize',mks)
    hold on
    subplot(4,1,2)
    plot(allswift.(swifts{iswift}).time,allswift.(swifts{iswift}).tsea,'-o','color',rgb('grey'),...
        'MarkerEdgeColor',cswift(iswift,:),'MarkerFaceColor',cswift(iswift,:),'MarkerSize',mks)
    hold on
    subplot(4,1,3);
    plot(allswift.(swifts{iswift}).time,allswift.(swifts{iswift}).sal,'-o','color',rgb('grey'),...
        'MarkerEdgeColor',cswift(iswift,:),'MarkerFaceColor',cswift(iswift,:),'MarkerSize',mks)
    hold on
    subplot(4,1,4);
    plot(allswift.(swifts{iswift}).time,allswift.(swifts{iswift}).driftspd,'-o','color',rgb('grey'),...
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
end
%% Waves
fh = figure('color','w','Name',[expdir  ' ' level ' Wave Data']);
set(fh,'outerposition',MP(1,:));
h = tight_subplot(nSN+1,1,0.025);
for iswift = 1:nswift
    axes(h(1))
    plot(allswift.(swifts{iswift}).time,allswift.(swifts{iswift}).windu,'-o','color',rgb('grey'),...
        'MarkerEdgeColor',cswift(iswift,:),'MarkerFaceColor',cswift(iswift,:),'MarkerSize',mks)
    hold on

    SN = swifts{iswift}(3:4);
    iSN = find(strcmp(SNs,SN));

    axes(h(iSN+1))
    pcolor(allswift.(swifts{iswift}).time,allswift.(swifts{iswift}).wavefreq,log10(allswift.(swifts{iswift}).wavepower));
    shading flat
    hold on
    title(['SWIFT' SN])
    
end
linkaxes(h,'x');
axes(h(1))
axis tight
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
set(fh,'outerposition',MP(1,:));
h = tight_subplot(nSN+1,1,0.025);
for iswift = 1:nswift

    if isfield(allswift.(swifts{iswift}),'relu')
    axes(h(1))
    plot(allswift.(swifts{iswift}).time,allswift.(swifts{iswift}).windu,'-o','color',rgb('grey'),...
        'MarkerEdgeColor',cswift(iswift,:),'MarkerFaceColor',cswift(iswift,:),'MarkerSize',mks)
    hold on

    SN = swifts{iswift}(3:4);
    iSN = find(strcmp(SNs,SN));

    axes(h(iSN+1))
    if ~any(isnan(allswift.(swifts{iswift}).depth)) && any(~isnan(allswift.(swifts{iswift}).relu(:)))
    pcolor(allswift.(swifts{iswift}).time,allswift.(swifts{iswift}).depth,allswift.(swifts{iswift}).relu);
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
set(fh,'outerposition',MP(1,:));
h = tight_subplot(nSN+1,1,0.025);
for iswift = 1:nswift

    if isfield(allswift.(swifts{iswift}),'spd_alt')
    axes(h(1))
    plot(allswift.(swifts{iswift}).time,allswift.(swifts{iswift}).windu,'-o','color',rgb('grey'),...
        'MarkerEdgeColor',cswift(iswift,:),'MarkerFaceColor',cswift(iswift,:),'MarkerSize',mks)
    hold on

    SN = swifts{iswift}(3:4);
    iSN = find(strcmp(SNs,SN));

    axes(h(iSN+1))
    if ~any(isnan(allswift.(swifts{iswift}).depth)) && any(~isnan(allswift.(swifts{iswift}).spd_alt(:)))
    pcolor(allswift.(swifts{iswift}).time,allswift.(swifts{iswift}).depth,allswift.(swifts{iswift}).spd_alt);
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
set(fh,'outerposition',MP(1,:));
h = tight_subplot(nSN+1,1,0.025);

for iswift = 1:nswift
    axes(h(1))
    plot(allswift.(swifts{iswift}).time,allswift.(swifts{iswift}).windu,'-o','color',rgb('grey'),...
        'MarkerEdgeColor',cswift(iswift,:),'MarkerFaceColor',cswift(iswift,:),'MarkerSize',mks)
    hold on

    SN = swifts{iswift}(3:4);
    iSN = find(strcmp(SNs,SN));

    axes(h(iSN+1))
    if ~any(isnan(allswift.(swifts{iswift}).surfz)) && any(~isnan(allswift.(swifts{iswift}).surftke(:))) && ~any(allswift.(swifts{iswift}).surftke(:)<0)
    pcolor(allswift.(swifts{iswift}).time,allswift.(swifts{iswift}).surfz,log10(allswift.(swifts{iswift}).surftke));
    end
    shading flat
    hold on
    title(['SWIFT' SN])
    
end
linkaxes(h,'x');
axes(h(1))
axis tight
ylim([0 20])
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