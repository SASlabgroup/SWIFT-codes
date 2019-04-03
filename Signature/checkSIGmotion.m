% check for motion contamination in SWIFT v4 Signature "avg" profiles
% (the slant beam results at 1 Hz)
% determine if AHRS corrected these onboard
%

filename =  'SWIFT23_SIG_17Sep2017_18_02.mat';

zbin = 25; % pick a bin to look at (out of 40 at 0.5 m spacing)
fs = 1;

load(filename); 

[upsd f] = pwelch(detrend( avg.VelocityData(:,zbin,1) ),[], [], [], fs);
[vpsd f] = pwelch(detrend(avg.VelocityData(:,zbin,2) ),[], [], [], fs);
[w1psd f] = pwelch(detrend(avg.VelocityData(:,zbin,3) ),[], [], [], fs);
[w2psd f] = pwelch(detrend(avg.VelocityData(:,zbin,4) ),[], [], [], fs);

[azpsd f] = pwelch(detrend(avg.Accelerometer(:,3)),[], [], [], fs);

figure(1), clf
loglog(f, azpsd.*1e-7, 'k'), hold on
loglog(f, upsd, f, vpsd, f, w1psd, f, w2psd), hold on
legend('a_z','u','v','w_1','w_2')
xlabel('f [Hz]')
title([filename ', bin ' num2str(zbin)],'interpreter','none')
print('-dpng',[filename '_bin' num2str(zbin) '.png'])