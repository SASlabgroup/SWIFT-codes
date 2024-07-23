function [SWIFT,outliersSWIFT,booloutSWIFT] = findoutliersSWIFT(SWIFT, method, pct,varargin)
% findoutliersSWIFT - finds outliers out of % range and plots hist of all
% SWIFT fields
% Find outliers in SWIFT L1 DATA    
% Michael James
% 7_12_2024
% findoutliersSWIFT(SWIFT, method, pctdatathresh,varargin)
% method == 
%       defined as "percentile" or "movmedian" (moving percentile)
% pct == 
%       defined as percent used in percentile method, write as "~" or leave blank for
%       movmedian
% varargin defined as string / value dictionary pairs. List below:
%       'plot_results' ; true/false bool
%       'window' ; float (this is a window for "movmedian")
% 7_23_2024
% Scoped down to per SWIFT variable so can be run in created loop
% determined by user
% Added boolean output for ease of indexing


% Preset binary flags
vararginlist = ["plot_results" ; "window"];
plot_results = true; %default create figures
window = 40; % Window size of 100 values as default

% Check if there are any optional arguments
if ~isempty(varargin)
    if mod(length(varargin),2) == 0 %check for pairs
        for i= 1:2:length(varargin)
            if mean(contains(string(vararginlist),char(varargin{i}))) ~=0
                eval([char(vararginlist(contains(string(vararginlist),varargin{i}))) ' = varargin{i+1};']);
                % taking the name and setting the variable to be the user
                % input
            else
                error('Check naming of the variable arguements')                
            end
        end;
    else
        error('incorrect variable arguements; must be in pairs')
    end;
elseif isempty(varargin)
    % Do nothing
else
    error('Input error'); help findoutliersSWIFT;
end


if mean(contains(["percentile" ; "movmedian"],char(method))) ==0
    error('use "percentile" or "movmedian" to define the method');
end


if string(method) == "percentile" 
    if 0<pct<100
        error("Percent should be 0<pct<100")
    end
end

fields = fieldnames(SWIFT);

% % Dummy table
% emptyfields = num2cell(nan(1, length(fields)));
% emptytbl = cell2table(emptyfields, fields);
% 
% % Create a 1xlength(swift) structure array with all fields
% outliersSWIFT = repmat(emptytbl, 1, length(SWIFT));

for q = 1:length(fields)
    if string(class([SWIFT(1).(fields{q})])) == "double" & string(fields{q}) ~="time"
        if string(method) == "percentile";       
            booloutSWIFTstruct.(fields{q}) = isoutlier([SWIFT.(fields{q})].', "percentiles", [50-pct/2 50+pct/2]);
        elseif string(method) == "movmedian";
            booloutSWIFTstruct.(fields{q}) = isoutlier([SWIFT.(fields{q})].', "movmedian", window);
        else
            error('Define method as percentile or movmedian')
        end
        for k = 1:length(SWIFT)
            booloutSWIFT(k).time = SWIFT(k).time;
            booloutSWIFT(k).(fields{q}) = booloutSWIFTstruct.(fields{q})(k);
            if booloutSWIFTstruct.(fields{q})(k) == 1;
                outliersSWIFT(k).time = SWIFT(k).time;
                outliersSWIFT(k).(fields{q}) = SWIFT(k).(fields{q});
            end
        end
        
    end;
end;
end