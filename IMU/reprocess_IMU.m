function [SWIFT,sinfo] = reprocess_IMU(missiondir,calctype,filtertype,saveraw,interpf)

% reprocess SWIFT v3 wave results using a surface reconstruction
% and acounting for listing or capsizing during icing conditions
% loop thru raw data for a given SWIFT deployment, then
% replace values in the SWIFT data structure of results
% assuming concatSWIFTv3_processed.m has already been run.
%
% J. Thomson, Oct 2015
%   edited version to add spectral check to reprocessed SWIFT data - Maddie 04/2016
%   cleaned and revised with IMU read function, Thomson, Jun 2016
%   subroutine to recalc all spectral moments based on displacements, Jun 2016
%   use RC prefilter in displacements, Oct 2016
%   revert to original directional moments, Oct 2017
%   optional prefilters and GPS, GPSandIMU reprocessing, Jun 2022
% K. Zeiden, July 2024
%   reformatting for use in master postprocessing script,
%   'postprocess_SWIFT'. 
%   Turned into function with mission directory as input
%   User input to determine what type of data to use (IMU, GPS or both),
%   whether to save raw displacements, and what filter type to use

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
elseif isempty(l3file) && ~isempty(l2file)% If not, load L2 file
    sfile = l2file;
    load([sfile.folder slash sfile.name],'SWIFT','sinfo');
else %  Exit reprocessing if no L2 or L3 product exists
    warning(['No L2 or L3 product found for ' missiondir(end-16:end) '. Skipping...'])
    return
end

%% Make sure 'calctype' specifies 'IMU', 'GPS' or 'IMUandGPS'

if ~strcmp(calctype,'IMU') && ~strcmp(calctype,'GPS') && ~strcmp(calctype,'IMUandGPS')
    error('Please specify ''IMU'', ''GPS'' or ''IMUandGPS'' for reprocessing.')
end

%% Filter Type

if strcmp(filtertype,'RC')
    prefilter = 'RC'; 
    RC = 3.5; 
elseif strcmp(filtertype,'elliptic')
    prefilter = 'elliptic';  
    dB = 5; % Lower is a strong filter?
    %  note that dB is set seperately (again) within rawdisplacements.m
else 
    error('Filter type must be ''RC'' or ''elliptic''.')
end

% Flag bad wave data
badwaves = false(1,length(SWIFT));

%% Loop through raw burst files and reprocess
bfiles = dir([missiondir slash '*' slash 'Raw' slash '*' slash '*IMU*.dat']);

for iburst = 1:length(bfiles)

   disp(['Burst ' num2str(iburst) ' : ' bfiles(iburst).name(1:end-4)])
    
    % Read or load raw IMU data
    if isempty(dir([bfiles(iburst).folder slash bfiles(iburst).name(1:end-4) '.mat']))
        disp('Reading raw IMU data...')
        [AHRS,GPS] = readSWIFTv3_IMU([bfiles(iburst).folder slash bfiles(iburst).name]);
    else
        load([bfiles(iburst).folder slash bfiles(iburst).name(1:end-4) '.mat'],'AHRS','GPS')
    end

    % If data is missing, skip burst
    if isempty(GPS) || length(GPS.NED_Vel.Velocity_NED)<2047 %isempty(AHRS) || length(AHRS.Accel) < 12000
        disp('Not enough data. Skipping...')
        continue
    end
        
    % % Find matching time index in the existing SWIFT structure
    % time = median(datenum(GPS.UTC.Yr, GPS.UTC.Mo, GPS.UTC.Da, GPS.UTC.Hr, GPS.UTC.Mn, GPS.UTC.Sec),'omitnan');% First entries are bad (no satellites acquired yet)
    % [tdiff,tindex] = min(abs([SWIFT.time]-time));   
    % if tdiff > 1/(5*24) % If no close time index, skip burst
    %     disp('No time match. Skipping...')
    %     continue
    % end

    % Find burst index in the existing SWIFT structure
    burstID = bfiles(iburst).name(13:end-4);
    sindex = find(strcmp(burstID,{SWIFT.burstID}'));
    if isempty(sindex)
        disp('No matching SWIFT index. Skipping...')
        continue
    end
        
    % Sampling rates and frequency bands
    if strcmp(calctype,'GPS')
        dt = NaN;
    else
        dt = median(diff(AHRS.Timestamp_sec)); % time step of raw IMU data
    end
%     if isnan(dt)
%         dt = 600./length(AHRS.Accel);
%     end
    fs_ahrs = 1/dt; % should be 25 Hz
    fs_gps = 1000./median(diff(GPS.UTC.mSec)); % should be 4 Hz
    f_original = SWIFT(sindex).wavespectra.freq;  % original frequency bands from onboard processing
    if any(isnan(f_original)) || any(f_original==0)
        % NOTE(@mleclair) This is where the inconsistencies come in. Maybe
        % this should be where we fix it?
        f_original = linspace(0.0098, 0.4902, 42)'; % apply standard 42 freq bands if missing
    end
        
    % Reconstruct sea surface (get raw displacements)
    % (!!!) call is [y,x,z] to get output in east, north, up instead of NEU
    if strcmp(calctype,'GPS')
        x = NaN(4096,1); y = NaN(4096,1); z = NaN(4096,1); 
    else
        [y,x,z,~] = rawdisplacements(AHRS,prefilter);
        if strcmp(prefilter,'RC')
            x=x'; y=y'; z=z';
        end
    end
        
    % Prepare GPS and IMU data for reprocessing
    u = GPS.NED_Vel.Velocity_NED(end-2047:end,2);
    v =  GPS.NED_Vel.Velocity_NED(end-2047:end,1);
    z_gps = GPS.Geodetic_Pos.H_above_MSL(end-2047:end);

    if strcmp(calctype,'IMUandGPS')
        [~,iinterp] = unique(AHRS.GPS_Time.TimeOfWeek);
        az = interp1(AHRS.GPS_Time.TimeOfWeek(iinterp),AHRS.Accel(iinterp,3),GPS.Time.TimeOfWeek(end-2047:end));
        if ~any(~isnan(az))
            disp('Time mismatch between AHRS and GPS. Skipping...')
            continue
        end
        indices = 1:2048;
        az = interp1(indices(~isnan(az)),az(~isnan(az)),indices,'linear',mean(az,'omitnan'))';
    else
        az = NaN(length(u),1);
    end
        
    % Prefilter
    if strcmp(prefilter,'elliptic')  % Elliptic filter

        [B,A] = ellip(3, .5, dB, 0.05/(fs_gps/2), 'high'); % original is ellip(3, .5, 20, 0.05/(fs/2), 'high');
        u = filtfilt(B, A, double(u));
        v = filtfilt(B, A, double(v));
        z_gps = filtfilt(B, A, double(z_gps));
        az = filtfilt(B, A, double(az)) + mean(az,'omitnan'); % restore the mean, because GPSandIMUwaves looks for it to be ~1g
        
    elseif strcmp(prefilter,'RC')  % RC filter 

        alpha = RC / (RC + 1./fs_gps);
        fu = NaN(1,length(u));
        fv = fu; fz = fu; faz = fu;
        fu(1) = u(1); fv(1)=v(1); fz(1)=z_gps(1); faz(1)=az(1);
        for ui = 2:length(u)
            fu(ui) = alpha * fu(ui-1) + alpha * ( u(ui) - u(ui-1) );
            fv(ui) = alpha * fv(ui-1) + alpha * ( v(ui) - v(ui-1) );
            fz(ui) = alpha * fz(ui-1) + alpha * ( z_gps(ui) - z_gps(ui-1) );
            faz(ui) = alpha * faz(ui-1) + alpha * ( az(ui) - az(ui-1) );
        end
        u = fu; v = fv; z_gps = fz; az = faz + mean(az,'omitnan');  % restore the mean, because GPSandIMUwaves looks for it to be ~1 g

    end

    %% Recalculate wave spectra
    if strcmp(calctype,'IMU') % using IMU displacements only

    igood = ~isnan( x + y + z);
    [Hs,Tp,Dp,E,f,a1,b1,a2,b2,check] = XYZwaves(x(igood),y(igood),z(igood),fs_ahrs);
        
    % Interpolate back to the original frequency bands
    if interpf
        E = interp1(f,E,f_original);
        a1 = interp1(f,a1,f_original);
        b1 = interp1(f,b1,f_original);
        a2 = interp1(f,a2,f_original);
        b2 = interp1(f,b2,f_original);
        check = interp1(f,check,f_original);
        f = f_original;
    end
        
    % Replace scalar values
    SWIFT(sindex).sigwaveheight = Hs;
    SWIFT(sindex).peakwaveperiod = Tp;
    SWIFT(sindex).peakwavedirT = Dp;
    SWIFT(sindex).wavespectra.energy = E;
    SWIFT(sindex).wavespectra.freq = f;
    SWIFT(sindex).wavespectra.a1 = a1;
    SWIFT(sindex).wavespectra.b1 = b1;
    SWIFT(sindex).wavespectra.a2 = a2;
    SWIFT(sindex).wavespectra.b2 = b2;
    SWIFT(sindex).wavespectra.check = check;
        
    elseif strcmp(calctype,'IMUandGPS') % using GPS velocities and IMU acceleration

        igood = ~isnan(u + v + az);

        if sum(igood) > 1024

            [Hs,Tp,Dp,E,f,a1,b1,a2,b2,check] = GPSandIMUwaves(u(igood),v(igood),az(igood),[],[],fs_gps);
            
            if interpf 
            % Interpolate to the original freq bands
                E = interp1(f,E,f_original);
                a1 = interp1(f,a1,f_original);
                b1 = interp1(f,b1,f_original);
                a2 = interp1(f,a2,f_original);
                b2 = interp1(f,b2,f_original);
                check = interp1(f,check,f_original);
                f = f_original;
            end
            
            % Replace scalar values, but not directional moments
            SWIFT(sindex).sigwaveheight = Hs;
            SWIFT(sindex).peakwaveperiod = Tp;
            SWIFT(sindex).peakwavedirT = Dp;
            SWIFT(sindex).wavespectra.energy = E;
            SWIFT(sindex).wavespectra.freq = f;
            SWIFT(sindex).wavespectra.a1 = a1;
            SWIFT(sindex).wavespectra.b1 = b1;
            SWIFT(sindex).wavespectra.a2 = a2;
            SWIFT(sindex).wavespectra.b2 = b2;
            SWIFT(sindex).wavespectra.check = check;
        else
            disp(['Bad u,v, az values -- did not reprocess ' bfiles(iburst).name '...'])
        end
        
    elseif strcmp(calctype,'GPS') % using GPS veloctiies and vertical displacement only

        [Hs,Tp,Dp,E,f,a1,b1,a2,b2,check] = GPSwaves(u,v,z_gps,fs_gps);
        
        % interp to the original freq bands
        if interpf
            E = interp1(f,E,f_original);
            a1 = interp1(f,a1,f_original);
            b1 = interp1(f,b1,f_original);
            a2 = interp1(f,a2,f_original);
            b2 = interp1(f,b2,f_original);
            check = interp1(f,check,f_original);
            f = f_original;
        end
        
        % replace scalar values, but not directional moments
        SWIFT(sindex).sigwaveheight = Hs;
        SWIFT(sindex).peakwaveperiod = Tp;
        SWIFT(sindex).peakwavedirT = Dp;
        SWIFT(sindex).wavespectra.energy = E;
        SWIFT(sindex).wavespectra.freq = f;
        SWIFT(sindex).wavespectra.a1 = a1;
        SWIFT(sindex).wavespectra.b1 = b1;
        SWIFT(sindex).wavespectra.a2 = a2;
        SWIFT(sindex).wavespectra.b2 = b2;
        SWIFT(sindex).wavespectra.check = check;


    end
        
    %% Flag bad results
    
    if Hs == 9999 || isnan(Hs) % invalid wave result
        disp('Bad wave height. Flagging...')
        badwaves(sindex) = true;
        SWIFT(sindex).sigwaveheight = NaN;
    end

    if Tp == 9999 || isnan(Tp) % invalid wave result
        disp('Bad wave period. Flagging...')
        badwaves(sindex) = true;
        SWIFT(sindex).peakwaveperiod = NaN;
    end

    if Dp == 9999 || isnan(Dp) % invalid wave result
        disp('Bad wave direction. Flagging...')
        badwaves(sindex) = true;
        SWIFT(sindex).peakwavedirT = NaN;
    end

    %% Save raw displacements to SWIFT structure and burst file if specified
    if saveraw
        save([bfiles(iburst).name(1:end-4) '.mat'],'z','-APPEND')
        SWIFT(sindex).x = x;
        SWIFT(sindex).y = y;
        SWIFT(sindex).z = z;
        SWIFT(sindex).u = u;
        SWIFT(sindex).v = v;
        SWIFT(sindex).rawlat = GPS.Geodetic_Pos.Lat_Lon(end-2047:end,1);
        SWIFT(sindex).rawlon = GPS.Geodetic_Pos.Lat_Lon(end-2047:end,2);
    end

end

%% Log reprocessing and flags, then save new L3 file or overwrite existing one

params.Data = calctype;
params.Filter = filtertype;
params.Interpf = interpf;
params.Saveraw = saveraw;

if isfield(sinfo,'postproc')
ip = length(sinfo.postproc)+1; 
else
    sinfo.postproc = struct;
    ip = 1;
end
sinfo.postproc(ip).type = 'IMU';
sinfo.postproc(ip).usr = getenv('username');
sinfo.postproc(ip).time = string(datetime('now'));
sinfo.postproc(ip).flags.badwaves = badwaves;
sinfo.postproc(ip).params = params;

save([sfile.folder slash sfile.name(1:end-6) 'L3.mat'],'SWIFT','sinfo')

%% End function
end