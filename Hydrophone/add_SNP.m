function [SWIFT,sinfo] = add_SNP(missiondir)
% SNAP hydrophone processing

% Based on scripts by R. Taylor (ARL-UT) and J. Thomson (APL-UW)
% Adapted by K. Zeiden June 2025

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

%% If no mat file, loop through raw hydrophone files and create mat file

gain = 168;  % hydrophone gain
fs0 = 48000;
f0_kHz = decimate(0:1:fs0/2,100)'./ 1e3;
nf = length(f0_kHz);

% mfile = dir([missiondir slash 'Hydrophone' slash '*.mat']);
mfile = [];

if isempty(mfile)
    
    hfiles = dir([missiondir slash 'Hydrophone' slash '*' slash '*.wav']);
    
    if ~isempty(hfiles)

    nfile = length(hfiles);
    time = NaN(1,nfile);
    PSD = NaN(nf,nfile);

    progressbar('Processing Hydrophone data... ')
    for ihydro = 1:nfile

        hfold = hfiles(ihydro).folder;
        hname = hfiles(ihydro).name(1:end-4);
    
       if exist([hfold slash hname '.mat'],'file')
           disp(['Loading ' hname '.mat'])
           load([hfold slash hname '.mat'],'mS','f_kHz','tsamp')
       else

            disp(['Reading ' hfiles(ihydro).name])
    
            % sample time
            timestring = hfiles(ihydro).name(1:15);  % this is datestr type 30 (ISO 8601)
            year = str2double(timestring(1:4));
            month = str2double(timestring(5:6));
            day = str2double(timestring(7:8));
            hour = str2double(timestring(10:11));
            minute = str2double(timestring(12:13));
            second = str2double(timestring(14:15));
            tsamp = datenum( year, month, day, hour, minute, second);
            
            % make spectrograms (should be a minute long dataset)
            try
            [data_T,fs] = audioread([hfiles(ihydro).folder slash hfiles(ihydro).name]); 
            catch ME
                disp(['Reading audiofile failed: ' ME.message '. Skipping.'])
                continue
            end
            
            % check frequency 
            if fs ~= fs0
                disp(['Warning, unexpected sampling frequency: ' num2str(fs) ' kHz'])
            end
    
            % make sure at least 60 seconds of data
            if length(data_T)/fs < 60
                disp('Sample too short. Skipping.')
                continue
            end
    
            % compute spectra (really spectrogram, time+freq)
            [~,f_Hz,~,psd] = spectrogram(data_T,fs,0,fs,fs,'psd');
    
            % convert to dB
            psd_db = 10*log10(psd)+gain; %in dB, adding the gain
           
            % find median values (avoids spiking) 
            mS = median(psd_db,2,'omitnan');
               
            % decimate to reduce frequency resolution 
            f_kHz = decimate(f_Hz, 100)./1000;
            mS = decimate(mS, 100);
    
            % save mat file
            save([hfold slash hname '.mat'],'f_kHz','mS','tsamp')
       end

        % interpolate to expected frequencies
        if length(f_kHz)~= length(f0_kHz)
            mS = interp1(f_kHz,mS,f0_kHz); 
        end
        
        % build results array 
        PSD(:,ihydro) = mS;
        time(ihydro) = tsamp; 
        
        progressbar(ihydro/nfile)
    end
    f_kHz = f0_kHz;
    save([missiondir slash 'Hydrophone' slash sfile.name(1:end-6) 'Hydrophone.mat'],'PSD','f_kHz','time')
    else
        disp('No Hydrophone data. Skipping...')
        return
    end
else 
    disp('Loading existing hydrophone mat file...')
    load([mfile.folder slash mfile.name],'PSD','f_kHz','time')
end

%% Add Hydrophone data to SWIFT

for sindex = 1:length(SWIFT)
   [tdiff,tindex] = min(abs( SWIFT(sindex).time - time ) ); 
   if tdiff < 1/(24*10)
       SWIFT(sindex).hydrophone.spectra = PSD(:,tindex);
       SWIFT(sindex).hydrophone.f_kHz = f_kHz;
   else
       SWIFT(sindex).hydrophone.spectra = NaN(length(f_kHz),1);
       SWIFT(sindex).hydrophone.f_kHz = f_kHz;
   end
    
end

%% Log reprocessing and flags, then save new L3 file or overwrite existing one

if isfield(sinfo,'postproc')
ip = length(sinfo.postproc)+1; 
else
    sinfo.postproc = struct;
    ip = 1;
end
sinfo.postproc(ip).type = 'AddHydrophone';
sinfo.postproc(ip).usr = getenv('username');
sinfo.postproc(ip).time = string(datetime('now'));
sinfo.postproc(ip).params.gain = gain;

save([sfile.folder slash sfile.name(1:end-6) 'L3.mat'],'SWIFT','sinfo')

%% End function
end
        

