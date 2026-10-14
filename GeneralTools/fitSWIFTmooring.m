% Fit watch circle of each SWIFT mooring over its final deployment period.
% Mask to t >= start of final deployment (set per buoy in header), project to
% local ENU about the median, Kasa circle fit, plot points + circle + center
% with a position table; print positions to the command window.

% --- edit for each deployment | this should have multiple swift mat files in it ---
data_dir = '/tmp/SWIFT_25_24_23_22_20261005T000000_now';

% first fix of final deployment (UTC)
% Trim off anything before the actual deployment
deploy_start = containers.Map( ...
    {'SWIFT22', 'SWIFT23', 'SWIFT24', 'SWIFT25'}, ...
    {datenum(2026,10,6,19,27,50), datenum(2026,10,8,17,57,57), ...
     datenum(2026,10,6,20,30,3),  datenum(2026,10,8,19,28,5)});

% --------------------------------

mat_files = dir(fullfile(data_dir, 'SWIFT*_telemetry.mat'));
wgs84 = wgs84Ellipsoid('meter');

figure('Color', 'w');
map_ax = geoaxes;
geobasemap(map_ax, 'satellite');
hold(map_ax, 'on');
colors = lines(numel(mat_files));

n_swift = numel(mat_files);
swift_id = strings(n_swift, 1);
center_lat = nan(n_swift, 1); center_lon = center_lat; radius_m = center_lat;
rms_residual = center_lat; n_used = center_lat; n_total = center_lat; start_time = center_lat;

for i = 1:n_swift
    swift_id(i) = erase(mat_files(i).name, '_telemetry.mat');
    telem = load(fullfile(mat_files(i).folder, mat_files(i).name));
    lat = [telem.SWIFT.lat]'; lon = [telem.SWIFT.lon]'; time = [telem.SWIFT.time]';
    valid = isfinite(lat) & isfinite(lon);
    n_total(i) = sum(valid);

    start_time(i) = deploy_start(char(swift_id(i)));
    in_deploy = valid & time >= start_time(i);
    lat = lat(in_deploy); lon = lon(in_deploy);
    n_used(i) = sum(in_deploy);

    ref_lat = median(lat); ref_lon = median(lon);
    [east, north] = geodetic2enu(lat, lon, 0, ref_lat, ref_lon, 0, wgs84);
    % Fit the center of the circle, it this is noisy you could do ransac, or if dragging break up the records  
    circle = fit_circle_kasa(east, north);
    radius_m(i) = circle(3);
    rms_residual(i) = sqrt(mean((hypot(east - circle(1), north - circle(2)) - circle(3)).^2));

    [center_lat(i), center_lon(i)] = enu2geodetic(circle(1), circle(2), 0, ref_lat, ref_lon, 0, wgs84);
    theta = linspace(0, 2*pi, 361);
    [circle_lat, circle_lon] = enu2geodetic(circle(1) + circle(3)*cos(theta), circle(2) + circle(3)*sin(theta), 0, ref_lat, ref_lon, 0, wgs84);

    geoscatter(map_ax, lat, lon, 8, colors(i,:), 'filled', 'MarkerFaceAlpha', 0.5, 'DisplayName', swift_id(i));
    geoplot(map_ax, circle_lat, circle_lon, '-', 'Color', colors(i,:), 'LineWidth', 1.5, 'HandleVisibility', 'off');
    geoscatter(map_ax, center_lat(i), center_lon(i), 120, colors(i,:), 'p', 'filled', 'MarkerEdgeColor', 'k', 'HandleVisibility', 'off');
    text(map_ax, center_lat(i), center_lon(i), "  " + swift_id(i), 'Color', 'w', 'FontWeight', 'bold');
end

legend(map_ax, 'Location', 'northeast');
title(map_ax, 'SWIFT mooring watch circles');
% pad the extent below the moorings so the table box sits in open water
[lat_lim, lon_lim] = geolimits(map_ax);
geolimits(map_ax, [lat_lim(1) - 0.6*diff(lat_lim), lat_lim(2)], lon_lim);

center_lat_dm = strings(n_swift, 1); center_lon_dm = center_lat_dm;
for i = 1:n_swift
    center_lat_dm(i) = deg_decmin(center_lat(i), 'N', 'S');
    center_lon_dm(i) = deg_decmin(center_lon(i), 'E', 'W');
end
start_str = string(datestr(start_time, 'yyyy-mm-dd HH:MM'));

table_text = sprintf('%-8s %-13s %-14s %5s  %s', 'SWIFT', 'lat', 'lon', 'r (m)', 'start (UTC)');
for i = 1:n_swift
    table_text = [table_text ...
     newline sprintf('%-8s %-13s %-14s %5.1f  %s', swift_id(i), center_lat_dm(i), center_lon_dm(i), radius_m(i), start_str(i))]; 
end
annotation('textbox', [0.14 0.12 0.4 0.12], 'String', table_text, 'FontName', 'Courier', 'FontSize', 9, 'BackgroundColor', 'w', 'FitBoxToText', 'on', 'Interpreter', 'none');
% exportgraphics(gcf, fullfile(data_dir, 'mooring_centroids.png'), 'Resolution', 150);

fprintf('%-8s %11s %12s %8s %8s %-17s %6s %6s\n', 'SWIFT', 'lat', 'lon', 'r_m', 'rms_m', 'start_utc', 'used', 'total');
for i = 1:n_swift
    fprintf('%-8s %11.6f %12.6f %8.1f %8.1f %-17s %6d %6d\n', swift_id(i), center_lat(i), center_lon(i), radius_m(i), rms_residual(i), start_str(i), n_used(i), n_total(i));
end

function m = fit_circle_kasa(x, y)
% x^2 + y^2 + D x + E y + F = 0  ->  [xc yc r]
coef = [x y ones(size(x))] \ -(x.^2 + y.^2);
xc = -coef(1)/2; yc = -coef(2)/2;
m = [xc yc sqrt(xc^2 + yc^2 - coef(3))];
end

function s = deg_decmin(deg, pos, neg)
hemi = pos; if deg < 0, hemi = neg; end
abs_deg = abs(deg);
s = sprintf('%d %06.3f %s', floor(abs_deg), 60*(abs_deg - floor(abs_deg)), hemi);
end
