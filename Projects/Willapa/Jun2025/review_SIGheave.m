function [metrics,figures,diagnostics] = review_SIGheave(missiondir,opts)

arguments
    missiondir {mustBeTextScalar} % SWIFT mission directory
    opts.fmin (1,1) double {mustBePositive,mustBeFinite} = 0.10 % Lowest recovered frequency, in Hz
    opts.fmax (1,1) double {mustBePositive,mustBeFinite} = 0.50 % Highest recovered frequency, in Hz
    opts.window_seconds (1,1) double {mustBePositive,mustBeFinite} = 256 % Welch window length, in seconds
    opts.accel_counts_per_g (1,1) double {mustBePositive,mustBeFinite} = 16384 % Accelerometer counts per g
    opts.max_reference_hs (1,1) double {mustBePositive,mustBeFinite} = 0.5 % Maximum SBG Hs used for calibration, in m
    opts.calibration_stride (1,1) double {mustBeInteger,mustBePositive} = 5 % Record stride used for calibration
    opts.minimum_calibration_records (1,1) double {mustBeInteger,mustBePositive} = 20 % Required ratios per frequency bin
    opts.reprocess_sbg (1,1) logical = true % Run the non-writing SBG step before Signature recovery
    opts.plot_dir {mustBeTextScalar} = "" % Optional directory for validation and effect plots
end

% Run the complete recovery without writing a product, then validate its
% band-limited Hs against SBG records excluded from calibration.

if opts.reprocess_sbg
    if strlength(string(opts.plot_dir)) > 0
        plot_dir = char(opts.plot_dir);
        if ~exist(plot_dir,'dir'); mkdir(plot_dir); end
        report_file = fullfile(plot_dir,'SBG_processing_report.txt');
    else
        report_file = [tempname '.txt'];
    end
    [input_SWIFT,input_sinfo] = reprocess_SBG( ...
        missiondir,false,false,false,true,90, ...
        save_product=false,save_cache=false,report_file=report_file);
    [~,~,diagnostics] = reprocess_SIGheave(missiondir, ...
        fmin=opts.fmin,fmax=opts.fmax, ...
        window_seconds=opts.window_seconds, ...
        accel_counts_per_g=opts.accel_counts_per_g, ...
        max_reference_hs=opts.max_reference_hs, ...
        calibration_stride=opts.calibration_stride, ...
        minimum_calibration_records=opts.minimum_calibration_records, ...
        input_SWIFT=input_SWIFT,input_sinfo=input_sinfo, ...
        save_product=false);
else
    [~,~,diagnostics] = reprocess_SIGheave(missiondir, ...
        fmin=opts.fmin,fmax=opts.fmax, ...
        window_seconds=opts.window_seconds, ...
        accel_counts_per_g=opts.accel_counts_per_g, ...
        max_reference_hs=opts.max_reference_hs, ...
        calibration_stride=opts.calibration_stride, ...
        minimum_calibration_records=opts.minimum_calibration_records, ...
        save_product=false);
end

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
figures.validation = figure('Color','w');
tiledlayout(3,1,'TileSpacing','compact','Padding','compact');

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

diagnostics.reference_band_hs = reference_band_hs;
diagnostics.holdout = holdout;

% Show the spectral and bulk effect using a common time axis. Spectra are
% plotted in log10 units with common color limits so the gap filling is
% visually comparable without implying energy outside the recovered band.
effect_hs = reference_band_hs;
effect_hs(diagnostics.recovered) = diagnostics.band_hs(diagnostics.recovered);
time_number = diagnostics.time;
reference_energy = diagnostics.reference_energy(:,waveband);
signature_energy = diagnostics.calibrated_energy(:,waveband);
reference_energy(reference_energy <= 0) = NaN;
signature_energy(signature_energy <= 0) = NaN;
reference_log_energy = log10(reference_energy);
signature_log_energy = log10(signature_energy);
combined = [reference_log_energy(:); signature_log_energy(:)];
combined = sort(combined(isfinite(combined)));
color_index = max(1,round([0.02 0.98]*length(combined)));
color_limits = combined(color_index);

figures.effect = figure('Color','w');
tiledlayout(3,1,'TileSpacing','compact','Padding','compact');
ax_reference = nexttile;
surf(time_number,frequency(waveband),reference_log_energy', ...
    'EdgeColor','none')
view(2)
axis tight
clim(color_limits)
ylabel('Frequency (Hz)')
title('SBG band energy before Signature recovery')
colorbar

ax_signature = nexttile;
surf(time_number,frequency(waveband),signature_log_energy', ...
    'EdgeColor','none')
view(2)
axis tight
clim(color_limits)
ylabel('Frequency (Hz)')
title('Calibrated Signature band energy')
colorbar

ax_effect = nexttile;
display_values = [reference_band_hs(reference_band_hs <= opts.max_reference_hs); ...
    effect_hs(isfinite(effect_hs))];
display_ymax = 1.08*max(display_values,[],'omitnan');
clipped_reference = reference_band_hs > display_ymax;
reference_display = reference_band_hs;
reference_display(clipped_reference) = display_ymax;
plot(time_number,reference_display,'.','MarkerSize',5)
hold on
plot(time_number,effect_hs,'.','MarkerSize',5)
plot(time_number(diagnostics.recovered), ...
    effect_hs(diagnostics.recovered),'r.','MarkerSize',7)
plot(time_number(clipped_reference),reference_display(clipped_reference), ...
    'k^','MarkerFaceColor','k','MarkerSize',5)
for i = find(clipped_reference)'
    text(time_number(i),0.97*display_ymax, ...
        sprintf(' %.2f m',reference_band_hs(i)), ...
        'VerticalAlignment','top','HorizontalAlignment','center')
end
ylim([0 display_ymax])
ylabel('Band H_s (m)')
xlabel('Time (UTC)')
legend('Before','After','Signature recovery','Off-scale before', ...
    'Location','best')
title(sprintf('%d missing records recovered',metrics.recovered))
linkaxes([ax_reference ax_signature ax_effect],'x')
time_ticks = floor(min(time_number)):ceil(max(time_number));
time_labels = cellstr(string(datetime(time_ticks, ...
    'ConvertFrom','datenum'),'MMM dd'));
set([ax_reference ax_signature ax_effect],'XTick',time_ticks)
set([ax_reference ax_signature],'XTickLabel',[])
set(ax_effect,'XTickLabel',time_labels)

if strlength(string(opts.plot_dir)) > 0
    plot_dir = char(opts.plot_dir);
    if ~exist(plot_dir,'dir'); mkdir(plot_dir); end
    exportgraphics(figures.validation,fullfile(plot_dir, ...
        'SWIFT25_signature_heave_validation.png'),'Resolution',180)
    exportgraphics(figures.effect,fullfile(plot_dir, ...
        'SWIFT25_signature_heave_effect.png'),'Resolution',180)
end

end
