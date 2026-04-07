function pullSWIFTtelemetryGUI()
% GUI wrapper for pullSWIFTtelemetry with built-in data visualization.
%
% Tab 1 – Pull Telemetry: enter IDs, time range, output directory, pull data.
% Tab 2 – Visualize: load compiled .mat files, map tracks, time series.
%
% Usage:  pullSWIFTtelemetryGUI()
%
% Requires pullSWIFTtelemetry.m and its dependencies on the MATLAB path.
% Requires MATLAB R2020b or later (uigridlayout, scroll on uitextarea).
%
%  M. LeClair, 2026

%% ---- Version check ---------------------------------------------------------
if verLessThan('matlab', '9.9')   % 9.9 = R2020b
    error('pullSWIFTtelemetryGUI requires MATLAB R2020b (9.9) or later. Current version: %s', version);
end

%% ---- Shared state ----------------------------------------------------------
% Variables declared here in the outer function are accessible to all nested
% callback functions below (MATLAB closure / shared workspace pattern).
loadedSWIFT = {};   % cell array: each cell holds full SWIFT struct array for one buoy
loadedIDs   = {};   % cell array of ID strings (one per SWIFT struct)

%% ---- Figure & tab group ----------------------------------------------------
% uifigure creates a modern "App Designer"-style window (introduced R2016a).
% It is NOT the same as the legacy `figure` command — it uses a different
% rendering engine and supports uigridlayout, uidropdown, uitextarea, etc.
fig = uifigure( ...
    'Name',     'SWIFT Telemetry Puller', ...
    'Position', [60 60 1100 680], ...   % [left bottom width height] in pixels
    'Resize',   'on');

% uitabgroup holds multiple uitab pages; the user clicks tab titles to switch.
% Setting Position to [0 0 1 1] with normalized Units makes it fill the figure.
tg = uitabgroup(fig, 'Units', 'normalized', 'Position', [0 0 1 1]);

tab1 = uitab(tg, 'Title', '  Pull Telemetry  ');
tab2 = uitab(tg, 'Title', '  Visualize  ');

%% ==========================================================================
%%  TAB 1 – Pull Telemetry
%% ==========================================================================

% uigridlayout divides a container into a grid of rows and columns.
% Row/column sizes can be fixed pixels (e.g. 20) or fractional ('1x', '2x').
% Fractional sizes divide whatever space is left after fixed rows/columns are
% allocated: '1x' gets all of it, '1x'+'2x' gives 1/3 and 2/3 respectively.
t1Grid = uigridlayout(tab1, [1 2]);    % 1 row, 2 columns
t1Grid.ColumnWidth  = {'1x', '2x'};   % left panel gets 1/3, right gets 2/3
t1Grid.RowHeight    = {'1x'};          % single row fills the full tab height
t1Grid.Padding      = [8 8 8 8];       % [left top right bottom] padding in px
t1Grid.ColumnSpacing = 8;

%% ---- Left panel (inputs) --------------------------------------------------
% uipanel is a grouping container that draws a titled border around its children.
% Placing it inside t1Grid and setting Layout.Row/Column tells the grid where to put it.
leftPanel = uipanel(t1Grid, 'Title', 'Parameters');
leftPanel.Layout.Row    = 1;   % place in grid row 1 ...
leftPanel.Layout.Column = 1;   % ... column 1

% Nest another uigridlayout inside the panel for fine-grained row control.
% Fixed pixel heights keep labels/buttons compact; '1x' on the text area lets
% it expand to fill whatever vertical space remains as the window is resized.
lg = uigridlayout(leftPanel, [19 1]);  % 19 rows, 1 column
lg.RowHeight  = { ...
    20, ...   % 1  label: Recent
    28, ...   % 2  recentDD dropdown
     8, ...   % 3  spacer
    20, ...   % 4  label: Active Buoys
    28, ...   % 5  activeBuoysDD + Refresh button row
    26, ...   % 6  Add to IDs button
     8, ...   % 7  spacer
    20, ...   % 8  label: SWIFT IDs
   '1x', ...  % 9  idsArea text area (grows with window height)
    10, ...   % 10 spacer
    20, ...   % 11 label: Start Time
    28, ...   % 12 startDP + time field
    10, ...   % 13 spacer
    20, ...   % 14 label: End Time
    28, ...   % 15 endDP + time field + Now checkbox
    10, ...   % 16 spacer
    36, ...   % 17 output dir field + Browse button
    36, ...   % 18 Pull Telemetry button
    22};      % 19 Clear Saved Preferences button
lg.Padding    = [8 8 8 8];
lg.RowSpacing = 2;

% -- Recent parameters dropdown --
% `@recentDDCB` is a function handle — MATLAB calls recentDDCB(src, event)
% whenever the dropdown value changes. Callbacks always receive two arguments:
% the source widget (src) and an event object; we often ignore them with ~.
mkLabel(lg, 1, 'Recent');
recentDD = uidropdown(lg, 'Items', {'(no history yet)'}, ...
    'ValueChangedFcn', @recentDDCB);
recentDD.Layout.Row = 2;  recentDD.Layout.Column = 1;

spacer(lg, 3);

% -- Active Buoys from server --
% A nested uigridlayout inside a single grid cell splits that cell into
% sub-columns, here placing the dropdown and Refresh button side by side.
mkLabel(lg, 4, 'Active Buoys');
activeBuoysGrid = uigridlayout(lg, [1 2]);
activeBuoysGrid.Layout.Row = 5;  activeBuoysGrid.Layout.Column = 1;
activeBuoysGrid.ColumnWidth = {'1x', 75};
activeBuoysGrid.Padding = [0 0 0 0];
activeBuoysDD = uidropdown(activeBuoysGrid, 'Items', {'(loading...)'});
activeBuoysDD.Layout.Row = 1;  activeBuoysDD.Layout.Column = 1;
refreshBuoysBtn = uibutton(activeBuoysGrid, 'Text', 'Refresh', ...
    'ButtonPushedFcn', @refreshBuoysCB);
refreshBuoysBtn.Layout.Row = 1;  refreshBuoysBtn.Layout.Column = 2;

addBuoyBtn = uibutton(lg, 'Text', 'Add to IDs', 'ButtonPushedFcn', @addBuoyCB);
addBuoyBtn.Layout.Row = 6;  addBuoyBtn.Layout.Column = 1;

spacer(lg, 7);

% -- IDs --
mkLabel(lg, 8, 'SWIFT IDs  (one per line)');
idsArea = uitextarea(lg, 'Value', {'16'; '17'}, ...
    'FontName', 'Courier New', ...
    'Tooltip',  'SWIFT v3/v4: 2-digit IDs (e.g. 16)   microSWIFT: 3-digit IDs (e.g. 016)');
idsArea.Layout.Row = 9;  idsArea.Layout.Column = 1;

spacer(lg, 10);
mkLabel(lg, 11, 'Start Time (UTC)');

startGrid = uigridlayout(lg, [1 2]);
startGrid.Layout.Row = 12;  startGrid.Layout.Column = 1;
startGrid.ColumnWidth = {'1x', 85};
startGrid.Padding = [0 0 0 0];
startDP = uidatepicker(startGrid, ...
    'Value',         datetime(now - 1, 'ConvertFrom', 'datenum'), ...
    'DisplayFormat', 'yyyy-MM-dd');
startDP.Layout.Row = 1;  startDP.Layout.Column = 1;
startTimeField = uieditfield(startGrid, 'text', ...
    'Value', '00:00:00', 'Placeholder', 'HH:MM:SS', 'FontName', 'Courier New', ...
    'Tooltip', 'Time of day (HH:MM:SS)');
startTimeField.Layout.Row = 1;  startTimeField.Layout.Column = 2;

spacer(lg, 13);
mkLabel(lg, 14, 'End Time (UTC)');

endGrid = uigridlayout(lg, [1 3]);
endGrid.Layout.Row = 15;  endGrid.Layout.Column = 1;
endGrid.ColumnWidth = {'1x', 85, 80};
endGrid.Padding = [0 0 0 0];
endDP = uidatepicker(endGrid, ...
    'Value',         NaT, ...
    'DisplayFormat', 'yyyy-MM-dd', ...
    'Placeholder',   'end date');
endDP.Layout.Row = 1;  endDP.Layout.Column = 1;
endTimeField = uieditfield(endGrid, 'text', ...
    'Value', '', 'Placeholder', 'HH:MM:SS', 'FontName', 'Courier New', ...
    'Tooltip', 'Time of day (HH:MM:SS)');
endTimeField.Layout.Row = 1;  endTimeField.Layout.Column = 2;
nowCheck = uicheckbox(endGrid, 'Text', 'Now', 'Value', true, ...
    'ValueChangedFcn', @nowCheckCB);
nowCheck.Layout.Row = 1;  nowCheck.Layout.Column = 3;
endDP.Enable        = 'off';
endTimeField.Enable = 'off';

spacer(lg, 16);

% -- Output directory --
dirRowGrid = uigridlayout(lg, [1 2]);
dirRowGrid.Layout.Row = 17;  dirRowGrid.Layout.Column = 1;
dirRowGrid.ColumnWidth = {'1x', 90};
dirRowGrid.Padding = [0 0 0 0];
dirField = uieditfield(dirRowGrid, 'text', 'Value', pwd, 'FontName', 'Courier New');
dirField.Layout.Row = 1;  dirField.Layout.Column = 1;
browseBtn = uibutton(dirRowGrid, 'Text', 'Browse...', 'ButtonPushedFcn', @browseDirCB);
browseBtn.Layout.Row = 1;  browseBtn.Layout.Column = 2;

% Row 18 is a fixed 36 px, so the button is the same height as the other
% action rows rather than expanding to fill all remaining space.
runBtn = uibutton(lg, ...
    'Text', 'Pull Telemetry', 'FontWeight', 'bold', 'FontSize', 13, ...
    'BackgroundColor', [0.18 0.55 0.34], 'FontColor', [1 1 1], ...
    'ButtonPushedFcn', @runCB);
runBtn.Layout.Row = 18;  runBtn.Layout.Column = 1;

clearPrefsBtn = uibutton(lg, ...
    'Text', 'Clear Saved Preferences', 'FontSize', 10, ...
    'ButtonPushedFcn', @clearPrefsCB);
clearPrefsBtn.Layout.Row = 19;  clearPrefsBtn.Layout.Column = 1;

loadPrefs();  % restore last-used parameters + populate recent dropdown

%% ---- Right panel (results table + log) ------------------------------------
rightPanel = uipanel(t1Grid, 'Title', 'Results');
rightPanel.Layout.Row = 1;  rightPanel.Layout.Column = 2;

% '1x' on the log row lets the text area grow as the window is resized.
rg = uigridlayout(rightPanel, [4 1]);
rg.RowHeight  = {22, 200, 22, '1x'};
rg.Padding    = [8 8 8 8];
rg.RowSpacing = 4;

mkLabel(rg, 1, 'Summary');
resultsTable = uitable(rg, ...
    'ColumnName',  {'ID', 'Last Time (UTC)', 'Lat', 'Lon', 'Battery (V)'}, ...
    'Data', {}, 'RowName', {}, ...
    'ColumnWidth', {55, 170, 85, 85, 90});
resultsTable.Layout.Row = 2;  resultsTable.Layout.Column = 1;

mkLabel(rg, 3, 'Log');
logArea = uitextarea(rg, 'Editable', 'off', 'FontName', 'Courier New', 'FontSize', 11, ...
    'Value', {'Ready. Set parameters and press  ''Pull Telemetry''.'});
logArea.Layout.Row = 4;  logArea.Layout.Column = 1;

fetchActiveBuoys();  % populate active buoys dropdown on startup

%% ==========================================================================
%%  TAB 2 – Visualize
%% ==========================================================================

t2Grid = uigridlayout(tab2, [1 2]);
t2Grid.ColumnWidth   = {260, '1x'};
t2Grid.RowHeight     = {'1x'};
t2Grid.Padding       = [8 8 8 8];
t2Grid.ColumnSpacing = 8;

%% ---- Viz control panel ----------------------------------------------------
vizCtrl = uipanel(t2Grid, 'Title', 'Load & Filter');
vizCtrl.Layout.Row = 1;  vizCtrl.Layout.Column = 1;

vc = uigridlayout(vizCtrl, [14 1]);
vc.RowHeight  = {36, 10, 20, 100, 10, 20, 22, 10, 20, 22, 10, 20, 22, '1x'};
vc.Padding    = [8 8 8 8];
vc.RowSpacing = 2;

loadBtn = uibutton(vc, ...
    'Text', 'Load .mat Files...', 'FontWeight', 'bold', 'FontSize', 12, ...
    'BackgroundColor', [0.22 0.45 0.70], 'FontColor', [1 1 1], ...
    'ButtonPushedFcn', @loadMatCB);
loadBtn.Layout.Row = 1;  loadBtn.Layout.Column = 1;

spacer(vc, 2);
mkLabel(vc, 3, 'Loaded SWIFTs');
loadedListBox = uilistbox(vc, 'Items', {}, 'Multiselect', 'on');
loadedListBox.Layout.Row = 4;  loadedListBox.Layout.Column = 1;
loadedListBox.ValueChangedFcn = @vizUpdateCB;

spacer(vc, 5);
mkLabel(vc, 6, 'Color tracks by');
colorDD = uidropdown(vc, ...
    'Items', {'SWIFT ID', 'Time', 'Battery', 'Hs', 'Water Temp', 'Salinity'}, ...
    'Value', 'SWIFT ID', 'ValueChangedFcn', @vizUpdateCB);
colorDD.Layout.Row = 7;  colorDD.Layout.Column = 1;

spacer(vc, 8);
mkLabel(vc, 9, 'Time series — variable 1');
ts1DD = uidropdown(vc, ...
    'Items', {'sigwaveheight', 'peakwaveperiod', 'windspd', 'watertemp', 'salinity', 'battery'}, ...
    'Value', 'sigwaveheight', 'ValueChangedFcn', @vizUpdateCB);
ts1DD.Layout.Row = 10;  ts1DD.Layout.Column = 1;

spacer(vc, 11);
mkLabel(vc, 12, 'Time series — variable 2');
ts2DD = uidropdown(vc, ...
    'Items', {'watertemp', 'salinity', 'battery', 'sigwaveheight', 'peakwaveperiod', 'windspd'}, ...
    'Value', 'watertemp', 'ValueChangedFcn', @vizUpdateCB);
ts2DD.Layout.Row = 13;  ts2DD.Layout.Column = 1;

%% ---- compi panel -----------------------------------------------------------
plotPanel = uipanel(t2Grid, 'Title', 'Plots');
plotPanel.Layout.Row = 1;  plotPanel.Layout.Column = 2;

pg = uigridlayout(plotPanel, [2 2]);
pg.RowHeight    = {'1x', '1x'};
pg.ColumnWidth  = {'1x', '1x'};
pg.Padding      = [6 6 6 6];
pg.RowSpacing   = 6;
pg.ColumnSpacing = 6;

axMap  = uiaxes(pg);  axMap.Layout.Row  = [1 2];  axMap.Layout.Column  = 1;
axTS1  = uiaxes(pg);  axTS1.Layout.Row  = 1;       axTS1.Layout.Column  = 2;
axTS2  = uiaxes(pg);  axTS2.Layout.Row  = 2;       axTS2.Layout.Column  = 2;

xlabel(axMap, 'Longitude');  ylabel(axMap, 'Latitude');
title(axMap,  'Position Tracks');
grid(axMap, 'on');  box(axMap, 'on');

xlabel(axTS1, 'Time (UTC)');
grid(axTS1, 'on');  box(axTS1, 'on');

xlabel(axTS2, 'Time (UTC)');
grid(axTS2, 'on');  box(axTS2, 'on');

%% ==========================================================================
%%  Callbacks – Tab 1 (Pull)
%% ==========================================================================
% All callbacks are nested functions so they share the outer workspace:
% they can read/write widgets (runBtn, logArea, etc.) and state variables
% (loadedSWIFT, loadedIDs) without passing them as arguments.
%
% The `~` in function signatures discards the two arguments that MATLAB
% always passes to callbacks: the source widget and the event object.

    function browseDirCB(~, ~)
        d = uigetdir(dirField.Value, 'Select Output Directory');
        if ischar(d) && ~isequal(d, 0)
            dirField.Value = d;
        end
    end

    function nowCheckCB(~, ~)
        if nowCheck.Value
            endDP.Enable        = 'off';
            endTimeField.Enable = 'off';
        else
            endDP.Enable        = 'on';
            endTimeField.Enable = 'on';
        end
    end

    function runCB(~, ~)
        rawIDs   = idsArea.Value;
        startStr = buildISO(startDP, startTimeField);
        if nowCheck.Value
            endStr = '';
        else
            endStr = buildISO(endDP, endTimeField);
        end
        outDir = strtrim(dirField.Value);

        % Build list of IDs
        idList = {};
        for k = 1:numel(rawIDs)
            id = strtrim(rawIDs{k});
            if ~isempty(id), idList{end+1} = id; end %#ok<AGROW>
        end
        if isempty(idList)
            appendLog(logArea, 'ERROR: No SWIFT IDs entered.'); return
        end

        % Type is inferred from ID length: 2-digit = v3/v4, 3-digit = microSWIFT
        lens = cellfun(@numel, idList);
        if ~all(lens == lens(1)) || ~any(lens(1) == [2 3])
            appendLog(logArea, 'ERROR: All IDs must be the same length: 2-digit (SWIFT v3/v4) or 3-digit (microSWIFT).');
            return
        end
        IDs = char(idList);

        if isempty(startStr)
            appendLog(logArea, 'ERROR: Start time is required.'); return
        end

        origDir = pwd;
        try
            cd(outDir);
        catch ME
            appendLog(logArea, ['ERROR changing directory: ' ME.message]); return
        end

        savePrefs();  % cache parameters before running

        runBtn.Enable = 'off';  runBtn.Text = 'Running...';
        drawnow;  % flush the event queue so the button visually updates before the long pull

        appendLog(logArea, repmat('-',1,60));
        appendLog(logArea, ['Pull started: ' datestr(now,'yyyy-mm-dd HH:MM:SS')]);
        appendLog(logArea, ['IDs:   ' strjoin(idList,', ')]);
        appendLog(logArea, ['Start: ' startStr]);
        appendLog(logArea, ['End:   ' endStr]);
        appendLog(logArea, ['Dir:   ' outDir]);
        drawnow;

        try
            [batteries, lastTimes, lastLats, lastLons] = ...
                pullSWIFTtelemetry(IDs, startStr, endStr, false);

            nSWIFT    = size(IDs, 1);
            tableData = cell(nSWIFT, 5);
            for si = 1:nSWIFT
                idStr = strtrim(IDs(si,:));
                tStr  = 'N/A';
                if lastTimes(si) > 0
                    tStr = datestr(lastTimes(si),'yyyy-mm-dd HH:MM:SS');
                end
                tableData(si,:) = {idStr, tStr, lastLats(si), lastLons(si), batteries(si)};
                appendLog(logArea, sprintf( ...
                    '  SWIFT %s  |  %s  |  Lat %+.4f  Lon %+.5f  |  %.2f V', ...
                    idStr, tStr, lastLats(si), lastLons(si), batteries(si)));
            end
            resultsTable.Data = tableData;
            appendLog(logArea, ['Complete: ' datestr(now,'yyyy-mm-dd HH:MM:SS')]);

            % Auto-load pulled .mat files into Visualize tab
            autoViz(outDir);

        catch ME
            appendLog(logArea, ['ERROR: ' ME.message]);
            for fi = 1:numel(ME.stack)
                appendLog(logArea, sprintf('  at %s (line %d)', ...
                    ME.stack(fi).name, ME.stack(fi).line));
            end
        end

        cd(origDir);
        runBtn.Enable = 'on';  runBtn.Text = 'Pull Telemetry';
    end

%% ==========================================================================
%%  Callbacks – Tab 2 (Visualize)
%% ==========================================================================

    function loadMatCB(~, ~)
        startDir = dirField.Value;
        if ~isfolder(startDir), startDir = pwd; end

        [files, fpath] = uigetfile( ...
            {'*telemetry.mat;*.mat', 'SWIFT mat files (*.mat)'}, ...
            'Select compiled SWIFT .mat files', ...
            startDir, 'MultiSelect', 'on');

        if isequal(files, 0), return; end
        if ischar(files), files = {files}; end

        for f = 1:numel(files)
            fullpath = fullfile(fpath, files{f});
            try
                S = load(fullpath);  % expects variable 'SWIFT'
                if ~isfield(S, 'SWIFT')
                    appendLog(logArea, ['Skip (no SWIFT var): ' files{f}]);
                    continue
                end
                sw = S.SWIFT;
                if isempty(sw), continue; end

                % Guess ID from filename  e.g. "SWIFT16_telemetry.mat"
                tok = regexp(files{f}, 'SWIFT\s*(\w+)_', 'tokens');
                if ~isempty(tok)
                    idStr = tok{1}{1};
                else
                    idStr = files{f};
                end

                % Append or replace
                idx = find(strcmp(loadedIDs, idStr), 1);
                if isempty(idx)
                    loadedIDs{end+1}   = idStr;
                    loadedSWIFT{end+1} = sw; %#ok<AGROW>
                else
                    loadedSWIFT{idx} = sw;
                end
                appendLog(logArea, sprintf('Loaded SWIFT %s  (%d records)', idStr, numel(sw)));
            catch ME
                appendLog(logArea, ['ERROR loading ' files{f} ': ' ME.message]);
            end
        end

        % Refresh list box
        loadedListBox.Items      = loadedIDs;
        loadedListBox.Value      = loadedIDs;  % select all by default
        vizUpdateCB([], []);
    end

    function vizUpdateCB(~, ~)
        if isempty(loadedSWIFT), return; end

        selIDs = loadedListBox.Value;
        if ischar(selIDs), selIDs = {selIDs}; end
        if isempty(selIDs), return; end

        colorVar = colorDD.Value;
        var1     = ts1DD.Value;
        var2     = ts2DD.Value;
        byID     = strcmp(colorVar, 'SWIFT ID');

        cla(axMap);  cla(axTS1);  cla(axTS2);
        colorbar(axMap, 'off');
        hold(axMap, 'on');  hold(axTS1, 'on');  hold(axTS2, 'on');

        cmap    = lines(numel(selIDs));
        allLats = [];

        for k = 1:numel(selIDs)
            idx = find(strcmp(loadedIDs, selIDs{k}), 1);
            if isempty(idx), continue; end
            sw  = loadedSWIFT{idx};
            col = cmap(k,:);

            lats = [sw.lat];
            lons = [sw.lon];
            tvec = [sw.time];
            allLats = [allLats, lats]; %#ok<AGROW>

            % Scatter color values
            if byID
                cvals = repmat(col, numel(tvec), 1);  % Nx3 RGB — fixed color per buoy
            else
                switch colorVar
                    case 'Time',       cvals = tvec;
                    case 'Battery',    cvals = extractField(sw, 'battery');
                    case 'Hs',         cvals = extractField(sw, 'sigwaveheight');
                    case 'Water Temp', cvals = extractField(sw, 'watertemp');
                    case 'Salinity',   cvals = extractField(sw, 'salinity');
                    otherwise,         cvals = tvec;
                end
            end

            % Track line (always per-buoy color) + scatter dots
            plot(axMap, lons, lats, '-', 'Color', col, 'LineWidth', 1, ...
                'HandleVisibility', 'off');
            if byID
                scatter(axMap, lons, lats, 20, cvals, 'filled', ...
                    'DisplayName', ['SWIFT ' selIDs{k}]);
            else
                scatter(axMap, lons, lats, 25, cvals, 'filled', ...
                    'DisplayName', ['SWIFT ' selIDs{k}]);
            end

            % Time series (always per-buoy color)
            y1 = extractField(sw, var1);
            plot(axTS1, tvec, y1, '.-', 'Color', col, ...
                'DisplayName', ['SWIFT ' selIDs{k}]);

            y2 = extractField(sw, var2);
            plot(axTS2, tvec, y2, '.-', 'Color', col, ...
                'DisplayName', ['SWIFT ' selIDs{k}]);
        end

        % Colorbar: only for non-ID modes; format time ticks as date strings
        if ~byID
            cb = colorbar(axMap);
            if strcmp(colorVar, 'Time')
                clims  = axMap.CLim;
                ticks  = linspace(clims(1), clims(2), 5);
                cb.Ticks      = ticks;
                cb.TickLabels = cellstr(datestr(ticks, 'mm/dd HH:MM'));
                cb.Label.String = 'Time (UTC)';
            else
                cb.Label.String = prettifyName(colorVar);
            end
        end

        % Correct aspect ratio for lat/lon (1 deg lon ≠ 1 deg lat)
        if ~isempty(allLats)
            latMid = mean(allLats, 'omitnan');
            if ~isnan(latMid) && abs(latMid) < 90
                daspect(axMap, [1/cosd(latMid), 1, 1]);
            end
        end

        legend(axMap,  'Location', 'best', 'FontSize', 8);
        legend(axTS1,  'Location', 'best', 'FontSize', 8);
        legend(axTS2,  'Location', 'best', 'FontSize', 8);

        ylabel(axTS1, prettifyName(var1));  title(axTS1, prettifyName(var1));
        ylabel(axTS2, prettifyName(var2));  title(axTS2, prettifyName(var2));

        axTS1.XTickLabelRotation = 30;
        axTS2.XTickLabelRotation = 30;
        datetick(axTS1, 'x', 'mm/dd HH:MM', 'keeplimits', 'keepticks');
        datetick(axTS2, 'x', 'mm/dd HH:MM', 'keeplimits', 'keepticks');

        hold(axMap, 'off');  hold(axTS1, 'off');  hold(axTS2, 'off');
    end

    function refreshBuoysCB(~, ~)
        fetchActiveBuoys();
    end

    function addBuoyCB(~, ~)
        sel = activeBuoysDD.Value;
        if isempty(sel) || any(strcmp(sel, {'(loading...)', '(none available)', '(fetch failed)'}))
            return
        end
        % Extract trailing number: "SWIFT 19" → "19", "microSWIFT 124" → "124"
        tok = regexp(sel, '(\d+)\s*$', 'tokens');
        if isempty(tok), return; end
        newID = tok{1}{1};
        currentIDs = idsArea.Value;
        currentIDs = currentIDs(~cellfun(@(s) isempty(strtrim(s)), currentIDs));
        if ~any(strcmp(strtrim(currentIDs), newID))
            idsArea.Value = [currentIDs; {newID}];
        end
    end

    function fetchActiveBuoys()
        activeBuoysDD.Items = {'(loading...)'};
        activeBuoysDD.Value = '(loading...)';
        drawnow;
        try
            data = webread('https://swiftserver.apl.uw.edu/services/active_buoys');
            if isstruct(data) && isfield(data, 'buoys') && ~isempty(data.buoys)
                buoys = data.buoys;
                names = cell(numel(buoys), 1);
                for bi = 1:numel(buoys)
                    names{bi} = buoys(bi).name;
                end
                activeBuoysDD.Items = names;
                activeBuoysDD.Value = names{1};
                appendLog(logArea, sprintf('Active buoys: fetched %d buoy(s).', numel(buoys)));
            else
                activeBuoysDD.Items = {'(none available)'};
                activeBuoysDD.Value = '(none available)';
            end
        catch ME
            activeBuoysDD.Items = {'(fetch failed)'};
            activeBuoysDD.Value = '(fetch failed)';
            appendLog(logArea, ['Active buoys fetch failed: ' ME.message]);
        end
    end

    function recentDDCB(~, ~)
        history = loadHistory();
        sel = recentDD.Value;
        idx = find(strcmp(recentDD.Items, sel), 1);
        % Item 1 is placeholder; items 2..end are history entries
        if isempty(history) || idx < 2, return; end
        e = history{idx - 1};
        idsArea.Value = e.ids;
        try, startDP.Value = datetime(e.startDate, 'ConvertFrom', 'datenum'); catch, end
        startTimeField.Value = e.startTime;
        nowCheck.Value = e.useNow;
        nowCheckCB([], []);
        if ~e.useNow && isfield(e, 'endDate')
            try, endDP.Value = datetime(e.endDate, 'ConvertFrom', 'datenum'); catch, end
        end
        endTimeField.Value = e.endTime;
        if isfolder(e.outDir), dirField.Value = e.outDir; end
    end

    function autoViz(outDir)
        % Scan outDir for all *telemetry.mat files, load into Visualize tab.
        hits = dir(fullfile(outDir, '*telemetry.mat'));
        if isempty(hits)
            appendLog(logArea, 'Viz: no telemetry .mat files found.');
            return
        end
        appendLog(logArea, sprintf('Viz: loading %d file(s)...', numel(hits)));
        for h = 1:numel(hits)
            fpath = fullfile(outDir, hits(h).name);
            try
                S = load(fpath);
                if ~isfield(S, 'SWIFT') || isempty(S.SWIFT), continue; end
                % Extract ID from filename (e.g. SWIFT16_telemetry.mat)
                tok = regexp(hits(h).name, 'SWIFT\s*(\w+?)_', 'tokens');
                id  = hits(h).name;  % fallback
                if ~isempty(tok), id = tok{1}{1}; end
                existing = find(strcmp(loadedIDs, id), 1);
                if isempty(existing)
                    loadedIDs{end+1}   = id; %#ok<AGROW>
                    loadedSWIFT{end+1} = S.SWIFT; %#ok<AGROW>
                else
                    loadedSWIFT{existing} = S.SWIFT;
                end
                appendLog(logArea, sprintf('  %s  (%d records)', hits(h).name, numel(S.SWIFT)));
            catch ME2
                appendLog(logArea, ['  skip: ' hits(h).name ' — ' ME2.message]);
            end
        end
        if ~isempty(loadedIDs)
            loadedListBox.Items = loadedIDs;
            loadedListBox.Value = loadedIDs;
            vizUpdateCB([], []);
            tg.SelectedTab = tab2;
        end
    end

    function savePrefs()
        % setpref/getpref persist key-value pairs in MATLAB's preferences store
        % (~/.matlab/<release>/MATLABprefs.mat on most systems), so values
        % survive across sessions without needing a separate config file.
        p = 'pullSWIFTtelemetryGUI';
        % Build entry for history
        e.ids       = idsArea.Value;
        e.startDate = datenum(startDP.Value);
        e.startTime = startTimeField.Value;
        e.useNow    = nowCheck.Value;
        e.endTime   = endTimeField.Value;
        e.outDir    = dirField.Value;
        if ~isnat(endDP.Value), e.endDate = datenum(endDP.Value); end

        % Prepend to history, keep last 10, dedupe by label
        label   = makeHistoryLabel(e);
        history = loadHistory();
        history = history(~cellfun(@(h) strcmp(makeHistoryLabel(h), label), history));
        history = [{e}, history];
        if numel(history) > 10, history = history(1:10); end
        setpref(p, 'history', history);

        % Also save as "last used"
        setpref(p, 'ids',       e.ids);
        setpref(p, 'startDate', e.startDate);
        setpref(p, 'startTime', e.startTime);
        setpref(p, 'useNow',    e.useNow);
        if isfield(e,'endDate'), setpref(p, 'endDate', e.endDate); end
        setpref(p, 'endTime', e.endTime);
        setpref(p, 'outDir',  e.outDir);

        refreshRecentDD(history);
    end

    function loadPrefs()
        p = 'pullSWIFTtelemetryGUI';
        if ispref(p, 'ids'),       idsArea.Value = getpref(p,'ids'); end
        if ispref(p, 'startDate')
            try, startDP.Value = datetime(getpref(p,'startDate'),'ConvertFrom','datenum'); catch, end
        end
        if ispref(p, 'startTime'), startTimeField.Value = getpref(p,'startTime'); end
        if ispref(p, 'useNow')
            nowCheck.Value = getpref(p,'useNow');
            nowCheckCB([], []);
        end
        if ispref(p,'endDate') && ~nowCheck.Value
            try, endDP.Value = datetime(getpref(p,'endDate'),'ConvertFrom','datenum'); catch, end
        end
        if ispref(p, 'endTime'), endTimeField.Value = getpref(p,'endTime'); end
        if ispref(p, 'outDir') && isfolder(getpref(p,'outDir'))
            dirField.Value = getpref(p,'outDir');
        end
        refreshRecentDD(loadHistory());
    end

    function refreshRecentDD(history)
        if isempty(history)
            recentDD.Items = {'(no history yet)'};
        else
            labels = cellfun(@makeHistoryLabel, history, 'UniformOutput', false);
            recentDD.Items = [{'(select recent...)'}, labels];
        end
        recentDD.Value = recentDD.Items{1};
    end

    function clearPrefsCB(~, ~)
        p = 'pullSWIFTtelemetryGUI';
        if ispref(p)
            rmpref(p);
        end
        refreshRecentDD({});
        appendLog(logArea, 'Saved preferences cleared.');
    end

end  % pullSWIFTtelemetryGUI

%% ==========================================================================
%%  Helper functions
%% ==========================================================================
% These are regular (non-nested) functions defined after the main function.
% They do NOT share the outer workspace, so GUI widgets must be passed in
% as arguments. Compare to the nested callbacks above which access everything
% from the closure.

function history = loadHistory()
    if ispref('pullSWIFTtelemetryGUI', 'history')
        history = getpref('pullSWIFTtelemetryGUI', 'history');
    else
        history = {};
    end
end

function label = makeHistoryLabel(e)
    ids = strjoin(strtrim(e.ids)', ',');
    try
        dateStr = datestr(e.startDate, 'yyyy-mm-dd');
    catch
        dateStr = '??';
    end
    label = sprintf('%s  |  SWIFTs: %s', dateStr, ids);
end

function isoStr = buildISO(dp, timeField)
% Build 'yyyy-mm-ddTHH:MM:SS' string from a uidatepicker + HH:MM:SS text field.
% Returns '' if the date picker is NaT.
    d = dp.Value;
    if isnat(d)
        isoStr = '';
        return
    end
    t = strtrim(timeField.Value);
    if isempty(t) || isempty(regexp(t, '^\d{2}:\d{2}:\d{2}$', 'once'))
        t = '00:00:00';
    end
    isoStr = [datestr(datenum(d), 'yyyy-mm-dd') 'T' t];
end

% Create a bold section-header label at the specified grid row.
% uigridlayout does not auto-place widgets — every widget must declare
% its Layout.Row and Layout.Column, or it defaults to the next available cell.
function mkLabel(parent, row, txt)
    lbl = uilabel(parent, 'Text', txt, 'FontWeight', 'bold');
    lbl.Layout.Row    = row;
    lbl.Layout.Column = 1;
end

% Place an invisible label as a visual gap between sections in a grid row.
% uigridlayout has no built-in "spacer" widget, so an empty label is idiomatic.
function spacer(parent, row)
    lbl = uilabel(parent, 'Text', '');
    lbl.Layout.Row    = row;
    lbl.Layout.Column = 1;
end

function appendLog(logArea, msg)
    cur = logArea.Value;
    if ischar(cur), cur = {cur}; end
    logArea.Value = [cur; {msg}];
    scroll(logArea, 'bottom');
    drawnow;
end

function vals = extractField(sw, fieldname)
% Extract a numeric field from a struct array; return NaN where missing.
    n = numel(sw);
    vals = NaN(1, n);
    if ~isfield(sw, fieldname), return; end
    for i = 1:n
        v = sw(i).(fieldname);
        if ~isempty(v) && isnumeric(v)
            vals(i) = v(1);
        end
    end
end

function s = prettifyName(varname)
    map = containers.Map( ...
        {'sigwaveheight','peakwaveperiod','windspd','watertemp','salinity','battery'}, ...
        {'Sig. Wave Height (m)', 'Peak Wave Period (s)', 'Wind Speed (m/s)', ...
         'Water Temperature (°C)', 'Salinity (PSU)', 'Battery (V)'});
    if isKey(map, varname)
        s = map(varname);
    else
        s = varname;
    end
end
