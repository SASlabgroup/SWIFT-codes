% matlab script to test NEDwaves,
% especially the memory light version relative to the full version
%
% J Thomson, 12/2025

clear all


testdata = importdata(['/Users/jthomson/Dropbox/engineering/SWIFT/microSWIFT_v2/Documentation/Accelerometer/ADXL355Z_samples_2g_noisefloor.txt']);
x = single( testdata(:,3)' * 9.8 ); % convert from g to m/s^2 and make row vector (1xM)
y = single( testdata(:,4)' * 9.8 ); % convert from g to m/s^2 and make row vector (1xM)
z = single( testdata(:,5)' * 9.8 ); % convert from g to m/s^2 and make row vector (1xM)

fs=3.9; 

[ fmin, fmax, XX, YY, ZZ] = XYZaccelerationspectra(x, y, z, fs);

f = linspace(fmin,fmax,length(XX));


figure(1), clf
plot(x), hold on, plot(y), plot(z)

figure(2), clf
loglog(f,XX, f,YY, f,ZZ), hold on
%axis([1e-2 1e0 1e-3 3e2])
ylabel('Spectral density [m^2/s^4/Hz]')



