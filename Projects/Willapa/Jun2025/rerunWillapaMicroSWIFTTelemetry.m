% Recreate the accepted Willapa microSWIFT telemetry NetCDF products from the
% SWIFT server. Intermediate downloaded SBD files and compiled .mat products
% remain in a new staging directory; only NetCDF is exported.
%
% Required workspace variable: stage
% Optional: exportdir, reference_dir

if ~exist("stage","var"), stage = getenv("WILLAPA_MICROSWIFT_STAGING"); end
if ~exist("exportdir","var"), exportdir = getenv("WILLAPA_MICROSWIFT_EXPORTS"); end
if ~exist("reference_dir","var"), reference_dir = exportdir; end
assert(strlength(string(stage)) > 0, ...
    "Set stage or WILLAPA_MICROSWIFT_STAGING.")
assert(~isfolder(stage), ...
    "Telemetry staging directory already exists; choose a new path: %s",stage)

driverPath = mfilename("fullpath");
drivers = fileparts(driverPath);
swiftcodes = fileparts(fileparts(fileparts(drivers)));
addpath(genpath(swiftcodes))

ids = char("157","158","159","160","170","171","172");
starttime = "2025-06-17T00:00:00";
endtime = "2025-06-27T23:59:59";

mkdir(stage)
startingDirectory = pwd;
restoreDirectory = onCleanup(@() cd(startingDirectory)); %#ok<NASGU>
cd(stage)
pullSWIFTtelemetry(ids,char(starttime),char(endtime),false);

if strlength(string(exportdir)) > 0 && ~isfolder(exportdir), mkdir(exportdir); end
for row = 1:size(ids,1)
    id = string(ids(row,:));
    product = "microSWIFT" + id + "_telemetry";
    matfile = fullfile(stage,product + ".mat");
    ncfile = fullfile(stage,product + ".nc");
    assert(isfile(matfile),"Telemetry compile did not create %s",matfile)
    source = load(matfile,"SWIFT");
    SWIFT2NC(source.SWIFT,char(ncfile));

    reference = fullfile(reference_dir,product + ".nc");
    if strlength(string(reference_dir)) > 0 && isfile(reference)
        newInfo = ncinfo(ncfile); oldInfo = ncinfo(reference);
        newNames = string({newInfo.Variables.Name});
        oldNames = string({oldInfo.Variables.Name});
        changed = [setdiff(newNames,oldNames) + " (new)", ...
            setdiff(oldNames,newNames) + " (missing)"];
        for name = intersect(newNames,oldNames)
            if ~isequaln(ncread(ncfile,name),ncread(reference,name))
                changed(end+1) = name; %#ok<SAGROW>
            end
        end
        fprintf("%s: variables differing from accepted export: %s\n", ...
            product,strjoin(changed,", "))
    else
        fprintf("%s: no accepted reference supplied\n",product)
    end

    if strlength(string(exportdir)) > 0
        copyfile(ncfile,fullfile(exportdir,product + ".nc"));
    end
end

if strlength(string(exportdir)) > 0
    fprintf("microSWIFT telemetry NetCDF exports written to %s\n",exportdir)
end
