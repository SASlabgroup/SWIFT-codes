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
%

clear all; close all
parentdir = pwd;  % change this to be the parent directory of all raw raw data (CF card offload from SWIFT)
%parentdir = ('/Volumes/Data/Newport/SWIFT19_15-18Oct2016');  % change this to be the parent directory of all raw raw data (CF card offload from SWIFT)


%% load existing SWIFT structure created during concatSWIFTv3_processed, replace only the new wave results
cd(parentdir);
wd = pwd;
wdi = find(wd == '/',1,'last');
wd = wd((wdi+1):length(wd));

load([wd '.mat'])

prune = false(1,length(SWIFT)); % initialize logical array for later pruning of bad data

cd('IMU/Raw/') % v3.2
%cd('COM-6/Raw/') % v3.3


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
            
            % find matching time index
            % use median to get burst time, because first entries are bad (no satellites acquired yet)
            time = nanmedian(datenum(GPS.UTC.Yr,GPS.UTC.Mo, GPS.UTC.Da, GPS.UTC.Hr, GPS.UTC.Mn, GPS.UTC.Sec));
            % match time to SWIFT structure and replace values
            [tdiff tindex] = min(abs([SWIFT.time]-time));
            if tdiff>1/48,
                disp('time gap too large at '),
                datestr(time)
                continue
            else
            end
            
            f = SWIFT(tindex).wavespectra.freq;  % original frequency bands
            
            % reconstruct sea surface by double integrating (and filtering) the accelerations
            [y,x,z, hs ] = rawdisplacements(AHRS); % call is [y,x,z] to get output in east, north, up
            save([filelist(fi).name(1:end-4) '.mat'],'z','-APPEND')
            
            % make new scalar energy spectra from sea surface heights
            dt = median(diff(AHRS.Timestamp_sec));  % time step should be 0.04 s
            if isnan(dt),
                dt = 600 ./ length(AHRS.Accel);
            else
            end
            fs = 1/dt; % should be 25 Hz
            
            % make wave spectra based on non-nan displacements
            good = ~isnan( x + y + z);
            [ newHs, newTp, newDp, newE, newf, newa1, newb1, newa2, newb2, check ] = XYZwaves(x(good),y(good),z(good),fs);
            
            if newHs~=9999 & ~isnan(newHs), % only replace valid results
                
                % interp to the original freq bands
                E = interp1(newf,newE,f);
                a1 = interp1(newf,newa1,f);
                b1 = interp1(newf,newb1,f);
                a2 = interp1(newf,newa2,f);
                b2 = interp1(newf,newb2,f);
                
                % replace scalar values, but not directional moments
                SWIFT(tindex).sigwaveheight = newHs;
                SWIFT(tindex).peakwaveperiod = newTp;
                SWIFT(tindex).peakwaveperiod = newTp;
                %SWIFT(tindex).peakwavedirT = newDp;
                SWIFT(tindex).wavespectra.energy = E;
                %SWIFT(tindex).wavespectra.a1 = a1;
                %SWIFT(tindex).wavespectra.b1 = b1;
                %SWIFT(tindex).wavespectra.a2 = a2;
                %SWIFT(tindex).wavespectra.b2 = b2;
                SWIFT(tindex).wavespectra.check = check;
                
                % include raw displacements (25 Hz)
                SWIFT(tindex).x = x;
                SWIFT(tindex).y = y;
                SWIFT(tindex).z = z;
                
                % include raw GPS velocities (4 Hz)
                gpslength = length(GPS.NED_Vel.Velocity_NED(:,2));
                last2048 = fliplr(gpslength - [0:2047]);
                if last2048 > 0 & isreal(last2048),
                    SWIFT(tindex).u = GPS.NED_Vel.Velocity_NED(last2048,2);
                    SWIFT(tindex).v = GPS.NED_Vel.Velocity_NED(last2048,1);
                else
                    SWIFT(tindex).u = NaN(2048,1);
                    SWIFT(tindex).v = NaN(2048,1);
                end
                
            else
                
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

for si=1:length(SWIFT),
    if SWIFT(si).peakwavedirT > 9000 , 
        SWIFT(si).peakwavedirT = NaN;
    else
    end
end

%% save a big file with raw displacements, then a small file with stats only

save([ wd '_reprocessedIMU_RC_displacements.mat'],'SWIFT')

%% save a small file with stats only

SWIFT = rmfield(SWIFT,'x');
SWIFT = rmfield(SWIFT,'y');
SWIFT = rmfield(SWIFT,'z');
SWIFT = rmfield(SWIFT,'u');
SWIFT = rmfield(SWIFT,'v');

save([ wd '_reprocessedIMU_RC.mat'],'SWIFT')


%% (re)plot

plotSWIFT(SWIFT)

[Etheta theta f dir spread spread2 spread2alt ] = SWIFTdirectionalspectra(SWIFT, 1);

