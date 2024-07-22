function [SWIFT,sinfo] = reprocess_AQH(missiondir,readraw,plotburst)

% Reprocess SWIFT v4 Aquadopp velocities from burst data
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
%   K. Zeiden 07/2024 - 

if ispc
    slash = '\';
else
    slash = '/';
end

%% Internal Toggles

% Data Load/Save Toggles
opt.saveAQH = true; %save detailed sig data in separate SIG structure
opt.saveplots = true; % save generated plots
opt.plotburst = plotburst;
opt.readraw = readraw;

% AQH Config
opt.xz = 0.8; % depth of transducer [m]
opt.dz = 0.04; % cell size
opt.bz = 0.1; % blanking distance
opt.dt = 1/4; % seconds

% QC
opt.mincorr = 50;
opt.minamp = 80;
opt.nsumeof = 3;
opt.lsm = 0.5;

%% Data type to be read in
if opt.readraw
    ftype = '.dat';
else
    ftype = '.mat';
end

%% Load or create SWIFT structure, create SIG structure, list burst files

l1file = dir([missiondir slash '*SWIFT*L1.mat']);
l2file = dir([missiondir slash '*SWIFT*L2.mat']);

if ~isempty(l2file) % First check to see if there is an existing L2 file to load
    sfile = l2file;
    load([sfile.folder slash sfile.name],'SWIFT','sinfo');
elseif isempty(l2file) && ~isempty(l1file)% If not, load L1 file
    sfile = l1file;
    load([sfile.folder slash sfile.name],'SWIFT','sinfo');
else %  Exit reprocessing if no L1 or L2 product exists
    warning(['No L1 or L2 product found for ' missiondir(end-16:end) '. Skipping...'])
    return
end
burstreplaced = false(length(SWIFT),1);
badaqh = false(length(SWIFT),1);

AQH = struct;
iaqh = 1;

%% List of burst files

bfiles = dir([missiondir slash 'AQH' slash 'Raw' slash '*' slash '*' ftype]);
if isempty(bfiles)
    error('   No burst files found    ')
end
nburst = length(bfiles);

%% Loop through burst files and reprocess signature data
for iburst = 1:nburst

    % Burst time stamp and name
    day = bfiles(iburst).name(13:21);
    hour = bfiles(iburst).name(23:24);
    mint = bfiles(iburst).name(26:27);
    btime = datenum(day) + datenum(0,0,0,str2double(hour),(str2double(mint)-1)*12,0);
    bname = bfiles(iburst).name(1:end-4);
    disp(['Burst ' num2str(iburst) ' : ' bname])

    % Load burst file
    if readraw
        disp('Reading raw AQH file...')
        [time,vel,amp,cor,press,pitch,roll,heading] = ...
            readSWIFTv3_AQH([bfiles(iburst).folder '\' bfiles(iburst).name]);
    else
        load([bfiles(iburst).folder '\' bfiles(iburst).name],...
            'Vel','Cor','Amp','Pressure','pitch','roll','heading','time')
        vel = Vel;
        cor = Cor;
        amp = Amp;
        press = Pressure';
    end

    % Skip burst if empty
    if isempty(vel)
        disp('Failed to read, skipping burst...')
        continue
    end

    % Create burst structure
    burst.time = time;
    burst.CorrelationData = cor;
    burst.AmplitudeData = amp;
    burst.VelocityData = vel;
    burst.Heading = heading;
    burst.Pitch = pitch;
    burst.Roll = roll;
    burst.Pressure = press;
    clear cor amp vel time heading pitch roll press

     % Burst time
    t0 = min(burst.time);
    if abs(btime - t0) > 12/(60*24)
        disp('   WARNING: File name disagrees with recorded time. Using recorded time...   ')
        btime = t0;
    end
    
    %%%%%%% FLAGS %%%%%%=

    % Flag if coming in/out of the water
    if any(ischange(burst.Pressure))
        disp('   FLAG: Out-of-Water (temp/pressure change)...')
        outofwater = true;
    else
        outofwater = false;
    end

    % Flag out of water based on bursts w/anomalously high amplitude
    if mean(burst.AmplitudeData(:),'omitnan') < opt.minamp
        disp('   FLAG: Low Amp (low average amp)...')
        badamp = true;
    else
        badamp = false;
    end

    % Flag out of water based on bursts w/low correlation
    if mean(burst.CorrelationData(:),'omitnan') < opt.mincorr
        disp('   FLAG: Bad Corr (low average corr)...')
        badcorr = true;
    else
        badcorr = false;
    end

    badburst = outofwater | badamp | badcorr;

    %%%%%%% Process HR velocity data ('burst' structure) %%%%%%

    [HRprofile,fh] = processAQHburst(burst,opt);
    
    if isempty(HRprofile)
        HRprofile = NaNstructR(AQH(iaqh-1).HRprofile);
    end
    
   if opt.saveplots && ~isempty(fh)
    figure(fh(1))
    set(gcf,'Name',[bname '_HR_data'])
    figname = [bfiles(iburst).folder slash get(gcf,'Name')];
    print(figname,'-dpng')
    close gcf
   
   end
        
    %%%%%%%% Save detailed signature data in SIG structure %%%%%%%%

    %Time
    AQH(iaqh).time = btime;
    % HR data
    AQH(iaqh).HRprofile = HRprofile;
    % Motion
    AQH(iaqh).motion.pitch = mean(burst.Pitch,'omitnan');
    AQH(iaqh).motion.roll = mean(burst.Roll,'omitnan');
    AQH(iaqh).motion.head = mean(burst.Heading,'omitnan');
    AQH(iaqh).motion.pitchvar = var(burst.Pitch,'omitnan');
    AQH(iaqh).motion.rollvar = var(burst.Roll,'omitnan');
    AQH(iaqh).motion.headvar = var(unwrap(burst.Heading),'omitnan');
    % Badburst & flags
    AQH(iaqh).badburst = outofwater | badamp | badcorr;
    AQH(iaqh).flag.outofwater = outofwater;
    AQH(iaqh).flag.badamp = badamp;
    AQH(iaqh).flag.badcorr = badcorr;
    AQH(iaqh).flag.notimematch = false; % Updated below

    iaqh = iaqh+1;

 %%%%%%%% Match burst time to existing SWIFT fields and replace data %%%%%%%%

   if ~isempty(fieldnames(SWIFT)) && ~isempty(SWIFT)

        [tdiff,tindex] = min(abs([SWIFT.time]-btime));
        if tdiff > 12/(60*24)% must be within 10 min
            disp('   NO time index match...')
            timematch = false;
        elseif tdiff < 12/(60*24)
            timematch = true;
            burstreplaced(tindex) = true;
        elseif isempty(tdiff)
            disp('   NO time index match...')
            timematch = false;
        end

        if  timematch && ~badburst % time match, good burst
            % HR data
            SWIFT(tindex).uplooking = [];
            SWIFT(tindex).uplooking.w = HRprofile.w;
            SWIFT(tindex).uplooking.wvar = HRprofile.wvar;
            SWIFT(tindex).uplooking.z = HRprofile.z';
            SWIFT(tindex).uplooking.tkedissipationrate = HRprofile.eps;

        elseif timematch && badburst % time match, bad burst
            % HR data
            SWIFT(tindex).uplooking = [];
            SWIFT(tindex).uplooking.w = NaN(size(HRprofile.w));
            SWIFT(tindex).uplooking.wvar = NaN(size(HRprofile.w));
            SWIFT(tindex).uplooking.z = HRprofile.z';
            SWIFT(tindex).uplooking.tkedissipationrate = ...
                NaN(size(HRprofile.w'));

            badaqh(tindex) = true;

        elseif ~timematch && ~badburst % Good burst, no time match
            disp('   ALERT: Burst good, but no time match...')
            AQH(iaqh-1).flag.notimematch = true;

        end
    end

% End burst loop
end

%% Clean up and save

% NaN out SWIFT aqh fields which were not matched to bursts
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

%% Log reprocessing and flags, then save new L2 file or overwrite existing one

params = opt;

if isfield(sinfo,'postproc')
ip = length(sinfo.postproc)+1; 
else
    sinfo.postproc = struct;
    ip = 1;
end
sinfo.postproc(ip).type = 'AQH';
sinfo.postproc(ip).usr = getenv('username');
sinfo.postproc(ip).time = string(datetime('now'));
sinfo.postproc(ip).flags.badaqh = badaqh;
sinfo.postproc(ip).params = params;

save([sfile.folder slash sfile.name(1:end-7) '_L2.mat'],'SWIFT','sinfo')

%% Save SIG Structure + Plot %%%%%%%%

if opt.saveAQH
   save([sfile.folder slash sfile.name(1:end-7) '_burstavgAQH.mat'],'AQH')
end

% Plot burst Averaged SWIFT Signature Data
catAQH(AQH,'plot');
set(gcf,'Name',sfile.name(1:end-7))
if opt.saveplots
    figname = [missiondir slash get(gcf,'Name')];
    print([figname '_AQH'],'-dpng')
    close gcf
end

cd(missiondir)

end