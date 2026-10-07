function SWIFT2NC_v2(SWIFT, filename, opts)
% Write a SWIFT struct array to a NETCDF4 file described by SWIFT_nc_schema
%
%   SWIFT2NC_v2(SWIFT, filename)
%   SWIFT2NC_v2(SWIFT, filename, platform='micro', overrides=ov)
%
% Only fields listed in SWIFT_nc_schema are written (others are listed in
% a warning). Substructs become groups (e.g. /signature/profile) that share
% the root time dimension. z, freq and echoz are coordinates: the second
% dimension of same-length fields in their group. Text fields that are the
% same in every burst (e.g. ID) become global attributes.
%
% platform is v3, v4 or micro; by default it is detected from SWIFT(1).ID.
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
end

% One struct with each field stacked over bursts (time along the last dimension)
flat = flattenSWIFT(SWIFT);
[varSchema, platformInfo, globalAtts] = SWIFT_nc_schema();

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
if isfield(overrides, 'platform')
    placeholders = mergeStructs(placeholders, overrides.platform);
end
if isfield(overrides, 'vars')
    varSchema = mergeStructs(varSchema, overrides.vars);
end
if isfield(overrides, 'globals')
    globalAtts = mergeStructs(globalAtts, overrides.globals);
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

% netCDF needs all dimensions and variables defined before any data is
% written, so defineGroup collects the data and we write it afterwards
timeDim = netcdf.defDim(ncid, 'time', numel(flat.time));
[pendingWrites, notInSchema] = defineGroup(ncid, ncid, '', varSchema, flat, timeDim, placeholders);
netcdf.endDef(ncid);
for k = 1:size(pendingWrites, 1)
    netcdf.putVar(pendingWrites{k, :}); % = putVar(group, varid, data)
end

if ~isempty(notInSchema)
    warnNoTrace('SWIFT2NC_v2:notInSchema', 'Not in SWIFT_nc_schema, not written: %s', ...
        strjoin(notInSchema, ', '));
end
end


function [pendingWrites, notInSchema] = defineGroup(ncid, group, path, varSchema, data, timeDim, placeholders)
% Define the variables of one level of the schema in netCDF group `group`,
% calling itself for each substruct (subgroup).
%   ncid          the file (root group)
%   path          e.g. 'signature.profile.', used in messages
%   varSchema     schema for this level: one field per variable, holding its
%                 attributes (and optionally .name, the netCDF name)
%   data          the matching level of the flattened SWIFT struct
% Returns pendingWrites, rows of {group, varid, data} for netcdf.putVar, and
% notInSchema, the paths of fields in data that the schema does not list.

pendingWrites = cell(0, 3);
notInSchema = strcat(path, setdiff(fieldnames(data), fieldnames(varSchema)))';
coordDims = zeros(0, 2); % one row per coordinate: [length, dimension id]

% Define coordinates first, so other fields can find their dimension
names = fieldnames(varSchema);
coordFirst = isCoord(names);
names = [names(coordFirst); names(~coordFirst)];

for i = 1:numel(names)
    name = names{i};
    spec = varSchema.(name);
    if ~isfield(data, name) % not in this data set, or no data
        continue
    end
    values = data.(name);

    % Substruct -> netCDF subgroup
    if isstruct(values)
        subgroup = netcdf.defGrp(group, name);
        [subWrites, subNotInSchema] = defineGroup(ncid, subgroup, [path name '.'], spec, values, timeDim, placeholders);
        pendingWrites = [pendingWrites; subWrites];
        notInSchema = [notInSchema subNotInSchema];
        continue
    end

    % netCDF name defaults to the SWIFT field name; everything else in
    % spec is written as an attribute
    ncName = name;
    if isfield(spec, 'name')
        ncName = spec.name;
    end
    attrs = rmfield(spec, intersect(fieldnames(spec), {'name'}));
    nRows = size(values, 1); % values is [nRows x nTimes]
    isRootTime = group == ncid && strcmp(name, 'time');

    if isstring(values) && all(values == values(1))
        % Same text in every burst (e.g. ID) -> global attribute
        netcdf.putAtt(ncid, netcdf.getConstant('NC_GLOBAL'), ncName, char(values(1)));
        continue
    elseif isstring(values)
        varid = netcdf.defVar(group, ncName, 'NC_STRING', timeDim);
        values = fillmissing(values, 'constant', "");
    elseif isRootTime
        % MATLAB datenum (days) -> whole seconds since 1970
        varid = netcdf.defVar(group, ncName, 'NC_DOUBLE', timeDim);
        values = round((values - datenum(1970, 1, 1)) * 86400);
    elseif nRows == 1
        % One value per burst -> (time)
        varid = netcdf.defVar(group, ncName, 'NC_DOUBLE', timeDim);
    elseif isCoord(name)
        % Coordinate: a dimension of its own. Normally each row (e.g. each
        % z bin) has the same value in every burst, ignoring NaN.
        rowValue = max(values, [], 2, 'omitnan');
        if all(values == rowValue | isnan(values), 'all')
            dimid = netcdf.defDim(group, ncName, nRows);
            varid = netcdf.defVar(group, ncName, 'NC_DOUBLE', dimid);
            values = rowValue;
        else
            warnNoTrace('SWIFT2NC_v2:coord', '%s%s varies between bursts, written as (time, %s_index)', ...
                path, name, ncName);
            dimid = netcdf.defDim(group, [ncName '_index'], nRows);
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
    if isnumeric(values) && ~isCoord(name) && ~isRootTime
        netcdf.defVarFill(group, varid, false, NaN); % missing = NaN; CF: no fill on coordinates
    end
    putAtts(group, varid, attrs, placeholders);
    pendingWrites(end+1, :) = {group, varid, values};
end
end


function tf = isCoord(name)
% SWIFT fields that are coordinates of same-length fields in their substruct
tf = ismember(name, {'z', 'freq', 'echoz'});
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
