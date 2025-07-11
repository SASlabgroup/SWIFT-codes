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

   disp(['Burst ' num2str(iburst) ' : ' bfiles(iburst).name(1:end-4)])

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

    % % Make sure data is same length
    % if length(sbgData.UtcTime.sec) ~= length(sbgData.ShipMotion.heave)
    %     disp('Bad data sizes. Skipping...')
    %     continue
    % end

    % Data to use
    z = sbgData.ShipMotion.heave;
    x = sbgData.ShipMotion.surge;
    y = sbgData.ShipMotion.sway;
    lat = sbgData.GpsPos.lat;
    lon = sbgData.GpsPos.long;
    u = sbgData.GpsVel.vel_e;
    v = sbgData.GpsVel.vel_n;

    if plotburst
            tproc = 475;
            figure('color','w')
            MP = get(0,'monitorposition');
            set(gcf,'outerposition',MP(1,:));
            subplot(3,1,1)
            plot(z,'-kx')
            hold on;
            plot(filloutliers(z,'linear'),'-rx')
            xlabel('NSamp');xlim([0 2750])
            ylabel('\eta [m]');ylim([-2 2])
            plot((length(z)-tproc*5+1)*[1 1],ylim,'--k','LineWidth',2)
            plot(tstart*[1 1],ylim,':k','LineWidth',2)
            title(bfiles(iburst).name,'interpreter','none')
            legend('Raw','Despiked','Variable Window','Fixed Start')
        
            subplot(3,1,2)
            plot(u,'-kx')
            hold on;
            plot(filloutliers(u,'linear'),'-rx')
            xlabel('NSamp');xlim([0 2750])
            ylabel('u [ms^{-2}]');ylim([-2 2])
            plot((length(z)-tproc*5+1)*[1 1],ylim,'--b','LineWidth',2)
            plot(tstart*[1 1],ylim,':b','LineWidth',2)
        
            subplot(3,1,3)
            plot(v,'-kx')
            hold on;axis tight
            plot(filloutliers(v,'linear'),'-rx')
            xlabel('NSamp');xlim([0 2750])
            ylabel('v [ms^{-2}]');ylim([-2 2])
            plot((length(z)-tproc*5+1)*[1 1],ylim,'--b','LineWidth',2)
        
            print([bfiles(iburst).folder '\' bfiles(iburst).name(1:end-4)],'-dpng')
            close gcf
    end

    % If not enough data to work with, skip burst
    if length(z)-tstart*5 < 256*fs
            disp('Not enough data. Skipping...')
            continue
    end

    % Remove start-up time and despike data
    z = filloutliers(z(tstart*5:end),'linear');
    x = filloutliers(x(tstart*5:end),'linear');
    y = filloutliers(y(tstart*5:end),'linear');
    lat = filloutliers(lat(tstart*5:end), 'linear');
    lon = filloutliers(lon(tstart*5:end), 'linear');
    u = filloutliers(u(tstart*5:end),'linear');
    v = filloutliers(v(tstart*5:end),'linear');

    % Force same size
    ndiff = length(z)-length(u);
    if ndiff > 0
        u = [u zeros(1,ndiff)];
        v = [v zeros(1,ndiff)];
    elseif ndiff < 0
        u = u(1:length(z));
        v = v(1:length(z));
    end
    ndiff = length(z) - length(lon);
    if ndiff > 0
        lon = [lon zeros(1,ndiff)];
        lat = [lat zeros(1,ndiff)];
    elseif ndiff < 0 
        lon = lon(1:length(z));
        lat = lat(1:length(z));
    end

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