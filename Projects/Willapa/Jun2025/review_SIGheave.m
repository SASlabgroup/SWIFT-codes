function [metrics,figures,diagnostics] = review_SIGheave(missiondir,opts)

arguments
    missiondir {mustBeTextScalar} % SWIFT mission directory
    opts.fmin (1,1) double {mustBePositive,mustBeFinite} = 0.10 % Lowest band edge, in Hz (see Process_WillapaMoored)
    opts.fmax (1,1) double {mustBePositive,mustBeFinite} = 1.25 % Highest Signature frequency used, in Hz
    opts.accel_counts_per_g (1,1) double {mustBePositive,mustBeFinite} = 16384 % Accelerometer counts per g
    opts.reprocess_sbg (1,1) logical = true % Run the non-writing SBG step before Signature recovery
    opts.plot_dir {mustBeTextScalar} = "" % Optional directory for validation and effect plots
end

% Run the complete recovery without writing a product, then validate it
% against simultaneous, gross-error-free SBG records: the band Hs against SBG
% Hs over each record's band (metrics.*), and the full-band sigwaveheight
% against the record's own Hs, SBGwaves heave over 0.05-2.5 Hz
% (metrics.record_*), which is what a filled record replaces. The figures
% show the full-band comparison.
%
% M. LeClair w/ claude, Oct 2026

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
        accel_counts_per_g=opts.accel_counts_per_g, ...
        input_SWIFT=input_SWIFT,input_sinfo=input_sinfo, ...
        save_product=false);
else
    [~,~,diagnostics] = reprocess_SIGheave(missiondir, ...
        fmin=opts.fmin,fmax=opts.fmax, ...
        accel_counts_per_g=opts.accel_counts_per_g, ...
        save_product=false);
end

frequency = diagnostics.frequency;
waveband = frequency > opts.fmin & frequency < opts.fmax;

% Band Hs against SBG Hs over each record's band.
reference_band_hs = diagnostics.reference_band_hs;
holdout = diagnostics.reference_qc & isfinite(reference_band_hs) & ...
    isfinite(diagnostics.band_hs);
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
metrics.mean_bias = mean(error,'omitnan');
metrics.median_absolute_error = median(abs(error),'omitnan');
metrics.rmse = sqrt(mean(error.^2,'omitnan'));
metrics.median_hs_ratio = median(estimate./reference,'omitnan');
metrics.mean_hs_ratio = mean(estimate./reference,'omitnan');
metrics.recovered = nnz(diagnostics.fill_candidate);
metrics.hs_band_factor = diagnostics.hs_band_factor;
metrics.median_low_edge = median(diagnostics.low_edge,'omitnan');

% Full-band sigwaveheight against the record's own Hs.
record = diagnostics.reference_hs(holdout);
record_estimate = diagnostics.signature_hs(holdout);
record_error = record_estimate-record;
correlation = corrcoef(record,record_estimate);
metrics.record_correlation = correlation(1,2);
metrics.record_median_hs_ratio = median(record_estimate./record,'omitnan');
metrics.record_median_bias = median(record_error,'omitnan');
metrics.record_rmse = sqrt(mean(record_error.^2,'omitnan'));

time = datetime(diagnostics.time,'ConvertFrom','datenum');
figures.validation = figure('Color','w');
tiledlayout(3,1,'TileSpacing','compact','Padding','compact');

ax_series = nexttile;
plot(time,diagnostics.signature_hs,'.','MarkerSize',5)
hold on
plot(time(diagnostics.reference_qc), ...
    diagnostics.reference_hs(diagnostics.reference_qc),'.','MarkerSize',5)
ylabel('H_s (m)')
legend('Signature','SBG','Location','best')
title('Signature-heave validation')

nexttile
plot(record,record_estimate,'.')
hold on
limit = max([record; record_estimate],[],'omitnan');
plot([0 limit],[0 limit],'k-')
xlabel('SBG H_s (m)')
ylabel(sprintf('Signature band H_s x %.3f (m)',diagnostics.hs_band_factor))
axis equal
xlim([0 limit])
ylim([0 limit])
title(sprintf('Holdout n = %d, r = %.3f, RMSE = %.4f m, ratio %.3f', ...
    metrics.records,metrics.record_correlation,metrics.record_rmse, ...
    metrics.record_median_hs_ratio))

ax_error = nexttile;
plot(time(holdout),record_error,'.')
yline(0,'k-')
xlabel('Time')
ylabel('Signature - SBG (m)')

linkaxes([ax_series ax_error],'x')

diagnostics.holdout = holdout;

% Show the spectral and bulk effect using a common time axis. Spectra are
% plotted in log10 units with common color limits so the gap filling is
% visually comparable without implying energy outside the recovered band.
before_hs = diagnostics.reference_hs;
before_hs(~diagnostics.reference_qc) = NaN;
effect_hs = before_hs;
effect_hs(diagnostics.fill_candidate) = ...
    diagnostics.signature_hs(diagnostics.fill_candidate);
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
title(sprintf('Signature energy: |a|-g spectrum /ω^4, %.2f--%.2f Hz (uncalibrated)',opts.fmin,opts.fmax))
colorbar

ax_effect = nexttile;
display_values = sort(effect_hs(isfinite(effect_hs)));
if isempty(display_values)
    display_ymax = 1;
else
    display_ymax = 1.08*display_values( ...
        max(1,round(0.99*length(display_values))));
end
clipped_reference = before_hs > display_ymax;
reference_display = before_hs;
reference_display(clipped_reference) = display_ymax;
plot(time_number,reference_display,'.','MarkerSize',5)
hold on
plot(time_number,effect_hs,'.','MarkerSize',5)
plot(time_number(diagnostics.fill_candidate), ...
    effect_hs(diagnostics.fill_candidate),'r.','MarkerSize',7)
plot(time_number(clipped_reference),reference_display(clipped_reference), ...
    'k^','MarkerFaceColor','k','MarkerSize',5)
for i = find(clipped_reference)'
    text(time_number(i),0.97*display_ymax, ...
        sprintf(' %.2f m',before_hs(i)), ...
        'VerticalAlignment','top','HorizontalAlignment','center')
end
ylim([0 display_ymax])
ylabel('H_s (m)')
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

% Diagnose the band-limited Signature spectrum on the full native SBGwaves
% grid; bins outside the recovered band remain NaN by design.
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

ax_full_signature = nexttile;
plotSpectralCells(ax_full_signature,time_number,frequency,signature_full_log)
clim(full_color_limits)
ylabel('Frequency (Hz)')
title(sprintf('Signature energy: |a|-g spectrum /ω^4, %.2f--%.2f Hz',opts.fmin,opts.fmax))
colorbar
yline(opts.fmin,'w--')
yline(opts.fmax,'w--')

ax_difference = nexttile;
plotSpectralCells(ax_difference,time_number,frequency,spectral_difference_db)
clim([-10 10])
colormap(ax_difference,differenceColormap(256))
ylabel('Frequency (Hz)')
title('Holdout spectral difference: Signature - SBG (dB)')
colorbar
yline(opts.fmin,'k--')
yline(opts.fmax,'k--')

nexttile
plot(frequency,median_difference,'k-','LineWidth',1.2)
hold on
plot(frequency,lower_difference,'b-')
plot(frequency,upper_difference,'r-')
yline(0,'k:')
xline(opts.fmin,'k--')
xline(opts.fmax,'k--')
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
