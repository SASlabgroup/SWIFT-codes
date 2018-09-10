function [] = plotSWIFT(SWIFT)
% Matlab function to plot the results in a SWIFT data structure
%   which must have multiple entries
% The resulting figures are named by the working directory
%   (and the parameters plotted)
%
% J. Thomson,    2014
% S. Brenner, 08/2018   Overhaul with more robust data field checks and
%                       adaptability.
%
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


%% Initialize 
% Check that SWIFT contains information
if isempty(SWIFT) 
    return;
end

% Define working directory (used to save figures)
wd = pwd;
wdi = find(wd == '/',1,'last');
wd = wd((wdi+1):length(wd));

% Save existing fontsize and fontweight, then set them globally 
% (so changes are applied to all figures called within the function)
fs = get(0,'defaultaxesfontsize');      % previous fontsize default
fw = get(0,'defaultaxesfontweight');    % previous fontweight default
set(0,'defaultaxesfontsize',14,'defaultaxesfontweight','demi');
% Create cleanup function that resets fontsize,weight when this function is
% finished or terminates for any reason
cleanupObj = onCleanup(@()set(0,'defaultaxesfontsize',fs,'defaultaxesfontweight',fw) );




%% Figure 1: Wind and wave plot
% Available for all SWIFT, although v4s do not have winds

figure(1), clf, n = 4;

if isfield(SWIFT,'windspd')
    ax(1) = subplot(n,1,1);
    plot( [SWIFT.time],[SWIFT.windspd],'bx','linewidth',2)
    datetick;
    ylabel('Wind [m/s]')
    set(gca,'Ylim',[0 ceil(max([SWIFT.windspd]))] )
end %if

if isfield(SWIFT,'sigwaveheight')
    ax(2) = subplot(n,1,2);
    plot( [SWIFT.time],[SWIFT.sigwaveheight],'g+','linewidth',2)
    datetick;
    ylabel('Wave H_s [m]')
    set(gca,'Ylim',[0 ceil(max([SWIFT.sigwaveheight]))] )
end %if

if isfield(SWIFT,'peakwaveperiod')
    ax(3) = subplot(n,1,3);
    plot( [SWIFT.time],[SWIFT.peakwaveperiod],'g+','linewidth',2)
    datetick;
    ylabel('Wave T_p [s]')
    set(gca,'Ylim',[0 20])
end %if 

if isfield(SWIFT,'winddirT') && isfield(SWIFT,'peakwavedirT')
    ax(4) = subplot(n,1,4);
    plot([SWIFT.time],[SWIFT.winddirT],'bx','linewidth',2), hold on,
    plot([SWIFT.time],[SWIFT.peakwavedirT],'g+','linewidth',2), hold on
    datetick;
    ylabel('directions [^\circ T]')
    set(gca,'Ylim',[0 360])
    set(gca,'YTick',[0 180 360])
    legend('Wind','Waves');
end %if

linkaxes(ax,'x')
set(gca,'XLim',[(min([SWIFT.time])-1/24) (max([SWIFT.time])+1/24)] )
print('-dpng',[wd  '_windandwaves.png'])



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

    % Create arrays for assigning makers and legend labels:
    legendlabs = {'0.1 m';'0.5 m';'1.2 m'};
    namearray =  {'Marker';'Color';'Linestyle'};
    valuearray = {'x','r','none';
                  '+','g','none';
                  '.','k','none'};
    % adjust array based on the number of CT sensors included:
    if numCT == 1
        valuearray = valuearray(2,:);
    elseif numCT == 2
        legendlabs = legendlabs(2:3);
        valuearray = valuearray(2:3,:);
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
    %set(gca,'Ylim',[-15 30])
    grid on;
end

% Plot water temperature:
if isfield(SWIFT,'watertemp')
    tax(2) = subplot(312);
    h = plot([SWIFT.time],Tarray,'linewidth',2);
    datetick;
    set(h,namearray,valuearray) 
    if numCT >1; legend(legendlabs); end%if
    ylabel('watertemp [C]')
    %set(gca,'Ylim',[-2 30])
end

% Plot salinity:
if isfield(SWIFT,'salinity');
    tax(3) = subplot(313);
    h = plot([SWIFT.time],Sarray,'linewidth',2);
    datetick;
    set(h,namearray,valuearray) 
    if numCT >1; legend(legendlabs); end%if
    ylabel('salinity [PSU]')
    %set(gca,'Ylim',[0 36])
end

linkaxes(tax,'x');
set(gca,'XLim',[(min([SWIFT.time])-1/24) (max([SWIFT.time])+1/24)]);
print('-dpng',[wd '_tempandsalinity.png'])
% -------------------------------------------------------------------------


%% Figure 3: Wave Spectra Plot
% Available for all SWIFTs, using either Microstrain or SBG inertial motion units with GPS

if isfield(SWIFT,'wavespectra')
    figure(3), clf;
    
    % Loop through timestamps
    for ai = 1:length(SWIFT)
        % If windspd value exist and are physical, use them to assign plot
        % color:
        cmap = colormap;
        if isfield(SWIFT,'windspd') && ~isnan(SWIFT(ai).windspd) &&... % check field exists and contains data
            SWIFT(ai).windspd > 0 && SWIFT(ai).windspd < 50            % check data is physical
            ci = ceil( SWIFT(ai).windspd ./ max([SWIFT.windspd]) * 64 );
            thiscolor = cmap(ci,:);
        else
            thiscolor = [0 0 0];
        end %if
        % Plot spectra on log-log scale
        if length(SWIFT(ai).wavespectra.freq) == length(SWIFT(ai).wavespectra.energy)
            loglog(SWIFT(ai).wavespectra.freq,SWIFT(ai).wavespectra.energy,'linewidth',2,'color',thiscolor);
            hold on
        else
        end %if
    end %for
    
    xlabel('freq [Hz]');
    ylabel('Energy [m^2/Hz]');
    if isfield(SWIFT,'windspd') &&  ~isnan(max([SWIFT.windspd]))
        title('Scalar wave spectra, colored by wind spd')
        colorbar('Ticks',0:0.2:1,'TickLabels',round(linspace(0,max([SWIFT.windspd]),6)));
    else
        title('Scalar wave spectra');
    end
    print('-dpng',[ wd '_wavespectra.png'])
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

    print('-dpng',[ wd '_HRprofile_turbulence.png'])
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
        
        % Plot north velocity profiles
        axes('position',[0.1 0.1 0.2 0.35]);
        plot(north_array,z_array,'k','linewidth',2);
        set(gca,'YDir','reverse');
        ylabel('z [m]');
        xlabel('North [m/s]');
        
        if size(east_array,2) > 1
        % Plot east velocity Hovmueller-type plot
        axes('position',[0.35 0.55 0.6 0.35])
        pcolor([prof.time],z_array,east_array);
        shading flat;
        set(gca,'ydir','reverse');
        datetick; 
        colorbar;
        title('East [m/s]')
        
        % Plot north velocity Hovmueller-type plot
        axes('position',[0.35 0.1 0.6 0.35])
        pcolor([prof.time],z_array,north_array);
        shading flat;
        set(gca,'ydir','reverse');
        datetick; 
        colorbar;
        title('North [m/s]')
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
    
    print('-dpng', [wd '_Avgvelocityprofiles.png']);      
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
    
    print('-dpng', [wd '_Avgvelocityprofiles.png']);  
end %if



%% Figure 6: Drift Plot
% Available for all SWIFTs

if isfield( SWIFT, 'driftspd' ) && isfield( SWIFT, 'driftdirT' )
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

    print('-dpng',[wd '_drift.png'])
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
    print('-dpng',[wd '_rain.png'])
    
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
    print('-dpng',[wd '_wind.png'])
else
end

%% Figure 9: oxygen and fluoresence 

if isfield(SWIFT,'O2conc') && any(~isnan([SWIFT.O2conc])) && any(~isempty([SWIFT.O2conc])),
    figure(9), hold off
    subplot(2,1,1),
    plot([SWIFT.time],[SWIFT.O2conc],'x')
    datetick
    ylabel('O_2 conc [uM/Kg]')
    print('-dpng',[wd '_oxygen_FDOM.png'])
end
    
if isfield(SWIFT,'FDOM') && any(~isnan([SWIFT.FDOM])) && any(~isempty([SWIFT.FDOM])),
    figure(9), hold off
    subplot(2,1,2),
    plot([SWIFT.time],[SWIFT.FDOM],'x')
    datetick
    ylabel('FDOM [ppb]')
    print('-dpng',[wd '_oxygen_FDOM.png'])
end


end %function