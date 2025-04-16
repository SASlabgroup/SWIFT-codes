function L0_createSBD(missiondir,SBDfold,burstinterval,payloadtype)

% Read and concatenate all onboard processed SWIFT data (once offloaded from SD card) 
%   for a given mission located in 'missiondir'. User must specify the
%   burst interval (in minutes) and payloadtype (always string value '7').

%   K. Zeiden, 10/2024

if ispc
    slash = '\';
else
    slash = '/';
end

%% Mission name

islash = strfind(missiondir,slash);

if ~isempty(islash)
    sname = missiondir(islash(end)+1:end);
else
    sname = missiondir;
end

%% Create diary file

diaryfile = [missiondir slash sname '_L0_createSBD.txt'];
if exist(diaryfile,'file')
    diary off
delete(diaryfile);
end
diary(diaryfile)
disp(['Creating SBD files for ' sname])


%% Create folder for new SBD files

if ~exist([missiondir slash SBDfold],'dir')
    mkdir([missiondir slash SBDfold])
end

%% Create temporary binary file with payload type

payloadfile = [missiondir slash 'payload'];
fid = fopen(payloadfile,'wb');
fwrite(fid,payloadtype,'uint8');
fclose(fid);

%% Find all processed (PRC) files in all port folders

PRCfiles = dir([missiondir slash '*' slash 'Processed' slash '*' slash '*PRC*.dat']);

% Get reference burst files by identifying unique burst times from
% all payloads
burstfiletimes = NaN(length(PRCfiles),1);
for iburst = 1:length(burstfiletimes)
    date = datenum(PRCfiles(iburst).name(13:21));
    hour = str2double(PRCfiles(iburst).name(23:24));
    min = (str2double(PRCfiles(iburst).name(26:27))-1)*burstinterval;
    burstfiletimes(iburst) = date + datenum([0 0 0 hour min 0]);
end
[~,b] = unique(burstfiletimes);
refbfiles = PRCfiles(b);

%% Loop through reference burst files (IMU or SBG)

for iburst = 1:length(refbfiles)
       
    ID = refbfiles(iburst).name(1:7);
    date = refbfiles(iburst).name(13:21);
    hour = refbfiles(iburst).name(23:24);
    burstnum = refbfiles(iburst).name(26:27);
    bfilename = [date '_' hour '_' burstnum '_PRC.dat'];

    disp(['Creating SBD file for burst ' num2str(iburst) ' : ' bfilename(1:end-8)])

    % Name concat file same as if pulled from swiftserver
    minute = num2str((str2double(burstnum(2))-1) * burstinterval);
    if length(minute) == 1
        minute = ['0' minute]; %#ok<AGROW>
    end 
    sbdfile = [missiondir slash SBDfold slash 'buoy-SWIFT_' ID(6:7) '-' date '_' hour  minute '000.sbd'];

    % Find all PRC files for this burst (instead of globbing files)
    PRCburstfiles = PRCfiles(contains({PRCfiles.name},bfilename));

    % Create system commmand to concatenate files
    if ispc
    syscommand = ['copy /b ' payloadfile];
    for iprc = 1:length(PRCburstfiles)
        syscommand = [syscommand '+' PRCburstfiles(iprc).folder slash PRCburstfiles(iprc).name]; %#ok<*AGROW>
    end
    syscommand = [syscommand ' ' sbdfile];
    else
        syscommand = ['cat ' payloadfile];
        for iprc = 1:length(PRCburstfiles)
            syscommand = [syscommand ' ' PRCburstfiles(iprc).folder slash PRCburstfiles(iprc).name];
        end
        syscommand = [syscommand ' > ' sbdfile];
    end

    % Execute system command to concatenate files
    status = system(syscommand);
    if status~=0
        warning('SBD file creation (PRC concatenation) failed...')
    else
        disp(['SBD file ' sbdfile ' created.'])
    end

end % End burst loop
    
delete(payloadfile)
diary off

end % End function

