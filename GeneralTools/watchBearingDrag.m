function [time,heading,anchor,axisbearing,dwells] = watchBearingDrag(SWIFT,options)
%WATCHBEARINGDRAG Estimate anchor-to-buoy bearing across anchor drags.
%
%   [time,heading,anchor,axisbearing,dwells] = watchBearingDrag(SWIFT,Name=Value)
%
%   Dwells (runs of fixes within DwellRadius of their median for at least
%   MinDwell; consecutive dwells within MergeDistance merged) mark where the
%   buoy held in a lobe of its watch circle. A dwell more than StepDistance
%   off the circle fitted to the fixes since the last drag starts a new
%   interval. Each interval gets a Kasa circle fit (fitCircleKasa) after
%   dropping fixes farther than MaxDistance from its median. The radius is
%   set by the mooring line, so intervals whose radius is more than a third
%   off the typical one (0.75-1.33 of the median) are badly fit and are
%   dropped.
%
%   time, heading  fixes with a bearing (datenum, deg from north, 0-360);
%                  with At, the requested times and the bearing of the
%                  nearest fix, NaN where it is more than MaxGap away (e.g.
%                  during a drag).
%   anchor         per interval: time (median), start, stop, east, north,
%                  radius, in metres about the deployment median position.
%   axisbearing    bearing of the lobe axis (deg, 0-180).
%   dwells         per dwell: start, stop, east, north, circle (interval;
%                  0 if unused).
%
%   Options (defaults): DwellRadius (15 m), MinDwell (1 h), MergeDistance
%   (20 m), StepDistance (8 m), MaxDistance (200 m), At ([]), MaxGap
%   (30 min).
%
% mleclair (using claude), Oct 2026
arguments
    SWIFT struct
    options.DwellRadius (1,1) double = 15
    options.MinDwell (1,1) double = 1/24
    options.MergeDistance (1,1) double = 20
    options.StepDistance (1,1) double = 8
    options.MaxDistance (1,1) double = 200
    options.At double = []
    options.MaxGap (1,1) double = 1/48
end

t = [SWIFT.time]';
lat = [SWIFT.lat]';
lon = [SWIFT.lon]';
valid = isfinite(t) & isfinite(lat) & isfinite(lon);
t = t(valid);
lat = lat(valid);
lon = lon(valid);
[t,order] = sort(t);
lat = lat(order);
lon = lon(order);

% Initialize outputs so empty or unusable records return consistently.
anchor = struct('time',[],'start',[],'stop',[],'east',[],'north',[],'radius',[]);
dwells = struct('start',[],'stop',[],'east',[],'north',[],'circle',[]);
time = zeros(0,1);
heading = zeros(0,1);
axisbearing = NaN;
if isempty(t)
    if ~isempty(options.At)
        time = options.At(:);
        heading = NaN(size(time));
    end
    return
end

lat0 = median(lat);
lon0 = median(lon);
east = (lon-lon0).*cosd(lat0)*111320;
north = (lat-lat0)*110540;

% Find stationary periods, merge interruptions, and split at anchor steps.
dwells = findDwells(t,east,north,options.DwellRadius,options.MinDwell);
dwells = mergeDwells(dwells,t,east,north,options.MergeDistance);
dwells.circle = circleSteps(dwells,t,east,north,options.StepDistance,options.MaxDistance);

% Fit each interval, then drop those whose radius is off the typical one.
intervals = setdiff(unique(dwells.circle)',0);
model = NaN(numel(intervals),3);
for k = 1:numel(intervals)
    dwell = find(dwells.circle == intervals(k));
    in = t >= dwells.start(dwell(1)) & t <= dwells.stop(dwell(end));
    model(k,:) = watchCircle([east(in) north(in)],options.MaxDistance);
end
ratio = model(:,3)/median(model(:,3),'omitnan');
good = ratio >= 0.75 & ratio <= 4/3;
dwells.circle(ismember(dwells.circle,intervals(~good))) = 0;

relative = zeros(0,2);
for k = find(good)'
    dwell = find(dwells.circle == intervals(k));
    start = dwells.start(dwell(1));
    stop = dwells.stop(dwell(end));
    center = model(k,1:2);
    fixes = t >= start & t <= stop & ...
        hypot(east-center(1),north-center(2)) <= options.MaxDistance;
    anchor.time(end+1,1) = median(t(fixes));
    anchor.start(end+1,1) = start;
    anchor.stop(end+1,1) = stop;
    anchor.east(end+1,1) = center(1);
    anchor.north(end+1,1) = center(2);
    anchor.radius(end+1,1) = model(k,3);
    time = [time; t(fixes)];
    heading = [heading; mod(atan2d(east(fixes)-center(1),north(fixes)-center(2)),360)];
    relative = [relative; east(fixes)-center(1) north(fixes)-center(2)];
end
% Number the dwells' intervals as the anchor rows.
[~,dwells.circle] = ismember(dwells.circle,intervals(good));

% The lobes lie along the principal axis of the anchor-relative positions.
if size(relative,1) >= 2
    [~,~,V] = svd(relative-mean(relative,1),0);
    axisbearing = mod(atan2d(V(1,1),V(2,1)),180);
end
if ~isempty(options.At)
    [time,heading] = bearingAt(time,heading,options.At(:),options.MaxGap);
end
end

function [newtime,bearing] = bearingAt(time,heading,newtime,maxgap)
% Sample the nearest bearing, leaving large temporal gaps undefined.
bearing = NaN(size(newtime));
if isempty(time); return; end
[time,keep] = unique(time,'stable');
heading = heading(keep);
if isscalar(time)
    nearest = ones(size(newtime));
else
    nearest = interp1(time,(1:numel(time))',newtime,'nearest','extrap');
end
bearing = heading(nearest);
bearing(abs(time(nearest)-newtime) > maxgap) = NaN;
end

function dwells = findDwells(t,east,north,radius,minduration)
% Collect runs that remain near their running median position.
dwells = struct('start',[],'stop',[],'east',[],'north',[]);
first = 1;
for k = 2:numel(t)+1
    if k <= numel(t)
        run = first:k-1;
        if hypot(east(k)-median(east(run)),north(k)-median(north(run))) <= radius
            continue
        end
    end
    run = first:k-1;
    if t(run(end))-t(run(1)) >= minduration
        dwells.start(end+1,1) = t(run(1));
        dwells.stop(end+1,1) = t(run(end));
        dwells.east(end+1,1) = median(east(run));
        dwells.north(end+1,1) = median(north(run));
    end
    first = k;
end
end

function dwells = mergeDwells(dwells,t,east,north,distance)
% Join nearby consecutive dwells and recompute their representative point.
k = 2;
while k <= numel(dwells.start)
    if hypot(dwells.east(k)-dwells.east(k-1),dwells.north(k)-dwells.north(k-1)) > distance
        k = k+1;
        continue
    end
    dwells.stop(k-1) = dwells.stop(k);
    in = t >= dwells.start(k-1) & t <= dwells.stop(k-1);
    dwells.east(k-1) = median(east(in));
    dwells.north(k-1) = median(north(in));
    for field = ["start","stop","east","north"]
        dwells.(field)(k) = [];
    end
end
end

function circle = circleSteps(dwells,t,east,north,stepdistance,maxdistance)
% Start a new interval when a dwell misses the current fitted circle.
n = numel(dwells.start);
circle = zeros(n,1);
if n < 2; return; end
circle(:) = 1;
first = 1;
current = 1;
for k = 3:n
    if k-first >= 2
        in = t >= dwells.start(first) & t <= dwells.stop(k-1);
        model = watchCircle([east(in) north(in)],maxdistance);
        residual = abs(hypot(dwells.east(k)-model(1),dwells.north(k)-model(2))-model(3));
        if isfinite(residual) && residual > stepdistance
            current = current+1;
            first = k;
        end
    end
    circle(k) = current;
end
for c = unique(circle)'
    if sum(circle == c) < 2
        circle(circle == c) = 0;
    end
end
end

function model = watchCircle(position,maxdistance)
% Reject gross position outliers before the non-robust algebraic fit.
origin = median(position,1);
position(vecnorm(position-origin,2,2) > maxdistance,:) = [];
model = fitCircleKasa(position(:,1),position(:,2));
end
