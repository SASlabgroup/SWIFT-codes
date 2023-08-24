function [SWIFT,SIG] = reprocess_SIG(missiondir,savedir,varargin)

% Reprocess SWIFT v4 signature velocities from burst data
%   Loops through burst MAT or DAT files for a given SWIFT deployment,
%   reprocessing signature data: 1) quality control the data, 2) compute
%   mean profiles of velocity, 3) compute dissipation from the HR beam 4)
%   replace signature data in original SWIFT structure with new values 5)
%   save detailed signature data in a separate SIG structure

%      J. Thomson, Sept 2017 (modified from AQH reprocessing)
%       7/2018, fix bug in the burst time stamp applied 4/2019, apply
%       altimeter results to trim profiles
%               and plot echograms, with vertical velocities
%       12/2019 add option for spectral dissipation,
%               with screening for too much rotational variance
%       Sep 2020 corrected bug in advective velocity applied to spectra Nov
%       2021 clean up and add more plotting for burst, avg, and echo Feb
%       2022 (K. Zeiden)
%         1. Cleaned up vestigial code (for readability) 2. New
%         out-of-water flag based on step functions in temp + press 3.
%         Method for flagging fish based on PDFs of amplitude and
%         correlation 4. Identify bad pings + bad bins, but only QC using
%         bad pings, bad bins + fish.
%               Include flag for bad bins in SWIFT structure for user
%               choice.
%         5. Include variance as well as average E+N profiles (similar to
%         w). 6. Toggle figure creation + saving. 7. Modular directories.
%       Jul 2022 (K. Zeiden)
%         1. Plots all SWIFT burst average velocity data after processing
%         is completed 2. Saves standard error (sigma_U/sqrt(N)) 3. No
%         longer saves QC flags -- user can evaluate based on standard
%         error after QC. 4. Switch to a QC toggle: user can use standard
%         amp & corr to remove bad pings + bad bins, and/or individual
%         data, and/or fish. Gives warning if standard error is increased
%         by applying the QC.
%       Aug 2022(K. Zeiden)
%            1. Add toggle to save new SWIFT structure or not
%            2. Removed any "continue" statements
%               -> might want burst plots for post-mortem even if data is bad
%            3. Variables have been renamed (for typing efficiency mostly,
%                   and seem more inutitive)
%            4. Added test to see if QC reduced the standard error. If not,
%                   relace with non-qc values
%            5. Add toggle to also/istead save burst-averaged signature data
%                   in a separate structure with analagous format to SWIFT structure
%                   (SIG structure, see catSIG as well for plotting the structure)
%                   motivated by missing data in SWIFT structure due to no timestamp match)
%            6. Add maximum velocity error to flag bad bursts (i.e. out of water)
%            7. Added toggle to save burst-averaged amp, corr & gyro
%       Sep 2022 (K. Zeiden)
%           1. updated dissipation estimate with new structure function
%                   methodology
%       Jan 2023 (K. Zeiden)
%           1. updated QC to de-spike HR velocity always, still optional to
%                   remove entire bad pings and bins
%           2. separated QC of bad pings and bad bins -- can remove entire
%                   bad pings and still get an averge, but bad bins removes entire
%                   average. Better to leave to post-processing
%           3. Remove amplitude thresholds -- amp has arbitrary bias. Amp
%                   still used in fish detection, b/c that is based on distribution
%                   of amplitude values in a burst.
%       Feb 2023 (K. Zeiden)
%           1. Re-added readSWIFTv4_SIG w/option to read-in raw burst files
%           2. Fixed NaN-ing out of dissipation estimates (was flagging
%           good bins as bad)
%       Mar 2023 (K. Zeiden)
%           1. Completely gut signature field after loading existing SWIFT
%           structure and replace w/ NaN structures. This prevents
%           vestigial signature fields which are not time matched with
%           burst files found
%           2. Remove velocity variance out-of-water flag -- doesn't work
%           well in high-seas. Correlation & Amplitude more reliable.
%           3. Simplified identification of bad bursts. Threshold applied to burst & bin-avg
%           values, and no longer lumping all flags into 'out-of-water'.
%           Single flag for 'badburst' for SWIFT structure culling, but
%           keep the other flags separate for SIG structure QC fields.
%       Jul 2023 (J. Thomson)
%           improve cross-platform usage with ispc binary calls
%       Aug 2023 (K. Zeiden)
%           simplify directory usage,convert reprocess_SIG to
%           function where mission directories are inputs
%           removed spectral estimate of dissipation rate, as is debunked

% NOTE: Known issue -- sometimes the ADCP 'sputters' and for a few minutes
% will record perfectly periodic ping-ping oscillations in correlation,
% amplitude and velocity before suddenly logging real data again. E.g.
% SWIFT 22, Mar 29 during LC-DRI Experiment. So far these periods elude QC
% traps due to the periodic oscillations which make the mean value
% reasonable. So far only known to have happened on SWIFT 22, LC-DRI Exp.

%% Load/Save/Plot Toggles

%Default
opt.readraw = false;% read raw binary files
opt.saveSWIFT = false;% save updated SWIFT structure
opt.saveSIG = false; %save detailed sig data in separate SIG structure
opt.plotburst = false; % generate plots for each burst
opt.plotmission = false; % generate summary plot for mission
opt.saveplots = false; % save generated plots

% Compare with varargin
togvars = fieldnames(opt);
if length(varargin) >= 1
    for ivar = 1:length(varargin)
        if any(strcmp(varargin{ivar},togvars))
            opt.(varargin{ivar}) = true;
        else
            error(['Input toggle ''' varargin{ivar} ''' is not an option'])
        end
    end
end

%% QC Toggles (broadband)

opt.QCcorr = false;% (NOT recommended) standard, QC removes any data below 'mincorr'
opt.QCbin = false;% QC entire bins with greater than pbadmax perecent bad correlation
opt.QCping = false; % QC entire ping with greater than pbadmax percent bad correlation
opt.QCfish = true;% detects fish from highly skewed amplitude distributions in a depth bin
opt.QCalt = false; % trim data based on altimeter

%% Processing parameters
% Config Parameters
opt.xz = 0.2; % depth of transducer [m]

% QC Parameters
opt.mincorr = 40; % burst-avg correlation minimum
opt.maxamp = 150; % burst-avg amplitude maximum
opt.maxwvar = 0.2; % burst-avg HR velocity (percent) error maximum
opt.pbadmax = 80; % maximum percent 'bad' amp/corr/err values per bin or ping allowed
opt.nsumeof = 5;% Number of lowest-mode EOFs to remove from turbulent velocity

% Data type
if opt.readraw
    ftype = '.dat';
else
    ftype = '.mat';
end

%% Ensure input directories end with slash
if ispc
    slash = '\';
else
    slash = '/';
end

if ~strcmp(missiondir(end),slash)
    missiondir = [missiondir slash];
end
if ~strcmp(savedir(end),slash)
    savedir = [savedir slash];
end

dirdelim = strfind(missiondir,slash);
SNprocess = missiondir(dirdelim(end-1)+1:dirdelim(end)-1);
disp(['*** Reprocessing ' SNprocess ' ***'])

%% Load or create SWIFT structure, create SIG structure, list burst files
clear SWIFT SIG

mfiles = dir([missiondir 'SWIFT*.mat']);
if isempty(mfiles)
    disp('No SWIFT structure found...')
    SWIFT = struct;
else
    if length(mfiles) > 1
        if any(contains({mfiles.name},'reprocessedSBG.mat'))
            mfile = mfiles(contains({mfiles.name},'reprocessedSBG.mat'));  % this might vary
        elseif any(contains({mfiles.name},'reprocessedSIGandSBG.mat'))
            mfile = mfiles(contains({mfiles.name},'reprocessedSIGandSBG.mat'));  % this might vary
        else
            mfile = mfiles(1);
        end
    else
        mfile = mfiles;
    end
    load([mfile.folder slash mfile.name],'SWIFT')
    burstreplaced = false(length(SWIFT),1);
end
SIG = struct;
isig = 1;

% Populate list of burst files, favor 'partial' burst files
bfiles = dir([missiondir 'SIG' slash 'Raw' slash '*' slash '*' ftype]);
if isempty(bfiles)
    error('   No burst files found    ')
end
bfiles = bfiles(~contains({bfiles.name},'smoothwHR'));
ipart = contains({bfiles.name},'partial');
bfiles(find(ipart)-1) = [];
nburst = length(bfiles);

%% Loop through and process burst files

for iburst = 1:nburst

    % Burst time stamp and name
    day = bfiles(iburst).name(13:21);
    hour = bfiles(iburst).name(23:24);
    mint = bfiles(iburst).name(26:27);
    btime = datenum(day)+datenum(0,0,0,str2double(hour),(str2double(mint)-1)*12,0);
    bname = bfiles(iburst).name(1:end-4);
    disp(['Burst ' num2str(iburst) ' : ' bname])

    % Load burst file
    if opt.readraw
       [burst,avg,battery,echo] = readSWIFTv4_SIG([bfiles(iburst).folder slash bfiles(iburst).name]);
    else
        load([bfiles(iburst).folder slash bfiles(iburst).name])
    end
    
    % Skip burst if empty
    if isempty(avg)
        disp('Failed to read, skipping burst...')
        continue
    end
    
    %%%%%%% FLAGS %%%%%%

    % Flag if file is too small
    if bfiles(iburst).bytes < 1e6 % 2e6,
        disp('   FLAG: Bad file (small)...')
        smallfile = true;
    else
        smallfile = false;
    end

    % Flag if coming in/out of the water
    if any(ischange(burst.Pressure)) && any(ischange(burst.Temperature))
        disp('   FLAG: Out-of-Water (temp/pressure change)...')
        outofwater = true;
    else
        outofwater = false;
    end

    % Flag out of water based on bursts w/anomalously high amp
    if mean(burst.AmplitudeData(:),'omitnan') > opt.maxamp
        disp('   FLAG: Bad Amp (high average amp)...')
        badamp = true;
    else
        badamp = false;
    end

    % Flag out of water based on bursts w/low cor
    if mean(burst.CorrelationData(:),'omitnan') < opt.mincorr
        disp('   FLAG: Bad Corr (low average corr)...')
        badcorr = true;
    else
        badcorr = false;
    end

    % Flag out of water based on bursts with high velocity variance
    if  mean(std(burst.VelocityData,[],2,'omitnan')) > opt.maxwvar
        disp('   FLAG: Bad Vel (high along-beam variance)...')
        badvel = true;
    else
        badvel = false;
    end

    % Determine Altimeter Distance
    if isfield(avg,'AltimeterDistance')
        maxz = median(avg.AltimeterDistance);
    else
        maxz = inf;
    end

    badburst = smallfile | outofwater | badamp | badcorr | badvel;

%     %%%%%%% Process Broadband velocity data ('avg' structure) %%%%%%

      [profile,fh] = processSIGavg(avg,opt);
      
        if opt.saveplots && ~isempty(fh)
            figure(fh(1))
            set(gcf,'Name',[bname '_bband_data'])
            figname = [savedir SNprocess slash get(gcf,'Name')];
            print(figname,'-dpng')
            close gcf
            
            figure(fh(2))
            set(gcf,'Name',[bname '_bband_profiles'])
            figname = [savedir SNprocess slash get(gcf,'Name')];
            print(figname,'-dpng')
            close gcf
        end


    %%%%%%% Process HR velocity data ('burst' structure) %%%%%%
    
    if length(size(burst.VelocityData)) > 2
        badburst = 1;
        disp('Bad HR Data...')
        hrw = NaN(size(SIG(end).HRprofile.w));
        hrwvar = NaN(size(SIG(end).HRprofile.w));
        hrz = SIG(end).HRprofile.z;
        eps_struct0 = NaN(size(SIG(end).HRprofile.eps_struct0));
        eps_structHP = NaN(size(SIG(end).HRprofile.eps_struct0));
        eps_structEOF = NaN(size(SIG(end).HRprofile.eps_struct0));
    else

        % HR Data
        hrtime = burst.time;
        hrcorr = burst.CorrelationData';
        hramp = burst.AmplitudeData';
        hrvel = -burst.VelocityData';

        % N pings + N z-bins
        [nbin,nping] = size(hrvel);
        dz = burst.CellSize;
        bz = burst.Blanking;
        hrz = opt.xz + bz + dz*(1:nbin);
        dt = ( max(hrtime) - min(hrtime) ) ./nping*24*3600; %range(hrtime)./nping*24*3600;

        % QC: Find spikes w/phase-shift threshold (Shcherbina 2018)
        L = bz+dz*nbin; % m
        F0 = 10^6; % Hz, pulse carrier frequency (1 MHz for Sig 1000)
        cs = mean(burst.SoundSpeed,'omitnan'); % m/s
        Vr = cs.^2./(4*F0*L);% m/s
        nfilt = round(1/dz);% 1 m
        [wclean,ispike] = despikeSIG(hrvel,nfilt,Vr/2,'interp');

        % Spatial High-pass and flag bad pings w/too high variance
        nsm = round(2/dz); % 1 m
        wphp = wclean - smooth_mat(wclean',hann(nsm))';
        badping = sum(ispike)./nbin > 0.5 | std(wphp,[],'omitnan') > 0.01;

        % QC & Calculate Mean Velocity + SE
        hrw = nanmean(wclean,2);
        hrwvar = var(wclean,[],2,'omitnan');

        % Plot beam data and QC info
        if opt.plotburst
            clear c
            figure('color','w','Name',[bname '_hr_data'])
            MP = get(0,'monitorposition');
            set(gcf,'outerposition',MP(1,:).*[1 1 1 1]);
            subplot(4,1,1)
            imagesc(hramp)
            caxis([50 160]); cmocean('amp')
            title('HR Data');
            ylabel('Bin #')
            c = colorbar;c.Label.String = 'A (dB)';
            subplot(4,1,2)
            imagesc(hrcorr)
            caxis([opt.mincorr-5 100]);cmocean('amp')
            ylabel('Bin #')
            c = colorbar;c.Label.String = 'C (%)';
            subplot(4,1,3)
            imagesc(hrvel)
            caxis([-0.5 0.5]);cmocean('balance');
            ylabel('Bin #')
            c = colorbar;c.Label.String = 'U_r(m/s)';
            subplot(4,1,4)
            imagesc(ispike)
            caxis([0 2]);colormap(gca,[rgb('white'); rgb('black')])
            ylabel('Bin #')
            c = colorbar;c.Ticks = [0.5 1.5];
            c.TickLabels = {'Good','Spike'};
            xlabel('Ping #')
            drawnow
            if opt.saveplots
                figname = [savedir SNprocess slash get(gcf,'Name')];
                print(figname,'-dpng')
                close gcf
            end
        end

        %%%%%% Dissipation Estimates %%%%%%

        % Sampling rate and window size
        fs = 1/dt; nwin = 64;
        if nwin > nping
            nwin = nping;
        end

        % Skip dissipation estimates if bad-burst
        if badburst  ||  sum(badping)/nping > 0.90
            disp('   Skipping dissipation...')
            eps_struct0 = NaN(size(hrw));
            eps_structHP = NaN(size(hrw));
            eps_structEOF = NaN(size(hrw));
            qual0.mspe = NaN(size(hrw));
            qual0.slope = NaN(size(hrw));
            qual0.epserr = NaN(size(hrw));
            qual0.A = NaN(size(hrw));
            qual0.B = NaN(size(hrw));
            qual0.N = NaN(size(hrw));
            qualHP.mspe = NaN(size(hrw));
            qualHP.slope = NaN(size(hrw));
            qualHP.epserr = NaN(size(hrw));
            qualHP.A = NaN(size(hrw));
            qualHP.B = NaN(size(hrw));
            qualHP.N = NaN(size(hrw));
            qualEOF.mspe = NaN(size(hrw));
            qualEOF.slope = NaN(size(hrw));
            qualEOF.epserr = NaN(size(hrw));
            qualEOF.A = NaN(size(hrw));
            qualEOF.B = NaN(size(hrw));
            qualEOF.N = NaN(size(hrw));
            wpsd = NaN(nbin,2*nwin+1);
            bobpsd = NaN(1,2*nwin+1);
            f = NaN(1,2*nwin+1);
        else

            %EOF High-pass
            eof_amp = NaN(nping,nbin);
            [eofs,eof_amp(~badping,:),~,~] = eof(wclean(:,~badping)');
            for ieof = 1:nbin
                eof_amp(:,ieof) = interp1(find(~badping),eof_amp(~badping,ieof),1:nping);
            end
            wpeof = eofs(:,opt.nsumeof+1:end)*(eof_amp(:,opt.nsumeof+1:end)');

            %Structure Function Dissipation
            rmin = dz;
            rmax = 4*dz;
            nzfit = 1;
            w = wclean;
            wp1 = wpeof;
            wp2 = wphp;
            ibad = repmat(badping,nbin,1) | ispike;
            w(ibad) = NaN;
            wp1(ibad) = NaN;
            wp2(ibad) = NaN;
            warning('off','all')
            [eps_struct0,qual0] = SFdissipation(w,hrz,rmin,2*rmax,nzfit,'cubic','mean');
            [eps_structEOF,qualEOF] = SFdissipation(wp1,hrz,rmin,rmax,nzfit,'linear','mean');
            [eps_structHP,qualHP] = SFdissipation(wp2,hrz,rmin,rmax,nzfit,'linear','mean');
            warning('on','all')

            % Motion spectra (bobbing)
            [bobpsd,f] = pwelch(detrend(gradient(burst.Pressure,dt)),nwin,[],[],fs);
            wpsd = NaN(nbin,nwin*2+1);
            for ibin = 1:nbin
                iw = w(ibin,:);
                iNaN = isnan(iw);
                if sum(iNaN) > 0.9*nping % skip if more than 90% NaN
                    continue
                else
                    iw(iNaN) = mean(iw,'omitnan'); % Replace NaN w/mean
                    [wpsd(ibin,:),f] = pwelch(detrend(iw),nwin,[],[],fs);
                end
            end

            if opt.plotburst
                clear b s
                figure('color','w','Name',[bname '_wspectra_eps'])
                MP = get(0,'monitorposition');
                set(gcf,'outerposition',MP(1,:).*[1 1 1 1]);
                subplot(1,4,[1 2])
                cmap = colormap;
                for ibin = 1:nbin
                    cind = round(size(cmap,1)*ibin/nbin);
                    l1 = loglog(f,wpsd(ibin,:),'color',cmap(cind,:),'LineWidth',1.5);
                    hold on
                end
                l2 = loglog(f,bobpsd,'LineWidth',2,'color',rgb('grey'));
                xlabel('Frequency [Hz]')
                ylabel('TKE [m^2/s^2/Hz]')
                title('HR Spectra')
                c = colorbar;
                c.Label.String = 'Bin #';
                c.TickLabels = num2str(round(c.Ticks'.*nbin));
                legend([l1 l2],'S_{w}','S_{bob}','Location','northwest')
                ylim(10.^[-6 0.8])
                xlim([10^-0.5 max(f)])
                subplot(1,4,3)
                b(1) = errorbar(hrw,hrz,sqrt(hrwvar)./nping,'horizontal');
                hold on
                b(2) = errorbar(avgw,avgz,sqrt(avgwvar)./nping,'horizontal');
                set(b,'LineWidth',2)
                plot([0 0],[0 20],'k--')
                xlabel('w [m/s]');
                title('Velocity')
                set(gca,'Ydir','reverse')
                legend(b,'HR','Broadband','Location','southeast')
                ylim([0 6])
                xlim([-0.075 0.075])
                set(gca,'YAxisLocation','right')
                subplot(1,4,4)
                s(1) = semilogx(eps_structEOF,hrz,'r','LineWidth',2);
                hold on
                s(2) =  semilogx(eps_structHP,hrz,':r','LineWidth',2);
                s(3) = semilogx(eps_struct0,hrz,'color',rgb('grey'),'LineWidth',2);
                xlim(10.^([-9 -3]))
                ylim([0 6])
                legend(s,'SF','SF (high-pass)','SF (modified)','Location','southeast')
                title('Dissipation')
                xlabel('\epsilon [W/Kg]'),ylabel('z [m]')
                set(gca,'Ydir','reverse')
                set(gca,'YAxisLocation','right')
                drawnow
                if opt.saveplots
                    figname = [savedir SNprocess slash get(gcf,'Name')];
                    print(figname,'-dpng')
                    close gcf
                end
            end
        end
    end

    %%%%%%%% Save processed signature data in seperate structure %%%%%%%%

    %Time
    SIG(isig).time = btime;
    %Temperaure
    SIG(isig).watertemp = profile.temp;
    % HR data
    SIG(isig).HRprofile.w = hrw;
    SIG(isig).HRprofile.wvar = hrwvar;
    SIG(isig).HRprofile.z = hrz';
    SIG(isig).HRprofile.eps_struct0 = eps_struct0';
    SIG(isig).HRprofile.eps_structHP = eps_structHP';
    SIG(isig).HRprofile.eps_structEOF = eps_structEOF';
    SIG(isig).HRprofile.QC.hrcorr = mean(hrcorr,2,'omitnan')';
    SIG(isig).HRprofile.QC.hramp = mean(hramp,2,'omitnan')';
    SIG(isig).HRprofile.QC.mspe0 = qual0.mspe;
    SIG(isig).HRprofile.QC.mspeHP = qualHP.mspe;
    SIG(isig).HRprofile.QC.mspeEOF = qualEOF.mspe;
    SIG(isig).HRprofile.QC.slope0 = qual0.slope;
    SIG(isig).HRprofile.QC.slopeHP = qualHP.slope;
    SIG(isig).HRprofile.QC.slopeEOF = qualEOF.slope;
    SIG(isig).HRprofile.QC.epserr0 = qual0.epserr;
    SIG(isig).HRprofile.QC.epserrHP = qualHP.epserr;
    SIG(isig).HRprofile.QC.epserrEOF = qualEOF.epserr;       
    SIG(isig).HRprofile.QC.N0 = qual0.N;
    SIG(isig).HRprofile.QC.NHP = qualHP.N;
    SIG(isig).HRprofile.QC.NEOF = qualEOF.N;    
    SIG(isig).HRprofile.QC.pspike = sum(ispike,2,'omitnan')./nping;
    % Broadband data
    SIG(isig).profile.u = profile.avgu;
    SIG(isig).profile.v = profile.avgv;
    SIG(isig).profile.w = profile.avgw;
    SIG(isig).profile.uvar = profile.avguvar;
    SIG(isig).profile.vvar = profile.avgvvar;
    SIG(isig).profile.wvar = profile.avgwvar;
    SIG(isig).profile.z = profile.avgz;
    SIG(isig).profile.QC.ucorr = profile.ucorr;
    SIG(isig).profile.QC.wcorr = profile.vcorr;
    SIG(isig).profile.QC.vcorr = profile.wcorr;
    SIG(isig).profile.QC.uamp = profile.uamp;
    SIG(isig).profile.QC.vamp = profile.vamp;
    SIG(isig).profile.QC.wamp = profile.wamp;
    % Motion
    SIG(isig).motion.pitch = mean(avg.Pitch,'omitnan');
    SIG(isig).motion.roll = mean(avg.Roll,'omitnan');
    SIG(isig).motion.head = mean(avg.Heading,'omitnan');
    SIG(isig).motion.pitchvar = var(avg.Pitch,'omitnan');
    SIG(isig).motion.rollvar = var(avg.Roll,'omitnan');
    SIG(isig).motion.headvar = var(unwrap(avg.Heading),'omitnan');
    SIG(isig).motion.wpsd = wpsd;
    SIG(isig).motion.bobpsd = bobpsd;
    SIG(isig).motion.f = f;
    % Badburst & flags
    SIG(isig).badburst = badburst;
    SIG(isig).flag.altimeter = maxz;
    SIG(isig).flag.smallfile = smallfile;
    SIG(isig).flag.outofwater = outofwater;
    SIG(isig).flag.badamp = badamp;
    SIG(isig).flag.badcorr = badcorr;
    SIG(isig).flag.badvel = badvel;

    isig = isig+1;

   %%%%%%%% Match burst time to existing SWIFT fields and replace data %%%%%%%%

   if ~isempty(fieldnames(SWIFT)) && ~isempty(SWIFT)

        [tdiff,tindex] = min(abs([SWIFT.time]-btime));
        if tdiff > 1/(24*10) % must be within 15 min
            disp('   NO time index match...')
            timematch = false;
        elseif tdiff < 1/(24*10)
            timematch = true;
            burstreplaced(tindex) = true;
        elseif isempty(tdiff)
            disp('   NO time index match...')
            timematch = false;
        end

        if  timematch && ~badburst % Good burst & time match
            % HR data
            SWIFT(tindex).signature.HRprofile = [];
            SWIFT(tindex).signature.HRprofile.w = hrw;
            SWIFT(tindex).signature.HRprofile.wvar = hrwvar;
            SWIFT(tindex).signature.HRprofile.z = hrz';
            SWIFT(tindex).signature.HRprofile.tkedissipationrate = eps_structEOF';
            % Broadband data
            SWIFT(tindex).signature.profile = [];
            SWIFT(tindex).signature.profile.east = profile.avgu;
            SWIFT(tindex).signature.profile.north = profile.avgv;
            SWIFT(tindex).signature.profile.w = profile.avgw;
            SWIFT(tindex).signature.profile.uvar = profile.avguvar;
            SWIFT(tindex).signature.profile.vvar = profile.avgvvar;
            SWIFT(tindex).signature.profile.wvar = profile.avgwvar;
            SWIFT(tindex).signature.profile.z = profile.avgz;
            % Altimeter & Out-of-Water Flag
            SWIFT(tindex).signature.altimeter = maxz;
            % Temperaure
            SWIFT(tindex).watertemp = profile.temp;

        elseif timematch && badburst % Bad burst & time match
            % HR data
            SWIFT(tindex).signature.HRprofile = [];
            SWIFT(tindex).signature.HRprofile.w = NaN(size(hrw));
            SWIFT(tindex).signature.HRprofile.wvar = NaN(size(hrw));
            SWIFT(tindex).signature.HRprofile.z = hrz;
            SWIFT(tindex).signature.HRprofile.tkedissipationrate = NaN(size(eps_structEOF'));
            % Broadband data
            SWIFT(tindex).signature.profile = [];
            SWIFT(tindex).signature.profile.w = NaN(size(profile.avgu));
            SWIFT(tindex).signature.profile.east = NaN(size(profile.avgu));
            SWIFT(tindex).signature.profile.north = NaN(size(profile.avgu));
            SWIFT(tindex).signature.profile.uvar = NaN(size(profile.avgu));
            SWIFT(tindex).signature.profile.vvar = NaN(size(profile.avgu));
            SWIFT(tindex).signature.profile.wvar = NaN(size(profile.avgu));
            SWIFT(tindex).signature.profile.z = profile.avgz;
        elseif ~timematch && ~badburst % Good burst, no time match
            disp('   ALERT: Burst good, but no time match...')
            tindex = length(SWIFT)+1;
            burstreplaced = [burstreplaced; true];
            varcopy = fieldnames(SWIFT);
            varcopy = varcopy(~strcmp(varcopy,'signature'));
            for icopy = 1:length(varcopy)
                if isa(SWIFT(1).(varcopy{icopy}),'double')
                    SWIFT(tindex).(varcopy{icopy}) = NaN;
                elseif isa(SWIFT(1).(varcopy{icopy}),'struct')
                    varcopy2 = fieldnames(SWIFT(1).(varcopy{icopy}));
                    for icopy2 = 1:length(varcopy2)
                        varsize = size(SWIFT(1).(varcopy{icopy}).(varcopy2{icopy2}));
                        SWIFT(tindex).(varcopy{icopy}).(varcopy2{icopy2}) = NaN(varsize);
                    end
                end
            end
            % HR data
            SWIFT(tindex).signature.HRprofile = [];
            SWIFT(tindex).signature.HRprofile.w = hrw;
            SWIFT(tindex).signature.HRprofile.wvar = hrwvar;
            SWIFT(tindex).signature.HRprofile.z = hrz;
            SWIFT(tindex).signature.HRprofile.tkedissipationrate = eps_structEOF';
            % Broadband data
            SWIFT(tindex).signature.profile = [];
            SWIFT(tindex).signature.profile.east = profile.avgu;
            SWIFT(tindex).signature.profile.north = profile.avgv;
            SWIFT(tindex).signature.profile.w = profile.avgw;
            SWIFT(tindex).signature.profile.uvar = profile.avguvar;
            SWIFT(tindex).signature.profile.vvar = profile.avgvvar;
            SWIFT(tindex).signature.profile.wvar = profile.avgwvar;
            SWIFT(tindex).signature.profile.z = profile.avgz;
            % Altimeter
            SWIFT(tindex).signature.altimeter = maxz;
            % Temperaure
            SWIFT(tindex).watertemp = profile.temp;
            % Time
            SWIFT(tindex).time = btime;
            disp(['   Burst time: ' datestr(btime)])
            disp(['   (new) SWIFT time: ' datestr(SWIFT(tindex).time)])
        end
    end

% End burst loop
end

%% Clean up and save

% NaN out SWIFT sig fields which were not matched to bursts
if ~isempty(fieldnames(SWIFT))
    inan = find(~burstreplaced);
    if ~isempty(inan)
        for it = inan'
            % HR data
            SWIFT(it).signature.HRprofile = [];
            SWIFT(it).signature.HRprofile.w = NaN(size(hrw));
            SWIFT(it).signature.HRprofile.wvar = NaN(size(hrw));
            SWIFT(it).signature.HRprofile.z = hrz;
            SWIFT(it).signature.HRprofile.tkedissipationrate = NaN(size(eps_structEOF'));
            % Broadband data
            SWIFT(it).signature.profile = [];
            SWIFT(it).signature.profile.w = NaN(size(profile.avgu));
            SWIFT(it).signature.profile.east = NaN(size(profile.avgu));
            SWIFT(it).signature.profile.north = NaN(size(profile.avgu));
            SWIFT(it).signature.profile.uvar = NaN(size(profile.avgu));
            SWIFT(it).signature.profile.vvar = NaN(size(profile.avgu));
            SWIFT(it).signature.profile.wvar = NaN(size(profile.avgu));
            SWIFT(it).signature.profile.z = profile.avgz;
        end
    end
end

% Sort by time
if ~isempty(fieldnames(SWIFT)) && isfield(SWIFT,'time')
[~,isort] = sort([SWIFT.time]);
SWIFT = SWIFT(isort);
end

%%%%%% Plot burst Averaged SWIFT Signature Data %%%%%%
if opt.plotmission
    catSIG(SIG,'plot','qc');
    set(gcf,'Name',SNprocess)
    if opt.saveplots
        figname = [savedir get(gcf,'Name')];
        print(figname,'-dpng')
        close gcf
    end
end

%%%%%% Save SWIFT Structure %%%%%%%%
if opt.saveSWIFT && ~isempty(fieldnames(SWIFT)) && isfield(SWIFT,'time')
    if strcmp(mfile.name(end-6:end-4),'SBG')
        save([savedir SNprocess '_reprocessedSIGandSBG.mat'],'SWIFT')
    else
        save([savedir SNprocess '_reprocessedSIG.mat'],'SWIFT')
    end
end

%%%%%% Save SIG Structure %%%%%%%%
if opt.saveSIG
   save([savedir SNprocess '_burstavgSIG.mat'],'SIG')
end


cd(savedir)

end