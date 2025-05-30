function [SWIFT,sinfo] = reprocess_AQD(missiondir,readraw)

% reprocess SWIFT v3 downlooking Aquadopp (AQD) results
% loop thru raw data for a given SWIFT deployment, then
% replace values in the SWIFT data structure of results
% (assuming concatSWIFTv3_processed.m has already been run.
%
%
% M. Smith 10/2015 based on reprocess_AQH.m code
%   J. Thomson 12/2015 to include option phase resolved dissipation (commented-out)
%   cleaned and revised with AQD read function, Thomson, Jun 2016
% M. Moulton 3/2017 correct error in Dir calculation
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

%% Parameters

minamp = 30; % amplitude cutoff, usually 30 or 40
minn = 50; % number of cells averaged for each depth
z = 1.25:0.5:20.75;

% Raw Doppler velocity precision of 1 MHz Aquadopp
Vert_prec =  .074; % m/s
Hori_prec = .224; % m/s

burstreplaced = NaN(length(SWIFT),1);

%% Loop through raw burst files and reprocess

bfiles = dir([missiondir slash '*' slash 'Raw' slash '*' slash '*AQD*.dat']);

for iburst = 1:length(bfiles)

     disp(['Burst ' num2str(iburst) ' : ' bfiles(iburst).name(1:end-4)])
    
    % Read or load raw data
    if isempty(dir([bfiles(iburst).folder slash bfiles(iburst).name(1:end-4) '.mat'])) || readraw
        [~,VelE,VelN,VelU,Amp1,Amp2,~,~,~,~,~] = readSWIFTv3_AQD([bfiles(iburst).folder slash bfiles(iburst).name]);
    else
        load([bfiles(iburst).folder slash bfiles(iburst).name(1:end-4) '.mat']) %#ok<LOAD>
    end
    
    % Use velocities only when sufficient return
    exclude = Amp1 < minamp | Amp2 < minamp; % Used for vel. magnitude
    
    % Average amplitudes of just velocity measurements used
    Amp1(exclude) = NaN; 
    Amp2(exclude) = NaN;
    Amp = (Amp1+Amp2)./2; % Corresponds to those used in velocity
    
    n = sum(~isnan(Amp),1);
    E_error = Hori_prec./sqrt(n); 
    N_error = E_error;
    Hori_error = sqrt((E_error.^2) + (N_error.^2));
    Hori_error(n < minn) = NaN;
    Amp = mean(Amp,1,'omitnan');
    Amp(n < minn) = NaN;
    
    % Average velocities first for "net" velocity + direction
    VelE(Amp1<minamp) = NaN; 
    VelN(Amp2<minamp) = NaN;
    VelE(exclude) = NaN; 
    VelN(exclude) = NaN;
    VelE = mean(VelE,1,'omitnan'); 
    VelN = mean(VelN,1,'omitnan');
    Vel = sqrt(VelE.^2 + VelN.^2);
    Vel(n < minn) = NaN;
    
    % Calculate direction from averaged velocities
    Dir = atan2d(VelE,VelN); % MM: Note, using atan rather than atan2 in this line was incorrect: Dir = rad2deg(atan(VelE./VelN));
    for i = 1:length(Dir)
        if Dir(i) <0
            Dir(i) = Dir(i)+360; % Make directions between 0 and 360
        end
    end
    Dir(n < minn) = NaN;
    
    % % Find matching time
    % time = datenum(bfiles(iburst).name(13:21)) + str2double(bfiles(iburst).name(23:24))./24 ...
    %     + str2double(bfiles(iburst).name(26:27))./(24*6);
    % [tdiff,tindex] = min(abs([SWIFT.time]-time));
    % if tdiff > 12/(60*24)
    %     disp('No time match...')
    %     continue
    % else
    %    burstreplaced(tindex) = true;
    % end

    % Find burst index in the existing SWIFT structure
    burstID = bfiles(iburst).name(13:end-4);
    sindex = find(strcmp(burstID,{SWIFT.burstID}'));
    if isempty(sindex)
        disp('No matching SWIFT index.')
    else
        burstreplaced(sindex) = true;
    end
    
    % Replace Values in SWIFT structure
    SWIFT(sindex).downlooking.velocitydirection = Dir';
    SWIFT(sindex).downlooking.amplitude = Amp';
    SWIFT(sindex).downlooking.z = z;
    SWIFT(sindex).downlooking.velocityerror = Hori_error;
    SWIFT(sindex).downlooking.vertvel = mean(VelU,1,'omitnan');
    
    if sum(SWIFT(sindex).downlooking.velocityprofile,'omitnan') > 0
        SWIFT(sindex).downlooking.velocityprofile = Vel';
    else
        SWIFT(sindex).downlooking.velocityprofile = NaN(40,1);      
    end
     
end

%% If SWIFT structure elements not replaced, fill variables with NaNs

for iburst = 1:length(SWIFT)
    if ~burstreplaced(iburst)
        SWIFT(iburst).downlooking.velocitydirection = NaN(40,1);
        SWIFT(iburst).downlooking.amplitude = NaN(40,1);
        SWIFT(iburst).downlooking.z = 0.25:0.5:19.75;
        SWIFT(iburst).downlooking.velocityerror = NaN(40,1);
        SWIFT(iburst).downlooking.velocityprofile = NaN(40,1);
    end
end

%% Log reprocessing and flags, then save new L3 file or overwrite existing one

if isfield(sinfo,'postproc')
ip = length(sinfo.postproc)+1; 
else
    sinfo.postproc = struct;
    ip = 1;
end
sinfo.postproc(ip).type = 'AQD';
sinfo.postproc(ip).usr = getenv('username');
sinfo.postproc(ip).time = string(datetime('now'));
sinfo.postproc(ip).flags = [];
sinfo.postproc(ip).params = [];

save([sfile.folder slash sfile.name(1:end-6) 'L3.mat'],'SWIFT','sinfo')

%% End function
end


