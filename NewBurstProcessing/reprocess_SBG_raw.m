% Batch Matlab read-in and reprocess of SWIFT v4 SBG wave data
%   reprocessing is necessary to fix a bug in directional momements
%   all data prior 11/2017 need this reprocessing
%
% M. Schwendeman, 01/2017
% J. Thomson, 10/2017 add reprocessing to batch read of raw data,
%                   and replace SWIFT data structure results.
% S. Kaster, 2018 include raw data in SWIFT structures
% clear all, close all

parentdir = pwd;  % change this to be the parent directory of all raw raw data (CF card offload from SWIFT)
%parentdir = ('/Volumes/Data/Newport/SWIFT19_15-18Oct2016');  % change this to be the parent directory of all raw raw data 

secondsofdata = 8*60;  % seconds of raw data to process (from the end of each burst, not beginning)

%% load existing SWIFT structure created during concatSWIFTv3_processed, replace only the new wave results
cd(parentdir);
wd = pwd;
wdi = find(wd == '/',1,'last');
wd = wd((wdi+1):length(wd));

% if ~isempty(dir([wd '_reprocessedSIG.mat'])) & readfromconcat~=1,
%     load([wd '_reprocessedSIG.mat'])
% else
%     load([wd '.mat'])
% end

load([wd '_reprocessed.mat'])

cd('SBG/Raw/') % v4.0


%% loop thru raw data

dirlist = dir('20*');

for di = 1:length(dirlist),
    
    cd([dirlist(di).name])
    filelist = dir('*.dat');
    
    for fi=1:length(filelist),
        
        % read or load raw data
        if isempty(dir([filelist(fi).name(1:end-4) '.mat'])),
            sbgData = sbgBinaryToMatlab(filelist(fi).name);
            save([filelist(fi).name(1:end-4) '.mat'],'sbgData'),
        else
            load([filelist(fi).name(1:end-4) '.mat']),
        end
        
        %% find matching time index
        alltime = datenum(sbgData.UtcTime.year, sbgData.UtcTime.month, sbgData.UtcTime.day, sbgData.UtcTime.hour, ... 
            sbgData.UtcTime.min, sbgData.UtcTime.sec + sbgData.UtcTime.nanosec./1e9);
        % use median to get burst time, because first entries are bad (no satellites acquired yet)
        time = nanmedian(alltime);
        length(SWIFT)
        % match time to SWIFT structure and replace values
        [tdiff tindex] = min(abs([SWIFT.time]-time));
        if tdiff>1/48,
            disp('time gap too large at '),
            datestr(time)
            
            continue
        else
        end
        
        %% make sure there is data to work with
        if length(sbgData.GpsVel.vel_e)>secondsofdata*5 & length(sbgData.GpsVel.vel_n)>secondsofdata*5 & ... 
                length(sbgData.ShipMotion.heave)>secondsofdata*5,
            
            f = SWIFT(tindex).wavespectra.freq;  % original frequency bands
            
            fs = 5; % should be 5 Hz for standard SBG settings
            
            % reprocess to get proper directional momements (bug fix in 11/2017)
            [ newHs, newTp, newDp, newE, newf, newa1, newb1, newa2, newb2, check ] = ... 
                SBGwaves(sbgData.GpsVel.vel_e(end-secondsofdata*5+1:end),sbgData.GpsVel.vel_n(end-secondsofdata*5+1:end),... 
                sbgData.ShipMotion.heave(end-secondsofdata*5+1:end),5);
            
            % reprocess using GPS velocites to get alternate results
            [ altHs, altTp, altDp, altE, altf, alta1, altb1, alta2, altb2 ] = ... 
                GPSwaves(sbgData.GpsVel.vel_e(end-secondsofdata*5+1:end),sbgData.GpsVel.vel_n(end-secondsofdata*5+1:end),[],5);

            
            % interp to the original freq bands, letting error codes act
            
            if altf~=9999
            
                E = interp1(newf,newE,f);
                altE = interp1(altf,altE,f);
                a1 = interp1(newf,newa1,f);
                b1 = interp1(newf,newb1,f);
                a2 = interp1(newf,newa2,f);
                b2 = interp1(newf,newb2,f);

            elseif altf==9999;
                
                E = NaN;
                altE = NaN;
                a1 = NaN;
                b1 = NaN;
                a2 = NaN;
                b2 = NaN;
                
            end
            % take reciprocal of wave directions (to make result direction FROM)
            dirto = newDp;
            if dirto >=180,
                newDp = dirto - 180;
            elseif dirto <180,
                newDp = dirto + 180;
            else
            end

            % replace scalar values
            SWIFT(tindex).sigwaveheight = newHs;
            SWIFT(tindex).sigwaveheight_alt = altHs;
            SWIFT(tindex).peakwaveperiod = newTp;
            SWIFT(tindex).peakwaveperiod_alt = altTp;
            SWIFT(tindex).peakwavedirT = newDp;
            SWIFT(tindex).wavespectra.energy = E;
            SWIFT(tindex).wavespectra.energy_alt = altE;
            SWIFT(tindex).wavespectra.a1 = a1;
            SWIFT(tindex).wavespectra.b1 = b1;
            SWIFT(tindex).wavespectra.a2 = a2;
            SWIFT(tindex).wavespectra.b2 = b2;
            SWIFT(tindex).wavespectra.check = check;
            
            % include raw displacements (5 Hz)
            SWIFT(tindex).x = sbgData.ShipMotion.surge(end-secondsofdata*5+1:end);
            SWIFT(tindex).y = sbgData.ShipMotion.sway(end-secondsofdata*5+1:end);
            SWIFT(tindex).z = sbgData.ShipMotion.heave(end-secondsofdata*5+1:end);
            
            % include raw times and lat/lon (5 Hz) 
            SWIFT(tindex).rawtime = alltime(end-secondsofdata*5+1:end);
            SWIFT(tindex).rawLat=sbgData.GpsPos.lat(end-secondsofdata*5+1:end);
            SWIFT(tindex).rawLon=sbgData.GpsPos.long(end-secondsofdata*5+1:end);
            % include raw GPS velocities (5 Hz)
            SWIFT(tindex).u = sbgData.GpsVel.vel_e(end-secondsofdata*5+1:end);
            SWIFT(tindex).v = sbgData.GpsVel.vel_n(end-secondsofdata*5+1:end);
            

            % remove bulk result if wave processing fails (9999 error code)
            if newHs == 9999,    
                SWIFT(tindex).sigwaveheight = NaN;
                SWIFT(tindex).peakwaveperiod = NaN;
                SWIFT(tindex).peakwaveperiod = NaN;
                SWIFT(tindex).peakwavedirT = NaN;
            end
            
            if altHs == 9999,    
                SWIFT(tindex).sigwaveheight_alt = NaN;
                SWIFT(tindex).peakwaveperiod_alt = NaN;
            end
            
            if newDp > 9000, % sometimes only the directions fail
               SWIFT(tindex).peakwavedirT = NaN;
            end

            
        else
            % remove result if insufficient raw data
            SWIFT(tindex) = [];
        end
    end
    
    cd('../')
    
end

cd(parentdir)

%% Quality control
bad = false(size(SWIFT));

for si=1:length(SWIFT)
    
    
    
    if isempty(SWIFT(si).u),
        bad(si) = true;
    else
    end
end

SWIFT(bad) = [];


%% (re)plotting

% plotSWIFT(SWIFT)

[Etheta theta f dir1 spread1 spread2 spread2alt ] = SWIFTdirectionalspectra(SWIFT, 0);


%% save a big file with raw displacements and dir spectra

save([ wd '_reprocessed.mat'],'SWIFT','Etheta','theta','f')

%% save a small file with stats only

SWIFT = rmfield(SWIFT,'x');
SWIFT = rmfield(SWIFT,'y');
SWIFT = rmfield(SWIFT,'z');
SWIFT = rmfield(SWIFT,'u');
SWIFT = rmfield(SWIFT,'v');
SWIFT = rmfield(SWIFT,'rawtime');

save([ wd '_reprocessedSBG_statsonly.mat'],'SWIFT')
