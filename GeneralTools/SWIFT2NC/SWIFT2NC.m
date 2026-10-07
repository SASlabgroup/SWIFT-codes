function SWIFT2NC(SWIFT, filename, opts)
% Write a SWIFT struct array to a NETCDF4 file described by SWIFT_nc_variables
%
%   SWIFT2NC(SWIFT, filename)
%   SWIFT2NC(SWIFT, filename, platform='micro', overrides=ov)
%
% Writes the layout of the old SWIFT2NC, for existing readers: no groups,
% the old variable and dimension names (definition name and dim, default
% the SWIFT field name) and time in days since 1970 (time.timeUnits).
%
% Only fields defined in SWIFT_nc_variables are written (others are listed in
% a warning). Substruct fields (e.g. signature.profile.east) are written
% next to the others. Coordinates (z, freq, echoz) define dimensions, and
% fields with several values per burst are written on the dimension their
% dim names (see SWIFT_nc_variables). Text fields that are the same in every
% burst (e.g. ID) become global attributes. Data with both uplooking and
% downlooking is an error (both z would be named z). A preProcessData
% function (e.g. clipping wavespectra) is applied to its field before
% writing.
%
% platform is v3, v4 or micro; by default it is detected from SWIFT(1).ID.
%
% overrides changes the definitions for this file, field by field. It has
% the same parts as SWIFT_nc_variables's outputs, all optional:
%   ov.platform.met = 'Airmar PB200';                  % placeholder values
%   ov.vars.airtemp.comment = 'sensor in sun shield';  % variable attributes
%   ov.vars.signature.profile.east.name = 'u_rel';     % (nested like S)
%   ov.globals.project = 'Willapa Bay 2025';           % global attributes
%
% Simpler replacement for the old SWIFT2NC, see flattenSWIFT for the reshaping.
%
% Oct 2026 by M. LeClair (using claude), based on the old SWIFT2NC

% Input checking; opts.* are the optional name=value arguments
arguments
    SWIFT struct
    filename {mustBeTextScalar}
    opts.platform {mustBeMember(opts.platform, ["auto" "v3" "v4" "micro"])} = "auto"
    opts.overrides struct = struct()
end

% One struct with each field stacked over bursts (time along the last dimension)
[flatSWIFT, skippedPaths] = flattenSWIFT(SWIFT);
if isfield(flatSWIFT, 'uplooking') && isfield(flatSWIFT, 'downlooking')
    % Both z would be written as z (no groups), which netCDF does not allow
    error('SWIFT2NC:upDown', ['SWIFT has both uplooking and downlooking data, ' ...
        'whose z would both be named z; remove one before writing']);
end
[variableDefinitions, platforms, globalAttributes] = SWIFT_nc_variables();

platform = opts.platform;
if platform == "auto"
    platform = detectPlatform(flatSWIFT.ID(1));
end

% Text substituted for {key} placeholders in attribute values, e.g. {id}
placeholders = platforms.(platform);
placeholders.id = char(flatSWIFT.ID(1));
% Sensor height/depth phrases, only when the data has the height. Every
% distinct value is listed, e.g. ' at 0.18, 0.66, 1.22 m depth' for three CTs
placeholders.at_ct_depth = '';
placeholders.at_met_height = '';
if isfield(flatSWIFT, 'CTdepth')
    placeholders.at_ct_depth = sprintf(' at %s m depth', listValues(flatSWIFT.CTdepth));
end
if isfield(flatSWIFT, 'metheight')
    placeholders.at_met_height = sprintf(' at %s m height above the wave-following surface', ...
        listValues(flatSWIFT.metheight));
end

% User overrides are applied last, so they win over the definitions and the data
overrides = opts.overrides;
unknownParts = setdiff(fieldnames(overrides), {'platform', 'vars', 'globals'});
if ~isempty(unknownParts)
    error('SWIFT2NC:overrides', 'Unknown overrides field(s): %s (use platform, vars, globals)', ...
        strjoin(unknownParts, ', '));
end
merged = mergeStructs(struct('platform', placeholders, 'vars', variableDefinitions, 'globals', globalAttributes), overrides);
placeholders = merged.platform;
variableDefinitions = merged.vars;
globalAttributes = merged.globals;

% MATLAB datenum (days) -> whole seconds or days since 1970 (time.timeUnits)
timeUnits = variableDefinitions.time.timeUnits;
flatSWIFT.time = flatSWIFT.time - datenum(1970, 1, 1);
if strcmp(timeUnits, 'seconds')
    flatSWIFT.time = round(flatSWIFT.time * 86400); % whole seconds, drops datenum round-off
elseif ~strcmp(timeUnits, 'days')
    error('SWIFT2NC:timeUnits', 'time.timeUnits must be seconds or days, not %s', timeUnits);
end
variableDefinitions.time.units = [timeUnits ' since 1970-01-01 00:00:00'];

% Create the file (CLOBBER = overwrite if it exists). onCleanup closes it
% when this function exits, even on an error.
ncFile = netcdf.create(filename, bitor(netcdf.getConstant('NETCDF4'), netcdf.getConstant('CLOBBER')));
closeFile = onCleanup(@() netcdf.close(ncFile));

% Global attributes
ncGlobal = netcdf.getConstant('NC_GLOBAL');
putAttributes(ncFile, ncGlobal, globalAttributes, placeholders);
netcdf.putAtt(ncFile, ncGlobal, 'platform', char(platform));
netcdf.putAtt(ncFile, ncGlobal, 'date_created', ...
    char(datetime('now', 'TimeZone', 'UTC', 'Format', 'yyyy-MM-dd''T''HH:mm:ss''Z''')));

timeDimId = netcdf.defDim(ncFile, 'time', numel(flatSWIFT.time));
auxCoordNames = containers.Map(); % dimension name -> coordinate that varies per burst
[notDefined, notWritten] = writeNCVariables(ncFile, '', variableDefinitions, flatSWIFT, ...
    timeDimId, placeholders, auxCoordNames);

if ~isempty(notDefined)
    warnNoTrace('SWIFT2NC:notDefined', 'Not defined in SWIFT_nc_variables, not written: %s', ...
        strjoin(notDefined, ', '));
end

% Defined fields that were not written: either skipped by flattenSWIFT
% (all NaN in every burst, or not a vector), or not in this SWIFT struct at
% all (e.g. v3-only sensors on a v4)
skipped = notWritten(cellfun(@(p) wasSkipped(p, skippedPaths), notWritten));
notInData = setdiff(notWritten, skipped, 'stable');
if ~isempty(skipped)
    warnNoTrace('SWIFT2NC:skipped', 'Defined in SWIFT_nc_variables but all NaN or not a vector, not written: %s', ...
        strjoin(skipped, ', '));
end
if ~isempty(notInData)
    warnNoTrace('SWIFT2NC:notInData', 'Defined in SWIFT_nc_variables but not in the data, not written: %s', ...
        strjoin(notInData, ', '));
end
end


function [notDefined, notWritten] = writeNCVariables(ncFile, path, variableDefinitions, flatSWIFT, ...
    timeDimId, placeholders, auxCoordNames)
% Define and write the netCDF variables of one level of the SWIFT struct
% tree. variableDefinitions and flatSWIFT are the same level of the two
% trees, so their field names match: at the top level (path '') they are
% the whole of SWIFT_nc_variables' S and of flatSWIFT, with leaves like
% airtemp and substructs like signature. A substruct is written by calling
% this function again one level down, e.g. for signature:
%   writeNCVariables(..., 'signature.', S.signature, flatSWIFT.signature, ...)
% which in turn calls it for signature.profile, whose leaves (z, east, ...)
% are written as netCDF variables (z, east, ...). The file has no groups,
% so every level writes into the same flat file, and path is only used to
% name fields in messages. NETCDF4 files allow writing data between
% definitions, so each variable is defined and written in one go.
%   ncFile        the file
%   path          this level's position in the tree, e.g. 'signature.profile.'
%   variableDefinitions  this level of SWIFT_nc_variables: one field per
%                 field of flatSWIFT, holding its attributes and settings
%                 (e.g. .name, .dim, .preProcessData)
%   flatSWIFT     this level of the flattened SWIFT struct (flattenSWIFT)
%   auxCoordNames containers.Map (a handle, shared by all levels) from a
%                 dimension name to the coordinate on it that varies per
%                 burst, for the CF coordinates attribute
% Returns notDefined, the paths of fields in flatSWIFT that are not
% defined, and notWritten, the paths of defined fields that flatSWIFT does
% not have, both collected from all the levels below too.

fieldNames = setdiff(fieldnames(variableDefinitions), {'preProcessData'}, 'stable'); % a setting of this level
notDefined = strcat(path, setdiff(fieldnames(flatSWIFT), fieldNames))';
notWritten = {};

% Define coordinates first, so their dimensions exist for the data fields
isCoordField = cellfun(@(n) isCoord(variableDefinitions.(n)), fieldNames);
fieldNames = [fieldNames(isCoordField); fieldNames(~isCoordField)];

for fieldIndex = 1:numel(fieldNames)
    fieldName = fieldNames{fieldIndex};
    variableDefinition = variableDefinitions.(fieldName);
    if ~isfield(flatSWIFT, fieldName) % not in this data set, or no data
        notWritten{end+1} = [path fieldName];
        continue
    end
    values = flatSWIFT.(fieldName);

    % preProcessData function, if defined: validates, reshapes or trims the
    % field before it is written, e.g. checking air pressure is in mbar or
    % clipping wavespectra to nbins frequencies. [] leaves the field out.
    if isfield(variableDefinition, 'preProcessData')
        values = variableDefinition.preProcessData(values, variableDefinition);
        if isempty(values)
            continue
        end
    end

    % Substruct: recurse one level down (e.g. signature, then
    % signature.profile) to write the data at each leaf (e.g.
    % signature.profile.east, written as east)
    if isstruct(values)
        [subNotDefined, subNotWritten] = writeNCVariables(ncFile, [path fieldName '.'], variableDefinition, values, ...
            timeDimId, placeholders, auxCoordNames);
        notDefined = [notDefined subNotDefined];
        notWritten = [notWritten subNotWritten];
        continue
    end

    % netCDF name defaults to the SWIFT field name
    ncName = fieldName;
    if isfield(variableDefinition, 'name')
        ncName = variableDefinition.name;
    end

    % Everything in variableDefinition except the settings is written as an
    % attribute. The settings are listed in SWIFT_nc_variables' header
    % (keep the two lists the same)
    variableAttributes = rmfield(variableDefinition, intersect(fieldnames(variableDefinition), ...
        {'name', 'dim', 'coordinate', 'preProcessData', 'nbins', 'timeUnits'}));
    nPerBurst = size(values, 1); % values is [nPerBurst x nTimes]

    if isstring(values) && all(values == values(1))
        % Same text in every burst (e.g. ID) -> global attribute
        netcdf.putAtt(ncFile, netcdf.getConstant('NC_GLOBAL'), ncName, char(values(1)));
        continue
    elseif isstring(values)
        varId = netcdf.defVar(ncFile, ncName, 'NC_STRING', timeDimId);
        values = fillmissing(values, 'constant', "");
    elseif nPerBurst == 1
        % One value per burst -> (time)
        varId = netcdf.defVar(ncFile, ncName, 'NC_DOUBLE', timeDimId);
    elseif isCoord(variableDefinition)
        % Coordinate: defines a dimension, named by its dim or else its
        % netCDF name. Normally each row (e.g. each z bin) has the same value
        % in every burst, ignoring NaN, and it is written once on its
        % dimension; if not, it is written per burst, on a <name>_index
        % dimension unless dim names one, and data fields on that dimension
        % name it in their CF coordinates attribute.
        binValues = max(values, [], 2, 'omitnan');
        isSameEveryBurst = all(values == binValues | isnan(values), 'all');
        dimName = ncName;
        if ~isSameEveryBurst
            dimName = [ncName '_index'];
        end
        if isfield(variableDefinition, 'dim')
            dimName = variableDefinition.dim;
        end
        dimId = netcdf.defDim(ncFile, dimName, nPerBurst);
        if isSameEveryBurst
            varId = netcdf.defVar(ncFile, ncName, 'NC_DOUBLE', dimId);
            values = binValues;
            % CF: a 1-D coordinate is strictly monotonic, with no missing values
            if ~(all(diff(values) > 0) || all(diff(values) < 0))
                warnNoTrace('SWIFT2NC:monotonic', '%s%s is not strictly monotonic (or has NaN), not a valid CF coordinate', ...
                    path, fieldName);
            end
        else
            warnNoTrace('SWIFT2NC:coord', '%s%s varies between bursts, written as (time, %s)', ...
                path, fieldName, dimName);
            varId = netcdf.defVar(ncFile, ncName, 'NC_DOUBLE', [dimId timeDimId]);
            auxCoordNames(dimName) = ncName;
        end
    elseif isfield(variableDefinition, 'dim')
        % Data field with several values per burst -> (time, dim), on a
        % coordinate's dimension (e.g. east on z) or one shared by every
        % field that names it (e.g. obs_sample). If the coordinate on it
        % varies per burst (echoz), name it so readers attach it.
        dimId = sharedDim(ncFile, variableDefinition.dim, nPerBurst);
        if isKey(auxCoordNames, variableDefinition.dim)
            variableAttributes.coordinates = auxCoordNames(variableDefinition.dim);
        end
        varId = netcdf.defVar(ncFile, ncName, 'NC_DOUBLE', [dimId timeDimId]);
    else
        % Several values per burst and no dim -> a dimension of its own
        % (e.g. watertemp from several CTs -> sea_water_temperature_n)
        dimId = netcdf.defDim(ncFile, [ncName '_n'], nPerBurst);
        varId = netcdf.defVar(ncFile, ncName, 'NC_DOUBLE', [dimId timeDimId]);
    end

    if isnumeric(values)
        netcdf.defVarDeflate(ncFile, varId, true, true, 4); % compression level 4
    end
    if isfloat(values) && ~isCoord(variableDefinition)
        netcdf.defVarFill(ncFile, varId, false, NaN); % missing = NaN; CF: no fill on coordinates
    end
    putAttributes(ncFile, varId, variableAttributes, placeholders);
    netcdf.putVar(ncFile, varId, values);
end
end


function dimId = sharedDim(ncFile, dimName, dimLength)
% Dimension dimName of length dimLength: a coordinate's, or else defined by
% the first field that names it
try
    dimId = netcdf.inqDimID(ncFile, dimName);
catch
    dimId = netcdf.defDim(ncFile, dimName, dimLength);
end
[~, existingLength] = netcdf.inqDim(ncFile, dimId);
if existingLength ~= dimLength
    error('SWIFT2NC:dim', 'dimension %s has length %d, not %d', dimName, existingLength, dimLength);
end
end


function tf = wasSkipped(path, skippedPaths)
% True if flattenSWIFT left out path (or everything under it): no data, or
% not a vector
tf = any(strcmp(skippedPaths, path) | startsWith(skippedPaths, [path '.']));
end


function text = listValues(values)
% Distinct values, ignoring NaN, as text: '0.66' or '0.18, 0.66, 1.22'
text = strjoin(compose("%g", unique(values(~isnan(values)))'), ", ");
end


function tf = isCoord(variableDefinition)
% The definition marks the field as a coordinate (time, z, freq, echoz)
tf = isfield(variableDefinition, 'coordinate') && variableDefinition.coordinate;
end


function warnNoTrace(varargin)
% warning() without the "In ... at line ..." stack trace
backtrace = warning('off', 'backtrace');
warning(varargin{:});
warning(backtrace);
end


function putAttributes(ncFile, varId, attributes, placeholders)
% Write each field of attributes as an attribute, replacing {key} with
% placeholders.key; skip attributes that end up empty
attributeNames = fieldnames(attributes);
placeholderKeys = fieldnames(placeholders);
for attributeIndex = 1:numel(attributeNames)
    attributeName = attributeNames{attributeIndex};
    attributeValue = attributes.(attributeName);
    if ischar(attributeValue)
        for keyIndex = 1:numel(placeholderKeys)
            key = placeholderKeys{keyIndex};
            attributeValue = strrep(attributeValue, ['{' key '}'], placeholders.(key));
        end
    end
    if ~isempty(attributeValue)
        netcdf.putAtt(ncFile, varId, attributeName, attributeValue);
    end
end
end


function base = mergeStructs(base, overrides)
% Copy every field of overrides into base, recursing where both have a
% substruct, so only the fields given in overrides change
fieldNames = fieldnames(overrides);
for fieldIndex = 1:numel(fieldNames)
    fieldName = fieldNames{fieldIndex};
    if isfield(base, fieldName) && isstruct(base.(fieldName)) && isstruct(overrides.(fieldName))
        base.(fieldName) = mergeStructs(base.(fieldName), overrides.(fieldName));
    else
        base.(fieldName) = overrides.(fieldName);
    end
end
end


function platform = detectPlatform(id)
% microSWIFT IDs have 3 digits; SWIFTs below 18 are v3, the rest v4
id = erase(id, ["SWIFT" " "]);
if strlength(id) == 3
    platform = "micro";
elseif str2double(id) < 18
    platform = "v3";
else
    platform = "v4";
end
end
