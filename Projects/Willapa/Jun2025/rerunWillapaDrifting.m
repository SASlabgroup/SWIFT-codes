% Rebuild the June 2025 drifting SWIFT missions in an isolated staging tree,
% compare them with production, export L4 NetCDF, and install only when the
% caller explicitly sets install=true and supplies an external backup root.
%
% Required workspace variables (the willapa_analysis launcher supplies them):
%   prodexp, stage
% Optional:
%   exportdir, backup_root, install (default false)
%
% Raw sensor directories are linked read-only from production into a new,
% empty staging mission. All generated SBD and MATLAB products stay in staging.

if ~exist("install","var"), install = false; end
if ~exist("prodexp","var"), prodexp = getenv("WILLAPA_DRIFTING_PRODUCTION"); end
if ~exist("stage","var"), stage = getenv("WILLAPA_DRIFTING_STAGING"); end
if ~exist("exportdir","var"), exportdir = getenv("WILLAPA_DRIFTING_EXPORTS"); end
if ~exist("backup_root","var"), backup_root = getenv("WILLAPA_DRIFTING_BACKUPS"); end

assert(strlength(string(prodexp)) > 0, ...
    "Set prodexp or WILLAPA_DRIFTING_PRODUCTION.")
assert(strlength(string(stage)) > 0, ...
    "Set stage or WILLAPA_DRIFTING_STAGING.")
if install
    assert(strlength(string(backup_root)) > 0, ...
        "Set backup_root or WILLAPA_DRIFTING_BACKUPS before install=true.")
end
assert(~ispc,"This staging driver currently requires Unix symbolic links.")

missions = ["SWIFT27_17Jun2025","SWIFT27_18Jun2025", ...
    "SWIFT27_19Jun2025","SWIFT27_21Jun2025","SWIFT27_22Jun2025", ...
    "SWIFT27_23-25Jun2025","SWIFT28_21Jun2025", ...
    "SWIFT28_22-23Jun2025","SWIFT28_24Jun2025","SWIFT28_25Jun2025", ...
    "SWIFT29_18-19Jun2025","SWIFT29_20Jun2025", ...
    "SWIFT29_23-24Jun2025","SWIFT29_25Jun2025"];

driverPath = mfilename("fullpath");
drivers = fileparts(driverPath);
swiftcodes = fileparts(fileparts(fileparts(drivers)));
addpath(genpath(swiftcodes))

assert(isfolder(prodexp),"Production archive not found: %s",prodexp)
if ~isfolder(stage), mkdir(stage); end
if strlength(string(exportdir)) > 0 && ~isfolder(exportdir), mkdir(exportdir); end
if install
    backup = fullfile(backup_root, ...
        "drifting_rerun_" + string(datetime("now","Format","yyyyMMdd_HHmm")));
    mkdir(backup)
end

%% 1. Link immutable raw inputs into new staging missions.
for mission = missions
    prod = fullfile(prodexp,mission);
    stg = fullfile(stage,mission);
    assert(isfolder(prod),"Production mission not found: %s",prod)
    assert(~isfolder(stg), ...
        "Staging mission already exists; use an empty staging path: %s",stg)
    mkdir(stg)

    entries = dir(prod);
    entries = entries([entries.isdir]);
    names = string({entries.name});
    names = names(~startsWith(names,".") & names ~= "ProcessedSBD" & ...
        names ~= "L5_review");
    for name = names
        source = fullfile(prod,name);
        destination = fullfile(stg,name);
        [status,message] = system("ln -s " + shellQuote(source) + " " + ...
            shellQuote(destination));
        assert(status == 0,"Could not link %s: %s",source,message)
    end
end

%% 2. Standard SWIFT-codes L0-L3 processing from raw files.
payloadtype = "7";
plotflag = true;
minwaveheight = 0;
minsalinity = 0;
maxdriftspd = 10;

for mission = missions
    missiondir = fullfile(stage,mission);
    acsfiles = dir(fullfile(missiondir,"*","Raw","**","*ACS*.dat"));
    assert(~isempty(acsfiles),"No ACS files found for %s",mission)
    burstind = NaN(length(acsfiles),1);
    for iburst = 1:length(acsfiles)
        token = regexp(acsfiles(iburst).name,"_(\d\d)\.dat$","tokens","once");
        if ~isempty(token), burstind(iburst) = str2double(token{1}); end
    end
    burstsPerHour = max(burstind,[],"omitnan");
    assert(isfinite(burstsPerHour) && burstsPerHour > 0, ...
        "Could not determine burst interval for %s",mission)
    burstinterval = 60 / burstsPerHour;
    fprintf("\n%s: %d ACS files, %.1f-minute interval\n", ...
        mission,length(acsfiles),burstinterval)

    L0_createSBD(char(missiondir),"ProcessedSBD",burstinterval,payloadtype);
    L1_compileSWIFT(char(missiondir),"ProcessedSBD", ...
        burstinterval,plotflag);
    L2_pruneSWIFT(char(missiondir),plotflag, ...
        minwaveheight,minsalinity,maxdriftspd);
    L3_postprocessSWIFT(char(missiondir));

    HPR = checkSIGhpr(char(missiondir),"plothpr"); %#ok<NASGU>
    save(fullfile(missiondir,mission + "_SIG_HPR.mat"),"HPR")
end

%% 3. Experiment-specific QC, L4 save, and NetCDF conversion.
qcSummary = repmat(struct,1,length(missions));
for im = 1:length(missions)
    mission = missions(im);
    missiondir = fullfile(stage,mission);
    l3file = fullfile(missiondir,mission + "_L3.mat");
    [SWIFT,sinfo,qcSummary(im)] = AdHocQC_WillapaDrifting(l3file); %#ok<ASGLU>
    l4file = fullfile(missiondir,mission + "_L4.mat");
    save(l4file,"SWIFT","sinfo")
    SWIFT2NC(SWIFT,char(fullfile(missiondir,mission + "_L4.nc")));
    fprintf("%s: L4 %d -> %d records\n",mission, ...
        qcSummary(im).input_records,qcSummary(im).output_records)
end

%% 4. Compare staged L1-L4 products and L4 NetCDF with production.
for mission = missions
    prod = fullfile(prodexp,mission);
    stg = fullfile(stage,mission);
    fprintf("\n%s\n",mission)
    for lev = ["L1","L2","L3","L4"]
        new = load(fullfile(stg,mission + "_" + lev + ".mat"),"SWIFT");
        old = load(fullfile(prod,mission + "_" + lev + ".mat"),"SWIFT");
        N = new.SWIFT; P = old.SWIFT;
        if numel(N) ~= numel(P) || any([N.time] ~= [P.time])
            fprintf("  %s: record/time mismatch (%d staged, %d production)\n", ...
                lev,numel(N),numel(P))
            continue
        end
        changed = strings(0);
        for name = string(union(fieldnames(N),fieldnames(P)))'
            if ~isfield(N,name) || ~isfield(P,name)
                changed(end+1) = name + " (only in one)"; %#ok<SAGROW>
                continue
            end
            count = 0;
            for k = 1:numel(N)
                if ~isequaln(N(k).(name),P(k).(name)), count = count + 1; end
            end
            if count > 0, changed(end+1) = sprintf("%s (%d)",name,count); end %#ok<SAGROW>
        end
        fprintf("  %s: %d records; differing fields: %s\n", ...
            lev,numel(N),strjoin(changed,", "))
    end

    stagedNc = fullfile(stg,mission + "_L4.nc");
    productionNc = fullfile(prod,mission + "_L4.nc");
    stagedInfo = ncinfo(stagedNc); productionInfo = ncinfo(productionNc);
    stagedNames = string({stagedInfo.Variables.Name});
    productionNames = string({productionInfo.Variables.Name});
    changed = [setdiff(stagedNames,productionNames) + " (new)", ...
        setdiff(productionNames,stagedNames) + " (missing)"];
    for name = intersect(stagedNames,productionNames)
        if ~isequaln(ncread(stagedNc,name),ncread(productionNc,name))
            changed(end+1) = name; %#ok<SAGROW>
        end
    end
    fprintf("  L4 NetCDF variables differing: %s\n",strjoin(changed,", "))
end

%% 5. Export only the accepted analysis handoff format.
if strlength(string(exportdir)) > 0
    for mission = missions
        copyfile(fullfile(stage,mission,mission + "_L4.nc"), ...
            fullfile(exportdir,mission + "_L4.nc"));
    end
    writetable(struct2table(qcSummary), ...
        fullfile(exportdir,"drifting_qc_summary.csv"));
    fprintf("L4 NetCDF exports written to %s\n",exportdir)
end

%% 6. Optional production installation, guarded by an external backup.
if install
    for mission = missions
        prod = fullfile(prodexp,mission);
        stg = fullfile(stage,mission);
        bak = fullfile(backup,mission);
        mkdir(bak)
        files = [mission + ["_L1","_L2","_L3","_L4"] + ".mat", ...
            mission + "_L4.nc", mission + "_SIG_HPR.mat"];
        for file = files
            if isfile(fullfile(prod,file)), copyfile(fullfile(prod,file),bak); end
            copyfile(fullfile(stg,file),prod);
        end
        fprintf("%s installed; previous products backed up in %s\n",mission,bak)
    end
end


function quoted = shellQuote(value)
value = string(value);
assert(~contains(value,'"'),"Paths containing double quotes are unsupported.")
quoted = string(sprintf('"%s"',char(value)));
end
