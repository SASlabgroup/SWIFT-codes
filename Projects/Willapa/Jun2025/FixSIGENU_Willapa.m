% Fix Signature ENU data on Willapa SWIFTs

if ispc
    slash = '\';
else
    slash = '/';
end

expdir = 'S:\Willapa\Jun2025\MooredSWIFTS';
% expdir = '/Volumes/Data/Willapa/Jun2025/MooredSWIFTs';

missions = dir([expdir slash 'SWIFT2*']);
missions = missions([missions.isdir]);

load('S:\SEAFAC\June2024\SIGopt_SEAFAC','sigopt');
sigopt.plotburst = true;

%% Loop through V3 missions and cut together IMU and GPS waves

for im = 1

missiondir = [missions(im).folder slash missions(im).name];

% L4 file
L4file = dir([missiondir slash '*L4.mat']);
if isempty(L4file)
    continue
end
load([L4file.folder slash L4file.name]);

% Loop through bursts and recalculate 
toff = NaN(length(SWIFT),1);
tlag = NaN(length(SWIFT),1);
hoff = NaN(length(SWIFT),1);
mheading = NaN(length(SWIFT),1);
mpitch = NaN(length(SWIFT),1);
mroll = NaN(length(SWIFT),1);

for iburst = 318:length(SWIFT)

    burstID = SWIFT(iburst).burstID;

    disp(['Processing burst ' burstID])

    sigfile = dir([missiondir slash 'SIG' slash 'Raw' slash '*' slash '*SIG*' burstID '*.mat']);
    sbgfile = dir([missiondir slash '*' slash 'Raw' slash '*' slash '*SBG*' burstID '*.mat']);

    if isempty(sigfile) || isempty(sbgfile)
        if isempty(sigfile)
        disp('SIG file is empty')
        elseif isempty(sbgfile)
            disp('SBG file is empty')
        end
        profile = SWIFT(iburst).signature.profile;
        SWIFT(iburst).signature.profile.east = NaN(size(profile.w));
        SWIFT(iburst).signature.profile.north = NaN(size(profile.w));
        SWIFT(iburst).signature.profile.w = NaN(size(profile.w));
        SWIFT(iburst).signature.profile.uvar = NaN(size(profile.w));
        SWIFT(iburst).signature.profile.vvar = NaN(size(profile.w));
        SWIFT(iburst).signature.profile.wvar = NaN(size(profile.w));
        SWIFT(iburst).signature.profile.z = profile.z;
        SWIFT(iburst).signature.profile.spd_alt = NaN(size(profile.w));
        continue
    end

    load([sigfile.folder slash sigfile.name],'avg','burst');
    load([sbgfile.folder slash sbgfile.name],'sbgData');

     if range(burst.time)*24*60 < 4.25
        disp('Burst too short.')
        profile = SWIFT(iburst).signature.profile;
        SWIFT(iburst).signature.profile.east = NaN(size(profile.w));
        SWIFT(iburst).signature.profile.north = NaN(size(profile.w));
        SWIFT(iburst).signature.profile.w = NaN(size(profile.w));
        SWIFT(iburst).signature.profile.uvar = NaN(size(profile.w));
        SWIFT(iburst).signature.profile.vvar = NaN(size(profile.w));
        SWIFT(iburst).signature.profile.wvar = NaN(size(profile.w));
        SWIFT(iburst).signature.profile.z = profile.z;
        SWIFT(iburst).signature.profile.spd_alt = NaN(size(profile.w));
        continue
     end

     if length(sbgData.EkfEuler.yaw)<10
         disp('SBG timeseries too short.')
                 profile = SWIFT(iburst).signature.profile;
        SWIFT(iburst).signature.profile.east = NaN(size(profile.w));
        SWIFT(iburst).signature.profile.north = NaN(size(profile.w));
        SWIFT(iburst).signature.profile.w = NaN(size(profile.w));
        SWIFT(iburst).signature.profile.uvar = NaN(size(profile.w));
        SWIFT(iburst).signature.profile.vvar = NaN(size(profile.w));
        SWIFT(iburst).signature.profile.wvar = NaN(size(profile.w));
        SWIFT(iburst).signature.profile.z = profile.z;
        SWIFT(iburst).signature.profile.spd_alt = NaN(size(profile.w));
        continue
     end

    bname = sigfile.name(1:end-4);

    % Recalculate ENU using SBG HPR
    hoffgiven = 0;
    [avgout, cparams, fh] = fixSIGenu(avg, burst, sbgData, 0 ...
        );
    if isempty(avgout)
        profile = SWIFT(iburst).signature.profile;
        SWIFT(iburst).signature.profile.east = NaN(size(profile.w));
        SWIFT(iburst).signature.profile.north = NaN(size(profile.w));
        SWIFT(iburst).signature.profile.w = NaN(size(profile.w));
        SWIFT(iburst).signature.profile.uvar = NaN(size(profile.w));
        SWIFT(iburst).signature.profile.vvar = NaN(size(profile.w));
        SWIFT(iburst).signature.profile.wvar = NaN(size(profile.w));
        SWIFT(iburst).signature.profile.z = profile.z;
        SWIFT(iburst).signature.profile.spd_alt = NaN(size(profile.w));
        continue
    end

    figure(fh)
    set(gcf,'Name',[bname '_HPR_sbgfix'])
    figname = [sigfile.folder slash get(gcf,'Name')];
    print(figname,'-dpng')
    close gcf

    % Reprocess avg data
    [profile,fh] = processSIGavg(avgout,sigopt);
    figure(fh)
    set(gcf,'Name',[bname '_bband_data_sbgfix'])
    figname = [sigfile.folder slash get(gcf,'Name')];
    print(figname,'-dpng')
    close gcf

    % Recalculate alt spd from sbg mean heading
    [enu_alt,profile.spd_alt,~] = altSIGenu(avgout,cparams.mheading);

    % Save in SWIFT structure
    SWIFT(iburst).signature.profile = [];
    SWIFT(iburst).signature.profile.east = profile.u;
    SWIFT(iburst).signature.profile.north = profile.v;
    SWIFT(iburst).signature.profile.w = profile.w;
    SWIFT(iburst).signature.profile.uvar = profile.uvar;
    SWIFT(iburst).signature.profile.vvar = profile.vvar;
    SWIFT(iburst).signature.profile.wvar = profile.wvar;
    SWIFT(iburst).signature.profile.z = profile.z;
    SWIFT(iburst).signature.profile.spd_alt = profile.spd_alt;

    toff(iburst) = cparams.toff;
    tlag(iburst) = cparams.tlag;
    hoff(iburst) = cparams.hoff;
    mheading(iburst) = cparams.mheading;
    mpitch(iburst) = cparams.mpitch;
    mroll(iburst) = cparams.mroll;

end


if isfield(sinfo,'postproc')
ip = length(sinfo.postproc)+1; 
else
    sinfo.postproc = struct;
    ip = 1;
end
sinfo.postproc(ip).type = 'fix_enu';
sinfo.postproc(ip).usr = getenv('username');
sinfo.postproc(ip).time = string(datetime('now'));
sinfo.postproc(ip).flags = [];
sinfo.postproc(ip).params.toff = toff;
sinfo.postproc(ip).params.tlag = tlag;
sinfo.postproc(ip).params.hoff = hoff;
sinfo.postproc(ip).params.mheading = mheading;
sinfo.postproc(ip).params.mpitch = mpitch;
sinfo.postproc(ip).params.mroll = mroll;

save([L4file.folder slash missions(im).name '_L5'],'SWIFT','sinfo');

end

%% Re-load and plot each mission

for im = 2

    missiondir = [missions(im).folder slash missions(im).name];

    % L5 file
    L5file = dir([missiondir slash '*L5.mat']);
    if isempty(L5file)
        continue
    end
    load([L5file.folder slash L5file.name],'SWIFT','sinfo')
    swiftL5 = catSWIFT(SWIFT);
    % L4 file
    L4file = dir([missiondir slash '*L4.mat']);
    if isempty(L4file)
        continue
    end
    load([L4file.folder slash L4file.name],'SWIFT')
    swiftL4 = catSWIFT(SWIFT);
        % L3 file
    L3file = dir([missiondir slash '*L3.mat']);
    if isempty(L3file)
        continue
    end
    load([L3file.folder slash L3file.name],'SWIFT')
    swiftL3 = catSWIFT(SWIFT);
    
    % Pick a velocity
    swiftL5.u = swiftL5.relu;
    swiftL5.v = swiftL5.relv;
    
    % Actual True Shear
    swiftL5.shearv = gradient(swiftL5.u')'./gradient(swiftL5.depth');
    swiftL5.shearu = gradient(swiftL5.u')'./gradient(swiftL5.depth');
    swiftL5.shear = sqrt(swiftL5.shearu.^2 + swiftL5.shearv.^2);
    
    % Speed Shear
    swiftL5.spd = sqrt(swiftL5.u.^2 + swiftL5.u.^2);
    swiftL5.spdshear = gradient(swiftL5.spd')'./gradient(swiftL5.depth');% confirmed this is very close to the true shear
    
    % Alternative Speed shear
    swiftL5.spdshear_alt = gradient(swiftL5.spd_alt')'./gradient(swiftL5.depth');

   % Compare SWIFT heading w/SBG
   lat0 = mean(swiftL5.lat,'omitnan');
   lon0 = mean(swiftL5.lon,'omitnan');
   dx = (swiftL5.lon - lon0) .* cosd(lat0);  % scale lon by cos(lat)
   dy = swiftL5.lat - lat0;
   hdg = atan2d(dx, dy);   % note: atan2d(x,y) not (y,x) for N-up

    figure;plot(swiftL5.time,hdg,'-kx')
    hold on
    plot(swiftL5.time,sinfo.postproc(end).params.mheading,'-rx')
    axis tight
    datetick('x','KeepLimits')
    legend('Buoy Lat-Lon Hdg','SBG Yaw')


   % Compare L4 and L5
    figure('color','w')
    fullscreen

    subplot(5,1,1)
    plot(swiftL5.time,sinfo.postproc(end).params.mheading,'-rx')
    ylim([-180 180]);
    title([missions(im).name ' SBG Mean Heading'],'interpreter','none')
    ylabel('[^{\circ}N]')

    subplot(5,1,2)
    pcolor(swiftL3.time,swiftL3.depth,swiftL3.relu);shading flat
    clim([-1 1]);title('Original East Velocity')
    cmocean('balance')
    ylabel('Z [m]')
    c = slimcolorbar;
    c.Label.String = 'U [ms^{-1}]';

    subplot(5,1,3)
    pcolor(swiftL4.time,swiftL3.depth,swiftL4.spd_alt);shading flat
    clim([0 1]);title('Original Burst-Avg Speed')
    ylabel('Z [m]')
    c = slimcolorbar;
    c.Label.String = '|U| [ms^{-1}]';

    subplot(5,1,4)
    pcolor(swiftL5.time,swiftL3.depth,swiftL5.relu);shading flat
    clim([-1 1]);title('Fixed East Velocity')
    cmocean('balance')
    ylabel('Z [m]')
    c = slimcolorbar;
    c.Label.String = 'U [ms^{-1}]';

    subplot(5,1,5)
    pcolor(swiftL5.time,swiftL3.depth,swiftL5.spd_alt);shading flat
    clim([0 1]);title('Fixed Burst-Avg Speed')
    ylabel('Z [m]')
    c = slimcolorbar;
    c.Label.String = '|U| [ms^{-1}]';

    h = findall(gcf,'Type','Axes');set(h(1:end-1),'YDir','Reverse')
    set(h(2:end),'XTickLabel',[])
    linkaxes(h,'x');axis tight
    axes(h(1));datetick('x','mm/dd','KeepLimits')
    
    
    % Compare types of shear
    figure('color','w','Name',[L5file.name(1:7) ' ' datestr(min(swiftL5.time),'mmm dd, yyyy')])
    h = tight_subplot(3,1,0.05);

    axes(h(1))
    pcolor(swiftL5.shear);shading flat
    colorbar;cmocean('balance');title('Current Shear');

    axes(h(2))
    pcolor(swiftL5.spdshear);shading flat
    colorbar;cmocean('balance');title('Speed Shear');
    
    axes(h(3))
    pcolor(swiftL5.spdshear_alt);shading flat
    colorbar;cmocean('balance');title('Bavg-Speed Shear')
    
    set(h,'YDir','Reverse')
    linkaxes(h);
    set(h(1:2),'CLim',[-0.1 0.1]);
    set(h(3:4),'CLim',[0 0.01])

end


