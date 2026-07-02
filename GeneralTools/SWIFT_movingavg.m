function [SWIFT] =SWIFT_movingavg(SWIFT, duration_dt)
%%%%%%%%%%%%%%%%%SWIFT_nondimensionalparams.m
%
%   Calculates moving averages for all SWIFT scalar .mat variables
% 
%   "SWIFT" - SWIFT structure
%   "duration_dt" - duration in datenum
% 
%   Created: M. James, June 2026

fields = fieldnames(SWIFT);
numericArrayFields = {};

for i = 1:numel(fields)
    fieldValue = SWIFT.(fields{i});
    
    % Check if the field is a numeric array (and not scalar)
    if isfloat(fieldValue) && isnumeric(fieldValue)
        if length([SWIFT.(fields{i})]) == length(SWIFT)
            numericArrayFields{end+1} = fields{i};
        end
    end
end

% Remove time as numeric field
numericArrayFields = setdiff(numericArrayFields, 'time');

% 2D vector list
vec2D = {'driftspd';'windspd';'peakwaveperiod'};
vec2Ddir = {'driftdirT';'windspd';'peakwaveperiod'};


for i=1:numel(numericArrayFields)
    
    for f = 1:numel([SWIFT.(numericArrayFields{i})]) % ensure every row has nan or value
        if isempty(SWIFT(f).(numericArrayFields{i}))
            SWIFT(f).(numericArrayFields{i}) = NaN;
        end
    end


    if contains(numericArrayFields(i),'std')
        [SWIFT.(numericArrayFields{i})] = deal(nan); % remove std statistics that are no longer valid. 
        continue;
    elseif strcmp(numericArrayFields(i), vec2D) % directional vectors
        idx = strcmp(numericArrayFields(i), vec2D);
        x = [SWIFT.(numericArrayFields{i})].*sind([SWIFT.(vec2Ddir{idx})]);
        y = [SWIFT.(numericArrayFields{i})].*cosd([SWIFT.(vec2Ddir{idx})]);

        x = movmean(x, days(duration_dt),'omitnan','SamplePoints',datetime([SWIFT.time],'ConvertFrom','datenum'));
        y = movmean(y, days(duration_dt),'omitnan','SamplePoints',datetime([SWIFT.time],'ConvertFrom','datenum'));

        temp = num2cell(sqrt(x.^2 + y.^2));
        [SWIFT.(numericArrayFields{i})] = deal(temp{:}); clear temp;
        temp = num2cell(atan2d(x,y));
        [SWIFT.(vec2Ddir{idx})] = deal(temp{:}); clear temp;

        clear x y idx;
    else
        try 
            temp = num2cell(movmean([SWIFT.(numericArrayFields{i})], duration_dt,'SamplePoints',[SWIFT.time]));
            [SWIFT.(numericArrayFields{i})] = deal(temp{:}); clear temp;
        catch me
            warning('Issue in:');
            disp(numericArrayFields{i});
            disp(me);
        end
    end
end
