function [x,y,z, hs ] = rawdisplacements(AHRS);
% function to estimate raw displacements from SWIFT buoys 
% also returns significant wave height, as estimated from the displacements
% this Hs should be checked against the spectral result 
% (SWIFT onboard processing) for quality assurance
%
% J. Thomson, modified from Tony de Paolo at Scripps 
%   v1, Jul 2015
%   v2, Sep 2015  fix bug in quaternion code
%   v3, Sep 2017 change to 10 dB of attenuation in the stopband of the elliptic filter
%   v4, Oct 2017  change eliptic filter to RC filter

RC = 4;


dt = median(diff(AHRS.Timestamp_sec));  % should be 0.04 s
if isnan(dt), dt = 600 ./ length(AHRS.Accel); else end
fs = 1/dt; % should be 25 Hz

%% convert to earth reference frame
a = quat_rotate_vector( AHRS.Accel , AHRS.Quat );


%% filter and integrate accelarations to velocities
ax = 9.8 * a(:,1); % m/ s^2 %duplicate steps
ay = 9.8 * a(:,2); % m/ s^2
az = 9.8 * a(:,3); % m/ s^2
ax = ax - nanmean(ax);
ay = ay - nanmean(ay);
az = az - nanmean(az);

% eliptic filter
%[B,A] = ellip(3, .5, 10, 0.05/(fs/2), 'high'); % original is ellip(3, .5, 20, 0.05/(fs/2), 'high');
%fax = filtfilt(B, A, double(ax(~isnan(ax))));
%fay = filtfilt(B, A, double(ay(~isnan(ay))));
%faz = filtfilt(B, A, double(az(~isnan(az))));

% RC filter
alpha = RC / (RC + 1./fs); 
fax(1) = ax(1); fay(1)=ay(1); faz(1)=az(1);
for ui = 2:length(ax),
    fax(ui) = alpha * fax(ui-1) + alpha * ( ax(ui) - ax(ui-1) );
    fay(ui) = alpha * fay(ui-1) + alpha * ( ay(ui) - ay(ui-1) );
    faz(ui) = alpha * faz(ui-1) + alpha * ( az(ui) - az(ui-1) );
end

u = cumtrapz(fax)*dt; % m/s, preferred over GPS.NED_Vel.Velocity_NED(:,3);
v = cumtrapz(fay)*dt; % m/s, preferred over GPS.NED_Vel.Velocity_NED(:,3);
w = cumtrapz(faz)*dt; % m/s, preferred over GPS.NED_Vel.Velocity_NED(:,3);
u = detrend(u);
v = detrend(v);
w = detrend(w);

%% filter and integrate velocities to displacements

% eliptic filter
%fu = filtfilt(B, A, double(u));
%fv = filtfilt(B, A, double(v));
%fw = filtfilt(B, A, double(w));

% RC filter
alpha = RC / (RC + 1./fs); 
fu(1) = u(1); fv(1)=v(1); fw(1)=w(1);
for ui = 2:length(ax),
    fu(ui) = alpha * fu(ui-1) + alpha * ( u(ui) - u(ui-1) );
    fv(ui) = alpha * fv(ui-1) + alpha * ( v(ui) - v(ui-1) );
    fw(ui) = alpha * fw(ui-1) + alpha * ( w(ui) - w(ui-1) );
end


x = cumtrapz(fu)*dt; % m
y = cumtrapz(fv)*dt; % m
z = cumtrapz(fw)*dt; % m
x = x - nanmean(x);
y = y - nanmean(y);
z = z - nanmean(z);

x( 1:(round(50/dt)) ) = NaN; % prune start points, which are contaminated by filter
x( (end-(round(50/dt))) : end ) = NaN; % prune end points, which are contaminated by filter
y( 1:(round(50/dt)) ) = NaN; % prune start points, which are contaminated by filter
y( (end-(round(50/dt))) : end ) = NaN; % prune end points, which are contaminated by filter
z( 1:(round(50/dt)) ) = NaN; % prune start points, which are contaminated by filter
z( (end-(round(50/dt))) : end ) = NaN; % prune end points, which are contaminated by filter
hs = 4 * sqrt(var(z( ~isnan(z)  )));  % check this against spectral result

%% optional plotting
% figure(1), clf, 
% ax(1) = subplot(3,1,1);
% plot(AHRS.Timestamp_sec,a)
% ax(2) = subplot(3,1,2);
% plot(AHRS.Timestamp_sec,w)
% ax(3) = subplot(3,1,3);
% plot(AHRS.Timestamp_sec,z)
% 
% linkaxes(ax,'x')

