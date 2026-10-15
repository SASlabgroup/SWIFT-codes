function [time,heading,anchor] = plotWatchBearingDrag(source,options)
%PLOTWATCHBEARINGDRAG Plot the drag-corrected watch-circle bearing of a moored SWIFT.
%
%   [time,heading,anchor] = plotWatchBearingDrag(source,Name=Value)
%
%   source  a SWIFT mission folder (its *_L4.mat is used) or a SWIFT .mat
%           file.
%
%   Name-value options:
%     OutputFile  figure file (default
%                 <folder>/debug/<mission>_watchbearing.png).
%
%   Runs watchBearingDrag and plots the dwells (runs of fixes held in one
%   lobe) colored by the watch circle they belong to, each circle's anchor
%   and radius, the positions against time with the circle spans shaded,
%   the distance from each circle's anchor (flat at the radius in the lobes
%   if the split is right), and the anchor-to-buoy bearing.

arguments
    source (1,1) string
    options.OutputFile string = ""
end

swiftfile = source;
if isfolder(source)
    l4 = dir(fullfile(source,'*_L4.mat'));
    swiftfile = fullfile(l4(1).folder,l4(1).name);
end
folder = fileparts(swiftfile);
[~,mission] = fileparts(folder);
loaded = load(swiftfile,'SWIFT');
[time,heading,anchor,~,dwells] = watchBearingDrag(loaded.SWIFT);
[x,y,t] = localPositions(loaded.SWIFT);
ncircle = numel(anchor.east);
colors = lines(max(ncircle,1));

% Circle of each fix with a bearing, and its distance from that anchor
circleof = NaN(size(t));
for k = 1:ncircle
    circleof(t >= anchor.start(k) & t <= anchor.stop(k)) = k;
end
hasbearing = ismember(t,time);
distance = NaN(size(t));
for k = 1:ncircle
    in = circleof == k & hasbearing;
    distance(in) = hypot(x(in)-anchor.east(k),y(in)-anchor.north(k));
end

fh = figure('Color','w','Position',[30 30 1700 1000]);
layout = tiledlayout(3,3,'TileSpacing','compact');
timelimits = [min(t) max(t)];

nexttile(1,[2 1]); hold on
plot(x(~hasbearing),y(~hasbearing),'x','Color',[0.7 0.7 0.7],'MarkerSize',4, ...
    'DisplayName','no bearing (drag, spike, transit)')
theta = linspace(0,2*pi,200);
for k = 1:ncircle
    in = circleof == k & hasbearing;
    plot(x(in),y(in),'.','Color',colors(k,:),'MarkerSize',5,'HandleVisibility','off')
    plot(anchor.east(k)+anchor.radius(k)*cos(theta), ...
        anchor.north(k)+anchor.radius(k)*sin(theta),'-','Color',colors(k,:), ...
        'DisplayName',sprintf('circle %d',k))
    plot(anchor.east(k),anchor.north(k),'p','MarkerSize',14, ...
        'MarkerFaceColor',colors(k,:),'MarkerEdgeColor','k','HandleVisibility','off')
    d = dwells.circle == k;
    plot(dwells.east(d),dwells.north(d),'o','MarkerSize',7,'MarkerEdgeColor','k', ...
        'MarkerFaceColor',colors(k,:),'HandleVisibility','off')
end
axis equal; grid on; xlabel('east [m]'); ylabel('north [m]')
lo = prctile([x(hasbearing) y(hasbearing)],0.5);
hi = prctile([x(hasbearing) y(hasbearing)],99.5);
pad = 0.3*max(hi-lo); xlim([lo(1)-pad hi(1)+pad]); ylim([lo(2)-pad hi(2)+pad])
legend('Location','best'); title('fixes by circle; dwells (o); anchors (stars)')

nexttile(7); hold on
for k = 1:ncircle
    in = circleof == k & hasbearing;
    plot(x(in)-anchor.east(k),y(in)-anchor.north(k),'.','Color',colors(k,:),'MarkerSize',4)
end
plot(0,0,'k+','MarkerSize',14,'LineWidth',2); axis equal; grid on
xlabel('east from anchor [m]'); ylabel('north from anchor [m]')
title('fixes relative to their circle''s anchor')

tiles = [2 5];
labels = ["east [m]","north [m]"];
for icomp = 1:2
    nexttile(tiles(icomp),[1 2]); hold on
    shadeCircles(anchor,colors)
    if icomp == 1; v = x; dv = dwells.east; else; v = y; dv = dwells.north; end
    plot(t,v,'.','Color',[0.4 0.4 0.4],'MarkerSize',4)
    for k = 1:ncircle
        in = dwells.circle == k;
        plot([dwells.start(in) dwells.stop(in)]',[dv(in) dv(in)]','-', ...
            'Color',colors(k,:),'LineWidth',3)
    end
    ylim(prctile(v(hasbearing),[0.5 99.5]) + [-30 30]); grid on; ylabel(labels(icomp))
    xlim(timelimits); xticks(floor(timelimits(1)):ceil(timelimits(2)))
    datetick('x','mm/dd','keeplimits','keepticks')
    title(labels(icomp) + " vs time; dwells (bars), circle spans (shaded)")
end

nexttile(8); hold on
for k = 1:ncircle
    in = circleof == k & hasbearing;
    plot(t(in),distance(in),'.','Color',colors(k,:),'MarkerSize',4)
    plot([anchor.start(k) anchor.stop(k)],anchor.radius(k)*[1 1],'k--')
end
grid on; xlim(timelimits); xticks(floor(timelimits(1)):ceil(timelimits(2)))
datetick('x','mm/dd','keeplimits','keepticks')
ylabel('m'); title('distance from the circle''s anchor')

nexttile(9); hold on
[~,ifix] = ismember(time,t);
for k = 1:ncircle
    in = circleof(ifix) == k;
    plot(time(in),heading(in),'.','Color',colors(k,:),'MarkerSize',4)
end
ylim([0 360]); yticks(0:90:360); grid on
xlim(timelimits); xticks(floor(timelimits(1)):ceil(timelimits(2)))
datetick('x','mm/dd','keeplimits','keepticks'); ylabel('deg')
title('watch bearing, anchor to buoy')

title(layout,sprintf('%s: watchBearingDrag, %d watch circle(s)',mission,ncircle), ...
    'Interpreter','none')
outputfile = options.OutputFile;
if outputfile == ""
    outputfile = fullfile(folder,"debug",mission + "_watchbearing.png");
end
if ~isfolder(fileparts(outputfile)); mkdir(fileparts(outputfile)); end
print(fh,outputfile,'-dpng','-r120')
end

function [x,y,t] = localPositions(SWIFT)
% Same projection as watchBearingDrag: metres about the deployment median.
lat = [SWIFT.lat]'; lon = [SWIFT.lon]'; t = [SWIFT.time]';
valid = isfinite(lat+lon+t);
lat = lat(valid); lon = lon(valid); t = t(valid);
[t,order] = sort(t); lat = lat(order); lon = lon(order);
lat0 = median(lat); lon0 = median(lon);
x = (lon-lon0).*cosd(lat0)*111320;
y = (lat-lat0)*110540;
end

function shadeCircles(anchor,colors)
% Shade each circle's time span.
yl = [-1e4 1e4];
for k = 1:numel(anchor.east)
    patch([anchor.start(k) anchor.stop(k) anchor.stop(k) anchor.start(k)], ...
        yl([1 1 2 2]),colors(k,:),'FaceAlpha',0.08,'EdgeColor','none')
end
end
