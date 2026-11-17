% Rerun Willapa missions from the production L3 in a staging folder, list
% every difference against production, and install only when install = true.
%
% Steps, all with the production SWIFT-codes drivers:
%   1. Copy the production L3 into staging; link SIG/ and SBG/ (raw bursts).
%   2. reprocess_SIG: Signature fields from SIG/Raw (incl. altimeter).
%   3. Process_WillapaMoored: reprocess_SBG waves + Signature-heave fill.
%   4. AdHocQC_WillapaMoored                         -> L4
%   5. FixSIGENU_Willapa                             -> L5, L5_review/
%   6. SWIFT2NC: L3, L4, L5 (42 bands), L5_85 (85 bands)
%   7. Compare with production: SWIFT fields per level, NetCDF variables.
%   8. Export NetCDF products to exportdir (when nonempty).
%   9. Install (install = true): back up production, then replace production.
%
% Read the step 7 output before setting install = true.
%
% The launcher in willapa_analysis supplies prodexp, stage, exportdir and
% backup_root. They may also be set in the MATLAB workspace before run().
% Changelog:
% M. LeClair w/ claude, Nov 2026: path excludes .git, .claude and worktree
%   folders (and removes them from a saved path) so stale worktree copies
%   cannot shadow current functions
if ~exist('install','var'), install = false; end

missions = ["SWIFT22_17-26Jun2025","SWIFT23_17-26Jun2025","SWIFT24_16-20Jun2025", ...
    "SWIFT24_20-25Jun2025","SWIFT24_25-27Jun2025","SWIFT25_16-27Jun2025", ...
    "SWIFT26_16-27Jun2025","SWIFT28_20-21Jun2025"];

driver_path = mfilename('fullpath');
drivers = fileparts(driver_path);
swiftcodes = fileparts(fileparts(fileparts(drivers)));
if ~exist('prodexp','var'), prodexp = getenv('WILLAPA_SWIFT_PRODUCTION'); end
if ~exist('stage','var'), stage = getenv('WILLAPA_SWIFT_STAGING'); end
if ~exist('exportdir','var'), exportdir = getenv('WILLAPA_SWIFT_EXPORTS'); end
if ~exist('backup_root','var'), backup_root = getenv('WILLAPA_SWIFT_BACKUPS'); end
assert(strlength(string(prodexp)) > 0, 'Set prodexp or WILLAPA_SWIFT_PRODUCTION')
assert(strlength(string(stage)) > 0, 'Set stage or WILLAPA_SWIFT_STAGING')
if install
    assert(strlength(string(backup_root)) > 0, ...
        'Set backup_root or WILLAPA_SWIFT_BACKUPS before install=true')
end
% Backups must live outside prodexp: FixSIGENU indexes expdir recursively and
% would otherwise find same-named burst files in a backup.
backup = fullfile(backup_root, ...
    "rerun_" + string(datetime('now','Format','yyyyMMdd_HHmm')));

% genpath recurses into .git, .claude/worktrees and other worktrees, whose
% older copies of functions (e.g. reprocess_SBG) would shadow the current ones.
% Such folders are also removed if a saved MATLAB path already holds them.
stale = ["/.git", "/.claude", "/.worktrees", "/worktrees"];
q = strsplit(path, pathsep);
q = q(contains(q, stale));
if ~isempty(q), rmpath(q{:}); end
p = strsplit(genpath(swiftcodes), pathsep);
p = p(~contains(p, stale) & p ~= "");
addpath(strjoin(p, pathsep))

%% 1. Staging: production L3 copy, links to the raw SIG and SBG bursts
for mission = missions
    prod = fullfile(prodexp,mission);
    stg  = fullfile(stage,mission);
    if ~exist(stg,'dir'), mkdir(stg); end
    copyfile(fullfile(prod,mission + "_L3.mat"), stg);
    if ~exist(fullfile(stg,'SIG'),'dir')
        system(sprintf('ln -s "%s" "%s"', fullfile(prod,'SIG'), fullfile(stg,'SIG')));
    end
    if ~exist(fullfile(stg,'SBG'),'dir')
        system(sprintf('ln -s "%s" "%s"', fullfile(prod,'SBG'), fullfile(stg,'SBG')));
    end
    nsig = numel(dir(fullfile(stg,'SIG','Raw','**','SWIFT*_SIG_*.mat')));
    nsbg = numel(dir(fullfile(stg,'SBG','Raw','**','SWIFT*_SBG_*.mat')));
    fprintf('%s: staging sees %d SIG and %d SBG burst files\n', mission, nsig, nsbg)
    % MATLAB's recursive dir() must see the files through the links.
    assert(nsig > 0 && nsbg > 0, 'dir() does not see the raw files through the links')
end

%% 2. Signature fields from SIG/Raw
for mission = missions
    reprocess_SIG(char(fullfile(stage,mission)), false, false);
end

%% 3-5. SBG waves + Signature fill, L4, L5
% The drivers read expdir/missionnames/outdir from the workspace and may
% overwrite loop variables, so keep a copy of the mission list.
runmissions = missions;
expdir = stage; missionnames = runmissions;
run(fullfile(drivers,'Process_WillapaMoored.m'))
expdir = stage; missionnames = runmissions;
run(fullfile(drivers,'AdHocQC_WillapaMoored.m'))
expdir = stage; outdir = stage; missionnames = runmissions;
run(fullfile(drivers,'FixSIGENU_Willapa.m'))
missions = runmissions;

%% 6. NetCDF
for mission = missions
    stg = fullfile(stage,mission);
    S = load(fullfile(stg,mission + "_L3.mat"),'SWIFT');
    SWIFT2NC(S.SWIFT, char(fullfile(stg,mission + "_L3.nc")), 'nfreq', 42);
    S = load(fullfile(stg,mission + "_L4.mat"),'SWIFT');
    SWIFT2NC(S.SWIFT, char(fullfile(stg,mission + "_L4.nc")), 'nfreq', 42);
    S = load(fullfile(stg,mission + "_L5.mat"),'SWIFT');
    SWIFT2NC(S.SWIFT, char(fullfile(stg,mission + "_L5.nc")), 'nfreq', 42);
    SWIFT2NC(S.SWIFT, char(fullfile(stg,mission + "_L5_85.nc")), 'nfreq', 85);
end

%% 7. Compare with production
for mission = missions
    prod = fullfile(prodexp,mission);
    stg  = fullfile(stage,mission);
    fprintf('\n%s\n', mission)

    % SWIFT structs: record times, then each top-level field.
    for lev = ["L3","L4","L5"]
        N = load(fullfile(stg, mission + "_" + lev + ".mat"),'SWIFT'); N = N.SWIFT;
        P = load(fullfile(prod,mission + "_" + lev + ".mat"),'SWIFT'); P = P.SWIFT;
        if numel(N) ~= numel(P) || any([N.time] ~= [P.time])
            fprintf('  %s: records differ (%d staging, %d production)\n', lev, numel(N), numel(P))
            continue
        end
        changed = strings(0);
        for name = string(union(fieldnames(N),fieldnames(P)))'
            if ~isfield(N,name) || ~isfield(P,name)
                changed(end+1) = name + " (only in one)"; %#ok<SAGROW>
                continue
            end
            nrec = 0;
            for k = 1:numel(N)
                if ~isequaln(N(k).(name), P(k).(name)), nrec = nrec + 1; end
            end
            if nrec > 0, changed(end+1) = sprintf('%s (%d)', name, nrec); end %#ok<SAGROW>
        end
        fprintf('  %s: %d records; fields differing (records): %s\n', ...
            lev, numel(N), strjoin(changed, ', '))
    end

    % NetCDF variables. Global attributes are not compared (creation date).
    for f = mission + ["_L3","_L4","_L5","_L5_85"] + ".nc"
        in = ncinfo(fullfile(stg,f)); ip = ncinfo(fullfile(prod,f));
        vn = string({in.Variables.Name}); vp = string({ip.Variables.Name});
        changed = [setdiff(vn,vp) + " (new)", setdiff(vp,vn) + " (missing)"];
        for v = intersect(vn,vp)
            if ~isequaln(ncread(fullfile(stg,f),v), ncread(fullfile(prod,f),v))
                changed(end+1) = v; %#ok<SAGROW>
            end
        end
        fprintf('  %s: variables differing: %s\n', f, strjoin(changed, ', '))
    end
end

%% 8. Export NetCDF handoff (never MATLAB products)
if strlength(string(exportdir)) > 0
    for mission = missions
        stg = fullfile(stage,mission);
        out = fullfile(exportdir,mission);
        if ~exist(out,'dir'), mkdir(out); end
        for f = mission + ["_L3","_L4","_L5","_L5_85"] + ".nc"
            copyfile(fullfile(stg,f), fullfile(out,f));
        end
    end
    fprintf('NetCDF exports written to %s\n', exportdir)
end

%% 9. Install production MATLAB and NetCDF products
if install
    for mission = missions
        prod = fullfile(prodexp,mission);
        stg  = fullfile(stage,mission);
        bak  = fullfile(backup,mission);
        mkdir(bak);
        files = [mission + ["_L3","_SIG","_L4","_L5"] + ".mat", ...
            mission + ["_L3","_L4","_L5","_L5_85"] + ".nc", "SBG_processing_report.txt"];
        for f = files
            copyfile(fullfile(prod,f), bak);
            copyfile(fullfile(stg,f), prod);
        end
        copyfile(fullfile(prod,'L5_review'), fullfile(bak,'L5_review'));
        copyfile(fullfile(stg,'L5_review'), fullfile(prod,'L5_review'));
        fprintf('%s installed; backup in %s\n', mission, bak)
    end
end
