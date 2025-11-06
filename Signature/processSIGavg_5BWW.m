function [profile,fh] = processSIGavg_5BWW(avg) %,opt)

opt.plotburst = false;
opt.slant = 25;

opt.avg.mincorr = 50; 
opt.avg.QCbin = true;
opt.avg.zbin = 0:0.5:50;

%% Data
amp = avg.AmplitudeData;
corr = avg.CorrelationData;
beam = avg.VelocityData;
[nping,nbin,nbeam] = size(beam);
depth = avg.Pressure;
temp = filloutliers(avg.Temperature,'linear');

% Depth bins
bz = avg.Blanking;
dz = avg.CellSize;
r = bz + dz*(1:nbin)';
z = depth' - r;
zlobe = depth.*(1 - cosd(opt.slant));

% Orientation
pitch = avg.Pitch;
roll = avg.Roll;
heading = avg.Heading;

%% Quality Control
ibad = false(size(beam));

% QC: flag corr minimum values
if opt.avg.QCbin
    ibadbin = squeeze(mean(corr,1,'omitnan')) < opt.avg.mincorr;
    ibadbin = repmat(ibadbin,1,1,nping);
    ibadbin = permute(ibadbin,[3 1 2]);
    ibad(ibadbin) = true;
end

% Remove bins above 5 m depth
ibad = ibad | (repmat(z',1,1,nbeam)<= zlobe);

% Apply QC
beamqc = beam;
beamqc(ibad) = NaN;

%% Convert to enu
enu = beam2enu(beamqc, heading, pitch, roll);

%% Plot beam data and QC flags

if opt.plotburst
    clear c
    QCcolor = [rgb('white');rgb('red');rgb('blue')];
    fh(1) = figure('color','w');
    MP = get(0,'monitorposition');
    set(gcf,'outerposition',MP(1,:).*[1 1 1 1]);
    for ibeam = 1:4
        subplot(5,4,ibeam+0*4)
        imagesc(squeeze(amp(:,:,ibeam))')
        clim([50 160]); cmocean('amp')
        title(['Beam ' num2str(ibeam)]);
        if ibeam == 1; ylabel('Bin #'); end
        if ibeam == 4;pos = get(gca,'Position');c(1) = colorbar;set(gca,'Position',pos);end

        subplot(5,4,ibeam+1*4)
        imagesc(squeeze(corr(:,:,ibeam))')
        clim([opt.avg.mincorr-5 100]);  cmocean('amp')
        if ibeam == 1; ylabel('Bin #'); end
        if ibeam == 4;pos = get(gca,'Position');c(2) = colorbar;set(gca,'Position',pos);end
        
        subplot(5,4,ibeam+2*4)
        imagesc(squeeze(beam(:,:,ibeam))')
        clim([-0.5 0.5]);cmocean('balance');
        if ibeam == 1; ylabel('Bin #'); end
        if ibeam == 4;pos = get(gca,'Position');c(3) = colorbar;set(gca,'Position',pos);end

        subplot(5,4,ibeam+3*4)
        imagesc(squeeze(ibad(:,:,ibeam))')
        clim([0 1]);colormap(gca,QCcolor)
        if ibeam == 1; ylabel('Bin #'); end
        if ibeam == 4;pos = get(gca,'Position');c(4) = colorbar;set(gca,'Position',pos);end

        subplot(5,4,ibeam+4*4)
              imagesc(squeeze(enu(:,:,ibeam))')
        clim([-0.5 0.5]);cmocean('balance');
        if ibeam == 1; ylabel('Bin #'); end
        if ibeam == 4;pos = get(gca,'Position');c(5) = colorbar;set(gca,'Position',pos);end

    end
    c(1).Label.String = 'A (dB)';
    c(2).Label.String = 'C (%)';
    c(3).Label.String = 'BEAM (m/s)';
    c(4).Ticks = [0.5 0.75];c(4).TickLabels = {'Good','Bad'};
    c(5).Label.String = 'ENU (m/s)';
    drawnow
    h = findall(gcf,'Type','Axes');
    set(h,'YDir','Normal')
    
else
    fh = [];
end

    %% Compute velocity profiles

    % Compute burst averaged velocity profiles

    zbin = opt.avg.zbin;
    nzbin = length(zbin);
    dz = median(diff(zbin));
    beamavg = NaN(nzbin,nbeam);
    beamvar = beamavg;
    enuavg = NaN(nzbin,nbeam);
    enuvar = enuavg;
    corravg = NaN(nzbin,nbeam);
    corrvar = corravg;
    ampavg = NaN(nzbin,nbeam);
    ampvar = ampavg;
    for ibeam = 1:nbeam

        ibeamqc = squeeze(beamqc(:,:,ibeam));   
        ienu = squeeze(enu(:,:,ibeam));
        icorr = squeeze(corr(:,:,ibeam));
        iamp = squeeze(amp(:,:,ibeam));

    for izbin = 1:nzbin

        i2bin = (z > zbin(izbin)-dz & z <= zbin(izbin)+dz)';

        beamavg(izbin,ibeam) = mean(ibeamqc(i2bin),'omitnan');
        beamvar(izbin,ibeam) = std(ibeamqc(i2bin),[],'omitnan');
        enuavg(izbin,ibeam) = mean(ienu(i2bin),'omitnan');
        enuvar(izbin,ibeam) = std(ienu(i2bin),[],'omitnan');
        corravg(izbin,ibeam) = mean(icorr(i2bin),'omitnan');
        corrvar(izbin,ibeam) = std(icorr(i2bin),[],'omitnan');
        ampavg(izbin,ibeam) = mean(iamp(i2bin),'omitnan');
        ampvar(izbin,ibeam) = std(iamp(i2bin),[],'omitnan');

    end
    end

    % Temperature
    tempavg = NaN(nzbin,1);
    tempvar = NaN(nzbin,1);
    for izbin = 1:nzbin
        i2bin = depth > zbin(izbin)-dz & depth <= zbin(izbin)+dz;
        tempavg(izbin) = mean(temp(i2bin),'omitnan');
        tempvar(izbin) = std(temp(i2bin),[],'omitnan');
    end


    %%
    % Main results
    profile.z = opt.avg.zbin;
    profile.w = enuavg(:,3);
    profile.v = enuavg(:,2);
    profile.u = enuavg(:,1);
    profile.wvar = enuvar(:,3);
    profile.vvar = enuvar(:,2);
    profile.uvar = enuvar(:,1);
    profile.temp = tempavg;
    profile.tempvar = tempvar;

    % Extra for QC
    profile.QC.w2 = enuavg(:,4);
    profile.QC.wvar2 = enuvar(:,4);
    profile.QC.beamavg = beamavg;
    profile.QC.beamvar = beamvar;
    profile.QC.corr = corravg;
    profile.QC.corrvar = corrvar;
    profile.QC.amp = ampavg;
    profile.QC.ampvar = ampvar;

    
end

