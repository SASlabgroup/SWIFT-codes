function plotSWIFTburst(missiondir,savedir)

% Plots burst data from ACS, PB2, and SIG
% Use L1 product to get burstIDs
% K. Zeiden 

% ACS sample rate = 0.5 Hz
% SIG sample rate = 4 Hz
% SBG sample rate = 5 Hz
% PB2 sample rate = 2 Hz


if ispc
    slash = '\';
else
    slash = '/';
end

%% Load L1file

L1file = dir([missiondir slash '*L1.mat']);

if isempty(L1file)
    disp(['No L1 product found for ' sname '.'])
    return
else
    load([L1file.folder slash L1file.name],'SWIFT');
end

SN = SWIFT(1).ID;

%%
% v = VideoWriter('echomovie.mp4', 'MPEG-4');
% v.FrameRate = 1; 
% open(v);

f = figure('color','w');
halfscreen(2)

for iburst = 1:length(SWIFT)

    burstID = SWIFT(iburst).burstID;

    sigfile = dir([missiondir slash '*' slash 'Raw' slash '*' slash '*SIG*' burstID '.mat']);
    acsfile = dir([missiondir slash '*' slash 'Raw' slash '*' slash '*ACS*' burstID '.mat']);
    sbgfile = dir([missiondir slash '*' slash 'Raw' slash '*' slash '*SBG*' burstID '.mat']);
    pb2file = dir([missiondir slash '*' slash 'Raw' slash '*' slash '*PB2*' burstID '.mat']);

    if isempty(sigfile)
       disp(['No mat file found for ' burstID])
        continue
    end

    acs = load([acsfile.folder slash acsfile.name]);
    sig = load([sigfile.folder slash sigfile.name]);
    sbg = load([sbgfile.folder slash sbgfile.name]); sbg = sbg.sbgData;
    pb2 = load([pb2file.folder slash pb2file.name]);

    t0 = sig.burst.time(1);
    acs.time = t0 + ((0:length(acs.Temperature)-1)./0.5)./(60*60*24);
    pb2.time = t0 + ((0:length(pb2.rawwindspd)-1)./2)./(60*60*24);

    subplot(5,1,1)
    plot((pb2.time-t0)*24*60,pb2.rawwindspd,'color','k','LineWidth',2)
    ylabel('U [ms^{-1}]')
    axis tight
    xlabel('Time [min]')
    set(gca,'XTick',0:8)
    grid on
    title(['SWIFT' SN ' - ' burstID ''],'interpreter','none')

    subplot(4,1,1)
    yyaxis left
    plot((acs.time-t0)*24*60,acs.Temperature,'color',rgb('cornflowerblue'),'LineWidth',2);
    hold on
    plot((sig.burst.time-t0)*24*60,sig.burst.Temperature,'-b','LineWidth',2)
    set(gca,'YColor',rgb('blue'));ylabel('T [C]')
    yyaxis right
    plot((acs.time-t0)*24*60,acs.Salinity,'color',rgb('coral'));
    set(gca,'YColor',rgb('coral'));ylabel('S [psu]')
    legend('ACS','SIG')
    axis tight
    xlabel('Time [min]')
    set(gca,'XTick',0:8)
    grid on
    title(['SWIFT' SN ' - ' burstID ''],'interpreter','none')

    subplot(4,1,[2 3])    
    imagesc((sig.echo.time-t0)*24*60,1:size(sig.echo.EchoSounder,2),sig.echo.EchoSounder')
    hold on
    plot(xlim,[64 64],'--k')
    axis tight
    grid on
    c = colorbar('south');
    c.Label.String = 'Echo [dB]';
    c.Position = c.Position.*[1 1 0.25 0.5];
    c.FontSize = 8;

    subplot(4,1,4)    
    imagesc((sig.burst.time-t0)*24*60,1:size(sig.burst.VelocityData,2),sig.burst.VelocityData')
    clim([-0.5 0.5])
    cmocean('balance')
    axis tight
    xlabel('Time [min]')
    grid on
    c = colorbar('south');
    c.Label.String = 'W [ms^{-1}]';
    c.Position = c.Position.*[1 1 0.25 0.5];
    c.FontSize = 8;

    h = findall(gcf,'Type','Axes');
    linkaxes(h,'x')
    axis tight

    % pause(0.1) 
    % frame = getframe(gcf);
    % writeVideo(v, frame);
    print([savedir slash 'SWIFT' SN '_' burstID],'-dpng')

    clf

end

% close(v);
close(f)

