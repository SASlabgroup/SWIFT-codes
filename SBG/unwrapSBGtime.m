function [sbg,info] = unwrapSBGtime(sbg,reference)
%UNWRAPSBGTIME Put SBG time_stamp on one continuous clock.
%
%   [sbg,info] = unwrapSBGtime(sbg)
%   [sbg,info] = unwrapSBGtime(sbg,true)
%
%   time_stamp, in every SBG log (ImuData, GpsPos, UtcTime, ...), is a
%   uint32 microsecond counter since SBG power-up that wraps every 2^32 us
%   (~71.6 min). An SBG powered per burst starts near 0 and does not wrap
%   within a burst. One left running between bursts starts anywhere and can
%   wrap mid-burst: sorting the stamps (unique) then reorders the record,
%   and a per-burst UTC anchor (UTC - stamp) splits by one wrap.
%
%   Each log's stamps are unwrapped from the steps between valid stamps
%   taken modulo 2^32, so a wrap is an ordinary step however much data is
%   missing around it, and a corrupt stamp offsets only itself. Zero stamps
%   are invalid: they are skipped and left at 0.
%
%   reference = true also shifts every log so the first valid IMU stamp is
%   0 (each log onto the IMU's wrap cycle), for code that assumes the burst
%   starts at time 0, e.g. the gyro cross-correlation with the Signature.
%   Zero stamps stay 0, so callers' zero-stamp masks still work; a valid
%   stamp shifted to exactly 0 (the first IMU stamp) is then masked as well.
%
%   info.nwrap  number of wraps found, summed over the logs
%   info.t0     first valid IMU stamp before referencing [us] (NaN if none)
%
% Changelog:
% M. LeClair w/ claude, Nov 2026: first version, from L3_highresSWIFT

if nargin < 2 || isempty(reference); reference = false; end

wrap = 2^32; % counter range [us]
info.nwrap = 0;
info.t0 = NaN;

% First valid IMU stamp = common time origin
t0 = 0;
if isfield(sbg,'ImuData') && isfield(sbg.ImuData,'time_stamp')
    i0 = find(sbg.ImuData.time_stamp ~= 0,1);
    if ~isempty(i0)
        t0 = double(sbg.ImuData.time_stamp(i0));
        info.t0 = t0;
    end
end

fields = fieldnames(sbg);
for idf = 1:length(fields)
    log = sbg.(fields{idf});
    if ~isstruct(log) || ~isfield(log,'time_stamp'); continue; end
    ts = double(log.time_stamp(:));
    nz = ts ~= 0; % valid stamps
    if ~any(nz); continue; end
    tv = ts(nz);
    step = mod(diff(tv) + wrap/2, wrap) - wrap/2; % a wrap is an ordinary step modulo 2^32
    tc = tv(1) + [0; cumsum(step)]; % continuous (unwrapped) time
    % Anchor on the first stamp whose dt to the next is plausible, so a corrupt first stamp (bad 
    % data which was present before doing the CRC check when reading the binary) does not offset the whole log
    plausible = abs(step) <= max(1e6, 10*median(abs(step)));
    ia = find(plausible,1);
    if ~isempty(ia); tc = tc + (tv(ia) - tc(ia)); end
    info.nwrap = info.nwrap + nnz(diff(tv) < -wrap/2 & plausible);
    ts(nz) = tc;
    if reference
        i1 = find(nz,1);
        ts(nz) = ts(nz) - wrap*round((ts(i1)-t0)/wrap) - t0; % same wrap cycle as the IMU, origin at first IMU stamp; zeros stay 0
    end
    sbg.(fields{idf}).time_stamp = reshape(ts,size(log.time_stamp));
end

end
