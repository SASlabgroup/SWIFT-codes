function [nearestswift, nearestburst, ddist, dtime] = find_closest_SWIFT(ctime, clat, clon, SWIFTtimes, SWIFTlats, SWIFTlons)
% FIND_CLOSEST_SWIFT Find the closest SWIFT and burst to a given point in time and space 
%    Motivated by desire to find SWIFT closest to a given CTD cast, but could
%       be used to find SWIFT nearest to any space-time point of interest. 

% Time must be datetime vector. If necessary use
%   datetime(time,'ConvertFrom','datenum').

% NOTE: maximum time difference of 1 hour is enforced, but maximum distance is not. 
% Can be changed below....

% K. Zeiden 06/17/2021, initialized by Grok AI

% Inputs:
%   ctime: datetime array of CTD cast times (n x 1)
%   clat: array of CTD cast latitudes in degrees (n x 1)
%   clon: array of CTD cast longitudes in degrees (n x 1)
%   SWIFTtimes: cell array of K datetime vectors, one for each of K SWIFTs
%   SWIFTlats: cell array of K latitude vectors, one for each of K SWIFTs
%   SWIFTlons: cell array of K longitude vectors, one for each of K SWIFTs

% Outputs:
%   nearestswift: indices of closest drifter (1 to K) for each CTD cast (n x 1)
%   nearestburst: indices within the drifter's time series (n x 1)
%   ddist: spatial distances to closest drifter points in km (n x 1)
%   dtime: time differences to closest drifter points in hours (n x 1)

% Example Usage
% ctime = datetime('2025-06-17') + hours(1:3)';
% clat = [40; 40.1; 40.2];
% clon = [-70; -70.1; -70.2];
% Stimes = {datetime('2025-06-17') + hours(0:2)', datetime('2025-06-17') + hours(1:3)'};
% Slats = {[40.01; 40.02; 40.03], [40.15; 40.16; 40.17]};
% Slons = {[-70.01; -70.02; -70.03], [-70.15; -70.16; -70.17]};
 
% [nearestswift, closestburst, ddist, dtime] = find_closest_SWIFT(ctime, clat, clon, SWIFTtimes, SWIFTlats, SWIFTlons);

% Ensure CTD inputs are column vectors
ctime = ctime(:);
clat = clat(:);
clon = clon(:);

ncast = length(ctime);
nearestswift = zeros(ncast, 1);
nearestburst = zeros(ncast, 1);
ddist = inf(ncast, 1);
dtime = inf(ncast, 1);

% Number of SWIFTs
nswift = length(SWIFTtimes);

% Normalize distances and times
maxdr = 0.5; % Max distance for normalization (km, adjust as needed)
maxdt = 1; % Max time difference for normalization (hours, adjust as needed)

% Loop through each position of interest (cast)
for i = 1:ncast

    mineudist = inf;

    % Loop through each SWIFT, find minimum distance in space-time, update
    % closest swift if nearer than the last. 

    for k = 1:nswift
        % Get current drifter's data
        stime = SWIFTtimes{k}(:);
        slat = SWIFTlats{k}(:);
        slon = SWIFTlons{k}(:);
        
        % Calculate spatial distances
        dx = deg2km(clon(i) - slon,6371*cosd(mean(slat,'omitnan'))) .* 1000;
        dy = deg2km(clat(i) - slat)*1000;
        dr = sqrt(dx.^2 + dy.^2); % km
        
        % Calculate time differences in hours
        dt = abs(hours(ctime(i) - stime));
        
        % Enforce maximum time
        dt(dt>maxdt) = inf;
        
        % Normalize distances and time differences
        normDist = dr / maxdr;
        normTime = dt / maxdt;
        
        % Combined metric (Euclidean distance in normalized space)
        eudist = sqrt(normDist.^2 + normTime.^2);
        
        % Find minimum for this drifter
        [imineudist, minindex] = min(eudist);
        
        % Update if this drifter is closer
        if imineudist < mineudist
            mineudist = imineudist;
            nearestswift(i) = k;
            nearestburst(i) = minindex;
            ddist(i) = dr(minindex);
            dtime(i) = dt(minindex);
        end
    end

end


% End Function
end