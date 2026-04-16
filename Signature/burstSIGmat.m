function burstSIGmat(missiondir, outdir, swiftname, burstMin)
% BURSTSIGMAT Group reformatted Signature mat files into fixed-length bursts
%   aligned within the hour. Data is treated as sequential and bursts are
%   allowed to span multiple reformat files.
%
%   burstSIGmat(missiondir)
%   burstSIGmat(missiondir, outdir)
%   burstSIGmat(missiondir, outdir, swiftname)
%   burstSIGmat(missiondir, outdir, swiftname, burstMin)
%
%   burstMin: burst length in minutes (default 12). Best if it divides 60
%     evenly so bursts tile the hour cleanly (e.g. 5, 6, 10, 12, 15, 20, 30, 60).
%
%   Output files: {swiftname}_SIG_{ddMMMyyyy}_{HH}_{BB}.mat
%   where BB is the burst index in the hour (01 = first burst of the hour).
%
% M.LeClair April 2026

if nargin<2 || isempty(outdir),   outdir = fullfile(missiondir,'bursts'); end
if nargin<4 || isempty(burstMin), burstMin = 12; end
if ~exist(outdir,'dir'), mkdir(outdir); end

files = dir(fullfile(missiondir,'*_reformat.mat'));
if isempty(files), disp('No *_reformat.mat files found.'); return; end

% Natural sort by (runIdx, chunkIdx). Handles both
%   SWIFTNN_RRRR.ad2cp.NNNNN_CC_reformat.mat
%   Data.RRR.NNNNN.ad2cp.NNNNN_CC_reformat.mat
keys = nan(length(files),2);
for i=1:length(files)
    tok = regexp(files(i).name,'(\d+)\.ad2cp\.\d+_(\d+)_reformat\.mat$','tokens','once');
    if ~isempty(tok)
        keys(i,:) = [str2double(tok{1}) str2double(tok{2})];
    end
end
if any(isnan(keys(:)))
    warning('burstSIGmat:unparsedNames', ...
        '%d file(s) did not match expected naming pattern; falling back to name sort.', ...
        nnz(any(isnan(keys),2)));
    [~,ord] = sort({files.name});
else
    [~,ord] = sortrows(keys);
end
files = files(ord);

if nargin<3 || isempty(swiftname)
    tok = regexp(files(1).name,'^(SWIFT\d+)','tokens','once');
    if ~isempty(tok)
        swiftname = tok{1};
    else
        [~,swiftname] = fileparts(missiondir);
        if isempty(swiftname), swiftname = 'SIG'; end
    end
end

burstDur = burstMin/1440; % days
avgBuf = []; burstBuf = []; echoMeta = [];
curStart = [];

for i = 1:length(files)
    fprintf('Loading %s\n', files(i).name);
    S = load(fullfile(files(i).folder, files(i).name));
    if isfield(S,'avg')   && ~isempty(S.avg),   avgBuf   = catStruct(avgBuf,   S.avg);   end
    if isfield(S,'burst') && ~isempty(S.burst), burstBuf = catStruct(burstBuf, S.burst); end
    if isfield(S,'echo'),  echoMeta = S.echo; end

    if isempty(curStart)
        t0 = earliest(avgBuf, burstBuf);
        if isempty(t0), continue; end
        dv = datevec(t0);
        dv(5) = floor(dv(5)/burstMin)*burstMin; dv(6) = 0;
        curStart = datenum(dv);
    end

    isLast = (i == length(files));

    while true
        burstEnd = curStart + burstDur;
        tmax = latest(avgBuf, burstBuf);
        if isempty(tmax), break; end
        if ~isLast && tmax < burstEnd, break; end
        if tmax < curStart
            curStart = burstEnd; continue; % gap: skip empty burst windows
        end
        avgOut   = sliceStruct(avgBuf,   curStart, burstEnd);
        burstOut = sliceStruct(burstBuf, curStart, burstEnd);
        if ~isempty(avgOut) || ~isempty(burstOut)
            saveBurst(outdir, swiftname, curStart, avgOut, burstOut, echoMeta, burstMin);
        end
        avgBuf   = dropBefore(avgBuf,   burstEnd);
        burstBuf = dropBefore(burstBuf, burstEnd);
        curStart = burstEnd;
        if isLast && isempty(latest(avgBuf, burstBuf)), break; end
    end
end
end

% ----- helpers -----

function A = catStruct(A, B)
if isempty(A), A = B; return; end
fn = fieldnames(B);
for k = 1:numel(fn)
    f = fn{k};
    if strcmp(f,'CellSize') || strcmp(f,'Blanking')
        A.(f) = B.(f);
    else
        if ~isfield(A,f), A.(f) = B.(f); else, A.(f) = cat(1, A.(f), B.(f)); end
    end
end
end

function t = earliest(a, b)
t = [];
if ~isempty(a) && ~isempty(a.time), t(end+1,1) = a.time(1); end
if ~isempty(b) && ~isempty(b.time), t(end+1,1) = b.time(1); end
if ~isempty(t), t = min(t); end
end

function t = latest(a, b)
t = [];
if ~isempty(a) && ~isempty(a.time), t(end+1,1) = a.time(end); end
if ~isempty(b) && ~isempty(b.time), t(end+1,1) = b.time(end); end
if ~isempty(t), t = max(t); end
end

function S = sliceStruct(S, tstart, tend)
if isempty(S), return; end
idx = S.time >= tstart & S.time < tend;
if ~any(idx), S = []; return; end
fn = fieldnames(S);
for k = 1:numel(fn)
    f = fn{k};
    if strcmp(f,'CellSize') || strcmp(f,'Blanking'), continue; end
    v = S.(f);
    if size(v,1) ~= numel(idx), continue; end
    switch ndims(v)
        case 2, S.(f) = v(idx,:);
        case 3, S.(f) = v(idx,:,:);
        case 4, S.(f) = v(idx,:,:,:);
    end
end
end

function S = dropBefore(S, tend)
if isempty(S), return; end
keep = S.time >= tend;
if all(keep), return; end
if ~any(keep), S = []; return; end
fn = fieldnames(S);
for k = 1:numel(fn)
    f = fn{k};
    if strcmp(f,'CellSize') || strcmp(f,'Blanking'), continue; end
    v = S.(f);
    if size(v,1) ~= numel(keep), continue; end
    switch ndims(v)
        case 2, S.(f) = v(keep,:);
        case 3, S.(f) = v(keep,:,:);
        case 4, S.(f) = v(keep,:,:,:);
    end
end
end

function saveBurst(outdir, swiftname, tstart, avg, burst, echo, burstMin)
dv = datevec(tstart);
dstr = datestr(tstart,'ddmmmyyyy');
hh = sprintf('%02d', dv(4));
bn = sprintf('%02d', floor(dv(5)/burstMin)+1);
fname = sprintf('%s_SIG_%s_%s_%s.mat', swiftname, dstr, hh, bn);
daydir = fullfile(outdir, datestr(tstart,'yyyymmdd'));
if ~exist(daydir,'dir'), mkdir(daydir); end
out = fullfile(daydir, fname);
fprintf('  -> %s\n', fname);
saveVars = struct();
if ~isempty(avg),   saveVars.avg = avg; end
if ~isempty(burst), saveVars.burst = burst; end
if ~isempty(echo),  saveVars.echo = echo; end
save(out, '-struct', 'saveVars');
end
