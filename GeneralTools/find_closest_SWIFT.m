function [nearestswift, nearestburst, deltadist, deltatime] = find_closest_SWIFT(casttime, castlat, castlon, SWIFTtimes, SWIFTlats, SWIFTlons, advscale)
% FIND_CLOSEST_SWIFT Find the closest SWIFT and burst to a given point in time and space 
%    Motivated by desire to find SWIFT closest to a given CTD cast, but could
%       be used to find SWIFT nearest to any space-time point of interest. 

%     Note: User must specify an advective timescale, 'advscale', to relate time
%     and space. E.g., typical drift speeds for period of interest

% Time must be datetime vector. If necessary use
%   datetime(time,'ConvertFrom','datenum').

% K. Zeiden 06/17/2021, initialized by Grok AI

% Inputs:
%   casttime: datetime array of CTD cast times (n x 1)
%   castlat: array of CTD cast latitudes in degrees (n x 1)
%   castlon: array of CTD cast longitudes in degrees (n x 1)
%   SWIFTtimes: cell array of K datetime vectors, one for each of K SWIFTs
%   SWIFTlats: cell array of K latitude vectors, one for each of K SWIFTs
%   SWIFTlons: cell array of K longitude vectors, one for each of K SWIFTs
%   advscale: (scalar) advective velocity scale in m/s (1 x 1)

% Outputs:
%   nearestswift: indices of closest drifter (1 to K) for each CTD cast (n x 1)
%   nearestburst: indices within the drifter's time series (n x 1)
%   deltadist: spatial distances to closest drifter points in km (n x 1)
%   deltatime: time differences to closest drifter points in min (n x 1)

% Example Usage
% casttime = datetime('2025-06-17') + hours(1:3)';
% castlat = [40; 40.1; 40.2];
% castlon = [-70; -70.1; -70.2];
% SWIFTtimes = {datetime('2025-06-17') + hours(0:2)', datetime('2025-06-17') + hours(1:3)'};
% SWIFTlats = {[40.01; 40.02; 40.03], [40.15; 40.16; 40.17]};
% SWIFTlons = {[-70.01; -70.02; -70.03], [-70.15; -70.16; -70.17]};
 
% [nearestswift, closestburst, deltadist, deltatime] = find_closest_SWIFT(casttime, castlat, castlon, SWIFTtimes, SWIFTlats, SWIFTlons);

% Plotting option
plotselect = false;
plotsum = false;

% Time and Distance scales
dtscale = 12*60; % (s) SWIFT duty cycle -- only matters if inforcing max separation
drscale = advscale*dtscale; % (m)

% Ensure CTD inputs are column vectors
casttime = casttime(:);
castlat = castlat(:);
castlon = castlon(:);

ncast = length(casttime);
nearestswift = zeros(ncast, 1);
nearestburst = zeros(ncast, 1);
deltadist = inf(ncast, 1);
deltatime = inf(ncast, 1);

% Number of SWIFTs
nswift = length(SWIFTtimes);

% Loop through each position of interest (cast)
if plotselect;figure('color','w');end
for icast = 1:ncast

    mineudist = inf;

    % Loop through each SWIFT mission, compute distance in space-time & update
    %   as closest swift if nearer than the last. 
    for kswift = 1:nswift

        % Get current drifter's data
        stime = SWIFTtimes{kswift}(:);
        slat = SWIFTlats{kswift}(:);
        slon = SWIFTlons{kswift}(:);
        
        % Calculate spatial distances (m)
        dx = deg2km(castlon(icast) - slon,6371*cosd(mean(slat,'omitnan'))) .* 1000;% m
        dy = deg2km(castlat(icast) - slat)*1000;% m
        dr = sqrt(dx.^2 + dy.^2); % m
        
        % Calculate time distances (s)
        dt = 60*60*abs(hours(casttime(icast) - stime));% s
        
        % Enforce maximum time
        % dt(dt>dtscale) = inf;

        % Enforce maximum distance
        % dr(dr>drscale) = inf;
        
        % Normalize distances and time differences
        normDist = dr / drscale;
        normTime = dt / dtscale;
        
        % Combined metric (Euclidean distance in normalized space)
        eudist = sqrt(normDist.^2 + normTime.^2);
        
        % Find minimum for this drifter
        [kmineudist, minburstindex] = min(eudist);
        
        % Update if this drifter is closer
        if kmineudist < mineudist
            mineudist = kmineudist;
            nearestswift(icast) = kswift;
            nearestburst(icast) = minburstindex;
            deltadist(icast) = dr(minburstindex)/1000;
            deltatime(icast) = dt(minburstindex)/60;
        end

        % Add SWIFT distances to figure
        if plotselect
        scatter(dr/1000,dt/60,5,'k','filled')
        hold on
        end

    end

    % Plot selected nearest SWIFT differences
    if plotselect
    scatter(deltadist(icast),deltatime(icast),'r','LineWidth',2)
    title(['Cast # ' num2str(icast)])
    ylim([0 6*60]);xlim([0 10])
    pause(0.25)
    cla
    end

end

if plotsum
figure('color','w')
subplot(2,2,1)
b = bar(1:ncast,deltatime);
b.FaceColor = 'r';
axis tight
hold on
plot(xlim,dtscale/60*[1 1],'--k')
title('Time to nearest SWIFT')
ylabel('\DeltaT [min]')
subplot(2,2,3)
b = bar(1:ncast,deltadist);
b.FaceColor = 'r';
axis tight
hold on
plot(xlim,drscale/1000*[1 1],'--k')
title('Distance to nearest SWIFT')
xlabel('Cast #')
ylabel('\DeltaX [km]')
subplot(2,2,[2 4])
scatter(deltadist*1000/drscale,deltatime*60/dtscale,[],'r','filled')
ylabel('\DeltaT/\delta_T')
xlabel('\DeltaX/U\delta_T')
title(['Euclidean Space (\deltaT = 12 min, U = ' num2str(advscale) ' ms^{-1})'])
axis equal tight
hold on
plot([1 1],[0 1],'--k');plot([0 1],[1 1],'--k')
xlim([0 3]);ylim([0 3])
end

% End Function
end