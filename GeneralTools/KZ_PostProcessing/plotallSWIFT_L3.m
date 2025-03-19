function allswift = plotallSWIFT_L3(expdir)
% plotallmisisons: Overview plot of L3 processed data from all missions in
% an experiment directory. fh1 figure plots data, fh2 plots trajectories.

% K. Zeiden March 2025

if ispc
    slash = '\';
else
    slash = '/';
end

missions = dir([expdir slash 'SWIFT*']);

allswift = struct;

for im = 1:length(missions)

    L3file = dir([missions(im).folder slash missions(im).name slash '*L3.mat']);

    ID = missions(im).name(6:7);
    sdate = datestr(datenum(missions(im).name(9:17),'ddmmmyyyy'),'mmdd');

    sname = ['SN' ID '_' sdate];

    if isempty(L3file)
        disp(['No L3 product found in ' missions(im).name '. Skipping...'])
    else
        disp(['Loading ' missions(im).name ' L3 product...'])
        load([L3file.folder slash L3file.name],'SWIFT');
        swift = catSWIFT(SWIFT);
        allswift.(sname) = swift;
    end

end

%% Plotting
MP = get(0,'monitorposition');
mks = 2;
swifts = fieldnames(allswift);
nswift = length(swifts);
cswift = jet(nswift);

% Anemometer
fh1 = figure('color','w','Name',[expdir  ' SWIFT Anemometer']);
set(fh1,'outerposition',MP(1,:));
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
subplot(4,1,1);title('Wind Speed');ylabel('U [ms^{-1}]');axis tight;datetick('x','KeepLimits')
subplot(4,1,2);title('Air Temperature');ylabel('T [C^{\circ}]');axis tight;datetick('x','KeepLimits')
subplot(4,1,3);title('Air Pressure');ylabel('P [dB]');axis tight;datetick('x','KeepLimits')
subplot(4,1,4);title('Humidity');ylabel('Rh [%]');axis tight;datetick('x','KeepLimits')
h1 = findall(fh1,'Type','axes');
linkaxes(h1,'x');
subplot(4,1,1)
axP = get(gca,'Position');
legend(swifts','Interpreter','none','FontSize',8,'Location','EastOutside')
set(gca, 'Position', axP);

% Waves & CT
fh2 = figure('color','w','Name',[expdir  ' SWIFT Waves + CT']);
set(fh2,'outerposition',MP(1,:));
for iswift = 1:nswift
    subplot(4,1,1);
    plot(allswift.(swifts{iswift}).time,allswift.(swifts{iswift}).tsea,'-o','color',rgb('grey'),...
        'MarkerEdgeColor',cswift(iswift,:),'MarkerFaceColor',cswift(iswift,:),'MarkerSize',mks)
    hold on
    subplot(4,1,2);
    plot(allswift.(swifts{iswift}).time,allswift.(swifts{iswift}).sal,'-o','color',rgb('grey'),...
        'MarkerEdgeColor',cswift(iswift,:),'MarkerFaceColor',cswift(iswift,:),'MarkerSize',mks)
    hold on
    subplot(4,1,3);
    plot(allswift.(swifts{iswift}).time,allswift.(swifts{iswift}).wavesigH,'-o','color',rgb('grey'),...
        'MarkerEdgeColor',cswift(iswift,:),'MarkerFaceColor',cswift(iswift,:),'MarkerSize',mks)
    hold on
    subplot(4,1,4);
    plot(allswift.(swifts{iswift}).time,allswift.(swifts{iswift}).wavepeakT,'-o','color',rgb('grey'),...
        'MarkerEdgeColor',cswift(iswift,:),'MarkerFaceColor',cswift(iswift,:),'MarkerSize',mks)
    hold on
end
subplot(4,1,1);title('Sea Temperature');ylabel('T [C^{\circ}]');axis tight;datetick('x','KeepLimits')
subplot(4,1,2);title('Salinity');ylabel('S [psu]');axis tight;datetick('x','KeepLimits')
subplot(4,1,3);title('Significant Wave Height');ylabel('H_s [m]');axis tight;datetick('x','KeepLimits')
subplot(4,1,4);title('Peak Wave Period');ylabel('T_p [s]');axis tight;datetick('x','KeepLimits')
h2 = findall(fh2,'Type','axes');
linkaxes(h2,'x');
axP = get(gca,'Position');
legend(swifts','Interpreter','none','FontSize',8,'Location','EastOutside')
set(gca, 'Position', axP);

% ADCP
fh3 = figure('color','w','Name',[expdir  ' SWIFT ADCP']);
set(fh3,'outerposition',MP(1,:));
for iswift = 1:nswift

    subplot(4,1,1);
    plot(allswift.(swifts{iswift}).time,allswift.(swifts{iswift}).windu,'-o','color',rgb('grey'),...
        'MarkerEdgeColor',cswift(iswift,:),'MarkerFaceColor',cswift(iswift,:),'MarkerSize',mks)
    hold on

    subplot(4,1,2);
    plot(allswift.(swifts{iswift}).time,allswift.(swifts{iswift}).driftu,'-o','color',rgb('grey'),...
        'MarkerEdgeColor',cswift(iswift,:),'MarkerFaceColor',cswift(iswift,:),'MarkerSize',mks)
    hold on

    subplot(4,1,3);
    zavg = allswift.(swifts{iswift}).depth < 5 & allswift.(swifts{iswift}).depth > 1;
    plot(allswift.(swifts{iswift}).time,mean(allswift.(swifts{iswift}).relu(zavg,:),1,'omitnan'),...
    '-o','color',rgb('grey'),...
        'MarkerEdgeColor',cswift(iswift,:),'MarkerFaceColor',cswift(iswift,:),'MarkerSize',mks)
    hold on

    subplot(4,1,4);
    zavg = allswift.(swifts{iswift}).surfz < 2 & allswift.(swifts{iswift}).surfz > 1;
    plot(allswift.(swifts{iswift}).time,mean(log10(allswift.(swifts{iswift}).surftke(zavg,:)),1,'omitnan'),...
        '-o','color',rgb('grey'),...
        'MarkerEdgeColor',cswift(iswift,:),'MarkerFaceColor',cswift(iswift,:),'MarkerSize',mks)
    hold on
    subplot(4,1,4);

end
subplot(4,1,1);title('Wind Speed');ylabel('U [ms^{-1}]');axis tight;datetick('x','KeepLimits')
subplot(4,1,2);title('Drift Speed');ylabel('U [ms^{-1}]');axis tight;datetick('x','KeepLimits')
subplot(4,1,3);title('Relative Velocity (1-5 m)');ylabel('U [ms^{-1}]');axis tight;...
    datetick('x','KeepLimits')
subplot(4,1,4);title('Dissipation (1-2 m)');ylabel('\epsilon [m^2s^{-2}]');axis tight;...
    datetick('x','KeepLimits')
h3 = findall(fh3,'Type','axes');
linkaxes(h3,'x');
subplot(4,1,1);
axP = get(gca,'Position');
legend(swifts','Interpreter','none','FontSize',8,'Location','EastOutside')
set(gca, 'Position', axP);

% Trajectories
figure('color','w','Name',[expdir   ' SWIFT Location']);
for iswift = 1:nswift
    scatter(allswift.(swifts{iswift}).lon,allswift.(swifts{iswift}).lat,'filled','MarkerFaceColor',cswift(iswift,:))
    hold on
end
axis equal tight
axP = get(gca,'Position');
legend(swifts','Interpreter','none','FontSize',8,'Location','EastOutside')
set(gca, 'Position', axP);

end