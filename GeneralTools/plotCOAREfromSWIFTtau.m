function [] = plotCOAREfromSWIFTtau( SWIFT, fluxes )
% plotCOAREfromSWIFTtau Makes a comparision plot of observed vs COARE tau
% with % difference over time and wind speed comparision. 
%   Detailed explanation goes here

% Calculate % difference param

if length(fluxes.tau) == length([SWIFT.time]),
    figure('Position', [488.0000  101.0000  688.2000  648.8000]), clf
    subplot 311
        plot([SWIFT.time],fluxes.tau,'kx')
        legend('COARE','Location','west')
        if isfield(SWIFT,'windustar') && length(fluxes.tau) == length([SWIFT.time])
            inertialtau = fluxes.rhoa.*[SWIFT.windustar]'.^2;
            hold on; plot([SWIFT.time],inertialtau,'ro');
            legend('COARE','inertial','Location','west')
        end
        if isfield(SWIFT,'windustar_directcovar') && length(fluxes.usr) == length([SWIFT.windustar_directcovar]),
            hold on
            directcovartau = fluxes.rhoa.*[SWIFT.windustar_directcovar]'.^2;
            plot([SWIFT.time],[SWIFT.windustar_directcovar],'b.')
            legend('COARE','inertial','direct covar','Location','west')
        else
        end
        grid minor
        datetick
        xlabel('[UTC]')
        ylabel('\tau [N/m^2]')
        if isfield(SWIFT,'ID'), title(sprintf('COARE Comparision of TAU SWIFT %s',SWIFT(1).ID)), else, end
        % reset xlim back a day
        xlim = get(gca,'XLim');
        set(gca,'XLim',[xlim(1)-1 xlim(2)])

    subplot 312
        yline(0, 'k--','HandleVisibility','off');
        if isfield(SWIFT,'windustar') && length(fluxes.tau) == length([SWIFT.time])
            inertialtau_pctdiff = (fluxes.tau - inertialtau) ./ inertialtau .*100;
            hold on; plot([SWIFT.time],inertialtau_pctdiff,'ro');
            legend('COARE - inertial','Location','southwest')
        end
        if isfield(SWIFT,'windustar_directcovar') && length(fluxes.usr) == length([SWIFT.windustar_directcovar]),
            hold on
            directcovartau_pctdiff = (fluxes.tau- directcovartau) ./ directcovartau .*100; 
            plot([SWIFT.time],directcovartau_pctdiff,'b.')
            legend('COARE - inertial','COARE - direct covar','Location','west')
        else
        end
        grid minor
        datetick
        xlabel('[UTC]')
        ylabel('% Difference \tau [N/m^2]')
        % reset xlim back a day
        xlim = get(gca,'XLim');
        set(gca,'XLim',[xlim(1)-1 xlim(2)])
    linkaxes(findobj(gcf,'Type','Axes'),'x')
   
    subplot 313
        yline(0, 'k--','HandleVisibility','off');
        if isfield(SWIFT,'windustar') && length(fluxes.tau) == length([SWIFT.time])
            hold on; plot([SWIFT.windspd],inertialtau_pctdiff,'ro');
            legend('COARE - inertial','Location','southwest')
        end
        if isfield(SWIFT,'windustar_directcovar') && length(fluxes.usr) == length([SWIFT.windustar_directcovar]),
            hold on
            plot([SWIFT.windspd],directcovartau_pctdiff,'b.')
            legend('COARE - inertial','COARE - direct covar','Location','southwest')
        else
        end
        grid minor
        xlabel('U_a_v_g [m/s]')
        ylabel('% Difference \tau [N/m^2]')
           
    


    if isfield(SWIFT,'ID'),
        print('-dpng',[SWIFT(1).ID '_COAREtausummary.png'])
    else
        print('-dpng',['_COAREtausummary.png'])
    end


else
    error('Check Inputs for proper value formatting')
end
%% CDF of Tau
if length(fluxes.tau) == length([SWIFT.time]),
    figure, clf
    xline(0,'k--','HandleVisibility','off')
    hold on;
    Qidx = [0.01: 0.01:1];
    Qinert = quantile(inertialtau_pctdiff,Qidx);
    plot(Qinert,Qidx,'r-'), 
    legend('COARE - inertial')
    if isfield(SWIFT,'windustar_directcovar') && length(fluxes.usr) == length([SWIFT.windustar_directcovar]),
        hold on
        Qcovar = quantile(directcovartau_pctdiff,Qidx);
       plot(Qinert,Qidx,'b-')
        legend('COARE - inertial','direct covar - inertial')
    else
    end

    axis square, grid on
    xlabel('% diff COARE - observed / observed')
    ylabel('Probability of Value <= Given Value')
    if isfield(SWIFT,'ID'), title(sprintf('COARE Comparision of TAU SWIFT %s',SWIFT(1).ID)), else, end

    if isfield(SWIFT,'ID'),
        print('-dpng',[SWIFT(1).ID '_tauCDF.png'])
    else
        print('-dpng',['tauCDF.png'])
    end
end
end