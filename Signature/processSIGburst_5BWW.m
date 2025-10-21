function [HRprofile,fh] = processSIGburst_5BWW(burst,varargin)
% Adapted processSIGburst to estimate structure function dissipation
% averaged across all 5 beams sampling HR data on Sig1000 mounted on a
% WireWalker.
% K. Zeiden 10/2025

if nargin < 2
    opt.plotburst = false; % generate plots for each burst
    opt.HR.mincorr = 40;% To ignore correlation, set to 0;
    opt.HR.QCbin = true;% QC entire bins with greater than opt.HR.pbadmax_bin perecent bad data (spikes & correlation)
    opt.HR.pbadmax_bin = 50;
    opt.HR.QCping = true;% QC entire bins with greater than opt.HR.pbadmax_ping perecent bad data (spikes & correlation)
    opt.HR.pbadmax_ping = 50;
    opt.HR.NaNbad = true;% NaN out bad data. Otherwise they are interpolated through.
    opt.HR.nsumeof = 3;
    opt.HR.eoftype = '5beam';
else
    opt = varargin{1};
end

%% Data
time = burst.time;
z0 = burst.Pressure;
dt = round(median(diff(time)*24*60*60),2);
wrise = gradient(z0)./dt;

% velocities
wraw = burst.VelocityData;
for ibeam = 1:4
    wraw(:,:,ibeam) = wraw(:,:,ibeam)-wrise*cosd(25);
end
wraw(:,:,5) = wraw(:,:,5)-wrise;
enuraw = burst.VelocityDataENU;
xyzraw = burst.VelocityDataXYZ;
enuraw(:,:,3) = enuraw(:,:,3)-wrise;
xyzraw(:,:,3) = xyzraw(:,:,3)-wrise;
errraw = burst.VelocityDataERR;

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
zbins = NaN(size(wraw));
r = bz + dz*(1:nbin);
zbins(:,:,5) = z0 - r;
for ibeam = 1:4
 zbins(:,:,ibeam) = z0 - r*cosd(25);
end

%% Quality Control 
 
% Identify Spikes (phase-shift threshold, Shcherbina 2018)
ispike = false(size(wraw));
for ibeam = 1:nbeam
    [~,ispikeibeam] = despikeSIG(squeeze(wraw(:,:,ibeam))',nfilt,Vr/2);
    ispike(:,:,ibeam) = ispikeibeam';
end

% Identify poor quality (low correlation) data
ipoor = hrcorr < opt.HR.mincorr;

% Identify near-surface data
zmin = 5;
isurf = zbins < zmin;

% All bad points
ibad = isurf | ipoor | ispike;
    
% Identify entire bad bins (percentage of bad data > opt.pbadmax_bin)
pbad_bin = 100*(sum(ibad,1,'omitnan')./nping);
ibadbin = pbad_bin > opt.HR.pbadmax_bin;
if opt.HR.QCbin
    ibad = ibad | repmat(ibadbin,nping,1,1);
end

% Identify entire bad pings (percentage of bad data > opt.pbadmax_ping, not
% including bad bins removed in previous step)
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
end

% Remove bad data
wclean = wraw;wclean(ibad) = NaN;

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
[enuclean,~,errclean ] = beam2enu(winterp(:,:,1:4), heading, pitch, roll);

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
rmin = dz;

% Integrate over each ping
rmax = nbin*dz;
z = squeeze(mean(zbins,2,'omitnan'));
slope = NaN(nping,nbeam);
A = NaN(nping,nbeam);
N = NaN(nping,nbeam);
nfit = NaN(nping,nbeam);
warning('off','all')
for ibeam = 1:nbeam
    for iping = 1:nping

        zi = squeeze(zbins(iping,:,ibeam));
        wi = squeeze(wpeof(iping,:,ibeam));

        R = zi-zi';
        R = round(R,2);
        [Z1,Z2] = meshgrid(zi);
        Z = (Z1+Z2)/2;
        dW = wi-wi';
        dW(abs(dW)>5*std(dW(:),[],'omitnan')) = NaN;
        D = dW.^2;

        ifit = R <= rmax & R >= rmin & ~isnan(D);

        nfit(iping,ibeam) = sum(ifit(:));
        if nfit(iping,ibeam)  < 3 % Must contain more than 3 points
            % disp('Not enough pts')
            continue     
        end
        x0 = ones(nfit(iping,ibeam),1);
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
        slope(iping,ibeam) = m(1);  

        % Fit structure function to D(z,r) = Ar^(2/3) + Nr^0
        G = [x23(:) x0(:)];
        Gg = (G'*G)\G';
        m = Gg*d(:);

        A(iping,ibeam) = m(2);
        N(iping,ibeam) = m(2);

    end
end
warning('on','all')
A(A<0) = NaN;
eps = (A./Cv2).^(3/2);
    
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
    pcolor(binnum,squeeze(zbins(:,:,ibeam))',squeeze(wraw(:,:,ibeam))')
    shading flat;
    xlabel('Bin #')
    clim([-0.05 0.05]);cmocean('balance')
    c = colorbar;c.Label.String = 'W_{r} (m/s)';
    c.Location = 'SouthOutside';
    title('W');
    subplot(1,5,2)
    pcolor(binnum,squeeze(zbins(:,:,ibeam))',squeeze(hramp(:,:,ibeam))')
    shading flat;
    cmocean('amp')
    title('Amp');
    ylabel('Z [m]')
    xlabel('Bin #')
    c = colorbar;c.Label.String = 'A (dB)';
    c.Location = 'SouthOutside';
    subplot(1,5,3)
    pcolor(binnum,squeeze(zbins(:,:,ibeam))',squeeze(hrcorr(:,:,ibeam))')
    shading flat;
    clim([35 100]);cmocean('amp')
    xlabel('Bin #')
    c = colorbar;c.Label.String = 'C (%)';
    c.Location = 'SouthOutside';
        title('Corr');
    subplot(1,5,4)
    pcolor(binnum,squeeze(zbins(:,:,ibeam))',squeeze(wpeof(:,:,ibeam))')
    shading flat;
    xlabel('Bin #')
    clim([-0.05 0.05]);cmocean('balance')
    c = colorbar;c.Label.String = 'W_{hp} (m/s)';
    c.Location = 'SouthOutside';
    title('W''');
    subplot(1,5,5)
    plot(log10(eps(:,ibeam)),z,'k','LineWidth',2)
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

    end

else
    fh = [];
end
    
%% Save Turbulence
clear HRprofile

% Results
HRprofile.time = mean(time,'omitnan');
HRprofile.z = z;
HRprofile.w = squeeze(mean(wclean,2,'omitnan'));
HRprofile.wvar = squeeze(std(wclean,[],2,'omitnan'));
HRprofile.eps = eps;
HRprofile.enu = squeeze(mean(enuclean,2,'omitnan'));

% Additional information for quality control
HRprofile.QC.N = N;
HRprofile.QC.slope = slope;
HRprofile.QC.eofs = eofs;
HRprofile.QC.eofvar = eofvar;
HRprofile.QC.eofamp = eofamp;
HRprofile.QC.wpeofmag = squeeze(std(wpeof,[],2,'omitnan'));
HRprofile.QC.hrcorr = squeeze(mean(hrcorr,2,'omitnan'));
HRprofile.QC.hramp = squeeze(mean(hramp,2,'omitnan'));
HRprofile.QC.pbad = squeeze(100*sum(ibad,2,'omitnan')./nbin); 
HRprofile.QC.enuerr = squeeze(mean(errclean,2,'omitnan'));

end
                   

