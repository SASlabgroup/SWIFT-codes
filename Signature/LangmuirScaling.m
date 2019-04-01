% Explore Langmuir scaling with SWIFT v4 data
% looking for downwelling in wbar (after Signature reprocessing)
% as a function of ustarwind and Stokes drift

clear all

%pwd

flist = dir('SWIFT*.mat');

counter = 0;

%% loop through and find all valid wind products first, accumulate array
for fi = 1:length(flist),
    
    load(flist(fi).name)
    
    g = 9.8;
    k = 4*pi^2./(g*[SWIFT.peakwaveperiod].^2); % deep water
    %k = wavenumber( 1./[SWIFT.peakwaveperiod], depth ); % intermediate
    om = 2*pi./[SWIFT.peakwaveperiod];
    uStokes0(counter + [1:length(SWIFT)])=[SWIFT.sigwaveheight].^2/(16) .* om .* k; % Surface value
    % uStokes = sigwaveheight.^2/(16)*om*k*exp(-2*k*z); % sub surface values
    
    
    for si=1:length(SWIFT),
        if isfield(SWIFT(si), 'signature') && isfield(SWIFT(si).signature,'profile') && isfield(SWIFT(si).signature.profile,'wbar')
            
            downwelling(counter + si) = nanmean( SWIFT(si).signature.profile.wbar(1:15) );
            %wind(counter + si) = SWIFT(si).windspd;
            wind(counter + si) = SWIFT(si).windustar;
    
        else
            downwelling(counter + si) = NaN;
            wind(counter + si) = NaN;
        end
    end
    
    counter = length(downwelling);
    
end

%% screen

La = uStokes0 ./ wind;
%downwelling( abs( downwelling ) > 0.1 ) = NaN;


%% plot and bin average

    figure(1), clf
    plot( La , downwelling ,  'kx')
    %binscatter( La, downwelling )
    hold on
    axis([0 0.15 -.05 .01])
    plot([0 0.14],[0 0],'k:')
    xlabel('La^{-2} = U_s / u_*')
    ylabel('w [m/s]')
    
    dLa = 0.02;
    Labins = [0.01:dLa:0.14]
    clear dmean
    
    for li=1:length(Labins),
        dmean(li) = nanmean( downwelling( find( abs( Labins(li) - (La) ) < (dLa./2) ) ) );
    end
    
    plot(Labins, dmean, 'ko','linewidth',5,'markersize',16)
    
