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

%% set up
clear all; close all
parentdir = pwd;  % change this to be the parent directory of all raw raw data (CF card offload from SWIFT)
tic
saverawdisplacements = false; % logical flag to increase speed by not saving the raw displacements.

%% choose a prefilter
%prefilter = str2cell('no')
prefilter = str2cell('RC'), RC = 3.5;
%prefilter = str2cell('elliptic'),  dB = 5; % lower is strong filter??
    %note that dB is set seperately (again) within rawdisplacements.m

%% load existing SWIFT structure created during concatSWIFTv3_processed, replace only the new wave results
% save time by screening the existing structure for bad bursts (out of water, etc)
cd(parentdir);
wd = pwd;
wdi = find(wd == '/',1,'last');
wd = wd((wdi+1):length(wd));

load([wd '.mat']) % loads the standard structure from onboard processing (named for the workding dir 'wd')
save([wd '_onboardprocessing.mat']) % saves onboard results (for posteriety)
IMUresults = SWIFT;  % make copy to use in populating with GPS results
GPSandIMUresults = SWIFT;  % make copy to use in populating with GPS results
GPSresults = SWIFT;  % make copy to use in populating with GPS results

prune = false(1,length(SWIFT)); % initialize logical array for later pruning of bad data

%cd('IMU/Raw/') % v3.2
cd('COM-6/Raw/') % v3.3


%% loop thru raw data

dirlist = dir('20*');

for di = 1:length(dirlist),
    
    cd([dirlist(di).name])
    filelist = dir('*.dat');
    
    for fi=1:length(filelist),
        
        % read or load raw data
        if isempty(dir([filelist(fi).name(1:end-4) '.mat'])),
            [ AHRS GPS ] = readSWIFTv3_IMU( filelist(fi).name );
        else
            load([filelist(fi).name(1:end-4) '.mat']),
        end
        
        % make sure there is data to work with
        if ~isempty(GPS) & ~isempty(AHRS) & length(AHRS.Accel) > 12000 & ~isempty(SWIFT),
            
            % find matching time index for the existing SWIFT structure,
            % (for replacing onboard processed results)
            % use median to get burst time, because first entries are bad (no satellites acquired yet)
            time = nanmedian(datenum(GPS.UTC.Yr,GPS.UTC.Mo, GPS.UTC.Da, GPS.UTC.Hr, GPS.UTC.Mn, GPS.UTC.Sec));
            [tdiff tindex] = min(abs([SWIFT.time]-time));
            if tdiff < 1/(5*24) % proceed if time match is close enough
                
                % sampling rates and frequency bands
                dt = median(diff(AHRS.Timestamp_sec));  % time step of raw IMU data
                if isnan(dt),
                    dt = 600 ./ length(AHRS.Accel);
                else
                end
                fs_ahrs = 1/dt; % should be 25 Hz
                fs_gps = 1000./median(diff(GPS.UTC.mSec)); % should be 4 Hz
                f_original = SWIFT(tindex).wavespectra.freq;  % original frequency bands from onboard processing
                
                
                %% reconstruct sea surface by double integrating (and prefiltering) the accelerations, with rotations
                [y,x,z, hs ] = rawdisplacements(AHRS, prefilter); % call is [y,x,z] to get output in east, north, up instead of NEU
                if strcmp( cellstr( prefilter ), 'RC')  % eliptic prefilter option
                    x=x'; y=y'; z=z';
                end
                if saverawdisplacements
                    save([filelist(fi).name(1:end-4) '.mat'],'z','-APPEND') % option to add heave estimates to each data file
                end
                
                %% reprocess for waves from the IMU (AHRS) displacements
                good = ~isnan( x + y + z);
                [ Hs, Tp, Dp, E, f, a1, b1, a2, b2, check ] = XYZwaves(x(good),y(good),z(good),fs_ahrs); %wave spectra based on displacements
                
                % interp to the original freq bands
                E = interp1(f,E,f_original);
                a1 = interp1(f,a1,f_original);
                b1 = interp1(f,b1,f_original);
                a2 = interp1(f,a2,f_original);
                b2 = interp1(f,b2,f_original);
                check = interp1(f,check,f_original);
                
                % replace scalar values
                IMUresults(tindex).sigwaveheight = Hs;
                IMUresults(tindex).peakwaveperiod = Tp;
                IMUresults(tindex).peakwaveperiod = Tp;
                IMUresults(tindex).peakwavedirT = Dp;
                IMUresults(tindex).wavespectra.energy = E;
                IMUresults(tindex).wavespectra.a1 = a1;
                IMUresults(tindex).wavespectra.b1 = b1;
                IMUresults(tindex).wavespectra.a2 = a2;
                IMUresults(tindex).wavespectra.b2 = b2;
                IMUresults(tindex).wavespectra.check = check;
                
                
                %% prepares GPS and IMU data for reprocessing
                [UT forinterp] = unique( AHRS.GPS_Time.TimeOfWeek );
                az = interp1( AHRS.GPS_Time.TimeOfWeek(forinterp), AHRS.Accel(forinterp,3), GPS.Time.TimeOfWeek(end-2047:end) );
                indices = 1:2048;
                az = interp1( indices(~isnan(az) ) , az(~isnan(az)), indices,'linear',nanmean(az))';
                u = GPS.NED_Vel.Velocity_NED(end-2047:end,2);
                v =  GPS.NED_Vel.Velocity_NED(end-2047:end,1);
                z_gps = GPS.Geodetic_Pos.H_above_MSL(end-2047:end);
                
                % prefilter
                if strcmp( cellstr( prefilter ), 'elliptic')  % eliptic prefilter option
                    [B,A] = ellip(3, .5, dB, 0.05/(fs_gps/2), 'high'); % original is ellip(3, .5, 20, 0.05/(fs/2), 'high');
                    u = filtfilt(B, A, double(u));
                    v = filtfilt(B, A, double(v));
                    z_gps = filtfilt(B, A, double(z_gps));
                    az = filtfilt(B, A, double(az)) + nanmean(az); % restore the mean, because GPSandIMUwaves looks for it to be ~1 g
                    
                elseif strcmp( cellstr( prefilter ), 'RC')  % RC filter
                    alpha = RC / (RC + 1./fs_gps);
                    fu(1) = u(1); fv(1)=v(1); fz(1)=z_gps(1); faz(1)=az(1);
                    for ui = 2:length(u),
                        fu(ui) = alpha * fu(ui-1) + alpha * ( u(ui) - u(ui-1) );
                        fv(ui) = alpha * fv(ui-1) + alpha * ( v(ui) - v(ui-1) );
                        fz(ui) = alpha * fz(ui-1) + alpha * ( z_gps(ui) - z_gps(ui-1) );
                        faz(ui) = alpha * faz(ui-1) + alpha * ( az(ui) - az(ui-1) );
                    end
                    u = fu; v=fv; z_gps = fz; az=faz + nanmean(az);  % restore the mean, because GPSandIMUwaves looks for it to be ~1 g
                end
                
                %% reprocess with GPS and IMU
                good = ~isnan( u + v + az );
                if sum(good)>1024
                    [ Hs, Tp, Dp, E, f, a1, b1, a2, b2 ] = GPSandIMUwaves(u(good), v(good), az(good), [], [], fs_gps);
                    
                    % interp to the original freq bands
                    E = interp1(f,E,f_original);
                    a1 = interp1(f,a1,f_original);
                    b1 = interp1(f,b1,f_original);
                    a2 = interp1(f,a2,f_original);
                    b2 = interp1(f,b2,f_original);
                    
                    % replace scalar values, but not directional moments
                    GPSandIMUresults(tindex).sigwaveheight = Hs;
                    GPSandIMUresults(tindex).peakwaveperiod = Tp;
                    GPSandIMUresults(tindex).peakwaveperiod = Tp;
                    GPSandIMUresults(tindex).peakwavedirT = Dp;
                    GPSandIMUresults(tindex).wavespectra.energy = E;
                    GPSandIMUresults(tindex).wavespectra.a1 = a1;
                    GPSandIMUresults(tindex).wavespectra.b1 = b1;
                    GPSandIMUresults(tindex).wavespectra.a2 = a2;
                    GPSandIMUresults(tindex).wavespectra.b2 = b2;
                    GPSandIMUresults(tindex).wavespectra.check = check;
                else
                    disp(['did not run GPSandIMU for ' datestr(GPSandIMUresults(tindex).time)])
                end
                
                %% reprocess with GPS only
                
                [ Hs, Tp, Dp, E_gps, f_gps, a1, b1, a2, b2 ] = GPSwaves(u, v, z_gps, fs_gps );
                
                % interp to the original freq bands
                E = interp1(f,E,f_original);
                a1 = interp1(f,a1,f_original);
                b1 = interp1(f,b1,f_original);
                a2 = interp1(f,a2,f_original);
                b2 = interp1(f,b2,f_original);
                
                % replace scalar values, but not directional moments
                GPSresults(tindex).sigwaveheight = Hs;
                GPSresults(tindex).peakwaveperiod = Tp;
                GPSresults(tindex).peakwaveperiod = Tp;
                GPSresults(tindex).peakwavedirT = Dp;
                GPSresults(tindex).wavespectra.energy = E;
                GPSresults(tindex).wavespectra.a1 = a1;
                GPSresults(tindex).wavespectra.b1 = b1;
                GPSresults(tindex).wavespectra.a2 = a2;
                GPSresults(tindex).wavespectra.b2 = b2;
                GPSresults(tindex).wavespectra.check = check;
                
                %% add raw displacements to SWIFT structure
                
                if saverawdisplacements
                    IMUresults(tindex).x = x;
                    IMUresults(tindex).y = y;
                    IMUresults(tindex).z = z;
                    IMUresults(tindex).u = u;
                    IMUresults(tindex).v = v;
                    IMUresults(tindex).rawlat = GPS.Geodetic_Pos.Lat_Lon(end-2047:end,1);
                    IMUresults(tindex).rawlon = GPS.Geodetic_Pos.Lat_Lon(end-2047:end,2);
                end
                
                %% flag bad data
                
                if Hs==9999 | isnan(Hs) % only replace valid results
                    prune(tindex) = true; % set for pruning, b/c invalid wave result
                end
                
            end
        end
    end
    
    cd('../')
    
end

cd(parentdir)

% Quality control
IMUresults(prune) = [];
GPSandIMUresults(prune)=[];
GPSresults(prune)=[];


%% save a big file with raw displacements, then a small file with stats only

SWIFT = IMUresults;

if saverawdisplacements
    save([ wd '_reprocessedIMU_' prefilter{1} 'prefilter_displacements.mat'],'SWIFT')
    SWIFT = rmfield(SWIFT,'x');
    SWIFT = rmfield(SWIFT,'y');
    SWIFT = rmfield(SWIFT,'z');
    SWIFT = rmfield(SWIFT,'u');
    SWIFT = rmfield(SWIFT,'v');
    SWIFT = rmfield(SWIFT,'rawlat');
    SWIFT = rmfield(SWIFT,'rawlon');
end

save([ wd '_reprocessedIMU_' prefilter{1} 'prefitler.mat'],'SWIFT')


%% plot results from the IMU reprocessing, as a sanity check

plotSWIFT(SWIFT)

[Etheta theta f dir spread spread2 spread2alt ] = SWIFTdirectionalspectra(SWIFT, 1);

%% save the GPSandIMU results as their own structure

SWIFT = GPSandIMUresults;

save([ wd '_reprocessedGPSandIMU_' prefilter{1} 'prefitler.mat'],'SWIFT')

%% save the GPS results as their own structure

SWIFT = GPSresults;

save([ wd '_reprocessedGPS_' prefilter{1} 'prefitler.mat'],'SWIFT')

%% close the timer

toc
