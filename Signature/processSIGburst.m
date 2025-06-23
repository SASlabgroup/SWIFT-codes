function [HRprofile,fh] = processSIGburst(burst,opt)
% NOTE: Quality Control
%   - remove worst pings to get good EOFs, then interpolate back in time
%   - alternatively, could use *only* despiked data. This does not
%       work well when data are very noisy/poor quality

%    Check to make sure dimensions correct
if length(size(burst.VelocityData)) > 2
    disp('   HR data dimensions bad')
    HRprofile = [];
    fh = [];
    return
end

% Data
hrcorr = burst.CorrelationData';
hramp = burst.AmplitudeData';
wraw = -burst.VelocityData';

% N pings + N z-bins
[nbin,nping] = size(wraw);
dz = burst.CellSize;
bz = burst.Blanking;
xz = opt.xz;
z = xz + bz + dz*(1:nbin)';

%%%%%%%% QC Veloctiy Data %%%%%%%%

% Identify Spikes (phase-shift threshold, Shcherbina 2018)
L = bz+dz*nbin; % m, pulse distance
F0 = 10^6; % Hz, pulse carrier frequency (1 MHz for Sig 1000)
cs = mean(burst.SoundSpeed,'omitnan'); % m/s, sound speed
Vr = cs.^2./(4*F0*L);% m/s
nfilt = round(1/dz);% 1 m
[~,ispike] = despikeSIG(wraw,nfilt,Vr/2);

% Identify poor quality (low correlation) data
ipoor = hrcorr < opt.HR.mincorr;

% Bad Data
ibad = ispike | ipoor;

% Fill bad data with linear interpolation
wclean = NaN(size(wraw));
for iping = 1:nping    
    igood = find(~ibad(:,iping));
    if length(igood) > 3
    wclean(:,iping) = interp1(igood,wraw(igood,iping),1:nbin,'linear','extrap'); 
    end
end

% NaN bad bins (percentage of bad data > opt.pbadmax_bin)
pbad_bin = 100*(sum(ibad,2,'omitnan')./nping);
badbin = pbad_bin > opt.HR.pbadmax_bin;
if opt.HR.QCbin
wclean(badbin,:) = NaN;
end

% NaN bad pings (percentage of bad data > opt.pbadmax_ping)
if opt.HR.QCbin
pbad_ping = 100*sum(ibad(~badbin,:))./sum(~badbin); 
else
    pbad_ping = 100*sum(ibad,'omitnan')./nbin;
end
badping = pbad_ping > opt.HR.pbadmax_ping;
if opt.HR.QCping
wclean(:,badping) = NaN;
end

%%%%%% Velocity Profile %%%%%%
HRprofile.w = mean(wclean,2,'omitnan');
HRprofile.wvar = var(wclean,[],2,'omitnan');
HRprofile.z = z;

%%%%%% Dissipation Estimates %%%%%%

% 1) No filter
wnf = wclean;

% 2) Spatial High-pass
nsm = round(2/dz); % 1 m
wphp = wclean - smooth_mat(wclean',hann(nsm))';

% 3) EOF High-pass using interpolated data 
[eofs,eofamp,eofvar,~] = eof(wclean');
wpeof = eofs(:,opt.HR.nsumeof+1:end)*(eofamp(:,opt.HR.nsumeof+1:end)');

% 4) Estimate dissipation rate from velocity structure functions
rmin = dz;
rmax = 4*dz;
nzfit = 1;

% 5) Include interpolated data or not...
if opt.HR.NaNbad
    wnf(ibad) = NaN;
    wpeof(ibad) = NaN;
    wphp(ibad) = NaN;
end

warning('off','all')
% No filter, no analytic wave fit (D ~ r^{-2/3})
[epsNF,qualNF] = SFdissipation(wnf,z,rmin,2*rmax,nzfit,'linear','mean');
% Analytic wave fit  (D ~ Ar^{-2/3} + Br^2)
[epsWV,qualWV] = SFdissipation(wnf,z,rmin,2*rmax,nzfit,'cubic','mean');
% EOF filter (D ~ r^{-2/3})
[epsEOF,qualEOF] = SFdissipation(wpeof,z,rmin,rmax,nzfit,'linear','mean');
% High-pass filter (D ~ r^{-2/3})
[epsHP,qualHP] = SFdissipation(wphp,z,rmin,rmax,nzfit,'linear','mean');
warning('on','all')

% Save Dissipation Results
HRprofile.eps = epsEOF';% Presumed to be best estimate

% Additional information for quality control
HRprofile.QC.epsNF = epsNF';
HRprofile.QC.epsWV = epsWV'; 
HRprofile.QC.epsHP = epsHP';
HRprofile.QC.epsEOF = epsEOF';
HRprofile.QC.qualNF = qualNF;
HRprofile.QC.qualWV = qualWV;
HRprofile.QC.qualHP = qualHP;
HRprofile.QC.qualEOF = qualEOF;
HRprofile.QC.eofs = eofs;
HRprofile.QC.eofvar = eofvar;
HRprofile.QC.eofamp = eofamp';
HRprofile.QC.wpeofmag = std(wpeof,[],2,'omitnan')';
HRprofile.QC.hrcorr = mean(hrcorr,2,'omitnan');
HRprofile.QC.hramp = mean(hramp,2,'omitnan');
HRprofile.QC.pspike = 100*(sum(ibad,2,'omitnan')./nping);  
HRprofile.QC.pbadping = sum(badping)./nping;

% Plot Burst 
if opt.plotburst
    
    % Visualize Data
    fh(1) = figure('color','w');
    clear c
    MP = get(0,'monitorposition');
    set(gcf,'outerposition',MP(1,:).*[1 1 1 1]);
    subplot(5,1,1)
    imagesc(hramp)
    caxis([50 160]); cmocean('amp')
    title('HR Data');
    ylabel('Bin #')
    c = colorbar;c.Label.String = 'A (dB)';
    subplot(5,1,2)
    imagesc(hrcorr)
    caxis([35 100]);cmocean('amp')
    ylabel('Bin #')
    c = colorbar;c.Label.String = 'C (%)';
    subplot(5,1,3)
    imagesc(wraw)
    caxis([-0.5 0.5]);cmocean('balance');
    ylabel('Bin #')
    c = colorbar;c.Label.String = 'W_r (m/s)';
    subplot(5,1,4)
    imagesc(ispike + 2*ipoor)
    caxis([0 2]);colormap(gca,[rgb('white'); rgb('blue'); rgb('red'); rgb('black')])
    ylabel('Bin #')
    c = colorbar;c.Ticks = (3/4)*(1:4)-0.3;
    c.TickLabels = {'Good','Spike','Low Corr','Both'};
    subplot(5,1,5)
    imagesc(wpeof)
    ylabel('Bin #')
    caxis([-0.05 0.05]);cmocean('balance')
    c = colorbar;c.Label.String = 'W_hp (m/s)';

    xlabel('Ping #')
    drawnow
else
    fh = [];
end
                   
end

