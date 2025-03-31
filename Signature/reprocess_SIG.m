function [SWIFT,sinfo] = reprocess_SIG(missiondir,readraw,plotburst)

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
%       July 2024 (K. Zeiden)
%           some reformatting to adhere to postprocess_SIG.m and mirror
%           other reprocessing scripts. Moved 'readraw' and 'plotburst' as
%           external toggles/function inputs. The others are changed less
%           frequently so they are 'internal'

% NOTE: Known issue -- sometimes the ADCP 'sputters' and for a few minutes
% will record perfectly periodic ping-ping oscillations in correlation,
% amplitude and velocity before suddenly logging real data again. E.g.
% SWIFT 22, Mar 29 during LC-DRI Experiment. So far these periods elude QC
% traps due to the periodic oscillations which make the mean value
% reasonable. So far only known to have happened on SWIFT 22, LC-DRI Exp.

if ispc
    slash = '\';
else
    slash = '/';
end

%% Load existing L3 product, or L2 product if does not exist. If no L3 product, return to function

l2file = dir([missiondir slash '*SWIFT*L2.mat']);
l3file = dir([missiondir slash '*SWIFT*L3.mat']);

if ~isempty(l3file) % First check to see if there is an existing L3 file to load
    sfile = l3file;
    load([sfile.folder slash sfile.name],'SWIFT','sinfo');
elseif isempty(l3file) && ~isempty(l2file)% If not, load L1 file
    sfile = l2file;
    load([sfile.folder slash sfile.name],'SWIFT','sinfo');
else %  Exit reprocessing if no L2 or L3 product exists
    warning(['No L2 or L3 product found for ' missiondir(end-16:end) '. Skipping...'])
    return
end

%% Toggles

%%% User Input Toggles
opt.readraw = readraw;% read raw binary files
opt.plotburst = plotburst; % generate plots for each burst

%%% Internal Toggles
opt.saveSIG = true; %save detailed sig data in separate SIG structure
opt.saveplots = true; % save generated plots

% QC Options (broadband)
opt.QCcorr = false;% (NOT recommended) standard, QC removes any data below 'mincorr'
opt.QCbin = false;% QC entire bins with greater than pbadmax perecent bad correlation
opt.QCping = false; % QC entire ping with greater than pbadmax percent bad correlation
opt.QCfish = true;% detects fish from highly skewed amplitude distributions in a depth bin
opt.QCalt = false; % trim data based on altimeter

% Config Parameters
opt.xz = 0.2; % depth of transducer [m]

% Calculation Parameters
opt.mincorr = 40; % burst-avg correlation minimum
opt.pbadmax = 80;
opt.maxamp = 150; % burst-avg amplitude maximum
opt.maxwvar = 0.2; % burst-avg HR velocity (percent) error maximum
opt.nsumeof = 3;% Default 3? Number of lowest-mode EOFs to remove from turbulent velocity

%% Data type to be read in
if opt.readraw
    ftype = '.dat';
else
    ftype = '.mat';
end

%% Create SIG structure, list burst files

burstreplaced = false(length(SWIFT),1);
badsig = false(1,length(SWIFT));

SIG = struct;
isig = 1;

%% List of burst files

bfiles = dir([missiondir slash 'SIG' slash 'Raw' slash '*' slash '*' ftype]);
if isempty(bfiles)
    error('   No burst files found    ')
end
bfiles = bfiles(~contains({bfiles.name},'smoothwHR'));

% Deal with 'partial' files: only use if full file is not available or is smaller
partburst = find(contains({bfiles.name},'partial'));
rmpart = false(1,length(partburst));
for iburst = 1:length(partburst)
    pdir = bfiles(partburst(iburst)).folder;
    pname = bfiles(partburst(iburst)).name;
    matburst = dir([pdir slash pname(1:end-12) '.mat']);
    if ~isempty(matburst) && matburst.bytes > bfiles(partburst(iburst)).bytes
        rmpart(iburst) = true;
    end
end
bfiles(partburst(rmpart)) = [];
nburst = length(bfiles);

%% Loop through burst files and reprocess signature data
for iburst = 1:nburst

    bname = bfiles(iburst).name(1:end-4);
    disp(['Burst ' num2str(iburst) ' : ' bname])

    % Load burst file
    if opt.readraw
   [burst,avg,~,~] = readSWIFTv4_SIG([bfiles(iburst).folder slash bfiles(iburst).name]);
    else
        load([bfiles(iburst).folder slash bfiles(iburst).name],'burst','avg','echo')
    end
    
    % Skip burst if empty
    if isempty(avg)
        disp('Failed to read, skipping burst...')
        continue
    end

    % Skip if any of the burst fields are 3D
    if ndims(burst.VelocityData)>2 || ndims(burst.CorrelationData)>2 || ndims(burst.AmplitudeData)>2
        disp('Burst fields have more than 2 dimensions, skipping burst...')
        continue
    end

    % Burst time
    btime = min(burst.time);

    % Find burst index in the existing SWIFT structure
    burstID = bfiles(iburst).name(13:end-4);
    sindex = find(strcmp(burstID,{SWIFT.burstID}'));
    if isempty(sindex)
        disp('No matching SWIFT index.')
        burstmatch = false;
    else
        burstmatch = true;
        burstreplaced(sindex) = true;
        stime = SWIFT(sindex).time;
        if abs(stime-btime) > 1/(60*24) % within 1-min
           disp('   WARNING: File name disagrees with recorded time...   ')
        end
    end

    % Altimeter Distance
    if isfield(avg,'AltimeterDistance')
        maxz = median(avg.AltimeterDistance);
    else
        maxz = inf;
    end
    
    %%%%%%% FLAGS %%%%%%

    % Flag if coming in/out of the water
    if any(ischange(burst.Pressure)) && any(ischange(burst.Temperature))
        disp('   FLAG: Out-of-Water (temp/pressure change)...')
        outofwater = true;
    else
        outofwater = false;
    end

    % Flag burst if file is too small...
    if bfiles(iburst).bytes < 1e6 % 2e6,
        disp('FLAG: Small file...')
        smallfile = true;
    else
        smallfile = false;
    end

    % Flag out of water based on bursts w/anomalously high amplitude
    if mean(burst.AmplitudeData(:),'omitnan') > opt.maxamp
        disp('   FLAG: High average amp...')
        badamp = true;
    else
        badamp = false;
    end

    % Flag out of water based on bursts w/low correlation
    if mean(burst.CorrelationData(:),'omitnan') < opt.mincorr
        disp('   FLAG: Low average corr...')
        badcorr = true;
    else
        badcorr = false;
    end

    % Flag bad bursts
    badburst = smallfile;% | badamp | badcorr

    %%%%%%% Process Broadband velocity data ('avg' structure) %%%%%%

      [profile,fh] = processSIGavg(avg,opt);
      
       if isempty(profile)
            profile = NaNstructR(SIG(isig-1).profile);
        end
      
        if opt.saveplots && ~isempty(fh)
            figure(fh(1))
            set(gcf,'Name',[bname '_bband_data'])
            figname = [bfiles(iburst).folder slash get(gcf,'Name')];
            print(figname,'-dpng')
            close gcf
            
            figure(fh(2))
            set(gcf,'Name',[bname '_bband_profiles'])
            figname = [bfiles(iburst).folder slash get(gcf,'Name')];
            print(figname,'-dpng')
            close gcf
        end
       

    %%%%%%% Process HR velocity data ('burst' structure) %%%%%%
    
        [HRprofile,fh] = processSIGburst(burst,opt);

        % Remove EOF data (too large)
        HRprofile.QC = rmfield(HRprofile.QC,{'eofs','eofvar','eofamp','wpeofmag'});
        
        if isempty(HRprofile)
            HRprofile = NaNstructR(SIG(isig-1).HRprofile);
        end
    
           if opt.saveplots && ~isempty(fh)
            figure(fh(1))
            set(gcf,'Name',[bname '_HR_data'])
            figname = [bfiles(iburst).folder slash get(gcf,'Name')];
            print(figname,'-dpng')
            close gcf
           
           end

    %%%%%%%% Process Echo data %%%%%%%%%%%
   if ~isempty(echo)

       if ~isempty(SWIFT)
        S =mean([SWIFT.salinity],'omitnan');
       else
           S = 25;
       end
       [echogram,fh] = processSIGecho(echo,S,opt);
       echogram.z = opt.xz + echogram.r;

        if opt.saveplots && ~isempty(fh)
            figure(fh)
            set(gcf,'Name',[bname '_Echogram'])
            figname = [bfiles(iburst).folder slash get(gcf,'Name')];
            print(figname,'-dpng')
            close gcf
        end
       
   end
    
    %%%%%%%% Save detailed signature data in SIG structure %%%%%%%%

    %Time
    SIG(isig).time = btime;
    % Burst ID
    SIG(isig).burstID = burstID;
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
    SIG(isig).timematch = burstmatch;
    SIG(isig).outofwater = outofwater;
    SIG(isig).flag.badamp = badamp;
    SIG(isig).flag.badcorr = badcorr;
    SIG(isig).flag.smallfile = smallfile;

    isig = isig+1;

   %%%%%%%% Match burst time to existing SWIFT fields and replace data %%%%%%%%

   if ~isempty(fieldnames(SWIFT)) && ~isempty(SWIFT)

        if  burstmatch && ~badburst % time match, good burst
            % HR data
            SWIFT(sindex).signature.HRprofile = [];
            SWIFT(sindex).signature.HRprofile.w = HRprofile.w;
            SWIFT(sindex).signature.HRprofile.wvar = HRprofile.wvar;
            SWIFT(sindex).signature.HRprofile.z = HRprofile.z';
            SWIFT(sindex).signature.HRprofile.tkedissipationrate = ...
                HRprofile.eps;
            % Broadband data
            SWIFT(sindex).signature.profile = [];
            SWIFT(sindex).signature.profile.east = profile.u;
            SWIFT(sindex).signature.profile.north = profile.v;
            SWIFT(sindex).signature.profile.w = profile.w;
            SWIFT(sindex).signature.profile.uvar = profile.uvar;
            SWIFT(sindex).signature.profile.vvar = profile.vvar;
            SWIFT(sindex).signature.profile.wvar = profile.wvar;
            SWIFT(sindex).signature.profile.z = profile.z;
            % Echogram data
            if ~isempty(echo)
                SWIFT(sindex).signature.echo = echogram.echoc;
                SWIFT(sindex).signature.echoz = echogram.r + opt.xz;
            end
            % Altimeter
            SWIFT(sindex).signature.altimeter = maxz;
            % Temperaure
            SWIFT(sindex).watertemp2 = profile.temp;

        elseif burstmatch && badburst % time match, bad burst
            % HR data
            SWIFT(sindex).signature.HRprofile = [];
            SWIFT(sindex).signature.HRprofile.w = NaN(size(HRprofile.w));
            SWIFT(sindex).signature.HRprofile.wvar = NaN(size(HRprofile.w));
            SWIFT(sindex).signature.HRprofile.z = HRprofile.z';
            SWIFT(sindex).signature.HRprofile.tkedissipationrate = ...
                NaN(size(HRprofile.w'));
            % Broadband data
            SWIFT(sindex).signature.profile = [];
            SWIFT(sindex).signature.profile.w = NaN(size(profile.u));
            SWIFT(sindex).signature.profile.east = NaN(size(profile.u));
            SWIFT(sindex).signature.profile.north = NaN(size(profile.u));
            SWIFT(sindex).signature.profile.uvar = NaN(size(profile.u));
            SWIFT(sindex).signature.profile.vvar = NaN(size(profile.u));
            SWIFT(sindex).signature.profile.wvar = NaN(size(profile.u));
            SWIFT(sindex).signature.profile.z = profile.z;
            % Echogram data
            if ~isempty(echo)
                SWIFT(sindex).signature.echo = NaN(size(echogram.echoc));
                SWIFT(sindex).signature.echoz = echogram.r + opt.xz;
            end
            % Flag
            badsig(sindex) = true;

        elseif ~burstmatch && ~badburst % Good burst, no index match
            disp('   ALERT: Burst good, but no index match...')

        end
    end

% End burst loop
end

%% Clean up

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

%% Sort by time %%%%%%%%

if ~isempty(fieldnames(SWIFT)) && isfield(SWIFT,'time')
[~,isort] = sort([SWIFT.time]);
SWIFT = SWIFT(isort);
end

%% Save SIG Structure + Plot %%%%%%%%

if opt.saveSIG
   save([sfile.folder slash sfile.name(1:end-7) '_burstavgSIG.mat'],'SIG')
end

% Plot burst Averaged SWIFT Signature Data
catSIG(SIG,'plot');
set(gcf,'Name',sfile.name(1:end-7))
if opt.saveplots
    figname = [missiondir slash get(gcf,'Name')];
    print([figname '_SIG'],'-dpng')
    close gcf
end


%% Log reprocessing and flags, then save new L3 file or overwrite existing one
params = opt;

if isfield(sinfo,'postproc')
ip = length(sinfo.postproc)+1; 
else
    sinfo.postproc = struct;
    ip = 1;
end
sinfo.postproc(ip).type = 'SIG';
sinfo.postproc(ip).usr = getenv('username');
sinfo.postproc(ip).time = string(datetime('now'));
sinfo.postproc(ip).flags.badsig = badsig;
sinfo.postproc(ip).params = params;

save([sfile.folder slash sfile.name(1:end-7) '_L3.mat'],'SWIFT','sinfo')

%% Return to mission directory
cd(missiondir)

end