%% SWIFTswarmfetch
% script to run the spatial fetch analysis on a multiple SWIFT buoy
% aggregation
%
% M. James 2/2025

%%%%%% Function for transforms

function [x y] = xytransform(lat,lon,latoffset,lonoffset, ly_headingCWnorth)
    % converts into ly coordinates with x as ly and y as crosswise
        %ly_headingCWnorth = -180;                    % deg CCW from True north
    radius = 6371*cosd(latoffset);
    
    north = 1000*deg2km( lat - latoffset );
    east = 1000*deg2km(lonoffset - lon , radius );
    
    x = east * sind(ly_headingCWnorth) + north * cosd(ly_headingCWnorth);  % Along ly_headingCWnorth
    y = east * cosd(ly_headingCWnorth) - north * sind(ly_headingCWnorth);
    x = -x; % make x in the ward direction for positive fetch
end

function circ_std_deg = circular_std(angles_deg)
    % Convert to radians
    angles_rad = deg2rad(angles_deg(:));

    % Mean resultant length
    R = abs(mean(exp(1i * angles_rad)));

    % Circular standard deviation in radians
    circ_std_rad = sqrt(-2 * log(R));

    % Convert to degrees
    circ_std_deg = rad2deg(circ_std_rad);
end

%%%%%%%%%

% Make U10
% U10 calculation 
tic;sprintf("Running U10 calculation, time elapsed %ds",round(toc))
if ~isfield(SWIFT, 'windspd10')
    SWIFT = SWIFT_makeU10(SWIFT);
end
%%%%%%%%%%%%%%%%%%%%%%

% Filter down true winds (winddirT must be present)
SWIFT = SWIFT(~isnan([SWIFT.winddirT]));

% Analyze and Plot variance of wind direction and speed
days = day([SWIFT.time]);
hours = hour([SWIFT.time]);

% Start hourly index at start of dataset
hours = hours + 24.*(days- days(1));
starthour = min(min([SWIFT.time]).*24)/24;
hour_idx = hours-min(hours)+1;

% Compute variance and mean using accumarray
% std_dir = accumarray(hour_idx', [SWIFT.winddirT]',...
%     [length(unique(hours)), 1], @(x) std(x, 0,'omitnan'), NaN);
% median_dir = accumarray(hour_idx', [SWIFT.winddirT]', ...
%     [length(unique(hours)), 1], @(x) median(x, 1,'omitnan'), NaN);
mean_dir = accumarray(hour_idx', [SWIFT.winddirT]', ...
    [length(unique(hours)), 1], @(x) ...
    mod(atan2d(mean(sind(x)), mean(cosd(x))), 360)...
    , NaN); %circularly calculated means (no discontinuity when in vector form)
std_dir = accumarray(hour_idx', [SWIFT.winddirT]', ...
    [length(unique(hours)), 1], @(x) ...
    circular_std(x)...
    , NaN); %circularly calculated means (no discontinuity when in vector form)
std_mag = accumarray(hour_idx', [SWIFT.windspd]',...
    [length(unique(hours)), 1], @(x) std(x, 0,'omitnan'), NaN);
mean_mag = accumarray(hour_idx', [SWIFT.windspd]', ...
    [length(unique(hours)), 1], @(x) mean(x, 1,'omitnan'), NaN);

% Compute circular means and std



% Check for discontinuity in dir
d_idx = find(mean_dir >340 | mean_dir <20);
d_idx_l = [1:size(hour_idx==d_idx,1)]*(hour_idx==d_idx)+1;
[d_val] = accumarray(d_idx_l', ... % 1 placeholder for null condition
    [SWIFT.winddirT]', [length(d_idx)+1, 1], @(x)...
    std(mod(x+180,360), 0,'omitnan'), NaN); %rotate axis 180 to account for discont
std_dir(d_idx) = d_val(2:end)';

% Datetime hour bins
hour_bins = unique(hour_idx./24 + starthour);
clear d_val d_idx d_idx_l hours days starthour

% Plot dir

%tolerances for filter
tol = 20; %deg
filteridx = std_dir<tol;
tol = 1; %m/s
filteridx(std_mag>tol) =0 ;

figure;subplot 211
errorbar(hour_bins, mean_dir, std_dir,...
    'ko-', 'MarkerFaceColor', 'k', 'LineWidth', 1.5);
hold on

errorbar(hour_bins(filteridx), mean_dir(filteridx),...
    std_dir(filteridx),'ro',...
    'MarkerFaceColor', 'r', 'LineWidth', 1.5);

datetick
yticks([ 0 90 180 270 360]);ylim([0 360])
ylabel('wind dir [deg]')
grid


subplot 212
errorbar(hour_bins, mean_mag, std_mag,...
    'ko-', 'MarkerFaceColor', 'k', 'LineWidth', 1.5);
hold on
errorbar(hour_bins(filteridx), mean_mag(filteridx),...
    std_mag(filteridx),'ro',...
    'MarkerFaceColor', 'r', 'LineWidth', 1.5);

datetick;ylim([0 20])
grid
ylabel('wind spd [m/s]')
legend('hourly binned data','< 20 deg <1 m/s |STD|','Location','best')
xlabel('UTC')
print('-djpeg','SWIFTswarmfetch_steadytest')

% Final Filtered idx from SWIFT
steady_winds_idx = max(hour_idx == find(filteridx),[], 1);

SWIFT = SWIFT(steady_winds_idx);

steady_winds_idx = hour_idx(steady_winds_idx);

figure;
histogram(steady_winds_idx, length(hour_bins));
xlabel('hour')
ylabel('count')
title('Counts for hours with steady winds')

print('-djpeg','SWIFTswarmfetch_steadyhourhistorgram')

figure; 
ID = categorical(string({SWIFT.ID})');
counts = countcats(ID);
labels = unique(ID);

bar(counts)
xticklabels(labels)
xlabel('SWIFT ID')
ylabel('Number of inputs')

print('-djpeg','SWIFTswarmfetch_steadySWIFTIDs')



clear ans tol 
%% Create fetch axis
% bin out mean dir
close all;

mean_dir = round(mean_dir/9)*9;

% Generic lat/lon offset
[latoffset,lonoffset] = deal(mean([SWIFT.lat],'all','omitnan'), mean([SWIFT.lon],'all','omitnan'));

% Find fetch from origin

%load in coastlines data
if ~exist('coastlinelatlon')
    load("Coastlinelatlon.mat");
    disp('loading alaska coastline')
end

%Define radius of fetch calc
r = 1000; %km
r = km2deg(r);

% Define lat, lon
lat = [SWIFT.lat]';
lon = [SWIFT.lon]';

for k =1:length(steady_winds_idx);
    % Set up wind vector 
    % Steady winds are grabbed in groups, SWIFT is grabbed individually
    windvx = [lon(k), lon(k) + sind(mean_dir(steady_winds_idx(k))).*r]; % x ccw from north
    windvy = [lat(k), lat(k) + cosd(mean_dir(steady_winds_idx(k))).*r]; % y ccw from north
    
    % 1 --> 2 first line, 3 --> 4 second line
    % Find intersection points
    [xi, yi] = polyxpoly(windvx, windvy, ...
        coastlinelatlon.lon, coastlinelatlon.lat);

    % Check if there is an intersection
    isIntersect = ~isempty(xi);

    if isIntersect
        distance = sqrt((xi-lon(k)).^2 + (yi-lat(k)).^2);
        fetch(k) = deg2km(min(distance)); % kmclear
    else
        fetch(k) =NaN;
    end
end; clear xi yi distance

fetch = fetch';
    %%

% Old version based on single point of calculated fetch 

% fetches = SWIFT_makefetchbins(latoffset,lonoffset,coastlinelatlon);
% 
% % Convert lat lon to along wind coords
% for i = 1:length(SWIFT);
%     for k = find(i==steady_winds_idx);
%         if k ==1;
%             [ x, y ] = xytransform([SWIFT(k).lat],...
%             [SWIFT(k).lon],latoffset,lonoffset, mean_dir(i));
%             x = x./1000 + fetches(round(mean_dir(i)/9));
%             y = y./1000;
%         else
%             [ xadd, yadd ] = xytransform([SWIFT(k).lat],...
%             [SWIFT(k).lon],latoffset,lonoffset, mean_dir(i));
%             xadd = xadd./1000 + fetches(round(mean_dir(i)/9));
%             yadd = yadd./1000;
%             x = [x xadd];
%             y = [y yadd];
%         end
%     end
% end; clear yadd xadd tol i k

% plot as a scatter vec to confirm spatial agreements

plot(coastlinelatlon.lon, coastlinelatlon.lat,'k-','HandleVisibility','off')
hold on
% plot([lonoffset] + sind([0:9:360]).*km2deg(fetches)',[latoffset] + cosd([0:9:360]).*km2deg(fetches)','o')
% plot([SWIFT.lon] + sind([SWIFT.winddirT]).*km2deg(x),[SWIFT.lat] + cosd([SWIFT.winddirT]).*km2deg(x),'x')

% Update with each id
dir4plot = mean_dir(steady_winds_idx);
for i = 1:length(labels)
    name = char(labels(i));
    i = ID == labels(i);

    p = plot(lon(i)+sind(dir4plot(i)).*km2deg(fetch(i)),lat(i)+cosd(dir4plot(i)).*km2deg(fetch(i)),'o',...
        'DisplayName',['SWIFT ',name,' fetch']);
    plot(lon(i),lat(i),'.','Color',p.Color,...
        'DisplayName',['SWIFT ',name,' location']); clear p;
end

clear dir4plot;

ylabel('lat'); xlabel('lon');
legend('location', 'southeast')
ylim([lat(1)- 0.5, lat(1)+ 0.5]);
xlim([lon(1)- 0.5, lon(1)+ 0.5]);

clear lat lon

print('-djpeg','SWIFTswarmfetch_checkfetch')

% Time synchronous fetch derivations

% Assign fetch "x" to SWIFT
for i = 1:length(SWIFT);
   SWIFT(i).fetch = fetch(i); 
end; clear i;

% Check for bad data (false inputs)
[SWIFT([SWIFT.sigwaveheight] == 0).sigwaveheight] = deal(nan);

% Run Nondimensional Params for entire

[nondim, ~] =SWIFT_nondimensionalparams(SWIFT,true,'23ANDUP'); 

% Run Nondimensional Params for each hour
% 
% for i = 1:length(hour_bins);
%     for k = find(i==steady_winds_idx);
%         if SWIFT(k)>
%         name = strcat('SpatialFetchSWIFT_', ...
%             string(datetime(hour_bins(1),'ConvertFrom', 'datenum')))
%         [nondim, ~] =SWIFT_nondimensionalparams(SWIFT(k),1,name); 
%     end
% end


%% Plot each buoy in nondim sigH

figure
hold on
plot(sort(nondim.fetch),0.029.*[sort(nondim.fetch)],'m','DisplayName','Structural Collinearity')
plot(sort(nondim.fetch),0.029.*[sort(nondim.fetch)].^(1./2),'k','DisplayName','Stiassanie 2012')

for i = 1:length(labels)
    name = char(labels(i));
    i = nondim.ID == string(labels(i));

    plot(nondim.fetch(i), nondim.sigH(i),'.','DisplayName',['SWIFT ',name]);
end

legend('Location','northwest')
set(gca,'XScale', 'log','YScale','log')
xlim([1-1 1e2]);
ylim([1-2 1e1]);

xlabel('Nondimensional Fetch \chi')
ylabel('Nondimensional Sig. Wave Height $\hat{H}$', 'Interpreter', 'latex')

savefig('SWIFT 2X fetch synopsis')
print('-djpeg','SWIFT 2X fetch synopsis')