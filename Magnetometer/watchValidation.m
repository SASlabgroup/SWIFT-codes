function [watchtime,watch,recordwatch,lobeA] = watchValidation(folder,swiftfile,time)
% Drag-corrected watch-circle bearing (validation only) and lobe of each
% record. Without a SWIFT file, all records count as lobe A.
%
% M. LeClair w/ claude, Oct 2026
watchtime = NaN; watch = NaN;
recordwatch = NaN(size(time)); lobeA = true(size(time));
if swiftfile == ""
    l4 = dir(fullfile(folder,'*_L4.mat'));
    if isempty(l4); return; end
    swiftfile = fullfile(l4(1).folder,l4(1).name);
end
loaded = load(swiftfile,'SWIFT');
[watchtime,watch,~,axisbearing] = watchBearingDrag(loaded.SWIFT);
[~,recordwatch] = watchBearingDrag(loaded.SWIFT,At=time);
lobeA = cosd(recordwatch-axisbearing) > 0;
end
