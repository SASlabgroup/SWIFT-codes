function [qual] = COARE_corr(SWIFT, fluxes)
% function to correlation table from COARE vars and SWIFT inputs
% 


savepath = 'C:\Users\MichaelJames\Dropbox\mjames\Carson_COAREcomparision\COARE_IO';
cd(savepath); fprintf('Savepath: %s', savepath);


%% COARE input values
% Time in Julian Day
time = [SWIFT.time];
jd = time;

% wind speed and height
if isfield(SWIFT,'windspd') && any(~isnan([SWIFT.windspd])),
    u = [SWIFT.windspd]; % vector; since SWIFT drifts, this is rel to water current
else
    disp('missing wind spd, COARE will skip most results')
    u = NaN; % required parameter, setting to zero remove most results
end

if isfield(SWIFT,'metheight') && any(~isnan([SWIFT.metheight])),
    zu = SWIFT(1).metheight; % constant
else
    zu = 1; % meter
end

zrf_u = 0; %reference height

% air temp and height
if isfield(SWIFT,'airtemp') && any(~isnan([SWIFT.airtemp])),
    t = [SWIFT.airtemp];
else
    disp('missing air temp, COARE will skip most results')
    t = NaN; % required parameter, setting to zero remove most results
end
% relative humidity and height
if isfield(SWIFT,'relhumidity') && any(~isnan([SWIFT.relhumidity])),
    rh = [SWIFT.relhumidity];
else
    rh = 95; % cannot be NaN, must have a value
end
% air pressure
if isfield(SWIFT,'airpres') && any(~isnan([SWIFT.airpres])),
    P = [SWIFT.airpres];
else
    P = NaN;
end

% water temp
if isfield(SWIFT,'watertemp') && any(~isnan([SWIFT.watertemp])),
    if length(SWIFT(1).watertemp) == 1,
        disp('one water temp depth')
        ts = [SWIFT.watertemp];
    else
        disp('multiple water temp depths, taking shallowest')
        for si=1:length(SWIFT),
            watertempindex = find( ~isnan ( SWIFT(si).watertemp ) & SWIFT(si).watertemp~=0.0, 1, 'first' );
            if ~isempty(watertempindex)
                ts(si) =  SWIFT(si).watertemp( watertempindex );
            else
                ts(si) = NaN;
            end
        end
    end
else
    disp('missing water temp, COARE will skip most results')
    ts = NaN; % required parameter, setting to zero remove most results
end

if isfield(SWIFT,'CTdepth') && any(~isnan([SWIFT.CTdepth])),
    ts_depth = [SWIFT.CTdepth];
    if ~any(diff(ts_depth)) ~=0
        ts_depth = ts_depth(1);
    end;
else 
    ts_depth = NaN;
end

% Water Salinity
if isfield(SWIFT,'salinity') && any(~isnan([SWIFT.salinity])),
    Ss = [SWIFT.salinity];
else
    Ss = NaN;
end;

% downwelling radiation
if isfield(SWIFT,'SWrad') && any(~isnan([SWIFT.SWrad])),
    sw_dn = [SWIFT.SWrad];
else
    sw_dn = NaN;
end

if isfield(SWIFT,'LWrad') && any(~isnan([SWIFT.LWrad])),
    lw_dn = [SWIFT.LWrad];
else
    lw_dn = NaN;
end

% latitude and lon
% lat = nanmean([SWIFT.lat]); % single value, not vector
% lon = nanmean([SWIFT.lon]); % single value, not vector
lat = [SWIFT.lat]; % vector
lon = [SWIFT.lon]; % vector

%fill in NaN with nanmean (toggle with comment)
lat(isnan(lat)) = nanmean(lat);
lon(isnan(lon)) = nanmean(lon);

% atmospheric PBL height
zi = NaN;

% rain rate
if isfield(SWIFT,'rainint') && any(~isnan([SWIFT.rainint])),
    rain = [SWIFT.rainint];
else
    rain = 0; % cannot be NaN, must have a value
end

% waves
if isfield(SWIFT,'peakwaveperiod') && any(~isnan([SWIFT.peakwaveperiod])),
    Tp = [SWIFT.peakwaveperiod];
    cp = 9.8 * Tp ./ (2 * pi);  % assume deep water dispersion relation
else
    cp = NaN;
end
% %fill in waveperiod NaNmean (toggle with commment)
% cp(cp ==0) = nanmean(cp);
% cp(isnan(cp)) = nanmean(cp);
cp(cp ==0) = nan; % Fill nan for blank

if isfield(SWIFT,'sigwaveheight') && any(~isnan([SWIFT.sigwaveheight])),
    sigH = [SWIFT.sigwaveheight];
else
    sigH = NaN;
end
% %fill in waveperiod NaNmean (toggle with commment)
% sigH(sigH ==0) = nanmean(sigH); % Setting blank "0" wh to NaN
% sigH(isnan(sigH)) = nanmean(sigH);
sigH(sigH ==0) = nan; % Fill nan for blank

% Default val fill (Moved from the COARE algorithm to here for better reference)

% Option to set local variables to default values if input is NaN... can do
% single value or fill each individual. Warning... this will fill arrays
% with the dummy values and produce results where no input data are valid
% ii=find(isnan(P)); P(ii)=1013;    % pressure
% ii=find(isnan(sw_dn)); sw_dn(ii)=200;   % incident shortwave radiation
% ii=find(isnan(lat)); lat(ii)=45;  % latitude
% ii=find(isnan(lw_dn)); lw_dn(ii)=400-1.6*abs(lat(ii)); % incident longwave radiation
ii=find(isnan(zi)); zi(ii)=600;   % PBL height
% ii=find(isnan(Ss)); Ss(ii)=35;    % Salinity


%% Make correlation

% calculate pct diff of ustr and dT_skin

qual_dT_skin = ([SWIFT.dT_skin]' - fluxes.dT_skin)./[SWIFT.dT_skin]';
qual_ustr = ([SWIFT.windustar]' -fluxes.usr) ./ [SWIFT.windustar]';

matrix = [u', t', rh',...
P', ts', sw_dn', lw_dn', lat', lon', ...
jd', rain', Ss', cp', sigH',[SWIFT.fetch]', [SWIFT.Tskin]', ...
[SWIFT.watertemp]' - [SWIFT.Tskin]', real(fluxes.dT_skin), qual_dT_skin, qual_ustr];
matrix = matrix(~any(isnan(matrix), 2), :);

figure('Position', [50 50 1500 900])

corrmatrix = corr(matrix,'type', 'Spearman');
variableNames = {'windspd', 'airtemp', 'relative humidity', ...
'P', 'watertemp', 'SWrad dw', 'LWrad dw', 'lat', 'lon', ...
'time','rain', 'Salinity', 'Wave age', 'sigH','fetch','Obs Tskin', 'Obs dTskin',...
'COARE dTskin', 'dTskindiff', 'ustrdiff'};

h = heatmap(corrmatrix);
colormap(cmocean('balance'))
caxis([-1 1])
h.XDisplayLabels = variableNames;
h.YDisplayLabels = variableNames;

ID  = string(mode(str2double(string({SWIFT.ID}))));

title(sprintf('Correlation Coefficients from COARE inputs and outputs SWIFT %s', ID))

print('-djpeg', fullfile(cd, strcat(string(ID), "_COARE_corrmatrix")))




end