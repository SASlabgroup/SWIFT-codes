function [SWIFT,sinfo] = reprocess_SBG(missiondir,saveraw,useGPS,interpf)


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
tproc = 475;% seconds

%% Flag bad wave data
badwaves = false(1,length(SWIFT));

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

    % SBG time
    btime = datenum(sbgData.UtcTime.year, sbgData.UtcTime.month, sbgData.UtcTime.day, sbgData.UtcTime.hour,...
        sbgData.UtcTime.min, sbgData.UtcTime.sec + sbgData.UtcTime.nanosec./1e9);

    % Find matching time index in the existing SWIFT structure
    % First entries are bad (no satellites acquired yet)
    [tdiff,tindex] = min(abs([SWIFT.time]-median(btime,'omitnan')));
    if tdiff > 1/(5*24) % If no close time index, skip burst
        disp('No time match. Skipping...')
        continue
    end

    % If not enough data to work with, skip burst
    if isempty(tindex) || length(btime)<tproc*5 || length(sbgData.ShipMotion.heave)<tproc*5 || ... 
            length(sbgData.GpsPos.lat)<tproc*5 || length(sbgData.GpsVel.vel_e)<tproc*5
            disp('Not enough data. Skipping...')
            continue
    end

        % Despike data and make convenience variables
        t = btime(end-tproc*5+1:end);
        t = filloutliers(t,'linear');
        z = sbgData.ShipMotion.heave(end-tproc*5+1:end);
        z = filloutliers(z,'linear');
        x = sbgData.ShipMotion.surge(end-tproc*5+1:end);
        x = filloutliers(x,'linear');
        y = sbgData.ShipMotion.sway(end-tproc*5+1:end);
        y = filloutliers(y,'linear');
        lat = sbgData.GpsPos.lat(end-tproc*5+1:end);
        lat = filloutliers(lat, 'linear');
        lon = sbgData.GpsPos.long(end-tproc*5+1:end);
        lon = filloutliers(lon, "linear");
        u = sbgData.GpsVel.vel_e(end-tproc*5+1:end);
        u = filloutliers(u,'linear');
        v = sbgData.GpsVel.vel_n(end-tproc*5+1:end);
        v = filloutliers(v,'linear');
        
        % Remove NaNs?
        ibad = isnan(z + x + y + u + v + lat + lon);
        t(ibad) = []; z(ibad) = []; x(ibad) = []; y(ibad)=[]; u(ibad)=[]; 
        v(ibad)=[]; lat(ibad)=[]; lon(ibad)=[];

        % Recalculate wave spectra to get proper directional moments 
        %   (bug fix in 11/2017)
        f = SWIFT(tindex).wavespectra.freq;  % original frequency bands
        fs = 5; % should be 5 Hz for standard SBG settings
        [newHs,newTp,newDp,newE,newf,newa1,newb1,newa2,newb2,newcheck] = SBGwaves(u,v,z,fs);

        % Alternative results using GPS velocites
        [altHs,altTp,altDp,altE,altf,alta1,altb1,alta2,altb2] = GPSwaves(u,v,[],fs);

        % reprocess using GPS positions
        [Elat,~] = pwelch(detrend(deg2km(lat)*1000),[],[],[], fs );
        [Elon,fgps] = pwelch(detrend(deg2km(lon,cosd(median(lat))*6371)*1000),[],[],[],fs);


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

        % Use spectra computed from GPS as alternative if specified
        if useGPS
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
        SWIFT(tindex).sigwaveheight = newHs;
        SWIFT(tindex).sigwaveheight_alt = altHs;
        SWIFT(tindex).peakwaveperiod = newTp;
        SWIFT(tindex).peakwaveperiod_alt = altTp;
        SWIFT(tindex).peakwavedirT = newDp;
        SWIFT(tindex).wavespectra.energy = E;
        SWIFT(tindex).wavespectra.energy_alt = altE;
        SWIFT(tindex).wavespectra.freq = f;
        SWIFT(tindex).wavespectra.a1 = a1;
        SWIFT(tindex).wavespectra.b1 = b1;
        SWIFT(tindex).wavespectra.a2 = a2;
        SWIFT(tindex).wavespectra.b2 = b2;
        SWIFT(tindex).wavespectra.check = check;

        % Save raw displacements (5 Hz) if specified
        if saveraw 
            SWIFT(tindex).x = x;
            SWIFT(tindex).y = y;
            SWIFT(tindex).z = z;
            SWIFT(tindex).rawtime = t;
            SWIFT(tindex).u = u;
            SWIFT(tindex).v = v;
        end

        % Flag bad bursts when processing fails (9999 error code)
        if isempty(u)
            badwaves(tindex) = true;
        end

        if newHs == 9999
            disp('wave processing gave 9999')
            SWIFT(tindex).sigwaveheight = NaN;
            SWIFT(tindex).peakwaveperiod = NaN;
            SWIFT(tindex).peakwaveperiod = NaN;
            SWIFT(tindex).peakwavedirT = NaN;
            badwaves(tindex) = true;
        end

        if altHs == 9999
            SWIFT(tindex).sigwaveheight_alt = NaN;
            SWIFT(tindex).peakwaveperiod_alt = NaN;
        end

        if newDp > 9000 % sometimes only the directions fail
            SWIFT(tindex).peakwavedirT = NaN;
        end

% End file loop
end


%% Log reprocessing and flags, then save new L3 file or overwrite existing one

params.AltGPS = useGPS;

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