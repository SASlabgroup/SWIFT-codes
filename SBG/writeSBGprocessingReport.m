function writeSBGprocessingReport(missiondir,SWIFT,filename,processing)

arguments
    missiondir {mustBeTextScalar} % SWIFT mission directory
    SWIFT struct % Processed SWIFT records
    filename {mustBeTextScalar} % Output text-file path
    processing struct % Per-record SBG processing state and provenance
end

% Write a tab-delimited SBG processing report, including source availability
% for records in L2 and for expected ten-minute slots that are absent from L2.

sbgfiles = dir(fullfile(missiondir,'*','Raw','*','*SBG*.*'));
sigfiles = dir(fullfile(missiondir,'*','Raw','*','*SIG*.*'));
imufiles = dir(fullfile(missiondir,'*','Raw','*','*IMU*.*'));
pb2files = dir(fullfile(missiondir,'*','Raw','*','*PB2*.*'));

nrecord = length(SWIFT);
sbg_present = false(nrecord,1);
sig_present = false(nrecord,1);
imu_present = false(nrecord,1);
pb2_present = false(nrecord,1);
for i = 1:nrecord
    id = string(SWIFT(i).burstID);
    sbg_present(i) = any(contains(string({sbgfiles.name}),id));
    sig_present(i) = any(contains(string({sigfiles.name}),id));
    imu_present(i) = any(contains(string({imufiles.name}),id));
    pb2_present(i) = any(contains(string({pb2files.name}),id));
end

burst_id = string({SWIFT.burstID})';
record_time = datetime([SWIFT.time]','ConvertFrom','datenum');

fid = fopen(filename,'w');
if fid < 0
    warning('writeSBGprocessingReport:ReportOpenFailed', ...
        'Could not open processing report: %s',filename)
    return
end
report_cleanup = onCleanup(@() fclose(fid));

fprintf(fid,['burst_id\trecord_time\tstatus\terror_message\tsource_file' ...
    '\tsbg_present\tsig_present\timu_present\tpb2_present' ...
    '\tsbg_shipmotion\tsbg_gpsvel\tsbg_gpspos\tsbg_imu\tsbg_euler\tsbg_utc' ...
    '\tcrop_seconds\twindow_count\tusable_points\tusable_seconds\tnominal_dof' ...
    '\tsbg_reprocessed\treduced_dof\n']);
for i = 1:nrecord
    fields = [burst_id(i),string(record_time(i),'yyyy-MM-dd HH:mm:ss'), ...
        processing.status(i),processing.error_message(i), ...
        processing.source_file(i), ...
        string([sbg_present(i),sig_present(i),imu_present(i),pb2_present(i), ...
        processing.sbg_shipmotion(i),processing.sbg_gpsvel(i), ...
        processing.sbg_gpspos(i),processing.sbg_imu(i), ...
        processing.sbg_euler(i),processing.sbg_utc(i)]), ...
        string([processing.crop_seconds(i),processing.window_count(i), ...
        processing.usable_points(i),processing.usable_seconds(i), ...
        processing.nominal_dof(i)]), ...
        string([processing.sbg_reprocessed(i),processing.reduced_dof(i)])];
    fields = replace(replace(fields,sprintf('\t'),' '),newline,' ');
    fprintf(fid,'%s\n',char(join(fields,sprintf('\t'))));
end

% Do not bridge breaks longer than one day, which can separate deployments
% or expose stray old records.
record_slot = unique(sort(round([SWIFT.time]'*24*6)));
slot_gap = diff(record_slot);
missing_slot = [];
for igap = find(slot_gap > 1 & slot_gap <= 24*6)'
    missing_slot = [missing_slot; ...
        (record_slot(igap)+1:record_slot(igap+1)-1)'];
end

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
