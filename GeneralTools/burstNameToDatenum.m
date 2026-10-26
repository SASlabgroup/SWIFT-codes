function time = burstNameToDatenum(name)
%BURSTNAMETODATENUM Nominal start time of a SWIFT burst file from its name.
%
%   time = burstNameToDatenum(name)
%
%   name  a burst file name (char or string) containing _ddMmmyyyy_HH_SS (e.g.
%         SWIFT25_SBG_21Jun2025_14_03.mat): the date, the hour, and the
%         10-minute slot within the hour, SS = 01..06.
%   time  datenum of the slot start (14:20 in the example), or NaN if the
%         name has no slot.
%
% mleclair (using claude), Oct 2026

% The date, hour and slot, each captured as a token:
%   (\d{2}[A-Za-z]{3}\d{4})  date: 2 digits, a 3-letter month, 4 digits
%                            (21Jun2025)
%   _(\d{2})                 hour: 2 digits after an underscore (14)
%   _(\d{2})                 slot: 2 digits after an underscore (03)
% 'once' returns the first match as a cell of the three tokens (char input,
% hence char(name)).
token = regexp(char(name),'(\d{2}[A-Za-z]{3}\d{4})_(\d{2})_(\d{2})','tokens','once');
time = NaN;
if isempty(token); return; end
time = datenum(token{1},'ddmmmyyyy') + str2double(token{2})/24 + ...
    (str2double(token{3})-1)/(6*24);
end
