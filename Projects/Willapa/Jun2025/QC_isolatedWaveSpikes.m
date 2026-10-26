function [SWIFT,qc] = QC_isolatedWaveSpikes(SWIFT,varargin)
%QC_ISOLATEDWAVESPIKES Remove isolated wave-height and spectral-energy spikes.
%
% [SWIFT,qc] = QC_isolatedWaveSpikes(SWIFT)
%
% QC is applied independently to Hs integrated from each physical energy
% spectrum over 0.05 < f < 1 Hz and to the stored bulk Hs. A record is
% rejected when either metric is both:
%
%   1. more than Ratio times the median of finite records within
%      +/- NeighborHours, excluding the record itself; and
%   2. more than its configured minimum excess above that median.
%
% Spectral candidates must also peak below MaximumPeakFrequency. This
% distinguishes the observed low-frequency motion artifacts from isolated
% but physical short-wave records.
%
% The complete wave bundle is rejected together so bulk values and spectra
% cannot disagree after QC. Frequency coordinates are retained.

p = inputParser;
addParameter(p,'NeighborHours',1,@(x) isnumeric(x) && isscalar(x) && x > 0);
addParameter(p,'Ratio',4,@(x) isnumeric(x) && isscalar(x) && x > 1);
addParameter(p,'MinimumExcess',0.25,@(x) isnumeric(x) && isscalar(x) && x > 0);
addParameter(p,'BulkMinimumExcess',0.5,@(x) isnumeric(x) && isscalar(x) && x > 0);
addParameter(p,'MaximumPeakFrequency',0.12,@(x) isnumeric(x) && isscalar(x) && x > 0);
addParameter(p,'MinimumNeighbors',4,@(x) isnumeric(x) && isscalar(x) && x >= 1);
parse(p,varargin{:});

nrecord = length(SWIFT);
times = [SWIFT.time];
spectralHs = NaN(1,nrecord);
peakFrequency = NaN(1,nrecord);
storedHs = NaN(1,nrecord);

if isfield(SWIFT,'sigwaveheight')
    storedHs = [SWIFT.sigwaveheight];
end

for it = 1:nrecord
    if ~isfield(SWIFT(it),'wavespectra') || ...
            ~isfield(SWIFT(it).wavespectra,'freq') || ...
            ~isfield(SWIFT(it).wavespectra,'energy')
        continue
    end

    f = double(SWIFT(it).wavespectra.freq(:));
    E = double(SWIFT(it).wavespectra.energy(:));
    if length(f) ~= length(E)
        continue
    end

    iwave = f > 0.05 & f < 1;
    if nnz(iwave) < 2 || any(~isfinite(E(iwave))) || ...
            any(E(iwave) < 0) || ~any(E(iwave) > 0)
        continue
    end
    spectralHs(it) = 4*sqrt(trapz(f(iwave),E(iwave)));
    waveFrequency = f(iwave);
    waveEnergy = E(iwave);
    [~,ipeak] = max(waveEnergy);
    peakFrequency(it) = waveFrequency(ipeak);
end

localMedianSpectralHs = NaN(1,nrecord);
localMedianStoredHs = NaN(1,nrecord);
spectralOutlier = false(1,nrecord);
bulkOutlier = false(1,nrecord);
waveoutlier = false(1,nrecord);
halfWidth = p.Results.NeighborHours/24;

for it = 1:nrecord
    nearby = abs(times-times(it)) <= halfWidth;
    nearby(it) = false;

    spectralNeighbors = nearby & isfinite(spectralHs);
    if nnz(spectralNeighbors) >= p.Results.MinimumNeighbors && ...
            isfinite(spectralHs(it))
        localMedianSpectralHs(it) = ...
            median(spectralHs(spectralNeighbors),'omitnan');
        spectralOutlier(it) = ...
            spectralHs(it) > p.Results.Ratio*localMedianSpectralHs(it) && ...
            spectralHs(it)-localMedianSpectralHs(it) > ...
                p.Results.MinimumExcess && ...
            peakFrequency(it) < p.Results.MaximumPeakFrequency;
    end

    bulkNeighbors = nearby & isfinite(storedHs);
    if nnz(bulkNeighbors) >= p.Results.MinimumNeighbors && ...
            isfinite(storedHs(it))
        localMedianStoredHs(it) = median(storedHs(bulkNeighbors),'omitnan');
        bulkOutlier(it) = ...
            storedHs(it) > p.Results.Ratio*localMedianStoredHs(it) && ...
            storedHs(it)-localMedianStoredHs(it) > ...
                p.Results.BulkMinimumExcess;
    end

    waveoutlier(it) = spectralOutlier(it) || bulkOutlier(it);
end

bulkFields = {'sigwaveheight','peakwaveperiod','peakwavedirT'};
spectralFields = {'energy','a1','b1','a2','b2','check'};

for it = find(waveoutlier)
    for ivar = 1:length(bulkFields)
        name = bulkFields{ivar};
        if isfield(SWIFT(it),name)
            SWIFT(it).(name) = NaN(size(SWIFT(it).(name)));
        end
    end

    if isfield(SWIFT(it),'wavespectra')
        for ivar = 1:length(spectralFields)
            name = spectralFields{ivar};
            if isfield(SWIFT(it).wavespectra,name)
                SWIFT(it).wavespectra.(name) = ...
                    NaN(size(SWIFT(it).wavespectra.(name)));
            end
        end
    end
end

qc.flag = waveoutlier;
qc.time = times(waveoutlier);
qc.spectralHs = spectralHs;
qc.storedHs = storedHs;
qc.peakFrequency = peakFrequency;
qc.localMedianSpectralHs = localMedianSpectralHs;
qc.localMedianStoredHs = localMedianStoredHs;
qc.spectralOutlier = spectralOutlier;
qc.bulkOutlier = bulkOutlier;
qc.params = p.Results;

end
