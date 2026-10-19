function SWIFT2NC_v2(SWIFT, filename, opts)
% Write a SWIFT struct array to a NETCDF4 file described by SWIFT_nc_schema
%
%   SWIFT2NC_v2(SWIFT, filename)
%   SWIFT2NC_v2(SWIFT, filename, platform='micro', overrides=ov)
%   SWIFT2NC_v2(SWIFT, filename, legacy=true)
%
% Only fields listed in SWIFT_nc_schema are written (others are listed in
% a warning). Substructs become groups (e.g. /signature/profile) that share
% the root time dimension. z, freq and echoz are coordinates: the second
% dimension of same-length fields in their group. Text fields that are the
% same in every burst (e.g. ID) become global attributes.
%
% platform is v3, v4 or micro; by default it is detected from SWIFT(1).ID.
%
% legacy=true writes the layout of the old SWIFT2NC for existing readers:
% no groups, the old variable and dimension names (schema legacy_name and
% legacy_dim, default the SWIFT field name) and time in days since 1970.
%
% overrides changes the schema for this file, field by field. It has the
% same parts as SWIFT_nc_schema's outputs, all optional:
%   ov.platform.met = 'Airmar PB200';                  % placeholder values
%   ov.vars.airtemp.comment = 'sensor in sun shield';  % variable attributes
%   ov.vars.signature.profile.east.name = 'u_rel';     % (nested like S)
%   ov.globals.project = 'Willapa Bay 2025';           % global attributes
%
% Simpler replacement for SWIFT2NC, see flattenSWIFT for the reshaping.
%
% Oct 2026 by M. LeClair (mleclair), based on SWIFT2NC

% Input checking; opts.* are the optional name=value arguments
arguments
    SWIFT struct
    filename {mustBeTextScalar}
    opts.platform {mustBeMember(opts.platform, ["auto" "v3" "v4" "micro"])} = "auto"
    opts.overrides struct = struct()
    opts.legacy (1,1) logical = false
end

% One struct with each field stacked over bursts (time along the last dimension)
[flat, noData] = flattenSWIFT(SWIFT);
[varSchema, platformInfo, globalAtts] = SWIFT_nc_schema();
if opts.legacy
    % Old SWIFT2NC names and time in days; overrides can still change them
    varSchema = legacySchema(varSchema);
    varSchema.time.encoding = 'days';
end

platform = opts.platform;
if platform == "auto"
    platform = detectPlatform(flat.ID(1));
end

% Text substituted for {key} placeholders in attribute values, e.g. {id}
placeholders = platformInfo.(platform);
placeholders.id = char(flat.ID(1));
% Sensor height/depth phrases, only when the data has the height
placeholders.at_ct_depth = '';
placeholders.at_met_height = '';
if isfield(flat, 'CTdepth')
    placeholders.at_ct_depth = sprintf(' at %g m depth', median(flat.CTdepth, 'all', 'omitnan'));
end
if isfield(flat, 'metheight')
    placeholders.at_met_height = sprintf(' at %g m height above the wave-following surface', ...
        median(flat.metheight, 'all', 'omitnan'));
end

% User overrides are applied last, so they win over the schema and the data
overrides = opts.overrides;
unknown = setdiff(fieldnames(overrides), {'platform', 'vars', 'globals'});
if ~isempty(unknown)
    error('SWIFT2NC_v2:overrides', 'Unknown overrides field(s): %s (use platform, vars, globals)', ...
        strjoin(unknown, ', '));
end
merged = mergeStructs(struct('platform', placeholders, 'vars', varSchema, 'globals', globalAtts), overrides);
placeholders = merged.platform;
varSchema = merged.vars;
globalAtts = merged.globals;

% MATLAB datenum (days) -> whole seconds or days since 1970 (schema time.encoding)
encoding = varSchema.time.encoding;
flat.time = flat.time - datenum(1970, 1, 1);
if strcmp(encoding, 'seconds')
    flat.time = round(flat.time * 86400); % whole seconds, drops datenum round-off
elseif ~strcmp(encoding, 'days')
    error('SWIFT2NC_v2:encoding', 'time encoding must be seconds or days, not %s', encoding);
end
varSchema.time.units = [encoding ' since 1970-01-01 00:00:00'];

% Bursts can have different numbers of frequency bins (e.g. 42 or 85), so
% clip or NaN-pad all spectra to the schema's nbins frequencies
if isfield(flat, 'wavespectra')
    flat.wavespectra = clipSpectra(flat.wavespectra, varSchema.wavespectra.freq.nbins);
end

% Create the file (CLOBBER = overwrite if it exists). onCleanup closes it
% when this function exits, even on an error.
ncid = netcdf.create(filename, bitor(netcdf.getConstant('NETCDF4'), netcdf.getConstant('CLOBBER')));
closeFile = onCleanup(@() netcdf.close(ncid));

% Global attributes
globalId = netcdf.getConstant('NC_GLOBAL');
putAtts(ncid, globalId, globalAtts, placeholders);
netcdf.putAtt(ncid, globalId, 'platform', char(platform));
netcdf.putAtt(ncid, globalId, 'date_created', ...
    char(datetime('now', 'TimeZone', 'UTC', 'Format', 'yyyy-MM-dd''T''HH:mm:ss''Z''')));

timeDim = netcdf.defDim(ncid, 'time', numel(flat.time));
[notInSchema, notWritten] = defineGroup(ncid, ncid, '', varSchema, flat, timeDim, placeholders, opts.legacy);

if ~isempty(notInSchema)
    warnNoTrace('SWIFT2NC_v2:notInSchema', 'Not in SWIFT_nc_schema, not written: %s', ...
        strjoin(notInSchema, ', '));
end

% Schema fields that were not written: either all NaN in every burst, or
% not in this SWIFT struct at all (e.g. v3-only sensors on a v4)
allNaN = notWritten(cellfun(@(p) hasNoData(p, noData), notWritten));
notInData = setdiff(notWritten, allNaN, 'stable');
if ~isempty(allNaN)
    warnNoTrace('SWIFT2NC_v2:allNaN', 'In SWIFT_nc_schema but all NaN, not written: %s', ...
        strjoin(allNaN, ', '));
end
if ~isempty(notInData)
    warnNoTrace('SWIFT2NC_v2:notInData', 'In SWIFT_nc_schema but not in the data, not written: %s', ...
        strjoin(notInData, ', '));
end
end


function [notInSchema, notWritten] = defineGroup(ncid, group, path, varSchema, data, timeDim, placeholders, legacy)
% Define and write the variables of one level of the schema in netCDF
% group `group`, calling itself for each substruct (subgroup). NETCDF4
% files allow writing data between definitions.
%   ncid          the file (root group)
%   path          e.g. 'signature.profile.', used in messages
%   varSchema     schema for this level: one field per variable, holding its
%                 attributes (and optionally .name, the netCDF name, and
%                 .dim, a coordinate's dimension name)
%   data          the matching level of the flattened SWIFT struct
%   legacy        true: substructs go in the same group (no subgroups)
% Returns notInSchema, the paths of fields in data that the schema does not list,
% and notWritten, the paths of schema fields that data does not have.

notInSchema = strcat(path, setdiff(fieldnames(data), fieldnames(varSchema)))';
notWritten = {};
coordDims = zeros(0, 2); % one row per coordinate: [length, dimension id]

% Define coordinates first, so other fields can find their dimension
names = fieldnames(varSchema);
coordFirst = isCoord(names);
names = [names(coordFirst); names(~coordFirst)];

for i = 1:numel(names)
    name = names{i};
    spec = varSchema.(name);
    if ~isfield(data, name) % not in this data set, or no data
        notWritten{end+1} = [path name];
        continue
    end
    values = data.(name);

    % Substruct -> netCDF subgroup (legacy: same group)
    if isstruct(values)
        subgroup = group;
        if ~legacy
            subgroup = netcdf.defGrp(group, name);
        end
        [subNotInSchema, subNotWritten] = defineGroup(ncid, subgroup, [path name '.'], spec, values, timeDim, placeholders, legacy);
        notInSchema = [notInSchema subNotInSchema];
        notWritten = [notWritten subNotWritten];
        continue
    end

    % netCDF name defaults to the SWIFT field name; everything else in
    % spec, except the settings below, is written as an attribute
    ncName = name;
    if isfield(spec, 'name')
        ncName = spec.name;
    end
    attrs = rmfield(spec, intersect(fieldnames(spec), ...
        {'name', 'dim', 'legacy_name', 'legacy_dim', 'nbins', 'encoding'}));
    nRows = size(values, 1); % values is [nRows x nTimes]

    if isstring(values) && all(values == values(1))
        % Same text in every burst (e.g. ID) -> global attribute
        netcdf.putAtt(ncid, netcdf.getConstant('NC_GLOBAL'), ncName, char(values(1)));
        continue
    elseif isstring(values)
        varid = netcdf.defVar(group, ncName, 'NC_STRING', timeDim);
        values = fillmissing(values, 'constant', "");
    elseif nRows == 1
        % One value per burst -> (time)
        varid = netcdf.defVar(group, ncName, 'NC_DOUBLE', timeDim);
    elseif isCoord(name)
        % Coordinate: a dimension of its own. Normally each row (e.g. each
        % z bin) has the same value in every burst, ignoring NaN; if not,
        % it is written per burst on a <name>_index dimension. spec.dim
        % overrides the dimension name.
        rowValue = max(values, [], 2, 'omitnan');
        isFixed = all(values == rowValue | isnan(values), 'all');
        dimName = ncName;
        if ~isFixed
            dimName = [ncName '_index'];
        end
        if isfield(spec, 'dim')
            dimName = spec.dim;
        end
        dimid = netcdf.defDim(group, dimName, nRows);
        if isFixed
            varid = netcdf.defVar(group, ncName, 'NC_DOUBLE', dimid);
            values = rowValue;
        else
            warnNoTrace('SWIFT2NC_v2:coord', '%s%s varies between bursts, written as (time, %s)', ...
                path, name, dimName);
            varid = netcdf.defVar(group, ncName, 'NC_DOUBLE', [dimid timeDim]);
        end
        coordDims(end+1, :) = [nRows dimid];
    else
        % Profile/spectrum -> (time, coordinate) using the coordinate of the
        % same length, else a dimension of its own named <name>_n
        dimid = coordDims(coordDims(:, 1) == nRows, 2);
        if numel(dimid) > 1
            error('SWIFT2NC_v2:ambiguous', '%s%s matches several coordinates', path, name);
        elseif isempty(dimid)
            dimid = netcdf.defDim(group, [ncName '_n'], nRows);
        end
        varid = netcdf.defVar(group, ncName, 'NC_DOUBLE', [dimid timeDim]);
    end

    if isnumeric(values)
        netcdf.defVarDeflate(group, varid, true, true, 4); % compression level 4
    end
    if isnumeric(values) && ~isCoord(name)
        netcdf.defVarFill(group, varid, false, NaN); % missing = NaN; CF: no fill on coordinates
    end
    putAtts(group, varid, attrs, placeholders);
    netcdf.putVar(group, varid, values);
end
end


function varSchema = legacySchema(varSchema)
% Schema for legacy=true: each variable's name becomes its legacy_name
% (default the SWIFT field name, as old SWIFT2NC) and legacy_dim its dim
for field = fieldnames(varSchema)'
    f = field{1};
    spec = varSchema.(f);
    if isGroup(spec)
        varSchema.(f) = legacySchema(spec);
        continue
    end
    spec.name = f;
    if isfield(spec, 'legacy_name')
        spec.name = spec.legacy_name;
    end
    if isfield(spec, 'legacy_dim')
        spec.dim = spec.legacy_dim;
    end
    varSchema.(f) = spec;
end
end


function tf = isGroup(spec)
% Schema substruct (e.g. signature) rather than one variable's attributes
tf = all(structfun(@isstruct, spec));
end


function spectra = clipSpectra(spectra, nbins)
% Clip each burst's spectra to the first nbins frequencies, NaN-padding
% shorter bursts. The grid is the first burst with nbins increasing
% frequencies; bursts with other frequencies (e.g. all-zero placeholders)
% become NaN. spectra.freq is [nFreq x nTimes], NaN-padded.
nFreq = size(spectra.freq, 1);
freq = clipRows(spectra.freq, nbins);
first = find(all(~isnan(freq), 1) & all(diff(freq) > 0, 1), 1);
if isempty(first)
    error('SWIFT2NC_v2:nbins', 'No burst has %d increasing wave frequencies', nbins);
end
freqGrid = freq(:, first);
offGrid = ~all(freq == freqGrid | isnan(freq), 1);
if any(offGrid)
    warnNoTrace('SWIFT2NC_v2:offGrid', '%d burst(s) with wavespectra.freq not on the %d-bin grid, written as NaN', ...
        sum(offGrid), nbins);
end

for field = fieldnames(spectra)'
    f = field{1};
    if size(spectra.(f), 1) ~= nFreq
        continue % only fields given per frequency
    end
    values = clipRows(spectra.(f), nbins);
    values(:, offGrid) = NaN;
    spectra.(f) = values;
end
spectra.freq = repmat(freqGrid, 1, size(freq, 2));
end


function values = clipRows(values, n)
% First n rows of values, NaN-padded if there are fewer
values(end+1:n, :) = NaN;
values = values(1:n, :);
end


function tf = hasNoData(path, noData)
% True if flattenSWIFT left out path (or everything under it) for having no data
tf = any(strcmp(noData, path) | startsWith(noData, [path '.']));
end


function tf = isCoord(name)
% SWIFT fields that are coordinates: time, and z, freq and echoz for
% same-length fields in their substruct
tf = ismember(name, {'time', 'z', 'freq', 'echoz'});
end


function warnNoTrace(varargin)
% warning() without the "In ... at line ..." stack trace
backtrace = warning('off', 'backtrace');
warning(varargin{:});
warning(backtrace);
end


function putAtts(group, varid, attrs, placeholders)
% Write each field of attrs as an attribute, replacing {key} with
% placeholders.key; skip attributes that end up empty
for nameCell = fieldnames(attrs)' % loop gives each name as a 1x1 cell
    attName = nameCell{1};
    value = attrs.(attName);
    if ischar(value)
        for key = fieldnames(placeholders)'
            value = strrep(value, ['{' key{1} '}'], placeholders.(key{1}));
        end
    end
    if ~isempty(value)
        netcdf.putAtt(group, varid, attName, value);
    end
end
end


function base = mergeStructs(base, overrides)
% Copy every field of overrides into base, recursing where both have a
% substruct, so only the fields given in overrides change
for field = fieldnames(overrides)'
    f = field{1};
    if isfield(base, f) && isstruct(base.(f)) && isstruct(overrides.(f))
        base.(f) = mergeStructs(base.(f), overrides.(f));
    else
        base.(f) = overrides.(f);
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
