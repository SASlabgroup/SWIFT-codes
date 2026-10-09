function [metrics,fh,diagnostics] = review_SIGheave(missiondir,opts)

arguments
    missiondir {mustBeTextScalar} % SWIFT mission directory
    opts.fmin (1,1) double {mustBePositive,mustBeFinite} = 0.10 % Lowest recovered frequency, in Hz
    opts.fmax (1,1) double {mustBePositive,mustBeFinite} = 0.50 % Highest recovered frequency, in Hz
    opts.window_seconds (1,1) double {mustBePositive,mustBeFinite} = 256 % Welch window length, in seconds
    opts.accel_counts_per_g (1,1) double {mustBePositive,mustBeFinite} = 16384 % Accelerometer counts per g
    opts.max_reference_hs (1,1) double {mustBePositive,mustBeFinite} = 0.5 % Maximum SBG Hs used for calibration, in m
    opts.calibration_stride (1,1) double {mustBeInteger,mustBePositive} = 5 % Record stride used for calibration
    opts.minimum_calibration_records (1,1) double {mustBeInteger,mustBePositive} = 20 % Required ratios per frequency bin
    opts.plot_file {mustBeTextScalar} = "" % Optional output figure path
end

% Run the complete Signature-heave recovery without writing a product, then
% validate its band-limited Hs against SBG records excluded from calibration.

[~,~,diagnostics] = reprocess_SIGheave(missiondir, ...
    fmin=opts.fmin,fmax=opts.fmax, ...
    window_seconds=opts.window_seconds, ...
    accel_counts_per_g=opts.accel_counts_per_g, ...
    max_reference_hs=opts.max_reference_hs, ...
    calibration_stride=opts.calibration_stride, ...
    minimum_calibration_records=opts.minimum_calibration_records, ...
    save_product=false);

frequency = diagnostics.frequency;
waveband = frequency > opts.fmin & frequency < opts.fmax;
nrecord = length(diagnostics.time);
reference_band_hs = NaN(nrecord,1);
for i = 1:nrecord
    use = waveband & isfinite(diagnostics.reference_energy(i,:)) & ...
        diagnostics.reference_energy(i,:) >= 0;
    if nnz(use) < 2
        continue
    end
    variance = trapz(frequency(use),diagnostics.reference_energy(i,use));
    if isfinite(variance) && variance > 0
        reference_band_hs(i) = 4*sqrt(variance);
    end
end

holdout = diagnostics.reference_qc & ...
    ~diagnostics.calibration_record & ...
    isfinite(reference_band_hs) & isfinite(diagnostics.band_hs);
reference = reference_band_hs(holdout);
estimate = diagnostics.band_hs(holdout);
error = estimate-reference;

metrics.records = nnz(holdout);
if metrics.records >= 2
    correlation = corrcoef(reference,estimate);
    metrics.correlation = correlation(1,2);
else
    metrics.correlation = NaN;
end
metrics.median_bias = median(error,'omitnan');
metrics.median_absolute_error = median(abs(error),'omitnan');
metrics.rmse = sqrt(mean(error.^2,'omitnan'));
metrics.recovered = nnz(diagnostics.recovered);

time = datetime(diagnostics.time,'ConvertFrom','datenum');
fh = figure('Color','w');
layout = tiledlayout(3,1,'TileSpacing','compact','Padding','compact');

ax_series = nexttile;
plot(time,diagnostics.band_hs,'.','MarkerSize',5)
hold on
plot(time(diagnostics.reference_qc), ...
    reference_band_hs(diagnostics.reference_qc),'.','MarkerSize',5)
ylabel('Band H_s (m)')
legend('Signature','SBG','Location','best')
title('Signature-heave validation')

nexttile
plot(reference,estimate,'.')
hold on
limit = max([reference; estimate],[],'omitnan');
plot([0 limit],[0 limit],'k-')
xlabel('SBG band H_s (m)')
ylabel('Signature band H_s (m)')
axis equal
xlim([0 limit])
ylim([0 limit])
title(sprintf('Holdout n = %d, r = %.3f, MAE = %.4f m', ...
    metrics.records,metrics.correlation,metrics.median_absolute_error))

ax_error = nexttile;
plot(time(holdout),error,'.')
yline(0,'k-')
xlabel('Time')
ylabel('Signature - SBG (m)')

linkaxes([ax_series ax_error],'x')
if strlength(string(opts.plot_file)) > 0
    exportgraphics(fh,opts.plot_file,'Resolution',180)
end

diagnostics.reference_band_hs = reference_band_hs;
diagnostics.holdout = holdout;

end
