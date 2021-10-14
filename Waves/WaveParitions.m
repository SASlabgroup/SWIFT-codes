% parition SWIFT data into swell and sea
% using a fixed cutoff
% ** future version should use spectral wave age
% ** or parition the 2-D spectra as done by Portilla et al
%
% J. Thomson, Oct 2021

%load('Swift-20-SCALE-Spring_reprocessedIMU_RC.mat');

fcutoff = 0.14; % Hz

for si=1:length(SWIFT)
    
    plotflag = false; % turn on/off polar plots of 2-D spectra
    recip = true; % turn on/off reciprical heading (waves "towards" or "from")
    [Etheta theta E f dir spread spread2 spread2alt ] = SWIFTdirectionalspectra(SWIFT(si), plotflag, recip);
    
    swell = f < fcutoff;
    sea = f >= fcutoff;
    df = median(diff(f));
    
    Hswell(si) = 4 * nansum(E(swell)*df)^.5; % partitioned wave height
    Dswell(si)  = nansum(dir(swell).*E(swell)) ./ nansum(E(swell));  % energy-weighted direction
    
    Hsea(si)  = 4 * nansum(E(sea)*df)^.5;
    Dsea(si)  = nansum(dir(sea).*E(sea)) ./ nansum(E(sea));  % energy-weighted direction

end

%% plot

figure(1), clf
subplot(2,1,1)
plot([SWIFT.time],[SWIFT.sigwaveheight],[SWIFT.time],Hswell,[SWIFT.time],Hsea)
ylabel('H [m]')
datetick
legend('total','swell','sea')

subplot(2,1,2)
plot([SWIFT.time],[SWIFT.peakwavedirT],[SWIFT.time],Dswell,[SWIFT.time],Dsea)
ylabel('D [deg]')
datetick
legend('total','swell','sea')