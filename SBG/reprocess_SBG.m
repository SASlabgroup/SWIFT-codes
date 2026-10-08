function [SWIFT,sinfo] = reprocess_SBG(missiondir,plotburst,saveraw,useGPS,interpf,tstart,opts)

arguments
    missiondir {mustBeTextScalar} % SWIFT mission directory
    plotburst (1,1) logical % Plot each processed burst
    saveraw (1,1) logical % Save cropped raw SBG measurements in SWIFT
    useGPS (1,1) logical % Calculate alternative energy from GPS positions
    interpf (1,1) logical % Interpolate spectra onto the existing frequency bands
    tstart (1,1) double {mustBeNonnegative,mustBeFinite} % Nominal crop start, in seconds
    opts.tmin (1,1) double {mustBeNonnegative,mustBeFinite} = tstart % Earliest allowed crop, in seconds
    opts.minimum_windows (1,1) double {mustBeInteger,mustBePositive} = 1 % Required overlapping spectral windows
    opts.save_product (1,1) logical = true % Save the L3 product
    opts.save_cache (1,1) logical = true % Cache converted raw SBG files
    opts.report_file {mustBeTextScalar} = "" % Processing report path; default is the mission directory
end

% Batch Matlab read-in and reprocess of SWIFT v4 SBG wave data
%   reprocessing is necessary to fix a bug in directional momements
%   all data prior 11/2017 need this reprocessing
%
% M. Schwendeman, 01/2017
% J. Thomson, 10/2017 add reprocessing to batch read of raw data,
%                   and replace SWIFT data structure results.
% K. Zeiden, July 2024
%   reformatting for use in master postprocessing script,
%   'postprocess_SWIFT'. 
%   Turned into function with mission directory as input

% For Willapa SWIFT26, tmin=76 follows the startup analysis. Keep the
% 256-second window and minimum_windows=1 to preserve frequency resolution
% while accepting lower nominal DOF for short records. Other Willapa
% missions retain tmin=tstart=90 because the earlier crop recovers no records.

missiondir = char(missiondir);
tmin = opts.tmin;
minimum_windows = opts.minimum_windows;
report_file = string(opts.report_file);
if strlength(report_file) == 0
    report_file = fullfile(missiondir,'SBG_processing_report.txt');
end
if tmin > tstart
    error('reprocess_SBG:InvalidCrop', ...
        'Minimum crop must not exceed tstart.')
end

if ispc 
    slash = '\';
else
    slash = '/';
end

%% Load the existing L3, or L2 when L3 does not exist.

l2file = dir([missiondir slash '*SWIFT*L2.mat']);
l3file = dir([missiondir slash '*SWIFT*L3.mat']);

if ~isempty(l3file)
    sfile = l3file;
    load([sfile.folder slash sfile.name],'SWIFT','sinfo');
elseif ~isempty(l2file)
    sfile = l2file;
    load([sfile.folder slash sfile.name],'SWIFT','sinfo');
else
    warning(['No L2 or L3 product found for ' missiondir(end-16:end) '. Skipping...'])
    return
end

%% Length of raw burst data to process, from end of burst (must be > 1536/5 = 307.2 s)
% tproc = 475;% seconds
% Moved to input, changed to fixed start, K. Zeiden 05/22/2025

%% Sampling Rate
fs = 5; % should be 5 Hz for standard SBG settings

%% Flag bad wave data
badwaves = false(1,length(SWIFT));
SWIFTreplaced = false(1,length(SWIFT));

% Compact per-record processing report
status = repmat("no_raw_sbg",length(SWIFT),1);
error_message = strings(length(SWIFT),1);
source_file = strings(length(SWIFT),1);
crop_seconds = NaN(length(SWIFT),1);
window_count = NaN(length(SWIFT),1);
usable_points = NaN(length(SWIFT),1);
usable_seconds = NaN(length(SWIFT),1);
nominal_dof = NaN(length(SWIFT),1);
sbg_shipmotion = false(length(SWIFT),1);
sbg_gpsvel = false(length(SWIFT),1);
sbg_gpspos = false(length(SWIFT),1);
sbg_imu = false(length(SWIFT),1);
sbg_euler = false(length(SWIFT),1);
sbg_utc = false(length(SWIFT),1);

%% Loop through raw burst files and reprocess

bfiles = dir([missiondir slash '*' slash 'Raw' slash '*' slash '*SBG*.dat']);

for iburst = 1:length(bfiles)

    bname = bfiles(iburst).name(1:end-4);
    burstID = extractAfter(bname,'_SBG_');
    sindex = find(strcmp(burstID,{SWIFT.burstID}'));
    if isempty(sindex)
        disp('No matching SWIFT index. Skipping...')
        continue
    end

    disp(['Burst ' num2str(iburst) ' : ' bname])
    source_file(sindex) = string(fullfile(bfiles(iburst).folder,bfiles(iburst).name));
    status(sindex) = "processing_error";

    try
    % Read or load raw IMU data
    clear sbgData
    if isempty(dir([bfiles(iburst).folder slash bfiles(iburst).name(1:end-4) '.mat']))
        disp('Reading raw SBG data...')
        if bfiles(iburst).bytes == 0
            error('reprocess_SBG:RawEmpty','Raw SBG file is empty.')
        end
        sbgData = sbgBinaryToMatlab([bfiles(iburst).folder slash bfiles(iburst).name]);
        if opts.save_cache
            save([bfiles(iburst).folder slash bfiles(iburst).name(1:end-4) '.mat'],'sbgData')
        end
    else
        load([bfiles(iburst).folder slash bfiles(iburst).name(1:end-4) '.mat'],'sbgData')
    end
    if isempty(sbgData)
        error('reprocess_SBG:RawEmpty','SBG data are empty.')
    end
    sbg_shipmotion(sindex) = isfield(sbgData,'ShipMotion');
    sbg_gpsvel(sindex) = isfield(sbgData,'GpsVel');
    sbg_gpspos(sindex) = isfield(sbgData,'GpsPos');
    sbg_imu(sindex) = isfield(sbgData,'ImuData');
    sbg_euler(sindex) = isfield(sbgData,'EkfEuler');
    sbg_utc(sindex) = isfield(sbgData,'UtcTime');
    if ~sbg_shipmotion(sindex) || ~sbg_gpsvel(sindex) || ...
            ~sbg_gpspos(sindex)
        error('reprocess_SBG:MissingRequiredStream', ...
            'ShipMotion, GpsVel, or GpsPos is missing.')
    end
    if isempty(sbgData.ShipMotion.heave) || ...
            isempty(sbgData.GpsVel.vel_e) || isempty(sbgData.GpsPos.lat)
        error('reprocess_SBG:RawEmpty', ...
            'Required SBG streams contain no samples.')
    end

    % IMU Motion
    z = sbgData.ShipMotion.heave(:)';
    x = sbgData.ShipMotion.surge(:)';
    y = sbgData.ShipMotion.sway(:)';
    ztime = sbgData.ShipMotion.time_stamp(:)'*10^(-6);% Convert to seconds
    imin = min([length(x) length(y) length(z) length(ztime)]);
    x = x(1:imin);y = y(1:imin);z = z(1:imin);ztime = ztime(1:imin);
    [~,iu] = unique(ztime);x = x(iu);y = y(iu);z = z(iu);ztime = ztime(iu);

    % GPS position
    lat = sbgData.GpsPos.lat(:)';
    lon = sbgData.GpsPos.long(:)';
    ltime = sbgData.GpsPos.time_stamp(:)'*10^(-6);
    imin = min([length(lon) length(lat) length(ltime)]);
    lat = lat(1:imin); lon = lon(1:imin); ltime = ltime(1:imin);
    [~,iu] = unique(ltime);lon = lon(iu);lat = lat(iu);ltime = ltime(iu);

    % GPS motion
    u = sbgData.GpsVel.vel_e(:)';
    v = sbgData.GpsVel.vel_n(:)';
    gpstime = sbgData.GpsVel.time_stamp(:)'*10^(-6);
    imin = min([length(u) length(v) length(gpstime)]);
    u = u(1:imin); v = v(1:imin); gpstime = gpstime(1:imin);
    [~,iu] = unique(gpstime);
    u = u(iu);v = v(iu);gpstime = gpstime(iu);

    % Interpolate to common time, using GPS time
    igood = ~isnan(lat) & ~isnan(lon) & ltime ~= 0;
    lat = interp1(ltime(igood),lat(igood),gpstime);
    lon = interp1(ltime(igood),lon(igood),gpstime);
    igood = ~isnan(x) & ~isnan(y) & ~isnan(z) & ztime ~= 0;
    z = interp1(ztime(igood),z(igood),gpstime);
    x = interp1(ztime(igood),x(igood),gpstime);
    y = interp1(ztime(igood),y(igood),gpstime);

    % Select the latest allowed crop supporting the requested number of
    % 256-second windows used by the unchanged SBGwaves implementation.
    finite = isfinite(z+x+y+u+v+lat+lon);
    imin = max(1,round(tmin*fs));
    if imin <= length(finite)
        usable_points(sindex) = nnz(finite(imin:end));
        usable_seconds(sindex) = usable_points(sindex)/fs;
    end
    w = round(fs*256);
    required = ceil((minimum_windows+3)*w/4);
    for candidate = tstart:-1:tmin
        % Match the original tstart*fs:end indexing.
        istart = max(1,round(candidate*fs));
        if istart <= length(finite) && nnz(finite(istart:end)) >= required
            crop_seconds(sindex) = candidate;
            window_count(sindex) = floor(4*(nnz(finite(istart:end))/w-1)+1);
            usable_points(sindex) = nnz(finite(istart:end));
            usable_seconds(sindex) = usable_points(sindex)/fs;
            % SBGwaves merges three bands: nominal DOF = 2*nwin*merge.
            nominal_dof(sindex) = 2*window_count(sindex)*3;
            break
        end
    end
    if ~isfinite(crop_seconds(sindex))
        status(sindex) = "insufficient_usable_data";
        error_message(sindex) = "Too few usable spectral windows.";
        continue
    end

    if plotburst

            figure('color','w')
            MP = get(0,'monitorposition');
            set(gcf,'outerposition',MP(1,:));
            subplot(3,1,1)
            plot(gpstime,z,'-kx')
            hold on;
            plot(gpstime,filloutliers(z,'linear'),'-rx')
            ylabel('\eta [m]');ylim([-2 2])
            plot(crop_seconds(sindex)*[1 1],ylim,':k','LineWidth',2)
            legend('Raw','Despiked','Start')
            title(bname,'interpreter','none')
        
            subplot(3,1,2)
            plot(gpstime,u,'-kx')
            hold on;
            plot(gpstime,filloutliers(u,'linear'),'-rx')
            ylabel('u [ms^{-2}]');ylim([-2 2])
            plot(crop_seconds(sindex)*[1 1],ylim,':k','LineWidth',2)
        
            subplot(3,1,3)
            plot(gpstime,v,'-kx')
            hold on;axis tight
            plot(gpstime,filloutliers(v,'linear'),'-rx')
            xlabel('Time [s]');
            ylabel('v [ms^{-2}]');ylim([-2 2])
            plot(crop_seconds(sindex)*[1 1],ylim,':k','LineWidth',2)

            h = findall(gcf,'Type','Axes');
            linkaxes(h,'x');
            xlim([0 max([550 max(gpstime)])])
        
            print([bfiles(iburst).folder '\' bfiles(iburst).name(1:end-4)],'-dpng')
            close gcf
    end

    % Crop and despike data
    z = filloutliers(z(istart:end),'linear');
    x = filloutliers(x(istart:end),'linear');
    y = filloutliers(y(istart:end),'linear');
    lat = filloutliers(lat(istart:end), 'linear');
    lon = filloutliers(lon(istart:end), 'linear');
    u = filloutliers(u(istart:end),'linear');
    v = filloutliers(v(istart:end),'linear');

    % Remove NaNs?
    ibad = isnan(z + x + y + u + v + lat + lon);
    z(ibad) = []; x(ibad) = []; y(ibad)=[]; u(ibad)=[]; 
    v(ibad)=[]; lat(ibad)=[]; lon(ibad)=[];

    % Recalculate wave spectra to get proper directional moments 
    %   (bug fix in 11/2017)
    f = SWIFT(sindex).wavespectra.freq;  % original frequency bands
    [newHs,newTp,newDp,newE,newf,newa1,newb1,newa2,newb2,newcheck] = ...
        SBGwaves(u,v,z,fs);

    if ~any(~isnan(newE))
        warning('NaN Spectra from SBGwaves')
    end

    % Alternative results using GPS velocites
    [altHs,altTp,altDp,altE,altf,alta1,altb1,alta2,altb2] = GPSwaves(u,v,[],fs);    


        % Interpolate results to L1 frequency bands
        if interpf
            E = interp1(newf,newE,f);
            if length(altE) > 1 
                altE = interp1(altf,altE,f); 
            else 
                altE = NaN(size(f)); 
            end
            a1 = interp1(newf,newa1,f);
            b1 = interp1(newf,newb1,f);
            a2 = interp1(newf,newa2,f);
            b2 = interp1(newf,newb2,f);
            check = interp1(newf,newcheck,f);
        else
            E = newE;
            altE = altE;
            f = newf;
            a1 = newa1;
            b1 = newb1;
            a2 = newa2;
            b2 = newb2;
            check = newcheck;
        end

        % Spectra computed from GPS positions as alternative to GPS velocities if specified
        if useGPS
            [Elat,~] = pwelch(detrend(deg2km(lat)*1000),[],[],[], fs );
            [Elon,fgps] = pwelch(detrend(deg2km(lon,cosd(median(lat))*6371)*1000),[],[],[],fs);
            altE = interp1(fgps, Elat + Elon, f);
        end

        % Convert wave directions to degrees FROM
        dirto = newDp;
        if dirto >=180
            newDp = dirto - 180;
            elseif dirto <180
                newDp = dirto + 180;
            else
        end

        % Replace new wave spectral variables in original SWIFT structure
        SWIFT(sindex).sigwaveheight = newHs;
        SWIFT(sindex).peakwaveperiod = newTp;
        SWIFT(sindex).peakwavedirT = newDp;
        SWIFT(sindex).wavespectra.energy = E;
        SWIFT(sindex).wavespectra.freq = f;
        SWIFT(sindex).wavespectra.a1 = a1;
        SWIFT(sindex).wavespectra.b1 = b1;
        SWIFT(sindex).wavespectra.a2 = a2;
        SWIFT(sindex).wavespectra.b2 = b2;
        SWIFT(sindex).wavespectra.check = check;
        SWIFT(sindex).wavespectra.dof = nominal_dof(sindex);
        if useGPS
           SWIFT(sindex).wavespectra.energy_alt = altE;
           SWIFT(sindex).peakwaveperiod_alt = altTp;
           SWIFT(sindex).sigwaveheight_alt = altHs;
        end
        SWIFTreplaced(sindex) = true;
        status(sindex) = "reprocessed_256s";

        % Save raw displacements (5 Hz) if specified
        if saveraw 

            % Time 
            sbgtime = datenum(sbgData.UtcTime.year, sbgData.UtcTime.month, sbgData.UtcTime.day, sbgData.UtcTime.hour,...
                sbgData.UtcTime.min, sbgData.UtcTime.sec + sbgData.UtcTime.nanosec./1e9);
            t = sbgtime(end-tproc*5+1:end);
            t = filloutliers(t,'linear');
            t(ibad) = [];
            
            SWIFT(sindex).x = x;
            SWIFT(sindex).y = y;
            SWIFT(sindex).z = z;
            SWIFT(sindex).rawtime = t;
            SWIFT(sindex).u = u;
            SWIFT(sindex).v = v;

        end

        % Flag bad bursts when processing fails (9999 error code)
        if isempty(u)
            badwaves(sindex) = true;
        end

        if newHs == 9999 || ~isfinite(newHs) || ~isfinite(newTp) || ...
                ~any(isfinite(E))
            disp('wave processing gave an invalid spectrum')
            SWIFT(sindex).sigwaveheight = NaN;
            SWIFT(sindex).peakwaveperiod = NaN;
            SWIFT(sindex).peakwaveperiod = NaN;
            SWIFT(sindex).peakwavedirT = NaN;
            badwaves(sindex) = true;
            SWIFTreplaced(sindex) = false;
            status(sindex) = "invalid_spectrum";
        end

        if altHs == 9999
            SWIFT(sindex).sigwaveheight_alt = NaN;
            SWIFT(sindex).peakwaveperiod_alt = NaN;
        end

        if newDp > 9000 % sometimes only the directions fail
            SWIFT(sindex).peakwavedirT = NaN;
        end

catch ME
    if strcmp(ME.identifier,'reprocess_SBG:RawEmpty')
        status(sindex) = "raw_empty";
    elseif strcmp(ME.identifier,'reprocess_SBG:MissingRequiredStream')
        status(sindex) = "missing_required_stream";
    else
        status(sindex) = "processing_error";
    end
    error_message(sindex) = string(ME.identifier) + ": " + string(ME.message);
    warning('reprocess_SBG:RecordFailed','%s: %s',burstID,ME.message)
end

% End file loop
end

%% NaN out bursts that weren't reprocessed 

if any(~SWIFTreplaced)
    for sindex = find(~SWIFTreplaced)

        % if ~exist('f','var')
            f = SWIFT(sindex).wavespectra.freq;
        % end
            SWIFT(sindex).sigwaveheight = NaN;
            SWIFT(sindex).peakwaveperiod = NaN;
            SWIFT(sindex).peakwavedirT = NaN;
            SWIFT(sindex).wavespectra.energy = NaN(size(f));
            SWIFT(sindex).wavespectra.freq = f;
            SWIFT(sindex).wavespectra.a1 = NaN(size(f));
            SWIFT(sindex).wavespectra.b1 = NaN(size(f));
            SWIFT(sindex).wavespectra.a2 = NaN(size(f));
            SWIFT(sindex).wavespectra.b2 = NaN(size(f));
            SWIFT(sindex).wavespectra.check = NaN(size(f));
            SWIFT(sindex).wavespectra.dof = NaN;
            if useGPS
                SWIFT(sindex).wavespectra.energy_alt = NaN(size(f));
                SWIFT(sindex).sigwaveheight_alt = NaN;
                SWIFT(sindex).peakwaveperiod_alt = NaN;
            end
    end
end


%% Log reprocessing and flags, then save new L3 file or overwrite existing one

params.useGPS = useGPS;
params.saveraw = saveraw;
params.interpf = interpf;
params.tstart = tstart;
params.tmin = tmin;
params.minimum_windows = minimum_windows;
params.crop_seconds = crop_seconds;
params.window_count = window_count;
params.usable_points = usable_points;
params.usable_seconds = usable_seconds;
params.nominal_dof = nominal_dof;
params.save_product = opts.save_product;
params.save_cache = opts.save_cache;

if isfield(sinfo,'postproc')
ip = length(sinfo.postproc)+1; 
else
    sinfo.postproc = struct;
    ip = 1;
end
sinfo.postproc(ip).type = 'SBG';
sinfo.postproc(ip).usr = getenv('username');
sinfo.postproc(ip).time = string(datetime('now'));
sinfo.postproc(ip).flags.badwaves = badwaves;
sinfo.postproc(ip).flags.status = status;
sinfo.postproc(ip).flags.SBGwaves_reprocessed = SWIFTreplaced;
sinfo.postproc(ip).flags.SBGwaves_reduced_dof = ...
    (SWIFTreplaced(:) & window_count < 4)';
sinfo.postproc(ip).params = params;

% Record which source types were present for every expected burst.
sbgfiles = dir([missiondir slash '*' slash 'Raw' slash '*' slash '*SBG*.*']);
sigfiles = dir([missiondir slash '*' slash 'Raw' slash '*' slash '*SIG*.*']);
imufiles = dir([missiondir slash '*' slash 'Raw' slash '*' slash '*IMU*.*']);
pb2files = dir([missiondir slash '*' slash 'Raw' slash '*' slash '*PB2*.*']);
sbg_present = false(length(SWIFT),1);
sig_present = false(length(SWIFT),1);
imu_present = false(length(SWIFT),1);
pb2_present = false(length(SWIFT),1);
for i = 1:length(SWIFT)
    id = string(SWIFT(i).burstID);
    sbg_present(i) = any(contains(string({sbgfiles.name}),id));
    sig_present(i) = any(contains(string({sigfiles.name}),id));
    imu_present(i) = any(contains(string({imufiles.name}),id));
    pb2_present(i) = any(contains(string({pb2files.name}),id));
end
burst_id = string({SWIFT.burstID})';
record_time = datetime([SWIFT.time]','ConvertFrom','datenum');
sbg_reprocessed = SWIFTreplaced(:);
reduced_dof = sbg_reprocessed & window_count < 4;

fid = fopen(report_file,'w');
if fid < 0
    warning('reprocess_SBG:ReportOpenFailed', ...
        'Could not open processing report: %s',report_file)
else
    report_cleanup = onCleanup(@() fclose(fid));
    fprintf(fid,['burst_id\trecord_time\tstatus\terror_message\tsource_file' ...
        '\tsbg_present\tsig_present\timu_present\tpb2_present' ...
        '\tsbg_shipmotion\tsbg_gpsvel\tsbg_gpspos\tsbg_imu\tsbg_euler\tsbg_utc' ...
        '\tcrop_seconds\twindow_count\tusable_points\tusable_seconds\tnominal_dof' ...
        '\tsbg_reprocessed\treduced_dof\n']);
    for i = 1:length(SWIFT)
        fields = [burst_id(i),string(record_time(i),'yyyy-MM-dd HH:mm:ss'), ...
            status(i),error_message(i),source_file(i), ...
            string([sbg_present(i),sig_present(i),imu_present(i),pb2_present(i), ...
            sbg_shipmotion(i),sbg_gpsvel(i),sbg_gpspos(i),sbg_imu(i), ...
            sbg_euler(i),sbg_utc(i)]), ...
            string([crop_seconds(i),window_count(i),usable_points(i), ...
            usable_seconds(i),nominal_dof(i)]), ...
            string([sbg_reprocessed(i),reduced_dof(i)])];
        fields = replace(replace(fields,sprintf('\t'),' '),newline,' ');
        fprintf(fid,'%s\n',char(join(fields,sprintf('\t'))));
    end
end

% Add expected ten-minute slots absent from L2. Do not bridge breaks longer
% than one day, which can separate deployments or expose stray old records.
record_slot = unique(sort(round([SWIFT.time]'*24*6)));
slot_gap = diff(record_slot);
missing_slot = [];
for igap = find(slot_gap > 1 & slot_gap <= 24*6)'
    missing_slot = [missing_slot; ...
        (record_slot(igap)+1:record_slot(igap+1)-1)']; %#ok<AGROW>
end
if ~isempty(missing_slot) && fid >= 0
    missing_time = datetime(missing_slot/(24*6),'ConvertFrom','datenum');
    for i = 1:length(missing_slot)
        id = string(datestr(missing_time(i),'ddmmmyyyy')) + "_" + ...
            sprintf('%02d',hour(missing_time(i))) + "_" + ...
            sprintf('%02d',floor(minute(missing_time(i))/10)+1);
        isbg = find(contains(string({sbgfiles.name}),id),1);
        missing_source = "";
        if ~isempty(isbg)
            missing_source = string(fullfile( ...
                sbgfiles(isbg).folder,sbgfiles(isbg).name));
        end
        fields = [id,string(missing_time(i),'yyyy-MM-dd HH:mm:ss'), ...
            "no_l2_record","Expected ten-minute slot is absent from L2.", ...
            missing_source,string([~isempty(isbg), ...
            any(contains(string({sigfiles.name}),id)), ...
            any(contains(string({imufiles.name}),id)), ...
            any(contains(string({pb2files.name}),id)),false(1,6)]), ...
            string(NaN(1,5)),string(false(1,2))];
        fprintf(fid,'%s\n',char(join(fields,sprintf('\t'))));
    end
end

if opts.save_product
    save([sfile.folder slash sfile.name(1:end-6) 'L3.mat'],'SWIFT','sinfo')
end

%% End function
end
