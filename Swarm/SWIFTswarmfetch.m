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
std_dir = accumarray(hour_idx', [SWIFT.winddirT]',...
    [length(unique(hours)), 1], @(x) std(x, 0,'omitnan'), NaN);
median_dir = accumarray(hour_idx', [SWIFT.winddirT]', ...
    [length(unique(hours)), 1], @(x) median(x, 1,'omitnan'), NaN);
std_mag = accumarray(hour_idx', [SWIFT.windspd]',...
    [length(unique(hours)), 1], @(x) std(x, 0,'omitnan'), NaN);
median_mag = accumarray(hour_idx', [SWIFT.windspd]', ...
    [length(unique(hours)), 1], @(x) median(x, 1,'omitnan'), NaN);

% Check for discontinuity in dir
d_idx = find(median_dir >340 | median_dir <20);
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
errorbar(hour_bins, median_dir, std_dir,...
    'ko-', 'MarkerFaceColor', 'k', 'LineWidth', 1.5);
hold on

errorbar(hour_bins(filteridx), median_dir(filteridx),...
    std_dir(filteridx),'ro',...
    'MarkerFaceColor', 'r', 'LineWidth', 1.5);

datetick
yticks([ 0 90 180 270 360]);ylim([0 360])
ylabel('wind dir [deg]')
grid


subplot 212
errorbar(hour_bins, median_mag, std_mag,...
    'ko-', 'MarkerFaceColor', 'k', 'LineWidth', 1.5);
hold on
errorbar(hour_bins(filteridx), median_mag(filteridx),...
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

%% Create fetch axis
% bin out median dir

median_dir = round(median_dir/9)*9;

% Generic lat/lon offset
[latoffset,lonoffset] = deal(mean([SWIFT.lat],'all','omitnan'), mean([SWIFT.lon],'all','omitnan'));

% Find fetch from origin

%load in coastlines data
load("Coastlinelatlon.mat");

fetches = SWIFT_makefetchbins(latoffset,lonoffset,coastlinelatlon);

% Convert lat lon to along wind coords
for i = 1:length(SWIFT);
    for k = find(i==steady_winds_idx);
        if k ==1;
            [ x, y ] = xytransform([SWIFT(k).lat],...
            [SWIFT(k).lon],latoffset,lonoffset, median_dir(i));
            x = x./1000 + fetches(round(median_dir(i)/9));
            y = y./1000;
        else
            [ xadd, yadd ] = xytransform([SWIFT(k).lat],...
            [SWIFT(k).lon],latoffset,lonoffset, median_dir(i));
            xadd = xadd./1000 + fetches(round(median_dir(i)/9));
            yadd = yadd./1000;
            x = [x xadd];
            y = [y yadd];
        end
    end
end; clear yadd xadd tol i k

% plot as a scatter vec to confirm spatial agreements

plot(coastlinelatlon.lon, coastlinelatlon.lat,'k-')
hold on
plot([lonoffset] + sind([0:9:360]).*km2deg(fetches)',[latoffset] + cosd([0:9:360]).*km2deg(fetches)','o')
plot([SWIFT.lon] + sind([SWIFT.winddirT]).*km2deg(x),[SWIFT.lat] + cosd([SWIFT.winddirT]).*km2deg(x),'x')
ylabel('lat'); xlabel('lon');
legend('','fetchbins', 'observed fetch from binning')
ylim([latoffset- 0.5, latoffset+ 0.5]);
xlim([lonoffset- 0.5, lonoffset+ 0.5]);

print('-djpeg','SWIFTswarmfetch_checkfetch')

% Time synchronous fetch derivations

% Assign fetch "x" to SWIFT
for i = 1:length(SWIFT);
   SWIFT(i).fetch = x(i); 
end; clear i;

% Check for bad data (false inputs)
[SWIFT([SWIFT.sigwaveheight] == 0).sigwaveheight] = deal(nan);

% Run Nondimensional Params for entire

[nondim, ~] =SWIFT_nondimensionalparams(SWIFT,true,'all'); 

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