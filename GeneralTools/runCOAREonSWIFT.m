function [fluxes Qnet] = runCOAREonSWIFT( SWIFT );
% function to run the COARE flux algoritm on a SWIFT data structure
% using whatever fields are available
% (and making assumptions about the rest)
% this assumes the user has COARE 3.5 installed and in their path 
% (separate from SWIFT codes)
%
% [fluxes Qnet] = runCOAREonSWIFT( SWIFT );
%
% output is an array of fluxes (see COARE routines for columns)
%   and a Qnet estimate, if radiation available
%
% J. Thomson, 9/2018
%
% TO DO: adjust windspd for wind relative to current (vector difference the drift spd)
%

time = [SWIFT.time];

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

%% air temp and height
if isfield(SWIFT,'airtemp') && any(~isnan([SWIFT.airtemp])),
    t = [SWIFT.airtemp];
else
    disp('missing air temp, COARE will skip most results')
    t = NaN; % required parameter, setting to zero remove most results
end
zt = zu; % air temp height is same as wind height

%% relative humidity and height
if isfield(SWIFT,'relhumidity') && any(~isnan([SWIFT.relhumidity])),
    rh = [SWIFT.relhumidity];
else
    rh = 95; % cannot be NaN, must have a value
end
zq = zu; % rh height is same as wind height

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
            ts(si) =  SWIFT(si).watertemp( find( ~isnan ( SWIFT(si).watertemp ) & SWIFT(si).watertemp~=0.0, 1, 'first' ) );
        end
    end
else
    disp('missing water temp, COARE will skip most results')
    ts = NaN; % required parameter, setting to zero remove most results
end

%% downwelling radiation
if isfield(SWIFT,'SWrad') && any(~isnan([SWIFT.SWrad])),
    Rs = [SWIFT.SWrad];
else
    Rs = NaN;
end

if isfield(SWIFT,'LWrad') && any(~isnan([SWIFT.LWrad])),
    Rl = [SWIFT.LWrad];
else
    Rl = NaN;
end

%% latitude
lat = nanmean([SWIFT.lat]); % single value, not vector

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

%% run COARE

fluxes = coare35vn_a(u',zu,t',zt,rh',zq,P',ts',Rs',Rl',lat',zi,rain',cp',sigH');

validcolumns = find( nansum( fluxes, 1 ) ~= 0  & ~isnan(nansum( fluxes, 1 )) );

ustar = fluxes(:,1); % wind friction velocity
tau = fluxes(:,2);%   tau = wind stress (N/m^2)
hsb = fluxes(:,3);%   hsb = sensible heat flux into (out of?) ocean (W/m^2)
hlh = fluxes(:,4);%   hlb = latent heat flux into (out of?) ocean (W/m^2)
hbb = fluxes(:,5);%   hbb = buoyancy flux into (out of?) ocean (W/m^2)
hsbb = fluxes(:,6);%   hsbb = "sonic" buoyancy flux measured directly by sonic anemometer
Cd = fluxes(:,11);
LWrad = fluxes(:,25); % code says up, but suspect it is net
U10 = fluxes(:,29);
U10N = fluxes(:,30);


%% calc net radiative balance (since COARE does not seem to do it)
albedo = 0.08; % 0.08 is open water, but can bemuch higher with ice.  see Persson et al JGR 2018, Eq. 1
SWradup = albedo * Rs';

% choose one below (based on interpretation of column 25)
LWnet = LWrad; LWradup = Rl' - LWnet;
%LWradup = LWrad; LWnet = Rl' - LWradup;

% calc net rad
netrad = Rs' - SWradup + LWnet;
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
plot(time,hsb,'bx',time,hlh,'r+',time,hbb,'go',time,hsbb,'cs');
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
plot(time,Rs,'x',time,Rl,'rx');
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
        plot(u,[SWIFT.windustar_directcovar],'b+')
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



