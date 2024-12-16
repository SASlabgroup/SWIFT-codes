function [outputArg1,outputArg2] = plotCOAREfromSWIFTtskin(SWIFT, fluxes)
% plotCOAREfromSWIFTtskin Makes a comparision plot of observed vs COARE tskin
% with % difference over time and wind speed comparision. 
%   Detailed explanation goes here

if length(fluxes.dT_skin) == length([SWIFT.time]) && isfield(SWIFT,'Tskin'),
    figure('Position', [488.0000  101.0000  688.2000  648.8000]), clf
    subplot 311
        dT_SWIFT = [SWIFT.watertemp]' - [SWIFT.Tskin]';
        yline(0, 'k--','HandleVisibility','off'); hold on;
        plot([SWIFT.time], dT_SWIFT,'kx',...
            [SWIFT.time], fluxes.dT_skin,'m*')
        legend('Observed','COARE', 'Location','west')
   
        grid minor
        datetick
        xlabel('[UTC]')
        ylabel(['T_s' char(176), 'C'])
        
        if isfield(SWIFT,'ID'), title(sprintf('COARE Comparision of Tskin SWIFT %s',SWIFT(1).ID)), else, end
        % reset xlim back a day
        xlim = get(gca,'XLim');
        set(gca,'XLim',[xlim(1)-1 xlim(2)])

    subplot 312
        yline(0, 'k--','HandleVisibility','off');
        Tskin_pctdiff = (fluxes.dT_skin - dT_SWIFT) ./ dT_SWIFT .*100;

        hold on; plot([SWIFT.time], Tskin_pctdiff,'b.');
        legend('COARE - Observed','Location','southwest')
        
        grid minor
        datetick
        xlabel('[UTC]')
        ylabel(['%diff T_s' char(176), 'C'])
        ylim([-1500 1500])
        % reset xlim back a day
        xlim = get(gca,'XLim');
        set(gca,'XLim',[xlim(1)-1 xlim(2)])
    linkaxes(findobj(gcf,'Type','Axes'),'x')
   
    subplot 313
        yline(0, 'k--','HandleVisibility','off');
        hold on; plot([SWIFT.windspd],Tskin_pctdiff,'b.');
        legend('COARE - observed','Location','southwest')

        grid minor
        xlabel('U_a_v_g [m/s]')
        ylabel(['%diff T_s' char(176), 'C'])
        ylim([-1500 1500])

    if isfield(SWIFT,'ID'),
        print('-dpng',[SWIFT(1).ID '_COARETskinsummary.png'])
    else
        print('-dpng',['_COARETskinsummary.png'])
    end

%% CDF of Tskin

    figure
    xline(0,'k--','HandleVisibility','off')
    hold on;
    Qidx = [0.01: 0.01:1];
    Qinert = quantile(Tskin_pctdiff,Qidx);
    plot(Qinert,Qidx,'r-'), 
    legend('COARE - inertial','Location','southeast')
    
    axis square, grid on
    xlabel(['% diff COARE - observed / observed',char(176), 'C'])
    ylabel('Probability of Value <= Given Value')
    if isfield(SWIFT,'ID'), title(sprintf('COARE Comparision of Tskin SWIFT %s',SWIFT(1).ID)), else, end

    if isfield(SWIFT,'ID'),
        print('-dpng',[SWIFT(1).ID '_TskinCDF.png'])
    else
        print('-dpng',['TskinCDF.png'])
    end

else
    error('Check Inputs for proper value formatting')
end
end