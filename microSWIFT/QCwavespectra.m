% matlab script to QC microSWIFT and SWIFT wave spectra
% addressing low-frequency bias in telemetry spectra when waves are small
%
% J. Thomson, Jul 2026

clear all, close all

flist = dir('*SWIFT*.mat');

fcutoff = 0.04;  % cutoff low freq with fixed value (suggest 0.05)
fcutoff_femultiple = 0.1;  % cutoff of low freq with a factor of fe

checkcutoff_low = 0.1; 
checkcutoff_high = 5;

spreadcutoff = 1;  % directional spread, in radians

for fi = 15 %:length(flist) % test with fi = 1, 10

    load(flist(fi).name)

    for si = 1:length(SWIFT)
        
        % initialize
        f = SWIFT(1).wavespectra.freq;
        Eoriginal(si,:) = SWIFT(si).wavespectra.energy;
        Tporiginal(si) = SWIFT(si).peakwaveperiod;
        check(si,:) = SWIFT(si).wavespectra.check;
        Enew(si,:) = Eoriginal(si,:);

        % fixed freq cutoff
        Enew(si,f<fcutoff) = NaN;

        % calc energy period
        fe(si) = nansum(Enew(si,:) .* f')...
            ./nansum(Enew(si,:));
        Te(si) = 1./fe(si);
        SWIFT(si).centroidwaveperiod = Te(si);

        % fe multiple cutoff
        Enew(si,f<fe(si)*fcutoff_femultiple) = NaN;

        % check factor cutoffs 
        %Enew(si, check(si,:) < checkcutoff_low) = NaN;
        %Enew(si, check(si,:) > checkcutoff_high) = NaN;

        % find peaks
        % [pks,locs] = findpeaks(Enew(si,:));

        % conver to vertical with check factor
        %Enew(si,:) = Enew(si,:) .* check(si,:);

        % directional spread
        %dir1 = atan2(b1,a1) ;  % [rad], 4 quadrant
        %dir2 = atan2(b2,a2)/2 ; % [rad], only 2 quadrant
        spread1(si,:) = sqrt( 2 * ( 1 - sqrt(SWIFT(si).wavespectra.a1.^2 + SWIFT(si).wavespectra.b1.^2) ) );
        %spread2 = sqrt( abs( 0.5 - 0.5 .* ( a2.*cos(2.*dir2) + b2.*cos(2.*dir2) )  ));
        Enew(si,spread1(si,:) > spreadcutoff) = NaN;

        % recalc Hs ** THE NANS WILL BIAS THIS LOW... NEED TO FILL SOMEHOW **
        Hsnew(si) = 4.*sqrt(nansum(Enew(si,:) * (f(2)-f(1))));

        % recacl peak period
        [Emax maxi] = max(Enew(si,:));
        firstnonnan = find(~isnan(Enew(si,:)),1);
        if maxi>firstnonnan
            SWIFT(si).peakwaveperiod = 1./f(maxi);
        else
            SWIFT(si).peakwaveperiod = NaN;
        end


    end

    figure(1), clf
    n=5;
    subplot(n,1,1)
    plot([SWIFT.time],[SWIFT.sigwaveheight],[SWIFT.time],Hsnew), 
    legend('old','new')
    datetick, ylabel('H_s (m)')
    title(flist(fi).name,'interp','none')
    subplot(n,1,2)
    plot([SWIFT.time],Tporiginal,'-',[SWIFT.time],[SWIFT.peakwaveperiod],'o',[SWIFT.time],[SWIFT.centroidwaveperiod],'x'), 
    datetick, legend('T_p old','T_p (new)','T_e')
    datetick, ylabel('T (s)')
    subplot(n,1,3)
    pcolor([SWIFT.time],f,log10(Eoriginal')), shading flat
    datetick,    ylabel('f (Hz)')
    legend('E_{old}')
    subplot(n,1,4)
    pcolor([SWIFT.time],f,log10(Enew')), shading flat
    datetick,    ylabel('f (Hz)')
    legend('E_{new}')
    ch = subplot(n,1,5);
    %pcolor([SWIFT.time],f,check'); shading flat, colormap(ch,'hot'), clim([0 2]),legend('ch')
    pcolor([SWIFT.time],f,spread1'); shading flat, colormap(ch,'hot'), clim([0 2]),legend('spread1')
    datetick, ylabel('f (Hz)')
end