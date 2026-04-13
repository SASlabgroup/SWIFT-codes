function missing = checkRequiredToolboxes(toolboxes, logFcn)
% CHECKREQUIREDTOOLBOXES  Verify required MATLAB toolboxes are licensed.
%
%   missing = checkRequiredToolboxes(toolboxes)
%   missing = checkRequiredToolboxes(toolboxes, logFcn)
%
% Inputs:
%   toolboxes - Nx3 cell array of {licenseFeature, displayName, url}.
%               licenseFeature is the string passed to license('test', ...).
%               Common values:
%                 'MAP_Toolbox'         - Mapping Toolbox
%                 'Fixed_Point_Toolbox' - Fixed-Point Designer
%                 'Signal_Toolbox'      - Signal Processing Toolbox
%                 'Statistics_Toolbox'  - Statistics & Machine Learning
%   logFcn    - (optional) function handle called as logFcn(msg, 'error')
%               for each missing toolbox. If omitted, missing toolboxes
%               are printed with warning().
%
% Output:
%   missing   - Nx3 cell array (subset of `toolboxes`) that are not licensed.

if nargin < 2, logFcn = []; end

missing = cell(0, 3);
for ii = 1:size(toolboxes, 1)
    feature  = toolboxes{ii, 1};
    dispName = toolboxes{ii, 2};
    url      = toolboxes{ii, 3};
    if ~license('test', feature)
        missing(end+1, :) = toolboxes(ii, :); %#ok<AGROW>
        msg = sprintf('MISSING toolbox: %s — install from %s', dispName, url);
        if ~isempty(logFcn)
            logFcn(msg, 'error');
        else
            warning('checkRequiredToolboxes:missing', '%s', msg);
        end
    end
end
end
