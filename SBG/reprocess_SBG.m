function [SWIFT,sinfo] = reprocess_SBG(missiondir,plotburst,saveraw,useGPS,interpf,tstart)


% Batch Matlab read-in and reprocess of SWIFT v4 SBG wave data
%   reprocessing is necessary to fix a bug in directional momements
%   all data prior 11/2017 need this reprocessing
%
% M. Schwendeman, 01/2017
% J. Thomson, 10/2017 add reprocessing to batch read of raw data,
%                   and replace SWIFT data structure results.
% K. Zeiden, July 2024
%   reformatting for use in master postprocessing script,
%   'postprocess_SWIFT'. 
%   Turned into function with mission directory as input

% Changed to fixed start (tstart, in seconds)

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

%% Length of raw burst data to process, from end of burst (must be > 1536/5 = 307.2 s)
% tproc = 475;% seconds
% Moved to input, changed to fixed start, K. Zeiden 05/22/2025

%% Sampling Rate
fs = 5; % should be 5 Hz for standard SBG settings

%% Flag bad wave data
badwaves = false(1,length(SWIFT));
SWIFTreplaced = false(1,length(SWIFT));

%% Loop through raw burst files and reprocess

bfiles = dir([missiondir slash '*' slash 'Raw' slash '*' slash '*SBG*.dat']);

for iburst = 1:length(bfiles)

    bname = bfiles(iburst).name(1:end-4);

   disp(['Burst ' num2str(iburst) ' : ' bname])

   % Read or load raw IMU data
    if isempty(dir([bfiles(iburst).folder slash bfiles(iburst).name(1:end-4) '.mat']))
        disp('Reading raw SBG data...')
        sbgData = sbgBinaryToMatlab([bfiles(iburst).folder slash bfiles(iburst).name]);
        save([bfiles(iburst).folder slash bfiles(iburst).name(1:end-4) '.mat'],'sbgData'),
    else
        load([bfiles(iburst).folder slash bfiles(iburst).name(1:end-4) '.mat'],'sbgData')
    end

    % Find burst index in the existing SWIFT structure
    burstID = bfiles(iburst).name(13:end-4);
    sindex = find(strcmp(burstID,{SWIFT.burstID}'));
    if isempty(sindex)
        disp('No matching SWIFT index. Skipping...')
        continue
    end

    % If not enough data to work with, skip burst
    if length(sbgData.ShipMotion.heave)-tstart*5 < 256*fs
            disp('Not enough data. Skipping...')
            continue
    end

    % IMU Motion
    z = sbgData.ShipMotion.heave(:)';
    x = sbgData.ShipMotion.surge(:)';
    y = sbgData.ShipMotion.sway(:)';
    ztime = sbgData.ShipMotion.time_stamp(:)'*10^(-6);% Convert to seconds
    imin = min([length(x) length(y) length(z) length(ztime)]);
    x = x(1:imin);y = y(1:imin);z = z(1:imin);ztime = ztime(1:imin);
    [~,iu] = unique(ztime);x = x(iu);y = y(iu);z = z(iu);ztime = ztime(iu);

    % GPS position
    lat = sbgData.GpsPos.lat(:)';
    lon = sbgData.GpsPos.long(:)';
    ltime = sbgData.GpsPos.time_stamp(:)'*10^(-6);
    imin = min([length(lon) length(lat) length(ltime)]);
    lat = lat(1:imin); lon = lon(1:imin); ltime = ltime(1:imin);
    [~,iu] = unique(ltime);lon = lon(iu);lat = lat(iu);ltime = ltime(iu);

    % GPS motion
    u = sbgData.GpsVel.vel_e(:)';
    v = sbgData.GpsVel.vel_n(:)';
    gpstime = sbgData.GpsVel.time_stamp(:)'*10^(-6);
    imin = min([length(u) length(v) length(gpstime)]);
    u = u(1:imin); v = v(1:imin); gpstime = gpstime(1:imin);
    [~,iu] = unique(gpstime);
    u = u(iu);v = v(iu);gpstime = gpstime(iu);

    % Interpolate to common time, using GPS time
    igood = ~isnan(lat) & ~isnan(lon) & ltime ~= 0;
    lat = interp1(ltime(igood),lat(igood),gpstime);
    lon = interp1(ltime(igood),lon(igood),gpstime);
    igood = ~isnan(x) & ~isnan(y) & ~isnan(z) & ztime ~= 0;
    z = interp1(ztime(igood),z(igood),gpstime);
    x = interp1(ztime(igood),x(igood),gpstime);
    y = interp1(ztime(igood),y(igood),gpstime);

    if plotburst

            figure('color','w')
            MP = get(0,'monitorposition');
            set(gcf,'outerposition',MP(1,:));
            subplot(3,1,1)
            plot(gpstime,z,'-kx')
            hold on;
            plot(gpstime,filloutliers(z,'linear'),'-rx')
            ylabel('\eta [m]');ylim([-2 2])
            plot(tstart*[1 1],ylim,':k','LineWidth',2)
            legend('Raw','Despiked','Start')
            title(bname,'interpreter','none')
        
            subplot(3,1,2)
            plot(gpstime,u,'-kx')
            hold on;
            plot(gpstime,filloutliers(u,'linear'),'-rx')
            ylabel('u [ms^{-2}]');ylim([-2 2])
            plot(tstart*[1 1],ylim,':k','LineWidth',2)
        
            subplot(3,1,3)
            plot(gpstime,v,'-kx')
            hold on;axis tight
            plot(gpstime,filloutliers(v,'linear'),'-rx')
            xlabel('Time [s]');
            ylabel('v [ms^{-2}]');ylim([-2 2])
            plot(tstart*[1 1],ylim,':k','LineWidth',2)

            h = findall(gcf,'Type','Axes');
            linkaxes(h,'x');
            xlim([0 550])
        
            print([bfiles(iburst).folder '\' bfiles(iburst).name(1:end-4)],'-dpng')
            close gcf
    end

    % Crop and despike data
    z = filloutliers(z(tstart*5:end),'linear');
    x = filloutliers(x(tstart*5:end),'linear');
    y = filloutliers(y(tstart*5:end),'linear');
    lat = filloutliers(lat(tstart*5:end), 'linear');
    lon = filloutliers(lon(tstart*5:end), 'linear');
    u = filloutliers(u(tstart*5:end),'linear');
    v = filloutliers(v(tstart*5:end),'linear');

    % Remove NaNs?
    ibad = isnan(z + x + y + u + v + lat + lon);
    z(ibad) = []; x(ibad) = []; y(ibad)=[]; u(ibad)=[]; 
    v(ibad)=[]; lat(ibad)=[]; lon(ibad)=[];

    % Recalculate wave spectra to get proper directional moments 
    %   (bug fix in 11/2017)
    f = SWIFT(sindex).wavespectra.freq;  % original frequency bands
    [newHs,newTp,newDp,newE,newf,newa1,newb1,newa2,newb2,newcheck] = SBGwaves(u,v,z,fs);

    if ~any(~isnan(newE))
        warning('NaN Spectra from SBGwaves')
    end

    % Alternative results using GPS velocites
    [altHs,altTp,altDp,altE,altf,alta1,altb1,alta2,altb2] = GPSwaves(u,v,[],fs);    


        % Interpolate results to L1 frequency bands
        if interpf
            E = interp1(newf,newE,f);
            if length(altE) > 1 
                altE = interp1(altf,altE,f); 
            else 
                altE = NaN(size(f)); 
            end
            a1 = interp1(newf,newa1,f);
            b1 = interp1(newf,newb1,f);
            a2 = interp1(newf,newa2,f);
            b2 = interp1(newf,newb2,f);
            check = interp1(newf,newcheck,f);
        else
            E = newE;
            altE = altE;
            f = newf;
            a1 = newa1;
            b1 = newb1;
            a2 = newa2;
            b2 = newb2;
            check = newcheck;
        end

        % Spectra computed from GPS positions as alternative to GPS velocities if specified
        if useGPS
            [Elat,~] = pwelch(detrend(deg2km(lat)*1000),[],[],[], fs );
            [Elon,fgps] = pwelch(detrend(deg2km(lon,cosd(median(lat))*6371)*1000),[],[],[],fs);
            altE = interp1(fgps, Elat + Elon, f);
        end

        % Convert wave directions to degrees FROM
        dirto = newDp;
        if dirto >=180
            newDp = dirto - 180;
            elseif dirto <180
                newDp = dirto + 180;
            else
        end

        % Replace new wave spectral variables in original SWIFT structure
        SWIFT(sindex).sigwaveheight = newHs;
        SWIFT(sindex).peakwaveperiod = newTp;
        SWIFT(sindex).peakwavedirT = newDp;
        SWIFT(sindex).wavespectra.energy = E;
        SWIFT(sindex).wavespectra.freq = f;
        SWIFT(sindex).wavespectra.a1 = a1;
        SWIFT(sindex).wavespectra.b1 = b1;
        SWIFT(sindex).wavespectra.a2 = a2;
        SWIFT(sindex).wavespectra.b2 = b2;
        SWIFT(sindex).wavespectra.check = check;
        if useGPS
           SWIFT(sindex).wavespectra.energy_alt = altE;
           SWIFT(sindex).peakwaveperiod_alt = altTp;
           SWIFT(sindex).sigwaveheight_alt = altHs;
        end
        SWIFTreplaced(sindex) = true;

        % Save raw displacements (5 Hz) if specified
        if saveraw 

            % Time 
            sbgtime = datenum(sbgData.UtcTime.year, sbgData.UtcTime.month, sbgData.UtcTime.day, sbgData.UtcTime.hour,...
                sbgData.UtcTime.min, sbgData.UtcTime.sec + sbgData.UtcTime.nanosec./1e9);
            t = sbgtime(end-tproc*5+1:end);
            t = filloutliers(t,'linear');
            t(ibad) = [];
            
            SWIFT(sindex).x = x;
            SWIFT(sindex).y = y;
            SWIFT(sindex).z = z;
            SWIFT(sindex).rawtime = t;
            SWIFT(sindex).u = u;
            SWIFT(sindex).v = v;

        end

        % Flag bad bursts when processing fails (9999 error code)
        if isempty(u)
            badwaves(sindex) = true;
        end

        if newHs == 9999
            disp('wave processing gave 9999 for Hs')
            SWIFT(sindex).sigwaveheight = NaN;
            SWIFT(sindex).peakwaveperiod = NaN;
            SWIFT(sindex).peakwaveperiod = NaN;
            SWIFT(sindex).peakwavedirT = NaN;
            badwaves(sindex) = true;
        end

        if altHs == 9999
            SWIFT(sindex).sigwaveheight_alt = NaN;
            SWIFT(sindex).peakwaveperiod_alt = NaN;
        end

        if newDp > 9000 % sometimes only the directions fail
            SWIFT(sindex).peakwavedirT = NaN;
        end

        if sum(E) < 1
            badwaves(sindex) = true;
        end

% End file loop
end

%% NaN out bursts that weren't reprocessed 

if any(~SWIFTreplaced)
    for sindex = find(~SWIFTreplaced)

        % if ~exist('f','var')
            f = SWIFT(sindex).wavespectra.freq;
        % end
            SWIFT(sindex).sigwaveheight = NaN;
            SWIFT(sindex).peakwaveperiod = NaN;
            SWIFT(sindex).peakwavedirT = NaN;
            SWIFT(sindex).wavespectra.energy = NaN(size(f));
            SWIFT(sindex).wavespectra.freq = f;
            SWIFT(sindex).wavespectra.a1 = NaN(size(f));
            SWIFT(sindex).wavespectra.b1 = NaN(size(f));
            SWIFT(sindex).wavespectra.a2 = NaN(size(f));
            SWIFT(sindex).wavespectra.b2 = NaN(size(f));
            SWIFT(sindex).wavespectra.check = NaN(size(f));
            if useGPS
                SWIFT(sindex).wavespectra.energy_alt = NaN(size(f));
                SWIFT(sindex).sigwaveheight_alt = NaN;
                SWIFT(sindex).peakwaveperiod_alt = NaN;
            end
    end
end


%% Log reprocessing and flags, then save new L3 file or overwrite existing one

params.useGPS = useGPS;
params.saveraw = saveraw;
params.interpf = interpf;
params.tstart = tstart;

if isfield(sinfo,'postproc')
ip = length(sinfo.postproc)+1; 
else
    sinfo.postproc = struct;
    ip = 1;
end
sinfo.postproc(ip).type = 'SBG';
sinfo.postproc(ip).usr = getenv('username');
sinfo.postproc(ip).time = string(datetime('now'));
sinfo.postproc(ip).flags.badwaves = badwaves;
sinfo.postproc(ip).params = params;

save([sfile.folder slash sfile.name(1:end-6) 'L3.mat'],'SWIFT','sinfo')

%% End function
end