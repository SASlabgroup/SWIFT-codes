function [HRprofile,fh] = processAQHburst(burst,opt)

% Data
corr = burst.CorrelationData';
amp = burst.AmplitudeData';
w = -burst.VelocityData';

% N pings + N z-bins
[nbin,nping] = size(w);
xz = opt.xz;
dz = opt.dz;
bz = opt.bz;
z = xz + bz + dz*(1:nbin)';

% Find Spikes
nsm = round(opt.lsm/dz); % 0.25 m
wfilt = w - smooth_mat(w',hann(nsm))'; 
ispike = abs(wfilt) > 3*std(wfilt);
winterp = NaN(size(w));
for iping = 1:nping    
    igood = find(~ispike(:,iping));
    if length(igood) > 3
        winterp(:,iping) = interp1(igood,w(igood,iping),1:nbin,'linear','extrap'); 
    end
end

%%%%%% Velocity Profile %%%%%%
HRprofile.w = mean(winterp,2,'omitnan');
HRprofile.wvar = var(winterp,[],2,'omitnan');
HRprofile.z = z;

%%%%%% Dissipation Estimates %%%%%%

% 1) Spatial High-pass
nsm = round(opt.lsm/dz); % 1 m
wphp = winterp - smooth_mat(winterp',hann(nsm))';
% wphp = winterp-mean(winterp,1,'omitnan');

% 2) EOF High-pass using interpolated data 
badping = sum(ispike)./nbin > 0.5; 
%   - remove worst pings to get good EOFs, then interpolate back in time
%   - alternatively, could use *only* despiked data. This does not
%       work well when data are very noisy/poor quality
eofamp = NaN(size(w'));
[eofs,eofamp(~badping,:),eofvar,~] = eof(winterp(:,~badping)');
if sum(~badping) > 2
    for ieof = 1:nbin
        eofamp(:,ieof) = interp1(find(~badping),eofamp(~badping,ieof),1:nping);
    end
    wpeof = eofs(:,opt.nsumeof+1:end)*(eofamp(:,opt.nsumeof+1:end)');
else
    wpeof = NaN(size(w));
end        

%%%%%%%%% 3) Estimate dissipation rate from velocity structure functions
ibad = ispike | repmat(badping,nbin,1);
rmin = dz;
rmax = 4*dz;
nzfit = 1;
w(ibad) = NaN;
wpeof(ibad) = NaN;
wphp(ibad) = NaN;

warning('off','all')
% No filter, no analytic wave fit (D ~ r^{-2/3})
[epsNF,qualNF] = SFdissipation(w,z,rmin,2*rmax,nzfit,'linear','mean');
% Analytic wave fit  (D ~ Ar^{-2/3} + Br^2)
[epsWV,qualWV] = SFdissipation(w,z,rmin,2*rmax,nzfit,'cubic','mean');
% EOF filter (D ~ r^{-2/3})
[epsEOF,qualEOF] = SFdissipation(wpeof,z,rmin,rmax,nzfit,'linear','mean');
% High-pass filter (D ~ r^{-2/3})
[epsHP,qualHP] = SFdissipation(wphp,z,rmin,rmax,nzfit,'linear','mean');
warning('on','all')

% Save Dissipation Results
HRprofile.eps = epsHP';% For AQH, simple high pass seems like the better estimate. Too few bins for good EOFs.

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
HRprofile.QC.eofsvar = eofvar;
HRprofile.QC.wpeofmag = std(wpeof,[],2,'omitnan')';
HRprofile.QC.hrcorr = mean(corr,2,'omitnan');
HRprofile.QC.hramp = mean(amp,2,'omitnan');
HRprofile.QC.pspike = (sum(ispike,2,'omitnan')./nping);  
HRprofile.QC.pbadping = sum(badping)./nping;

% Plot Burst 
if opt.plotburst
    
    % Visualize Data
    fh(1) = figure('color','w');
    clear c
    MP = get(0,'monitorposition');
    set(gcf,'outerposition',MP(1,:).*[1 1 1 1]);
    subplot(5,1,1)
    imagesc(amp)
    caxis([50 160]); cmocean('amp')
    title('HR Data');
    ylabel('Bin #')
    c = colorbar;c.Label.String = 'A (dB)';
    subplot(5,1,2)
    imagesc(corr)
    caxis([35 100]);cmocean('amp')
    ylabel('Bin #')
    c = colorbar;c.Label.String = 'C (%)';
    subplot(5,1,3)
    imagesc(winterp)
    caxis([-0.5 0.5]);cmocean('balance');
    ylabel('Bin #')
    c = colorbar;c.Label.String = 'W_r (m/s)';
    subplot(5,1,4)
    imagesc(ispike)
    caxis([0 2]);colormap(gca,[rgb('white'); rgb('black')])
    ylabel('Bin #')
    c = colorbar;c.Ticks = [0.5 1.5];
    c.TickLabels = {'Good','Spike'};
    subplot(5,1,5)
    imagesc(wphp)
    ylabel('Bin #')
    caxis([-0.05 0.05]);cmocean('balance')
    c = colorbar;c.Label.String = 'W_hp (m/s)';

    xlabel('Ping #')
    drawnow
else
    fh = [];
end
                   
end

