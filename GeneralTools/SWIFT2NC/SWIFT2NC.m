function SWIFT2NC(SWIFT, filename, opts)
% Write a SWIFT struct array to a NETCDF4 file, as SWIFT_nc_variables defines it
%
%   SWIFT2NC(SWIFT, filename)
%   SWIFT2NC(SWIFT, filename, platform='micro', overrides=ov)
%
% Write the old SWIFT2NC's layout for existing readers (no groups, its variable names, time in days since 1970),
% in the CF-1.8 dimension order. Write only fields defined in SWIFT_nc_variables; its header describes the
% definitions, dims and {key} placeholders. Put wave spectra on one frequency grid first (normalizeWavespectra),
% then stack each field over bursts (flattenSWIFT).
%
% platform   v3, v4 or micro; by default detected from SWIFT(1).ID
% overrides  change the definitions for this file, with the parts of SWIFT_nc_variables' outputs:
%   ov.platform.met = 'Airmar PB200';                  % placeholder values
%   ov.vars.airtemp.comment = 'sensor in sun shield';  % variable attributes (nested like S)
%   ov.globals.project = 'Willapa Bay 2025';           % global attributes
%
% Errors on: both uplooking and downlooking (both z would be named z), text that varies between bursts, a field
% with several values per burst but no dims, and time or a 1-D coordinate with NaN, not strictly monotonic or
% (1-D coordinate) varying between bursts.
%
% Oct 2026 by M. LeClair (using claude), based on the old SWIFT2NC
%
% Changelog:
%   2026-11-19 M. LeClair w/ claude: initial version, replaces the old SWIFT2NC.m: definitions-driven writer in the old layout, CF-1.8 dimension order from dims in SWIFT_nc_variables, per-file overrides

arguments
    SWIFT struct
    filename {mustBeTextScalar}
    opts.platform {mustBeMember(opts.platform, ["auto" "v3" "v4" "micro"])} = "auto"
    opts.overrides struct = struct()
end

% Load the definitions and apply the user's overrides
[variableDefinitions, platforms, globalAttributes, settingNames] = SWIFT_nc_variables();
[variableDefinitions, globalAttributes, platformOverrides] = applyOverrides(opts.overrides, ...
    variableDefinitions, globalAttributes);

% Put the wave spectra on the freq grid
if isfield(SWIFT, 'wavespectra')
    freqDefinition = variableDefinitions.wavespectra.freq;
    SWIFT = normalizeWavespectra(SWIFT, freqDefinition.nbins, freqDefinition.fmin, freqDefinition.df);
end

% Flatten the SWIFT struct array to one [n x nTimes] array per field, check it, convert time
flatSWIFT = flattenSWIFT(SWIFT);
if isfield(flatSWIFT, 'uplooking') && isfield(flatSWIFT, 'downlooking')
    error('SWIFT2NC:upDown', 'SWIFT has both uplooking and downlooking data, whose z would both be named z; remove one');
end
[flatSWIFT.time, variableDefinitions.time.units] = convertTime(flatSWIFT.time, variableDefinitions.time.timeUnits);

% Make the text for the {key} placeholders in attributes
platform = opts.platform;
if platform == "auto"
    platform = detectPlatform(flatSWIFT.ID(1));
end
placeholders = makePlaceholders(platforms.(platform), flatSWIFT, platformOverrides);

% Create the file (CLOBBER overwrites it); onCleanup closes it when this function exits, even on an error
ncFile = netcdf.create(filename, bitor(netcdf.getConstant('NETCDF4'), netcdf.getConstant('CLOBBER')));
closeFile = onCleanup(@() netcdf.close(ncFile));

% Write the global attributes and the time dimension
writeGlobalAttributes(ncFile, globalAttributes, placeholders, platform);
timeDimId = netcdf.defDim(ncFile, 'time', numel(flatSWIFT.time));

% Write the netCDF variables, then warn about the fields not written
[notDefined, notWritten] = writeNCVariables(ncFile, '', variableDefinitions, flatSWIFT, timeDimId, ...
    placeholders, settingNames);

if ~isempty(notDefined)
    warnNoTrace('SWIFT2NC:notDefined', 'Not defined in SWIFT_nc_variables, not written: %s', strjoin(notDefined, ', '));
end
if ~isempty(notWritten)
    warnNoTrace('SWIFT2NC:notWritten', ['Defined in SWIFT_nc_variables but not written (not in the data, ' ...
        'all NaN, or not a vector): %s'], strjoin(notWritten, ', '));
end
end


function [variableDefinitions, globalAttributes, platformOverrides] = applyOverrides(overrides, ...
    variableDefinitions, globalAttributes)
% Apply the user's overrides over the definitions. Return the platform part, to apply over the placeholders after
% those taken from the data.
unknownParts = setdiff(fieldnames(overrides), {'platform', 'vars', 'globals'});
if ~isempty(unknownParts)
    error('SWIFT2NC:overrides', 'Unknown overrides field(s): %s (use platform, vars, globals)', ...
        strjoin(unknownParts, ', '));
end
merged = mergeStructs(struct('platform', struct(), 'vars', variableDefinitions, 'globals', globalAttributes), overrides);
variableDefinitions = merged.vars;
globalAttributes = merged.globals;
platformOverrides = merged.platform;
end


function [time, units] = convertTime(time, timeUnits)
% Check time is a valid CF coordinate, then convert it from MATLAB datenum to days or whole seconds since 1970
validateCoordinates(time, 'time', @(t) string(datetime(t, 'ConvertFrom', 'datenum')));
time = time - datenum(1970, 1, 1);
if strcmp(timeUnits, 'seconds')
    time = round(time * 86400); % whole seconds, drops datenum round-off
elseif ~strcmp(timeUnits, 'days')
    error('SWIFT2NC:timeUnits', 'time.timeUnits must be seconds or days, not %s', timeUnits);
end
units = [timeUnits ' since 1970-01-01 00:00:00'];
end


function placeholders = makePlaceholders(placeholders, flatSWIFT, platformOverrides)
% Add {id} and the sensor height/depth phrases to the platform's placeholder text (e.g. {imu}). The phrases list
% every distinct value (' at 0.18, 0.66, 1.22 m depth'), or are '' without the height. Apply the user's platform
% overrides last, so they win.
placeholders.id = char(flatSWIFT.ID(1));
placeholders.at_ct_depth = '';
placeholders.at_met_height = '';
if isfield(flatSWIFT, 'CTdepth')
    placeholders.at_ct_depth = sprintf(' at %s m depth', listValues(flatSWIFT.CTdepth));
end
if isfield(flatSWIFT, 'metheight')
    placeholders.at_met_height = sprintf(' at %s m height above the wave-following surface', ...
        listValues(flatSWIFT.metheight));
end
placeholders = mergeStructs(placeholders, platformOverrides);
end


function writeGlobalAttributes(ncFile, globalAttributes, placeholders, platform)
% Write the defined global attributes, plus platform, date_created and history
ncGlobal = netcdf.getConstant('NC_GLOBAL');
putAttributes(ncFile, ncGlobal, globalAttributes, placeholders);
netcdf.putAtt(ncFile, ncGlobal, 'platform', char(platform));
dateCreated = char(datetime('now', 'TimeZone', 'UTC', 'Format', 'yyyy-MM-dd''T''HH:mm:ss''Z'''));
netcdf.putAtt(ncFile, ncGlobal, 'date_created', dateCreated);
netcdf.putAtt(ncFile, ncGlobal, 'history', ['Created with SWIFT2NC by ' currentUser()]);
end


function [notDefined, notWritten] = writeNCVariables(ncFile, path, variableDefinitions, flatSWIFT, ...
    timeDimId, placeholders, settingNames)
% Write one level of the SWIFT struct tree, calling this function again for each substruct (signature, then
% signature.profile, ...). variableDefinitions and flatSWIFT are the same level of the two trees. Every level
% writes into the same flat file; path (e.g. 'signature.profile.') only names fields in messages.
%
% Return the paths of data fields that are not defined (notDefined) and of defined fields the data does not have
% (notWritten), from this level and the ones below.

% Leave out preProcessData, a setting of this level, not a field to write
fieldNames = setdiff(fieldnames(variableDefinitions), {'preProcessData'}, 'stable');
notDefined = strcat(path, setdiff(fieldnames(flatSWIFT), fieldNames))';
notWritten = {};

% Put the coordinates first, so their dimensions exist when the other fields are written
isCoordField = cellfun(@(n) isCoord(variableDefinitions.(n)), fieldNames);
fieldNames = [fieldNames(isCoordField); fieldNames(~isCoordField)];

for fieldIndex = 1:numel(fieldNames)
    fieldName = fieldNames{fieldIndex};
    variableDefinition = variableDefinitions.(fieldName);
    if ~isfield(flatSWIFT, fieldName)
        notWritten{end+1} = [path fieldName];
        continue
    end
    values = flatSWIFT.(fieldName);

    % Run preProcessData, if defined, to check or change the field before writing it; [] leaves it out
    if isfield(variableDefinition, 'preProcessData')
        values = variableDefinition.preProcessData(values, variableDefinition);
        if isempty(values)
            continue
        end
    end

    if isstruct(values)
        [subNotDefined, subNotWritten] = writeNCVariables(ncFile, [path fieldName '.'], variableDefinition, ...
            values, timeDimId, placeholders, settingNames);
        notDefined = [notDefined subNotDefined];
        notWritten = [notWritten subNotWritten];
        continue
    end

    ncName = fieldName; % netCDF name defaults to the SWIFT field name
    if isfield(variableDefinition, 'name')
        ncName = variableDefinition.name;
    end
    variableAttributes = rmfield(variableDefinition, intersect(fieldnames(variableDefinition), settingNames));
    nPerBurst = size(values, 1); % values is [nPerBurst x nTimes]

    if isstring(values)
        % Write text that is the same in every burst (e.g. ID) as a global attribute
        if ~all(values == values(1))
            error('SWIFT2NC:text', '%s%s is text that differs between bursts; only text that is the same in every burst (a global attribute) is written', ...
                path, fieldName);
        end
        netcdf.putAtt(ncFile, netcdf.getConstant('NC_GLOBAL'), ncName, char(values(1)));
        continue
    elseif nPerBurst == 1
        % Write one value per burst as (time)
        varId = netcdf.defVar(ncFile, ncName, 'NC_DOUBLE', timeDimId);
    elseif ~isfield(variableDefinition, 'dims')
        % Write a 1-D coordinate once, on a dimension of its netCDF name; each row (e.g. each z bin) must have the
        % same value in every burst, ignoring NaN
        if ~isCoord(variableDefinition)
            error('SWIFT2NC:dims', '%s%s has %d values per burst but no dims in SWIFT_nc_variables', ...
                path, fieldName, nPerBurst);
        elseif ~isSameEveryBurst(values)
            error('SWIFT2NC:coordinateVaries', ['%s%s varies between bursts; give it dims in ' ...
                'SWIFT_nc_variables to write it per burst (as echoz)'], path, fieldName);
        end
        dimId = netcdf.defDim(ncFile, ncName, nPerBurst);
        varId = netcdf.defVar(ncFile, ncName, 'NC_DOUBLE', dimId);
        values = max(values, [], 2, 'omitnan');
        validateCoordinates(values, [path fieldName], @(v) string(sprintf('%g', v)));
    else
        % Write several values per burst on the dimensions dims gives in CDL order (e.g. 'time z', 'freq time'): a
        % coordinate's (east on z), or one shared by the fields that name it (obs_sample)
        dims = variableDefinition.dims;
        dimId = sharedDim(ncFile, char(setdiff(split(string(dims)), "time")), nPerBurst);
        if startsWith(dims, 'time') % MATLAB lists netCDF dimensions in the reverse of the CDL order
            varId = netcdf.defVar(ncFile, ncName, 'NC_DOUBLE', [dimId timeDimId]);
        else
            varId = netcdf.defVar(ncFile, ncName, 'NC_DOUBLE', [timeDimId dimId]);
            values = values.';
        end
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


function validateCoordinates(values, name, valueText)
% Error at the first NaN or break in strict monotonicity (CF-1.8 section 1.2: a coordinate variable has no missing
% values and is strictly monotonic); valueText(value) formats a value for the message.
values = values(:);
if any(isnan(values))
    error('SWIFT2NC:coordinateNaN', '%s has NaN, not a valid CF coordinate; first at index %d', ...
        name, find(isnan(values), 1));
end
if numel(values) < 2
    return
end
steps = sign(diff(values));
badIndex = find(steps == 0 | steps ~= steps(1), 1);
if ~isempty(badIndex)
    error('SWIFT2NC:coordinateOrder', '%s is not strictly monotonic, not a valid CF coordinate; at index %d: %s, then %s', ...
        name, badIndex, valueText(values(badIndex)), valueText(values(badIndex + 1)));
end
end


function tf = isSameEveryBurst(values)
% Return true if each row has the same value in every burst, ignoring NaN
tf = all(values == max(values, [], 2, 'omitnan') | isnan(values), 'all');
end


function dimId = sharedDim(ncFile, dimName, dimLength)
% Return dimension dimName, a coordinate's or one defined by the first field naming it; error if not dimLength long
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


function putAttributes(ncFile, varId, attributes, placeholders)
% Write each field of attributes as an attribute, replacing {key} with placeholders.key; skip attributes that end
% up empty
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
% Copy every field of overrides into base, recursing where both have a substruct, so only the fields given in
% overrides change
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
% Return the platform from the ID: microSWIFT IDs have 3 digits, SWIFTs below 18 are v3, the rest v4
id = erase(id, ["SWIFT" " "]);
if strlength(id) == 3
    platform = "micro";
elseif str2double(id) < 18
    platform = "v3";
else
    platform = "v4";
end
end


function text = listValues(values)
% Return the distinct values, ignoring NaN, as text: '0.66' or '0.18, 0.66, 1.22'
text = strjoin(compose("%g", unique(values(~isnan(values)))'), ", ");
end


function tf = isCoord(variableDefinition)
% Return true if the definition marks the field as a coordinate (time, z, freq, echoz)
tf = isfield(variableDefinition, 'coordinate') && variableDefinition.coordinate;
end


function user = currentUser()
% Return the login name for the history attribute ($USER, or $USERNAME on Windows)
user = getenv('USER');
if isempty(user)
    user = getenv('USERNAME');
end
end


function warnNoTrace(varargin)
% Warn without the "In ... at line ..." stack trace
backtrace = warning('off', 'backtrace');
warning(varargin{:});
warning(backtrace);
end
