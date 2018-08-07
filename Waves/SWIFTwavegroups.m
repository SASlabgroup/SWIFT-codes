function [nu GF k s SIWEH ] = SWIFTwavegroups(SWIFT,fs);
% matlab function to calculate wave group paramters from SWIFT data
% (requires post-processed raw displacements SWIFT.z at sampling fs)
%
% [nu GF k s SIWEH] = SWIFTwavegroups(SWIFT,fs);
%
%  nu is the spectral bandwidth, 
%  GF is the groupiness factor, 
%  k is kurtosis, 
%  s is skewness of the time series, 
%  SIWEH is the "smoothed instantaneous wave energy history"
%
% J. Thomson, Feb 2017
%

for si = 1:length(SWIFT),
    
    si
    
    % bandwidth metrics, following Longuet-Higgins (1957, 1984),
    df = abs(median(diff(SWIFT(si).wavespectra.freq)));
    m0 = nansum(SWIFT(si).wavespectra.freq.^0 .* SWIFT(si).wavespectra.energy) * df;
    m1 = nansum(SWIFT(si).wavespectra.freq.^1 .* SWIFT(si).wavespectra.energy) * df;
    m2 = nansum(SWIFT(si).wavespectra.freq.^2 .* SWIFT(si).wavespectra.energy) * df;
    nu(si) = sqrt( (m0*m2)./(m1.^2) - 1);
    
    % groupiness, following Funke and Mansard (1980)
    % using SIWEH, the "smoothed instantaneous wave energy history"
    dt = 1/fs;
    clear SIWEH;
    
    if true %isreal(si + length( [SWIFT(si).z] )) & (si + length( [SWIFT(si).z] ))> 0 & isinteger(si + length( [SWIFT(si).z] )),
        
        SIWEH( length( [SWIFT(si).z] ) ) = NaN;  % possibly need to make length int64 first?
        for ii = 1:length(SWIFT(si).z),
            starti = max([ 1  (ii-round( 2*SWIFT(si).peakwaveperiod./dt))]);
            stopi = min([ length(SWIFT(si).z)  (ii+round( 2*SWIFT(si).peakwaveperiod./dt))]);
            SIWEH(ii) = 1./SWIFT(si).peakwaveperiod .* nansum( SWIFT(si).z( starti:stopi ).^2 .*  bartlett( length(starti:stopi) ) .* dt );
            if SIWEH(ii) == 0,
                SIWEH(ii) = NaN;
            else
            end
        end
        
%         figure(10), clf, 
%         subplot(2,1,1)
%         plot(SWIFT(si).z),
%         subplot(2,1,2)
%         plot(SIWEH,'r')
        
        GF(si) = nanstd(SIWEH) ./ nanmean(SIWEH);
        
    else,
        GF(si) = NaN;
    end
    
    % nonlinear metrics
    k(si) = kurtosis(SWIFT(si).z);
    s(si) = skewness(SWIFT(si).z);
    
end

% clf
% subplot(4,1,1),
% plot([SWIFT.time],nu,'m.','markersize',10), hold on
% datetick,
% ylabel('\nu')
% subplot(4,1,2),
% plot([SWIFT.time],GF,'m.','markersize',10), hold on
% datetick,
% ylabel('GF')
% subplot(4,1,3),
% plot([SWIFT.time],k,'m.','markersize',10), hold on
% datetick,
% ylabel('kurtosis')
% subplot(4,1,3),
% plot([SWIFT.time],s,'m.','markersize',10), hold on
% datetick,
% ylabel('skewness')