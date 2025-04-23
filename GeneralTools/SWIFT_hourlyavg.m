function [hrSWIFT] =SWIFT_hourlyavg(SWIFT)
%%%%%%%%%%%%%%%%%SWIFT_nondimensionalparams.m
%
%   Calculates hourly averages for all SWIFT scalar .mat variables
%
%   Created: M. James, April 2025

fields = fieldnames(SWIFT);
numericArrayFields = {};

for i = 1:numel(fields)
    fieldValue = SWIFT.(fields{i});
    
    % Check if the field is a numeric array (and not scalar)
    if isfloat(fieldValue) && isscalar(fieldValue)
        numericArrayFields{end+1} = fields{i};
    end
end

% time
days = day([SWIFT.time]);
hours = hour([SWIFT.time]);

% Start hourly index at start of dataset
hours = hours + 24.*(days- days(1));
starthour = min([SWIFT.time]*24)/24;
hours = hours-min(hours)+1;

%continuous indexing
hour_idx = hours;
while any( diff(hour_idx)>1)
    min(find(diff(hour_idx)>1))
    hour_idx(ans+1:end) = hour_idx(ans+1:end) - diff(hour_idx(ans:ans+1));
end

% Datetime hour bins
hour_bins = unique(hours./24 - 0.5/24 + starthour); % center point at every half hour


for i=1:numel(numericArrayFields)
    if contains(numericArrayFields(i),'dir')
        x = num2cell(accumarray(hour_idx', [SWIFT.(numericArrayFields{i})]', ...
        [length(unique(hours)), 1], @(x) ...
        mod(atan2d(nanmean(sind(x)), nanmean(cosd(x))), 360)...
        , NaN)); %circularly calculated means (no discontinuity when in vector form)
        [hrSWIFT(1:length(unique(hours))).(numericArrayFields{i})] = deal(x{:});
    else         
        try
            x = num2cell(accumarray(hour_idx', [SWIFT.(numericArrayFields{i})]', ...
                [length(unique(hours)), 1], @(x) ...
                nanmean(x)...
                , NaN)); %circularly calculated means (no discontinuity when in vector form)
            [hrSWIFT(1:length(unique(hours))).(numericArrayFields{i})] = deal(x{:});
        catch me
            disp(me)
        end
    end
end

num2cell(hour_bins+0.5/24);
[hrSWIFT.time] = deal(ans{:});

[hrSWIFT.ID] = deal(SWIFT(1).ID);
end
