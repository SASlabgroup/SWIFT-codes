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

%% Load existing L2 product, or L1 product if does not exist. If no L1 product, return to function

l1file = dir([missiondir slash '*SWIFT*L1.mat']);
l2file = dir([missiondir slash '*SWIFT*L2.mat']);

if ~isempty(l2file) % First check to see if there is an existing L2 file to load
    sfile = l2file;
    load([sfile.folder slash sfile.name],'SWIFT','sinfo');
elseif isempty(l2file) && ~isempty(l1file)% If not, load L1 file
    sfile = l1file;
    load([sfile.folder slash sfile.name],'SWIFT','sinfo');
else %  Exit reprocessing if no L1 or L2 product exists
    warning(['No L1 or L2 product found for ' missiondir(end-16:end) '. Skipping...'])
    return
end

%% Loop through raw burst files and reprocess

bfiles = dir([missiondir slash '*' slash 'Raw' slash '*' slash '*Y81*.dat']);

for iburst = 1:length(bfiles)

   disp(['Burst ' num2str(iburst) ' : ' bfiles(iburst).name(1:end-4)])
        
        if bfiles(iburst).bytes > 1e5
        RMYdata = importdata([bfiles(iburst).folder slash bfiles(iburst).name]);
        uvw = RMYdata.data(:,1:3);
        temp = RMYdata.data(:,4);
        else 
            uvw = NaN(1000,3);
            temp = NaN(1000,1);
        end
        windspd = mean((uvw(:,1).^2 + uvw(:,2).^2 + uvw(:,3).^2).^.5);
        
        % Recalculate friction velocity
        z = sinfo.metheight;
        fs = 10;
        [ustar,~,~,~,~,~,~,~,~,~] = inertialdissipation(uvw(:,1),uvw(:,2),uvw(:,3),temp,z,fs);
        
     
        % Find matching time
        time = datenum(bfiles(iburst).name(13:21)) + str2double(bfiles(iburst).name(23:24))./24 ...
            + str2double(bfiles(iburst).name(26:27))./(24*6);
        [tdiff,tindex] = min(abs([SWIFT.time]-time));


        % Replace wind speed, NaN out wind direction and replace ustar
        if ~isempty(tdiff) && tdiff < 12/(24*60)
            SWIFT(tindex).windspd = windspd;
            SWIFT(tindex).winddirR = NaN;
            if ustar ~= 9999
                SWIFT(tindex).windustar = ustar;
            end
        end

end
       

%% Log reprocessing and flags, then save new L2 file or overwrite existing one

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

save([sfile.folder slash sfile.name(1:end-6) 'L2.mat'],'SWIFT','sinfo')

%% End function
end
        
