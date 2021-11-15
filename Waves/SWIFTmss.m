function [mss, mssnorm, SWIFT] = SWIFTmss( SWIFT, plotflag )
% function to calculate mean square slope from the wave spectra in a SWIFT data structure
% outputs are mss, and mss normalize by the width of the frequency range 
%
%   [mss, mssnorm] = SWIFTmss( SWIFT );
%
% J. Thomson, Sept 2020
%               Nov 2021, use dynamic frequency range (1.0 f_e to 2.0 f_e)
%                       also expand results to include theoretical mss and put results in SWIFT structure
%                   and add a plotting option

%fmin = 0.3; % fixed options (legacy)
%fmax = 0.45; % max freq (legacy)

if isfield(SWIFT,'wavespectra'),
    for si = 1:length(SWIFT), 
        
        %% observed mss (as 4th moment of spectral tail)
        df = mean(diff( SWIFT(si).wavespectra.freq ));
        fe(si) = nansum(SWIFT(si).wavespectra.freq .* SWIFT(si).wavespectra.energy) ./ nansum(SWIFT(si).wavespectra.energy) ;
        findices = find( SWIFT(si).wavespectra.freq > fe(si) );
        mss(si) = nansum( (2*3.14*SWIFT(si).wavespectra.freq(findices)).^4 .* SWIFT(si).wavespectra.energy(findices) ) .* df ./ (9.8^2);
        mssnorm(si) = mss(si) ./ range( SWIFT(si).wavespectra.freq(findices) );
        
        %% adjust the mss observations for relative currents, see Iyer et al 2021/2022
        % ** some confusion over normalization and sign of adjustment
        if isfield(SWIFT,'driftspd')
            recip = 0; % wave direction towards, not from
            [Etheta theta E f dir spread spread2 spread2alt ] = SWIFTdirectionalspectra(SWIFT(si), 0, recip); 
            EqDir(si) = nansum(E(findices) .* dir(findices) ) ./ nansum(E(findices));
            relU(si) = SWIFT(si).driftspd * cosd( EqDir(si) - SWIFT(si).driftdirT )  % relative current (sign matters!)
            mssadjusted(si) = mss(si) - nansum( 8*3.14*SWIFT(si).wavespectra.freq(findices) * relU(si) ) .* df ./ (9.8) ... 
                -  nansum( 24*(3.14*SWIFT(si).wavespectra.freq(findices) * relU(si) ).^2 ) .* df ./ (9.8^2) ... 
                -  nansum( 32*(3.14*SWIFT(si).wavespectra.freq(findices) * relU(si) ).^3 ) .* df ./ (9.8^3) ... 
                -  nansum( 16*(3.14*SWIFT(si).wavespectra.freq(findices) * relU(si) ).^4 ) .* df ./ (9.8^4) ;
            %mssadjusted(si) = mssadjusted(si) ./ range( SWIFT(si).wavespectra.freq(findices) );
        else
            mssadjusted(si) = NaN;
        end
        
        %% expected mss based on Phillips (1985) wind-wave equilibrium, without currents 
        if isfield(SWIFT,'windspd')
            Ip = 2.5;
            beta = 0.012;
            Cd = 1.5e-3;
            ustar(si) = ( Cd * SWIFT(si).windspd.^2 ).^0.5;
            msstheoretical(si) = 8 * 3.14 * beta * Ip * range( SWIFT(si).wavespectra.freq(findices) ) * ustar(si) ./ 9.8;
            msstheoretical(si) = msstheoretical(si) ./ range( SWIFT(si).wavespectra.freq(findices) );
        else
            msstheoretical(si) = NaN;
        end
        
        %% put results in data structure
        SWIFT(si).centriodwaveperiod = 1./fe(si);
        SWIFT(si).mss = mss(si);
        SWIFT(si).mssnormalized = mssnorm(si);
        SWIFT(si).mssadjusted = mssadjusted(si);
        SWIFT(si).msstheoretical = msstheoretical(si);
        if mssadjusted(si) < 0, 
            SWIFT(si).mssadjusted = 0;
        end

    end
else
    mss = NaN(length(SWIFT));
    mssnorm = NaN(length(SWIFT));
end


if plotflag,
    %%
    figure(1), clf
    plot([SWIFT.time],[SWIFT.mss],':',[SWIFT.time],[SWIFT.mssnormalized],[SWIFT.time],[SWIFT.mssadjusted],[SWIFT.time], [SWIFT.msstheoretical],'linewidth',3)
    datetick
    ylabel('mss []')
    legend('observed mss','observed mss, normalized','adjusted mss','theoretical mss, normalized','Location','NortheastOutside')
    print('-dpng','SWIFTmss.png') 
    %%
end

end

