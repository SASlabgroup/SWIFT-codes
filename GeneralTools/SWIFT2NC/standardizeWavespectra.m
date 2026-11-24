function SWIFT = standardizeWavespectra(SWIFT, nFreq, minFreq, deltaFreq)
% Put every burst's wavespectra on one frequency grid
%
%   SWIFT = standardizeWavespectra(SWIFT, nFreq, minFreq, deltaFreq)
%
%   SWIFT      SWIFT struct array, one element per burst
%   nFreq      number of frequency bins to keep
%   minFreq    centre of the first bin (Hz)
%   deltaFreq  bin width (Hz); bin k is minFreq + (k-1)*deltaFreq
%
% Set freq and the per-frequency fields (energy, energy_alt, a1, b1, a2, b2, check) of each burst to
% 1 x nFreq on the grid. Leave the other wavespectra fields (e.g. dof) and bursts without wavespectra
% as they are. For each burst:
%   1. Make each per-frequency field a row of freq's length: replace 9999 (fill from failed
%      processing, e.g. SBGwaves) with NaN, give all-NaN fields freq's length, clip longer fields
%      (warning), and stop with an error on shorter ones.
%   2. Set placeholders (all-zero freq, or fewer than 2 known frequencies) to NaN (warning).
%   3. Snap frequencies within 1e-4 Hz of a grid bin onto it, then interpolate linearly onto the grid,
%      with NaN outside freq's range. Bursts on the grid are only clipped or NaN-padded to nFreq.
%      Warn if a burst is off the grid (interpolated) or has frequencies outside it (dropped).
% If no burst has a per-frequency value left (all NaN), remove wavespectra (warning).
%
% Nov 2026 by M. LeClair (using claude)
%
% Changelog:
%   2026-11-20 M. LeClair w/ claude: standardize wavespectra before saving to netcdf.

arguments
    SWIFT struct
    nFreq (1,1) {mustBeInteger, mustBePositive}
    minFreq (1,1) double
    deltaFreq (1,1) double {mustBePositive}
end

% Set up the fields to standardize and the target grid
perFrequencyNames = ["energy" "energy_alt" "a1" "b1" "a2" "b2" "check"];
freqGrid = minFreq + deltaFreq * (0:nFreq-1);
freqTolerance = 1e-4; % Hz, well below the ~0.01 Hz bin spacing

% Flag the bursts that need each change, to report them at the end
nBursts = numel(SWIFT);
isFilled = false(1, nBursts);
isLengthClipped = false(1, nBursts);
isPlaceholder = false(1, nBursts);
isClipped = false(1, nBursts);
isInterpolated = false(1, nBursts);
hasSpectra = false(1, nBursts); % burst has a per-frequency value that is not NaN after step 3

for burstIndex = 1:nBursts
    % Skip bursts without wavespectra
    spectra = SWIFT(burstIndex).wavespectra;
    if ~isstruct(spectra) || isempty(spectra)
        continue
    end

    % Take freq as a row (empty if missing) and list the per-frequency fields this burst has
    % ('stable' keeps perFrequencyNames' order)
    freq = [];
    if isfield(spectra, 'freq')
        freq = double(spectra.freq(:))';
    end
    fieldNames = intersect(perFrequencyNames, string(fieldnames(spectra))', 'stable');

    % 1. Make every field a row of freq's length: replace the 9999 fill with NaN, give all-NaN fields
    % (e.g. SBGwaves' scalar 9999) freq's length, clip longer fields, and stop on shorter ones (their
    % values may not line up with freq)
    isFilled(burstIndex) = any(freq == 9999);
    freq(freq == 9999) = NaN;
    for fieldName = fieldNames
        values = double(spectra.(fieldName)(:))';
        isFilled(burstIndex) = isFilled(burstIndex) || any(values == 9999);
        values(values == 9999) = NaN;
        if all(isnan(values))
            values = NaN(size(freq));
        elseif numel(values) < numel(freq)
            error('standardizeWavespectra:fieldLength', ...
                'burst %d: wavespectra.%s has %d values, fewer than the %d of wavespectra.freq', ...
                burstIndex, fieldName, numel(values), numel(freq));
        elseif numel(values) > numel(freq)
            isLengthClipped(burstIndex) = true;
            values = values(1:numel(freq));
        end
        spectra.(fieldName) = values;
    end

    % 2. Placeholder (all-zero freq, or too few frequencies to interpolate): set every field to NaN.
    % Report it only if freq has values; empty or all-NaN freq just means no spectra.
    isKnown = ~isnan(freq);
    if sum(isKnown) < 2 || all(freq(isKnown) == 0) % interp1 needs 2 frequencies
        isPlaceholder(burstIndex) = any(isKnown);
        for fieldName = fieldNames
            spectra.(fieldName) = NaN(1, nFreq);
        end

    % 3. Snap frequencies within freqTolerance of a grid bin (any bin, also beyond nFreq) onto it, then
    % interpolate linearly onto the grid. interp1 returns the values exactly at the snapped bins, so
    % bursts on the grid are only clipped or NaN-padded, and gives NaN outside freq's range (no
    % extrapolation).
    else
        binFreq = minFreq + deltaFreq * round((freq - minFreq) / deltaFreq); % nearest bin
        isOnBin = abs(freq - binFreq) <= freqTolerance;
        freq(isOnBin) = binFreq(isOnBin);
        isInterpolated(burstIndex) = any(isKnown & ~isOnBin);
        isClipped(burstIndex) = any(freq(isKnown) < freqGrid(1)   - freqTolerance | ...
                                    freq(isKnown) > freqGrid(end) + freqTolerance);
        for fieldName = fieldNames
            values = spectra.(fieldName);
            spectra.(fieldName) = interp1(freq(isKnown), values(isKnown), freqGrid, 'linear');
            hasSpectra(burstIndex) = hasSpectra(burstIndex) || any(~isnan(spectra.(fieldName)));
        end
    end

    % Store the burst on the grid
    spectra.freq = freqGrid;
    SWIFT(burstIndex).wavespectra = spectra;
end

% Report how many bursts needed each change, and the first of them
warnBursts(isFilled, 'standardizeWavespectra:fill', 'had 9999 in wavespectra, written as NaN');
warnBursts(isLengthClipped, 'standardizeWavespectra:fieldLength', ...
    'had wavespectra fields longer than freq, clipped to freq');
warnBursts(isPlaceholder, 'standardizeWavespectra:placeholder', ...
    'had placeholder wavespectra (all-zero freq, or fewer than 2 frequencies), written as NaN');
warnBursts(isInterpolated, 'standardizeWavespectra:interpolated', ...
    sprintf('had wavespectra.freq off the grid (fmin %g Hz, df %g Hz), linearly interpolated onto it', ...
    minFreq, deltaFreq));
warnBursts(isClipped, 'standardizeWavespectra:clipped', ...
    sprintf('had wave frequencies outside %.4f-%.4f Hz (nFreq = %d), dropped', freqGrid(1), freqGrid(end), nFreq));

% Remove wavespectra if no burst has spectra left, so it is not written
if ~any(hasSpectra)
    SWIFT = rmfield(SWIFT, 'wavespectra');
    warnNoTrace('standardizeWavespectra:noSpectra', 'No burst has wave spectra (all NaN), wavespectra removed');
end
end


function warnBursts(isFlagged, id, message)
% Warn once if any burst is flagged, e.g. '3 burst(s) (first is burst 12) had ...'
if any(isFlagged)
    warnNoTrace(id, '%d burst(s) (first is burst %d) %s', sum(isFlagged), find(isFlagged, 1), message);
end
end


function warnNoTrace(varargin)
% Warn without the "In ... at line ..." stack trace
backtrace = warning('off', 'backtrace');
warning(varargin{:});
warning(backtrace);
end
