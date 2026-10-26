function cal = plotMagCalibration3D(records,folder,inclination,options)
%PLOTMAGCALIBRATION3D Fit and plot the 3D calibration of a magnetometer.
%
%   cal = plotMagCalibration3D(records,folder,inclination,Name=Value)
%
%   records      magnetometer records of one mission (see
%                plotMagCalibration2D).
%   folder       the mission folder; its name labels the figure.
%   inclination  magnetic inclination in the frame of records.d, deg: the
%                local (e.g. WMM) value, negated if d points up.
%
%   Name-value options: Sensor, Reference, Declination, Breaks, Window,
%   Step, SWIFTfile as in plotMagCalibration2D; OutputFile (default
%   <folder>/debug/<mission>_<Sensor>_mag3d.png).
%
%   Fits fitMagCalibration3D and plots: the raw body-frame field with the
%   fitted ellipsoid and hard-iron track; the corrected field on the unit
%   sphere; the hard iron per window; the record-mean heading against the
%   reported heading and the watch-circle bearing; the heading minus the
%   watch bearing by watch-circle lobe; and the inclination and field
%   magnitude, which a correct calibration holds constant.
%
% mleclair (using claude), Oct 2026

arguments
    records struct
    folder (1,1) string
    inclination (1,1) double
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
cal = fitMagCalibration3D(records.key,records.m,records.d,options.Window, ...
    options.Step,options.Breaks,inclination);

% Corrected field, heading, inclination and magnitude per record
nrec = numel(records.key);
corrected = cell(nrec,1);
heading = NaN(nrec,1);
recordinclination = NaN(nrec,1);
magnitude = NaN(nrec,1);
for irec = 1:nrec
    [c,S] = magCalibrationAt(cal,records.key(irec));
    p = (records.m{irec} - c)*S';     % S is symmetric
    corrected{irec} = p;
    [X,Y,Z] = levelMagField(p,records.d{irec});
    heading(irec) = meandir(atan2d(-Y,X)) + options.Declination;
    recordinclination(irec) = mean(atan2d(Z,hypot(X,Y)));
    magnitude(irec) = mean(vecnorm(p,2,2));
end
magnitude = magnitude/median(magnitude,'omitnan');

[watchtime,watch,recordwatch,lobeA] = watchValidation(folder,options.SWIFTfile, ...
    records.key);

%% Figure
fh = figure('Color','w','Position',[30 30 1500 1000]);
layout = tiledlayout(3,3,'TileSpacing','compact');
timelimits = [min(records.key) max(records.key)];
allm = vertcat(records.m{:});
allp = vertcat(corrected{:});
k = round(linspace(1,size(allm,1),min(20000,size(allm,1))));

nexttile(1)
plot3(allm(k,1),allm(k,2),allm(k,3),'.','Color',[0.6 0.6 0.6],'MarkerSize',1)
hold on
plotFittedEllipsoids(cal)
axis equal; grid on; view(35,20)
xlabel('m_x'); ylabel('m_y'); zlabel('m_z')
title('raw body-frame field; fit (mid window), centers (red)')

nexttile(4)
unitp = allp(k,:)./median(vecnorm(allp,2,2));
plot3(unitp(:,1),unitp(:,2),unitp(:,3),'.','Color',[0.3 0.5 0.8],'MarkerSize',1)
hold on
[sx,sy,sz] = sphere(24);
surf(sx,sy,sz,'FaceAlpha',0,'EdgeColor',[0.7 0.7 0.7],'EdgeAlpha',0.4)
axis equal; grid on; view(35,20)
title('corrected field (normalized) on the unit sphere')

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
legend('c_x','c_y','c_z','Location','best','AutoUpdate','off')
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
plot(records.key(lobeA),recordinclination(lobeA),'.', ...
    'Color',[0 0.45 0.74],'MarkerSize',5); hold on
plot(records.key(~lobeA),recordinclination(~lobeA),'.', ...
    'Color',[0.85 0.33 0.1],'MarkerSize',5)
yline(inclination,'k--')
ylim(inclination + [-15 15]); grid on
xlim(timelimits); xticks(floor(timelimits(1)):ceil(timelimits(2)))
datetick('x','mm/dd','keeplimits','keepticks'); ylabel('deg')
title(sprintf('inclination: mean %.1f, sd %.1f (target %.1f dashed)', ...
    mean(recordinclination,'omitnan'),std(recordinclination,'omitnan'), ...
    inclination))

nexttile(9)
plot(records.key(lobeA),magnitude(lobeA),'.', ...
    'Color',[0 0.45 0.74],'MarkerSize',5); hold on
plot(records.key(~lobeA),magnitude(~lobeA),'.', ...
    'Color',[0.85 0.33 0.1],'MarkerSize',5)
yline(1,'k--')
ylim([0.7 1.3]); grid on
xlim(timelimits); xticks(floor(timelimits(1)):ceil(timelimits(2)))
datetick('x','mm/dd','keeplimits','keepticks')
title(sprintf('field magnitude / median (should be 1): sd %.1f%%', ...
    100*std(magnitude,'omitnan')))

title(layout,mission + ": inclination-constrained 3D " + options.Sensor + ...
    " magnetometer calibration",'Interpreter','none')
outputfile = options.OutputFile;
if outputfile == ""
    outputfile = fullfile(folder,"debug",mission + "_" + ...
        options.Sensor + "_mag3d.png");
end
outdir = fileparts(outputfile);
if outdir ~= "" && ~isfolder(outdir); mkdir(outdir); end
print(fh,outputfile,'-dpng','-r120')
end

function plotFittedEllipsoids(cal)
% Fitted surface of the middle window of each segment and the center track.
% The surface is S^-1 * (unit sphere) + c.
[sx,sy,sz] = sphere(24);
for iseg = unique(cal.segment)'
    in = find(cal.segment == iseg);
    j = in(ceil(numel(in)/2));
    surface = (cal.shape(:,:,j)\[sx(:) sy(:) sz(:)]')' + cal.center(j,:);
    surf(reshape(surface(:,1),size(sx)),reshape(surface(:,2),size(sx)), ...
        reshape(surface(:,3),size(sx)),'FaceColor','r','FaceAlpha',0.05, ...
        'EdgeColor',[0.85 0.3 0.3],'EdgeAlpha',0.3)
    plot3(cal.center(in,1),cal.center(in,2),cal.center(in,3),'r.-','MarkerSize',8)
end
end
