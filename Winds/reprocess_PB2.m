function [SWIFT,sinfo] = reprocess_PB2(missiondir,readraw,plotburst)

% Reprocess Airmar Weather Station model 200WX files
% loop thru raw data for a given SWIFT deployment, then
% replace values in the SWIFT data structure of results
% (assuming concatSWIFTv3_processed.m has already been run.

% K. Zeiden 03/2025 based on reprocess_WXT
% plotburst = false;

if ispc 
    slash = '\';
else
    slash = '/';
end

%% Load existing L3 product, or L2 product if does not exist. If no L3 product, return to function

l2file = dir([missiondir slash '*SWIFT*L2.mat']);
l3file = dir([missiondir slash '*SWIFT*L3.mat']);

if ~isempty(l3file) % First check to see if there is an existing L3 file to load
    sfile = l3file;
    load([sfile.folder slash sfile.name],'SWIFT','sinfo');
elseif isempty(l3file) && ~isempty(l2file)% If not, load L1 file
    sfile = l2file;
    load([sfile.folder slash sfile.name],'SWIFT','sinfo');
else %  Exit reprocessing if no L2 or L3 product exists
    warning(['No L2 or L3 product found for ' missiondir(end-16:end) '. Skipping...'])
    return
end

%% Loop through raw burst files and reprocess
SWIFTreplaced = false(length(SWIFT),1);
relwind = false(length(SWIFT),1);

bfiles = dir([missiondir slash '*' slash 'Raw' slash '*' slash '*PB2*.dat']);
disp(['Found ' num2str(length(bfiles)) ' burst files...'])

for iburst = 1:length(bfiles)

   disp(['Burst ' num2str(iburst) ' : ' bfiles(iburst).name(1:end-4)])
        
        if bfiles(iburst).bytes   == 0
            disp('Burst file is empty. Skippping ...')
            continue
        end
            
        % Read mat file or load raw data
        if isempty(dir([bfiles(iburst).folder slash bfiles(iburst).name(1:end-4) '.mat'])) || readraw
            [~,windspd,winddirT,airtemp,airpres,~,~,~,~,pitch,roll,relhumidity,windspdR,winddirR] = ...
                readSWIFTv3_PB2([bfiles(iburst).folder slash bfiles(iburst).name]);
        else
            load([bfiles(iburst).folder slash bfiles(iburst).name(1:end-4) '.mat']), %#ok<LOAD>
            windspd = rawwindspd;
            winddirT = rawwinddir;
            airtemp = rawairtemp;
            airpres = rawairpres;
            relhumidity = rawhumidity;
            windspdR = rawwindspdR;
            winddirR = rawwinddirR;
        end

        % Check for zero-d data
        if mean(airtemp,'omitnan') == 0 && mean(windspd,'omitnan') == 0
            disp('Bad data (all zero). Skipping...')
            continue
        end

        % Check for bad winds
        if mean(windspd,'omitnan') > 50 && std(windspd,[],'omitnan') < 1
            disp('WARNING: Bad wind.')
            windspd = NaN;
            winddirT = NaN;
        end

        % Check airpressure units (if O(10), is in inches of mercury)
        if mean(airpres,'omitnan') < 500
            airpres = airpres.*33.8639;% Convert to mb
        end

        % Find burst index in the existing SWIFT structure
        burstID = bfiles(iburst).name(13:end-4);
        sindex = find(strcmp(burstID,{SWIFT.burstID}'));
        if isempty(sindex)
            disp('No matching SWIFT index. Skipping...')
            continue
        end

        % Despike
        ispike = windspd > median(windspd)+3*std(windspd,'omitnan');
        if sum(~ispike) > 3; windspddsp = interp1(find(~ispike),windspd(~ispike),1:length(windspd)); end
        ispike = winddirT > median(winddirT)+3*std(winddirT,'omitnan');
        if sum(~ispike) > 3; winddirTdsp = interp1(find(~ispike),winddirT(~ispike),1:length(winddirT));end
        ispike = windspdR > median(windspdR)+3*std(windspdR,'omitnan');
        if sum(~ispike) > 3; windspdRdsp = interp1(find(~ispike),windspdR(~ispike),1:length(windspdR));end
        ispike = winddirR > median(winddirR)+3*std(winddirR,'omitnan');
        if sum(~ispike) > 3; winddirRdsp = interp1(find(~ispike),winddirR(~ispike),1:length(winddirR));end
        ispike = airtemp > median(airtemp)+3*std(airtemp,'omitnan');
        if sum(~ispike) > 3; airtempdsp = interp1(find(~ispike),airtemp(~ispike),1:length(airtemp));end
        ispike = airpres > median(airpres)+3*std(airpres,'omitnan');
        if sum(~ispike) > 3; airpresdsp = interp1(find(~ispike),airpres(~ispike),1:length(airpres));end
        ispike = relhumidity > median(relhumidity)+3*std(relhumidity,'omitnan');
        if sum(~ispike) > 3; relhumiditydsp = interp1(find(~ispike),relhumidity(~ispike),1:length(relhumidity));end

        % Compute tilt
        tilt = acosd(cosd(pitch).*cosd(roll));

        % Plotdata
        if plotburst
            figure('color','w')
            fullscreen
            subplot(5,1,1)
            plot(windspd,'-kx')
            hold on
            plot(windspdR,'-x','color',rgb('grey'))
            plot(windspddsp,'-rx')
            plot(windspdR,'-x','color',rgb('coral'))
            axis tight;ylim([0 20]);title('Wind Speed');legend('True','Relative','T Despike','R Despiked')
            subplot(5,1,2)
            plot(winddirT,'-kx')
            hold on
            plot(winddirR,'-x','color',rgb('grey'))
            axis tight;title('Wind Direction');legend('True','Relative')
            subplot(5,1,3)
            plot(airtemp,'-kx');
            hold on
            plot(airtempdsp,'-rx')
            axis tight;title('Air Temperature');
            subplot(5,1,4)
            plot(airpres,'-kx')
            hold on
            plot(airpresdsp,'-rx')
            axis tight;title('Air Pressure');
            subplot(5,1,5)
            plot(relhumidity,'-kx')
            hold on
            plot(relhumiditydsp,'-rx')
            axis tight;title('Humidity');
            print([bfiles(iburst).folder '\' bfiles(iburst).name(1:end-4)],'-dpng')
            close gcf
        end

        % Mean + Std Dev values
        windspdstddev = std(windspddsp,[],'omitnan'); %#ok<*NANSTD> % std dev of wind spd (m/s) 
        windspdskew = skewness(windspddsp,[],'omitnan');
        windspdkurt = kurtosis(windspddsp,[],'omitnan');
        windspd = nanmean(windspddsp); %#ok<*NANMEAN> % mean wind speed (m/s)
        % If wind is NaN, use relative wind speed if not NaN
        if isnan(windspd) && ~isnan(nanmean(windspdRdsp))
            windspdstddev = nanstd(windspdRdsp);
            windspdskew = skewness(windspdRdsp,[],'omitnan');
            windspdkurt = kurtosis(windspdRdsp,[],'omitnan');
            windspd = nanmean(windspdRdsp);
            relwind(sindex) = true;
        end
        winddirTstddev = nanstd(winddirTdsp);% std dev of wind direction (deg)
        winddirT = meandir(winddirTdsp);% mean wind direction (deg true)
        winddirRstddev = nanstd(winddirRdsp);% std dev of wind direction (deg)
        winddirR = meandir(winddirRdsp);% mean wind direction (deg relative)
        airtempstddev = nanstd(airtempdsp);
        airtemp = nanmean(airtempdsp);
        airpresstddev = nanstd(airpresdsp);
        airpres = nanmean(airpresdsp);
        relhumiditystddev = nanstd(relhumiditydsp);
        relhumidity = nanmean(relhumiditydsp);
        tiltstd = std(tilt,[],'omitnan');
        tilt = mean(tilt,'omitnan');

        % Bad if wind spd std dev > mean wind speed
        if windspdstddev/windspd < 1

        % Save in SWIFT structure
        SWIFT(sindex).windspd = windspd;
        SWIFT(sindex).windspdstddev = windspdstddev; 
        SWIFT(sindex).windspdskew = windspdskew;
        SWIFT(sindex).windspdkurt = windspdkurt;
        SWIFT(sindex).winddirT = winddirT;
        SWIFT(sindex).winddirTstddev =  winddirTstddev;
        SWIFT(sindex).winddirR = winddirR; 
        SWIFT(sindex).winddirRstddev = winddirRstddev;
        SWIFT(sindex).airtemp = airtemp; 
        SWIFT(sindex).airtempstddev = airtempstddev; 
        SWIFT(sindex).airpres = airpres; 
        SWIFT(sindex).airpresstddev = airpresstddev; 
        SWIFT(sindex).relhumidity = relhumidity;
        SWIFT(sindex).relhumiditystddev = relhumiditystddev;

        % Save tilt
        SWIFT(sindex).tilt = tilt;
        SWIFT(sindex).tiltstd = tiltstd;

        SWIFTreplaced(sindex) = true;
        end

end


%% If SWIFT structure elements not replaced, fill variables with NaNs

if any(~SWIFTreplaced)

    [SWIFT(~SWIFTreplaced).windspd] = deal(NaN);
    [SWIFT(~SWIFTreplaced).windspdstddev] = deal(NaN);
    [SWIFT(~SWIFTreplaced).windspdskew] = deal(NaN);
    [SWIFT(~SWIFTreplaced).windspdkurt] = deal(NaN);
    [SWIFT(~SWIFTreplaced).winddirT] = deal(NaN);
    [SWIFT(~SWIFTreplaced).winddirTstddev] =  deal(NaN);
    [SWIFT(~SWIFTreplaced).winddirR] = deal(NaN);
    [SWIFT(~SWIFTreplaced).winddirRstddev] =  deal(NaN);
    [SWIFT(~SWIFTreplaced).airtemp] = deal(NaN);
    [SWIFT(~SWIFTreplaced).airtempstddev] = deal(NaN);
    [SWIFT(~SWIFTreplaced).airpres] = deal(NaN);
    [SWIFT(~SWIFTreplaced).airpresstddev] = deal(NaN);
    [SWIFT(~SWIFTreplaced).relhumidity] = deal(NaN);
    [SWIFT(~SWIFTreplaced).relhumiditystddev] = deal(NaN);

    [SWIFT(~SWIFTreplaced).tilt] = deal(NaN);
    [SWIFT(~SWIFTreplaced).tiltstd] = deal(NaN);

end

%% Log reprocessing and flags, then save new L3 file or overwrite existing one

if isfield(sinfo,'postproc')
ip = length(sinfo.postproc)+1; 
else
    sinfo.postproc = struct;
    ip = 1;
end
sinfo.postproc(ip).type = 'PB2';
sinfo.postproc(ip).usr = getenv('username');
sinfo.postproc(ip).time = string(datetime('now'));
sinfo.postproc(ip).flags.relwind = relwind;
sinfo.postproc(ip).params = [];

save([sfile.folder slash sfile.name(1:end-6) 'L3.mat'],'SWIFT','sinfo')

%% End function
end