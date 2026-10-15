function records = loadSIGmagRecords(folder,nsample)
%LOADSIGMAGRECORDS Magnetometer samples of every Signature burst under a folder.
%
%   records = loadSIGmagRecords(folder,nsample)
%
%   folder   a SWIFT mission folder (searched recursively for
%            *_SIG_ddMmmyyyy_HH_s.mat burst files).
%   nsample  samples kept per record, evenly spaced (default 100).
%
%   records.key   nominal slot time of each record (burstNameToDatenum), sorted;
%   records.m, records.d   cell arrays of raw body-frame field samples and
%                 accelerometer directions (readSIGmag);
%   records.yaw   record-mean onboard heading, deg;
%   records.file  source file.
%   Uses a parallel pool if one is open.

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
time = NaN(nfile,1); m = cell(nfile,1); d = cell(nfile,1); yaw = NaN(nfile,1);
parfor ifile = 1:nfile
    loaded = load(fullfile(files(ifile).folder,files(ifile).name),'avg');
    if ~isfield(loaded,'avg'); continue; end
    [mm,dd,hh] = readSIGmag(loaded.avg);
    if size(mm,1) < 10; continue; end
    keep = round(linspace(1,size(mm,1),min(nsample,size(mm,1))));
    m{ifile} = mm(keep,:);
    d{ifile} = dd(keep,:);
    yaw(ifile) = meandir(hh(keep));
    time(ifile) = burstNameToDatenum(files(ifile).name);
end
valid = isfinite(time);
[records.key,isort] = sort(time(valid));
m = m(valid); d = d(valid); yaw = yaw(valid);
files = string(fullfile({files.folder},{files.name}))';
files = files(valid);
records.m = m(isort);
records.d = d(isort);
records.yaw = yaw(isort);
records.file = files(isort);
end
