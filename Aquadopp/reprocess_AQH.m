%% Reprocess SWIFT v4 Aquadopp velocities from burst data
%   Loops through burst MAT or DAT files for a given SWIFT deployment,
%   reprocessing AQH data: 1) quality control the data, 2) compute
%   mean profiles of velocity, 3) compute dissipation from the HR beam 4)
%   replace AQH data in original SWIFT structure with new values 5)
%   save detailed signature data in a separate SIG structure

%   K. Zeiden 07/2023 - Completely new reprocessing based on reprocess_SIG   
%       Still need to do significant work on QC process, identifying
%           out-of-water bursts etc. Right now not doing any of that.
%       Both EOF + Low-pass used to isolate turbulence, but it seems like
%           the EOF method isn't working very well due to the low N (16 bins
%           vs. 128 bins for Sig1000). Low-pass does well b/c the shear is
%           moderate?

%% User Defined Inputs

% JIM - MAC
% % Directory with existing SWIFT structures (e.g. from telemetry)
% swiftdir = './';
% % Directory with signature burst files 
% burstdir = './';% 
% % Directory to save updated/new SWIFT/SIG structures (see toggle 'saveSWIFT')
% saveswiftdir = [ swiftstructdir ];
% savesigdir = [ swiftstructdir ];
% % Directory to save figures (will create folder for each mission if doesn't already exist)
% savefigdir = './';

% KRISTIN - PC
% Directory with existing SWIFT structures (e.g. from telemetry)
swiftdir = 'S:\LC-DRI\';
% Directory with signature burst files 
burstdir = 'S:\LC-DRI\';
% Directory to save updated/new SWIFT/SIG structures (see toggle 'saveSWIFT')
saveswiftdir = 'C:\Users\kfitz\Dropbox\MATLAB\LC-DRI\Data\SWIFT\L2\V3\neof5\reprocessAQH\';
savesigdir = 'C:\Users\kfitz\Dropbox\MATLAB\LC-DRI\Data\SWIFT\L2\V3\neof5\reprocessAQH\AQH\';
% Directory to save figures (will create folder for each mission if doesn't already exist)
savefigdir = 'C:\Users\kfitz\Dropbox\MATLAB\LC-DRI\Figures\AQH';

%Data Load/Save Toggles
readraw = true;% read raw binary files
saveSWIFT = true;% save updated SWIFT structure
saveAQH = true; %save detailed sig data in separate SIG structure

% Plotting Toggles
plotburst = false; % generate plots for each burst
plotmission = true; % generate summary plot for mission
saveplots = false; % save generated plots
MP = get(0,'monitorposition');

% AQH Config
xcdrdepth = 0.8; % depth of transducer [m]
dz = 0.04; % cell size
bz = 0.1; % blanking distance
dt = 1/4; % seconds

% User defined QC parameters
nsumeof = 3;% Number of lowest-mode EOFs to remove from turbulent velocity

%Populate list of SWIFT missions to re-process
cd(burstdir)
swifts = dir('SWIFT1*');
swifts = {swifts.name};
nswift = length(swifts);

clear SWIFT AQH
badburst = false;

%% Loop through SWIFT missions
% For each mission, loop through burst files and process the data

for iswift = [1:3 6:nswift]

    SNprocess = swifts{iswift}; 
    disp(['********** Reprocessing ' SNprocess ' **********'])

    % Create SIG structure for detailed signature data results
    AQH = struct;
    isig = 1;

    % Load pre-existing mission mat file with SWIFT structure 
    structfile = dir([swiftdir SNprocess '\' SNprocess(1:6) '*.mat']);
    if length(structfile) > 1
        structfile = structfile(contains({structfile.name},'reprocessedIMU.mat'));
    end 
    if isempty(structfile)
        disp('No SWIFT structure found...')
        SWIFT = struct;
    else
            load([structfile.folder '\' structfile.name])
            % Prepare flag vector for replaced burst data
            burstreplaced = false(length(SWIFT),1);
    end

    % Populate list of burst files
    if readraw
        ftype = '.dat';
    else
            ftype = '.mat';
    end
    if ispc
        fpath = '\AQH\Raw\*\*';
    else
            fpath = '/AQH/Raw/*/*';
    end
    bfiles = dir([burstdir SNprocess fpath ftype]);
    if isempty(bfiles)
        disp('   No burst files found, skipping SWIFT...')
        continue
    end
    nburst = length(bfiles);
    
    % Loop through and process burst files
    for iburst = 1:nburst
        
        % Burst time stamp
        day = bfiles(iburst).name(13:21);
        hour = bfiles(iburst).name(23:24);
        mint = bfiles(iburst).name(26:27);
        btime = datenum(day)+datenum(0,0,0,str2double(hour),(str2double(mint)-1)*12,0);
        bname = bfiles(iburst).name(1:end-4);
        disp(['Burst ' num2str(iburst) ' : ' bname])

        % Load burst file
        if readraw
            disp('Reading raw AQH file...')
            [~,vel,amp,corr,press,pitch,roll,heading] = ...
                readSWIFTv3_AQH([bfiles(iburst).folder '\' bfiles(iburst).name]);
        else
            load([bfiles(iburst).folder '\' bfiles(iburst).name],...
                'Vel','Cor','Amp','Pressure','pitch','roll','heading')
            vel = Vel;
            corr = Cor;
            amp = Amp;
            press = Pressure';
        end

        % Skip burst if empty
        if isempty(vel)
            disp('Failed to read, skipping burst...')
            continue
        end

        % HR Data
        hrcorr = corr';
        hramp = amp';
        hrvel = -vel';
        clear corr amp vel

        % N pings + N z-bins 
        [nbin,nping] = size(hrvel);
        hrz = xcdrdepth - bz - dz*(1:nbin);
        hrtime = (0:nping)*dt;
        
        %%%%% QC %%%%%
        
        % Low correlation
        corrmin = 50;
        ilowcorr = hrcorr < corrmin;

        % Too high velocity
        nsm = round(0.5/dz); % 0.25 m
        wlp = smooth_mat(hrvel',hann(nsm))';
        wphp = hrvel - wlp; 
        wstd = std(wphp(~ilowcorr));
        ispike = abs(wphp) > 3*wstd;
        
        % Bad pts
        ibad = ispike | ilowcorr;
        badping = sum(ibad)/nbin > 0.5;
 
        % EOF High-pass
        nsumeof = 3;
        [eofs,eof_amp,~,~] = eof(hrvel');
        weof = eofs(:,1:nsumeof)*(eof_amp(:,1:nsumeof)');
        wpeof = eofs(:,nsumeof+1:end)*(eof_amp(:,nsumeof+1:end)');

        % Plot beam data and QC info
        if plotburst
            clear c
            figure('color','w','Name',[bname '_hr_data'])
            set(gcf,'outerposition',MP(1,:).*[1 1 1 1]);
            subplot(5,1,1)
            imagesc(hramp)
            caxis([60 160]); cmocean('thermal')
            title('HR Data');
            ylabel('Bin #')
            c = colorbar;c.Label.String = 'A (dB)';
            subplot(5,1,2)
            imagesc(hrcorr)
            caxis([0 100]);colormap(gca,'jet')
            ylabel('Bin #')
            c = colorbar;c.Label.String = 'C (%)';
            subplot(5,1,3)
            plot(press,'k','LineWidth',1.5)
            axis tight
            ylabel('P [dB]')
            c = colorbar;c.Visible = 'off';
            subplot(5,1,4)
            imagesc(hrvel)
            caxis([-0.5 0.5]);cmocean('balance');
            ylabel('Bin #')
            c = colorbar;c.Label.String = 'U_r(m/s)';
            subplot(5,1,5)
            imagesc(ibad)
            caxis([0 2]);colormap(gca,[rgb('white'); rgb('black')])
            ylabel('Bin #')
            c = colorbar;c.Ticks = [0.5 1.5];
            c.TickLabels = {'Good','Bad'};
            xlabel('Ping #')
            
            drawnow
            set(get(gcf,'Children'),'YDir','Normal')
            if saveplots
                figname = [savefigdir SNprocess '\' get(gcf,'Name')];
                print(figname,'-dpng')
                close gcf
            end
        end
        
        %%%%%% Mean velocity profile + standard error %%%%%
  
        hrw = nanmean(wlp,2);
        hrwerr = nanstd(wlp,[],2)./sqrt(nping);

        %%%%%% Dissipation Estimates %%%%%%

        % Sampling rate and window size
        fs = 1/dt; nwin = 64;
        if nwin > nping
            nwin = nping;
        end

        % Skip dissipation estimates if bad-burst
        if sum(badping)/nping > 0.90
            disp('   Skipping dissipation...')
            eps_struct0 = NaN(size(hrw));
            eps_structHP = NaN(size(hrw));
            eps_structEOF = NaN(size(hrw));
            eps_spectral = NaN(size(hrw));
            mspe0 = NaN(size(hrw));
            mspeHP = NaN(size(hrw));
            mspeEOF = NaN(size(hrw));
            slope0 = NaN(size(hrw));
            slopeHP = NaN(size(hrw));
            slopeEOF = NaN(size(hrw));
            wpsd = NaN(nbin,2*nwin+1);
            bobpsd = NaN(1,2*nwin+1);
            f = NaN(1,2*nwin+1);
        else

            %Structure Function Dissipation
            rmin = dz;
            rmax = 4*dz;
            nzfit = 1;
            w = wlp;
            wp1 = wpeof;
            wp2 = wphp;
            w(ibad) = NaN;
            wp1(ibad) = NaN;
            wp2(ibad) = NaN;
            warning('off','all')
            % z = -hrz, for some reason. too tired
            [eps_struct0,~,fitcoeff0,qual0] = SFdissipation(w,-hrz,rmin,2*rmax,nzfit,'cubic','mean');
            [eps_structEOF,~,fitcoeffEOF,qualEOF] = SFdissipation(wp1,-hrz,rmin,rmax,nzfit,'linear','mean');
            [eps_structHP,~,fitcoefHP,qualHP] = SFdissipation(wp2,-hrz,rmin,rmax,nzfit,'linear','mean');
            warning('on','all')
            mspe0 = qual0.mspe;
            mspeHP = qualHP.mspe;
            mspeEOF = qualEOF.mspe;
            slope0 = qual0.slope;
            slopeHP = qualHP.slope;
            slopeEOF = qualEOF.slope;

            % Motion spectra (bobbing)
            [bobpsd,f] = pwelch(detrend(gradient(press,dt)),nwin,[],[],fs);
            for ibin = 1:nbin
            [wpsd(ibin,:),f] = pwelch(detrend(hrvel(ibin,:)),nwin,[],[],fs);
            end

            if plotburst
                clear b s
                figure('color','w','Name',[bname '_wspectra_eps'])
                set(gcf,'outerposition',MP(1,:).*[1 1 1 1]);
                subplot(1,4,[1 2])
                cmap = colormap;
                for ibin = 1:nbin
                    cind = round(size(cmap,1)*ibin/nbin);
                    l1 = loglog(f,wpsd(ibin,:),'color',cmap(cind,:),'LineWidth',1.5);
                    hold on
                end
                l2 = loglog(f,bobpsd,'LineWidth',2,'color',rgb('black'));
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
                b(1) = errorbar(hrw,hrz,hrwerr,'horizontal');
                hold on
                b(2) = errorbar(mean(hrvel,2,'omitnan'),hrz,std(hrvel,[],2,'omitnan')/nping,'horizontal');
                set(b,'LineWidth',2)
                plot([0 0],[0 1],'k--')
                xlabel('w [m/s]');
                title('Velocity')
                set(gca,'Ydir','reverse')
                legend(b,'HR','HR (no QC)','Location','southeast')
                ylim([0 1])
                xlim([-0.075 0.075])
                set(gca,'YAxisLocation','right')
                subplot(1,4,4)
                s(1) = semilogx(eps_structEOF,hrz,'r','LineWidth',2);
                hold on
                s(2) =  semilogx(eps_structHP,hrz,':r','LineWidth',2);
                s(3) = semilogx(eps_struct0,hrz,'color',rgb('grey'),'LineWidth',2);
                xlim(10.^([-9 -3]))
                ylim([0 1])
                legend(s,'SF (EOF)','SF (high-pass)','SF (modified)','Location','southeast')
                title('Dissipation')
                xlabel('\epsilon [W/Kg]'),ylabel('z [m]')
                set(gca,'Ydir','reverse')
                set(gca,'YAxisLocation','right')
                drawnow
                if saveplots
                    figname = [savefigdir SNprocess '\' get(gcf,'Name')];
                    print(figname,'-dpng')
                    close gcf
                end
            end
        end
        
        %%%%%%%% Save processed signature data in seperate structure %%%%%%%%

        % HR data
        AQH(isig).HRprofile.w = hrw;
        AQH(isig).HRprofile.werr = hrwerr;
        AQH(isig).HRprofile.z = hrz';
        AQH(isig).HRprofile.eps_struct0 = eps_struct0';
        AQH(isig).HRprofile.eps_structHP = eps_structHP';
        AQH(isig).HRprofile.eps_structEOF = eps_structEOF';
        %Time
        AQH(isig).time = btime;
        %QC Info
        AQH(isig).QC.hrcorr = mean(hrcorr,2,'omitnan')';
        AQH(isig).QC.hramp = mean(hramp,2,'omitnan')';
        AQH(isig).QC.pitch = mean(pitch,'omitnan');
        AQH(isig).QC.roll = mean(roll,'omitnan');
        AQH(isig).QC.head = mean(heading,'omitnan');
        AQH(isig).QC.pitchvar = var(pitch,'omitnan');
        AQH(isig).QC.rollvar = var(roll,'omitnan');
        AQH(isig).QC.headvar = var(unwrap(heading),'omitnan');
        AQH(isig).QC.wpsd = wpsd;
        AQH(isig).QC.bobpsd = bobpsd;
        AQH(isig).QC.f = f;
        AQH(isig).QC.mspe0 = mspe0;
        AQH(isig).QC.mspeHP = mspeHP;
        AQH(isig).QC.mspeEOF = mspeEOF;
        AQH(isig).QC.slope0 = slope0;
        AQH(isig).QC.slopeHP = slopeHP;
        AQH(isig).QC.slopeEOF = slopeEOF;
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
                SWIFT(tindex).uplooking= [];
                SWIFT(tindex).uplooking.w = hrw;
                SWIFT(tindex).uplooking.werr = hrwerr;
                SWIFT(tindex).uplooking.z = hrz';
                SWIFT(tindex).uplooking.tkedissipationrate = eps_structHP';

            elseif timematch && badburst % Bad burst & time match
                % HR data
                SWIFT(tindex).uplooking = [];
                SWIFT(tindex).uplooking.w  = NaN(size(hrw));
                SWIFT(tindex).uplooking.werr = NaN(size(hrw));
                SWIFT(tindex).uplooking.z = hrz;
                SWIFT(tindex).uplooking.tkedissipationrate = NaN(size(eps_structHP'));
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
                SWIFT(tindex).uplooking= [];
                SWIFT(tindex).uplooking.w = hrw;
                SWIFT(tindex).uplooking.werr = hrwerr;
                SWIFT(tindex).uplooking.z = hrz';
                SWIFT(tindex).uplooking.tkedissipationrate = eps_structHP';
                % Time
                SWIFT(tindex).time = btime;
                disp(['   Burst time: ' datestr(btime)])
                disp(['   (new) SWIFT time: ' datestr(SWIFT(tindex).time)])
            end
        end

    % End burst loop
    end
        
    % NaN out SWIFT sig fields which were not matched to bursts
    inan = find(~burstreplaced);
    if ~isempty(inan)
        for it = inan'
            % HR data
                SWIFT(tindex).uplooking = [];
                SWIFT(tindex).uplooking.w  = NaN(size(hrw));
                SWIFT(tindex).uplooking.werr = NaN(size(hrw));
                SWIFT(tindex).uplooking.z = hrz;
                SWIFT(tindex).uplooking.tkedissipationrate = NaN(size(eps_structHP'));
        end
    end

    % Sort by time
    if ~isempty(fieldnames(SWIFT))
    [~,isort] = sort([SWIFT.time]);
    SWIFT = SWIFT(isort);
    end
    
    %%%%%% Plot burst Averaged SWIFT Signature Data %%%%%%
    if plotmission
        catAQH(AQH);
        set(gcf,'Name',SNprocess)
        if saveplots
            %Create mission folder if doesn't already exist
            if ~isfolder([savefigdir SNprocess])
                mkdir([savefigdir SNprocess])
            end
            figname = [savefigdir '\' get(gcf,'Name')];
            print(figname,'-dpng')
            close gcf
        end
    end
            
	%%%%%% Save SWIFT Structure %%%%%%%%
    if saveSWIFT && ~isempty(fieldnames(SWIFT))
        if strcmp(structfile.name(end-6:end-4),'IMU')
            save([saveswiftdir SNprocess '_reprocessedAQHandIMU.mat'],'SWIFT')
        else
            save([saveswiftdir SNprocess '_reprocessedAQH.mat'],'SWIFT')
        end
    end
    
    %%%%%% Save SIG Structure %%%%%%%%
    if saveAQH
       save([savesigdir SNprocess '_burstavgAQH.mat'],'AQH')
    end
    
% End mission loop
end
% clear all