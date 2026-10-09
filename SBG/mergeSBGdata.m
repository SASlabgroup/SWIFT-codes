function [out,info] = mergeSBGdata(records,referencetime)
%MERGESBGDATA Put one or more SBG records on their native reconstructed UTC.
%
% UtcTime, ImuData, and EkfEuler share the SBG hardware timestamp. Valid
% UTC packets therefore provide a clock anchor even when other packets in a
% burst contain stale calendar fields. Each input record is anchored before
% samples are combined because the hardware timestamp resets between files.

if ~iscell(records); records = {records}; end
if nargin < 2 || isempty(referencetime); referencetime = now; end

imutime = []; imugyro = zeros(0,3);
ekftime = []; ekfangle = zeros(0,3);
used = false(length(records),1);
anchorresidual = NaN(length(records),1);

for ir = 1:length(records)
    record = records{ir};
    if ~validRecord(record); continue; end
    [anchor,residual] = utcAnchor(record.UtcTime,referencetime);
    if ~isfinite(anchor); continue; end

    [stamp,iu] = unique(double(record.ImuData.time_stamp(:))/1e6);
    thistime = anchor+stamp/86400;
    thisgyro = double([record.ImuData.gyro_x(:) ...
        record.ImuData.gyro_y(:) record.ImuData.gyro_z(:)]);
    thisgyro = thisgyro(iu,:);
    keep = isfinite(thistime) & abs(thistime-referencetime) < 2/24;
    imutime = [imutime; thistime(keep)];
    imugyro = [imugyro; thisgyro(keep,:)];

    [stamp,iu] = unique(double(record.EkfEuler.time_stamp(:))/1e6);
    thistime = anchor+stamp/86400;
    thisangle = double([record.EkfEuler.pitch(:) ...
        record.EkfEuler.roll(:) record.EkfEuler.yaw(:)]);
    thisangle = thisangle(iu,:);
    keep = isfinite(thistime) & abs(thistime-referencetime) < 2/24;
    ekftime = [ekftime; thistime(keep)];
    ekfangle = [ekfangle; thisangle(keep,:)];

    used(ir) = true;
    anchorresidual(ir) = residual;
end

[imutime,iu] = unique(imutime);
imugyro = imugyro(iu,:);
[ekftime,iu] = unique(ekftime);
ekfangle = ekfangle(iu,:);

out = struct;
out.ImuData.time = imutime;
out.ImuData.gyro_x = imugyro(:,1);
out.ImuData.gyro_y = imugyro(:,2);
out.ImuData.gyro_z = imugyro(:,3);
out.EkfEuler.time = ekftime;
out.EkfEuler.pitch = ekfangle(:,1);
out.EkfEuler.roll = ekfangle(:,2);
out.EkfEuler.yaw = ekfangle(:,3);

info.records = length(records);
info.recordsused = sum(used);
info.anchorresidualseconds = anchorresidual;
info.imusamples = length(imutime);
info.ekfsamples = length(ekftime);
end

function [anchor,residual] = utcAnchor(utc,referencetime)
year = double(utc.year(:));
month = double(utc.month(:));
day = double(utc.day(:));
hour = double(utc.hour(:));
minute = double(utc.min(:));
second = double(utc.sec(:));
nanosecond = double(utc.nanosec(:));
stamp = double(utc.time_stamp(:))/1e6;
valid = year >= 2000 & year <= 2100 & month >= 1 & month <= 12 & ...
    day >= 1 & day <= 31 & hour >= 0 & hour <= 23 & ...
    minute >= 0 & minute <= 59 & second >= 0 & second < 61 & ...
    isfinite(nanosecond) & isfinite(stamp);
calendar = NaN(size(year));
calendar(valid) = datenum([year(valid) month(valid) day(valid) ...
    hour(valid) minute(valid) second(valid)]) + ...
    nanosecond(valid)/1e9/86400;
valid = valid & abs(calendar-referencetime) < 1;
anchors = calendar(valid)-stamp(valid)/86400;
anchor = median(anchors,'omitnan');
residual = 86400*1.4826*median(abs(anchors-anchor),'omitnan');
end

function tf = validRecord(record)
groups.EkfEuler = {'time_stamp','pitch','roll','yaw'};
groups.UtcTime = {'time_stamp','year','month','day','hour','min','sec','nanosec'};
groups.ImuData = {'time_stamp','gyro_x','gyro_y','gyro_z'};
tf = true;
names = fieldnames(groups);
for ig = 1:length(names)
    group = names{ig};
    fields = groups.(group);
    if ~isfield(record,group); tf = false; return; end
    ntime = length(record.(group).time_stamp);
    for jf = 1:length(fields)
        if ~isfield(record.(group),fields{jf}) || ...
                length(record.(group).(fields{jf})) < ntime
            tf = false;
            return
        end
    end
end
end
