% matlab script to test NEDwaves,
% especially the memory light version relative to the full version
%
% J Thomson, 12/2025

clear all

%% load data
fs=3.9; testdata = importdata('/Users/lindzey/Dropbox/microSWIFT_v2/Documentation/Accelerometer/20251208_ADXL355_data/accel_data_0000.txt');
%fs=4000; testdata = importdata('/Users/lindzey/Dropbox/Documentation/Accelerometer/20251001_ADXL355_data/table_quiet/accel_data_0004.txt');
%fs=4000; testdata = importdata('/Users/lindzey/Dropbox/microSWIFT_v2/Documentation/Accelerometer/20251001_ADXL355_data/table_accelerations/accel_data_0002.txt');
x = single( testdata(:,3)' * 9.8 ); % convert from g to m/s^2 and make row vector (1xM)
y = single( testdata(:,4)' * 9.8 ); % convert from g to m/s^2 and make row vector (1xM)
z = single( testdata(:,5)' * 9.8 ); % convert from g to m/s^2 and make row vector (1xM)


%% plots and basic stats

% figure(1), clf
% plot(x), hold on, plot(y), plot(z)

%mean(x), mean(y), mean(z)

%% prune data (try to break code)
prune = [];
x(prune)=[];
y(prune)=[];
z(prune)=[];


%% run code

[ fmin, fmax, XX, YY, ZZ] = XYZaccelerationspectra(x, y, z, fs);

[ fmin_lel, fmax_lel, XX_lel, YY_lel, ZZ_lel] = XYZaccelerationspectraLEL(x, y, z, fs);


f = linspace(fmin,fmax,length(XX));
f_lel = linspace(fmin_lel,fmax_lel,length(XX_lel));


figure(2), clf
subplot(3,1,1)
loglog(f,XX, f,YY, f,ZZ), hold on
legend('x','y','z')
%axis([1e-2 1e0 1e-3 3e2])


subplot(3,1,2)
loglog(f_lel,XX_lel, f_lel,YY_lel, f_lel,ZZ_lel), hold on
legend('xl', 'yl', 'zl')
%axis([1e-2 1e0 1e-3 3e2])
ylabel('Spectral density [m^2/s^4/Hz]')


subplot(3,1,3)
semilogx(f,XX-XX_lel, f,YY-YY_lel, f,ZZ-ZZ_lel), hold on
legend('x','y','z')





