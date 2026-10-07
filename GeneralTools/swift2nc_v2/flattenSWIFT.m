function [F, skipped] = flattenSWIFT(SWIFT)
% Flatten a SWIFT struct array into a struct tree of [n x nt] arrays
%
%   [F, skipped] = flattenSWIFT(SWIFT)
%
% F mirrors the SWIFT struct tree, with one column per burst:
%   numeric/logical vectors -> [n x nt] double, NaN where missing; vectors
%                              of different length are NaN-padded to the
%                              longest (reported in one warning)
%   text (ID, date, ...)    -> [1 x nt] string, <missing> where absent/NaN
% Fields are the union over all bursts, so substructs may differ by burst.
%
% Fields that are anything else (cell, matrix, struct array) or contain no
% data at all are left out; their dotted paths are returned in skipped.
%
% Pure reshaping: no renaming, unit changes or derived quantities
%
% Oct 2026 by M. LeClair (mleclair) Based on catSWIFT

    % One cell per burst, so each level of the tree is handled the same way
    [F, skipped, ragged] = flattenLevel(num2cell(SWIFT(:)'), '');

    if ~isempty(ragged)
        warnRagged(ragged);
    end
end


function [F, skipped, ragged] = flattenLevel(bursts, prefix)
    % Flatten one level of the tree.
    %   bursts   1 x nt cell: the struct at this level in each burst ([] if absent)
    %   prefix   dotted path of this level, e.g. 'signature.profile.'
    %   F        flattened struct for this level
    %   skipped  dotted paths of fields left out
    %   ragged   rows of {prefix, fieldname, lengths} for NaN-padded fields

    nt = numel(bursts);
    F = struct();
    skipped = {};
    ragged = cell(0, 3);

    % Union of field names over all bursts
    names = {};
    for it = 1:nt
        if isstruct(bursts{it})
            names = union(names, fieldnames(bursts{it}), 'stable');
        end
    end

    for k = 1:numel(names)
        name = names{k};
        path = [prefix name];

        % This field's value in each burst ([] where missing)
        values = cell(1, nt);
        for it = 1:nt
            if isstruct(bursts{it}) && isfield(bursts{it}, name)
                values{it} = bursts{it}.(name);
            end
        end

        % Decide the field type from the bursts that have it
        % (cellfun applies a function to each cell, e.g. isempty)
        present = values(~cellfun(@isempty, values));

        if allAre(present, @isSubstruct)
            % Substruct: recurse, keep it only if something survived
            [child, childSkipped, childRagged] = flattenLevel(values, [path '.']);
            if ~isempty(fieldnames(child))
                F.(name) = child;
            end
            skipped = [skipped childSkipped];
            ragged = [ragged; childRagged];

        elseif allAre(present, @isNumericVector)
            % Numeric vectors: one column per burst, NaN-padded to the longest
            lengths = cellfun(@numel, values);
            columns = NaN(max([lengths 1]), nt); % at least one row
            for it = find(lengths > 0)
                columns(1:lengths(it), it) = double(values{it}(:));
            end

            if all(isnan(columns(:)))
                skipped{end+1} = path;
            else
                F.(name) = columns;
                distinctLengths = unique(lengths(lengths > 0));
                if numel(distinctLengths) > 1
                    ragged(end+1, :) = {prefix, name, mat2str(distinctLengths)};
                end
            end

        elseif allAre(present, @isTextOrNaN) && any(cellfun(@isText, present))
            % Text (NaN counts as missing): one string per burst
            text = strings(1, nt);
            text(:) = missing;
            for it = find(cellfun(@isText, values))
                text(it) = string(values{it});
            end
            F.(name) = text;

        else
            % Other types, or no data in any burst
            skipped{end+1} = path;
        end
    end
end


function warnRagged(ragged)
    % One warning listing all NaN-padded fields. Fields in the same substruct
    % with the same lengths share a line, e.g.
    %   signature.profile.{east,north,up}: lengths [40 42]
    groupKey = strcat(ragged(:, 1), ragged(:, 3)); % prefix + lengths
    [~, firstRow, group] = unique(groupKey, 'stable');

    lines = cell(size(firstRow));
    for k = 1:numel(firstRow)
        prefix = ragged{firstRow(k), 1};
        lengths = ragged{firstRow(k), 3};
        names = strjoin(ragged(group == k, 2), ',');
        lines{k} = sprintf('  %s{%s}: lengths %s', prefix, names, lengths);
    end

    % Hide the stack trace so the warning is just the list
    backtrace = warning('off', 'backtrace');
    warning('flattenSWIFT:ragged', 'NaN-padded fields with varying lengths:\n%s', ...
        strjoin(lines, newline));
    warning(backtrace);
end


function tf = allAre(values, test)
    % true if values is non-empty and test(v) is true for every cell
    tf = ~isempty(values) && all(cellfun(test, values));
end


function tf = isSubstruct(v)
    tf = isstruct(v) && isscalar(v);
end


function tf = isNumericVector(v)
    tf = (isnumeric(v) || islogical(v)) && isvector(v);
end


function tf = isText(v)
    tf = (ischar(v) && isrow(v)) || (isstring(v) && isscalar(v));
end


function tf = isTextOrNaN(v)
    % text, or a NaN placeholder for missing text (e.g. date = NaN)
    tf = isText(v) || (isnumeric(v) && isscalar(v) && isnan(v));
end
