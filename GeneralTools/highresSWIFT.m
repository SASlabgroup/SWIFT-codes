% function SWIFT = highresSWIFT(missiondir,burstint,sigopt)

% Calculates higher res burst-averages using L1 SWIFT product. 
% K. Zeiden Aug 2025

% Develop first with SWIFT26 on June 26, Waldron Island Main Experiment
missiondir = 'S:\SanJuanIslands\WaldronIsland_CoastalFronts2022\Main_Jun2022\SWIFTs\L0\SWIFT26_26Jun2022';
burstdt = round(8.5*60/10)/(60*60*24); % datenum units (days)
load('S:\SanJuanIslands\WaldronIsland_CoastalFronts2022\Main_Jun2022\SWIFTs\L0\SIGopt.mat')


%%

if ispc
    slash = '\';
else
    slash = '/';
end

%% Load L1file

L1file = dir([missiondir slash '*L1.mat']);

if isempty(L1file)
    disp(['No L1 product found for ' sname '.'])
    return
else
    load([L1file.folder slash L1file.name],'SWIFT');
end

SN = SWIFT(1).ID;

%% Initialize new SWIFT

SWIFThr(1).time = [];
SWIFThr(1).burstID = [];
SWIFThr(1).signature = [];
SWIFThr(1).watertemp2 = [];
SWIFThr(1).watertemp2stddev = [];
SWIFThr(1).outofwater = [];
SWIFThr(1).watertemp = [];
SWIFThr(1).watertempstddev = [];
SWIFThr(1).salinity = [];
SWIFThr(1).salinitystddev = [];
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

    sigfile = dir([missiondir slash '*' slash 'Raw' slash '*' slash '*SIG*' burstID '.mat']);
    acsfile = dir([missiondir slash '*' slash 'Raw' slash '*' slash '*ACS*' burstID '.mat']);
    pb2file = dir([missiondir slash '*' slash 'Raw' slash '*' slash '*PB2*' burstID '.mat']);
    sbgfile = dir([missiondir slash '*' slash 'Raw' slash '*' slash '*SBG*' burstID '.mat']);

    %% Signature 1000

    if isempty(sigfile)
       disp(['No mat file found for ' burstID '. Skipping.'])
        % continue        
    else
        sig = load([sigfile.folder slash sigfile.name]);
    end

    % Adjust time vectors
    sigtoff = sig.burst.time(1)-t0;
    sig.burst.time = sig.burst.time - sigtoff;
    sig.avg.time = sig.avg.time - sigtoff;
    if isfield(sig,'echo')
        sig.echo.time = sig.echo.time - sigtoff;
    end

    % Loop through time intervals, select data and reprocess
    for it = 1:length(time)-1

        % HR data
        burstint = sig.burst.time >= time(it) & sig.burst.time < time(it+1);
        burstfields = fieldnames(sig.burst);
        for ifield = 1:length(burstfields)
            if any(size(sig.burst.(burstfields{ifield})) == 1) && length(sig.burst.(burstfields{ifield})) ~= 1
                sighr.burst.(burstfields{ifield}) = sig.burst.(burstfields{ifield})(burstint);
            elseif ~any(size(sig.burst.(burstfields{ifield})) == 1) && length(sig.burst.(burstfields{ifield})) ~= 1
                sighr.burst.(burstfields{ifield}) = sig.burst.(burstfields{ifield})(burstint,:);
            else
                sighr.burst.(burstfields{ifield}) = sig.burst.(burstfields{ifield});
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
        for ifield = 1:length(avgfields)
            if any(size(sig.avg.(avgfields{ifield})) == 1) && length(sig.avg.(avgfields{ifield})) ~= 1
                sighr.avg.(avgfields{ifield}) = sig.avg.(avgfields{ifield})(avgint);
            elseif ~any(size(sig.avg.(avgfields{ifield})) == 1) && length(sig.avg.(avgfields{ifield})) ~= 1 && ismatrix(sig.avg.(avgfields{ifield}))
                sighr.avg.(avgfields{ifield}) = sig.avg.(avgfields{ifield})(avgint,:);
            elseif ~any(size(sig.avg.(avgfields{ifield})) == 1) && length(sig.avg.(avgfields{ifield})) ~= 1 && ~ismatrix(sig.avg.(avgfields{ifield}))
                sighr.avg.(avgfields{ifield}) = sig.avg.(avgfields{ifield})(avgint,:,:);
            else
                sighr.avg.(avgfields{ifield}) = sig.avg.(avgfields{ifield});
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
        if isfield(sig,'echo')
        echoint = sig.echo.time >= time(it) & sig.echo.time < time(it+1);
        echofields = fieldnames(sig.echo);
        for ifield = 1:length(echofields)
            if any(size(sig.echo.(echofields{ifield})) == 1) && length(sig.echo.(echofields{ifield})) ~= 1
                sighr.echo.(echofields{ifield}) = sig.echo.(echofields{ifield})(echoint);
            elseif ~any(size(sig.echo.(echofields{ifield})) == 1) && length(sig.echo.(echofields{ifield})) ~= 1
                sighr.echo.(echofields{ifield}) = sig.echo.(echofields{ifield})(echoint,:);
            else
                sighr.echo.(echofields{ifield}) = sig.echo.(echofields{ifield});
            end
        end
        S = SWIFT(iburst).salinity;
        [echogram,fh] = processSIGecho(sighr.echo,S,sigopt);
        oneSWIFT(it).signature.echo = echogram.echoc;
        oneSWIFT(it).signature.echoz = echogram.r + sig.echo.Blanking + sigopt.xz;
        end


    end

    %% ACS 
    if isempty(acsfile)
       disp(['No ADCS file found for ' burstID])
        acs.time = sig.burst.time;
        acs.Temperature = NaN(size(acs.time));
        acs.Salinity = NaN(size(acs.time));
    else
        acs = load([acsfile.folder slash acsfile.name]);
        acs.time = t0 + ((0:length(acs.Temperature)-1)./0.5)./(60*60*24);
    end

    % Loop through time intervals, select data and reprocess
    for it = 1:length(time)-1
       acsint = acs.time >= time(it) & acs.time < time(it+1);

        cropSalinity = acs.Salinity(acsint);
        cropTemperature = acs.Temperature(acsint);

        % Out of water
        iout = cropSalinity < 1;
        if sum(iout)/length(cropSalinity) > 0.1
            oneSWIFT(it).outofwater = true;
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

    %% Airmar
    if isempty(pb2file)
        disp(['No PB2 file found for ' burstID])
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
   for ifield = 1:length(pb2fields)
       % Despike
       var = pb2.(pb2fields{ifield});
        ispike = var > median(var)+3*std(var,'omitnan');
        if sum(~ispike) > 3
            var = interp1(find(~ispike),var(~ispike),1:length(var));
        else
            var = NaN(size(var));
        end
        pb2.(pb2fields{ifield}) = var;
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

    %% add new burst intervals to SWIFT structure
    SWIFThr = [SWIFThr oneSWIFT];

end % End burst

SWIFThr = SWIFThr(2:end);
