function [metrics,figures,diagnostics] = review_SIGheave(missiondir,opts)

arguments
    missiondir {mustBeTextScalar} % SWIFT mission directory
    opts.fmin (1,1) double {mustBePositive,mustBeFinite} = 0.05 % Canonical Hs lower frequency, in Hz
    opts.fmax (1,1) double {mustBePositive,mustBeFinite} = 2.00 % Highest measured Signature frequency, in Hz
    opts.tail_fmax (1,1) double {mustBePositive,mustBeFinite} = 2.50 % Upper frequency of extrapolated tail, in Hz
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
        fmin=opts.fmin,fmax=opts.fmax,tail_fmax=opts.tail_fmax, ...
        window_seconds=opts.window_seconds, ...
        accel_counts_per_g=opts.accel_counts_per_g, ...
        max_reference_hs=opts.max_reference_hs, ...
        calibration_stride=opts.calibration_stride, ...
        minimum_calibration_records=opts.minimum_calibration_records, ...
        input_SWIFT=input_SWIFT,input_sinfo=input_sinfo, ...
        save_product=false);
else
    [~,~,diagnostics] = reprocess_SIGheave(missiondir, ...
        fmin=opts.fmin,fmax=opts.fmax,tail_fmax=opts.tail_fmax, ...
        window_seconds=opts.window_seconds, ...
        accel_counts_per_g=opts.accel_counts_per_g, ...
        max_reference_hs=opts.max_reference_hs, ...
        calibration_stride=opts.calibration_stride, ...
        minimum_calibration_records=opts.minimum_calibration_records, ...
        save_product=false);
end

frequency = diagnostics.frequency;
waveband = frequency > opts.fmin & frequency < opts.tail_fmax;

holdout = diagnostics.reference_qc & ...
    ~diagnostics.calibration_record & ...
    isfinite(diagnostics.reference_hs) & ...
    isfinite(diagnostics.canonical_hs);
reference = diagnostics.reference_hs(holdout);
estimate = diagnostics.canonical_hs(holdout);
error = estimate-reference;

metrics.records = nnz(holdout);
if metrics.records >= 2
    correlation = corrcoef(reference,estimate);
    metrics.correlation = correlation(1,2);
else
    metrics.correlation = NaN;
end
metrics.median_bias = median(error,'omitnan');
metrics.mean_bias = mean(error,'omitnan');
metrics.median_absolute_error = median(abs(error),'omitnan');
metrics.rmse = sqrt(mean(error.^2,'omitnan'));
metrics.median_hs_ratio = median(estimate./reference,'omitnan');
metrics.mean_hs_ratio = mean(estimate./reference,'omitnan');
metrics.recovered = nnz(diagnostics.recovered);

time = datetime(diagnostics.time,'ConvertFrom','datenum');
figures.validation = figure('Color','w');
tiledlayout(3,1,'TileSpacing','compact','Padding','compact');

ax_series = nexttile;
plot(time,diagnostics.canonical_hs,'.','MarkerSize',5)
hold on
plot(time(diagnostics.reference_qc), ...
    diagnostics.reference_hs(diagnostics.reference_qc),'.','MarkerSize',5)
ylabel('H_s (m)')
legend('Signature','SBG','Location','best')
title('Signature-heave validation')

nexttile
plot(reference,estimate,'.')
hold on
limit = max([reference; estimate],[],'omitnan');
plot([0 limit],[0 limit],'k-')
xlabel('SBG H_s (m)')
ylabel('Estimated H_s (m)')
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

diagnostics.holdout = holdout;

% Show the spectral and bulk effect using a common time axis. Spectra are
% plotted in log10 units with common color limits so the gap filling is
% visually comparable without implying energy outside the recovered band.
effect_hs = diagnostics.reference_hs;
effect_hs(diagnostics.recovered) = ...
    diagnostics.canonical_hs(diagnostics.recovered);
time_number = diagnostics.time;
reference_energy = diagnostics.reference_energy(:,waveband);
signature_energy = diagnostics.signature_energy(:,waveband);
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
title('Signature energy: calibrated 0.05--2 Hz, extrapolated 2--2.5 Hz')
colorbar

ax_effect = nexttile;
display_values = [diagnostics.reference_hs( ...
    diagnostics.reference_hs <= opts.max_reference_hs); ...
    effect_hs(isfinite(effect_hs))];
display_ymax = 1.08*max(display_values,[],'omitnan');
clipped_reference = diagnostics.reference_hs > display_ymax;
reference_display = diagnostics.reference_hs;
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
        sprintf(' %.2f m',diagnostics.reference_hs(i)), ...
        'VerticalAlignment','top','HorizontalAlignment','center')
end
ylim([0 display_ymax])
ylabel('Canonical H_s (m)')
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

% Diagnose the calibrated and extrapolated Signature spectrum over the same
% native 0.05--2.5 Hz grid used by SBGwaves.
full_signature_energy = diagnostics.signature_energy;
spectral_difference_db = 10*log10(full_signature_energy./ ...
    diagnostics.reference_energy);
spectral_difference_db(~holdout,:) = NaN;
spectral_difference_db(~isfinite(spectral_difference_db)) = NaN;

reference_full_log = log10(diagnostics.reference_energy);
signature_full_log = log10(full_signature_energy);
reference_full_log(~isfinite(reference_full_log)) = NaN;
signature_full_log(~isfinite(signature_full_log)) = NaN;
full_combined = sort([reference_full_log(:); signature_full_log(:)]);
full_combined = full_combined(isfinite(full_combined));
full_color_index = max(1,round([0.02 0.98]*length(full_combined)));
full_color_limits = full_combined(full_color_index);

median_difference = NaN(size(frequency));
lower_difference = NaN(size(frequency));
upper_difference = NaN(size(frequency));
for i = 1:length(frequency)
    values = sort(spectral_difference_db(:,i));
    values = values(isfinite(values));
    if isempty(values); continue; end
    median_difference(i) = median(values);
    lower_difference(i) = values(max(1,round(0.25*length(values))));
    upper_difference(i) = values(max(1,round(0.75*length(values))));
end

figures.spectral_difference = figure('Color','w');
tiledlayout(4,1,'TileSpacing','compact','Padding','compact');
ax_full_reference = nexttile;
plotSpectralCells(ax_full_reference,time_number,frequency,reference_full_log)
clim(full_color_limits)
ylabel('Frequency (Hz)')
title('SBG energy: full non-overlapping frequency grid')
colorbar
yline(opts.fmin,'w--')
yline(opts.fmax,'w--')
yline(opts.tail_fmax,'w--')

ax_full_signature = nexttile;
plotSpectralCells(ax_full_signature,time_number,frequency,signature_full_log)
clim(full_color_limits)
ylabel('Frequency (Hz)')
title('Signature energy: measured through 2 Hz, extrapolated tail above')
colorbar
yline(opts.fmin,'w--')
yline(opts.fmax,'w--')
yline(opts.tail_fmax,'w--')

ax_difference = nexttile;
plotSpectralCells(ax_difference,time_number,frequency,spectral_difference_db)
clim([-10 10])
colormap(ax_difference,differenceColormap(256))
ylabel('Frequency (Hz)')
title('Holdout spectral difference: Signature - SBG (dB)')
colorbar
yline(opts.fmin,'k--')
yline(opts.fmax,'k--')
yline(opts.tail_fmax,'k--')

nexttile
plot(frequency,median_difference,'k-','LineWidth',1.2)
hold on
plot(frequency,lower_difference,'b-')
plot(frequency,upper_difference,'r-')
yline(0,'k:')
xline(opts.fmin,'k--')
xline(opts.fmax,'k--')
xline(opts.tail_fmax,'k--')
xlim([frequency(1) frequency(end)])
xlabel('Frequency (Hz)')
ylabel('Difference (dB)')
legend('Median','25th percentile','75th percentile', ...
    'Location','best')
title('Frequency-resolved holdout bias')

linkaxes([ax_full_reference ax_full_signature ax_difference],'x')
full_time_ticks = floor(min(time_number)):ceil(max(time_number));
full_time_labels = cellstr(string(datetime(full_time_ticks, ...
    'ConvertFrom','datenum'),'MMM dd'));
set([ax_full_reference ax_full_signature ax_difference], ...
    'XTick',full_time_ticks)
set([ax_full_reference ax_full_signature],'XTickLabel',[])
set(ax_difference,'XTickLabel',full_time_labels)

diagnostics.spectral_difference_db = spectral_difference_db;

if strlength(string(opts.plot_dir)) > 0
    plot_dir = char(opts.plot_dir);
    if ~exist(plot_dir,'dir'); mkdir(plot_dir); end
    exportgraphics(figures.validation,fullfile(plot_dir, ...
        'SWIFT25_signature_heave_validation.png'),'Resolution',180)
    exportgraphics(figures.effect,fullfile(plot_dir, ...
        'SWIFT25_signature_heave_effect.png'),'Resolution',180)
    exportgraphics(figures.spectral_difference,fullfile(plot_dir, ...
        'SWIFT25_signature_heave_spectral_difference.png'),'Resolution',180)
end

end

function plotSpectralCells(ax,time,frequency,values)

% Put records on the regular ten-minute grid before imagesc so each time and
% frequency bin is a discrete, non-overlapping cell and data gaps stay blank.
time = time(:);
time_step = median(diff(unique(time)),'omitnan');
time_grid = (min(time):time_step:max(time))';
grid_values = NaN(length(time_grid),length(frequency));
slot = round((time-min(time))/time_step)+1;
grid_values(slot,:) = values;
image_handle = imagesc(ax,time_grid,frequency,grid_values');
set(image_handle,'AlphaData',isfinite(grid_values'))
set(ax,'YDir','normal')
axis(ax,'tight')

end

function map = differenceColormap(count)

half = floor(count/2);
blue = [0.230 0.299 0.754];
white = [1 1 1];
red = [0.706 0.016 0.150];
lower = [linspace(blue(1),white(1),half)', ...
    linspace(blue(2),white(2),half)', ...
    linspace(blue(3),white(3),half)'];
upper_count = count-half;
upper = [linspace(white(1),red(1),upper_count)', ...
    linspace(white(2),red(2),upper_count)', ...
    linspace(white(3),red(3),upper_count)'];
map = [lower; upper];

end
