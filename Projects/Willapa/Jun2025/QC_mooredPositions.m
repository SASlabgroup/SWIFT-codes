function [SWIFT,qc] = QC_mooredPositions(SWIFT,options)
%QC_MOOREDPOSITIONS Remove GPS spikes and off-site records of a moored SWIFT.
%
% [SWIFT,qc] = QC_mooredPositions(SWIFT)
%
% Distances are about the deployment median position.
%
%   1. Records at the start or end of the deployment that are more than
%      EndDistance from the mooring are transits or recovery, out of the
%      water but not caught by the ACS flag; they are dropped. Records in
%      between are kept even when far off, e.g. on a dragged anchor.
%   2. One or two consecutive fixes more than SpikeDistance from the finite
%      fixes on either side, which are themselves within SpikeDistance of
%      each other, are a GPS spike; their positions are set to NaN and the
%      records kept.
%
% qc.dropped and qc.spike flag the input records.

arguments
    SWIFT struct
    options.EndDistance (1,1) double {mustBePositive} = 500
    options.SpikeDistance (1,1) double {mustBePositive} = 100
end

lat = [SWIFT.lat]';
lon = [SWIFT.lon]';
lat0 = median(lat,'omitnan');
lon0 = median(lon,'omitnan');
x = (lon-lon0).*cosd(lat0)*111320;
y = (lat-lat0)*110540;

% Off-site runs at either end
far = hypot(x,y) > options.EndDistance;
keep = false(size(far));
keep(find(~far,1):find(~far,1,'last')) = true;

% Isolated spikes among the kept records
spike = false(size(far));
fixes = find(keep & isfinite(x));
for k = 2:numel(fixes)-1
    for width = 1:min(2,numel(fixes)-k)
        run = fixes(k:k+width-1);
        if isSpike(x,y,run,fixes(k-1),fixes(k+width),options.SpikeDistance)
            spike(run) = true;
            break
        end
    end
end

[SWIFT(spike).lat] = deal(NaN);
[SWIFT(spike).lon] = deal(NaN);
SWIFT = SWIFT(keep);

qc.dropped = ~keep;
qc.spike = spike;
qc.params = struct('EndDistance',options.EndDistance, ...
    'SpikeDistance',options.SpikeDistance);
end

function tf = isSpike(x,y,run,before,after,distance)
% Every fix in run is far from both neighbours, which agree with each other.
d = @(a,b) hypot(x(a)-x(b),y(a)-y(b));
tf = all(d(run,before) > distance & d(run,after) > distance) && ...
    d(before,after) <= distance;
end
