function [SWIFT,AQH] = reprocess_AQH(missiondir,savedir,varargin)
% Reprocess AQH data to compute dissipation rate. Based on reprocess_SIG(missiondir,savedir).
% Jan 2024, K. Zeiden

%% Load/Save/Plot Toggles

%Default
opt.readraw = false;% read raw binary files
opt.saveSWIFT = false;% save updated SWIFT structure
opt.saveAQH = false; %save detailed sig data in separate SIG structure
opt.plotburst = false; % generate plots for each burst
opt.plotmission = false; % generate summary plot for mission
opt.saveplots = false; % save generated plots

% Processing parameters
% Config Parameters
opt.xz = 0.8; % depth of transducer [m]
opt.dz = 0.04; % cell size
opt.bz = 0.1; % blanking distance
opt.dt = 1/4; % seconds

% QC Parameters
opt.nsumeof = 1;% too few EOFs to remove more
opt.lsm = 0.12;%
opt.mincorr = 50;

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
clear SWIFT AQH

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
AQH = struct;
iaqh = 1;

% Populate list of burst files, favor 'partial' burst files
% Data type
if opt.readraw
    ftype = '.dat';
else
    ftype = '.mat';
end
bfiles = dir([missiondir 'AQH' slash 'Raw' slash '*' slash '*' ftype]);
if isempty(bfiles)
    error('   No burst files found    ')
end
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
        disp('Reading raw AQH file...')
        [burst.time,burst.VelocityData,burst.AmplitudeData,burst.CorrelationData...
            ,burst.Pressure,burst.Temperature,burst.Pitch,burst.Roll,burst.Heading] = ...
            readSWIFTv3_AQH([bfiles(iburst).folder '\' bfiles(iburst).name]);
    else
        load([bfiles(iburst).folder '\' bfiles(iburst).name],...
            'Vel','Cor','Amp','Pressure','Temp','pitch','roll','heading','time')
        if exist('Vel')
        burst.VelocityData = Vel;
        burst.CorrelationData = Cor;
        burst.AmplitudeData = Amp;
        burst.Pressure = Pressure;
        burst.Temperature = Temp;
        burst.Pitch = pitch;
        burst.Roll = roll;
        burst.Heading = heading;
        burst.time = time;
        else
            burst.VelocityData = [];
        end
    end
    
    % Skip burst if empty
    if isempty(burst.VelocityData)
        disp('Failed to read, skipping burst...')
        continue
    end
    
%%%%%%% FLAGS %%%%%%
    
    % Flag if burst time from name is very different from recorded
    t0 = datenum(datestr(min(burst.time),'dd-mmm-yyyy HH:MM'));
    if abs(btime - t0) > 12/(60*24)
        disp('   WARNING: File name time disagrees with recorded time. Using recorded time...   ')
    else
        t0 = btime;
    end

    % Flag if file is too small
    if bfiles(iburst).bytes < 1e5
        disp('   FLAG: Bad file (small)...')
        smallfile = true;
    else
        smallfile = false;
    end

    % Flag if coming in/out of the water
    if any(ischange(burst.Pressure))
        disp('   FLAG: Out-of-Water (pressure change)...')
        outofwater = true;
    else
        outofwater = false;
    end

    % Flag out of water based on bursts w/low cor
    if mean(burst.CorrelationData(:),'omitnan') < opt.mincorr
        disp('   FLAG: Bad Corr (low average corr)...')
        badcorr = true;
    else
        badcorr = false;
    end

    badburst = smallfile | outofwater | badcorr;

%%%%%%% Process HR velocity data ('burst' structure) %%%%%%
    
    [HRprofile,fh] = processAQHburst(burst,opt);

    if isempty(HRprofile)
        HRprofile = NaNstructR(AQH(isig-1).HRprofile);
    end

       if opt.saveplots && ~isempty(fh)
        figure(fh(1))
        set(gcf,'Name',[bname '_HR_data'])
        figname = [savedir SNprocess slash get(gcf,'Name')];
        print(figname,'-dpng')
        close gcf

        figure(fh(2))
        set(gcf,'Name',[bname '_HR_profiles'])
        figname = [savedir SNprocess slash get(gcf,'Name')];
        print(figname,'-dpng')
        close gcf
       end
    
    
%%%%%%%% Save detailed signature data in SIG structure %%%%%%%%

    %Time
    AQH(iaqh).time = t0;
    % HR data
    AQH(iaqh).HRprofile = HRprofile;
    %Temperaure
    AQH(iaqh).watertemp = mean(burst.Temperature);
    % Motion
    AQH(iaqh).motion.pitch = mean(burst.Pitch,'omitnan');
    AQH(iaqh).motion.roll = mean(burst.Roll,'omitnan');
    AQH(iaqh).motion.head = mean(burst.Heading,'omitnan');
    AQH(iaqh).motion.pitchvar = var(burst.Pitch,'omitnan');
    AQH(iaqh).motion.rollvar = var(burst.Roll,'omitnan');
    AQH(iaqh).motion.headvar = var(unwrap(burst.Heading),'omitnan');
    % Badburst & flags
    AQH(iaqh).badburst = badburst;
    AQH(iaqh).flag.smallfile = smallfile;
    AQH(iaqh).flag.outofwater = outofwater;
    AQH(iaqh).flag.badcorr = badcorr;

    iaqh = iaqh+1;

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

        if  timematch % Always save results if time match
            % HR data
            SWIFT(tindex).uplooking = [];
            SWIFT(tindex).uplooking.w = HRprofile.w;
            SWIFT(tindex).uplooking.werr = HRprofile.wvar;
            SWIFT(tindex).uplooking.z = HRprofile.z';
            SWIFT(tindex).uplooking.tkedissipationrate = ...
                HRprofile.eps;
            % Temperaure
            SWIFT(tindex).watertemp = mean(burst.Temperature);

        elseif ~timematch && ~badburst % Good burst, no time match
            disp('   ALERT: Burst good, but no time match...')
            tindex = length(SWIFT)+1;
            burstreplaced = [burstreplaced; true]; %#ok<AGROW>
            % Copy fields from SWIFT(1);
            SWIFT(tindex) = NaNstructR(SWIFT(1));            
            % HR data
            SWIFT(tindex).uplooking  = [];
            SWIFT(tindex).uplooking.w = HRprofile.w;
            SWIFT(tindex).uplooking.wvar = HRprofile.wvar;
            SWIFT(tindex).uplooking.z = HRprofile.z';
            SWIFT(tindex).uplooking.tkedissipationrate = ...
                HRprofile.eps;
            % Temperaure
            SWIFT(tindex).watertemp = mean(burst.Temperature);
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
            SWIFT(it).uplooking = [];
            SWIFT(it).uplooking.w = NaN(size(HRprofile.w));
            SWIFT(it).uplooking.wvar = NaN(size(HRprofile.w));
            SWIFT(it).uplooking.z = HRprofile.z;
            SWIFT(it).uplooking.tkedissipationrate = NaN(size(HRprofile.w'));
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
        save([savedir SNprocess '_reprocessedAQHandSBG.mat'],'SWIFT')
    else
        save([savedir SNprocess '_reprocessedAQH.mat'],'SWIFT')
    end
end

%%%%%% Save AQH Structure %%%%%%%%
if opt.saveAQH
   save([savedir SNprocess '_burstavgAQH.mat'],'AQH')
end

%%%%%% Plot burst Averaged SWIFT Signature Data %%%%%%
% if opt.plotmission
%     catAQH(AQH,'plot');
%     set(gcf,'Name',SNprocess)
%     if opt.saveplots
%         figname = [savedir get(gcf,'Name')];
%         print(figname,'-dpng')
%         close gcf
%     end
% end


cd(savedir)

end