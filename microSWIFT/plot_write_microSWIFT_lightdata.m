% script to plot and export as csv the microSWIFT light data 
% which stored as a separate data structure
%
% L. Crews, 4 / 2025
% 

savedir = pwd;
files = dir(['*.mat']);

warning('off', 'all')
disp(newline)

for j = 1:length(files)
    if exist('SWIFTlightdata', 'var')
        clear SWIFTlightdata
    end

    filename = files(j).name;
    load(filename, 'SWIFTlightdata')

    % Extract SWIFT number 
    tokens = regexp(filename, 'microSWIFT(\d+)_telemetry\.mat', 'tokens');    
    if ~isempty(tokens)
        swift_number = str2double(tokens{1}{1});
    end

    if exist('SWIFTlightdata', 'var')

        disp(['microSWIFT ', num2str(swift_number), ...
            ' min light: ' , num2str(min([SWIFTlightdata.lightmin]))...
            ', max light: ' , num2str(max([SWIFTlightdata.lightmax]))])

        %Convert the lightchannels fields to timeseries and plot
        SWIFTlightdata_timeseries = extract_lightchannel_timeseries(SWIFTlightdata);
        plot_lightchannel_timeseries(SWIFTlightdata_timeseries);
        title(['Light data for microSWIFT ', num2str(swift_number)])

        %Save plot
        plot_savename = ['microSWIFT', num2str(swift_number), '_lightdata.png'];
        saveas(gcf, [savedir '/' plot_savename])

        %Save .csv
        csv_savename = ['microSWIFT', num2str(swift_number), '_lightdata.csv'];
        write_SWIFTlightdata_timeseries_to_csv(SWIFTlightdata_timeseries, [savedir '/' csv_savename])

    else
        disp(['No light data for microSWIFT ', num2str(swift_number)])
    end
    
end
 
disp(newline)
warning('on', 'all')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Extracts time series of each light channel from SWIFTlightdata
function SWIFTlightdata_timeseries = extract_lightchannel_timeseries(SWIFTlightdata)

    n = length(SWIFTlightdata);

    % Preallocate
    SWIFTlightdata_timeseries.time = nan(1, n);
    SWIFTlightdata_timeseries.lon = nan(1, n);
    SWIFTlightdata_timeseries.lat = nan(1, n);

    SWIFTlightdata_timeseries.clear   = nan(1, n);
    SWIFTlightdata_timeseries.f1      = nan(1, n);
    SWIFTlightdata_timeseries.f2      = nan(1, n);
    SWIFTlightdata_timeseries.f3      = nan(1, n);
    SWIFTlightdata_timeseries.f4      = nan(1, n);
    SWIFTlightdata_timeseries.f5      = nan(1, n);
    SWIFTlightdata_timeseries.f6      = nan(1, n);
    SWIFTlightdata_timeseries.f7      = nan(1, n);
    SWIFTlightdata_timeseries.f8      = nan(1, n);
    SWIFTlightdata_timeseries.dark    = nan(1, n);
    SWIFTlightdata_timeseries.nearIR  = nan(1, n);

    % Extract data at each timestep
    for j = 1:n
        lc = SWIFTlightdata(j).lightchannels;

        SWIFTlightdata_timeseries.clear(j)   = lc(1);
        SWIFTlightdata_timeseries.f1(j)      = lc(2);
        SWIFTlightdata_timeseries.f2(j)      = lc(3);
        SWIFTlightdata_timeseries.f3(j)      = lc(4);
        SWIFTlightdata_timeseries.f4(j)      = lc(5);
        SWIFTlightdata_timeseries.f5(j)      = lc(6);
        SWIFTlightdata_timeseries.f6(j)      = lc(7);
        SWIFTlightdata_timeseries.f7(j)      = lc(8);
        SWIFTlightdata_timeseries.f8(j)      = lc(9);
        SWIFTlightdata_timeseries.dark(j)    = lc(10);
        SWIFTlightdata_timeseries.nearIR(j)  = lc(11);

        SWIFTlightdata_timeseries.time(j) = SWIFTlightdata(j).time;
        SWIFTlightdata_timeseries.lon(j) = SWIFTlightdata(j).lon;
        SWIFTlightdata_timeseries.lat(j) = SWIFTlightdata(j).lat;

    end
end

% Plots all light channel time series vs time
function plot_lightchannel_timeseries(SWIFTlightdata_timeseries)

    % Extract time
    t = SWIFTlightdata_timeseries.time;

    % Matrix of light channel values
    Y = [
        SWIFTlightdata_timeseries.clear;
        SWIFTlightdata_timeseries.f1;
        SWIFTlightdata_timeseries.f2;
        SWIFTlightdata_timeseries.f3;
        SWIFTlightdata_timeseries.f4;
        SWIFTlightdata_timeseries.f5;
        SWIFTlightdata_timeseries.f6;
        SWIFTlightdata_timeseries.f7;
        SWIFTlightdata_timeseries.f8;
        SWIFTlightdata_timeseries.dark;
        SWIFTlightdata_timeseries.nearIR
    ];

    % Corresponding labels
    labels = {'Clear','f1','f2','f3','f4','f5','f6','f7','f8','Dark','Near IR'};

    cmap = linspecer(length(labels)); %Unique color for each variable

    % Plot
    figure('color', 'w', 'pos', [560   266   851   582])
    hold on
    for j = 1:length(labels)
        plot(t, Y(j, :), 'LineWidth', 1.5, 'Color', cmap(j, :)); 
    end

    legend(labels, 'Location', 'bestoutside');
    xlabel('Time [UTC]');
    ylabel('Light Intensity');
    grid on; box on
    set(gca, 'XTick', [floor(min(t)):(2/24):ceil(max(t))], 'fontsize', 14)
    datetick('x','dd mmm hh:MM','keeplimits', 'keepticks')
    xlim([min(t), max(t)])
    ylim([-200, max(Y(:)) + 1000])
    colormap(cmap);

end

% Saves the timeseries struct as a CSV file
function write_SWIFTlightdata_timeseries_to_csv(SWIFTlightdata_timeseries, filename)

    time = datetime(SWIFTlightdata_timeseries.time, 'ConvertFrom', 'datenum', 'Format', 'yyyy-MM-dd HH:mm:ss');

    % Convert to table
    T = table( ...
        time', ...
        SWIFTlightdata_timeseries.lon', ...
        SWIFTlightdata_timeseries.lat', ...
        SWIFTlightdata_timeseries.clear', ...
        SWIFTlightdata_timeseries.f1', ...
        SWIFTlightdata_timeseries.f2', ...
        SWIFTlightdata_timeseries.f3', ...
        SWIFTlightdata_timeseries.f4', ...
        SWIFTlightdata_timeseries.f5', ...
        SWIFTlightdata_timeseries.f6', ...
        SWIFTlightdata_timeseries.f7', ...
        SWIFTlightdata_timeseries.f8', ...
        SWIFTlightdata_timeseries.dark', ...
        SWIFTlightdata_timeseries.nearIR', ...
        'VariableNames', {'Time (UTC)', 'Longitude', 'Latitude', 'Clear', 'f1', 'f2', 'f3', 'f4', 'f5', 'f6', 'f7', 'f8', 'Dark', 'Near IR'} ...
    );

    % Write to CSV
    writetable(T, filename);
end
 