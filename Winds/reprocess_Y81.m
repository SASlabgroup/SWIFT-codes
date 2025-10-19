function [SWIFT,sinfo] = reprocess_Y81(missiondir)

% SWIFT RM Young and IMU processing
%
% Loop through files, grabs raw IMU and sonic data, pass to motion
% correction function, and calculate relevant quantities, saved in
% structure 'sonic'
% S Zippel, 2018?
% J. Thomson, 12/2019 revs
% K. Zeiden 07/2024 reformatted for symmetry with bulk post processing
%    postprocess_SWIFT.m

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

%% Loop through raw burst files and reprocess

bfiles = dir([missiondir slash '*' slash 'Raw' slash '*' slash '*Y81*.dat']);

for iburst = 1:length(bfiles)

   disp(['Burst ' num2str(iburst) ' : ' bfiles(iburst).name(1:end-4)])
        
        % Read raw data
        if bfiles(iburst).bytes > 1e5
        [u,v,w,temp,~] = readSWIFT_Y81([bfiles(iburst).folder slash bfiles(iburst).name]);
        else
            disp('File size too small, NaN out ...')
            u = NaN(1000,1);
            v = u;w = u;temp = u;
        end
        windspd = mean( (u.^2 + v.^2 + w.^2).^.5 );
        winddirR = meandir(atan2d(v,u));

        % Recalculate friction velocity
        z = sinfo.metheight;
        fs = 10;
        [ustar,~,~,~,~,~,~,~,windfreq,windpower] = inertialdissipation(u,v,w,temp,z,fs);

        % Find burst index in the existing SWIFT structure
        burstID = bfiles(iburst).name(13:27);
        sindex = find(strcmp(burstID,{SWIFT.burstID}'));
        if isempty(sindex)
            disp('No matching SWIFT index. Skipping...')
            continue
        else
            SWIFT(sindex).windspd = windspd;
            SWIFT(sindex).winddirR = winddirR;
            if ustar ~= 9999
                SWIFT(sindex).windustar = ustar;
                SWIFT(sindex).windspectra.freq = windfreq(:);
                SWIFT(sindex).windspectra.energy = windpower(:);
            end
        end

end
       

%% Log reprocessing and flags, then save new L3 file or overwrite existing one

if isfield(sinfo,'postproc')
ip = length(sinfo.postproc)+1; 
else
    sinfo.postproc = struct;
    ip = 1;
end
sinfo.postproc(ip).type = 'Y81';
sinfo.postproc(ip).usr = getenv('username');
sinfo.postproc(ip).time = string(datetime('now'));
sinfo.postproc(ip).flags = [];
sinfo.postproc(ip).params = [];

save([sfile.folder slash sfile.name(1:end-6) 'L3.mat'],'SWIFT','sinfo')

%% End function
end
        
