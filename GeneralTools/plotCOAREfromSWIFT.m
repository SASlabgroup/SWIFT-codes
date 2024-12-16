function [] = plotCOAREfromSWIFT(SWIFT, fluxes)
%plotCOAREfromSWIFT Runs through full panel plot of SWIFT variables and
%COARE outputs from fluxes table. 
%   plotCOAREfromSWIFT(SWIFT, fluxes)
%   SWIFT - Common SWIFT structure 
%   fluxes - given from runCOARE3_6onSWIFT.m or newer; MUST be a table with
%   same OUTPUT names as COARE.
%   
%   Tskin - will add in observed Tskin if included as part of the SWIFT
%   structure

Tskinflag = false; 
if isfield(SWIFT,'Tskin') && any(~isnan([SWIFT.Tskin])),
    Tskinflag = true;
end;

%% General COARE outputs

figure, clf
subplot(3,1,1);
plot([SWIFT.time],[SWIFT.airtemp],'kx',[SWIFT.time],[SWIFT.watertemp],'md');
legend('air temp','water temp')
if Tskinflag ==true
    hold on
    plot([SWIFT.time],[SWIFT.Tskin], 'c.')
    legend('air temp','water temp','skin temp')
    hold off
end
ylabel('[C]')
datetick
if isfield(SWIFT,'ID'), title(SWIFT(1).ID), else, end

subplot(3,1,2);
plot([SWIFT.time],fluxes.hsb,'bx',[SWIFT.time],fluxes.hlb,'r+',[SWIFT.time],fluxes.hbb,'g.',[SWIFT.time],fluxes.hsbb,'c.');
legend('Q_{sen}','Q_{latent}','Q_{buoy}','Q_{sbuoy}')
if isfield(SWIFT,'Qsen'), 
    hold on
    plot([SWIFT.time],[SWIFT.Qsen],'kd')
    legend('Q_{sen}','Q_{latent}','Q_{buoy}','Q_{sbuoy}','Q_{wT}')
    yline(0,'k:')
end
hold on
datetick
ylabel('[W/m^2]')

subplot(3,1,3);
plot([SWIFT.time],[SWIFT.windspd],'kx',[SWIFT.time],fluxes.U10,'b+');
datetick
legend('measured wind','U_{10}')
ylabel('[m/s]')
linkaxes(findobj(gcf,'Type', 'Axes'),'x')
if isfield(SWIFT,'ID'),
    print('-dpng',[SWIFT(1).ID '_COAREfluxes.png'])
else
    print('-dpng',['COAREfluxes.png'])
end


figure, clf
ax(1) = subplot(3,1,1);
yyaxis left
plot([SWIFT.time],[SWIFT.SWrad],'x');ylabel('SW down [W/m^2]')
yyaxis right
plot([SWIFT.time],[SWIFT.LWrad],'rx');ylabel('LW down [W/m^2]')
datetick
if isfield(SWIFT,'ID'), title(SWIFT(1).ID), else, end
ax(2) = subplot(3,1,2);
yyaxis left
plot([SWIFT.time],fluxes.sw_up,'x'); ylabel('SW up [W/m^2]')
yyaxis right
plot([SWIFT.time],fluxes.lw_up,'rx');ylabel('LW up [W/m^2]')
datetick
ax(3) = subplot(3,1,3);
plot([SWIFT.time],fluxes.netrad,'go',[SWIFT.time],fluxes.Qnet,'ks'); hold on
yline(0, 'k:')
legend('Net rad','Net all')
datetick
ylabel('[W/m^2]')
linkaxes(ax,'x')
if isfield(SWIFT,'ID'),
    print('-dpng',[SWIFT(1).ID '_radfluxes.png'])
else
    print('-dpng',['radfluxes.png'])
end

if isfield(SWIFT,'windustar') && length(fluxes.usr) == length([SWIFT.windustar]),
    figure, clf
    plot([SWIFT.windspd],fluxes.usr,'kx',[SWIFT.windspd],[SWIFT.windustar],'ro'), 
    legend('COARE','inertial')
    if isfield(SWIFT,'windustar_directcovar') && length(fluxes.usr) == length([SWIFT.windustar_directcovar]),
        hold on
        plot([SWIFT.windspd],[SWIFT.windustar_directcovar],'b.')
        legend('COARE','inertial','direct covar')
    else
    end

    axis square, grid
    axis([ 0 15 0 1])
    xlabel('Measured wind spd [m/s]')
    ylabel('u_* [m/s]')
    if isfield(SWIFT,'ID'), title(SWIFT(1).ID), else, end

    if isfield(SWIFT,'ID'),
        print('-dpng',[SWIFT(1).ID '_ustar.png'])
    else
        print('-dpng',['ustar.png'])
    end
    
    
    figure, clf
    xline(0,'k--','HandleVisibility','off')
    hold on;
    Qidx = [0.01: 0.01:1];
    inertialusr_pctdiff = (fluxes.usr - [SWIFT.windustar]') ./ [SWIFT.windustar]' .*100;
    Qinert = quantile(inertialusr_pctdiff,Qidx);
    plot(Qinert,Qidx,'r-'), 
    legend('COARE - inertial')
    if isfield(SWIFT,'windustar_directcovar') && length(fluxes.usr) == length([SWIFT.windustar_directcovar]),
        hold on
        directcovarusr_pctdiff = (fluxes.usr - [SWIFT.windustar_directcovar]') ./ [SWIFT.windustar_directcovar]' .*100; 
        Qcovar = quantile(directcovarusr_pctdiff,Qidx);
       plot(Qinert,Qidx,'b-')
        legend('COARE - inertial','direct covar - inertial')
    else
    end

    axis square, grid on
    xlabel('% diff COARE - observed / observed')
    ylabel('Probability of Value <= Given Value')
    if isfield(SWIFT,'ID'), title(sprintf('COARE Comparision of U_* SWIFT %s',SWIFT(1).ID)), else, end

    if isfield(SWIFT,'ID'),
        print('-dpng',[SWIFT(1).ID '_ustarCDF.png'])
    else
        print('-dpng',['ustarCDF.png'])
    end
else
end
    


if isfield(SWIFT,'windustar') && length(fluxes.tau) == length([SWIFT.time]),
    figure, clf
    inertialtau = fluxes.rhoa.*[SWIFT.windustar]'.^2;
    plot([SWIFT.time],fluxes.tau,'kx',[SWIFT.time],inertialtau,'ro'); datetick;
    legend('COARE','inertial')
    if isfield(SWIFT,'windustar_directcovar') && length(fluxes.usr) == length([SWIFT.windustar_directcovar]),
        hold on
        directcovartau = fluxes.rhoa.*[SWIFT.windustar_directcovar]'.^2;
        plot([SWIFT.time],[SWIFT.windustar_directcovar],'b.')
        legend('COARE','inertial','direct covar')
    else
    end

    grid minor;
    xlabel('[UTC]')
    ylabel('\tau [N/m^2]')

    if isfield(SWIFT,'ID'), title(SWIFT(1).ID), else, end

    if isfield(SWIFT,'ID'),
        print('-dpng',[SWIFT(1).ID '_tau.png'])
    else
        print('-dpng',['_tau.png'])
    end

else
end

if length(fluxes.tau) == length([SWIFT.time]),
    figure('Position', [488.0000  101.0000  688.2000  648.8000]), clf
    subplot 311
        plot([SWIFT.time],fluxes.tau,'kx')
        legend('COARE','Location','west')
        if isfield(SWIFT,'windustar') && length(fluxes.tau) == length([SWIFT.time])
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
        if isfield(SWIFT,'ID'), title(sprintf('COARE Prediction Summary SWIFT %s',SWIFT(1).ID)), else, end
        % reset xlim back a day
        xlim = get(gca,'XLim');
        set(gca,'XLim',[xlim(1)-1 xlim(2)])

    subplot 312
        plot([SWIFT.time],fluxes.hsb,'bx',[SWIFT.time],fluxes.hlb,'r+',[SWIFT.time],fluxes.hbb,'g.',[SWIFT.time],fluxes.hsbb,'c.');
        legend('Q_{sen}','Q_{latent}','Q_{buoy}','Q_{sbuoy}','Location','west')
        if isfield(SWIFT,'Qsen'), 
            hold on
            plot([SWIFT.time],[SWIFT.Qsen],'kd')
            legend('Q_{sen}','Q_{latent}','Q_{buoy}','Q_{sbuoy}','Q_{wT}','Location','west')
            yline(0,'k:')
        end
        hold on
        datetick
        grid minor
        ylabel('[W/m^2]')
        % reset xlim back a day
        xlim = get(gca,'XLim');
        set(gca,'XLim',[xlim(1)-1 xlim(2)])
   
    subplot 313
        yline(0, 'k--'); hold on;
        if Tskinflag == true;
            plot([SWIFT.time], [SWIFT.watertemp] - [SWIFT.Tskin],'kx',...
            [SWIFT.time], fluxes.dT_skin,'m*')
            legend('','Observed','COARE', 'Location','west')
        else
            plot([SWIFT.time], fluxes.dT_skin,'m*')
            legend('','COARE', 'Location','west')
        end
        
        ylabel(['T_s' char(176), 'C'])
        datetick
        grid minor
        % reset xlim back a day
        xlim = get(gca,'XLim');
        set(gca,'XLim',[xlim(1)-1 xlim(2)])
    
    linkaxes(findobj(gcf,'Type','Axes'),'x')


    if isfield(SWIFT,'ID'),
        print('-dpng',[SWIFT(1).ID '_COAREpredictionsummary.png'])
    else
        print('-dpng',['_COAREpredictionsummary.png'])
    end

end



end