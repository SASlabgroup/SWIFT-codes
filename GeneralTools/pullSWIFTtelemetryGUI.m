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
lg = uigridlayout(leftPanel, [20 1]);  % 20 rows, 1 column
lg.RowHeight  = { ...
    20, ...   % 1  label: Recent Queries
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
    20, ...   % 17 label: Save Destination
    36, ...   % 18 output dir field + Browse button
    36, ...   % 19 Pull Telemetry button
    22};      % 20 Clear Saved Preferences button
lg.Padding    = [8 8 8 8];
lg.RowSpacing = 2;

% -- Recent parameters dropdown --
% `@recentDDCB` is a function handle — MATLAB calls recentDDCB(src, event)
% whenever the dropdown value changes. Callbacks always receive two arguments:
% the source widget (src) and an event object; we often ignore them with ~.
mkLabel(lg, 1, 'Recent Queries');
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
mkLabel(lg, 17, 'Save Destination');
dirRowGrid = uigridlayout(lg, [1 2]);
dirRowGrid.Layout.Row = 18;  dirRowGrid.Layout.Column = 1;
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
runBtn.Layout.Row = 19;  runBtn.Layout.Column = 1;

clearPrefsBtn = uibutton(lg, ...
    'Text', 'Clear Saved Preferences', 'FontSize', 10, ...
    'ButtonPushedFcn', @clearPrefsCB);
clearPrefsBtn.Layout.Row = 20;  clearPrefsBtn.Layout.Column = 1;

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
% uihtml renders an HTML string — lets us style individual log lines
% (bold headers, red errors) which uitextarea cannot do.
logArea = uihtml(rg);
logArea.Layout.Row = 4;  logArea.Layout.Column = 1;
% Initialise with a wrapper div that behaves like a read-only log console.
% The JS function appendLine() is called from MATLAB via logArea.Data and
% a DataChangedFcn on the JS side to auto-scroll and append styled lines.
logArea.HTMLSource = buildLogHTML();
appendLog(logArea, 'Ready. Set parameters and press "Pull Telemetry".', 'muted');

% Show git branch and commit using MATLAB's built-in git API (R2023b+).
try
    repoDir = fileparts(fileparts(mfilename('fullpath')));  % SWIFT-codes root
    repo = gitrepo(repoDir);
    branchName = char(repo.CurrentBranch.Name);
    commitId   = char(repo.LastCommit.ID);
    if numel(commitId) > 7, commitId = commitId(1:7); end
    appendLog(logArea, sprintf('SWIFT-codes  |  branch: %s  |  commit: %s', ...
        branchName, commitId), 'muted');
catch ME
    appendLog(logArea, ['Git info unavailable: ' ME.message], 'muted');
end

% Check for required MATLAB toolboxes. Mapping Toolbox is needed for
% geoaxes/geoplot basemap tiles on Tab 2; Fixed-Point Designer is required
% by some pullSWIFTtelemetry dependencies.
checkRequiredToolboxes( { ...
    'MAP_Toolbox',         'Mapping Toolbox',      'https://www.mathworks.com/products/mapping.html'; ...
    'Fixed_Point_Toolbox', 'Fixed-Point Designer', 'https://www.mathworks.com/products/fixed-point-designer.html'}, ...
    @(msg, style) appendLog(logArea, msg, style));

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

% uigridlayout arranges child widgets in a grid.  [17 1] = 17 rows, 1 col.
% Each widget is placed by setting its .Layout.Row / .Layout.Column.
% RowHeight values are pixels (numeric) or stretchy ('1x' fills remaining).
% The pattern is: widget, spacer, label, widget, spacer, label, widget, ...
vc = uigridlayout(vizCtrl, [17 1]);
vc.RowHeight  = { ...
    36,   ... % row 1:  Load button (tall, prominent)
    10,   ... % row 2:  spacer
    20,   ... % row 3:  "Loaded SWIFTs" label
    100,  ... % row 4:  listbox (tall to show multiple buoy names)
    10,   ... % row 5:  spacer
    20,   ... % row 6:  "Color tracks by" label
    22,   ... % row 7:  color dropdown
    10,   ... % row 8:  spacer
    20,   ... % row 9:  "Time series 1" label
    22,   ... % row 10: time-series-1 dropdown
    10,   ... % row 11: spacer
    20,   ... % row 12: "Time series 2" label
    22,   ... % row 13: time-series-2 dropdown
    10,   ... % row 14: spacer
    20,   ... % row 15: "Basemap" label
    22,   ... % row 16: basemap dropdown
    '1x'};    % row 17: stretchy filler — pushes everything above upward
vc.Padding    = [8 8 8 8];   % [left bottom right top] inner margin (px)
vc.RowSpacing = 2;            % vertical gap between rows (px)

% --- Load button ---
% uibutton creates a push button.  ButtonPushedFcn fires when clicked.
loadBtn = uibutton(vc, ...
    'Text', 'Load .mat Files...', 'FontWeight', 'bold', 'FontSize', 12, ...
    'BackgroundColor', [0.22 0.45 0.70], 'FontColor', [1 1 1], ...
    'ButtonPushedFcn', @loadMatCB);
loadBtn.Layout.Row = 1;  loadBtn.Layout.Column = 1;

% --- Buoy listbox ---
% spacer() and mkLabel() are local helpers defined at the bottom of this
% file.  spacer inserts a blank, mkLabel creates a uilabel in a given row.
spacer(vc, 2);
mkLabel(vc, 3, 'Loaded SWIFTs');
% uilistbox shows a scrollable list.  'Multiselect','on' lets the user
% ctrl/shift-click to select several buoys at once.
loadedListBox = uilistbox(vc, 'Items', {}, 'Multiselect', 'on');
loadedListBox.Layout.Row = 4;  loadedListBox.Layout.Column = 1;
% ValueChangedFcn fires whenever the selection changes — triggers replot.
loadedListBox.ValueChangedFcn = @vizUpdateCB;

% --- Color-by dropdown ---
spacer(vc, 5);
mkLabel(vc, 6, 'Color tracks by');
% uidropdown creates a combo-box.  'Items' is the list of choices, 'Value'
% is the initial selection.  ValueChangedFcn triggers replot on change.
colorDD = uidropdown(vc, ...
    'Items', {'SWIFT ID', 'Time', 'Battery', 'Hs', 'Water Temp', 'Salinity'}, ...
    'Value', 'SWIFT ID', 'ValueChangedFcn', @vizUpdateCB);
colorDD.Layout.Row = 7;  colorDD.Layout.Column = 1;

% --- Time-series variable 1 ---
spacer(vc, 8);
mkLabel(vc, 9, 'Time series — variable 1');
ts1DD = uidropdown(vc, ...
    'Items', {'sigwaveheight', 'peakwaveperiod', 'windspd', 'watertemp', 'salinity', 'battery'}, ...
    'Value', 'sigwaveheight', 'ValueChangedFcn', @vizUpdateCB);
ts1DD.Layout.Row = 10;  ts1DD.Layout.Column = 1;

% --- Time-series variable 2 ---
spacer(vc, 11);
mkLabel(vc, 12, 'Time series — variable 2');
ts2DD = uidropdown(vc, ...
    'Items', {'watertemp', 'salinity', 'battery', 'sigwaveheight', 'peakwaveperiod', 'windspd'}, ...
    'Value', 'watertemp', 'ValueChangedFcn', @vizUpdateCB);
ts2DD.Layout.Row = 13;  ts2DD.Layout.Column = 1;

% --- Basemap style ---
spacer(vc, 14);
mkLabel(vc, 15, 'Basemap');
% These are the built-in MATLAB basemap tile layers (R2018b+, no toolbox).
% Tiles are fetched from MathWorks servers so an internet connection is
% needed (except 'none').
basemapDD = uidropdown(vc, ...
    'Items', {'bluegreen', 'streets', 'streets-light', 'streets-dark', ...
              'topographic', 'satellite', 'ocean', 'darkwater', ...
              'grayland', 'grayterrain', 'colorterrain', 'landcover', 'none'}, ...
    'Value', 'darkwater', 'ValueChangedFcn', @basemapChangeCB);
basemapDD.Layout.Row = 16;  basemapDD.Layout.Column = 1;

%% ---- Plot panel ------------------------------------------------------------
plotPanel = uipanel(t2Grid, 'Title', 'Plots');
plotPanel.Layout.Row = 1;  plotPanel.Layout.Column = 2;

% 2x2 grid for the plots: map on the left (spans both rows), two time-
% series plots stacked on the right.  '1x' means each row/col gets equal
% share of available space.
pg = uigridlayout(plotPanel, [2 2]);
pg.RowHeight    = {'1x', '1x'};
pg.ColumnWidth  = {'1x', '1x'};
pg.Padding      = [6 6 6 6];
pg.RowSpacing   = 6;
pg.ColumnSpacing = 6;

% geoaxes is like axes but projects lat/lon onto a map with basemap tiles.
% Layout.Row = [1 2] makes it span both rows (full left column).
axMap  = geoaxes(pg);  axMap.Layout.Row  = [1 2];  axMap.Layout.Column  = 1;
% uiaxes creates standard Cartesian axes for the time-series panels.
axTS1  = uiaxes(pg);  axTS1.Layout.Row  = 1;       axTS1.Layout.Column  = 2;
axTS2  = uiaxes(pg);  axTS2.Layout.Row  = 2;       axTS2.Layout.Column  = 2;

% Set the initial basemap tile layer (geoaxes draws lat/lon labels itself).
geobasemap(axMap, 'bluegreen');
title(axMap, 'Position Tracks');

% Standard axes setup for the two time-series panels.
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
            appendLog(logArea, 'ERROR: No SWIFT IDs entered.', 'error'); return
        end

        % Type is inferred from ID length: 2-digit = v3/v4, 3-digit = microSWIFT
        lens = cellfun(@numel, idList);
        if ~all(lens == lens(1)) || ~any(lens(1) == [2 3])
            appendLog(logArea, 'ERROR: All IDs must be the same length: 2-digit (SWIFT v3/v4) or 3-digit (microSWIFT).', 'error');
            return
        end
        IDs = char(idList);

        if isempty(startStr)
            appendLog(logArea, 'ERROR: Start time is required.', 'error'); return
        end

        % Build a subfolder name from search parameters so each pull lands
        % in its own directory and never collides with previous results.
        % e.g. "SWIFT_16_23_20250101T0000_20250115T0000"
        idTag    = ['SWIFT_' strjoin(idList, '_')];
        startTag = regexprep(startStr, '[-:]', '');  % 20250101T000000
        if isempty(endStr)
            endTag = 'now';
        else
            endTag = regexprep(endStr, '[-:]', '');
        end
        subName = [idTag '_' startTag '_' endTag];
        pullDir = fullfile(outDir, subName);

        % Create the output directory tree (including parents) if needed.
        if ~isfolder(pullDir)
            [ok, msg] = mkdir(pullDir);
            if ~ok
                appendLog(logArea, ['ERROR creating directory: ' msg], 'error'); return
            end
            appendLog(logArea, ['Created: ' pullDir]);
        end

        % Warn if the pull directory already contains SWIFT artifacts from
        % a previous run with the same parameters.
        appendLog(logArea, repmat('-',1,60), 'bold');
        prevZips = dir(fullfile(pullDir, 'SWIFT*.zip'));              % downloaded archives
        prevDirs = dir(fullfile(pullDir, 'buoy-*'));                  % unpacked SBD folders
        prevDirs = prevDirs([prevDirs.isdir]);
        prevMats = dir(fullfile(pullDir, '*SWIFT*_telemetry.mat'));   % processed output
        if ~isempty(prevZips)
            appendLog(logArea, sprintf( ...
                'WARNING: %d downloaded zip file(s) found — will be overwritten.', numel(prevZips)), 'warn');
        end
        if ~isempty(prevDirs)
            appendLog(logArea, sprintf( ...
                'WARNING: %d unpacked buoy-* folder(s) found — contents will be overwritten.', numel(prevDirs)), 'warn');
        end
        if ~isempty(prevMats)
            appendLog(logArea, sprintf( ...
                'WARNING: %d processed telemetry .mat file(s) found — will be overwritten.', numel(prevMats)), 'warn');
        end
        if ~isempty(prevZips) || ~isempty(prevDirs) || ~isempty(prevMats)
            appendLog(logArea, ['  Dir: ' pullDir], 'warn');
        end

        origDir = pwd;
        try
            cd(pullDir);
        catch ME
            appendLog(logArea, ['ERROR changing directory: ' ME.message], 'error'); return
        end

        savePrefs();  % cache parameters before running

        runBtn.Enable = 'off';  runBtn.Text = 'Running...';
        drawnow;  % flush the event queue so the button visually updates before the long pull

        appendLog(logArea, ['Pull started: ' datestr(now,'yyyy-mm-dd HH:MM:SS')], 'bold');
        appendLog(logArea, ['IDs:   ' strjoin(idList,', ')], 'bold');
        appendLog(logArea, ['Start: ' startStr], 'bold');
        appendLog(logArea, ['End:   ' endStr], 'bold');
        appendLog(logArea, ['Dir:   ' pullDir], 'bold');
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
            autoViz(pullDir);

        catch ME
            appendLog(logArea, ['ERROR: ' ME.message], 'error');
            for fi = 1:numel(ME.stack)
                appendLog(logArea, sprintf('  at %s (line %d)', ...
                    ME.stack(fi).name, ME.stack(fi).line), 'error');
            end
        end

        cd(origDir);
        appendLog(logArea, 'Please see Command Window for full verbose output.');
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
                    appendLog(logArea, ['Skip (no SWIFT var): ' files{f}], 'warn');
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
                appendLog(logArea, ['ERROR loading ' files{f} ': ' ME.message], 'error');
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

        delete(allchild(axMap));  delete(allchild(axTS1));  delete(allchild(axTS2));
        colorbar(axMap, 'off');
        geobasemap(axMap, basemapDD.Value);  % re-apply after clearing children
        hold(axMap, 'on');  hold(axTS1, 'on');  hold(axTS2, 'on');

        cmap    = lines(numel(selIDs));
        allLats  = [];
        allTimes = [];

        for k = 1:numel(selIDs)
            idx = find(strcmp(loadedIDs, selIDs{k}), 1);
            if isempty(idx), continue; end
            sw  = loadedSWIFT{idx};
            col = cmap(k,:);

            lats = [sw.lat];
            lons = [sw.lon];
            tvec = [sw.time];
            allLats  = [allLats, lats]; %#ok<AGROW>
            allTimes = [allTimes, tvec]; %#ok<AGROW>

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
            geoplot(axMap, lats, lons, '-', 'Color', col, 'LineWidth', 1, ...
                'HandleVisibility', 'off');
            if byID
                geoscatter(axMap, lats, lons, 20, cvals, 'filled', ...
                    'DisplayName', ['SWIFT ' selIDs{k}]);
            else
                geoscatter(axMap, lats, lons, 25, cvals, 'filled', ...
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

        % geoaxes handles aspect ratio automatically

        legend(axMap,  'Location', 'best', 'FontSize', 8);
        legend(axTS1,  'Location', 'best', 'FontSize', 8);
        legend(axTS2,  'Location', 'best', 'FontSize', 8);

        ylabel(axTS1, prettifyName(var1));  title(axTS1, prettifyName(var1));
        ylabel(axTS2, prettifyName(var2));  title(axTS2, prettifyName(var2));

        % Set shared x-axis limits across all buoys, then format as dates
        if ~isempty(allTimes)
            tMin = min(allTimes);
            tMax = max(allTimes);
            pad  = max(0.01 * (tMax - tMin), 1/24);  % at least 1-hour pad
            xlim(axTS1, [tMin - pad, tMax + pad]);
            xlim(axTS2, [tMin - pad, tMax + pad]);
        end
        axTS1.XTickLabelRotation = 30;
        axTS2.XTickLabelRotation = 30;
        datetick(axTS1, 'x', 'mm/dd HH:MM', 'keeplimits');
        datetick(axTS2, 'x', 'mm/dd HH:MM', 'keeplimits');

        hold(axMap, 'off');  hold(axTS1, 'off');  hold(axTS2, 'off');
    end

    function basemapChangeCB(~, ~)
        geobasemap(axMap, basemapDD.Value);
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
                appendLog(logArea, sprintf('Active buoys: fetched %d buoy(s).', numel(buoys)), 'muted');
            else
                activeBuoysDD.Items = {'(none available)'};
                activeBuoysDD.Value = '(none available)';
            end
        catch ME
            activeBuoysDD.Items = {'(fetch failed)'};
            activeBuoysDD.Value = '(fetch failed)';
            appendLog(logArea, ['Active buoys fetch failed: ' ME.message], 'error');
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
                appendLog(logArea, ['  skip: ' hits(h).name ' — ' ME2.message], 'warn');
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

%% ---- Bring window to front and give it focus -----------------------------
drawnow;
figure(fig);

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

function appendLog(logArea, msg, style)
% Append a styled line to the uihtml log panel.
%   style: 'normal' (default), 'bold', 'error' (red+bold), 'warn' (orange)
    if nargin < 3, style = 'normal'; end
    % HTML-escape special characters so messages render literally
    msg = strrep(msg, '&', '&amp;');
    msg = strrep(msg, '<', '&lt;');
    msg = strrep(msg, '>', '&gt;');
    % Build the HTML line directly and accumulate in the UserData buffer.
    % We store the full HTML string in UserData so no messages are lost
    % (the DataChanged JS event can miss rapid-fire .Data updates).
    switch style
        case 'bold',  line = ['<div class="bold">'  msg '</div>'];
        case 'error', line = ['<div class="error">' msg '</div>'];
        case 'warn',  line = ['<div class="warn">'  msg '</div>'];
        case 'muted', line = ['<div class="muted">' msg '</div>'];
        otherwise,    line = ['<div>'               msg '</div>'];
    end
    if isempty(logArea.UserData)
        logArea.UserData = line;
    else
        logArea.UserData = [logArea.UserData, line];
    end
    % Push the full accumulated HTML to JS; it replaces #log innerHTML.
    logArea.Data = logArea.UserData;
end

function html = buildLogHTML()
% Returns the inline HTML/CSS/JS for the log panel used by appendLog().
    html = [ ...
    '<html><head><style>' ...
    'body{margin:0;padding:0;background:#fff;}' ...
    '#log{font-family:"Courier New",monospace;font-size:11px;' ...
    '  padding:6px;overflow-y:auto;height:100vh;box-sizing:border-box;' ...
    '  white-space:pre-wrap;word-wrap:break-word;}' ...
    '.bold{font-weight:bold;}' ...
    '.error{color:#cc1111;font-weight:bold;}' ...
    '.warn{color:#b8860b;}' ...
    '.muted{color:#999999;}' ...
    '</style></head><body><div id="log"></div>' ...
    '<script>' ...
    'function setup(htmlComponent){' ...
    '  htmlComponent.addEventListener("DataChanged",function(){' ...
    '    var d=htmlComponent.Data;if(!d)return;' ...
    '    var log=document.getElementById("log");' ...
    '    log.innerHTML=d;' ...
    '    log.lastElementChild.scrollIntoView({behavior:"auto"});' ...
    '  });' ...
    '}' ...
    '</script></body></html>'];
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
