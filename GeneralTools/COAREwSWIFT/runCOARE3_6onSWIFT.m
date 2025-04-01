function [fluxes Qnet] = runCOAREonSWIFT( SWIFT );
% function to run the COARE flux algoritm on a SWIFT data structure
% using whatever fields are available
% (and making assumptions about the rest)
% this assumes the user has COARE 3.5 installed and in their path 
% (separate from SWIFT codes)
%
% [fluxes Qnet] = runCOAREonSWIFT( SWIFT );
% 
% Obtain NEW COARE 3.6 from git@github.com:NOAA-PSL/COARE-algorithm.git
%
% output is an array of fluxes (see COARE routines for columns)
%   and a Qnet estimate, if radiation available
%
% J. Thomson, 9/2018
%
% TO DO: adjust windspd for wind relative to current (vector difference the drift spd)
%
% M. James 9/2024
% Added in reference to new COARE algorithm; Key for output, included new
% required inputs; reference and comment toggle between "Warm" and base
% scripts
% Added in drift to correct wind spd
% Added input plots
% Added in table conversion (no more manual indexing)
%

savepath = 'C:\Users\MichaelJames\Dropbox\mjames\Carson_COAREcomparision\COARE_IO';
cd(savepath); fprintf('Savepath: %s', savepath);
%% Time in Julian Day
time = [SWIFT.time];
jd = time;

%% wind speed and height
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

% Plot input
figure
plot(time, u,'x'); legend(sprintf('reference height = %g', zu));grid on;
title('COARE input');
datetick
ylabel('Wind [m/s]')

print('-djpeg',[cd '\' sprintf('%s_COAREinputwind.jpeg',SWIFT(1).ID)])

%% air temp and height
if isfield(SWIFT,'airtemp') && any(~isnan([SWIFT.airtemp])),
    t = [SWIFT.airtemp];
else
    disp('missing air temp, COARE will skip most results')
    t = NaN; % required parameter, setting to zero remove most results
end
zt = zu; % air temp height is same as wind height
zrf_t = zrf_u; %same reference

% Plot input
figure; 
plot(time, t,'x'); legend(sprintf('reference height = %g', zt));grid on;
title('COARE input');
datetick
ylabel('Air temp [deg C]')

print('-djpeg',[cd '\' sprintf('%s_COAREinputairtemp.jpeg',SWIFT(1).ID)])

%% relative humidity and height
if isfield(SWIFT,'relhumidity') && any(~isnan([SWIFT.relhumidity])),
    rh = [SWIFT.relhumidity];
else
    rh = 95.*ones(1,length(SWIFT)); % cannot be NaN, must have a value
end
zq = zu; % rh height is same as wind height
zrf_q = zrf_u; %same reference

% Plot input
figure; 
plot(time, rh,'x'); legend(sprintf('reference height = %g', zq));grid on;
title('COARE input');
datetick
ylabel('Humidity [%]')

print('-djpeg',[cd '\' sprintf('%s_COAREinputhumidity.jpeg',SWIFT(1).ID)])

%% air pressure
if isfield(SWIFT,'airpres') && any(~isnan([SWIFT.airpres])),
    P = [SWIFT.airpres];
else
    P = NaN;
end

% Plot input
figure; 
plot(time, P,'x'); legend(sprintf('reference height = %g', zt));grid on;
title('COARE input');
datetick
ylabel('Air pressure [mbar]')

print('-djpeg',[cd '\' sprintf('%s_COAREinputairpressure.jpeg',SWIFT(1).ID)])

%% water temp
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


% Plot input
figure; 
plot(time, ts,'x'); legend(sprintf('reference depth = %g', ts_depth(1)));grid on;
title('COARE input');
datetick
ylabel('Water temp [deg C]')

print('-djpeg',[cd '\' sprintf('%s_COAREinputwatertemp.jpeg',SWIFT(1).ID)])

%% Water Salinity
if isfield(SWIFT,'salinity') && any(~isnan([SWIFT.salinity])),
    Ss = [SWIFT.salinity];
else
    Ss = NaN;
end;

% Plot input
figure; 
plot(time, Ss,'x'); legend(sprintf('reference depth = %g', ts_depth(1)));grid on;
title('COARE input');
datetick
ylabel('Salinity [PSU]')

print('-djpeg',[cd '\' sprintf('%s_COAREinputsalinity.jpeg',SWIFT(1).ID)])

%% downwelling radiation
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

% Plot input
figure; 
yyaxis left
plot(time, lw_dn,'x');
ylabel('LW Radiation Downwelling [W/m^2]');
datetick; set(gca,'XGrid', 'on')
yyaxis right
plot(time,sw_dn,'o')
ylabel('SW Radiation Downwelling [W/m^2]');
title('COARE input');

print('-djpeg',[cd '\' sprintf('%s_COAREinputraddwnwell.jpeg',SWIFT(1).ID)])
%% latitude and lon
% lat = nanmean([SWIFT.lat]); % single value, not vector
% lon = nanmean([SWIFT.lon]); % single value, not vector
lat = [SWIFT.lat]; % vector
lon = [SWIFT.lon]; % vector

%fill in NaN with nanmean (toggle with comment)
lat(isnan(lat)) = nanmean(lat);
lon(isnan(lon)) = nanmean(lon);



geoplot(lat, lon);
title('COARE input');
print('-djpeg',[cd '\' sprintf('%s_COAREinputlatlon.jpeg',SWIFT(1).ID)])

%% atmospheric PBL height
zi = NaN;

%% rain rate
if isfield(SWIFT,'rainint') && any(~isnan([SWIFT.rainint])),
    rain = [SWIFT.rainint];
else
    rain = zeros(length(SWIFT),1); % cannot be NaN, must have a value
end

figure; 
plot(time, rain,'x'); grid on;
title('COARE input');
datetick
ylabel('Rain Rate')

print('-djpeg',[cd '\' sprintf('%s_COAREinputrain.jpeg',SWIFT(1).ID)])

%% waves
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

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Comment OUT unless you
% want no waves
% sigH = repmat(nan,[1 573]);
% cp = repmat(nan,[1 573]);
% Tp = repmat(nan,[1 573]);


figure; 
subplot(311)
plot(time, sigH,'x'); grid on;
title('COARE input');
datetick
ylabel('Wave Height [m]')
subplot(312)
plot(time, Tp,'x'); grid on;
datetick
ylabel("Peak Wave Period (s)")
subplot(313)
plot(time, cp,'x'); grid on;
datetick
ylabel("Wave Speed (m/s)")

print('-djpeg',[cd '\' sprintf('%s_COAREinputwaveheight.jpeg',SWIFT(1).ID)])

%% Default val fill (Moved from the COARE algorithm to here for better reference)

% Option to set local variables to default values if input is NaN... can do
% single value or fill each individual. Warning... this will fill arrays
% with the dummy values and produce results where no input data are valid
% ii=find(isnan(P)); P(ii)=1013;    % pressure
% ii=find(isnan(sw_dn)); sw_dn(ii)=200;   % incident shortwave radiation
% ii=find(isnan(lat)); lat(ii)=45;  % latitude
% ii=find(isnan(lw_dn)); lw_dn(ii)=400-1.6*abs(lat(ii)); % incident longwave radiation
ii=find(isnan(zi)); zi(ii)=600;   % PBL height
% ii=find(isnan(Ss)); Ss(ii)=35;    % Salinity

%% run COARE
% Running Warm Layer inclusive script (other script commented out)
% fluxes = coare36vn_zrf_et(u',zu,t',zt,rh',zq,P',ts',sw_dn',lw_dn',lat',lon',jd',zi,rain',Ss',cp',sigH',zrf_u,zrf_t,zrf_q)
fluxes = coare36vnWarm_et(jd',u',zu,t',zt,rh',zq,P',ts',sw_dn',lw_dn',lat',lon',zi,rain',ts_depth',Ss',cp',sigH',zrf_u,zrf_t,zrf_q)

validcolumns = find( nansum( fluxes, 1 ) ~= 0  & ~isnan(nansum( fluxes, 1 )) );

ustar = fluxes(:,1); % wind friction velocity
tau = fluxes(:,2);%   tau = wind stress (N/m^2)
hsb = fluxes(:,3);%   hsb = sensible heat flux into (out of?) ocean (W/m^2)
hlh = fluxes(:,4);%   hlb = latent heat flux into (out of?) ocean (W/m^2)
hbb = fluxes(:,5);%   hbb = buoyancy flux into (out of?) ocean (W/m^2)
hsbb = fluxes(:,6);%   hsbb = "sonic" buoyancy flux measured directly by sonic anemometer
Cd = fluxes(:,13);
LWrad = fluxes(:,28); 
U10 = fluxes(:,33);
U10N = fluxes(:,34);

% Convert to labeled table

fluxes = array2table(fluxes, ...
     'VariableNames',{ ...
    'usr' 'tau' 'hsb' 'hlb' 'hbb' 'hsbb' 'hlwebb' 'tsr' 'qsr' 'zo'  'zot'...
    'zoq' 'Cd' 'Ch' 'Ce'  'L'  'zeta' 'dT_skin' 'dq_skin' 'dz_skin' 'Urf'...
    'Trf' 'Qrf' 'RHrf' 'UrfN' 'TrfN' 'QrfN'  'lw_net' 'sw_net' 'Le' 'rhoa'...
    'UN' 'U10' 'U10N' 'Cdn_10' 'Chn_10' 'Cen_10' 'hrain' 'Qs' 'Evap' 'T10'...
    'T10N' 'Q10' 'Q10N'  'RH10' 'P10' 'rhoa10' 'gust' 'wc_frac' 'Edis'...
    'dT_warm'  'dz_warm'  'dT_warm_to_skin'  'du_warm'
    })
% KEY for flux indexing
%1    usr = friction velocity that includes gustiness (m/s), u*
%2    tau = wind stress that includes gustiness (N/m^2)
%3    hsb = sensible heat flux (W/m^2) ... positive for Tair < Tskin
%4    hlb = latent heat flux (W/m^2) ... positive for qair < qs
%5    hbb = atmospheric buoyany flux (W/m^2)... positive when hlb and hsb heat the atmosphere
%6   hsbb = atmospheric buoyancy flux from sonic ... as above, computed with sonic anemometer T
%7 hlwebb = webb factor to be added to hl covariance and ID latent heat fluxes
%8    tsr = temperature scaling parameter (K), t*
%9    qsr = specific humidity scaling parameter (kg/kg), q*
%10     zo = momentum roughness length (m) 
%1    zot = thermal roughness length (m) 
%2    zoq = moisture roughness length (m)
%3     Cd = wind stress transfer (drag) coefficient at height zu (unitless)
%4     Ch = sensible heat transfer coefficient (Stanton number) at height zu (unitless)
%5     Ce = latent heat transfer coefficient (Dalton number) at height zu (unitless)
%6      L = Monin-Obukhov length scale (m) 
%7    zeta = Monin-Obukhov stability parameter zu/L (dimensionless)
%8 dT_skin = cool-skin temperature depression (degC), pos value means skin is cooler than subskin
%9 dq_skin = cool-skin humidity depression (g/kg)
%20 dz_skin = cool-skin thickness (m)
%1    Urf = wind speed at reference height (user can select height at input)
%2    Trf = air temperature at reference height
%3    Qrf = air specific humidity at reference height
%4   RHrf = air relative humidity at reference height
%5   UrfN = neutral value of wind speed at reference height
%6   TrfN = neutral value of air temp at reference height
%7  qarfN = neutral value of air specific humidity at reference height
%8 lw_net = Net IR radiation computed by COARE (W/m2)... positive heating ocean
%9 sw_net = Net solar radiation computed by COARE (W/m2)... positive heating ocean
%30     Le = latent heat of vaporization (J/K)
%1   rhoa = density of air at input parameter height zt, typically same as zq (kg/m3)
%2     UN = neutral value of wind speed at zu (m/s)
%3    U10 = wind speed adjusted to 10 m (m/s)
%4   UN10 = neutral value of wind speed at 10m (m/s)
%5 Cdn_10 = neutral value of drag coefficient at 10m (unitless)
%6 Chn_10 = neutral value of Stanton number at 10m (unitless)
%7 Cen_10 = neutral value of Dalton number at 10m (unitless)
%8  hrain = rain heat flux (W/m^2)... positive cooling ocean
%9     Qs = sea surface specific humidity, i.e. assuming saturation (g/kg)
%40   Evap = evaporation rate (mm/h)
%1    T10 = air temperature at 10m (deg C)
%2    Q10 = air specific humidity at 10m (g/kg)
%3   RH10 = air relative humidity at 10m (%)
%4    P10 = air pressure at 10m (mb)
%5 rhoa10 = air density at 10m (kg/m3)
%6   gust = gustiness velocity (m/s)
%7 wc_frac = whitecap fraction (ratio)
%8   Edis = energy dissipated by wave breaking (W/m^2)
%9   dT_warm  - dT from base of warm layer to skin, i.e. warming across entire warm layer depth (deg C) 
%50  dz_warm  - warm layer thickness (m)
%1   dT_warm_to_skin  -dT from measurement depth to skin due to warm layer, 
%                       such that Tskin = Tsea + dT_warm_to_skin - dT_skin
%2   du_warm - total current accumulation in warm layer (m/s ?...  unsure of units but likely m/s)

%% calc net radiative balance (since COARE does not seem to do it)
% albedo = 0.08; % 0.08 is open water, but can bemuch higher with ice.  see Persson et al JGR 2018, Eq. 1
% SWradup = albedo * sw_dn';
% FLUXES Calculated within COARE 3.6, option for lat/lon and time/zenith angle specific albedo
% according to Payne 1972 or constant

fluxes.sw_up = [SWIFT.SWrad]' - fluxes.sw_net; % positive heating ocean

% choose one below (based on interpretation of column 25)
fluxes.lw_up = [SWIFT.LWrad]' - fluxes.lw_net; %positive heating ocean

% calc net rad
fluxes.netrad = fluxes.sw_net + fluxes.lw_net;
fluxes.Qnet = fluxes.netrad - fluxes.hsb - fluxes.hlb; % positive heating ocean; Ta < Tskin; Ta < Tskin
Qnet = fluxes.Qnet;

%% plot key values as time series

plotCOAREfromSWIFT(SWIFT, fluxes); 
% Much more simplified; split into a separate call to plotting script
% Legacy code below




% rtime = max(time) - min(time);
% 
% figure, clf
% ax(1) = subplot(3,1,1);
% plot(time,t,'kx',time,ts,'md');
% legend('air temp','water temp')
% ylabel('[C]')
% datetick, set(gca,'XLim',[min(time) max(time)+0.3*rtime])
% if isfield(SWIFT,'ID'), title(SWIFT(1).ID), else, end
% ax(2) = subplot(3,1,2);
% plot(time,hsb,'bx',time,hlh,'r+',time,hbb,'g.',time,hsbb,'c.');
% legend('Q_{sen}','Q_{latent}','Q_{buoy}','Q_{sbuoy}')
% if isfield(SWIFT,'Qsen'), 
%     hold on
%     plot(time,[SWIFT.Qsen],'kd')
%     plot([min(time) max(time)],[ 0 0],'k:')
%     legend('Q_{sen}','Q_{latent}','Q_{buoy}','Q_{sbuoy}','Q_{wT}')
% else
% end
% hold on
% datetick
% ylabel('[W/m^2]')
% ax(3) = subplot(3,1,3);
% plot(time,u,'kx',time,U10,'b+');
% datetick
% legend('measured wind','U_{10}')
% ylabel('[m/s]')
% linkaxes(ax,'x')
% if isfield(SWIFT,'ID'),
%     print('-dpng',[SWIFT(1).ID '_COAREfluxes.png'])
% else
%     print('-dpng',['COAREfluxes.png'])
% end
% 
% 
% figure, clf
% ax(1) = subplot(3,1,1);
% yyaxis left
% plot(time,sw_dn,'x');ylabel('SW down [W/m^2]')
% yyaxis right
% plot(time,lw_dn,'rx');ylabel('LW down [W/m^2]')
% datetick, set(gca,'XLim',[min(time) max(time)+0.3*rtime])
% if isfield(SWIFT,'ID'), title(SWIFT(1).ID), else, end
% ax(2) = subplot(3,1,2);
% yyaxis left
% plot(time,SWradup,'x'); ylabel('SW up [W/m^2]')
% yyaxis right
% plot(time,LWradup,'rx');ylabel('LW up [W/m^2]')
% datetick
% ax(3) = subplot(3,1,3);
% plot(time,netrad,'go',time,Qnet,'ks'); hold on
% plot([min(time) max(time)],[ 0 0],'k:')
% legend('Net rad','Net all')
% datetick
% ylabel('[W/m^2]')
% linkaxes(ax,'x')
% if isfield(SWIFT,'ID'),
%     print('-dpng',[SWIFT(1).ID '_radfluxes.png'])
% else
%     print('-dpng',['radfluxes.png'])
% end
% 
% 
% if isfield(SWIFT,'windustar') && length(ustar) == length([SWIFT.windustar]),
%     figure, clf
%     plot(u,ustar,'kx',u,[SWIFT.windustar],'ro'), 
%     legend('COARE','inertial')
%     if isfield(SWIFT,'windustar_directcovar') && length(ustar) == length([SWIFT.windustar_directcovar]),
%         hold on
%         plot(u,[SWIFT.windustar_directcovar],'b.')
%         legend('COARE','inertial','direct covar')
%     else
%     end
% 
%     axis square, grid
%     axis([ 0 15 0 1])
%     xlabel('Measured wind spd [m/s]')
%     ylabel('u_* [m/s]')
%     if isfield(SWIFT,'ID'), title(SWIFT(1).ID), else, end
% 
%     if isfield(SWIFT,'ID'),
%         print('-dpng',[SWIFT(1).ID '_ustar.png'])
%     else
%         print('-dpng',['ustar.png'])
%     end
% 
% else
% end
% 
% if isfield(SWIFT,'windustar') && length(tau) == length([SWIFT.time]),
%     figure, clf
%     inertialtau = fluxes.rhoa.*[SWIFT.windustar]'.^2;
%     plot(time,tau,'kx',time,inertialtau,'ro'); datetick;
%     legend('COARE','inertial')
%     if isfield(SWIFT,'windustar_directcovar') && length(ustar) == length([SWIFT.windustar_directcovar]),
%         hold on
%         directcovartau = fluxes.rhoa.*[SWIFT.windustar_directcovar]'.^2;
%         plot(time,[SWIFT.windustar_directcovar],'b.')
%         legend('COARE','inertial','direct covar')
%     else
%     end
% 
%     grid minor;
%     xlabel('[UTC]')
%     ylabel('\tau [N/m^2]')
% 
%     if isfield(SWIFT,'ID'), title(SWIFT(1).ID), else, end
% 
%     if isfield(SWIFT,'ID'),
%         print('-dpng',[SWIFT(1).ID '_tau.png'])
%     else
%         print('-dpng',['_tau.png'])
%     end
% 
% else
% end



