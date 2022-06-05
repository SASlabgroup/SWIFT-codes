% reprocess SWIFT v3 wave results using a surface reconstruction
% and acounting for listing or capsizing during icing conditions
% loop thru raw data for a given SWIFT deployment, then
% replace values in the SWIFT data structure of results
% (assuming concatSWIFTv3_processed.m has already been run.
%
% J. Thomson, Oct 2015
%   edited version to add spectral check to reprocessed SWIFT data - Maddie 04/2016
%   cleaned and revised with IMU read function, Thomson, Jun 2016
%   subroutine to recalc all spectral moments based on displacements, Jun 2016
%   use RC filter in displacements, Oct 2016
%   revert to original directional moments, Oct 2017
%   optional filters and GPS reprocessing, Jun 2022

%% set up
clear all; close all
parentdir = pwd;  % change this to be the parent directory of all raw raw data (CF card offload from SWIFT)
tic

%% choose a filter
filter = str2cell('RC');
%filter = str2cell('elliptic');
dB = 10;

%% load existing SWIFT structure created during concatSWIFTv3_processed, replace only the new wave results
cd(parentdir);
wd = pwd;
wdi = find(wd == '/',1,'last');
wd = wd((wdi+1):length(wd));

load([wd '.mat']) % loads the standard structure from onboard processing (named for the workding dir 'wd')
GPSresults = SWIFT;  % make copy to use in populating with GPS results.

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
            
            % find matching time index for the existing SWIFT structure
            % (for replacing onboard processed results)
            % use median to get burst time, because first entries are bad (no satellites acquired yet)
            time = nanmedian(datenum(GPS.UTC.Yr,GPS.UTC.Mo, GPS.UTC.Da, GPS.UTC.Hr, GPS.UTC.Mn, GPS.UTC.Sec));
            [tdiff tindex] = min(abs([SWIFT.time]-time));
            %             if tdiff>1/48,
            %                 disp('time gap too large at '),
            %                 datestr(time)
            %                 continue
            %             else
            %             end
            
            f_original = SWIFT(tindex).wavespectra.freq;  % original frequency bands
            dt = median(diff(AHRS.Timestamp_sec));  % time step of raw IMU data
            if isnan(dt),
                dt = 600 ./ length(AHRS.Accel);
            else
            end
            fs_ahrs = 1/dt; % should be 25 Hz
            fs_gps = 1000./median(diff(GPS.UTC.mSec)); % should be 4 Hz
            
            
            %% reconstruct sea surface by double integrating (and filtering)the accelerations, with rotations
            [y,x,z, hs ] = rawdisplacements(AHRS, filter); % call is [y,x,z] to get output in east, north, up
            if strcmp( cellstr( filter ), 'RC')  % eliptic filter option
                x=x'; y=y'; z=z';
            end
            save([filelist(fi).name(1:end-4) '.mat'],'z','-APPEND')
            forinterp = ~isnan(z) & AHRS.GPS_Time.TimeOfWeek > 1e5;
            z_slow = interp1( AHRS.GPS_Time.TimeOfWeek(forinterp), z(forinterp), GPS.Time.TimeOfWeek(end-2047:end) ); % make a version that matches GPS sampling
            
            %% reprocess for wave results... UVZwaves preferred, because magnetometer errors interfere with XYZwaves
            %good = ~isnan( x + y + z);
            %[ Hs, Tp, Dp, E, f, a1, b1, a2, b2, check ] = XYZwaves(x(good),y(good),z(good),fs_ahrs); %wave spectra based on displacements
            [ Hs, Tp, Dp, E, f, a1, b1, a2, b2, check ] = UVZwaves(GPS.NED_Vel.Velocity_NED(~isnan(z_slow),2), ...
                GPS.NED_Vel.Velocity_NED(~isnan(z_slow),1), z_slow(~isnan(z_slow)),fs_gps); % wave spectra from velocity and heave
            
            % interp to the original freq bands
            E = interp1(f,E,f_original);
            a1 = interp1(f,a1,f_original);
            b1 = interp1(f,b1,f_original);
            a2 = interp1(f,a2,f_original);
            b2 = interp1(f,b2,f_original);
            check = interp1(f,check,f_original);
            
            % replace scalar values
            SWIFT(tindex).sigwaveheight = Hs;
            SWIFT(tindex).peakwaveperiod = Tp;
            SWIFT(tindex).peakwaveperiod = Tp;
            SWIFT(tindex).peakwavedirT = Dp;
            SWIFT(tindex).wavespectra.energy = E;
            SWIFT(tindex).wavespectra.a1 = a1;
            SWIFT(tindex).wavespectra.b1 = b1;
            SWIFT(tindex).wavespectra.a2 = a2;
            SWIFT(tindex).wavespectra.b2 = b2;
            SWIFT(tindex).wavespectra.check = check;
            
            %% also reprocess GPS raw data, noting that GPS waves already has an RC filter
            u = GPS.NED_Vel.Velocity_NED(end-2047:end,2);
            v =  GPS.NED_Vel.Velocity_NED(end-2047:end,1);
            z_gps = GPS.Geodetic_Pos.H_above_MSL(end-2047:end);
            if strcmp( cellstr( filter ), 'elliptic')  % eliptic filter option
                [B,A] = ellip(3, .5, dB, 0.05/(fs_gps/2), 'high'); % original is ellip(3, .5, 20, 0.05/(fs/2), 'high');
                u = filtfilt(B, A, double(u));
                v = filtfilt(B, A, double(v));
                z_gps = filtfilt(B, A, double(z_gps));
            end
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
            
            % include raw displacements (25 Hz) in data structure
            SWIFT(tindex).x = x;
            SWIFT(tindex).y = y;
            SWIFT(tindex).z = z;
            
            % include raw GPS velocities (4 Hz) in data structure
            gpslength = length(GPS.NED_Vel.Velocity_NED(:,2));
            last2048 = fliplr(gpslength - [0:2047]);
            if last2048 > 0 & isreal(last2048),
                SWIFT(tindex).u = GPS.NED_Vel.Velocity_NED(last2048,2);
                SWIFT(tindex).v = GPS.NED_Vel.Velocity_NED(last2048,1);
                SWIFT(tindex).rawlat = GPS.Geodetic_Pos.Lat_Lon(last2048,1);
                SWIFT(tindex).rawlon = GPS.Geodetic_Pos.Lat_Lon(last2048,2);
            else
                SWIFT(tindex).u = NaN(2048,1);
                SWIFT(tindex).v = NaN(2048,1);
                SWIFT(tindex).rawlat = NaN(2048,1);
                SWIFT(tindex).rawlon = NaN(2048,1);
            end
            
            
            if Hs==9999 | isnan(Hs) % only replace valid results
                prune(tindex) = true; % set for pruning, b/c invalid wave result
            end
            
        else
            
            % not enough raw data
            
        end
    end
    
    cd('../')
    
end

cd(parentdir)

% Quality control
SWIFT(prune) = [];
GPSresults(prune)=[];

for si=1:length(SWIFT),
    if SWIFT(si).peakwavedirT > 9000 ,
        SWIFT(si).peakwavedirT = NaN;
    else
    end
end

%% save a big file with raw displacements, then a small file with stats only

save([ wd '_reprocessedIMU_' filter{1} 'filter_displacements.mat'],'SWIFT')

%% save a small file with stats only

SWIFT = rmfield(SWIFT,'x');
SWIFT = rmfield(SWIFT,'y');
SWIFT = rmfield(SWIFT,'z');
SWIFT = rmfield(SWIFT,'u');
SWIFT = rmfield(SWIFT,'v');
SWIFT = rmfield(SWIFT,'rawlat');
SWIFT = rmfield(SWIFT,'rawlon');

save([ wd '_reprocessedIMU_' filter{1} 'fitler.mat'],'SWIFT')

%% (re)plot

plotSWIFT(SWIFT)

[Etheta theta f dir spread spread2 spread2alt ] = SWIFTdirectionalspectra(SWIFT, 1);

%% save the GPS results as their own structure
SWIFT = GPSresults;

save([ wd '_reprocessedGPS_' filter{1} 'fitler.mat'],'SWIFT')

toc
