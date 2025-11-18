<<<<<<< Updated upstream
function [HRprofile,fh] = processSIGburst_5BWW(burst,varargin)
=======
function [HRprofile,fh1,fh2] = processSIGburst_5BWW(burst,varargin)
>>>>>>> Stashed changes
% Adapted processSIGburst to estimate structure function dissipation
% averaged across all 5 beams sampling HR data on Sig1000 mounted on a
% WireWalker.
% K. Zeiden 10/2025

<<<<<<< Updated upstream
%% Development

% Use burst around Jun 23, 21:00:00 UTC
% load('S:\SEAFAC\June2024\SouthMooring\Sig1000\S100595A054_SEAFAC_WW\SIG\Raw\20240623\SWIFT20_SIG_23Jun2024_20_55.mat','burst');
% 
% % Isolate ascent profile
% time = burst.time';
% z = burst.Pressure';
% dt = round(median(diff(time)*24*60*60),2);
% wrise = gradient(z)./dt;
% irise = smooth_vec(wrise,hann(10/dt)) <= -0.1 ;
% irise = find(irise,1,'first'):find(irise,1,'last');
% bfields = fieldnames(burst);
% nping = length(time);
% for ifield = 1:length(bfields)
%     var = burst.(bfields{ifield});
%     if any(size(var)==nping) && ismatrix(var)
%         var = var(irise,:);
%     elseif any(size(var) == nping) && ndims(var) == 3
%         var = var(irise,:,:);
%     end
%     burst.(bfields{ifield}) = var;
% end
% 
% clearvars -except burst

%%
% if nargin < 2
    opt.plotburst = false; % generate plots for each burst
=======
if nargin < 2
    opt.plotburst = true; % generate plots for each burst
>>>>>>> Stashed changes
    opt.HR.mincorr = 40;% To ignore correlation, set to 0;
    opt.HR.QCbin = true;% QC entire bins with greater than opt.HR.pbadmax_bin perecent bad data (spikes & correlation)
    opt.HR.pbadmax_bin = 50;
    opt.HR.QCping = true;% QC entire bins with greater than opt.HR.pbadmax_ping perecent bad data (spikes & correlation)
    opt.HR.pbadmax_ping = 50;
    opt.HR.NaNbad = true;% NaN out bad data. Otherwise they are interpolated through.
    opt.HR.nsumeof = 3;
<<<<<<< Updated upstream
    opt.HR.eoftype = '5beam';
    opt.HR.binavgSF = true;
% else
%     opt = varargin{1};
% end

%% Data
time = burst.time;
depth = burst.Pressure;
dt = round(median(diff(time)*24*60*60),2);
wrise = gradient(depth)./dt;

% velocities
wraw = burst.VelocityData;
for ibeam = 1:4
    wraw(:,:,ibeam) = wraw(:,:,ibeam)-wrise*cosd(25);
end
wraw(:,:,5) = wraw(:,:,5)-wrise;

% correlation + amplitude
hramp = burst.AmplitudeData;
hrcorr = burst.CorrelationData;

% orientation
pitch = burst.Pitch;
roll = burst.Roll;
heading = burst.Heading;

% velocity range
[nping,nbin,nbeam] = size(wraw);
dz = burst.CellSize;
bz = burst.Blanking;
L = bz+dz*nbin; % m, pulse distance
F0 = 10^6; % Hz, pulse carrier frequency (1 MHz for Sig 1000)
cs = mean(burst.SoundSpeed,'omitnan'); % m/s, sound speed
Vr = cs.^2./(4*F0*L);% m/s
nfilt = round(1/dz);% 1 m

% depth bins
z = NaN(size(wraw));
r = bz + dz*(1:nbin);
z(:,:,5) = depth - r;
for ibeam = 1:4
 z(:,:,ibeam) = depth - r*cosd(25);
end

%% Quality Control 
 
% Identify Spikes (phase-shift threshold, Shcherbina 2018)
ispike = false(size(wraw));
for ibeam = 1:nbeam
    [~,ispikeibeam] = despikeSIG(squeeze(wraw(:,:,ibeam))',nfilt,Vr/2);
    ispike(:,:,ibeam) = ispikeibeam';
end
=======
else
    opt = varargin{1};
end

%% Isolate ascent profile
time = burst.time';
z0 = burst.Pressure';
dt = round(median(diff(time)*24*60*60),2);
wrise = gradient(z0)./dt;
irise = smooth_vec(wrise,hann(10/dt)) <= -0.1 ;
irise = find(irise,1,'first'):find(irise,1,'last');
time = time(irise);
wrise = wrise(irise);
z0 = z0(irise);

for ibeam = 1:5

hrcorr = squeeze(burst.CorrelationData(irise,:,ibeam))';
hramp = squeeze(burst.AmplitudeData(irise,:,ibeam))';
if ibeam == 5
wraw = squeeze(burst.VelocityData(irise,:,ibeam))' - wrise;
else
    wraw = squeeze(burst.VelocityData(irise,:,ibeam))'-cosd(25)*wrise;
end

% orientation
pitch = burst.Pitch(irise);
roll = burst.Roll(irise);
heading = burst.Heading(irise);

% bin depths matrix, profile depth vector (mid-beam, each ping)
[nbin,nping] = size(wraw);
dz = burst.CellSize;
bz = burst.Blanking;
if ibeam == 5
zbins = z0 - (bz + dz*(1:nbin)');
else
 zbins = z0 - (bz+dz*(1:nbin)')*cosd(25);
end
zprofile = mean(zbins);

% Velocity Range
L = bz+dz*nbin; % m, pulse distance
F0 = 10^6; % Hz, pulse carrier frequency (1 MHz for Sig 1000)
cs = mean(burst.SoundSpeed(irise),'omitnan'); % m/s, sound speed
Vr = cs.^2./(4*F0*L);% m/s
nfilt = round(1/dz);% 1 m

%% QC Veloctiy Data %%%%%%%

% Identify Spikes (phase-shift threshold, Shcherbina 2018)
[~,ispike] = despikeSIG(wraw,nfilt,Vr/2);
>>>>>>> Stashed changes

% Identify poor quality (low correlation) data
ipoor = hrcorr < opt.HR.mincorr;

% Identify near-surface data
zmin = 5;
<<<<<<< Updated upstream
isurf = z < zmin;

% All bad points
ibad = isurf | ipoor | ispike;
    
% Identify entire bad bins (percentage of bad data > opt.pbadmax_bin)
pbad_bin = 100*(sum(ibad,1,'omitnan')./nping);
ibadbin = pbad_bin > opt.HR.pbadmax_bin;
if opt.HR.QCbin
    ibad = ibad | repmat(ibadbin,nping,1,1);
=======
isurf = zbins < zmin;

% All bad points
ibad = isurf | ipoor | ispike;

% Identify entire bad bins (percentage of bad data > opt.pbadmax_bin)
pbad_bin = 100*(sum(ibad,2,'omitnan')./nping);
ibadbin = pbad_bin > opt.HR.pbadmax_bin;
if opt.HR.QCbin
    ibad = ibad | repmat(ibadbin,1,nping);
>>>>>>> Stashed changes
end

% Identify entire bad pings (percentage of bad data > opt.pbadmax_ping, not
% including bad bins removed in previous step)
<<<<<<< Updated upstream
ibadbin = squeeze(ibadbin);
pbad_ping = NaN(nping,1,nbeam);
if opt.HR.QCbin
    for ibeam = 1:nbeam
    pbad_ping(:,:,ibeam) = 100*sum(ibad(:,~ibadbin(:,ibeam),ibeam),2,'omitnan')./sum(~ibadbin(:,ibeam)); 
    end
else
    pbad_ping = 100*sum(ibad,2,'omitnan')./nbin;
end
ibadping = pbad_ping > opt.HR.pbadmax_ping;
if opt.HR.QCping
    ibad = ibad | repmat(ibadping,1,nbin,1);
=======
if opt.HR.QCbin
pbad_ping = 100*sum(ibad(~ibadbin,:))./sum(~ibadbin); 
else
    pbad_ping = 100*sum(ibad,'omitnan')./nbin;
end
ibadping = pbad_ping > opt.HR.pbadmax_ping;
if opt.HR.QCping
    ibad = ibad | repmat(ibadping,nbin,1);
>>>>>>> Stashed changes
end

% Remove bad data
wclean = wraw;wclean(ibad) = NaN;

<<<<<<< Updated upstream
%% Re-compute ENU velocities from clean data

% Interpolate through NaN
winterp = NaN(size(wclean));
for ibeam = 1:nbeam
    for iping = 1:nping
        wi = wclean(iping,:,ibeam);
        if sum(~isnan(wi))>3
        winterp(iping,:,ibeam) = interp1(find(~isnan(wi)),wi(~isnan(wi)),1:nbin);
        end
    end
end
[enuclean] = beam2enu(winterp(:,:,1:4), heading, pitch, roll);

%% High-pass data using EOFs
% Note: interpolates through NaN data first

if strcmp(opt.HR.eoftype,'single')% Single beam EOFs

    neoflp = opt.HR.nsumeof;
    eofs = NaN(nbin,nbin,nbeam);
    eofamp = NaN(nping,nbin,nbeam);
    eofvar = NaN(nbin,nbeam);
    wpeof = NaN(nping,nbin,nbeam);
    for ibeam = 1:nbeam
    [ieofs,ieofamp,ieofvar,~] = eof(squeeze(wclean(:,:,ibeam)));
    iwpeof = ieofs(:,neoflp+1:end,:)*(ieofamp(:,neoflp+1:end,:)');
    wpeof(:,:,ibeam) = iwpeof';
    eofs(:,:,ibeam) = ieofs;
    eofamp(:,:,ibeam) = ieofamp;
    eofvar(:,ibeam) = ieofvar;
    end

    elseif strcmp(opt.HR.eoftype,'4beam')% 4-beam EOF
        
        % 4-beam EOFs
        neoflp = opt.HR.nsumeof*4;
        [eofs,eofamp,eofvar,~] = eof(reshape(wclean(:,:,1:4),nping,nbin*4));
        wpeof = eofs(:,neoflp+1:end,:)*(eofamp(:,neoflp+1:end,:)');
        wpeof = reshape(wpeof',nping,nbin,4);

        % 5th beam EOF
        [eofs5,eofamp5,eofvar5,~] = eof(squeeze(wclean(:,:,5)));
        wpeof5 = eofs5(:,neoflp+1:end,:)*(eofamp5(:,neoflp+1:end,:)');
        eofs = [eofs; [eofs5 NaN(nbin,nbin*3)]];
        eofamp = [eofamp eofamp5];
        eofvar = [eofvar eofvar5];   
        wpeof(:,:,5) = wpeof5';
    
    elseif strcmp(opt.HR.eoftype,'5beam')% 5-beam EOF
    
    % 5-beam EOFs
    neoflp = opt.HR.nsumeof*nbeam;
    [eofs,eofamp,eofvar,~] = eof(reshape(wclean,nping,nbin*nbeam));
    wpeof = eofs(:,neoflp+1:end,:)*(eofamp(:,neoflp+1:end,:)');
    wpeof = reshape(wpeof',nping,nbin,nbeam);

end

% Remove bad data
wpeof(ibad) = NaN;% this is pretty critical, lots of spikes

%% Dissipation Rate 
Cv2 = 2.1;
dzbin = 0.5;
zbin = (0:dzbin:50)';

[nzbin,~] = size(zbin);
slope = NaN(nzbin,nbeam);
int = NaN(nzbin,nbeam);
A = NaN(nzbin,nbeam);
N = NaN(nzbin,nbeam);
eps = NaN(nzbin,nbeam);
ndat = NaN(nzbin,nbeam);
nfit = NaN(nzbin,nbeam);

warning('off','all')

% Integrate over depth bins
for ibeam = 1:nbeam

    zi = squeeze(z(:,:,ibeam));
    wi = squeeze(wpeof(:,:,ibeam));

    for izbin = 1:nzbin

        zmin = zbin(izbin)-dzbin/2;
        zmax = zbin(izbin)+dzbin/2;

        % Any data in depth bin?
        ndat(izbin,ibeam) = sum( ~isnan(wi (zi > zmin & zi < zmax) ));
        if ndat < 50
            continue
        end
            
        % Compute velocity differences, bin by range
        [dW, R] = ADCPpairdiff(wi, zi, zmin, zmax);
        if isempty(dW)
           continue
        end
        if ibeam < 5;  R = R./cosd(25); end

        % Bin by r and average D = <dW.^2>;
        if opt.HR.binavgSF
            r = (dz/2: dz : nbin*dz+dz/2)';
            [~, ~, binidx] = histcounts(R,r);
            dW = [dW; NaN];  
            binidx = [binidx; length(r)];
            n = accumarray(binidx,ones(size(dW)),[],@sum);
            mu = accumarray(binidx,dW,[],@mean);
            sig = accumarray(binidx,dW,[],@std);
            outlier = (abs(dW) >= (mu(binidx) + 3*sig(binidx))) & n(binidx)>5;
            D = accumarray(binidx(~outlier), dW(~outlier).^2,[], @mean);
            ifit = ~isnan(D) & D>0 & n > 0;
            D = D(ifit);
            r = r(ifit);
        else
            mu = mean(dW,'omitnan');
            sig = std(dW,[],'omitnan');
            outlier = abs(dW) >= (mu+5*sig);
            ifit = ~outlier;
            D = dW(ifit).^2;
            r = R(ifit);
        end

        % Vectors to perform fit (at least 3 points)
        Nfit = sum(ifit);
        if Nfit  < 3
            continue     
        else
            nfit(izbin,ibeam) = Nfit;
        end
         
        % Perform fit
        [eps(izbin,ibeam),A(izbin,ibeam),N(izbin,ibeam),slope(izbin,ibeam)] = SFfit(D,r);

    end
end
warning('on','all')

    
%% Plot

if opt.plotburst

    for ibeam = 1:nbeam

    % % Visualize Data
    % fh(ibeam) = figure('color','w');
    % clear c
    % MP = get(0,'monitorposition');
    % set(gcf,'outerposition',MP(1,:).*[1 1 1 1]);
    % nsub = 7;
    % subplot(nsub,1,1)
    % yyaxis right
    % plot(1:nping,z0,'-b','LineWidth',2)
    % set(gca,'YColor','b','YDir','Reverse');ylabel('Z [m]')
    % yyaxis left
    % plot(1:nping,-wrise,'-k')
    % set(gca,'YColor','k');ylabel('W_r [ms^{-1}]')
    % axis tight
    % c = colorbar;c.Visible = 'off';
    % title('HR Data');
    % subplot(nsub,1,2)
    % yyaxis right
    % plot(1:nping,pitch,'-r')
    % hold on;
    % plot(1:nping,roll,'-b')
    % set(gca,'YColor','b');
    % yyaxis left
    % plot(1:nping,heading,'-k')
    % set(gca,'Ycolor','k');ylabel('\Theta [deg]')
    % axis tight
    % c = colorbar;c.Visible = 'off';
    % legend('Pitch,Roll,Heading')
    % subplot(nsub,1,3)
    % i = imagesc(squeeze(hramp(:,:,ibeam))');i.Interpolation = 'nearest';
    % cmocean('amp')
    % ylabel('Bin #');set(gca,'YDir','Normal')
    % c = colorbar;c.Label.String = 'A (dB)';
    % subplot(nsub,1,4)
    % i = imagesc(squeeze(hrcorr(:,:,ibeam))');i.Interpolation = 'nearest';
    % clim([35 100]);cmocean('amp')
    % ylabel('Bin #')
    % c = colorbar;c.Label.String = 'C (%)';
    % subplot(nsub,1,5)
    % i = imagesc(squeeze(wraw(:,:,ibeam))');i.Interpolation = 'nearest';
    % clim([-0.5 0.5]);cmocean('balance');
    % ylabel('Bin #')
    % c = colorbar;c.Label.String = 'W_r (m/s)';
    % subplot(nsub,1,6)
    % i = imagesc(squeeze(ispike(:,:,ibeam))' ...
    %     + 2*squeeze(ipoor(:,:,ibeam))');i.Interpolation = 'nearest';
    % clim([0 2]);colormap(gca,[rgb('white'); rgb('blue'); rgb('red'); rgb('black')])
    % ylabel('Bin #')
    % c = colorbar;c.Ticks = (3/4)*(1:4)-0.3;
    % c.TickLabels = {'Good','Spike','Low Corr','Both'};
    % subplot(nsub,1,7)
    % imagesc(squeeze(wpeof(:,:,ibeam))')
    % ylabel('Bin #')
    % clim([-0.05 0.05]);cmocean('balance')
    % c = colorbar;c.Label.String = 'W_{hp} (m/s)';
    % xlabel('Ping #')
    % p = get(gca,'Position');
    % h = findall(gcf,'Type','Axes');
    % for ih = 1:length(h)
    %     h(ih).Position(3) = p(3);h(ih).Position(4) = p(4);
    % end
    % set(h(1:end-3),'YDir','Normal')

    % Plot Data in Profile form and Dissipation
    binnum = repmat((1:nbin)',1,nping);
    fh(ibeam) = figure('color','w');
    MP = get(0,'monitorposition');
    set(gcf,'outerposition',MP(2,:).*[1 1 0.75 1]+[MP(3)/4 0 0 0]);
    subplot(1,5,1)
    pcolor(binnum,squeeze(z(:,:,ibeam))',squeeze(wraw(:,:,ibeam))')
    shading flat;
    xlabel('Bin #')
    clim([-0.05 0.05]);cmocean('balance')
    c = colorbar;c.Label.String = 'W_{r} (m/s)';
    c.Location = 'SouthOutside';
    title('W');
    subplot(1,5,2)
    pcolor(binnum,squeeze(z(:,:,ibeam))',squeeze(hramp(:,:,ibeam))')
=======
%% Filter Data %%%%%%

% 1) No filter
wnf = wclean;

% 2) Spatial High-pass
nsm = round(2/dz); % 1 m
wphp = wclean - smooth_mat(wclean',hann(nsm))';

% 3) EOF High-pass using interpolated data 
[eofs,eofamp,eofvar,~] = eof(wclean');
wpeof = eofs(:,opt.HR.nsumeof+1:end)*(eofamp(:,opt.HR.nsumeof+1:end)');

% 5) Re-remove bad data
if opt.HR.NaNbad
    wnf(ibad) = NaN;
    wpeof(ibad) = NaN;
    wphp(ibad) = NaN;
end

%% Dissipation Rate
rmin = dz;
rmax = nbin*dz;
Cv2 = 2.1;
slope = NaN(1,nping);
A = NaN(1,nping);
N = NaN(1,nping);

for iping = 1:nping

    zi = zbins(:,iping);
    wi = wpeof(:,iping);

    R = zi-zi';
    R = round(R,2);
    [Z1,Z2] = meshgrid(zi);
    Z0 = (Z1+Z2)/2;
    dW = wi-wi';
    dW(abs(dW)>5*std(dW(:),[],'omitnan')) = NaN;
    D = dW.^2;

    ifit= R <= rmax & R >= rmin & ~isnan(D);

    nfit = sum(ifit(:));
    if nfit < 3 % Must contain more than 3 points
        % disp('Not enough pts')
        continue     
    end
    x0 = ones(nfit,1);
    x1 = R(ifit);
    x23 = R(ifit).^(2/3);
    d = D(ifit);

    % Best-fit power-law to the structure function
    ilog = x1 > 0 & d > 0;% log(0) = -Inf
    x1log = log10(x1(ilog));
    dlog = log10(d(ilog));
    xNlog = x0(ilog);
    G = [x1log(:) xNlog(:)];
    Gg = (G'*G)\G';
    m = Gg*dlog(:);
    slope(iping) = m(1);  

    % Fit structure function to D(z,r) = Ar^(2/3) + Nr^0
    G = [x23(:) x0(:)];
    Gg = (G'*G)\G';
    m = Gg*d(:);

    A(iping) = m(2);
    N(iping) = m(2);

end
A(A<0) = NaN;
eps = (A./Cv2).^(3/2);

%%
if opt.plotburst

    % Visualize Data
    fh1(ibeam) = figure('color','w');
    clear c
    MP = get(0,'monitorposition');
    set(gcf,'outerposition',MP(1,:).*[1 1 1 1]);
    nsub = 7;

    subplot(nsub,1,1)
    yyaxis right
    plot(1:nping,z0,'-b','LineWidth',2)
    set(gca,'YColor','b','YDir','Reverse');ylabel('Z [m]')
    yyaxis left
    plot(1:nping,-wrise,'-k')
    set(gca,'YColor','k');ylabel('W_r [ms^{-1}]')
    axis tight
    c = colorbar;c.Visible = 'off';
    title('HR Data');

    subplot(nsub,1,2)
    yyaxis right
    plot(1:nping,pitch,'-r')
    hold on;
    plot(1:nping,roll,'-b')
    set(gca,'YColor','b');
    yyaxis left
    plot(1:nping,heading,'-k')
    set(gca,'Ycolor','k');ylabel('\Theta [deg]')
    axis tight
    c = colorbar;c.Visible = 'off';
    legend('Pitch,Roll,Heading')

    subplot(nsub,1,3)
    i = imagesc(hramp);i.Interpolation = 'nearest';
    cmocean('amp')
    ylabel('Bin #');set(gca,'YDir','Normal')
    c = colorbar;c.Label.String = 'A (dB)';
    subplot(nsub,1,4)
    i = imagesc(hrcorr);i.Interpolation = 'nearest';
    caxis([35 100]);cmocean('amp')
    ylabel('Bin #')
    c = colorbar;c.Label.String = 'C (%)';
    subplot(nsub,1,5)
    i = imagesc(wraw);i.Interpolation = 'nearest';
    caxis([-0.5 0.5]);cmocean('balance');
    ylabel('Bin #')
    c = colorbar;c.Label.String = 'W_r (m/s)';

    subplot(nsub,1,6)
    i = imagesc(ispike + 2*ipoor);i.Interpolation = 'nearest';
    caxis([0 2]);colormap(gca,[rgb('white'); rgb('blue'); rgb('red'); rgb('black')])
    ylabel('Bin #')
    c = colorbar;c.Ticks = (3/4)*(1:4)-0.3;
    c.TickLabels = {'Good','Spike','Low Corr','Both'};
    subplot(nsub,1,7)
    imagesc(wpeof)
    ylabel('Bin #')
    caxis([-0.05 0.05]);cmocean('balance')

    c = colorbar;c.Label.String = 'W_{hp} (m/s)';

    xlabel('Ping #')

    p = get(gca,'Position');
    h = findall(gcf,'Type','Axes');
    for ih = 1:length(h)
        h(ih).Position(3) = p(3);h(ih).Position(4) = p(4);
    end
    set(h(1:end-3),'YDir','Normal')

    % Plot Data in Profile form and Dissipation
    binnum = repmat((1:nbin)',1,nping);

    fh2(ibeam) = figure('color','w');
    MP = get(0,'monitorposition');
    set(gcf,'outerposition',MP(1,:).*[1 1 0.75 1]+[MP(3)/4 0 0 0]);

    subplot(1,4,1)
    pcolor(binnum,zbins,hramp)
>>>>>>> Stashed changes
    shading flat;
    cmocean('amp')
    title('Amp');
    ylabel('Z [m]')
    xlabel('Bin #')
    c = colorbar;c.Label.String = 'A (dB)';
    c.Location = 'SouthOutside';
<<<<<<< Updated upstream
    subplot(1,5,3)
    pcolor(binnum,squeeze(z(:,:,ibeam))',squeeze(hrcorr(:,:,ibeam))')
=======

    subplot(1,4,2)
    pcolor(binnum,zbins,hrcorr)
>>>>>>> Stashed changes
    shading flat;
    clim([35 100]);cmocean('amp')
    xlabel('Bin #')
    c = colorbar;c.Label.String = 'C (%)';
    c.Location = 'SouthOutside';
        title('Corr');
<<<<<<< Updated upstream
    subplot(1,5,4)
    pcolor(binnum,squeeze(z(:,:,ibeam))',squeeze(wpeof(:,:,ibeam))')
=======

    subplot(1,4,3)
    pcolor(binnum,zbins,wpeof)
>>>>>>> Stashed changes
    shading flat;
    xlabel('Bin #')
    clim([-0.05 0.05]);cmocean('balance')
    c = colorbar;c.Label.String = 'W_{hp} (m/s)';
    c.Location = 'SouthOutside';
    title('W''');
<<<<<<< Updated upstream
    subplot(1,5,5)
    plot(log10(eps(:,ibeam)),zbin,'k','LineWidth',2)
=======

    subplot(1,4,4)
    plot(log10(eps),zprofile,'k','LineWidth',2)
>>>>>>> Stashed changes
    xlabel('\epsilon [m^2s^{-3}]')
    c = colorbar;c.Visible = 'off';
    c.Location = 'SouthOutside';
    title('\epsilon(z)')
    xlim([-10 -4])
<<<<<<< Updated upstream
    h = findall(gcf,'Type','Axes');
    linkaxes(h,'y')
    set(h,'YDir','Reverse')
    xlabel('Bin #')
    drawnow

    end

else
    fh = [];
end
    
%% Save Turbulence
clear HRprofile

% Results
HRprofile.time = mean(time,'omitnan');
HRprofile.z = zbin;

% Dissipation
HRprofile.eps = eps;
HRprofile.w = NaN(nzbin,nbeam);
HRprofile.wvar = NaN(nzbin,nbeam);
HRprofile.enu = NaN(nzbin,nbeam-1);

HRprofile.QC.eofs = eofs;
HRprofile.QC.eofvar = eofvar;
HRprofile.QC.nfit = nfit;
HRprofile.QC.ndat = ndat;
HRprofile.QC.N = N;
HRprofile.QC.slope = slope;
HRprofile.QC.wpeofmag = NaN(nzbin,nbeam);
HRprofile.QC.hrcorr = NaN(nzbin,nbeam);
HRprofile.QC.hramp = NaN(nzbin,nbeam);
HRprofile.QC.pbad = NaN(nzbin,nbeam);
for ibeam = 1:nbeam

        zi = squeeze(z(:,:,ibeam)); 
        wi = squeeze(wclean(:,:,ibeam));
        hrcorri = squeeze(hrcorr(:,:,ibeam));
        hrampi = squeeze(hramp(:,:,ibeam));
        wpeofi = squeeze(wpeof(:,:,ibeam));
        ibadi = squeeze(ibad(:,:,ibeam));

        if ibeam <5
            enui = squeeze(enuclean(:,:,ibeam));
        end

        for izbin = 1:nzbin
    
            zmin = zbin(izbin)-dzbin/2;
            zmax = zbin(izbin)+dzbin/2;
    
            idat2bin = zi >= zmin & zi < zmax;
    
            HRprofile.w(izbin,ibeam) = mean(wi(idat2bin),'omitnan');
            HRprofile.wvar(izbin,ibeam) = std(wi(idat2bin),[],'omitnan');
            if ibeam < 5
                HRprofile.enu(izbin,ibeam) = mean(enui(idat2bin),'omitnan');
            end
    
            HRprofile.QC.wpeofmag(izbin,ibeam) = std(wpeof(idat2bin),[],'omitnan');
            HRprofile.QC.hrcorr(izbin,ibeam) = mean(hrcorri(idat2bin),'omitnan');
            HRprofile.QC.hramp(izbin,ibeam) = mean(hrampi(idat2bin),'omitnan');
            HRprofile.QC.pbad(izbin,ibeam) = sum(100*ibadi(idat2bin)./numel(idat2bin),'omitnan');

        end

end


end
                   
=======

    h = findall(gcf,'Type','Axes');
    linkaxes(h,'y')
    set(h,'YDir','Reverse')

    xlabel('Bin #')
    drawnow

else
    fh1 = [];
    fh2 = [];
end

%% Save Results

HRprofile(ibeam).w = mean(wclean,'omitnan');
HRprofile(ibeam).wvar = var(wclean,[],'omitnan');
HRprofile(ibeam).z = zprofile;
HRprofile(ibeam).eps = eps';
HRprofile(ibeam).time = mean(time,'omitnan');

% Additional information for quality control
HRprofile(ibeam).QC.N = N;
HRprofile(ibeam).QC.eofs = eofs;
HRprofile(ibeam).QC.eofvar = eofvar;
HRprofile(ibeam).QC.eofamp = eofamp';
HRprofile(ibeam).QC.wpeofmag = std(wpeof,[],'omitnan')';
HRprofile(ibeam).QC.hrcorr = mean(hrcorr,'omitnan')';
HRprofile(ibeam).QC.hramp = mean(hramp,'omitnan')';
HRprofile(ibeam).QC.pbad = 100*sum(ibad)./nbin; 

end
                   
end
>>>>>>> Stashed changes

