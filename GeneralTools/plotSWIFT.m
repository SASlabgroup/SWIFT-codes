function [] = plotSWIFT(SWIFT);
% Matlab function to plot the results in a SWIFT data structure
%   which must have multiple entries
% The resulting figures are named by the working directory
%   (and the parameters plotted)
%
% J. Thomson, 2014
%

if ~isempty(SWIFT) & length(SWIFT)>0,
    
    wd = pwd;
    wdi = find(wd == '/',1,'last');
    wd = wd((wdi+1):length(wd));
    
    
    %% wind and wave plot
    figure(1), clf, n = 4;
    
    ax(1) = subplot(n,1,1);
    plot( [SWIFT.time],[SWIFT.windspd],'bx','linewidth',2)
    set(gca,'Fontsize',16,'fontweight','demi')
    datetick
    ylabel([ 'windppd [m/s]'])
    set(gca,'Ylim',[0 20])
    
    ax(2) = subplot(n,1,2);
    plot( [SWIFT.time],[SWIFT.sigwaveheight],'g+','linewidth',2)
    set(gca,'Fontsize',16,'fontweight','demi')
    datetick
    ylabel([ 'waveheight [m]'])
    set(gca,'Ylim',[0 7])
    
    ax(3) = subplot(n,1,3);
    plot( [SWIFT.time],[SWIFT.peakwaveperiod],'g+','linewidth',2)
    set(gca,'Fontsize',16,'fontweight','demi')
    datetick
    ylabel([ 'waveperiod [s]'])
    set(gca,'Ylim',[0 20])
    
    ax(4) = subplot(n,1,4);
    plot([SWIFT.time],[SWIFT.winddirT],'bx','linewidth',2), hold on,
    plot([SWIFT.time],[SWIFT.peakwavedirT],'g+','linewidth',2), hold on
    set(gca,'Fontsize',16,'fontweight','demi')
    datetick
    ylabel('directions [^\circ T]')
    set(gca,'Ylim',[0 360])
    set(gca,'YTick',[0 180 360])
    
    linkaxes(ax,'x')
    set(gca,'XLim',[(min([SWIFT.time])-1/24) (max([SWIFT.time])+1/24)] )
    print('-dpng',[wd  '_windandwaves.png'])
    
    
    %% temperature and salinity plot
    figure(2), clf, n = 3;
    
    tax(1) = subplot(n,1,1);
    plot( [SWIFT.time],[SWIFT.airtemp],'g+','linewidth',2)
    set(gca,'Fontsize',16,'fontweight','demi')
    datetick
    ylabel(['airtemp [C]'])
    set(gca,'Ylim',[-15 30])
    grid
    
    tax(2) = subplot(n,1,2);
    if length([SWIFT.time])==length([SWIFT.watertemp]), % only one CT
        plot( [SWIFT.time],[SWIFT.watertemp],'g+','linewidth',2)
    elseif length([SWIFT.time])==length([SWIFT.watertemp])./2, % three CTs
        Tarray = reshape([SWIFT.watertemp],2,length([SWIFT.time]));
        plot( [SWIFT.time],Tarray(1,:),'g+','linewidth',2), hold on
        plot( [SWIFT.time],Tarray(2,:),'k.','linewidth',2), hold on
        legend('0.5 m','1.2 m')
    elseif length([SWIFT.time])==length([SWIFT.watertemp])./3, % three CTs
        Tarray = reshape([SWIFT.watertemp],3,length([SWIFT.time]));
        plot( [SWIFT.time],Tarray(1,:),'rx','linewidth',2), hold on
        plot( [SWIFT.time],Tarray(2,:),'g+','linewidth',2), hold on
        plot( [SWIFT.time],Tarray(3,:),'k.','linewidth',2), hold on
        legend('0.1 m','0.5 m','1.2 m')
    else
    end
    set(gca,'Fontsize',16,'fontweight','demi')
    datetick
    ylabel(['watertemp [C]'])
    set(gca,'Ylim',[-2 30])
    
    tax(3) = subplot(n,1,3);
    if length([SWIFT.time])==length([SWIFT.salinity]), % only one CT
        plot( [SWIFT.time],[SWIFT.salinity],'g+','linewidth',2)
    elseif length([SWIFT.time])==length([SWIFT.salinity])./2, % three CTs
        Sarray = reshape([SWIFT.salinity],2,length([SWIFT.time]));
        plot( [SWIFT.time],Sarray(1,:),'g+','linewidth',2), hold on
        plot( [SWIFT.time],Sarray(2,:),'k.','linewidth',2), hold on
        legend('0.5 m','1.2 m')
    elseif length([SWIFT.time])==length([SWIFT.salinity])./3, % three CTs
        Sarray = reshape([SWIFT.salinity],3,length([SWIFT.time]));
        plot( [SWIFT.time],Sarray(1,:),'rx','linewidth',2), hold on
        plot( [SWIFT.time],Sarray(2,:),'g+','linewidth',2), hold on
        plot( [SWIFT.time],Sarray(3,:),'k.','linewidth',2), hold on
        legend('0.1 m','0.5 m','1.2 m')
    else
    end
    set(gca,'Fontsize',16,'fontweight','demi')
    datetick
    ylabel(['salinity [PSU]'])
    set(gca,'Ylim',[0 36])
    
    linkaxes(tax,'x')
    set(gca,'XLim',[(min([SWIFT.time])-1/24) (max([SWIFT.time])+1/24)])
    print('-dpng',[wd '_tempandsalinity.png'])
    
    
    
    %% wave spectra plot
    figure(4), clf
    if isfield(SWIFT,'wavespectra'),
        for ai = 1:length(SWIFT),
            cmap = colormap;
            if ~isnan(SWIFT(ai).windspd) & SWIFT(ai).windspd > 0 & SWIFT(ai).windspd < 50,
                ci = ceil( SWIFT(ai).windspd ./ max([SWIFT.windspd]) * 64 );
                thiscolor = cmap(ci,:);
            else
                thiscolor = [0 0 0];
            end
            if length(SWIFT(ai).wavespectra.freq) == length(SWIFT(ai).wavespectra.energy),
                loglog(SWIFT(ai).wavespectra.freq,SWIFT(ai).wavespectra.energy,'linewidth',2,'color',thiscolor), hold on
            else
            end
            set(gca,'Fontsize',16,'fontweight','demi')
            xlabel('freq [Hz]')
            ylabel('Energy [m^2/Hz')
            title('Scalar wave spectra, colored by wind spd')
        end
        if ~isnan(max([SWIFT.windspd])),
            colorbar('Ticks',[0:.2:1],'TickLabels',round(linspace(0,max([SWIFT.windspd]),6))),
        else
        end
        print('-dpng',[ wd '_wavespectra.png'])
    else
    end
    
    
    
    %% turbulence plot
    figure(3), clf
    
    axes('position',[0.1 0.1 0.2 0.8])
    for ai = 1:length(SWIFT),
        
        if ~isnan(SWIFT(ai).uplooking.tkedissipationrate),
            epsilon(:,ai) = SWIFT(ai).uplooking.tkedissipationrate;
            z = SWIFT(ai).uplooking.z;
            t(ai) = SWIFT(ai).time;
            semilogx(SWIFT(ai).uplooking.tkedissipationrate,SWIFT(ai).uplooking.z,'k','linewidth',2), hold on
        elseif isfield(SWIFT(ai),'signature'),
        %elseif isfield(SWIFT(ai).signature.HRprofile,'z'),
            if ~isempty( SWIFT(ai).signature.HRprofile.z ),
                epsilon(:,ai) = SWIFT(ai).signature.HRprofile.tkedissipationrate;
                z = SWIFT(ai).signature.HRprofile.z;
                t(ai) = SWIFT(ai).time;
                semilogx(SWIFT(ai).signature.HRprofile.tkedissipationrate,SWIFT(ai).signature.HRprofile.z,'k','linewidth',2), hold on
            else
                epsilon(1:128,ai) = NaN;
                %z = NaN;
                t(ai) = SWIFT(ai).time;
            end
        else
            epsilon(1:16,ai) = NaN;
            %z = NaN;
            t(ai) = SWIFT(ai).time;
        end
        set(gca,'YDir','reverse')
        set(gca,'Fontsize',16,'fontweight','demi')
        ylabel('z [m]')
        xlabel('\epsilon [W/kg]')
        if ~all(isnan(epsilon)), set(gca,'ylim',[0 max(z)]), else end
        %set(gca,'Ylim',[0 0.7])
        %set(gca,'Xlim',[0 1e-2])
    end
    
    
    if any( nansum(epsilon) ~= 0 ) & length(SWIFT)>1,
        axes('position',[0.35 0.1 0.6 0.8])
        pcolor(t,z,log10(epsilon)), shading flat
        %       tall = [ones(length(z),1)*t];
        %       zall = [z'*ones(1,length(t))];
        %       scatter(tall(:),zall(:),10,log10(epsilon(:)),'filled' )
        set(gca,'ydir','reverse')
        datetick
        title('TKE dissipation rate, log scale [W/kg]')
        colorbar, caxis([-8 -2])
        set(gca,'ylim',[0 max(z)])
    else
    end
    
    print('-dpng',[ wd '_HRprofile_turbulence.png'])
    
    
    %% downlooking velocity profile plots
    
    figure(5), clf
    
    eastax = axes('position',[0.1 0.55 0.2 0.35]);
    northax = axes('position',[0.1 0.1 0.2 0.35]);
    
    for ai = 1:length(SWIFT),
        if ~isnan(SWIFT(ai).downlooking.velocityprofile),
            plot(SWIFT(ai).downlooking.velocityprofile,SWIFT(ai).downlooking.z,'linewidth',2), hold on
            east(:,ai) = NaN;
            north(:,ai) = NaN;
            magprofile(:,ai) = SWIFT(ai).downlooking.velocityprofile;
            z = SWIFT(ai).downlooking.z;
            t(ai) = SWIFT(ai).time;
        elseif isfield(SWIFT(ai),'signature') && isfield(SWIFT(ai).signature,'profile') && isfield(SWIFT(ai).signature.profile,'east'),
            if ~isempty( SWIFT(ai).signature.profile.east ),
                z = SWIFT(ai).signature.profile.z;
                t(ai) = SWIFT(ai).time;
                
                axes(eastax);
                east(:,ai) = SWIFT(ai).signature.profile.east ;
                plot(east(:,ai),SWIFT(ai).signature.profile.z,'k','linewidth',2), hold on
                
                axes(northax);
                north(:,ai) = SWIFT(ai).signature.profile.north ;
                plot(north(:,ai),SWIFT(ai).signature.profile.z,'k','linewidth',2), hold on
                
                %axes('position',[0.1 0.1 0.2 0.8]), hold on
                magprofile(:,ai) = sqrt( SWIFT(ai).signature.profile.east.^2 + SWIFT(ai).signature.profile.north.^2);
                %plot(magprofile(:,ai),SWIFT(ai).signature.profile.z,'k','linewidth',2),
            else
                east(1:40,ai) = NaN;
                north(1:40,ai) = NaN;
                magprofile(1:40,ai) = NaN;
                %z(1:40) = NaN;
                t(ai) = SWIFT(ai).time;
            end
        else
            east(1:40,ai) = NaN;
            north(1:40,ai) = NaN;
            magprofile(1:40,ai) = NaN;
            %z(1:40) = NaN;
            t(ai) = SWIFT(ai).time;
        end
        
        
        if any( nansum(east(:) + north(:)) ~= 0 ),
            axes(eastax);
            set(gca,'YDir','reverse')
            set(gca,'Fontsize',16,'fontweight','demi')
            ylabel('z [m]')
            xlabel('East [m/s]')
            
            axes(northax);
            set(gca,'YDir','reverse')
            set(gca,'Fontsize',16,'fontweight','demi')
            ylabel('z [m]')
            xlabel('North [m/s]')
        else
        end
    end
    
    if any( nansum(east(:) + north(:)) ~= 0 ) && size(east,2) > 1,%& ~isnan(z),
        axes('position',[0.35 0.55 0.6 0.35])
        pcolor(t,z,east), shading flat
        set(gca,'ydir','reverse')
        datetick, colorbar
        title('East [m/s]')
        
        axes('position',[0.35 0.1 0.6 0.35])
        pcolor(t,z,north), shading flat
        set(gca,'ydir','reverse')
        datetick, colorbar
        title('North [m/s]')
    elseif any( nansum(magprofile(:)) ~= 0) & length(SWIFT)>1,
        axes('position',[0.35 0.1 0.6 0.35])
        pcolor(t,z,magprofile), shading flat
        set(gca,'ydir','reverse')
        datetick, colorbar
        title('Magnitude [m/s]')
        delete(eastax)
    else
    end
    
    %axes('position',[0.35 0.1 0.6 0.8])
    %pcolor(t,z,magprofile), shading flat
    %set(gca,'ydir','reverse')
    %datetick, colorbar
    
    print('-dpng', [wd '_Avgvelocityprofiles.png'])
    
    
    %% drift plot
    figure(6), clf
    %quiver(lon,lat,dlondt,dlatdt,1), hold on
    quiver([SWIFT.lon],[SWIFT.lat],[SWIFT.driftspd].*sind([SWIFT.driftdirT]),[SWIFT.driftspd].*cosd([SWIFT.driftdirT]),1,'r','linewidth',2), hold on
    xlabel('longitude'), ylabel('latitude')
    axlims = axis;
    %quiver(axlims(1) +(axlims(2)-axlims(1))./10, axlims(3)+(axlims(4)-axlims(3))./10, .1, 0,0 );
    %text(axlims(1) +(axlims(2)-axlims(1))./9, axlims(3)+(axlims(4)-axlims(3))./8,'0.1 m/s')
    plot([SWIFT.lon],[SWIFT.lat],'bo','markersize',2), hold on
    %plot(lon(length(lon)),lat(length(lon)),'r.','markersize',20), hold on
    set(gca,'Fontsize',16,'fontweight','demi')
    print('-dpng',[wd '_drift.png'])
    
    %     if any( nansum(east(:) + north(:)) ~= 0 ) & ~isnan(any(z)),
    %     figure(20), clf
    %     lons = [SWIFT.lon]'.*ones(1,length(east));
    %     lats = [SWIFT.lon]'.*ones(1,length(east));
    %     quiver3(lons,lats,
    %     else
    %     end
    
    %% rain
    if isfield(SWIFT,'rainaccum')
        
        if  ~isnan([SWIFT.rainaccum]),
            
            figure(8), clf, n = 3;
            
            rax(1) = subplot(n,1,1);
            plot( [SWIFT.time],[SWIFT.relhumidity],'kx','linewidth',2)
            datetick
            ylabel(['Rel. humid. [%]'])
            set(gca,'Ylim',[0 100])
            
            rax(2) = subplot(n,1,2);
            plot( [SWIFT.time],[SWIFT.rainaccum],'kx','linewidth',2)
            datetick
            ylabel(['rain accum [mm]'])
            
            rax(3) = subplot(n,1,3);
            plot( [SWIFT.time],[SWIFT.rainint],'kx','linewidth',2)
            datetick
            ylabel(['rain int [mm/hr]'])
            set(gca,'Ylim',[0 inf])
            
            print('-dpng',[wd '_rain.png'])
            
        else
        end
        
    else
    end
    
    %% wind spectra
    
    if isfield(SWIFT,'windspectra'),
        
        if any(~isnan([SWIFT.windustar])),
            figure(9), clf
            for ai=1:length(SWIFT),
                loglog(SWIFT(ai).windspectra.freq,SWIFT(ai).windspectra.energy,'k','linewidth',1), hold on,
                set(gca,'fontweight','demi','fontsize',12)
                xlabel('f [Hz]')
                ylabel('E [m^2/Hz]')
                title('Wind Spectra')
            end
            
            set(gca,'FontSize',16,'fontweight','demi')
            print('-dpng',[wd '_wind.png'])
            
        else
        end
        
    else
    end
    
else
end
