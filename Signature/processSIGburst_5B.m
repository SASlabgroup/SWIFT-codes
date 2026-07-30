function [HRprofile,fh] = processSIGburst_5B(burst,varargin)
% Process 5-beam HR Signature Data from drifting SWIFTs
% Adapted from procressSIGburst_5BWW

% Currently no depth correction is made, so there will be depth smearing
% with increasing severity towards the base of the profile.

% K. Zeiden January 2026

%% Development %%
% missiondir = 'S:\RRF\HR5Beam\20260108\RRF_FieldTest_Jan2026\SWIFT23_08Jan2026';
% bfiles = dir([missiondir slash 'SIG' slash 'Raw' slash '*' slash '*.mat']);
% iburst = 10;
% load([bfiles(iburst).folder slash bfiles(iburst).name])

%% Options

if nargin < 2
    opt.plotburst = true; % generate plots for each burst
    opt.HR.mincorr = 40;% To ignore correlation, set to 0;
    opt.HR.QCbin = true;% QC entire bins with greater than opt.HR.pbadmax_bin perecent bad data (spikes & correlation)
    opt.HR.pbadmax_bin = 50;
    opt.HR.QCping = true;% QC entire bins with greater than opt.HR.pbadmax_ping perecent bad data (spikes & correlation)
    opt.HR.pbadmax_ping = 50;
    opt.HR.NaNbad = true;% NaN out bad data. Otherwise they are interpolated through.
    opt.HR.nsumeof = 3;
    opt.HR.eoftype = '5beam';
    opt.HR.binavgSF = true;
else
    opt = varargin{1};
end

%% Data

% velocities
wraw = burst.VelocityData;

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

% nominal depth bins (not corrected for motion)
nomz = NaN(nbin,nbeam);
r = bz + dz*(1:nbin);
depth = 0.2;
nomz(:,5) = depth + r;
for ibeam = 1:4
 nomz(:,ibeam) = depth + r*cosd(25);
end

% true depth bins 
[~, truez] = correctSIGdepths_BA(burst) ;

%% Quality Control 
 
% Identify Spikes (phase-shift threshold, Shcherbina 2018)
ispike = false(size(wraw));
for ibeam = 1:nbeam
    [~,ispikeibeam] = despikeSIG(squeeze(wraw(:,:,ibeam))',nfilt,Vr/2);
    ispike(:,:,ibeam) = ispikeibeam';
end

% Identify poor quality (low correlation) data
ipoor = hrcorr < opt.HR.mincorr;

% All bad points
ibad = ipoor | ispike;
    
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
wclean = wraw;
wclean(ibad) = NaN;

%% Compute 'ENU' velocities from clean data

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
opt.HR.eoftype = '5beam';

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

%% Development: Dissipation Rate for each beam
rmin = dz;
rmax = 4*dz;
nzfit = 1;
zbin = nomz(:,5);
fittype = 'linear';
avgtype = 'mean';

% Original function
tic
eps0 = NaN(nbin,nbeam);
qual0.mspe = NaN(nbin,nbeam);
qual0.slope = NaN(nbin,nbeam);
qual0.epserr = NaN(nbin,nbeam);
qual0.A = NaN(nbin,nbeam);
qual0.B = NaN(nbin,nbeam);
qual0.N = NaN(nbin,nbeam);
for ibeam = 1:nbeam
    w = squeeze(wpeof(:,:,ibeam))';
    z = nomz(:,ibeam);
[eps0(:,ibeam),qual0ibeam] = SFdissipation(w,z,rmin,rmax,nzfit,fittype,avgtype);
qual0.mspe(:,ibeam) = qual0ibeam.mspe;
qual0.slope(:,ibeam) = qual0ibeam.slope;
qual0.epserr(:,ibeam) = qual0ibeam.epserr;
qual0.A(:,ibeam) = qual0ibeam.A;
qual0.B(:,ibeam) = qual0ibeam.B;
qual0.N(:,ibeam) = qual0ibeam.N;
end
toc

% New depth-variable function
tic
eps = NaN(nbin,nbeam);
qual.mspe = NaN(nbin,nbeam);
qual.slope = NaN(nbin,nbeam);
qual.epserr = NaN(nbin,nbeam);
qual.A = NaN(nbin,nbeam);
qual.B = NaN(nbin,nbeam);
qual.N = NaN(nbin,nbeam);
for ibeam = 1:nbeam
    w = squeeze(wpeof(:,:,ibeam))';
    z = squeeze(truez(:,:,ibeam))';
    [eps(:,ibeam),qualibeam] = SFdissipation_varz(w,repmat(r(:),1,nping),z,zbin,rmin,rmax,nzfit,fittype,avgtype);
qual.mspe(:,ibeam) = qualibeam.mspe;
qual.slope(:,ibeam) = qualibeam.slope;
qual.epserr(:,ibeam) = qualibeam.epserr;
qual.A(:,ibeam) = qualibeam.A;
qual.B(:,ibeam) = qualibeam.B;
qual.N(:,ibeam) = qualibeam.N;
end
toc

% New all-beam function
% tic
% [eps2,~] = SFdissipation_beamavg(wpeof,truez,zbin,rmin,rmax,nzfit,'linear','mean','all');
% toc

% Plot
% figure('color','w')
% h = gobjects(nbeam+1,1);
% for ibeam = 1:nbeam
%     subplot(1,nbeam+1,ibeam)
%     plot(eps0(:,ibeam),-nomz(:,ibeam),'k','LineWidth',2);
%     hold on
%     plot(eps(:,ibeam),-zbin,'r','LineWidth',2);
%     h(ibeam) = gca;
%     title(['Beam ' num2str(ibeam)])
% end
% legend('Fixed Depth','Variable Depth')
% subplot(1,nbeam+1,nbeam+1)
% plot(mean(eps0,2,'omitnan'),-nomz(:,5),'k','LineWidth',2)
% hold on
% plot(mean(eps,2,'omitnan'),-zbin,'r','LineWidth',2)
% % plot(eps2,-zbin,'b','LineWidth',2)
% % legend('Fixed Depth','Variable Depth','Single-Ensemble Method')
% title('Beam-Averaged')
% h(ibeam+1) = gca;
% set(h,'XScale','log')
% linkaxes(h)
% h(1);ylabel('Z [m]');
% for ih = 1:length(h)
%     xlabel('\epsilon [m^2s^{-3}]')
% end
% axis tight
% set(h,'XGrid','on','YGrid','on')
    
%% Save Results
clear HRprofile

%%%%%% Velocity Profile %%%%%%
HRprofile.w = squeeze(mean(wclean,1,'omitnan'));
HRprofile.wvar = squeeze(var(wclean,[],1,'omitnan'));
HRprofile.enu = squeeze(mean(enuclean,1,'omitnan'));
HRprofile.enuvar = squeeze(var(enuclean,[],1,'omitnan'));
HRprofile.z = nomz;

% Save Dissipation Results
HRprofile.eps = eps;% Presumed to be best estimate

% Additional information for quality control
HRprofile.QC.eps0 = eps0;
HRprofile.QC.qual = qual;
HRprofile.QC.qual0 = qual0;
% HRprofile.QC.eofs = eofs;
% HRprofile.QC.eofvar = eofvar;
% HRprofile.QC.eofamp = eofamp';
HRprofile.QC.wpeofmag = squeeze(std(wpeof,[],1,'omitnan'));
HRprofile.QC.hrcorr = squeeze(mean(hrcorr,1,'omitnan'));
HRprofile.QC.hramp = squeeze(mean(hramp,1,'omitnan'));
HRprofile.QC.pspike = squeeze(100*(sum(ibad,1,'omitnan')./nping));  

%% Plot Burst 
if opt.plotburst

    for ibeam = 1:nbeam
    
    % Visualize Data
    fh(ibeam) = figure('color','w');
    clear c
    MP = get(0,'monitorposition');
    set(gcf,'outerposition',MP(1,:).*[1 1 1 1]);
    subplot(5,1,1)
    imagesc(hramp(:,:,ibeam)')
    clim([50 160]); cmocean('amp')
    title(['HR Data (Beam ' num2str(ibeam) ')']);
    ylabel('Bin #')
    c = colorbar;c.Label.String = 'A (dB)';
    subplot(5,1,2)
    imagesc(hrcorr(:,:,ibeam)')
    clim([35 100]);cmocean('amp')
    ylabel('Bin #')
    c = colorbar;c.Label.String = 'C (%)';
    subplot(5,1,3)
    imagesc(wraw(:,:,ibeam)')
    clim([-0.5 0.5]);cmocean('balance');
    ylabel('Bin #')
    c = colorbar;c.Label.String = 'W_r (m/s)';
    subplot(5,1,4)
    imagesc(ispike(:,:,ibeam)' + 2*ipoor(:,:,5)')
    clim([0 2]);colormap(gca,[rgb('white'); rgb('blue'); rgb('red'); rgb('black')])
    ylabel('Bin #')
    c = colorbar;c.Ticks = (3/4)*(1:4)-0.3;
    c.TickLabels = {'Good','Spike','Low Corr','Both'};
    subplot(5,1,5)
    imagesc(wpeof(:,:,ibeam)')
    ylabel('Bin #')
    clim([-0.05 0.05]);cmocean('balance')
    c = colorbar;c.Label.String = 'W_hp (m/s)';

    xlabel('Ping #')
    drawnow
    end
else
    fh = [];
end


end
                   

