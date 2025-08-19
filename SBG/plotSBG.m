function [fh,sbgData] = plotSBG(sbgData,varargin)

% Plots 'raw' (not derived products) SBG data. If varargin = 'qcdata',
% performs a linear interpolation through spikes identified by a 5 point
% (1 seconds, if sampled at 5 Hz) moving median filter.

% K. Zeiden 08

fs = 1./(median(diff(sbgData.UtcTime.time_stamp),'omitnan').*10^(-6));

if strcmp(varargin{1},'qcdata') || strcmp(varargin{1},'qc')
    qcdata = true;
else
    qcdata = false;
end

if qcdata
    fields = fieldnames(sbgData);
    for idf = 1:length(fields)
        vects = fieldnames(sbgData.(fields{idf}));
        for ivec = 1:length(vects)
            sbgData.(fields{idf}).(vects{ivec}) = filloutliers(sbgData.(fields{idf}).(vects{ivec}),'linear','movmedian',fs);
        end
    end
end
sbgData.UtcTime.datetime = datenum([sbgData.UtcTime.year(:) sbgData.UtcTime.month(:) sbgData.UtcTime.day(:) ...
    sbgData.UtcTime.hour(:) sbgData.UtcTime.min(:) sbgData.UtcTime.sec(:)+sbgData.UtcTime.nanosec(:)*10^(-9)])';

fh = figure('color','w');
MP = get(0,'monitorposition');
set(fh,'outerposition',MP(1,:));

% Gyroscope
subplot(4,2,1)
plot(sbgData.ImuData.gyro_x)
hold on
plot(sbgData.ImuData.gyro_y)
plot(sbgData.ImuData.gyro_z)
title('Gryo (\delta\theta/\deltat)')
legend('x','y','z')
ylabel('rads^{-1}')
axis tight; 
if ~qcdata;ylim([-1 1]);end

% IMU
subplot(4,2,3)
plot(sbgData.ImuData.accel_x)
hold on
plot(sbgData.ImuData.accel_y)
plot(sbgData.ImuData.accel_z)
title('Acceleration (\deltau/\deltat)');
axis tight;if ~qcdata; ylim([-10 10]);end
ylabel('ms^{-2}')

% Magnetometer
subplot(4,2,5)
plot(sbgData.Mag.mag_x)
hold on
plot(sbgData.Mag.mag_y)
plot(sbgData.Mag.mag_z)
title('Magnetometer')
axis tight; if ~qcdata;ylim([-1 1]);end
ylabel('G')

% GPS Latitude + Longitude
subplot(4,2,7)
yyaxis left
plot(sbgData.GpsPos.long,'-k')
set(gca,'YColor','k')
axis tight; if ~qcdata;ylim(median(sbgData.GpsPos.long,'omitnan')+[-0.01 0.01]);end
ylabel('^{\circ}E')
yyaxis right
plot(sbgData.GpsPos.lat,'-','color',rgb('grey'))
set(gca,'YColor','k')
ylabel('^{\circ}N')
axis tight; if ~qcdata;ylim(median(sbgData.GpsPos.lat,'omitnan')+[-0.1 0.1]);end
legend('Latitude','Longitude')
title('GPS')
xlabel('N');ylabel('^{\circ}N')
set(gca,'YColor',rgb('grey'))

% Time stamps
subplot(4,2,2:2:8)
plot(sbgData.UtcTime.time_stamp*10^(-6),'-kx')
hold on
plot(sbgData.ImuData.time_stamp*10^(-6),'-rx')
plot(sbgData.Mag.time_stamp*10^(-6),'-bx')
plot(sbgData.GpsPos.time_stamp*10^(-6),'-gx')
legend('Time','IMU','Mag','GPS')
axis tight
ylabel('T [s]')
xlabel('N')

end