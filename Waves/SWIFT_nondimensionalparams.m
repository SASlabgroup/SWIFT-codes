function [nondim, SWIFT] =SWIFT_nondimensionalparams(SWIFT,plotbool)
%%%%%%%%%%%%%%%%%SWIFT_nondimensionalparams.m
%
%   Calculates nondimensional fetch, energy, frequency, and waveheight and
%   puts each into an table. Will also filter for wave age < 1 based off of
%   pkfrequency. "plotbool" signifies the action to either plot or not plot
%   the results in a comparision. Uses "Coastlinelatlon.mat" as alaskan
%   coastline database and SWIFT_makeU10.m
%
%   Created: M. James, December 2024

% Load in coastline database from GSHHG (Alaska coast available from M. James)
load("Coastlinelatlon.mat");

if nargin < 2
    plotbool = 0;
    warning("No plot flag, setting plotting to off");
end

% SWIFTfetch calculation
tic;sprintf("Calculating Fetch, time elapsed %ds",round(toc))
if ~isfield(SWIFT,'winddirT')
    warning('No true winds, using relative winds');
    winddir = [SWIFT.peakwavedirT]; % use wave dir

    %% Calculation of true winds from wdirR and driftdirT, code in progress...
    % for k = 1:length(SWIFT);
    %     SWIFT(k).winddirT = atan2d(SWIFT(k).windspd.*cosd(SWIFT(k).winddirR) ... % north wind
    %          % + SWIFT(k).driftspd.*cosd(SWIFT(k).driftdirT)... % north drift
    %         % , SWIFT(k).driftspd.*sind(SWIFT(k).driftdirT) +... %east drift
    %         SWIFT(k).windspd.*sind(SWIFT(k).winddirR)); %east wind
    %     SWIFT(k).winddirT = mod(-SWIFT(k).winddirT+360, 360);
    % end
    %%
else 
    winddir = [SWIFT.winddirT];
end

% Fit fetchbins to data (ASSUMING Stationary comapared to fetch distance
% ds << fetch)

idx = find(abs([SWIFT.lat] -nanmean([SWIFT.lat]))+ abs([SWIFT.lon] -nanmean([SWIFT.lon]))...
    == min(abs([SWIFT.lat] -nanmean([SWIFT.lat]))+ abs([SWIFT.lon] -nanmean([SWIFT.lon]))));% find point closest to center
[fetchbins,degbincenter]=SWIFT_makefetchbins(SWIFT(idx).lat,SWIFT(idx).lon, coastlinelatlon)

clear idx
for k = 1:length(SWIFT)
    [~, idx] = min(abs(winddir(k) - degbincenter));
    SWIFT(k).fetch = fetchbins(idx);
    clear idx;
end


% U10 calculation 
tic;sprintf("Running U10 calculation, time elapsed %ds",round(toc))
if ~isfield(SWIFT, 'windspd10')
    SWIFT = SWIFT_makeU10(SWIFT);
end



% Calculation of nondim params
disp('Calculating nondimensional params')
g = 9.81;
nondim.pkf = (1./[SWIFT.peakwaveperiod]').*[SWIFT.windspd10]' ./ g;
nondim.fetch = g.*[SWIFT.fetch]' ./ ([SWIFT.windspd10]').^2;
nondim.energy = g.^2.*[SWIFT.sigwaveheight]' ./ (16*([SWIFT.windspd10]').^4);
nondim.sigH = g.^2.*[SWIFT.sigwaveheight]' ./ (([SWIFT.windspd10]').^2);

nondim = struct2table(nondim);

name = 'SWIFT20-waveagefiltered';

if plotbool
    disp('Plot flag true... plotting results')
    % Limits
    epmax = 3.6e-3;
    vmin = 0.13;
    sigHmax = 0.15;


    figure
    histogram(nondim.pkf,30)
    hold on
    xline(1/(2*pi),'k','LineWidth',2)
    xline(vmin,'k--','LineWidth',2)
    legend('','Wave Age Minimum for Non Swell','Fully Developed Minimum')
    title('Histogram of Nondimensional Peak Frequency')

    
    disp('Plotting filtered by wave age for pure wind seas')
    nondim = nondim(nondim.pkf > 1/(2*pi),:); % Filter out by wave age
    figure

    % Fetch vs Energy
    subplot 221
    scatter(nondim.fetch, nondim.energy,10,'filled','DisplayName','Binned Data');

    % Caculate regression
    [p, S] = polyfit(log10(nondim.fetch),log10(nondim.energy),1);
    regressslope = sprintf('Regression fit e%.2f', p(1));

    hold on
    plot(nondim.fetch, 10.^p(2)*nondim.fetch.^2,'m','DisplayName','Spurious Slope')
    plot(nondim.fetch, 10.^polyval(p, log10(nondim.fetch)),'r','DisplayName',regressslope)
    yline(epmax,'k--','DisplayName','Fully Developed max')
    set(gca, 'XScale','log');set(gca, 'YScale','log');
    legend()
    xlabel(' \chi')
    ylabel(' \epsilon ')


    % Fetch vs pk frequency
    subplot 222
    scatter(nondim.fetch, nondim.pkf,10,'filled','DisplayName','Binned Data');

     % Caculate regression
    [p, S] = polyfit(log10(nondim.fetch),log10(nondim.pkf),1);
    regressslope = sprintf('Regression fit e%.2f', p(1));

    hold on
    plot(nondim.fetch, 10.^p(2)*nondim.fetch.^(-1/2),'m','DisplayName','Spurious Slope')
    plot(nondim.fetch, 10.^polyval(p, log10(nondim.fetch)),'r','DisplayName',regressslope)
    yline(vmin,'k:','DisplayName','Fully Developed min')
    set(gca, 'XScale','log');set(gca, 'YScale','log');
    legend()
    xlabel(' \chi')
    ylabel(' v')

    % Fetch vs SigH
    subplot 223
    scatter(nondim.fetch, nondim.sigH,10,'filled','DisplayName','Binned Data');
    
    % Caculate regression
    [p, S] = polyfit(log10(nondim.fetch),log10(nondim.sigH),1);
    regressslope = sprintf('Regression fit e%.2f', p(1));

    hold on
    plot(nondim.fetch, 10.^p(2)*nondim.fetch,'m','DisplayName','Spurious Slope')
    plot(nondim.fetch, 10.^polyval(p, log10(nondim.fetch)),'r','DisplayName',regressslope)
    yline(sigHmax,'k--','DisplayName','Fully Developed max')
    set(gca, 'XScale','log');set(gca, 'YScale','log');
    legend()
    xlabel(' \chi')
    ylabel('$\hat{H}$', 'Interpreter', 'latex')

    % Frequency vs Energy
    subplot 224
    scatter(nondim.pkf, nondim.energy,10,'filled','DisplayName','Binned Data');
    
    % Caculate regression
    [p, S] = polyfit(log10(nondim.pkf),log10(nondim.energy),1);
    regressslope = sprintf('Regression fit e%.2f', p(1));

    hold on
    plot(nondim.pkf, 10.^p(2)*nondim.pkf.^(-4),'m','DisplayName','Spurious Slope')
    plot(nondim.pkf, 10.^polyval(p, log10(nondim.pkf)),'r','DisplayName',regressslope)
    xline(vmin,'k:','DisplayName','Fully Developed min')
    yline(epmax,'k--','DisplayName','Fully Developed max' )
    set(gca, 'XScale','log');set(gca, 'YScale','log');
    legend()
    xlabel(' v')
    ylabel(' \epsilon')

    sgtitle(['Nondimensional Relationships of ',name])

    savefig(fullfile(cd, ['nondimplots',name]));
    print('-djpeg', fullfile(cd, ['nondimplots',name]));
end

save(fullfile(cd, ['nondimparams_',name]),'nondim')

end