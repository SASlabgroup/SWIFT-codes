function [] = plotSWIFT(SWIFT)
% Matlab function to plot the results in a SWIFT data structure
%   which must have multiple entries
% The resulting figures are named by the working directory
%   (and the parameters plotted)
%
% J. Thomson, 2014
% S. Brenner, 08/2018   Overhaul with more robust data field checks and
%                       adaptability.
% J. Thomson, 9/2018  set the ratio on the drift map to acount for changing
%               lat - lon ratio as a function of latitude (i.e., make
%               geographic axis ratio)
% M. Smith, 09/2018 update CT plotting to utilize CTdepth when available
% J. Thomson, 09/2018 include spectrogram in wave spectral figure  and
%               include met height legend in temp plot
% L. Crews 05/2025 plot info from vertical and horizontal acceleration histograms 
%
% plotSWIFT creates the following figures if applicable data is available:
%   figure 1: Wind and wave plot
%   figure 2: Temperature (air and water) and salinity plot
%   figure 3: Wave spectra plot
%   figure 4: Turbulence plot
%   figure 5: Downlooking velocity plots
%   figure 6: Drift plot
%   figure 7: Rain and humidity
%   figure 8: Wind spectra
%   figure 9: oxygen concentration and FDOM (fluorometer dissolved organic matter?)
%   figure 10: radiometers
%   figure 11: drift spd and direction
%   figure 12: acceleration histogram info (slow, turned off by default - set plot_wavehistogram = true)
%   figure 13: shortwave radiation and atmos pressure

if ispc
    slash = '\';
else
    slash = '/';
end


%% Initialize 
% Check that SWIFT contains information
if isempty(SWIFT) 
    return;
end

% use ID or working directory to name figure output
if isfield(SWIFT(1),'ID')
    wd = SWIFT(1).ID;
else
    wd = pwd;
    wdi = find(wd == slash,1,'last');
    wd = wd((wdi+1):length(wd));
end

% Save existing fontsize and fontweight, then set them globally 
% (so changes are applied to all figures called within the function)
fs = get(0,'defaultaxesfontsize');      % previous fontsize default
fw = get(0,'defaultaxesfontweight');    % previous fontweight default
set(0,'defaultaxesfontsize',14,'defaultaxesfontweight','demi');
% Create cleanup function that resets fontsize,weight when this function is
% finished or terminates for any reason
cleanupObj = onCleanup(@()set(0,'defaultaxesfontsize',fs,'defaultaxesfontweight',fw) );

% Plot info from wave histograms? Slow due to interpolating to common bins
plot_wavehistogram = true;

%% Figure 1: Wind and wave plot
% Available for all SWIFT, although v4s do not have winds

figure(1), clf, n = 4;

if isfield(SWIFT,'windspd') && any(~isnan([SWIFT.windspd])),
    ax(1) = subplot(n,1,1);
    plot( [SWIFT.time],[SWIFT.windspd],'bx','linewidth',2)
    datetick;
    ylabel('Wind [m/s]'), grid
    set(gca,'Ylim',[0 20])% ceil(max([SWIFT.windspd]))] )
end %if

if isfield(SWIFT,'sigwaveheight')
    ax(2) = subplot(n,1,2);
    plot( [SWIFT.time],[SWIFT.sigwaveheight],'g+','linewidth',2)
    datetick;
    ylabel('Wave H_s [m]'), grid
    set(gca,'Ylim',[0 inf])%ceil(max([SWIFT.sigwaveheight]))] )
end %if

if isfield(SWIFT,'peakwaveperiod')
    ax(3) = subplot(n,1,3);
    plot( [SWIFT.time],[SWIFT.peakwaveperiod],'g+','linewidth',2)
    datetick;
    ylabel('Wave T_p [s]')
    set(gca,'Ylim',[0 20]), grid
end %if 

if isfield(SWIFT,'peakwavedirT')
    ax(4) = subplot(n,1,4);
    plot([SWIFT.time],[SWIFT.peakwavedirT],'g+','linewidth',2), hold on
    datetick;
    ylabel('directions [^\circ T]')
    set(gca,'Ylim',[0 360])
    set(gca,'YTick',[0 180 360]), grid
end %if

if isfield(SWIFT,'winddirT') && length([SWIFT.winddirT]) == length([SWIFT.time])
    ax(4) = subplot(n,1,4);
    plot([SWIFT.time],[SWIFT.winddirT],'bx','linewidth',2), hold on
    datetick;
    ylabel('directions [^\circ T]'), grid
    set(gca,'Ylim',[0 360])
    set(gca,'YTick',[0 180 360])
    %legend('Wind','Waves');
end %if

linkaxes(ax,'x')
set(gca,'XLim',[(min([SWIFT.time])-1/24) (max([SWIFT.time])+1/24)] )
print('-dpng',['SWIFT' wd  '_windandwaves.png'])



%% Figure 2: Temperature and salinity plot
% Available for all SWIFTs
% Note: SWIFTs come in varieties containing 1--3 CT sensors. This code 
%       should adaptively account for for any of those options, however if
%       there is a mix-and-match across timestamps the code may not produce
%       expected results.

% Preprocessing work: -----------------------------------------------------
if isfield(SWIFT,'watertemp') && isfield(SWIFT,'salinity')

    % Create arrays of water temp and salinity:
    try
        Tarray = reshape( [SWIFT.watertemp],[],length(SWIFT) )';
        Sarray = reshape( [SWIFT.salinity],[],length(SWIFT) )';
    catch % if the number of elements doesn't divide evenly, reshape will throw error 
        warning('Mismatch in sizes for both watertemp and salinity across different timestamps in fig. 2.  Using only final CT sensor data for each timestamp')
        Tarray = arrayfun(@(x)x.watertemp(end),SWIFT)';
        Sarray = arrayfun(@(x)x.salinity(end),SWIFT)';
    end

    % number of CT sensors:
    numCT = size(Tarray,2);
    
  
    % Create arrays for assigning makers and legend labels based on numCT:
    namearray =  {'Marker';'Color';'Linestyle'}; 
    if isfield(SWIFT,'CTdepth')
        for cti = 1:numCT
            legendlabs{cti,1} = [num2str(SWIFT(end).CTdepth(cti),3) ' m'];
        end
    elseif numCT == 3  & ~isfield(SWIFT,'CTdepth')
        disp('CTdepth field not found: using default SWIFT depths')
        legendlabs = {'0.18 m';'0.66 m';'1.22 m'};
    elseif numCT == 2  & ~isfield(SWIFT,'CTdepth')
        disp('CTdepth field not found: using default SWIFT depths')
        legendlabs = {'0.66 m';'1.22 m'};
    elseif numCT == 1  & ~isfield(SWIFT,'CTdepth')
        disp('CTdepth field not found: using default SWIFT depths')
        legendlabs = {'0.5 m'};
    end
    
    if numCT == 3
        valuearray = {'x','b','none';
          '+','c','none';
          '.','k','none'};
    elseif numCT == 1
        valuearray = {'x','b','none'};
    elseif numCT == 2
        valuearray = {'x','b','none';
            '+','c','none'};
    end %if

end %if
% -------------------------------------------------------------------------


% Plotting: ---------------------------------------------------------------
figure(2); clf;

% Plot air temperature:
if isfield(SWIFT,'airtemp')
    tax(1) = subplot(311);
    plot( [SWIFT.time],[SWIFT.airtemp],'g+','linewidth',2);
    datetick;
    ylabel('airtemp [C]')
    if isfield(SWIFT,'metheight')
        legend([num2str(SWIFT(1).metheight,3) ' m'],'Location','NortheastOutside')
    else
        legend(['0.84 m'],'Location','NortheastOutside')
    end
    %set(gca,'Ylim',[-15 30])
    grid on;
end

% Plot water temperature:
if isfield(SWIFT,'watertemp') && isfield(SWIFT,'salinity')
    tax(2) = subplot(312);
    h = plot([SWIFT.time],Tarray,'linewidth',2);
    datetick;
    set(h,namearray,valuearray) 
    if exist('legendlabs'); legend(legendlabs,'Location','NortheastOutside'); end%if
    ylabel('watertemp [C]'), grid on
    %set(gca,'Ylim',[-2 30])
end

% Plot salinity:
if isfield(SWIFT,'watertemp') && isfield(SWIFT,'salinity')
    tax(3) = subplot(313);
    h = plot([SWIFT.time],Sarray,'linewidth',2);
    datetick;
    set(h,namearray,valuearray) 
    if exist('legendlabs'); legend(legendlabs,'Location','NortheastOutside'); end%if
    ylabel('salinity [PSU]'), grid on
    %set(gca,'Ylim',[0 36])
end

if isfield(SWIFT,'airtemp') | isfield(SWIFT,'watertemp') && isfield(SWIFT,'salinity'),
    linkaxes(tax,'x');
    set(gca,'XLim',[(min([SWIFT.time])-1/24) (max([SWIFT.time])+1/24)]);
    print('-dpng',['SWIFT' wd '_tempandsalinity.png'])
else
end
% -------------------------------------------------------------------------


%% Figure 3: Wave Spectra Plot
% Available for all SWIFTs, using either Microstrain or SBG inertial motion units with GPS
 t=[];
if isfield(SWIFT,'wavespectra')
    figure(3), clf;
    
    % line spectra
    subplot(2,1,1)
    % Loop through timestamps
    for ai = 1:length(SWIFT)
        % If windspd value exist and are physical, use them to assign plot
        % color:
        cmap = colormap;
        if isfield(SWIFT,'windspd') && ~isnan(SWIFT(ai).windspd) &&... % check field exists and contains data
            SWIFT(ai).windspd > 0 && SWIFT(ai).windspd < 50            % check data is physical
            ci = ceil( SWIFT(ai).windspd ./ max([SWIFT.windspd]) * length(cmap) );
            thiscolor = cmap(ci,:);
        else
            thiscolor = [0 0 0];
        end %if
        % Plot spectra on log-log scale
        if length(SWIFT(ai).wavespectra.freq) == length(SWIFT(ai).wavespectra.energy)
            semilogy(SWIFT(ai).wavespectra.freq,SWIFT(ai).wavespectra.energy,'linewidth',2,'color',thiscolor);
            hold on
            E(ai,:) = SWIFT(ai).wavespectra.energy;
            f(ai,:) = SWIFT(ai).wavespectra.freq;
            t(ai) = SWIFT(ai).time;
        else
        end %if
    end %for
    
    xlabel('freq [Hz]');
    ylabel('Energy [m^2/Hz]');
    axis([5e-2 7e-1 1e-3 inf])
    title('Scalar wave spectra');
    if isfield(SWIFT,'windspd') &&  ~isnan(max([SWIFT.windspd]))
        WindColorbar = colorbar('Location','East','Ticks',0:0.2:1,'TickLabels',round(linspace(0,max([SWIFT.windspd]),6)*10)/10);
        WindColorbar.Label.String = 'Wind spd [m/s]';
    else

    end
    
    % spectrogram
    subplot(2,1,2)
    if length(t)>1,
    pcolor(nanmean(f,1),t,log10(E)), shading flat
    axis([5e-2 7e-1 min(t) max(t)])
    xlabel('freq [Hz]');
    datetick('y')
    ylabel('Time -->')
    Ecolorbar = colorbar('Location','East');
    Ecolorbar.Label.String = 'Log_{10}(E)';
    colormap(gca,'spring')    
    else 
    end
    
    print('-dpng',[ 'SWIFT' wd '_wavespectra.png'])
else
end %if


%% Figure 4: Turbulence plot
% available for SWIFTS with Nortek AquadoppHR (uplooking) or Signature ADCP (downlooking)

% Turbulence profiles can be stored in one of two fields:
% 1. SWIFT.uplooking.tkedissipationrate
% 2. SWIFT.signature.HRprofile
%
% Note that if there is a mis-match between timestamps the code may not
% produce the expected results.



% Preprocessing -----------------------------------------------------------
% Loop through time records and extract turbulence profiles (if they exist)
% into their own structure array
turb(1:length(SWIFT)) = struct; % pre-allocate structure
for ai = 1:length(SWIFT)
    if isfield(SWIFT(ai),'uplooking') &&... 
            isfield(SWIFT(ai).uplooking,'tkedissipationrate') &&... % does the field exist?
        nansum([SWIFT(ai).uplooking.tkedissipationrate]) ~= 0  % does it contain data?
            turb(ai).time = SWIFT(ai).time;
            turb(ai).z = SWIFT(ai).uplooking.z(:)';
            turb(ai).epsilon = SWIFT(ai).uplooking.tkedissipationrate(:)';
    elseif isfield(SWIFT(ai),'signature') &&... % does the field exist?
            isfield(SWIFT(ai).signature,'HRprofile') &&... % does the field exist?
            isfield(SWIFT(ai).signature.HRprofile,'tkedissipationrate') &&... % does the field exist?
           nansum([SWIFT(ai).signature.HRprofile.tkedissipationrate]) ~= 0   % does it contain data?
            turb(ai).time = SWIFT(ai).time;
            turb(ai).z = SWIFT(ai).signature.HRprofile.z(:)';
            turb(ai).epsilon = SWIFT(ai).signature.HRprofile.tkedissipationrate(:)';
    else % no data
        turb(ai).time = [];
        turb(ai).z = ([]);
        turb(ai).epsilon = ([]);
    end %if
end %for
% -------------------------------------------------------------------------

% Plotting: ---------------------------------------------------------------
if nansum([turb.epsilon]) ~= 0 % check if there is something to plot
    figure(4); clf;
    zmax = max( [turb.z] );
    try
        % If the size of all turbulence profiles is the same, we can create
        % arrays of those profiles and plot them.  
        z_array =   reshape([turb.z],[],length([turb.time]));
        eps_array = reshape([turb.epsilon],[],length([turb.time]));

        axes('position',[0.1 0.1 0.18 0.8])
        semilogx(eps_array, z_array, 'k','linewidth',2);
        set(gca,'YDir','reverse','Ylim',[0,zmax])
        ylabel('z [m]')
        xlabel('\epsilon [W/kg]')

        axes('position',[0.35 0.1 0.6 0.8])
        pcolor([turb.time],z_array,log10(eps_array));
        shading flat;
        datetick;
        title('TKE dissipation rate, log scale [W/kg]')
        colorbar, caxis([-8 -2])
        set(gca,'ydir','reverse','ylim',[0,zmax])
    catch
        % If there is a size mis-match, the reshape function will throw an
        % error.  Then we should just plot the extant profiles:
        warning('Possible size mismatch between turbulence profiles at different timestamps in fig. 4');
        hold on;
        arrayfun(@(S) plot(S.epsilon,S.z,'k','linewidth',2), turb);
        set(gca,'XScale','log','YDir','reverse','Ylim',[0,zmax]);
        ylabel('z [m]')
        xlabel('\epsilon [W/kg]')
    end %try/catch

    print('-dpng',['SWIFT' wd '_HRprofile_turbulence.png'])
end %if



%% Figure 5: Downlooking velocity profiles
% Available for SWIFTS with downlooking Nortek Signature or Aquadopp

% Velocity profiles can be stored in one of two fields:
% 1. SWIFT.downlooking.velocityprofile
% 2. SWIFT.signature.profile
% Each of these 
%
% Note that if there is a mis-match between timestamps the code may not
% produce the expected results.
%
% (This code section takes the same approach as for Figure 4.)

% Preprocessing -----------------------------------------------------------
% Loop through time records and extract velocity profiles (if they exist)
% into their own structure arrays
prof(1:length(SWIFT)) = struct; % pre-allocate structure
for ai = 1:length(SWIFT)
    if isfield(SWIFT(ai),'downlooking') &&... % does the field exist?
       isfield(SWIFT(ai).downlooking,'velocityprofile') &&... % does the field exist?
       nansum([SWIFT(ai).downlooking.velocityprofile]) ~= 0   % does it contain data?
            prof(ai).time = SWIFT(ai).time;
            prof(ai).z = SWIFT(ai).downlooking.z;
            prof(ai).spd = SWIFT(ai).downlooking.velocityprofile;
            prof(ai).east_vel = [];
            prof(ai).north_vel = []; 
    elseif isfield(SWIFT(ai),'signature') &&...
           isfield(SWIFT(ai).signature.profile,'east') &&...   % does the field exist?
           (nansum([SWIFT(ai).signature.profile.east]) ~= 0  ||...
            nansum([SWIFT(ai).signature.profile.north]) ~= 0 )  % does it contain data (in either vector)?
            prof(ai).time = SWIFT(ai).time;
            prof(ai).z = SWIFT(ai).signature.profile.z;
            prof(ai).east_vel = SWIFT(ai).signature.profile.east;
            prof(ai).north_vel = SWIFT(ai).signature.profile.north; 
            prof(ai).spd = sqrt( prof(ai).east_vel.^2 +  prof(ai).north_vel.^2) ;
    else % no data
        prof(ai).time = [];
        prof(ai).z = [];
        prof(ai).east_vel = [];
        prof(ai).north_vel = [];
        prof(ai).spd = [];
    end %if
end %for 
% -------------------------------------------------------------------------

% Plotting: ---------------------------------------------------------------
if any(nansum([prof.east_vel]) ~= 0)  || any(nansum([prof.north_vel]) ~= 0)  % Separate east & north profiles
    figure(5); clf;
    try
        z_array = reshape([prof.z],[],length([prof.time]));
        east_array = reshape([prof.east_vel],[],length([prof.time]));
        north_array = reshape([prof.north_vel],[],length([prof.time]));
        % Plot east velocity profiles
        axes('position',[0.1 0.55 0.2 0.35]);
        plot(east_array,z_array,'k','linewidth',2);
        set(gca,'YDir','reverse');
        ylabel('z [m]');
        xlabel('East [m/s]');
        set(gca,'XLim',[-1 1])
        
        % Plot north velocity profiles
        axes('position',[0.1 0.1 0.2 0.35]);
        plot(north_array,z_array,'k','linewidth',2);
        set(gca,'YDir','reverse');
        ylabel('z [m]');
        xlabel('North [m/s]');
        set(gca,'XLim',[-1 1])
        
        if size(east_array,2) > 1
        % Plot east velocity Hovmueller-type plot
        axes('position',[0.35 0.55 0.6 0.35])
        pcolor([prof.time],z_array,east_array);
        shading flat;
        set(gca,'ydir','reverse');
        datetick; 
        colorbar;
        title('East [m/s]')
        cmocean('balance')
        caxis([-1 1])
        
        % Plot north velocity Hovmueller-type plot
        axes('position',[0.35 0.1 0.6 0.35])
        pcolor([prof.time],z_array,north_array);
        shading flat;
        set(gca,'ydir','reverse');
        datetick; 
        colorbar;
        title('North [m/s]')
        cmocean('balance')
        caxis([-1 1])

        end %if
        
    catch
        % If there is a size mis-match, the reshape function will throw an
        % error.  Then we should just plot the extant profiles:
        warning('Possible size mismatch between velocity profiles at different timestamps in fig. 5');
        
        % Plot east velocity profiles
        axes('position',[0.1 0.55 0.2 0.35]);
        hold on;
        arrayfun(@(S) plot(S.east_vel,S.z,'k','linewidth',2), prof);
        set(gca,'YDir','reverse');
        ylabel('z [m]');
        xlabel('East [m/s]');
        
        % Plot north velocity profiles
        axes('position',[0.1 0.1 0.2 0.35]);
        arrayfun(@(S) plot(S.north_vel,S.z,'k','linewidth',2), prof);
        set(gca,'YDir','reverse');
        ylabel('z [m]');
        xlabel('North [m/s]');       
        
    end %try/catch
    
    print('-dpng', ['SWIFT' wd '_Avgvelocityprofiles.png']);      
elseif nansum([prof.spd]) ~= 0 % no separate profiles, but speeds exist
    figure(5); clf;
    
    try
        z_array = reshape([prof.z],[],length([prof.time]));
        spd_array = reshape([prof.spd],[],length([prof.time]));
        
        % Plot speed profiles
        axes('position',[0.1 0.1 0.18 0.35]);
        plot(spd_array,z_array,'k','linewidth',2);
        set(gca,'YDir','reverse');
        ylabel('z [m]');
        xlabel('Magnitude [m/s]');
        
        
        % Plot speed Hovmueller-type plot
        axes('position',[0.35 0.1 0.6 0.35])
        pcolor([prof.time],z_array,spd_array);
        shading flat;
        set(gca,'ydir','reverse');
        datetick; 
        colorbar;
        title('Magnitude [m/s]')
    catch
        % If there is a size mis-match, the reshape function will throw an
        % error.  Then we should just plot the extant profiles:
        warning('Possible size mismatch between velocity profiles at different timestamps in fig. 5');
        
        axes('position',[0.1 0.1 0.2 0.35]);
        arrayfun(@(S) plot(S.spd,S.z,'k','linewidth',2), prof);
        set(gca,'YDir','reverse');
        ylabel('z [m]');
        xlabel('Magnitude [m/s]');      
    end %try/catch
    
    print('-dpng', ['SWIFT' wd '_Avgvelocityprofiles.png']);  
end %if



%% Figure 6: Drift Plot
% Available for all SWIFTs

if isfield( SWIFT, 'driftspd' ) && isfield( SWIFT, 'driftdirT' )
    if any(~isnan([SWIFT.lat]))
        figure(6);
        clf;

        quiver([SWIFT.lon],[SWIFT.lat],...
            [SWIFT.driftspd].*sind([SWIFT.driftdirT]),...
            [SWIFT.driftspd].*cosd([SWIFT.driftdirT]),...
            1,'r','linewidth',2);
        hold on;
        plot([SWIFT.lon],[SWIFT.lat],'bo','markersize',2);

        xlabel('longitude');
        ylabel('latitude');
        ratio = [1./abs(cosd(nanmean([SWIFT.lat]))),1,1];  % ratio of lat to lon distances at a given latitude
        daspect(ratio)
        print('-dpng',['SWIFT' wd '_drift.png'])
    else
        disp('*** ALL POSITIONS ARE NAN, cannot make drift plot ***')
    end
end %if

%% Figure 7: Rain
% Available for SWIFT v3s with Vaisala 536 met stations

if isfield(SWIFT,'rainaccum') && any(~isnan([SWIFT.rainaccum])) && any(~isempty([SWIFT.rainaccum]))
    
    figure(8); clf;
    
    rax(1) = subplot(n,1,1);
    plot( [SWIFT.time],[SWIFT.relhumidity],'kx','linewidth',2)
    datetick;
    ylabel('Rel. humid. [%]')
    set(gca,'Ylim',[0 100])
    
    rax(2) = subplot(n,1,2);
    plot( [SWIFT.time],[SWIFT.rainaccum],'kx','linewidth',2)
    datetick;
    ylabel('Rain accum. [mm]')
    
    rax(3) = subplot(n,1,3);
    plot( [SWIFT.time],[SWIFT.rainint],'kx','linewidth',2)
    datetick;
    ylabel('Rain int. [mm/hr]')
    set(gca,'Ylim',[0 inf])
    
    linkaxes(rax,'x');
    set(gca,'XLim',[(min([SWIFT.time])-1/24) (max([SWIFT.time])+1/24)]);
    print('-dpng',['SWIFT' wd '_rain.png'])
    
end %if 

%% Figure 8: Wind Spectra
% Available for v3 SWIFTs with RM Young 3-axis sonic anemometers

if isfield(SWIFT,'windspectra') &&... % check field exists
    any(~isnan([SWIFT.windustar])) && any(~isempty([SWIFT.windustar]))  % if SWIFT.windustar exists then spectra will exist 
    figure(8); clf;
    
    % Loop through timestamps
    for ai = 1:length(SWIFT)
        
        if length(SWIFT(ai).windspectra.freq) == length(SWIFT(ai).windspectra.energy) % check size

            % Plot spectra on log-log scale
            loglog(SWIFT(ai).windspectra.freq,SWIFT(ai).windspectra.energy,...
                   'k','linewidth',1);
            hold on;
        else
        end %if
    end %for
    
    xlabel('freq [Hz]')
    ylabel('Energy [m^2/Hz]')
    title('Wind Spectra')
    set(gca,'XLim',[1e-2 1e1])
    print('-dpng',['SWIFT' wd '_wind.png'])
else
end

%% Figure 9: oxygen and fluoresence 

if isfield(SWIFT,'O2conc') && any(~isnan([SWIFT.O2conc])) && any(~isempty([SWIFT.O2conc])),
    figure(9), hold off
    subplot(2,1,1),
    plot([SWIFT.time],[SWIFT.O2conc],'x')
    datetick
    ylabel('O_2 conc [uM/Kg]')
    print('-dpng',['SWIFT' wd '_oxygen_FDOM.png'])
end
    
if isfield(SWIFT,'FDOM') && any(~isnan([SWIFT.FDOM])) && any(~isempty([SWIFT.FDOM])),
    figure(9), hold off
    subplot(2,1,2),
    plot([SWIFT.time],[SWIFT.FDOM],'x')
    datetick
    ylabel('FDOM [ppb]')
    print('-dpng',['SWIFT' wd '_oxygen_FDOM.png'])
end


%% Figure 10: SST radiometers (CT15)

if isfield(SWIFT, 'radiometertemp1mean') && any(~isnan([SWIFT.radiometertemp1mean]))
    nrad = length( SWIFT(1).radiometertemp1mean );
    RadT1 = reshape([SWIFT.radiometertemp1mean],nrad,length(SWIFT));
    RadT2 = reshape([SWIFT.radiometertemp2mean],nrad,length(SWIFT));
    if isfield(SWIFT, 'radiometerrad1')
        RadR1 = reshape([SWIFT.radiometerrad1],nrad,length(SWIFT));
        RadR2 = reshape([SWIFT.radiometerrad2],nrad,length(SWIFT));
    else
        RadR1 = NaN;
        RadR2 = NaN;  
    end
    
    figure(10), hold off
    subplot(2,1,1)
    plot([SWIFT.time],RadT1)
    hold on
    plot([SWIFT.time],RadT2,'color',rgb('lightgrey'))
    datetick
    ylabel('Temperature [C]')
    subplot(2,1,2)
    plot([SWIFT.time],RadR1)
    hold on
    plot([SWIFT.time],RadR2,'color',rgb('lightgrey'))
    datetick
    ylabel('Radiance [mV]')
    print('-dpng',['SWIFT' wd '_radiometer.png'])

end

%% Figure 11: drift speed and direction

if isfield(SWIFT,'driftspd') && any(~isnan([SWIFT.driftspd]))

    figure(11), clf
    subplot(2,1,1)
    plot([SWIFT.time],[SWIFT.driftspd])
    hold on
    datetick
    ylabel('Drift Spd [m/s]')
    subplot(2,1,2)
    plot([SWIFT.time],[SWIFT.driftdirT],'.')
    hold on
    datetick
    ylabel('Drift dir [deg T]')
    set(gca,'YLim',[0 360])
    print('-dpng',['SWIFT' wd '_driftspd_driftdir.png']) 

end

%% Figure 12: horizontal and acceleration histogram pcolor plots, skewness, kurtosis

if plot_wavehistogram && isfield(SWIFT, 'wavehistogram')
    direcs = {'hor', 'vert'}; %Iterate and make plots for horizontal and vertical accelerations
    for direc_num = 1:numel(direcs)
        direc = char(direcs(direc_num));
     
        figure(12), clf; set(gcf, 'color', 'w')
    
        % Find min and max values of entire dataset for common bin edges
        minacc = inf; maxacc = -inf;
        minacc_count = inf; maxacc_count = -inf;
        nbins = 32; %Consistent with existing bin number

        for j = 1:numel(SWIFT)            
            bins = SWIFT(j).wavehistogram.([direc, 'accbins']);
            counts = SWIFT(j).wavehistogram.([direc, 'acc']);

            %Update min and max values of the entire dataset
            minacc = min(minacc, min(bins));
            maxacc = max(maxacc, max(bins));
            minacc_count = min(minacc_count, min(counts));
            maxacc_count = max(maxacc_count, max(counts));
        end

        %Common bins to grid all data to 
        interp_bin_centers = linspace(minacc, maxacc, nbins);
       
        interp_counts = nan(numel(SWIFT), nbins);  %Initialize
    
        % Data for plots of skew and kurtosis over time
        skews = nan(numel(SWIFT), 1);
        kurtos = nan(numel(SWIFT), 1);
        times = nan(numel(SWIFT), 1);
    
        for j = 1:numel(SWIFT)
             
            bins = SWIFT(j).wavehistogram.([direc, 'accbins']);
            counts = SWIFT(j).wavehistogram.([direc, 'acc']);
            interp_counts(j, :) = interp1(bins, counts, interp_bin_centers, 'linear') ./ sum(counts); % normalized
        
            %Calculate and save needeed info for skewness andd kurtosis plots
            data = repelem(bins, counts); % Reconstruct pseudo-data 
            skews(j) = skewness(data);
            kurtos(j) = kurtosis(data); 
            times(j) = SWIFT(j).time;  % For vertical axis; 
    
            %Optionally plot to see that data reconstruction worked
            % figure; clf; hold on
            % histogram(data)
            % plot(bins, counts);
    
        end
    %%
        %Pcolor of all histograms over time - additional formatting for all subplots done at the end
        subplot(3, 1, 1); hold on; box on
        pcolor(times, interp_bin_centers, interp_counts'); shading flat
        ylabel([direc, ' acc [g]'], 'FontSize', 12)
        cb = colorbar;
        %clabel(cb, 'observations [counts]', 'FontSize', 12)
        cb.Label.String = 'N';
        %clim([minacc_count maxacc_count]) 
        ylim([minacc, maxacc])
        
        %% Plot skew and kurtosis
    
        %Smooth with 1-day moving window
        smooth_skews = movmean(skews, 1, 'SamplePoints', times);
        smooth_kurtos = movmean(kurtos, 1, 'SamplePoints', times);
    
        subplot(3, 1, 2); hold on; 
        plot(times, smooth_skews,  'color', 'k', 'linewidth', 1);  
        ylabel('skewness', 'FontSize', 12)
        cb2 = colorbar; set(cb2,'Visible','off')
        
        subplot(3, 1, 3); hold on; 
        plot(times, smooth_kurtos, 'color', 'k', 'linewidth', 1); 
        ylabel('kurtosis', 'FontSize', 12)
        cb3 = colorbar; set(cb3,'Visible','off')
    
        %Plot formatting
        for splot = 1:3
            subplot(3, 1, splot)
            xlim([SWIFT(1).time, SWIFT(end).time])
            datetick('x', 'keeplimits')
            set(gca, 'FontSize', 12)
            box on; grid on
        end
    end %End of loop for acceleration direction (horizontal or vertical)
    
    print('-dpng',['SWIFT' wd '_acchist.png']) 

end 

%% figure 13: shortwave radiation
if isfield(SWIFT,'solarrad') && isfield(SWIFT,'airpres') && isfield(SWIFT,'airtemp') && isfield(SWIFT,'windspd') % check field exists
    
    figure(13), clf
    
    subplot(4,1,1)
    plot([SWIFT.time],[SWIFT.solarrad],'linewidth',2)
    datetick
    ylabel('Solar rad. [W/m^2]')

    subplot(4,1,2)
    plot([SWIFT.time],[SWIFT.airtemp],'linewidth',2)
    datetick
    ylabel('Air temp [C]')

    subplot(4,1,3)
    plot([SWIFT.time],[SWIFT.airpres],'linewidth',2)
    datetick
    ylabel('Air pres [mb]')

    subplot(4,1,4)
    plot([SWIFT.time],[SWIFT.windspd],'linewidth',2)
    datetick
    ylabel('Wind spd [m/s]')

    print('-dpng',['SWIFT' wd '_solarrad_met.png']) 

end

