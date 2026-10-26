function records = loadSIGmagRecords(folder,nsample)
%LOADSIGMAGRECORDS Magnetometer samples of every Signature burst under a folder.
%
%   records = loadSIGmagRecords(folder,nsample)
%
%   folder   a SWIFT mission folder (searched recursively for
%            *_SIG_ddMmmyyyy_HH_s.mat burst files).
%   nsample  samples kept per record, evenly spaced (default 100).
%
%   records.time  nominal slot time of each record (burstNameToDatenum), sorted;
%   records.m_in_body, records.level_in_body
%                 cell arrays of raw field samples and up vectors
%                 (accelerometer) in the Signature body frame (readSIGmag);
%   records.yaw   record-mean onboard heading, deg;
%   records.file  source file.
%   Uses a parallel pool if one is open.
%
% M. LeClair w/ claude, Oct 2026

if nargin < 2; nsample = 100; end
files = dir(fullfile(folder,'**','*_SIG_*.mat'));
% Burst files only, not the processed or echogram products. A burst name
% ends in _SIG_ddMmmyyyy_HH_SS.mat:
%   _SIG_                    the Signature sensor tag
%   \d{2}[A-Za-z]{3}\d{4}    date, e.g. 18Jun2025
%   _\d{2}_\d{2}             hour and 10-minute slot, e.g. _20_01
%   \.mat$                   the extension, at the very end ($), so mission
%                            products (<mission>_SIG.mat, _SIG_HPR.mat) and
%                            names with a suffix after the slot do not match
% 'once' gives [] for a non-matching name.
isburst = ~cellfun(@isempty,regexp({files.name}, ...
    '_SIG_\d{2}[A-Za-z]{3}\d{4}_\d{2}_\d{2}\.mat$','once'));
files = files(isburst & ~startsWith({files.name},'._'));
% Largest file if a slot has a partial and a full copy
[~,ibig] = sort([files.bytes],'descend');
files = files(ibig);
[~,iu] = unique({files.name},'stable');
files = files(iu);

nfile = numel(files);
time = NaN(nfile,1); m_in_body = cell(nfile,1); level_in_body = cell(nfile,1); yaw = NaN(nfile,1);
parfor ifile = 1:nfile
    loaded = load(fullfile(files(ifile).folder,files(ifile).name),'avg');
    if ~isfield(loaded,'avg'); continue; end
    [m_in_sig,up_in_sig,onboardheading] = readSIGmag(loaded.avg);
    if size(m_in_sig,1) < 10; continue; end
    keep = round(linspace(1,size(m_in_sig,1),min(nsample,size(m_in_sig,1))));
    m_in_body{ifile} = m_in_sig(keep,:);
    level_in_body{ifile} = up_in_sig(keep,:);
    yaw(ifile) = meandir(onboardheading(keep));
    time(ifile) = burstNameToDatenum(files(ifile).name);
end
valid = isfinite(time);
[records.time,isort] = sort(time(valid));
m_in_body = m_in_body(valid); level_in_body = level_in_body(valid); yaw = yaw(valid);
files = string(fullfile({files.folder},{files.name}))';
files = files(valid);
records.m_in_body = m_in_body(isort);
records.level_in_body = level_in_body(isort);
records.yaw = yaw(isort);
records.file = files(isort);
end
