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

%% Make sure save directory exists

if ~exist(savedir,'dir')
    error('Save directory does not exist.')
end

%% Load/Save/Plot Toggles

% Plotting toggles
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

%% Other QC params

% QC Options (broadband)
opt.QCcorr = false;% (NOT recommended) standard, QC removes any data below 'mincorr'
opt.QCbin = false;% QC entire bins with greater than pbadmax perecent bad correlation
opt.QCping = false; % QC entire ping with greater than pbadmax percent bad correlation
opt.QCfish = true;% detects fish from highly skewed amplitude distributions in a depth bin
opt.QCalt = false; % trim data based on altimeter

% Config Parameters
opt.xz = 0.2; % depth of transducer [m]

% QC Parameters
opt.mincorr = 40; % burst-avg correlation minimum
opt.maxamp = 150; % burst-avg amplitude maximum
opt.maxwvar = 0.2; % burst-avg HR velocity (percent) error maximum
opt.pbadmax = 80; % maximum percent 'bad' amp/corr/err values per bin or ping allowed
opt.nsumeof = 3;% Default 3? Number of lowest-mode EOFs to remove from turbulent velocity

if opt.nsumeof~=3
    warning(['EOF filter changed to ' num2str(opt.nsumeof)])
end

%% Data type to be read in
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

% Populate list of burst files
bfiles = dir([missiondir 'SIG' slash 'Raw' slash '*' slash '*' ftype]);
if isempty(bfiles)
    error('   No burst files found    ')
end
bfiles = bfiles(~contains({bfiles.name},'smoothwHR'));

% Deal with 'partial' files (two options)
%bfiles = bfiles(~contains({bfiles.name},'partial'));
ipart = find(contains({bfiles.name},'partial'));
idel = [];
for ip = 1:length(ipart)
    pname = bfiles(ipart(ip)).name;
    mname = [pname(1:end-12) '.mat'];
    pdir = bfiles(ipart(ip)).folder;
    if exist([pdir slash mname])
        idel = [idel find(strcmp({bfiles.name}',bfiles(1).name))];
    end
end
bfiles(idel) = [];
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
   [burst,avg,~,~] = readSWIFTv4_SIG([bfiles(iburst).folder slash bfiles(iburst).name]);
    else
        load([bfiles(iburst).folder slash bfiles(iburst).name],'burst','avg')
    end
    
    % Skip burst if empty
    if isempty(avg)
        disp('Failed to read, skipping burst...')
        continue
    end
    
    %%%%%%% FLAGS %%%%%%
    
    % Flag if burst time from name is very different from recorded
    t0 = datenum(datestr(min(avg.time),'dd-mmm-yyyy HH:MM'));
    if abs(btime - t0) > 12/(60*24)
        disp('   WARNING: File name time disagrees with recorded time. Using recorded time...   ')
    else
        t0 = btime;
    end

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

%     % Flag out of water based on bursts with high velocity variance
%     if  mean(std(burst.VelocityData,[],2,'omitnan')) > opt.maxwvar
%         disp('   FLAG: Bad Vel (high along-beam variance)...')
%         badvel = true;
%     else
%         badvel = false;
%     end

    % Determine Altimeter Distance
    if isfield(avg,'AltimeterDistance')
        maxz = median(avg.AltimeterDistance);
    else
        maxz = inf;
    end

    badburst = smallfile | outofwater | badamp | badcorr;% | badvel;

    %%%%%%% Process Broadband velocity data ('avg' structure) %%%%%%

      [profile,fh] = processSIGavg(avg,opt);
      
       if isempty(profile)
            profile = NaNstructR(SIG(isig-1).profile);
        end
      
        if opt.saveplots && ~isempty(fh)
            figure(fh(1))
            set(gcf,'Name',[bname '_bband_data'])
            figname = [bfiles(iburst).folder slash SNprocess slash get(gcf,'Name')];
            print(figname,'-dpng')
            close gcf
            
            figure(fh(2))
            set(gcf,'Name',[bname '_bband_profiles'])
            figname = [bfiles(iburst).folder slash SNprocess slash get(gcf,'Name')];
            print(figname,'-dpng')
            close gcf
        end
       


    %%%%%%% Process HR velocity data ('burst' structure) %%%%%%
    
        [HRprofile,fh] = processSIGburst(burst,opt);
        
        if isempty(HRprofile)
            HRprofile = NaNstructR(SIG(isig-1).HRprofile);
        end
    
           if opt.saveplots && ~isempty(fh)
            figure(fh(1))
            set(gcf,'Name',[bname '_HR_data'])
            figname = [bfiles(iburst).folder slash SNprocess slash get(gcf,'Name')];
            print(figname,'-dpng')
            close gcf
            
%             figure(fh(2))
%             set(gcf,'Name',[bname '_HR_profiles'])
%             figname = [savedir SNprocess slash get(gcf,'Name')];
%             print(figname,'-dpng')
%             close gcf
           end

    %%%%%%%% Process Echo data %%%%%%%%%%%

   if ~empty(echo)

       if ~isempty(SWIFT)
        S =mean([SWIFT.salinity],'omitnan');
       else
           S = 25;
       end
       [echogram,fh] = processSIGecho(echo,S);
       echogram.z = opt.xz + echogram.r;

        if opt.saveplots && ~isempty(fh)
            figure(fh)
            set(gcf,'Name',[bname '_Echogram'])
            figname = [bfiles(iburst).folder slash SNprocess slash get(gcf,'Name')];
            print(figname,'-dpng')
            close gcf
        end
       
   end
    
    %%%%%%%% Save detailed signature data in SIG structure %%%%%%%%

    %Time
    SIG(isig).time = t0;
    % HR data
    SIG(isig).HRprofile = HRprofile;
    %Temperaure
    SIG(isig).watertemp = profile.temp;
    % Broadband data
    SIG(isig).profile = profile;
    % Echogram data
    if ~isempty(echo)
    SIG(isig).echogram = echogram;
    end
    % Motion
    SIG(isig).motion.pitch = mean(avg.Pitch,'omitnan');
    SIG(isig).motion.roll = mean(avg.Roll,'omitnan');
    SIG(isig).motion.head = mean(avg.Heading,'omitnan');
    SIG(isig).motion.pitchvar = var(avg.Pitch,'omitnan');
    SIG(isig).motion.rollvar = var(avg.Roll,'omitnan');
    SIG(isig).motion.headvar = var(unwrap(avg.Heading),'omitnan');
    % Badburst & flags
    SIG(isig).badburst = badburst;
    SIG(isig).flag.altimeter = maxz;
    SIG(isig).flag.smallfile = smallfile;
    SIG(isig).flag.outofwater = outofwater;
    SIG(isig).flag.badamp = badamp;
    SIG(isig).flag.badcorr = badcorr;

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

        if  timematch %&& ~badburst % time match
            % HR data
            SWIFT(tindex).signature.HRprofile = [];
            SWIFT(tindex).signature.HRprofile.w = HRprofile.w;
            SWIFT(tindex).signature.HRprofile.wvar = HRprofile.wvar;
            SWIFT(tindex).signature.HRprofile.z = HRprofile.z';
            SWIFT(tindex).signature.HRprofile.tkedissipationrate = ...
                HRprofile.eps;
            % Broadband data
            SWIFT(tindex).signature.profile = [];
            SWIFT(tindex).signature.profile.east = profile.u;
            SWIFT(tindex).signature.profile.north = profile.v;
            SWIFT(tindex).signature.profile.w = profile.w;
            SWIFT(tindex).signature.profile.uvar = profile.uvar;
            SWIFT(tindex).signature.profile.vvar = profile.vvar;
            SWIFT(tindex).signature.profile.wvar = profile.wvar;
            SWIFT(tindex).signature.profile.z = profile.z;
            if ~isempty(echo)
                SWIFT(tindex).signature.echogram = echogram;
            end
            % Altimeter & Out-of-Water Flag
            SWIFT(tindex).signature.altimeter = maxz;
            % Temperaure
            SWIFT(tindex).watertemp = profile.temp;

%         elseif timematch && badburst % Bad burst & time match
%             % HR data
%             SWIFT(tindex).signature.HRprofile = [];
%             SWIFT(tindex).signature.HRprofile.w = NaN(size(HRprofile.w));
%             SWIFT(tindex).signature.HRprofile.wvar = NaN(size(HRprofile.w));
%             SWIFT(tindex).signature.HRprofile.z = HRprofile.z';
%             SWIFT(tindex).signature.HRprofile.tkedissipationrate = ...
%                 NaN(size(HRprofile.w'));
%             % Broadband data
%             SWIFT(tindex).signature.profile = [];
%             SWIFT(tindex).signature.profile.w = NaN(size(profile.u));
%             SWIFT(tindex).signature.profile.east = NaN(size(profile.u));
%             SWIFT(tindex).signature.profile.north = NaN(size(profile.u));
%             SWIFT(tindex).signature.profile.uvar = NaN(size(profile.u));
%             SWIFT(tindex).signature.profile.vvar = NaN(size(profile.u));
%             SWIFT(tindex).signature.profile.wvar = NaN(size(profile.u));
%             SWIFT(tindex).signature.profile.z = profile.z;
        elseif ~timematch && ~badburst % Good burst, no time match
            disp('   ALERT: Burst good, but no time match...')
            tindex = length(SWIFT)+1;
            burstreplaced = [burstreplaced; true]; %#ok<AGROW>
            % Copy fields from SWIFT(1);
            SWIFT(tindex) = NaNstructR(SWIFT(1));            
            % HR data
            SWIFT(tindex).signature.HRprofile = [];
            SWIFT(tindex).signature.HRprofile.w = HRprofile.w;
            SWIFT(tindex).signature.HRprofile.wvar = HRprofile.wvar;
            SWIFT(tindex).signature.HRprofile.z = HRprofile.z';
            SWIFT(tindex).signature.HRprofile.tkedissipationrate = ...
                HRprofile.eps;
            % Broadband data
            SWIFT(tindex).signature.profile = [];
            SWIFT(tindex).signature.profile.east = profile.u;
            SWIFT(tindex).signature.profile.north = profile.v;
            SWIFT(tindex).signature.profile.w = profile.w;
            SWIFT(tindex).signature.profile.uvar = profile.uvar;
            SWIFT(tindex).signature.profile.vvar = profile.vvar;
            SWIFT(tindex).signature.profile.wvar = profile.wvar;
            SWIFT(tindex).signature.profile.z = profile.z;
            % Altimeter
            SWIFT(tindex).signature.altimeter = maxz;
            % Temperaure
            SWIFT(tindex).watertemp = profile.temp;
            % Time
            SWIFT(tindex).time = btime;
            SWIFT(tindex).date = datestr(btime,'ddmmyyyy');
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
            SWIFT(it).signature.HRprofile.w = NaN(size(HRprofile.w));
            SWIFT(it).signature.HRprofile.wvar = NaN(size(HRprofile.w));
            SWIFT(it).signature.HRprofile.z = HRprofile.z;
            SWIFT(it).signature.HRprofile.tkedissipationrate = NaN(size(HRprofile.w'));
            % Broadband data
            SWIFT(it).signature.profile = [];
            SWIFT(it).signature.profile.w = NaN(size(profile.u));
            SWIFT(it).signature.profile.east = NaN(size(profile.u));
            SWIFT(it).signature.profile.north = NaN(size(profile.u));
            SWIFT(it).signature.profile.uvar = NaN(size(profile.u));
            SWIFT(it).signature.profile.vvar = NaN(size(profile.u));
            SWIFT(it).signature.profile.wvar = NaN(size(profile.u));
            SWIFT(it).signature.profile.z = profile.z;
        end
    end
end

% Sort by time
if ~isempty(fieldnames(SWIFT)) && isfield(SWIFT,'time')
[~,isort] = sort([SWIFT.time]);
SWIFT = SWIFT(isort);
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

%%%%%% Plot burst Averaged SWIFT Signature Data %%%%%%
if opt.plotmission
    catSIG(SIG,'plot');
    set(gcf,'Name',SNprocess)
    if opt.saveplots
        figname = [savedir get(gcf,'Name')];
        print(figname,'-dpng')
        close gcf
    end
end


cd(savedir)

end