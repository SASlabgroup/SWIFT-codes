function [SWIFT,sinfo] = qcSWIFT(missiondir,minsalinity,minwave,maxdrift)

% Based on SWIFT_QC by J. Thomson

% Basic QC; goal is to remove bursts when SWIFT is out of water.

if ispc 
    slash = '\';
else
    slash = '/';
end

%% Load existing L2 product, or L1 product if does not exist. If no L1 product, return to function

l1file = dir([missiondir slash '*SWIFT*L1.mat']);

if ~isempty(l1file) 
    load([l1file.folder slash l1file.name],'SWIFT','sinfo');
else
    warning(['No L1 product found for ' missiondir(end-16:end) '. Skipping...'])
    return
end


%% QC

    if isfield(SWIFT,'salinity')
        badsal = [SWIFT.salinity] < minsalinity;  % this will break if multiple salinity values (salty SWIFTs)
        SWIFT(badsal) = [];
    end


    if isfield(SWIFT,'sigwaveheight')
        badwave = [SWIFT.sigwaveheight] < minwave; 
        SWIFT(badwave) = [];
    end

    if isfield(SWIFT,'driftspd')
        baddrift = [SWIFT.driftspd] > maxdrift; 
        SWIFT(baddrift) = [];
    end

%% Log QC and flags, then save new L2 file or overwrite existing one

if isfield(sinfo,'postproc')
ip = length(sinfo.postproc)+1; 
else
    sinfo.postproc = struct;
    ip = 1;
end
sinfo.postproc(ip).type = 'Y81';
sinfo.postproc(ip).usr = getenv('username');
sinfo.postproc(ip).time = string(datetime('now'));
sinfo.postproc(ip).flags = [];
sinfo.postproc(ip).params = [];

save([sfile.folder slash sfile.name(1:end-6) 'L2.mat'],'SWIFT','sinfo')



end