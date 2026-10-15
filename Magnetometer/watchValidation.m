function [watchtime,watch,recordwatch,lobeA] = watchValidation(folder,swiftfile,key)
% Drag-corrected watch-circle bearing (validation only) and lobe of each
% record. Without a SWIFT file, all records count as lobe A.
watchtime = NaN; watch = NaN;
recordwatch = NaN(size(key)); lobeA = true(size(key));
if swiftfile == ""
    l4 = dir(fullfile(folder,'*_L4.mat'));
    if isempty(l4); return; end
    swiftfile = fullfile(l4(1).folder,l4(1).name);
end
loaded = load(swiftfile,'SWIFT');
[watchtime,watch,~,axisbearing] = watchBearingDrag(loaded.SWIFT);
[~,recordwatch] = watchBearingDrag(loaded.SWIFT,At=key);
lobeA = cosd(recordwatch-axisbearing) > 0;
end
