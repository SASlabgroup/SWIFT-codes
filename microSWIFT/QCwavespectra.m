% matlab script to QC microSWIFT and SWIFT wave spectra
% addressing low-frequency bias in telemetry spectra when waves are small
%
% J. Thomson, Jul 2026

% need to try a gradient-based filter... no positive gradient for f < fe 

clear all, close all

flist = dir('*SWIFT*.mat');

fcutoff = 0.04;  % cutoff low freq with fixed value (suggest 0.05)
fcutoff_femultiple = 0.1;  % cutoff of low freq with a factor of fe

checkcutoff_low = 0.1; 
checkcutoff_high = 5;

spreadcutoff = 1;  % directional spread, in radians

standardf = linspace(0.0098,0.4902,42);
noisefloor = 1e-5.*standardf.^-2; % static noise floor

for fi = 10 %:length(flist) % test with fi = 1 (small waves), 10 (clean swell), 15 (challenge case)

    load(flist(fi).name)

    for si = 1:length(SWIFT)
        
        % initialize
        f = SWIFT(1).wavespectra.freq;
        Eoriginal(si,:) = SWIFT(si).wavespectra.energy;
        Tporiginal(si) = SWIFT(si).peakwaveperiod;
        check(si,:) = SWIFT(si).wavespectra.check;
        Enew(si,:) = Eoriginal(si,:);

        %% make corrections 

        % fixed freq cutoff
        Enew(si,f<fcutoff) = NaN;

        % noise floor cutoff
        toolow = Enew(si,:) < noisefloor;
        Enew(si, toolow ) = NaN;

        % calc energy period
        fe(si) = nansum(Enew(si,:) .* f')...
            ./nansum(Enew(si,:));
        Te(si) = 1./fe(si);
        SWIFT(si).centroidwaveperiod = Te(si);

        % fe multiple cutoff
        %Enew(si,f<fe(si)*fcutoff_femultiple) = NaN;

        % check factor cutoffs 
        %Enew(si, check(si,:) < checkcutoff_low) = NaN;
        %Enew(si, check(si,:) > checkcutoff_high) = NaN;

        % find peaks
        % [pks,locs] = findpeaks(Enew(si,:));

        % conver to vertical with check factor
        %Enew(si,:) = Enew(si,:) .* check(si,:);

        % directional spread cutoff
        spread1(si,:) = sqrt( 2 * ( 1 - sqrt(SWIFT(si).wavespectra.a1.^2 + SWIFT(si).wavespectra.b1.^2) ) );
        spread1(si,:) = real( spread1(si,:) );
        Enew(si,spread1(si,:) > spreadcutoff) = NaN;
        %Enew(si,spread1(si,:) > spreadcutoff & f'<fe(si)*fcutoff_femultiple ) = NaN;

        %% recalc bulk parameters

        % backfill the NaNs and recalc Hs 
        % (essential to fill the NaNs, since they would bias-low the integral energy
        % good = ~isnan(Enew(si,:));
        % if sum(good)>2
        %     Enew(si,:) = interp1(f(good), Enew(si,good), f, 'linear','extrap');
        % end
        Enew(si, isnan(Enew(si,:)) ) = noisefloor( isnan(Enew(si,:)) );
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