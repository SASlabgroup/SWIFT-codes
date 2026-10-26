function records = loadSBGmagRecords(folder,nsample)
%LOADSBGMAGRECORDS Magnetometer samples of every SBG record under a folder.
%
%   records = loadSBGmagRecords(folder,nsample)
%
%   folder   a SWIFT mission folder (searched recursively for *_SBG_*.mat).
%   nsample  samples kept per record, evenly spaced (default 100).
%
%   records.key   nominal slot time of each record (burstNameToDatenum), sorted;
%   records.m, records.d   cell arrays of body-frame field samples and down
%                 vectors (readSBGmag);
%   records.yaw   record-mean EKF yaw, deg;
%   records.file  source file.
%   Uses a parallel pool if one is open.
%
% mleclair (using claude), Oct 2026

if nargin < 2; nsample = 100; end
files = dir(fullfile(folder,'**','*_SBG_*.mat'));
files = files(~startsWith({files.name},'._'));
% Largest file if a slot has a partial and a full copy
[~,ibig] = sort([files.bytes],'descend');
files = files(ibig);
[~,iu] = unique({files.name},'stable');
files = files(iu);

nfile = numel(files);
key = NaN(nfile,1); m = cell(nfile,1); d = cell(nfile,1); yaw = NaN(nfile,1);
parfor ifile = 1:nfile
    loaded = load(fullfile(files(ifile).folder,files(ifile).name),'sbgData');
    if ~isfield(loaded,'sbgData'); continue; end
    [mm,dd,yy] = readSBGmag(loaded.sbgData);
    if size(mm,1) < 10; continue; end
    keep = round(linspace(1,size(mm,1),min(nsample,size(mm,1))));
    m{ifile} = mm(keep,:);
    d{ifile} = dd(keep,:);
    yaw(ifile) = meandir(yy(keep));
    key(ifile) = burstNameToDatenum(files(ifile).name);
end
used = isfinite(key);
[records.key,isort] = sort(key(used));
m = m(used); d = d(used); yaw = yaw(used);
files = string(fullfile({files.folder},{files.name}))';
files = files(used);
records.m = m(isort);
records.d = d(isort);
records.yaw = yaw(isort);
records.file = files(isort);
end
