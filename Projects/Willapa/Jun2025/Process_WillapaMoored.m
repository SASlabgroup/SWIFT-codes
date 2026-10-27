% Runs all processing for Willapa Bay 2025 (moored)

% 1. L0_createSBD.m
% 2. L1_compileSWIFT.m
% 3. L2_pruneSWIFT.m
% 4. L3_postprocessSWIFT.m

% Changelog:
% K. Zeiden June 2025
% M. LeClair w/ claude, Oct 2026: paths with fullfile and the SSD as
%   the Mac default; L0-L3 commented out (done); SBG wave recovery (SWIFT26
%   tmin 76); SWIFT25 Signature-heave wave fill

%% Experiment specific parameters

% Experiment Directory (workspace override: expdir, e.g. a staging folder)
if ~exist('expdir','var') || isempty(expdir)
    if ispc
        expdir = 'S:/Willapa/Jun2025/MooredSWIFTs';
    else
        expdir = '/Volumes/PortableSSD/MooredSWIFTS';
    end
end

% SBD folder
SBDfold = 'ProcessedSBD';

% Sampling Parameters
payloadtype = '7'; % v3.3 (2015) and up 

% Plotting toggle
plotflag = true;

% Prune Parameters (to identify out-of-water-bursts)
minwaveheight = 0;% minimum wave height [m]
minsalinity = 0;% minimum salinity [PSU] 
maxdriftspd = 10;% maximum drift speed [m/s]

%% List of missions

missions = dir(fullfile(expdir,'SWIFT*'));
missions = missions([missions.isdir]);
missions = missions(~contains({missions.name},'directoffload'));
if exist('missionnames','var') && ~isempty(missionnames)   % workspace override
    missions = missions(ismember({missions.name},missionnames));
end

%% Loop through missions and post process

for im = 1:length(missions)

    missiondir = fullfile(missions(im).folder,missions(im).name);
    cd(missiondir)
    [~,sname] = fileparts(missiondir);

    % L0-L3 are commented out: processing starts from the existing L3.
    % Uncomment them to rebuild from raw.
    % % Burst interval
    % acsfiles = dir(fullfile(missiondir,'*','Raw','*','*ACS*.dat'));
    % burstind = NaN(length(acsfiles),1);
    % for iburst = 1:length(acsfiles)
    %     burstind(iburst) = str2double(acsfiles(iburst).name(end-5:end-4));
    % end
    % burstinterval = 60/max(burstind);

    % % Create SBD files
    % L0_createSBD(missiondir,SBDfold,burstinterval,payloadtype);

    % % Compile SWIFT structure
    % [SWIFTL1,sinfoL1] = L1_compileSWIFT(missiondir,SBDfold,burstinterval,plotflag);

    % % Prune out-of-water bursts
    % [SWIFTL2,sinfoL2] = L2_pruneSWIFT(missiondir,plotflag,minwaveheight,minsalinity,maxdriftspd);

    % % Post-process all non-SBG sensors through the standard driver.
    % [SWIFTL3,sinfoL3] = L3_postprocessSWIFT(missiondir, ...
    %     'rpWXT','rpPB2','rpY81','rpIMU','rpACS','rpACO', ...
    %     'rpSIG','rpAQH','rpAQD','plotswift');

    % SBG waves use 256-second FFT windows, so the full wave-frequency range
    % is resolved. SWIFT26's heave settles 70--80 s into each record, so its
    % crop starts at 76 s (tmin=76) and a single window is accepted
    % (minimum_windows=1); the other missions keep the 90-second crop, which
    % loses none of their records.
    %
    % reprocess_SBG stores the DOF in wavespectra.dof, flags raw-SBG and
    % reduced-DOF records in sinfo, and writes SBG_processing_report.txt with
    % source availability and errors. A failed raw calculation stays missing
    % (L2 wave values are not carried into L3); expected ten-minute slots
    % absent from L2 are reported but not inserted, since they have no SWIFT
    % record.
    if strcmp(sname,'SWIFT26_16-27Jun2025')
        [SWIFTL3,sinfoL3] = reprocess_SBG( ...
            missiondir,false,false,false,true,90, ...
            tmin=76,minimum_windows=1);
    else
        [SWIFTL3,sinfoL3] = reprocess_SBG( ...
            missiondir,false,false,false,true,90);
    end

    % SWIFT25's SBG outage on 20--21 June is filled from the Signature
    % accelerometer after all available SBG records have been reprocessed.
    % reprocess_SIGheave deliberately writes only separate signaturewaves
    % variables. Promotion into the canonical fields is Willapa-specific and
    % scalar only (directional moments stay NaN).
    % - Spectrum: uncalibrated, from a per-burst low edge (where the
    %   Signature acceleration spectrum rises above 3x its own 0.05--0.10 Hz
    %   noise floor, never below 0.10 Hz) to 1.25 Hz; NaN elsewhere. SWIFT25
    %   is a low-signal site (median SBG heave Hs 0.08 m) and Signature
    %   accelerometer noise is additive and dominates below ~0.2 Hz; up to
    %   1.25 Hz the Signature tracks SBG heave within ~8%.
    % - Hs: band Hs times the SBG ratio of record Hs to Hs over the same band
    %   (1.10 on SWIFT25); the band Hs is kept in signaturewaves.
    % On SWIFT25's 1146 records with both sensors (review_SIGheave): band
    % Hs/SBG over the same band 1.01 (RMSE 0.010 m, r 0.98), median low edge
    % 0.24 Hz; full-band Hs/record Hs 0.99 (RMSE 0.015 m, r 0.97), reading
    % ~0.88 for record Hs < 0.06 m and ~1.05 above 0.15 m.
    % review_SIGheave checks the fill against simultaneous SBG records.
    if strcmp(sname,'SWIFT25_16-27Jun2025')
        [SWIFTL3,sinfoL3,signature_diagnostics] = reprocess_SIGheave( ...
            missiondir,fmax=1.25,input_SWIFT=SWIFTL3,input_sinfo=sinfoL3, ...
            save_product=false);
        [SWIFTL3,sinfoL3] = fillWillapaSignatureWaves( ...
            SWIFTL3,sinfoL3,signature_diagnostics.fill_candidate);
        saveWillapaL3(missiondir,SWIFTL3,sinfoL3)
    end

    close all

end

%% Ad Hoc QC

% AdHocQC_WillapaBay

function [SWIFT,sinfo] = fillWillapaSignatureWaves(SWIFT,sinfo,fill)
% SBG waves stay in the standard fields wherever available; records without
% usable SBG waves (fill) take the Signature fallback. Records in the SBG
% outage have no telemetry spectrum, so their frequency grid is NaN and the
% fallback goes on the standard grid of the SBG records.
% wavespectra is rebuilt with the standard fields of the SBG records; which
% records were filled is in sinfo.postproc (flags.filled), the bands in
% signaturewaves.

standard_frequency = standardWaveFrequency(SWIFT);
for i = find(fill(:))'
    fallback = SWIFT(i).signaturewaves;
    output_frequency = SWIFT(i).wavespectra.freq;
    if ~all(isfinite(output_frequency))
        output_frequency = standard_frequency;
    end
    output_size = size(output_frequency);
    energy = interp1(fallback.freq,fallback.energy,output_frequency);

    SWIFT(i).sigwaveheight = fallback.sigwaveheight;
    SWIFT(i).peakwaveperiod = fallback.peakwaveperiod;
    SWIFT(i).peakwavedirT = NaN;
    SWIFT(i).wavespectra = struct('energy',reshape(energy,output_size), ...
        'freq',output_frequency,'a1',NaN(output_size),'b1',NaN(output_size), ...
        'a2',NaN(output_size),'b2',NaN(output_size), ...
        'check',NaN(output_size),'dof',fallback.dof);
end

if isfield(sinfo,'postproc')
    ip = length(sinfo.postproc)+1;
else
    sinfo.postproc = struct;
    ip = 1;
end
sinfo.postproc(ip).type = 'WillapaSignatureHeaveFill';
sinfo.postproc(ip).usr = getenv('username');
sinfo.postproc(ip).time = string(datetime('now'));
sinfo.postproc(ip).flags.filled = fill;
% Each filled record's band is in signaturewaves.measured_band.
first = find(fill(:),1);
if ~isempty(first)
    sinfo.postproc(ip).params.fmax = SWIFT(first).signaturewaves.measured_band(2);
    sinfo.postproc(ip).params.hs_band_factor = SWIFT(first).signaturewaves.hs_band_factor;
else
    sinfo.postproc(ip).params.fmax = NaN;
    sinfo.postproc(ip).params.hs_band_factor = NaN;
end
sinfo.postproc(ip).params.calibrated = false;
sinfo.postproc(ip).params.tail_extrapolated = false;

end

function saveWillapaL3(missiondir,SWIFT,sinfo)

files = dir(fullfile(missiondir,'*SWIFT*L3.mat'));
files = files(~startsWith({files.name},'._'));
if isempty(files)
    error('Process_WillapaMoored:MissingL3', ...
        'No L3 product found in %s.',missiondir)
end
save(fullfile(files(1).folder,files(1).name),'SWIFT','sinfo')

end

function frequency = standardWaveFrequency(SWIFT)

for i = 1:length(SWIFT)
    frequency = SWIFT(i).wavespectra.freq;
    if ~isempty(frequency) && all(isfinite(frequency))
        return
    end
end
error('Process_WillapaMoored:NoWaveFrequency', ...
    'No record has a finite wave frequency grid.')

end
