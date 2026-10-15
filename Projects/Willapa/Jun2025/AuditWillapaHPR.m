function [inventory,summary,failures,lagsummary] = AuditWillapaHPR(expdir,outdir)
% Audit Willapa Signature HPR source coverage and processing results.
%
% This is read-only with respect to the mission archive. It inventories the
% union of L4 records and all raw/reformatted SIG and SBG files, then joins
% the per-mission audits written by FixSIGENU_Willapa. The summary goes to
% <outdir>/L5_review.

if nargin < 1 || isempty(expdir)
    expdir = '/Volumes/PortableSSD/MooredSWIFTS';
end
if nargin < 2 || isempty(outdir)
    outdir = expdir;     % where FixSIGENU_Willapa wrote the per-mission audits
end
if ~isfolder(expdir)
    error('Willapa archive is not mounted: %s',expdir)
end

reviewdir = fullfile(outdir,'L5_review');
if ~exist(reviewdir,'dir'); mkdir(reviewdir); end

missions = dir(fullfile(expdir,'SWIFT2*'));
missions = missions([missions.isdir]);
[~,isort] = sort({missions.name});
missions = missions(isort);

entries = containers.Map('KeyType','char','ValueType','any');
missionmeta = repmat(struct('name',"",'platform',"",'tmin',NaN, ...
    'tmax',NaN,'l4path',"",'l4bytes',NaN,'l4date',"", ...
    'nrecords',0,'nfinite',0),length(missions),1);

%% Index every L4 record

for im = 1:length(missions)
    mission = string(missions(im).name);
    missiondir = fullfile(missions(im).folder,missions(im).name);
    platform = extractBefore(mission,'_');
    platform = erase(platform,'SWIFT');
    missionmeta(im).name = mission;
    missionmeta(im).platform = platform;

    l4files = dir(fullfile(missiondir,'*L4.mat'));
    l4files = l4files(~startsWith({l4files.name},'._'));
    if isempty(l4files)
        warning('No L4 file for %s',mission)
        continue
    end
    [~,inew] = max([l4files.datenum]);
    l4file = l4files(inew);
    l4path = string(fullfile(l4file.folder,l4file.name));
    data = load(l4path,'SWIFT');
    SWIFT = data.SWIFT;

    missionmeta(im).l4path = l4path;
    missionmeta(im).l4bytes = l4file.bytes;
    missionmeta(im).l4date = string(l4file.date);
    missionmeta(im).nrecords = length(SWIFT);
    stime = [SWIFT.time];
    missionmeta(im).tmin = min(stime,[],'omitnan');
    missionmeta(im).tmax = max(stime,[],'omitnan');

    nfinite = 0;
    for ir = 1:length(SWIFT)
        burstID = string(SWIFT(ir).burstID);
        key = char(platform + "|" + burstID);
        entry = getEntry(entries,key,mission,platform,burstID,true);
        entry.mission = mission;
        entry.l4indices(end+1) = ir;
        entry.l4times(end+1) = SWIFT(ir).time;
        entry.l4path = l4path;
        entry.l4finitebins(end+1) = finiteProfileBins(SWIFT(ir));
        nfinite = nfinite + (entry.l4finitebins(end) > 0);
        entries(key) = entry;
    end
    missionmeta(im).nfinite = nfinite;
end

%% Index all source files in the complete archive

sigfiles = dir(fullfile(expdir,'**','SWIFT*_SIG_*'));
sigfiles = sigfiles(~[sigfiles.isdir]);
sigfiles = sigfiles(~startsWith({sigfiles.name},'._'));
for ifile = 1:length(sigfiles)
    [~,~,ext] = fileparts(sigfiles(ifile).name);
    if ~ismember(lower(string(ext)),[".dat" ".mat"]); continue; end
    [platform,burstID,ok] = parseSourceName(sigfiles(ifile).name,'SIG');
    path = string(fullfile(sigfiles(ifile).folder,sigfiles(ifile).name));
    % Mission-level products such as *_SIG_HPR.mat share the broad prefix
    % but are not burst sources. Retain malformed IDs only within SIG source
    % directories so they remain visible without misclassifying products.
    if ~ok && ~contains(path,string(filesep)+"SIG"+string(filesep)); continue; end
    if ok
        key = char(platform + "|" + burstID);
    else
        key = sprintf('UNPARSED|SIG|%06d',ifile);
    end
    entry = getEntry(entries,key,"",platform,burstID,ok);
    if lower(string(ext)) == ".dat"
        entry.datpaths(end+1,1) = path;
        entry.datbytes(end+1,1) = sigfiles(ifile).bytes;
    else
        entry.sigpaths(end+1,1) = path;
        entry.sigbytes(end+1,1) = sigfiles(ifile).bytes;
    end
    entries(key) = entry;
end

sbgfiles = dir(fullfile(expdir,'**','SWIFT*_SBG_*.mat'));
sbgfiles = sbgfiles(~[sbgfiles.isdir]);
sbgfiles = sbgfiles(~startsWith({sbgfiles.name},'._'));
for ifile = 1:length(sbgfiles)
    [platform,burstID,ok] = parseSourceName(sbgfiles(ifile).name,'SBG');
    path = string(fullfile(sbgfiles(ifile).folder,sbgfiles(ifile).name));
    if ~ok && ~contains(path,string(filesep)+"SBG"+string(filesep)); continue; end
    if ok
        key = char(platform + "|" + burstID);
    else
        key = sprintf('UNPARSED|SBG|%06d',ifile);
    end
    entry = getEntry(entries,key,"",platform,burstID,ok);
    entry.sbgpaths(end+1,1) = path;
    entry.sbgbytes(end+1,1) = sbgfiles(ifile).bytes;
    entries(key) = entry;
end

%% Load existing burst audits once

missionaudit = cell(length(missions),1);
for im = 1:length(missions)
    mission = string(missions(im).name);
    auditfile = fullfile(outdir,char(mission),'L5_review', ...
        char(mission + "_L5_source_audit.csv"));
    if isfile(auditfile)
        missionaudit{im} = readtable(auditfile,'TextType','string', ...
            'Delimiter',',');
    else
        missionaudit{im} = table;
    end
end

%% Convert the union index to a table

keys = string(entries.keys)';
nrow = length(keys);
mission = strings(nrow,1);
platform = strings(nrow,1);
burstID = strings(nrow,1);
time = NaN(nrow,1);
time_utc = strings(nrow,1);
id_parse_ok = false(nrow,1);
in_l4 = false(nrow,1);
l4_count = zeros(nrow,1);
l4_index = NaN(nrow,1);
l4_path = strings(nrow,1);
l4_finite_bins = NaN(nrow,1);
dat_count = zeros(nrow,1);
dat_bytes = zeros(nrow,1);
dat_paths = strings(nrow,1);
sig_mat_count = zeros(nrow,1);
sig_mat_bytes = zeros(nrow,1);
sig_mat_path = strings(nrow,1);
sig_mat_paths = strings(nrow,1);
sig_partial = false(nrow,1);
sbg_mat_count = zeros(nrow,1);
sbg_mat_bytes = zeros(nrow,1);
sbg_mat_path = strings(nrow,1);
sbg_mat_paths = strings(nrow,1);
duplicate_l4 = false(nrow,1);
duplicate_sig = false(nrow,1);
duplicate_sbg = false(nrow,1);
source_without_l4 = false(nrow,1);
dat_without_sig_mat = false(nrow,1);
process_status = strings(nrow,1);
action = strings(nrow,1);
profile_rms_change = NaN(nrow,1);
profile_max_change = NaN(nrow,1);
time_source = strings(nrow,1);
final_lag_seconds = NaN(nrow,1);
raw_time_lag_seconds = NaN(nrow,1);
local_median_lag_seconds = NaN(nrow,1);
raw_lag_departure_seconds = NaN(nrow,1);
lag_correlation = NaN(nrow,1);
used_interpolated_lag = false(nrow,1);
extrapolated_lag = false(nrow,1);
lag_method = strings(nrow,1);
lag_reason = strings(nrow,1);
bad_ahrs_matrix_pings = NaN(nrow,1);
mean_broadband_correlation = NaN(nrow,1);
sig_load_status = strings(nrow,1);
sig_has_avg = false(nrow,1);
sig_has_burst = false(nrow,1);
sig_sample_count = NaN(nrow,1);
sig_duration_minutes = NaN(nrow,1);
sbg_load_status = strings(nrow,1);
sbg_has_data = false(nrow,1);
sbg_euler_samples = NaN(nrow,1);
sbg_imu_samples = NaN(nrow,1);
sbg_duration_minutes = NaN(nrow,1);

for irow = 1:nrow
    entry = entries(char(keys(irow)));
    mission(irow) = assignMission(entry,missionmeta);
    platform(irow) = entry.platform;
    burstID(irow) = entry.burstID;
    id_parse_ok(irow) = entry.idparseok;

    if ~isempty(entry.l4indices)
        in_l4(irow) = true;
        l4_count(irow) = length(entry.l4indices);
        l4_index(irow) = entry.l4indices(1);
        l4_path(irow) = entry.l4path;
        l4_finite_bins(irow) = max(entry.l4finitebins);
        time(irow) = entry.l4times(1);
    else
        time(irow) = burstNameToDatenum(entry.burstID);
    end
    if isfinite(time(irow)); time_utc(irow) = string(datestr(time(irow),31)); end

    dat_count(irow) = length(entry.datpaths);
    dat_bytes(irow) = sum(entry.datbytes);
    dat_paths(irow) = strjoin(entry.datpaths,';');
    sig_mat_count(irow) = length(entry.sigpaths);
    sig_mat_paths(irow) = strjoin(entry.sigpaths,';');
    if ~isempty(entry.sigpaths)
        [sig_mat_bytes(irow),ibig] = max(entry.sigbytes);
        sig_mat_path(irow) = entry.sigpaths(ibig);
        sig_partial(irow) = contains(sig_mat_path(irow),'_partial.mat');
    end
    sbg_mat_count(irow) = length(entry.sbgpaths);
    sbg_mat_paths(irow) = strjoin(entry.sbgpaths,';');
    if ~isempty(entry.sbgpaths)
        [sbg_mat_bytes(irow),ibig] = max(entry.sbgbytes);
        sbg_mat_path(irow) = entry.sbgpaths(ibig);
    end

    duplicate_l4(irow) = l4_count(irow) > 1;
    duplicate_sig(irow) = sig_mat_count(irow) > 1;
    duplicate_sbg(irow) = sbg_mat_count(irow) > 1;
    source_without_l4(irow) = ~in_l4(irow) && ...
        (dat_count(irow) > 0 || sig_mat_count(irow) > 0 || sbg_mat_count(irow) > 0);
    dat_without_sig_mat(irow) = dat_count(irow) > 0 && sig_mat_count(irow) == 0;

    im = find(string({missionmeta.name}) == mission(irow),1);
    if isempty(im) || isempty(missionaudit{im}); continue; end
    audit = missionaudit{im};
    ia = find(string(audit.burstID) == burstID(irow),1);
    if isempty(ia); continue; end
    process_status(irow) = auditString(audit,ia,'status');
    action(irow) = auditString(audit,ia,'action');
    profile_rms_change(irow) = auditNumber(audit,ia,'profile_rms_change');
    profile_max_change(irow) = auditNumber(audit,ia,'profile_max_change');
    time_source(irow) = auditString(audit,ia,'time_source');
    final_lag_seconds(irow) = 86400*auditNumber(audit,ia,'time_lag');
    raw_time_lag_seconds(irow) = ...
        auditNumber(audit,ia,'raw_time_lag_seconds');
    local_median_lag_seconds(irow) = ...
        auditNumber(audit,ia,'local_median_lag_seconds');
    raw_lag_departure_seconds(irow) = ...
        auditNumber(audit,ia,'raw_lag_departure_seconds');
    lag_correlation(irow) = auditNumber(audit,ia,'lag_correlation');
    used_interpolated_lag(irow) = ...
        auditLogical(audit,ia,'used_interpolated_lag');
    extrapolated_lag(irow) = auditLogical(audit,ia,'extrapolated_lag');
    lag_method(irow) = auditString(audit,ia,'lag_method');
    lag_reason(irow) = auditString(audit,ia,'lag_reason');
    bad_ahrs_matrix_pings(irow) = ...
        auditNumber(audit,ia,'bad_ahrs_matrix_pings');
    mean_broadband_correlation(irow) = ...
        auditNumber(audit,ia,'mean_broadband_correlation');
end

% Older audits do not contain the expanded lag provenance. Preserve what can
% be inferred, but leave the unknown raw lag explicit for replaced records.
oldDirect = isfinite(final_lag_seconds) & ~used_interpolated_lag & ...
    ~isfinite(raw_time_lag_seconds);
raw_time_lag_seconds(oldDirect) = final_lag_seconds(oldDirect);
lag_method(oldDirect & lag_method == "") = "direct";
lag_reason(oldDirect & lag_reason == "") = "legacy_audit";
oldReplaced = isfinite(final_lag_seconds) & used_interpolated_lag & ...
    lag_method == "";
lag_method(oldReplaced) = "interpolated_legacy";
lag_reason(oldReplaced) = "legacy_audit_raw_lag_unavailable";
for im = 1:length(missions)
    use = mission == string(missions(im).name) & isfinite(final_lag_seconds);
    if ~any(use); continue; end
    ii = find(use);
    [~,order] = sort(time(ii));
    ii = ii(order);
    oldmedian = movmedian(final_lag_seconds(ii),13,'omitnan');
    missingmedian = ~isfinite(local_median_lag_seconds(ii));
    local_median_lag_seconds(ii(missingmedian)) = oldmedian(missingmedian);
    missingdeparture = ~isfinite(raw_lag_departure_seconds(ii)) & ...
        isfinite(raw_time_lag_seconds(ii));
    raw_lag_departure_seconds(ii(missingdeparture)) = abs( ...
        raw_time_lag_seconds(ii(missingdeparture)) - ...
        local_median_lag_seconds(ii(missingdeparture)));
end

final_status = process_status;
final_status(~id_parse_ok) = "unparseable_source_id";
final_status(final_status == "" & source_without_l4) = "source_without_l4";
final_status(final_status == "" & in_l4 & sig_mat_count == 0 & ...
    sbg_mat_count == 0) = "missing_sig_sbg";
final_status(final_status == "" & in_l4 & sig_mat_count == 0 & ...
    sbg_mat_count > 0) = "missing_sig";
final_status(final_status == "" & in_l4 & sig_mat_count > 0 & ...
    sbg_mat_count == 0) = "missing_sbg";
final_status(final_status == "" & in_l4) = "not_processed";
final_status(final_status == "") = "unassigned_source";

inventory = table(mission,platform,burstID,time,time_utc,id_parse_ok, ...
    in_l4,l4_count,l4_index,l4_path,l4_finite_bins,dat_count,dat_bytes, ...
    dat_paths,sig_mat_count,sig_mat_bytes,sig_mat_path,sig_mat_paths, ...
    sig_partial,sbg_mat_count,sbg_mat_bytes,sbg_mat_path,sbg_mat_paths, ...
    duplicate_l4,duplicate_sig,duplicate_sbg,source_without_l4, ...
    dat_without_sig_mat,process_status,final_status,action, ...
    profile_rms_change,profile_max_change,time_source,final_lag_seconds, ...
    raw_time_lag_seconds,local_median_lag_seconds, ...
    raw_lag_departure_seconds,lag_correlation,used_interpolated_lag, ...
    extrapolated_lag,lag_method,lag_reason,bad_ahrs_matrix_pings, ...
    mean_broadband_correlation,sig_load_status,sig_has_avg,sig_has_burst, ...
    sig_sample_count,sig_duration_minutes,sbg_load_status,sbg_has_data, ...
    sbg_euler_samples,sbg_imu_samples,sbg_duration_minutes);

%% Inspect the actual contents of failed or unmatched sources

inspect = inventory.final_status ~= "corrected" | ...
    inventory.duplicate_sig | inventory.duplicate_sbg | ...
    inventory.dat_without_sig_mat;
for irow = find(inspect)'
    if strlength(inventory.sig_mat_path(irow)) > 0
        [loadstatus,hasavg,hasburst,nsample,duration] = ...
            inspectSIG(inventory.sig_mat_path(irow));
        inventory.sig_load_status(irow) = loadstatus;
        inventory.sig_has_avg(irow) = hasavg;
        inventory.sig_has_burst(irow) = hasburst;
        inventory.sig_sample_count(irow) = nsample;
        inventory.sig_duration_minutes(irow) = duration;
    else
        inventory.sig_load_status(irow) = "missing";
    end
    if strlength(inventory.sbg_mat_path(irow)) > 0
        [loadstatus,hasdata,neuler,nimu,duration] = ...
            inspectSBG(inventory.sbg_mat_path(irow));
        inventory.sbg_load_status(irow) = loadstatus;
        inventory.sbg_has_data(irow) = hasdata;
        inventory.sbg_euler_samples(irow) = neuler;
        inventory.sbg_imu_samples(irow) = nimu;
        inventory.sbg_duration_minutes(irow) = duration;
    else
        inventory.sbg_load_status(irow) = "missing";
    end
end

[~,order] = sortrows(table(inventory.mission,inventory.time, ...
    inventory.platform,inventory.burstID),[1 2 3 4]);
inventory = inventory(order,:);

inventory_issue = inventory.final_status ~= "corrected" | ...
    inventory.duplicate_l4 | inventory.duplicate_sig | ...
    inventory.duplicate_sbg | inventory.source_without_l4 | ...
    inventory.dat_without_sig_mat;
failures = inventory(inventory_issue,:);

summary = groupsummary(inventory,{'mission','final_status'});
summary.Properties.VariableNames{'GroupCount'} = 'count';
summary.Percent = NaN(height(summary),1);
summarymissions = unique(summary.mission);
for im = 1:length(summarymissions)
    use = summary.mission == summarymissions(im);
    summary.Percent(use) = 100*summary.count(use)/sum(summary.count(use));
end

lagsummary = makeLagSummary(inventory);

writetable(inventory,fullfile(reviewdir,'Willapa_HPR_source_inventory.csv'))
writetable(summary,fullfile(reviewdir,'Willapa_HPR_status_summary.csv'))
writetable(failures,fullfile(reviewdir,'Willapa_HPR_failures.csv'))
writetable(lagsummary,fullfile(reviewdir,'Willapa_HPR_gyro_lag_summary.csv'))
saveStatusPlot(inventory,missions,reviewdir)
saveLagPlot(inventory,missions,reviewdir)

disp(summary)
disp(lagsummary)
end

function entry = getEntry(entries,key,mission,platform,burstID,idparseok)
if isKey(entries,key)
    entry = entries(key);
    return
end
entry.mission = string(mission);
entry.platform = string(platform);
entry.burstID = string(burstID);
entry.idparseok = logical(idparseok);
entry.l4indices = [];
entry.l4times = [];
entry.l4path = "";
entry.l4finitebins = [];
entry.datpaths = strings(0,1);
entry.datbytes = [];
entry.sigpaths = strings(0,1);
entry.sigbytes = [];
entry.sbgpaths = strings(0,1);
entry.sbgbytes = [];
end

function [platform,burstID,ok] = parseSourceName(name,sensor)
% Platform number and burst ID from a raw file name, e.g.
% SWIFT25_SBG_21Jun2025_14_03.dat -> "25", "21Jun2025_14_03":
%   SWIFT(\d+)_                     token 1: the SWIFT number
%   <sensor>_                       the sensor tag, SIG or SBG ('ignorecase'
%                                   also accepts sig/sbg)
%   (\d{2}[A-Za-z]{3}\d{4}_\d{2}_\d{2})  token 2: the burst ID, date
%                                   ddMmmyyyy, hour and 10-minute slot
pattern = ['SWIFT(\d+)_' sensor '_(\d{2}[A-Za-z]{3}\d{4}_\d{2}_\d{2})'];
token = regexp(name,pattern,'tokens','once','ignorecase');
ok = ~isempty(token);
if ok
    platform = string(token{1});
    burstID = string(token{2});
else
    platform = "";
    burstID = string(name);
end
end

function n = finiteProfileBins(swift)
n = 0;
if ~isfield(swift,'signature') || isempty(swift.signature) || ...
        ~isfield(swift.signature,'profile') || isempty(swift.signature.profile)
    return
end
p = swift.signature.profile;
if isfield(p,'east') && isfield(p,'north')
    n = sum(isfinite(p.east(:)) & isfinite(p.north(:)));
end
end

function mission = assignMission(entry,missionmeta)
if strlength(entry.mission) > 0
    mission = entry.mission;
    return
end
allpaths = [entry.datpaths; entry.sigpaths; entry.sbgpaths];
for im = 1:length(missionmeta)
    missionpath = string(filesep) + missionmeta(im).name + string(filesep);
    if any(contains(allpaths,missionpath))
        mission = missionmeta(im).name;
        return
    end
end
t = burstNameToDatenum(entry.burstID);
sameplatform = string({missionmeta.platform}) == entry.platform;
candidate = find(sameplatform & isfinite([missionmeta.tmin]) & ...
    isfinite([missionmeta.tmax]));
if isempty(candidate) || ~isfinite(t)
    mission = "UNASSIGNED";
    return
end
distance = NaN(length(candidate),1);
for ic = 1:length(candidate)
    im = candidate(ic);
    if t < missionmeta(im).tmin
        distance(ic) = missionmeta(im).tmin-t;
    elseif t > missionmeta(im).tmax
        distance(ic) = t-missionmeta(im).tmax;
    else
        distance(ic) = 0;
    end
end
[~,imin] = min(distance);
mission = missionmeta(candidate(imin)).name;
end

function value = auditString(audit,row,name)
value = "";
if ismember(name,audit.Properties.VariableNames)
    value = string(audit.(name)(row));
    if ismissing(value); value = ""; end
end
end

function value = auditNumber(audit,row,name)
value = NaN;
if ismember(name,audit.Properties.VariableNames)
    raw = audit.(name)(row);
    if isnumeric(raw) || islogical(raw)
        value = double(raw);
    else
        value = str2double(string(raw));
    end
end
end

function value = auditLogical(audit,row,name)
value = false;
if ~ismember(name,audit.Properties.VariableNames); return; end
raw = audit.(name)(row);
if islogical(raw) || isnumeric(raw)
    value = logical(raw);
else
    value = ismember(lower(string(raw)),["true" "1"]);
end
end

function [status,hasavg,hasburst,nsample,duration] = inspectSIG(path)
status = "load_error";
hasavg = false;
hasburst = false;
nsample = NaN;
duration = NaN;
try
    variables = string({whos('-file',char(path)).name});
    hasavg = any(variables == "avg");
    hasburst = any(variables == "burst");
    if ~hasavg || ~hasburst
        status = "missing_required_variable";
        return
    end
    data = load(char(path),'avg','burst');
    if isempty(data.avg) || isempty(data.burst)
        status = "empty";
        return
    end
    if isfield(data.burst,'time')
        btime = data.burst.time(:);
        nsample = length(btime);
        if ~isempty(btime)
            duration = (max(btime,[],'omitnan')-min(btime,[],'omitnan'))*1440;
        end
    end
    status = "loaded";
catch err
    status = "load_error:" + string(err.identifier);
end
end

function [status,hasdata,neuler,nimu,duration] = inspectSBG(path)
status = "load_error";
hasdata = false;
neuler = NaN;
nimu = NaN;
duration = NaN;
try
    variables = string({whos('-file',char(path)).name});
    hasdata = any(variables == "sbgData");
    if ~hasdata
        status = "missing_required_variable";
        return
    end
    data = load(char(path),'sbgData');
    if isempty(data.sbgData)
        status = "empty";
        return
    end
    sbg = data.sbgData;
    if isfield(sbg,'EkfEuler') && isfield(sbg.EkfEuler,'time_stamp')
        neuler = length(sbg.EkfEuler.time_stamp);
    end
    if isfield(sbg,'ImuData') && isfield(sbg.ImuData,'time_stamp')
        itime = double(sbg.ImuData.time_stamp(:));
        nimu = length(itime);
        if ~isempty(itime)
            duration = (max(itime,[],'omitnan')-min(itime,[],'omitnan'))/1e6/60;
        end
    end
    status = "loaded";
catch err
    status = "load_error:" + string(err.identifier);
end
end

function summary = makeLagSummary(inventory)
missions = unique(inventory.mission,'stable');
rows = cell(0,13);
for im = 1:length(missions)
    use = inventory.mission == missions(im) & ...
        isfinite(inventory.final_lag_seconds);
    lag = inventory.final_lag_seconds(use);
    corr = inventory.lag_correlation(use);
    method = inventory.lag_method(use);
    if isempty(lag); continue; end
    q = prctile(lag,[25 75]);
    rows(end+1,:) = {missions(im),length(lag), ...
        sum(method == "direct"),sum(startsWith(method,"interpolated")), ...
        sum(method == "extrapolated"),median(lag,'omitnan'),q(1),q(2), ...
        min(lag),max(lag),median(corr,'omitnan'), ...
        sum(corr < 0.8),sum(inventory.raw_lag_departure_seconds(use) > 3)}; %#ok<AGROW>
end
summary = cell2table(rows,'VariableNames',{'mission','n_lags','n_direct', ...
    'n_interpolated','n_extrapolated','median_seconds','q25_seconds', ...
    'q75_seconds','min_seconds','max_seconds','median_correlation', ...
    'n_low_correlation','n_local_outlier'});
end

function saveStatusPlot(inventory,missions,reviewdir)
% One row per mission on a shared time axis; each burst is a 10-minute cell
% coloured by why it was or was not corrected (statusCategory), one fixed
% colour per category. Row labels give corrected bursts / L4 records.
[statusnames,colors] = statusCategories();
category = statusCategory(inventory.final_status);
slot = 10/(24*60);

fh = figure('Visible','off','Color','w','Position',[40 40 1500 520]);
ax = axes(fh);
hold(ax,'on')
nmission = length(missions);
labels = strings(nmission,1);
for im = 1:nmission
    use = inventory.mission == string(missions(im).name) & isfinite(inventory.time);
    t = inventory.time(use);
    status = category(use);
    inl4 = inventory.in_l4(use) == 1;
    labels(im) = sprintf('%s  %d/%d',missions(im).name, ...
        sum(inl4 & status == "corrected"),sum(inl4));
    for is = 1:numel(statusnames)
        start = t(status == statusnames(is))';
        if isempty(start); continue; end
        x = [start; start+slot; start+slot; start];
        y = repmat(im + [-0.4; -0.4; 0.4; 0.4],1,numel(start));
        patch(ax,x,y,colors(is,:),'EdgeColor','none')
    end
end

% Legend: one entry per status that occurs, with its count
count = arrayfun(@(name) sum(category == name),statusnames);
occurs = find(count > 0);
legendhandles = gobjects(size(occurs));
for k = 1:numel(occurs)
    is = occurs(k);
    legendhandles(k) = patch(ax,NaN,NaN,colors(is,:),'EdgeColor','none', ...
        'DisplayName',sprintf('%s (%d)',statusnames(is),count(is)));
end
legend(legendhandles,'Location','southoutside','NumColumns',numel(occurs))

times = inventory.time(isfinite(inventory.time));
xlim(ax,[floor(min(times)) ceil(max(times))])
xticks(ax,floor(min(times)):ceil(max(times)))
datetick(ax,'x','mm/dd','keeplimits','keepticks')
set(ax,'YDir','reverse','TickLabelInterpreter','none')
yticks(ax,1:nmission); yticklabels(ax,labels); ylim(ax,[0.5 nmission+0.5])
grid(ax,'on'); box(ax,'on')
title(ax,'Willapa HPR correction status per burst (corrected / L4 records)')
exportgraphics(fh,fullfile(reviewdir,'Willapa_HPR_status_timeline.png'), ...
    'Resolution',150)
close(fh)
end

function [names,colors] = statusCategories()
% Plot categories, in legend order, and their colours.
names = ["corrected","no L4","no SIG","no SBG","short SIG","short SBG", ...
    "weak correlation","other"];
colors = [0.20 0.60 0.30; 0.80 0.80 0.80; 0.95 0.60 0.10; 0.55 0.25 0.75; ...
    0.95 0.45 0.70; 0.70 0.10 0.10; 0 0 0; 0.45 0.30 0.15];
end

function category = statusCategory(status)
% Why a burst was or was not corrected, from its final status. no L4: no L4
% record (source_without_l4) or no usable L4 profile (invalid_l4_profile).
% no SIG / no SBG: the file is missing, empty or unreadable; no SBG also
% covers no SBG data during the Signature burst (no_time_overlap; nearly
% all of these have no SBG file at all). weak correlation: the gyro-lag
% correlation was too weak to trust the relative SBG time. Anything else
% (e.g. no_mag_anchor, profile_failed) is other.
names = ["corrected","source_without_l4","invalid_l4_profile", ...
    "missing_sig","missing_sig_sbg","empty_sig","missing_sbg","empty_sbg", ...
    "malformed_sbg","no_time_overlap","short_sig","short_sbg", ...
    "relative_time_weak_lag"];
labels = ["corrected","no L4","no L4","no SIG","no SIG","no SIG","no SBG", ...
    "no SBG","no SBG","no SBG","short SIG","short SBG","weak correlation"];
category = repmat("other",size(status));
for k = 1:numel(names)
    category(status == names(k)) = labels(k);
end
end

function saveLagPlot(inventory,missions,reviewdir)
fh = figure('Visible','off','Color','w','Position',[40 40 1500 1100]);
tiledlayout(length(missions),1,'TileSpacing','compact','Padding','compact')
legendhandles = gobjects(0);
for im = 1:length(missions)
    nexttile
    use = inventory.mission == string(missions(im).name) & ...
        isfinite(inventory.time) & isfinite(inventory.final_lag_seconds);
    t = inventory.time(use);
    lag = inventory.final_lag_seconds(use);
    corr = inventory.lag_correlation(use);
    method = inventory.lag_method(use);
    localmedian = inventory.local_median_lag_seconds(use);
    [t,order] = sort(t);
    lag = lag(order); corr = corr(order); method = method(order);
    localmedian = localmedian(order);
    yyaxis left
    hold on
    hmedian = plot(t,localmedian,'-k','LineWidth',0.8, ...
        'DisplayName','Local median');
    hdirect = plot(t(method == "direct"),lag(method == "direct"),'.', ...
        'Color',[0 0.45 0.74],'DisplayName','Direct lag');
    isinterpolated = startsWith(method,"interpolated");
    hinterp = plot(t(isinterpolated),lag(isinterpolated),'o', ...
        'Color',[0.85 0.33 0.1],'MarkerSize',3, ...
        'DisplayName','Interpolated lag');
    hextrap = plot(t(method == "extrapolated"), ...
        lag(method == "extrapolated"),'x', ...
        'Color',[0.64 0.08 0.18],'MarkerSize',4, ...
        'DisplayName','Extrapolated lag');
    ylabel('lag (s)')
    yyaxis right
    hcorr = plot(t,corr,'.','Color',[0.45 0.45 0.45], ...
        'MarkerSize',3,'DisplayName','Gyro correlation');
    hthreshold = yline(0.8,':','Color',[0.5 0.5 0.5], ...
        'DisplayName','Correlation threshold');
    ylim([-0.05 1.05]); ylabel('correlation')
    datetick('x','mm/dd','keeplimits'); grid on
    title(missions(im).name,'Interpreter','none')
    if isempty(legendhandles)
        legendhandles = [hmedian hdirect hinterp hextrap hcorr hthreshold];
    end
end
lg = legend(legendhandles,'Location','southoutside','NumColumns',3);
lg.Layout.Tile = 'south';
sgtitle('Willapa SIG/SBG gyro lag and match quality')
exportgraphics(fh,fullfile(reviewdir,'Willapa_HPR_gyro_lag.png'), ...
    'Resolution',150)
close(fh)
end
