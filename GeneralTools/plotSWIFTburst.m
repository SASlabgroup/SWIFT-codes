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
halfscreen(1)

for iburst = 1:length(SWIFT)

    burstID = SWIFT(iburst).burstID;

    sigfile = dir([missiondir slash '*' slash 'Raw' slash '*' slash '*SIG*' burstID '.mat']);
    acsfile = dir([missiondir slash '*' slash 'Raw' slash '*' slash '*ACS*' burstID '.mat']);
    pb2file = dir([missiondir slash '*' slash 'Raw' slash '*' slash '*PB2*' burstID '.mat']);
    sbgfile = dir([missiondir slash '*' slash 'Raw' slash '*' slash '*SBG*' burstID '.mat']);
    acofile = dir([missiondir slash '*' slash 'Raw' slash '*' slash '*ACO*' burstID '.mat']);

    % Signature 1000
    if isempty(sigfile)
       disp(['No mat file found for ' burstID '. Skipping.'])
        continue        
    else
        sig = load([sigfile.folder slash sigfile.name]);
    end
    t0 = min(sig.burst.time);
    sig.burst.AngularVelocity = sqrt(sig.burst.AHRS_GyroX.^2 + sig.burst.AHRS_GyroY.^2 + sig.burst.AHRS_GyroZ.^2);
    nping = length(sig.burst.time);
    if nping < 3E3
        sigfs = 4;
        sig.burst.time = t0 + (0:nping-1)*0.25/(60*60*24);
    elseif nping > 3E3
        sigfs = 8;
        sig.burst.time = t0 + (0:nping-1)*0.125/(60*60*24);
    end

    if ~isfield(sig,'echo')
        sig.echo = [];
    end

    % ACS 
     acsfs = 0.5;
    if isempty(acsfile)
       disp(['No ACS file found for ' burstID])
        acs.time = sig.burst.time;
        acs.Temperature = NaN(size(acs.time));
        acs.Salinity = NaN(size(acs.time));
    else
        acs = load([acsfile.folder slash acsfile.name]);
        acs.time = t0 + ((0:length(acs.Temperature)-1)./acsfs)./(60*60*24);
        imin = min([length(acs.time) length(acs.Salinity) length(acs.Temperature)]);
        acs.time = acs.time(1:imin);
        acs.Salinity = acs.Salinity(1:imin);
        acs.Temperature = acs.Temperature(1:imin);
    end

    % ACO
    acofs = 1;
    if isempty(acofile)
        disp(['No ACO file found for ' burstID])
        aco.time = sig.burst.time;
        aco.Temp = NaN(size(aco.time));
        aco.O2Concentration = NaN(size(aco.time));
        iaco = 0;
    else
       aco = load([acofile.folder slash acofile.name]);aco = aco.O2;
       ntaco = length(aco.O2Concentration);
       % aco.time = t0 + ((0:ntaco-1)./acofs)./(60*60*24);
       tf = t0 + 542/(24*60*60); 
       aco.time = linspace(t0,tf,ntaco);

       % timeinterp = t0:1/(acsfs*24*60*60):min([max(acs.time) max(aco.time)]);
       % aco.Tempinterp = interp1(aco.time,aco.Temp,timeinterp);
       % acs.Tempinterp = interp1(acs.time,acs.Temperature,timeinterp);
       % [r,lags] = xcorr(acs.Tempinterp-mean(acs.Tempinterp,'omitnan'),aco.Tempinterp-mean(aco.Tempinterp,'omitnan'));
       % [~,imaxcorr] = max(r);
       % aco_toff = (lags(imaxcorr)./acsfs)./(60*60*24);% days
       % disp(['ACO offset = ' num2str(round(aco_toff*24*60*60)) ' s'])

       % aco_toff = 30/(60*60*24);% days
       % aco.time = aco.time+aco_toff;

       iaco = 1;
    end

    % Airmar
    if isempty(pb2file)
        disp(['No PB2 file found for ' burstID])
        pb2.time = sig.burst.time;
        pb2.rawwindspd = NaN(size(pb2.time));
        pb2.rawwindspdclean = pb2.rawwindspd;
    else
        pb2 = load([pb2file.folder slash pb2file.name]);
        pb2.rawwindspdclean = filloutliers(pb2.rawwindspd,'linear','mean');
        if length(pb2.rawwindspd) ~= length(pb2.time)
            pb2.time = min(pb2.time)+ (0:(length(pb2.rawwindspd)-1))*0.5;
        end
    end

    % SBG Ellipse N(?)
    sbg = load([sbgfile.folder slash sbgfile.name],'sbgData');sbg = sbg.sbgData;
    if isempty(sbg.UtcTime.time_stamp)
        sig.burst.SBG_AngularVelocity = NaN(1,length(sig.burst.time));
        sbg_toff = 0;
    else
    sbgfs = 1./(median(diff(sbg.UtcTime.time_stamp),'omitnan').*10^(-6));
    % Fill outliers in timestamps
    fields = fieldnames(sbg);
    for idf = 1:length(fields)
        vects = fieldnames(sbg.(fields{idf}));
        for ivec = 1:length(vects)
            sbg.(fields{idf}).time_stamp = filloutliers(sbg.(fields{idf}).time_stamp,...
                'linear','movmedian',sbgfs);
        end
    end
    sbg.ImuData.angvel = sqrt(sbg.ImuData.gyro_x.^2 + ...
        sbg.ImuData.gyro_y.^2 + sbg.ImuData.gyro_z.^2).*180/pi;
    igood = sbg.ImuData.angvel < 360;
    sbg.ImuData.angvel = interp1(find(igood),sbg.ImuData.angvel(igood),1:length(sbg.ImuData.angvel));
    [~,iu] = unique(sbg.ImuData.time_stamp);
    sig.burst.SBG_AngularVelocity = interp1(sbg.ImuData.time_stamp(iu)*10^(-6),...
        sbg.ImuData.angvel(iu),(sig.burst.time-t0)*24*60*60,'linear');
    izero = isnan(sig.burst.SBG_AngularVelocity);
    sig.burst.SBG_AngularVelocity(izero) = 0;
    [r,lags] = xcorr(sig.burst.AngularVelocity,sig.burst.SBG_AngularVelocity,'normalized');
    [~,imaxcorr] = max(r);
    sbg_toff = lags(imaxcorr)./sigfs;% seconds
    end

    % Plot
    subplot(6+iaco,1,1)
    plot((pb2.time-t0)*24*60,pb2.rawwindspdclean,'color','r')
    ulim = ylim;
    hold on
    plot((pb2.time-t0)*24*60,pb2.rawwindspd,'color',rgb('grey'))
    ylabel('U [ms^{-1}]')
    axis tight;
    ylim(ulim)
    xlabel('Time [min]')
    set(gca,'XTick',0:8)
    grid on
    title(['SWIFT' SN ' - ' burstID ''],'interpreter','none')

    if iaco > 0
        subplot(6+iaco,1,2)
        plot((aco.time-t0)*24*60,aco.O2Concentration,'color',rgb('mediumseagreen'),'LineWidth',2)
        ylabel('O2 [uM]')
        axis tight;
        xlabel('Time [min]')
        set(gca,'XTick',0:8)
        grid on
    end

    subplot(6+iaco,1,2+iaco)
    yyaxis left
    plot((acs.time-t0)*24*60,acs.Temperature,'color',rgb('cornflowerblue'),'LineWidth',2);
    hold on
    plot((sig.burst.time-t0)*24*60,sig.burst.Temperature,'-b','LineWidth',2)
    plot((aco.time-t0)*24*60,aco.Temp,'-','color',rgb('lightblue'),'LineWidth',2)
    set(gca,'YColor',rgb('blue'));ylabel('T [C]')
    yyaxis right
    plot((acs.time-t0)*24*60,acs.Salinity,'color',rgb('coral'),'LineWidth',2);
    set(gca,'YColor',rgb('coral'));ylabel('S [psu]')
    legend('ACS','SIG','ACO','fontsize',5)
    axis tight
    xlabel('Time [min]')
    set(gca,'XTick',0:8)
    grid on

    subplot(6+iaco,1,3+iaco)
    plot((sig.burst.time-t0)*24*60,sig.burst.AngularVelocity,'-k')
    hold on
    plot((sig.burst.time-t0)*24*60+ sbg_toff/60,sig.burst.SBG_AngularVelocity,'color',rgb('grey'))
    legend('SBG','SIG','fontsize',5)
    axis tight
    xlabel('Time [min]')
    set(gca,'XTick',0:8)
    grid on
   
    if ~isempty(sig.echo)
    subplot(6+iaco,1,[4 5]+iaco) 
    imagesc((sig.echo.time-t0)*24*60,1:size(sig.echo.EchoSounder,2),sig.echo.EchoSounder')
    else
        subplot(6+iaco,1,4+iaco) 
        imagesc((sig.burst.time-t0)*24*60,1:size(sig.burst.AmplitudeData,2),sig.burst.AmplitudeData')
    end
    hold on
    plot(xlim,[64 64],'--k')
    axis tight
    grid on
    c = colorbar('south');
    if ~isempty(sig.echo)
    c.Label.String = 'Echo [dB]';
    else
        c.Label.String = 'Amp [dB]';
        cmocean('thermal')
    end
    c.Position = c.Position.*[1 1 0.25 0.5];
    c.FontSize = 8;

    subplot(6+iaco,1,6+iaco)    
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

