function records = loadSBGmagRecords(folder,nsample)
%LOADSBGMAGRECORDS Magnetometer samples of every SBG record under a folder.
%
%   records = loadSBGmagRecords(folder,nsample)
%
%   folder   a SWIFT mission folder (searched recursively for *_SBG_*.mat).
%   nsample  samples kept per record, evenly spaced (default 100).
%
%   records.time  nominal slot time of each record (burstNameToDatenum), sorted;
%   records.m_in_body, records.level_in_body
%                 cell arrays of field samples and down vectors in the SBG
%                 body frame (readSBGmag);
%   records.yaw   record-mean EKF yaw, deg;
%   records.file  source file.
%   Uses a parallel pool if one is open.
%
% M. LeClair w/ claude, Oct 2026

if nargin < 2; nsample = 100; end
files = dir(fullfile(folder,'**','*_SBG_*.mat'));
files = files(~startsWith({files.name},'._'));
% Largest file if a slot has a partial and a full copy
[~,ibig] = sort([files.bytes],'descend');
files = files(ibig);
[~,iu] = unique({files.name},'stable');
files = files(iu);

nfile = numel(files);
time = NaN(nfile,1); m_in_body = cell(nfile,1); level_in_body = cell(nfile,1); yaw = NaN(nfile,1);
parfor ifile = 1:nfile
    loaded = load(fullfile(files(ifile).folder,files(ifile).name),'sbgData');
    if ~isfield(loaded,'sbgData'); continue; end
    [m_in_sbg,down_in_sbg,ekfyaw] = readSBGmag(loaded.sbgData);
    if size(m_in_sbg,1) < 10; continue; end
    keep = round(linspace(1,size(m_in_sbg,1),min(nsample,size(m_in_sbg,1))));
    m_in_body{ifile} = m_in_sbg(keep,:);
    level_in_body{ifile} = down_in_sbg(keep,:);
    yaw(ifile) = meandir(ekfyaw(keep));
    time(ifile) = burstNameToDatenum(files(ifile).name);
end
used = isfinite(time);
[records.time,isort] = sort(time(used));
m_in_body = m_in_body(used); level_in_body = level_in_body(used); yaw = yaw(used);
files = string(fullfile({files.folder},{files.name}))';
files = files(used);
records.m_in_body = m_in_body(isort);
records.level_in_body = level_in_body(isort);
records.yaw = yaw(isort);
records.file = files(isort);
end
