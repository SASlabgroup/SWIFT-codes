function [SWIFT,sinfo] = L3_highresSWIFT(missiondir,burstdt,sigopt)

% Calculates higher res burst-averages using L1 SWIFT product. 
% K. Zeiden Aug 2025
%
% [SWIFT,sinfo] = L3_highresSWIFT(missiondir,burstdt,sigopt)
%
%% Develop first with SWIFT26 on June 26, Waldron Island Main Experiment
%
% missiondir = 'S:\SanJuanIslands\WaldronIsland_CoastalFronts2022\Main_Jun2022\SWIFTs\L0\SWIFT26_02Jul2022';
% missiondir = cd;
% burstdt = floor(8.5*60/10)/(60*60*24); % datenum units (days)
%%

if ispc
    slash = '\';
else
    slash = '/';
end

%% Load L1file

L1file = dir([missiondir slash '*L1.mat']);

if isempty(L1file)
    disp('No L1 product found.')
    return
else
    load([L1file.folder slash L1file.name],'SWIFT','sinfo');
end

%% Initialize new SWIFT

SWIFThr(1).time = [];
SWIFThr(1).burstID = [];
SWIFThr(1).signature = [];
SWIFThr(1).O2conc = [];
SWIFThr(1).O2concstddev = [];
SWIFThr(1).O2sat = [];
SWIFThr(1).O2satstddev = [];
SWIFThr(1).watertemp3 = [];
SWIFThr(1).watertemp3stddev = [];
SWIFThr(1).watertemp2 = [];
SWIFThr(1).watertemp2stddev = [];
SWIFThr(1).watertemp = [];
SWIFThr(1).watertempstddev = [];
SWIFThr(1).salinity = [];
SWIFThr(1).salinitystddev = [];
SWIFThr(1).outofwater = [];
SWIFThr(1).lon = [];
SWIFThr(1).lat = [];
SWIFThr(1).driftspd = [];
SWIFThr(1).driftdirT = [];
SWIFThr(1).windspd = [];
SWIFThr(1).windspdstddev = [];
SWIFThr(1).winddirT = [];
SWIFThr(1).winddirTstddev = [];
SWIFThr(1).airtemp = [];
SWIFThr(1).airtempstddev = [];
SWIFThr(1).airpres = [];
SWIFThr(1).airpresstddev = [];
SWIFThr(1).relhumidity = [];
SWIFThr(1).relhumiditystddev = [];
SWIFThr(1).wavespectra = [];
SWIFThr(1).sigwaveheight = [];

oneSWIFT = struct();

%% Loop through burst files and recompute mean + std 

for iburst = 1:length(SWIFT)

    burstID = SWIFT(iburst).burstID;
    t0 = SWIFT(iburst).time;
    time = t0:burstdt:(t0+(8.5/(60*24)));
    for it = 1:length(time)-1
        oneSWIFT(it).time = time(it);
        oneSWIFT(it).burstID = [burstID '_' num2str(it)];
    end

    sigfile = dir([missiondir slash '*' slash 'Raw' slash '*' slash '*SIG*' burstID '*.mat']);
    acsfile = dir([missiondir slash '*' slash 'Raw' slash '*' slash '*ACS*' burstID '*.mat']);
    pb2file = dir([missiondir slash '*' slash 'Raw' slash '*' slash '*PB2*' burstID '*.mat']);
    sbgfile = dir([missiondir slash '*' slash 'Raw' slash '*' slash '*SBG*' burstID '*.mat']);
    acofile = dir([missiondir slash '*' slash 'Raw' slash '*' slash '*ACO*' burstID '*.mat']);

    %% Signature 1000

   disp(['Processing burst ' burstID ':'])

    if isempty(sigfile)
        disp('- No SIG file. Skipping.')
        continue        
    else
        sig = load([sigfile.folder slash sigfile.name]);
    end

    % Make sure correct data structures
    if ~isfield(sig,'burst')
        disp('- Wrong SIG data format. Skipping.')
        continue
    end

    % Make sure Signature dimensions are correct
    if length(size(sig.burst.VelocityData)) > 2 || length(size(sig.burst.AmplitudeData)) > 2 || length(size(sig.burst.CorrelationData)) > 2
        disp('   SIG HR data dimensions bad. Skipping.')
        continue
    end

    % Make sure long enough
    if range(sig.burst.time) < 4/(24*60)
        disp('- SIG burst too short. Skipping.')
        continue
    end

    % Adjust time vectors
    sigtoff = sig.burst.time(1)-t0;
    sig.burst.time = sig.burst.time - sigtoff;
    sig.avg.time = sig.avg.time - sigtoff;
    if isfield(sig,'echo') && ~isempty(sig.echo)
        sig.echo.time = sig.echo.time - sigtoff;
    end

    % Loop through time intervals, select data and reprocess
    for it = 1:length(time)-1

        % HR data
        burstint = sig.burst.time >= time(it) & sig.burst.time < time(it+1);
        burstfields = fieldnames(sig.burst);
        for ivar = 1:length(burstfields)
            if any(size(sig.burst.(burstfields{ivar})) == 1) && length(sig.burst.(burstfields{ivar})) ~= 1
                sighr.burst.(burstfields{ivar}) = sig.burst.(burstfields{ivar})(burstint);
            elseif ~any(size(sig.burst.(burstfields{ivar})) == 1) && length(sig.burst.(burstfields{ivar})) ~= 1
                sighr.burst.(burstfields{ivar}) = sig.burst.(burstfields{ivar})(burstint,:);
            else
                sighr.burst.(burstfields{ivar}) = sig.burst.(burstfields{ivar});
            end
        end
        [HRprofile,~] = processSIGburst(sighr.burst,sigopt);
        oneSWIFT(it).signature.HRprofile = [];
        oneSWIFT(it).signature.HRprofile.w = HRprofile.w;
        oneSWIFT(it).signature.HRprofile.wvar = HRprofile.wvar;
        oneSWIFT(it).signature.HRprofile.z = HRprofile.z;
        oneSWIFT(it).signature.HRprofile.tkedissipationrate = ...
            HRprofile.eps;
        oneSWIFT(it).watertemp2 = mean(sighr.burst.Temperature,'omitnan');
        oneSWIFT(it).watertemp2stddev = std(sighr.burst.Temperature,[],'omitnan');

        % BB data
        avgint = sig.avg.time >= time(it) & sig.avg.time < time(it+1);
        avgfields = fieldnames(sig.avg);
        for ivar = 1:length(avgfields)
            if any(size(sig.avg.(avgfields{ivar})) == 1) && length(sig.avg.(avgfields{ivar})) ~= 1
                sighr.avg.(avgfields{ivar}) = sig.avg.(avgfields{ivar})(avgint);
            elseif ~any(size(sig.avg.(avgfields{ivar})) == 1) && length(sig.avg.(avgfields{ivar})) ~= 1 && ismatrix(sig.avg.(avgfields{ivar}))
                sighr.avg.(avgfields{ivar}) = sig.avg.(avgfields{ivar})(avgint,:);
            elseif ~any(size(sig.avg.(avgfields{ivar})) == 1) && length(sig.avg.(avgfields{ivar})) ~= 1 && ~ismatrix(sig.avg.(avgfields{ivar}))
                sighr.avg.(avgfields{ivar}) = sig.avg.(avgfields{ivar})(avgint,:,:);
            else
                sighr.avg.(avgfields{ivar}) = sig.avg.(avgfields{ivar});
            end
        end
        [profile,~] = processSIGavg(sighr.avg,sigopt);
        oneSWIFT(it).signature.profile = [];
        oneSWIFT(it).signature.profile.east = profile.u;
        oneSWIFT(it).signature.profile.north = profile.v;
        oneSWIFT(it).signature.profile.w = profile.w;
        oneSWIFT(it).signature.profile.uvar = profile.uvar;
        oneSWIFT(it).signature.profile.vvar = profile.vvar;
        oneSWIFT(it).signature.profile.wvar = profile.wvar;
        oneSWIFT(it).signature.profile.z = profile.z;
        oneSWIFT(it).signature.profile.spd_alt = profile.spd_alt;

        % Echogram data
        if isfield(sig,'echo') && ~isempty(sig.echo)
        ntecho = length(sig.echo.time);
        echoint = sig.echo.time >= time(it) & sig.echo.time < time(it+1);
        echofields = fieldnames(sig.echo);
        for ivar = 1:length(echofields)
            if any(size(sig.echo.(echofields{ivar})) == 1) && length(sig.echo.(echofields{ivar})) == ntecho
                
                sighr.echo.(echofields{ivar}) = sig.echo.(echofields{ivar})(echoint);
            elseif ~any(size(sig.echo.(echofields{ivar})) == 1) && length(sig.echo.(echofields{ivar})) ~= 1
                sighr.echo.(echofields{ivar}) = sig.echo.(echofields{ivar})(echoint,:);
            elseif all(size(sig.echo.(echofields{ivar})) == 1)
                sighr.echo.(echofields{ivar}) = sig.echo.(echofields{ivar});
            else
                sighr.echo.(echofields{ivar}) = NaN(1,sum(echoint));
            end
        end
        S = SWIFT(iburst).salinity;
        [echogram,~] = processSIGecho(sighr.echo,S,sigopt);
        oneSWIFT(it).signature.echo = echogram.echoc;
        oneSWIFT(it).signature.echoz = echogram.r + sig.echo.Blanking + sigopt.xz;
        end

    end

    %% ACS 
    if isempty(acsfile)
       disp('- No ACS file.')
        acs.time = sig.burst.time;
        acs.Temperature = NaN(size(acs.time));
        acs.Salinity = NaN(size(acs.time));
    else
        acs = load([acsfile.folder slash acsfile.name]);
        acs.time = t0 + ((0:length(acs.Temperature)-1)./0.5)./(60*60*24);
    end

    % Deal with data wrong sized.
    imin = min([length(acs.Temperature) length(acs.Salinity) length(acs.time)]);
    acs.Temperature = acs.Temperature(1:imin);
    acs.Salinity = acs.Salinity(1:imin);
    acs.time = acs.time(1:imin);

    % Loop through time intervals, select data and reprocess

    for it = 1:length(time) - 1
       acsint = acs.time >= time(it) & acs.time < time(it+1);

        cropSalinity = acs.Salinity(acsint);
        cropTemperature = acs.Temperature(acsint);

        % Out of water
        iout = cropSalinity < 1;
        if sum(iout)/length(cropSalinity) > 0.1
            oneSWIFT(it).outofwater = true;
        else
            oneSWIFT(it).outofwater = false;
        end
        cropSalinity(iout) = NaN;
        cropTemperature(iout) = NaN;
    
        % Salinity spikes/dropouts
        ispikesal = isoutlier(cropSalinity,'movmedian',30);
        if sum(~ispikesal) > 3
        cropSalinity = interp1(find(~ispikesal),cropSalinity(~ispikesal),1:length(cropSalinity));
        end
    
         % Temperature spikes
        ispiketemp = isoutlier(cropTemperature,'movmedian',30);
        if sum(~ispiketemp) > 3
        cropTemperature = interp1(find(~ispiketemp),cropTemperature(~ispiketemp),1:length(cropTemperature));
        end
    
        % Mean values
        meanwatertempclean = mean(cropTemperature,'omitnan');
        watertempstddev = std(cropTemperature,[],'omitnan');
        meansalinityclean = mean(cropSalinity,'omitnan');
        salinitystddev = std(cropSalinity,[],'omitnan');

        % Add to SWIFT structure
        oneSWIFT(it).watertemp = meanwatertempclean;
        oneSWIFT(it).watertempstddev = watertempstddev;
        oneSWIFT(it).salinitystddev = salinitystddev;
        oneSWIFT(it).salinity = meansalinityclean;

    end

    %% ACO

    if isempty(acofile)
       disp('- No ACO file.')
        aco.time = sig.burst.time;
        aco.O2Concentration = NaN(size(sig.burst.time));
        aco.Temp = NaN(size(sig.burst.time));
        aco.AirSat = NaN(size(sig.burst.time));
    else
        aco = load([acofile.folder slash acofile.name]);aco = aco.O2;
        aco.time = t0 + (0:length(aco.O2Concentration)-1)./(60*60*24);
    end

     % Loop through time intervals, select data and reprocess
    for it = 1:length(time)-1
       acoint = aco.time >= time(it) & aco.time < time(it+1);

        cropO2 = aco.O2Concentration(acoint);
        croptemp = aco.Temp(acoint);
        cropairsat = aco.AirSat(acoint);
    
        % Add to SWIFT structure
        oneSWIFT(it).O2conc = mean(cropO2,'omitnan');
        oneSWIFT(it).O2concstddev = std(cropO2,[],'omitnan');
        oneSWIFT(it).O2sat = mean(cropairsat,'omitnan');
        oneSWIFT(it).O2satstddev = std(cropairsat,[],'omitnan');
        oneSWIFT(it).watertemp3 = mean(croptemp,'omitnan');
        oneSWIFT(it).watertemp3stddev = std(croptemp,[],'omitnan');
    end

    %% Airmar
    if isempty(pb2file)
        disp('- No PB2 file.')
        pb2.time = sig.burst.time;
        pb2.rawwindspd = NaN(size(pb2.time));
        pb2.rawwinddir = NaN(size(pb2.time));
        pb2.rawairtemp = NaN(size(pb2.time));
        pb2.rawairpres = NaN(size(pb2.time));
        pb2.lat = NaN(size(pb2.time));
        pb2.lon = NaN(size(pb2.time));
        pb2.sog = NaN(size(pb2.time));
        pb2.cog = NaN(size(pb2.time));
        pb2.pitch = NaN(size(pb2.time));
        pb2.roll = NaN(size(pb2.time));
    else
        pb2 = load([pb2file.folder slash pb2file.name]);
        pb2.rawwindspdclean = filloutliers(pb2.rawwindspd,'linear','mean');
        if length(pb2.rawwindspd) ~= length(pb2.time)
            pb2.time = min(pb2.time)+ (0:(length(pb2.rawwindspd)-1))*0.5;
        end
        pb2.time = pb2.time - sigtoff;
    end

   % Check airpressure units (if O(10), is in inches of mercury)
   if mean(pb2.rawairpres,'omitnan') < 500
       pb2.rawairpres = pb2.rawairpres.*33.8639;% Convert to mb
   end

   % Despike
   pb2fields = fieldnames(pb2);
   pb2fields = pb2fields(~contains(pb2fields,'time'));
   for ivar = 1:length(pb2fields)
       % Despike
       var = pb2.(pb2fields{ivar});
        ispike = var > median(var)+3*std(var,'omitnan');
        if sum(~ispike) > 3
            var = interp1(find(~ispike),var(~ispike),1:length(var));
        else
            var = NaN(size(var));
        end
        pb2.(pb2fields{ivar}) = var;
   end

   % Compute drift spd
    lat0 = mean(pb2.lat,'omitnan');
    dt = 0.5;% seconds
    dlondt = gradient(pb2.lon)./dt; % deg/s
    pb2.u = deg2km(dlondt,6371*cosd(lat0)).*1000; % m/s
    dlatdt = gradient(pb2.lat)./dt; % deg/s
    pb2.v = deg2km(dlatdt).*1000; % m/s
    pb2.u(isinf(pb2.u)) = NaN;
    pb2.u = filloutliers(pb2.u,'linear');
    pb2.v(isinf(pb2.v)) = NaN;
    pb2.v = filloutliers(pb2.v,'linear');
    pb2.driftspd = sqrt(pb2.u.^2 + pb2.v.^2); % m/s
    pb2.driftdirT = -180 ./ 3.14 .* atan2d(pb2.v,pb2.u); % cartesian direction [deg]
    pb2.driftdirT = pb2.driftdirT + 90;  % rotate from eastward = 0 to northward  = 0
    pb2.driftdirT( pb2.driftdirT<0) = pb2.driftdirT( pb2.driftdirT<0 ) + 360; % make quadrant II 270->360 instead of -90 -> 0

   % Loop through time intervals, select data and reprocess
   for it = 1:length(time)-1

      pb2int = pb2.time >= time(it) & pb2.time < time(it+1);

      if sum(pb2int) == 0

        oneSWIFT(it).lon = NaN;
        oneSWIFT(it).lat = NaN;
        oneSWIFT(it).windspd = NaN;
        oneSWIFT(it).windspdstddev = NaN; 
        oneSWIFT(it).winddirT = NaN;
        oneSWIFT(it).winddirTstddev =  NaN;
        oneSWIFT(it).airtemp = NaN; 
        oneSWIFT(it).airtempstddev = NaN; 
        oneSWIFT(it).airpres = NaN; 
        oneSWIFT(it).airpresstddev = NaN; 
        oneSWIFT(it).relhumidity = NaN;
        oneSWIFT(it).relhumiditystddev = NaN;
        oneSWIFT(it).driftspd = NaN;
        oneSWIFT(it).driftdirT = NaN;
    
      else

        oneSWIFT(it).lon = mean(pb2.lon(pb2int),'omitnan');
        oneSWIFT(it).lat = mean(pb2.lat(pb2int),'omitnan');
        oneSWIFT(it).windspd = mean(pb2.rawwindspd(pb2int),'omitnan');
        oneSWIFT(it).windspdstddev = std(pb2.rawwindspd(pb2int),[],'omitnan'); 
        oneSWIFT(it).winddirT = mean(pb2.rawwinddir(pb2int),'omitnan');
        oneSWIFT(it).winddirTstddev =  std(pb2.rawwinddir(pb2int),[],'omitnan'); 
        oneSWIFT(it).airtemp = mean(pb2.rawairtemp(pb2int),'omitnan'); 
        oneSWIFT(it).airtempstddev = std(pb2.rawairtemp(pb2int),[],'omitnan');  
        oneSWIFT(it).airpres = mean(pb2.rawairpres(pb2int),'omitnan'); 
        oneSWIFT(it).airpresstddev = std(pb2.rawairpres(pb2int),[],'omitnan');  
        if isfield(pb2,'rawrelhumidity')
        oneSWIFT(it).relhumidity = mean(pb2.rawrelhumidity(pb2int),'omitnan');
        oneSWIFT(it).relhumiditystddev = NaN;
        else
           oneSWIFT(it).relhumidity = NaN;
           oneSWIFT(it).relhumiditystddev = NaN;
        end
        oneSWIFT(it).driftspd = mean(pb2.driftspd(pb2int),'omitnan');
        oneSWIFT(it).driftdirT = meandir(pb2.driftdirT(pb2int));

      end

   end

    %% SBG Ellipse N(?)

    sbg = load([sbgfile.folder slash sbgfile.name],'sbgData');sbg = sbg.sbgData;

    if ~isempty(sbg.UtcTime.time_stamp)

        % Fill outliers in timestamps
        sbgfs = 1./(median(diff(sbg.UtcTime.time_stamp),'omitnan').*10^(-6));
        fields = fieldnames(sbg);
        for idf = 1:length(fields)
            sbg.(fields{idf}).time_stamp = filloutliers(sbg.(fields{idf}).time_stamp,...
                'linear','movmedian',sbgfs);
        end
    
        % SBG angular velocity
        sbgangvel = sqrt(sbg.ImuData.gyro_x.^2 + ...
            sbg.ImuData.gyro_y.^2 + sbg.ImuData.gyro_z.^2).*180/pi;
        igood = sbgangvel < 360;
        sbgangvel = interp1(find(igood),sbgangvel(igood),1:length(sbgangvel));
        sbgtime = sbg.ImuData.time_stamp*10^(-6);% seconds
    
        % SIG angular velocity
        sigangvel = sqrt(sig.burst.AHRS_GyroX.^2 + sig.burst.AHRS_GyroY.^2 + sig.burst.AHRS_GyroZ.^2);
        sigfs = round(1./(median(diff(sig.burst.time))*24*60*60));
        sigtime = (sig.burst.time-sig.burst.time(1))*24*60*60;% seconds
    
        % Interpolate SBG angular velocity to SIG time
        [~,iu] = unique(sbgtime);
        sbgangvel = interp1(sbgtime(iu),sbgangvel(iu),sigtime,'linear');
        sbgangvel(isnan(sbgangvel)) = 0;
    
        % Compute lagged correlation to find offset
        [r,lags] = xcorr(sigangvel,sbgangvel,'normalized');
        [~,imaxcorr] = max(r);
        sbgtoff = lags(imaxcorr)./sigfs;% seconds
    
        % Heave
        z = sbg.ShipMotion.heave(:)';
        ztime = sbg.ShipMotion.time_stamp(:)'*10^(-6);% Convert to seconds
        imin = min([length(z) length(ztime)]);
        z = z(1:imin);ztime = ztime(1:imin);
        [~,iu] = unique(ztime);z = z(iu);ztime = ztime(iu);
        igood = ~isnan(z) & ztime ~= 0 & abs(z) < 30;
        z = interp1(ztime(igood),z(igood),sbgtime);
        z(isnan(z)) = mean(z,'omitnan');
    
        % Crop first minute and apply offset
        z = z(60*sbgfs:end);
        sbgtime = (sbgtime(60*sbgfs:end) + sbgtoff)./(24*60*60) + sig.burst.time(1);
    
        % Loop through intervals and compute wave spectrum
        nwinE = floor((256*sbgfs)/11);
        df = 1/(nwinE/sbgfs);
        f = 0:df:(sbgfs/2 - df);
        for it = 1:length(time)-1
        
            sbgint = sbgtime >= time(it) & sbgtime < time(it+1);
            if sum(sbgint) > nwinE*2
        
            % wave spectrum
            [E,~,~,~,~] = hannwinPSD2(z(sbgint)',nwinE,sbgfs,'par');
        
            % significant wave height
            ifreqsigH = f > 0.05 & f < 1;
            Hs  = 4*sqrt(sum(E(ifreqsigH)*df,'omitnan'));
        
            oneSWIFT(it).wavespectra.energy = E;
            oneSWIFT(it).wavespectra.freq = f;
            oneSWIFT(it).sigwaveheight = Hs;
        
            else
                oneSWIFT(it).wavespectra.energy = NaN(1,nwinE/2);
                oneSWIFT(it).wavespectra.freq = f;
                oneSWIFT(it).sigwaveheight = NaN;
        
            end
    
        end

    else % Empty SBG structure
        nwinE = floor((256*5)/11);
        df = 1/(nwinE/5);
        f = 0:df:(5/2 - df);
        nf = length(f);

        for it = 1:length(time)-1
            oneSWIFT(it).wavespectra.energy = NaN(1,nf);
            oneSWIFT(it).wavespectra.freq = f;
            oneSWIFT(it).sigwaveheight = NaN;
        end
    end

    %% Concatenate new burst averaged data to SWIFThr structure
    SWIFThr = [SWIFThr oneSWIFT];

end % End burst

SWIFThr = SWIFThr(2:end);
SWIFT = SWIFThr;

% Pull out outofwater
outofwater = [SWIFT.outofwater];
SWIFT = rmfield(SWIFT,'outofwater');

%% Save info in 'sinfo'
% This is really just for symmetry and to track out of water

% SIG
if ~isempty(sigfile)
    if isfield(sinfo,'postproc')
    ip = length(sinfo.postproc)+1; 
    else
        sinfo.postproc = struct;
        ip = 1;
    end
    sinfo.postproc(ip).type = 'SIG';
    sinfo.postproc(ip).usr = getenv('username');
    sinfo.postproc(ip).time = string(datetime('now'));
    sinfo.postproc(ip).flags = [];
end

% ACS
if ~isempty(acsfile)
    if isfield(sinfo,'postproc')
    ip = length(sinfo.postproc)+1; 
    else
        sinfo.postproc = struct;
        ip = 1;
    end
    sinfo.postproc(ip).type = 'ACS';
    sinfo.postproc(ip).usr = getenv('username');
    sinfo.postproc(ip).time = string(datetime('now'));
    sinfo.postproc(ip).flags.outofwater = outofwater;
end

% ACO
if ~isempty(acofile)
    if isfield(sinfo,'postproc')
    ip = length(sinfo.postproc)+1; 
    else
        sinfo.postproc = struct;
        ip = 1;
    end
    sinfo.postproc(ip).type = 'ACO';
    sinfo.postproc(ip).usr = getenv('username');
    sinfo.postproc(ip).time = string(datetime('now'));
    sinfo.postproc(ip).flags= [];
end

% PB2
if ~isempty(pb2file)
    if isfield(sinfo,'postproc')
    ip = length(sinfo.postproc)+1; 
    else
       sinfo.postproc = struct;
       ip = 1;
    end
    sinfo.postproc(ip).type = 'PB2';
    sinfo.postproc(ip).usr = getenv('username');
    sinfo.postproc(ip).time = string(datetime('now'));
    sinfo.postproc(ip).params = [];
end

% SBG
if ~isempty(sbgfile)
    if isfield(sinfo,'postproc')
    ip = length(sinfo.postproc)+1; 
    else
        sinfo.postproc = struct;
        ip = 1;
    end
    sinfo.postproc(ip).type = 'SBG';
    sinfo.postproc(ip).usr = getenv('username');
    sinfo.postproc(ip).time = string(datetime('now'));
end

%% Save

save([L1file.folder slash L1file.name(1:end-6) 'L3_highres.mat'],'SWIFT','sinfo')

%% Plot

if length(SWIFT) == 0
    disp('All data Out of water')
    return
end

swift = catSWIFT(SWIFT(~outofwater));

vars = fieldnames(swift);
time0 = swift.time;
time = min(time0):median(diff(time0)):max(time0);
nt0 = length(swift.time);
nt = length(time);
for ivar = 1:length(vars)

    var = swift.(vars{ivar});

    if strcmp(vars{ivar},'time') || ~any(size(var) == nt0)
        continue
    end

    ny = size(var,1);
    varfull = NaN(ny,nt);

    for it = 1:nt0
        [dt,imatch] = min(abs(time0(it) - time));
        if dt < 60/(60*60*24)
        varfull(:,imatch) = var(:,it);
        end
    end

    swift.(vars{ivar}) = varfull;

end
swift.time = time;

fh = figure('color','w','Name',[L1file.name(1:end-6) 'L3_highres']);
fullscreen
h = tight_subplot(7,1);

% Wind
axes(h(1))
yyaxis left
plot(swift.time,swift.windu,'-k','LineWidth',2)
ylabel('U [ms^{-1}]')
yyaxis right
plot(swift.time,swift.wavesigH,'-','color',rgb('grey'),'LineWidth',2)
set(gca,'YColor',rgb('grey'));
ylabel('H [m]')
legend('Wind','Waves')
axis tight
title('Wind + Waves');
set(gca,'Fontsize',8)

% Temp
axes(h(2))
yyaxis left
plot(swift.time,swift.tsea,'-b','LineWidth',2)
hold on
plot(swift.time,swift.tsea2,'-','color',rgb('cornflowerblue'),'LineWidth',2)
plot(swift.time,swift.tsea3,'-','color',rgb('Dodgerblue'),'LineWidth',2)
set(gca,'YColor','b')
ylabel('T [^{\circ}C]')
% Sal
yyaxis right
plot(swift.time,swift.sal,'r','LineWidth',2)
set(gca,'YColor','r')
ylabel('S [psu]')
legend('T_{CT}','T_{SIG}','T_{ACO}','S')
axis tight
title('Temperature + Salinity');
set(gca,'Fontsize',8)

% Oxygen
axes(h(3))
plot(swift.time,swift.O2conc,'color',rgb('grey'),'LineWidth',2)
ylabel('O_2 [uM]')
axis tight
title('Oxygen Concentration');
set(gca,'Fontsize',8)

% Downwelling
axes(h(4))
pcolor(swift.time,-swift.surfz,swift.surfw);shading flat
axis tight
c = slimcolorbar;c.Label.String = 'W [ms^{-1}]';
cmocean('balance');clim([-0.1 0.1])
ylabel('Z [m]')
title('Downwelling');
set(gca,'Fontsize',8)

% Turbulence
axes(h(5))
pcolor(swift.time,-swift.surfz,log10(swift.surftke));shading flat
axis tight
c = slimcolorbar;c.Label.String = '\epsilon [m^2s^{-3}]';
c.Ticks = -8:2:-4;c.TickLabels = {'10^{-8}','10^{-6}','10^{-4}'};
colormap(gca,colorcet('R4'));clim([-8 -4]);
ylabel('Z [m]')
title('TKE Dissipation Rate');
set(gca,'Fontsize',8)

% Echogram
axes(h(7))
if ~isfield(swift,'echo')
    swift.echo = NaN(500,length(swift.time));
    swift.echoz = -20 + 0.04*(1:500) -0.1 - 0.2;
end
h(7).Position = h(7).Position.*[1 1 1 2];
pcolor(swift.time,-swift.echoz,swift.echo);shading flat
hold on
axis tight
plot(xlim,[-3 -3],'--k')
c = slimcolorbar;c.Label.String = 'E [db]';
c.Ticks = -8:2:-4;c.TickLabels = {'10^{-8}','10^{-6}','10^{-4}'};
cmocean('thermal');clim([60 120])
ylabel('Z [m]')
title('Echogram');
set(gca,'Fontsize',8)

rmemptysub
h = h([1:5 7]);
linkaxes(h,'x')
set(h(1:end-1),'XTickLabel',[])
datetick('x')

set(fh,'Name',[ L1file.name(1:end-6) 'L3_highres'])
print(fh,[L1file.folder slash L1file.name(1:end-6) 'L3_highres'],'-dpng')

end
