function [SWIFT,sinfo,qc] = AdHocQC_WillapaDrifting(l3file)
%ADHOCQC_WILLAPADRIFTING Apply the accepted June 2025 drifting-SWIFT QC.
%
% This is the portable SWIFT-codes version of the experiment script stored
% beside the production data on bigwaves. It preserves the accepted rules:
% remove ACS out-of-water records, weak/failed wave records (except the long
% SWIFT27 23-25 June mission), salinity below 27.7, and all records before
% 17 June 2025; also mask Signature bottom-reflection dissipation values.

arguments
    l3file (1,1) string
end

assert(isfile(l3file),"L3 product not found: %s",l3file)
source = load(l3file,"SWIFT","sinfo");
SWIFT = source.SWIFT;
sinfo = source.sinfo;

iacs = find(strcmp({sinfo.postproc.type}',"ACS"));
assert(~isempty(iacs),"No ACS processing flags found in %s",l3file)
iout = logical(sinfo.postproc(iacs(end)).flags.outofwater);

waveenergy = NaN(1,length(SWIFT));
wavecheck = NaN(1,length(SWIFT));
for it = 1:length(SWIFT)
    waveenergy(it) = sum(SWIFT(it).wavespectra.energy,"omitnan");
    wavecheck(it) = sum(SWIFT(it).wavespectra.check,"omitnan");
end
ilowwave = waveenergy < 0.03 | wavecheck < 10;
ilowsal = [SWIFT.salinity] < 27.7;

[~,mission] = fileparts(fileparts(l3file));
if mission == "SWIFT27_23-25Jun2025"
    ibad = iout | ilowsal;
else
    ibad = ilowwave | iout | ilowsal;
end

qc = struct( ...
    "mission",char(mission), ...
    "input_records",length(SWIFT), ...
    "out_of_water",nnz(iout), ...
    "low_wave",nnz(ilowwave), ...
    "low_salinity",nnz(ilowsal), ...
    "removed_union",nnz(ibad));
SWIFT = SWIFT(~ibad);

if isfield(SWIFT,"signature")
    for it = 1:length(SWIFT)
        if isfield(SWIFT(it).signature,"HRprofile") && ...
                isfield(SWIFT(it).signature.HRprofile,"w") && ...
                isfield(SWIFT(it).signature.HRprofile,"tkedissipationrate")
            reflection = isnan(SWIFT(it).signature.HRprofile.w);
            SWIFT(it).signature.HRprofile.tkedissipationrate(reflection) = NaN;
        end
    end
end

iexp = [SWIFT.time] > datenum([2025 06 17]);
qc.before_experiment = nnz(~iexp);
SWIFT = SWIFT(iexp);
qc.output_records = length(SWIFT);

if isfield(sinfo,"postproc")
    ip = length(sinfo.postproc) + 1;
else
    sinfo.postproc = struct;
    ip = 1;
end
sinfo.postproc(ip).type = "AdHocQC_WillapaDrifting";
sinfo.postproc(ip).usr = getenv("username");
sinfo.postproc(ip).time = string(datetime("now"));
sinfo.postproc(ip).params = struct( ...
    "minimum_wave_energy",0.03, ...
    "minimum_wave_check",10, ...
    "minimum_salinity",27.7, ...
    "experiment_start_datenum",datenum([2025 06 17]));
sinfo.postproc(ip).flags = struct( ...
    "outofwater",iout, ...
    "lowwave",ilowwave, ...
    "lowsalinity",ilowsal, ...
    "removed",ibad);
end
