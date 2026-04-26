% matlab script to test NEDwaves,
% especially the memory light version relative to the full version
%
% J Thomson, 12/2025
%   updated 4/2026 to loop thru several raw files

clear all

%fs=3.9; 
fs=4000
dropbox_dir = '/Users/jthomson/Dropbox/engineering/SWIFT/microSWIFT_v2/Documentation/Accelerometer/20260426_4khz_tabletop/';
% dropbox_dir = '/Users/lindzey/Dropbox/microSWIFT_v2/Documentation/Accelerometer/20260406_ADXL355_data/';

%% load data

flist = dir([dropbox_dir '*data*.txt']);

for fi = 1:length(flist)
    testdata = importdata([dropbox_dir flist(fi).name]);

%fs=3.9; testdata = importdata(dropbox_dir + "microSWIFT_v2/Documentation/Accelerometer/20260406_ADXL355_data/accel_data_0000.txt");
%fs=3.9; testdata = importdata(dropbox_dir + "microSWIFT_v2/Documentation/Accelerometer/20251208_ADXL355_data/accel_data_0000.txt");
%fs=4000; testdata = importdata(dropbox_dir + "microSWIFT_v2/Documentation/Accelerometer/20251001_ADXL355_data/table_quiet/accel_data_0004.txt");
%fs=4000; testdata = importdata(dropbox_dir + "microSWIFT_v2/Documentation/Accelerometer/20251001_ADXL355_data/table_accelerations/accel_data_0002.txt");
%fs=4000; testdata = importdata(dropbox_dir + "microSWIFT_v2/Documentation/Accelerometer/20260426_4khz_tabletop/");


x = single( testdata(:,3)' * 9.8 ); % convert from g to m/s^2 and make row vector (1xM)
y = single( testdata(:,4)' * 9.8 ); % convert from g to m/s^2 and make row vector (1xM)
z = single( testdata(:,5)' * 9.8 ); % convert from g to m/s^2 and make row vector (1xM)


%% plots and basic stats

figure(1), clf
plot(x), hold on, plot(y), plot(z)

%mean(x), mean(y), mean(z)

%% prune data (try to break code)
prune = [];
x(prune)=[];
y(prune)=[];
z(prune)=[];


%% run code

[ fmin, fmax, XX, YY, ZZ] = XYZaccelerationspectra(x, y, z, fs);

[ fmin_lel, fmax_lel, XX_lel, YY_lel, ZZ_lel] = XYZaccelerationspectra_C_refactor(x, y, z, fs);


f = linspace(fmin,fmax,length(XX));
f_lel = linspace(fmin_lel,fmax_lel,length(XX_lel));


figure(2), clf
subplot(1,2,1)
plot(x./9.8), hold on
plot(y./9.8), hold on
plot(z./9.8), hold on
legend('x','y','z')
%axis([1e-2 1e0 1e-3 3e2])
ylabel('acc [g]')
xlabel('samples')

subplot(2,2,2)
loglog(f,XX, f,YY, f,ZZ), hold on
legend('x','y','z')
%axis([1e-2 1e0 1e-3 3e2])
ylabel('Spectral density [m^2/s^4/Hz]')
xlabel('f [Hz]')

subplot(2,2,4)
loglog(f_lel,XX_lel, f_lel,YY_lel, f_lel,ZZ_lel), hold on
legend('xl', 'yl', 'zl')
%axis([1e-2 1e0 1e-3 3e2])
ylabel('Spectral density [m^2/s^4/Hz]')
xlabel('f [Hz]')

%subplot(3,1,3)
%semilogx(f,XX-XX_lel, f,YY-YY_lel, f,ZZ-ZZ_lel), hold on
%legend('x','y','z')

print('-dpng', [dropbox_dir flist(fi).name(1:(end-4)) '_spectra.png']); 

disp('------------Any differences in spectra? -------- ')
ferr = max(abs(f - f_lel))
xerr = max(abs(XX-XX_lel))
yerr = max(abs(YY-YY_lel))
zerr = max(abs(ZZ-ZZ_lel))

%pause

end


