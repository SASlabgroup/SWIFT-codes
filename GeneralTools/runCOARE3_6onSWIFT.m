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
% required inputs

%% Time in Julian Day
time = [SWIFT.time];
jd = time;

%% wind speed and height
if isfield(SWIFT,'windspd') && any(~isnan([SWIFT.windspd])),
    u = [SWIFT.windspd]; % vector
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

%% air temp and height
if isfield(SWIFT,'airtemp') && any(~isnan([SWIFT.airtemp])),
    t = [SWIFT.airtemp];
else
    disp('missing air temp, COARE will skip most results')
    t = NaN; % required parameter, setting to zero remove most results
end
zt = zu; % air temp height is same as wind height
zrf_t = zrf_u; %same reference
%% relative humidity and height
if isfield(SWIFT,'relhumidity') && any(~isnan([SWIFT.relhumidity])),
    rh = [SWIFT.relhumidity];
else
    rh = 95; % cannot be NaN, must have a value
end
zq = zu; % rh height is same as wind height
zrf_q = zrf_u; %same reference
%% air pressure
if isfield(SWIFT,'airpres') && any(~isnan([SWIFT.airpres])),
    P = [SWIFT.airpres];
else
    P = NaN;
end

%% water temp
if isfield(SWIFT,'watertemp') && any(~isnan([SWIFT.airtemp])),
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

%% Water Salinity
Ss = [SWIFT.salinity];

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

%% latitude and lon
lat = nanmean([SWIFT.lat]); % single value, not vector
lon = nanmean([SWIFT.lon]); % single value, not vector

%% atmospheric PBL height
zi = NaN;

%% rain rate
if isfield(SWIFT,'rainint') && any(~isnan([SWIFT.rainint])),
    rain = [SWIFT.rainint];
else
    rain = 0; % cannot be NaN, must have a value
end

%% waves
if isfield(SWIFT,'peakwaveperiod') && any(~isnan([SWIFT.peakwaveperiod])),
    Tp = [SWIFT.peakwaveperiod];
    cp = 9.8 * Tp ./ (2 * pi);  % assume deep water dispersion relation
else
    cp = NaN;
end
if isfield(SWIFT,'sigwaveheight') && any(~isnan([SWIFT.sigwaveheight])),
    sigH = [SWIFT.sigwaveheight];
else
    sigH = NaN;
end

%% Default val fill (Moved from the COARE algorithm to here for better reference)

% Option to set local variables to default values if input is NaN... can do
% single value or fill each individual. Warning... this will fill arrays
% with the dummy values and produce results where no input data are valid
ii=find(isnan(P)); P(ii)=1013;    % pressure
ii=find(isnan(sw_dn)); sw_dn(ii)=200;   % incident shortwave radiation
ii=find(isnan(lat)); lat(ii)=45;  % latitude
ii=find(isnan(lw_dn)); lw_dn(ii)=400-1.6*abs(lat(ii)); % incident longwave radiation
ii=find(isnan(zi)); zi(ii)=600;   % PBL height
ii=find(isnan(Ss)); Ss(ii)=35;    % Salinity

%% run COARE

fluxes = coare36vn_zrf_et(u',zu,t',zt,rh',zq,P',ts',sw_dn',lw_dn',lat',lon',jd,zi,rain',Ss',cp',sigH',zrf_u,zrf_t,zrf_q)

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

%% calc net radiative balance (since COARE does not seem to do it)
albedo = 0.08; % 0.08 is open water, but can bemuch higher with ice.  see Persson et al JGR 2018, Eq. 1
SWradup = albedo * sw_dn';

% choose one below (based on interpretation of column 25)
LWnet = LWrad; LWradup = lw_dn' - LWnet;
%LWradup = LWrad; LWnet = lw_dn' - LWradup;

% calc net rad
netrad = sw_dn' - SWradup + LWnet;
Qnet = netrad - hsb - hlh;


%% plot key values as time series
rtime = max(time) - min(time);

figure(1), clf
ax(1) = subplot(3,1,1);
plot(time,t,'kx',time,ts,'md');
legend('air temp','water temp')
ylabel('[C]')
datetick, set(gca,'XLim',[min(time) max(time)+0.3*rtime])
if isfield(SWIFT,'ID'), title(SWIFT(1).ID), else, end
ax(2) = subplot(3,1,2);
plot(time,hsb,'bx',time,hlh,'r+',time,hbb,'g.',time,hsbb,'c.');
legend('Q_{sen}','Q_{latent}','Q_{buoy}','Q_{sbuoy}')
if isfield(SWIFT,'Qsen'), 
    hold on
    plot(time,[SWIFT.Qsen],'kd')
    plot([min(time) max(time)],[ 0 0],'k:')
    legend('Q_{sen}','Q_{latent}','Q_{buoy}','Q_{sbuoy}','Q_{wT}')
else
end
hold on
datetick
ylabel('[W/m^2]')
ax(3) = subplot(3,1,3);
plot(time,u,'kx',time,U10,'b+');
datetick
legend('measured wind','U_{10}')
ylabel('[m/s]')
linkaxes(ax,'x')
if isfield(SWIFT,'ID'),
    print('-dpng',[SWIFT(1).ID '_COAREfluxes.png'])
else
    print('-dpng',['COAREfluxes.png'])
end


figure(2), clf
ax(1) = subplot(3,1,1);
plot(time,sw_dn,'x',time,lw_dn,'rx');
legend('SW down','LW down')
ylabel('[W/m^2]')
datetick, set(gca,'XLim',[min(time) max(time)+0.3*rtime])
if isfield(SWIFT,'ID'), title(SWIFT(1).ID), else, end
ax(2) = subplot(3,1,2);
plot(time,SWradup,'x',time,LWradup,'rx');
legend('SW up','LW up')
datetick
ylabel('[W/m^2]')
ax(3) = subplot(3,1,3);
plot(time,netrad,'go',time,Qnet,'ks'); hold on
plot([min(time) max(time)],[ 0 0],'k:')
legend('Net rad','Net all')
datetick
ylabel('[W/m^2]')
linkaxes(ax,'x')
if isfield(SWIFT,'ID'),
    print('-dpng',[SWIFT(1).ID '_radfluxes.png'])
else
    print('-dpng',['radfluxes.png'])
end


if isfield(SWIFT,'windustar') && length(ustar) == length([SWIFT.windustar]),
    figure(3), clf
    plot(u,ustar,'kx',u,[SWIFT.windustar],'ro'), 
    legend('COARE','inertial')
    if isfield(SWIFT,'windustar_directcovar') && length(ustar) == length([SWIFT.windustar_directcovar]),
        hold on
        plot(u,[SWIFT.windustar_directcovar],'b.')
        legend('COARE','inertial','direct covar')
    else
    end
    
    axis square, grid
    axis([ 0 15 0 1])
    xlabel('Measured wind spd [m/s]')
    ylabel('u_* [m/s]')
    if isfield(SWIFT,'ID'), title(SWIFT(1).ID), else, end

    if isfield(SWIFT,'ID'),
        print('-dpng',[SWIFT(1).ID '_ustar.png'])
    else
        print('-dpng',['ustar.png'])
    end
    
else
end



