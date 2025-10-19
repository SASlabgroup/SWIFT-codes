function [HRprofile,fh1,fh2] = processSIGburst_5BWW(burst,varargin)
% Adapted processSIGburst to estimate structure function dissipation
% averaged across all 5 beams sampling HR data on Sig1000 mounted on a
% WireWalker.
% K. Zeiden 10/2025

if nargin < 2
    opt.plotburst = true; % generate plots for each burst
    opt.HR.mincorr = 40;% To ignore correlation, set to 0;
    opt.HR.QCbin = true;% QC entire bins with greater than opt.HR.pbadmax_bin perecent bad data (spikes & correlation)
    opt.HR.pbadmax_bin = 50;
    opt.HR.QCping = true;% QC entire bins with greater than opt.HR.pbadmax_ping perecent bad data (spikes & correlation)
    opt.HR.pbadmax_ping = 50;
    opt.HR.NaNbad = true;% NaN out bad data. Otherwise they are interpolated through.
    opt.HR.nsumeof = 3;
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

% Identify poor quality (low correlation) data
ipoor = hrcorr < opt.HR.mincorr;

% Identify near-surface data
zmin = 5;
isurf = zbins < zmin;

% All bad points
ibad = isurf | ipoor | ispike;

% Identify entire bad bins (percentage of bad data > opt.pbadmax_bin)
pbad_bin = 100*(sum(ibad,2,'omitnan')./nping);
ibadbin = pbad_bin > opt.HR.pbadmax_bin;
if opt.HR.QCbin
    ibad = ibad | repmat(ibadbin,1,nping);
end

% Identify entire bad pings (percentage of bad data > opt.pbadmax_ping, not
% including bad bins removed in previous step)
if opt.HR.QCbin
pbad_ping = 100*sum(ibad(~ibadbin,:))./sum(~ibadbin); 
else
    pbad_ping = 100*sum(ibad,'omitnan')./nbin;
end
ibadping = pbad_ping > opt.HR.pbadmax_ping;
if opt.HR.QCping
    ibad = ibad | repmat(ibadping,nbin,1);
end

% Remove bad data
wclean = wraw;wclean(ibad) = NaN;

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
    shading flat;
    cmocean('amp')
    title('Amp');
    ylabel('Z [m]')
    xlabel('Bin #')
    c = colorbar;c.Label.String = 'A (dB)';
    c.Location = 'SouthOutside';

    subplot(1,4,2)
    pcolor(binnum,zbins,hrcorr)
    shading flat;
    clim([35 100]);cmocean('amp')
    xlabel('Bin #')
    c = colorbar;c.Label.String = 'C (%)';
    c.Location = 'SouthOutside';
        title('Corr');

    subplot(1,4,3)
    pcolor(binnum,zbins,wpeof)
    shading flat;
    xlabel('Bin #')
    clim([-0.05 0.05]);cmocean('balance')
    c = colorbar;c.Label.String = 'W_{hp} (m/s)';
    c.Location = 'SouthOutside';
    title('W''');

    subplot(1,4,4)
    plot(log10(eps),zprofile,'k','LineWidth',2)
    xlabel('\epsilon [m^2s^{-3}]')
    c = colorbar;c.Visible = 'off';
    c.Location = 'SouthOutside';
    title('\epsilon(z)')
    xlim([-10 -4])

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

