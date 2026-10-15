function cal = plotMagCalibration2D(records,folder,options)
%PLOTMAGCALIBRATION2D Fit and plot the 2D (levelled) calibration of a magnetometer.
%
%   cal = plotMagCalibration2D(records,folder,Name=Value)
%
%   records  magnetometer records of one mission: key (slot time,
%            datenum), m and d (cell arrays of body-frame field samples and
%            unit down vectors) and yaw (record-mean heading the sensor
%            reports, deg), e.g. from loadSBGmagRecords or
%            loadSIGmagRecords.
%   folder   the mission folder; its name labels the figure.
%
%   Name-value options:
%     Sensor       sensor name for labels and the file name (default "SBG").
%     Reference    name of the reported heading in records.yaw (default
%                  "EKF yaw").
%     Declination  local magnetic declination, deg east (default 0, so
%                  headings are magnetic).
%     Breaks       times of known changes in the magnetic environment, e.g.
%                  battery changes (default none).
%     Window, Step fit window length and spacing, days (default 24.84 h,
%                  3 h).
%     SWIFTfile    SWIFT .mat with lat/lon for the watch-circle check
%                  (default: *_L4.mat in the folder, if any).
%     OutputFile   figure file (default
%                  <folder>/debug/<mission>_<Sensor>_mag2d.png).
%
%   Levels the field with the down vectors (levelMagField), fits
%   fitMagCalibration2D and plots: the levelled horizontal field with the
%   fitted hard-iron centers; the corrected field on the unit circle; the
%   centers per window; the record-mean heading against the reported
%   heading and the watch-circle bearing; the heading minus the watch
%   bearing by watch-circle lobe; the calibrated minus the reported heading
%   (for the SBG, the yaw anchor offset); and the horizontal field
%   magnitude, which a correct calibration holds constant.

arguments
    records struct
    folder (1,1) string
    options.Sensor (1,1) string = "SBG"
    options.Reference (1,1) string = "EKF yaw"
    options.Declination (1,1) double = 0
    options.Breaks double = []
    options.Window (1,1) double = 24.84/24
    options.Step (1,1) double = 3/24
    options.SWIFTfile string = ""
    options.OutputFile string = ""
end

if isfile(folder); folder = fileparts(folder); end
[~,mission] = fileparts(folder);
levelled = cell(size(records.m));
for irec = 1:numel(records.key)
    [X,Y] = levelMagField(records.m{irec},records.d{irec});
    levelled{irec} = [X Y];
end
cal = fitMagCalibration2D(records.key,levelled,options.Window,options.Step, ...
    options.Breaks);

% Corrected field, heading and magnitude per record
nrec = numel(records.key);
corrected = cell(nrec,1);
heading = NaN(nrec,1); magnitude = NaN(nrec,1);
for irec = 1:nrec
    [c,S] = magCalibrationAt(cal,records.key(irec));
    p = (levelled{irec} - c)*S';      % S is symmetric
    corrected{irec} = p;
    heading(irec) = meandir(atan2d(-p(:,2),p(:,1))) + options.Declination;
    magnitude(irec) = mean(vecnorm(p,2,2));
end
magnitude = magnitude/median(magnitude,'omitnan');
anchoroffset = mod(heading-records.yaw+180,360)-180;

[watchtime,watch,recordwatch,lobeA] = watchValidation(folder,options.SWIFTfile, ...
    records.key);

%% Figure
fh = figure('Color','w','Position',[30 30 1500 1000]);
layout = tiledlayout(3,3,'TileSpacing','compact');
timelimits = [min(records.key) max(records.key)];
alll = vertcat(levelled{:});
allp = vertcat(corrected{:});
k = round(linspace(1,size(alll,1),min(20000,size(alll,1))));

nexttile(1)
plot(alll(k,1),alll(k,2),'.','Color',[0.6 0.6 0.6],'MarkerSize',1); hold on
plot(cal.center(:,1),cal.center(:,2),'r.','MarkerSize',8)
plot(0,0,'k+','MarkerSize',12,'LineWidth',2)
axis equal; grid on; xlabel('X (levelled)'); ylabel('Y (levelled)')
percentileLimits([alll; 0 0])
title('levelled horizontal field; centers per window (red)')

nexttile(4)
unitp = allp(k,:)./median(vecnorm(allp,2,2));
plot(unitp(:,1),unitp(:,2),'.','Color',[0.3 0.5 0.8],'MarkerSize',1); hold on
theta = linspace(0,2*pi,200);
plot(cos(theta),sin(theta),'r'); plot(0,0,'k+','MarkerSize',12,'LineWidth',2)
axis equal; grid on; percentileLimits([unitp; 0 0])
title(sprintf('corrected field (normalized) on the unit circle; %s',cal.method))

nexttile(7)
hold on
for iseg = unique(cal.segment)'
    in = cal.segment == iseg;
    set(gca,'ColorOrderIndex',1)
    plot(cal.time(in),cal.center(in,:),'.-','MarkerSize',8)
end
grid on
xlim(timelimits); xticks(floor(timelimits(1)):ceil(timelimits(2)))
datetick('x','mm/dd','keeplimits','keepticks')
legend('c_X','c_Y','Location','best','AutoUpdate','off')
for b = cal.breaks'; xline(b,'k:'); end
title('hard-iron center per window; breaks (:)')

nexttile(2,[1 2])
plot(watchtime,mod(watch,360),'k.','MarkerSize',4, ...
    'DisplayName','watch bearing (drag-corrected)'); hold on
plot(records.key,mod(records.yaw,360),'r.','MarkerSize',5, ...
    'DisplayName',options.Sensor + " " + options.Reference)
plot(records.key,mod(heading,360),'.','Color',[0 0.6 0.2], ...
    'MarkerSize',5,'DisplayName','calibrated magnetometer')
ylim([0 360]); yticks(0:90:360); grid on; ylabel('deg')
xlim(timelimits); xticks(floor(timelimits(1)):ceil(timelimits(2)))
datetick('x','mm/dd','keeplimits','keepticks')
legend('Location','eastoutside')
title("record-mean heading of the " + options.Sensor + " x axis")

nexttile(5,[1 2])
plotWatchResidual(records.key,heading,recordwatch,lobeA,timelimits)

nexttile(8)
plot(records.key(lobeA),anchoroffset(lobeA),'.', ...
    'Color',[0 0.45 0.74],'MarkerSize',5); hold on
plot(records.key(~lobeA),anchoroffset(~lobeA),'.', ...
    'Color',[0.85 0.33 0.1],'MarkerSize',5)
grid on
xlim(timelimits); xticks(floor(timelimits(1)):ceil(timelimits(2)))
datetick('x','mm/dd','keeplimits','keepticks')
ylabel('deg')
title(sprintf('calibrated heading minus %s: median %.1f',options.Reference, ...
    median(anchoroffset,'omitnan')))

nexttile(9)
plot(records.key(lobeA),magnitude(lobeA),'.', ...
    'Color',[0 0.45 0.74],'MarkerSize',5); hold on
plot(records.key(~lobeA),magnitude(~lobeA),'.', ...
    'Color',[0.85 0.33 0.1],'MarkerSize',5)
yline(1,'k--')
ylim([0.7 1.3]); grid on
xlim(timelimits); xticks(floor(timelimits(1)):ceil(timelimits(2)))
datetick('x','mm/dd','keeplimits','keepticks')
title(sprintf('horizontal field magnitude / median: sd %.1f%%', ...
    100*std(magnitude,'omitnan')))

title(layout,mission + ": 2D (levelled) " + options.Sensor + ...
    " magnetometer calibration",'Interpreter','none')
outputfile = options.OutputFile;
if outputfile == ""
    outputfile = fullfile(folder,"debug",mission + "_" + ...
        options.Sensor + "_mag2d.png");
end
outdir = fileparts(outputfile);
if outdir ~= "" && ~isfolder(outdir); mkdir(outdir); end
print(fh,outputfile,'-dpng','-r120')
end

function percentileLimits(xy)
% Axis limits from the 0.5--99.5th percentiles, so rare spikes do not set
% the scale; padded by 10%.
lo = prctile(xy,0.5,1); hi = prctile(xy,99.5,1);
pad = 0.1*max(hi-lo);
xlim([lo(1)-pad hi(1)+pad]); ylim([lo(2)-pad hi(2)+pad])
end
