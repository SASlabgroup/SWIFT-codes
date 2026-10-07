function [flatSWIFT, skippedPaths] = flattenSWIFT(SWIFT)
% Flatten a SWIFT struct array into a struct tree of [n x nTimes] arrays
%
%   [flatSWIFT, skippedPaths] = flattenSWIFT(SWIFT)
%
% flatSWIFT mirrors the SWIFT struct tree, with one column per burst:
%   numeric/logical vectors -> [n x nTimes] double, NaN where missing;
%                              vectors of different length are NaN-padded
%                              to the longest (reported in one warning)
%   text (ID, date, ...)    -> [1 x nTimes] string, <missing> where
%                              absent/NaN
% Fields are the union over all bursts, so substructs may differ by burst.
%
% Fields that are anything else (cell, matrix, struct array) or contain no
% data at all are left out; their dotted paths are returned in skippedPaths.
%
% Pure reshaping: no renaming, unit changes or derived quantities
%
% Oct 2026 by M. LeClair (using claude), based on catSWIFT

% One struct per burst, as a cell, so each level of the tree is handled the
% same way
[flatSWIFT, skippedPaths, raggedFields] = flattenLevel(num2cell(SWIFT(:)'), '');

if ~isempty(raggedFields)
    warnRagged(raggedFields);
end
end


function [flatLevel, skippedPaths, raggedFields] = flattenLevel(burstStructs, path)
% Flatten one level of the tree, calling itself for each substruct.
%   burstStructs  1 x nTimes cell: the struct at this level in each burst
%                 ([] if the burst does not have it)
%   path          dotted path of this level, e.g. 'signature.profile.'
%   flatLevel     flattened struct for this level
%   skippedPaths  dotted paths of fields left out
%   raggedFields  rows of {path, fieldName, lengths} for NaN-padded fields

nTimes = numel(burstStructs);
flatLevel = struct();
skippedPaths = {};
raggedFields = cell(0, 3);

% Union of field names over all bursts, in order of first appearance
% (cellfun applies a function to each cell, e.g. fieldnames)
isStructBurst = cellfun(@isstruct, burstStructs);
burstFieldNames = cellfun(@fieldnames, burstStructs(isStructBurst), 'UniformOutput', false);
fieldNames = unique(vertcat(burstFieldNames{:}), 'stable');

% Usually every burst has all the fields; then one struct array gives
% each field's values in one step, as {burstArray.(fieldName)}
haveSameFields = all(cellfun(@isSubstruct, burstStructs)) && ...
    all(cellfun(@numel, burstFieldNames) == numel(fieldNames));
if haveSameFields
    burstArray = [burstStructs{:}];
end

for fieldIndex = 1:numel(fieldNames)
    fieldName = fieldNames{fieldIndex};
    fieldPath = [path fieldName];

    % This field's value in each burst ([] where missing)
    if haveSameFields
        burstValues = {burstArray.(fieldName)};
    else
        burstValues = cell(1, nTimes);
        for burstIndex = 1:nTimes
            if isstruct(burstStructs{burstIndex}) && isfield(burstStructs{burstIndex}, fieldName)
                burstValues{burstIndex} = burstStructs{burstIndex}.(fieldName);
            end
        end
    end

    % Decide the field type from the bursts that have it
    presentValues = burstValues(~cellfun(@isempty, burstValues));

    if allAre(presentValues, @isSubstruct)
        % Substruct: recurse, keep it only if something survived
        [subLevel, subSkippedPaths, subRaggedFields] = flattenLevel(burstValues, [fieldPath '.']);
        if ~isempty(fieldnames(subLevel))
            flatLevel.(fieldName) = subLevel;
        end
        skippedPaths = [skippedPaths subSkippedPaths];
        raggedFields = [raggedFields; subRaggedFields];

    elseif allAre(presentValues, @isNumericVector)
        % Numeric vectors: one column per burst, NaN-padded to the longest
        lengths = cellfun(@numel, burstValues);
        columns = NaN(max([lengths 1]), nTimes); % at least one row
        for burstIndex = find(lengths > 0)
            columns(1:lengths(burstIndex), burstIndex) = double(burstValues{burstIndex}(:));
        end

        if all(isnan(columns(:)))
            skippedPaths{end+1} = fieldPath;
        else
            flatLevel.(fieldName) = columns;
            distinctLengths = unique(lengths(lengths > 0));
            if numel(distinctLengths) > 1
                raggedFields(end+1, :) = {path, fieldName, mat2str(distinctLengths)};
            end
        end

    elseif allAre(presentValues, @isTextOrNaN) && any(cellfun(@isText, presentValues))
        % Text (NaN counts as missing): one string per burst
        textValues = strings(1, nTimes);
        textValues(:) = missing;
        for burstIndex = find(cellfun(@isText, burstValues))
            textValues(burstIndex) = string(burstValues{burstIndex});
        end
        flatLevel.(fieldName) = textValues;

    else
        % Other types, or no data in any burst
        skippedPaths{end+1} = fieldPath;
    end
end
end


function warnRagged(raggedFields)
% One warning listing all NaN-padded fields. Fields in the same substruct
% with the same lengths share a line, e.g.
%   signature.profile.{east,north,up}: lengths [40 42]
groupKey = strcat(raggedFields(:, 1), raggedFields(:, 3)); % path + lengths
[~, firstRow, group] = unique(groupKey, 'stable');

lines = cell(size(firstRow));
for groupIndex = 1:numel(firstRow)
    path = raggedFields{firstRow(groupIndex), 1};
    lengths = raggedFields{firstRow(groupIndex), 3};
    fieldNames = strjoin(raggedFields(group == groupIndex, 2), ',');
    lines{groupIndex} = sprintf('  %s{%s}: lengths %s', path, fieldNames, lengths);
end

% Hide the stack trace so the warning is just the list
backtrace = warning('off', 'backtrace');
warning('flattenSWIFT:ragged', 'NaN-padded fields with varying lengths:\n%s', ...
    strjoin(lines, newline));
warning(backtrace);
end


function tf = allAre(values, test)
% true if values is non-empty and test(value) is true for every cell.
% Testing the first value alone rules out the wrong type without a pass
% over every burst.
tf = ~isempty(values) && test(values{1}) && all(cellfun(test, values));
end


function tf = isSubstruct(value)
tf = isstruct(value) && isscalar(value);
end


function tf = isNumericVector(value)
tf = (isnumeric(value) || islogical(value)) && isvector(value);
end


function tf = isText(value)
tf = (ischar(value) && isrow(value)) || (isstring(value) && isscalar(value));
end


function tf = isTextOrNaN(value)
% text, or a NaN placeholder for missing text (e.g. date = NaN)
tf = isText(value) || (isnumeric(value) && isscalar(value) && isnan(value));
end
