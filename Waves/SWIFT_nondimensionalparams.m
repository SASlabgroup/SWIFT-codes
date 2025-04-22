function [nondim, SWIFT] =SWIFT_nondimensionalparams(SWIFT,plotbool,name)
%%%%%%%%%%%%%%%%%SWIFT_nondimensionalparams.m
%
%   Calculates nondimensional fetch, energy, frequency, and waveheight and
%   puts each into an table. Will also filter for wave age < 1 based off of
%   pkfrequency. "plotbool" signifies the action to either plot or not plot
%   the results in a comparision. Uses "Coastlinelatlon.mat" as alaskan
%   coastline database and SWIFT_makeU10.m
%
%   Created: M. James, December 2024
if nargin <3 % default name
 name = 'SWIFT';
end
if ~isfield(SWIFT, 'fetch')
    % Load in coastline database from GSHHG (Alaska coast available from M. James)
    load("Coastlinelatlon.mat");
    
    if nargin < 2
        plotbool = 0;
        warning("No plot flag, setting plotting to off");
    end
    
    % SWIFTfetch calculation
    tic;sprintf("Calculating Fetch, time elapsed %ds",round(toc))
    if ~isfield(SWIFT,'winddirT')
        warning('No true winds, using wave dir');
        winddir = mod([SWIFT.peakwavedirT]+180, 360); % use wave dir
        % winddir = [SWIFT.peakwavedirT];
    
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
    
    % % Works for stationary
    % idx = find(abs([SWIFT.lat] -nanmean([SWIFT.lat]))+ abs([SWIFT.lon] -nanmean([SWIFT.lon]))...
    %     == min(abs([SWIFT.lat] -nanmean([SWIFT.lat]))+ abs([SWIFT.lon] -nanmean([SWIFT.lon]))));% find point closest to center
    % [fetchbins,degbincenter]=SWIFT_makefetchbins(SWIFT(idx).lat,SWIFT(idx).lon, coastlinelatlon)
    % 
    % clear idx
    % for k = 1:length(SWIFT)
    %     [~, idx] = min(abs(winddir(k) - degbincenter));
    %     SWIFT(k).fetch = fetchbins(idx);
    %     clear idx;
    % end
    
    % Adapted to moving buoys
    % Bin everything to 9 deg bins
    bincenters = [0,4.5:360]';
    [~, idx] = min(abs(winddir - bincenters),[],1);
    winddir = bincenters(idx);
    
    clear idx
    for k = 1:length(SWIFT)
        %Define radius of fetch calc
        r = 1000; %km
        r = km2deg(r);
        
        % Set up wind vector
        windvx = [SWIFT(k).lon, SWIFT(k).lon + sind(winddir(k)).*r]; % x ccw from north
        windvy = [SWIFT(k).lat, SWIFT(k).lat + cosd(winddir(k)).*r]; % y ccw from north
       
        % 1 --> 2 first line, 3 --> 4 second line
        % Find intersection points
        [xi, yi] = polyxpoly(windvx, windvy, ...
            coastlinelatlon.lon, coastlinelatlon.lat);
    
        % Check if there is an intersection
        isIntersect = ~isempty(xi);
    
        if isIntersect
            distance = sqrt((xi-SWIFT(k).lon).^2 + (yi-SWIFT(k).lat).^2);
            SWIFT(k).fetch = deg2km(min(distance)); % kmclear
        else
            SWIFT(k).fetch =NaN;
        end
        clear idx xi yi isIntersect distance
    end
end

% U10 calculation 
tic;sprintf("Running U10 calculation, time elapsed %ds",round(toc))
if ~isfield(SWIFT, 'windspd10')
    SWIFT = SWIFT_makeU10(SWIFT);
end



% Calculation of nondim params
disp('Calculating nondimensional params')
g = 9.81;
nondim.time = [SWIFT.time]';
nondim.ID = string({SWIFT.ID})'
nondim.winddirT = [SWIFT.winddirT]';
nondim.pkf = (1./[SWIFT.peakwaveperiod]').*[SWIFT.windspd10]' ./ g;
nondim.fetch = g.*[SWIFT.fetch]' ./ ([SWIFT.windspd10]').^2;
nondim.energy = g.^2.*[SWIFT.sigwaveheight]' ./ (16*([SWIFT.windspd10]').^4);
nondim.sigH = g.^2.*[SWIFT.sigwaveheight]' ./ (([SWIFT.windspd10]').^2);

nondim = struct2table(nondim);

if plotbool
    disp('Plot flag true... plotting results')
    % Limits
    epmax = 3.6e-3; % from young 1999
    vmin = 0.13;
    sigHmax = 0.15;


    figure
    histogram(nondim.pkf,30)
        
    disp('Plotting filtered by wave age for pure wind seas')
    nondim = nondim(nondim.pkf > 1/(2*pi),:); % Filter out by wave age

    hold on
    histogram(nondim.pkf,30)

    xline(1/(2*pi),'k','LineWidth',2)
    xline(vmin,'k--','LineWidth',2)
    legend('','waveagefilter','Wave Age Minimum for Non Swell','Fully Developed Minimum')
    title('Histogram of Nondimensional Peak Frequency')

    figure('Position', [100 100 1000 600]);

    % Fetch vs Energy
    subplot 221
    scatter(nondim.fetch, nondim.energy,10,'filled','DisplayName','Binned Data');

    % Caculate regression
    valididx = isfinite(log10(nondim.fetch)) & isfinite(log10(nondim.energy)); % find idx without NaN

    [p, S] = polyfit(log10(nondim.fetch(valididx)),log10(nondim.energy(valididx)),1);
    regressslope = sprintf('Regression fit e%.2f', p(1));

    hold on
    plot(nondim.fetch, 10.^p(2)*nondim.fetch.^2,'m','DisplayName','Spurious Slope')
    plot(nondim.fetch, 10.^polyval(p, log10(nondim.fetch)),'r','DisplayName',regressslope)
    yline(epmax,'k--','DisplayName','Fully Developed max')
    set(gca, 'XScale','log');set(gca, 'YScale','log');
    legend('Location','northwest')
    xlabel(' \chi')
    ylabel(' \epsilon ')


    % Fetch vs pk frequency
    subplot 222
    scatter(nondim.fetch, nondim.pkf,10,'filled','DisplayName','Binned Data');

     % Caculate regression
    valididx = isfinite(log10(nondim.fetch)) & isfinite(log10(nondim.pkf)); % find idx without NaN

    [p, S] = polyfit(log10(nondim.fetch(valididx)),log10(nondim.pkf(valididx)),1);
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
    valididx = isfinite(log10(nondim.fetch)) & isfinite(log10(nondim.sigH)); % find idx without NaN

    [p, S] = polyfit(log10(nondim.fetch(valididx)),log10(nondim.sigH(valididx)),1);
    regressslope = sprintf('Regression fit e%.2f', p(1));

    hold on
    plot(nondim.fetch, 10.^p(2)*nondim.fetch,'m','DisplayName','Spurious Slope')
    plot(nondim.fetch, 10.^polyval(p, log10(nondim.fetch)),'r','DisplayName',regressslope)
    yline(sigHmax,'k--','DisplayName','Fully Developed max')
    set(gca, 'XScale','log');set(gca, 'YScale','log');
    legend('Location','northwest')
    xlabel(' \chi')
    ylabel('$\hat{H}$', 'Interpreter', 'latex')

    % Frequency vs Energy
    subplot 224
    scatter(nondim.pkf, nondim.energy,10,'filled','DisplayName','Binned Data');
    
    % Caculate regression
    valididx = isfinite(log10(nondim.energy)) & isfinite(log10(nondim.pkf)); % find idx without NaN
    
    [p, S] = polyfit(log10(nondim.pkf(valididx)),log10(nondim.energy(valididx)),1);
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