% script to scale near-surface TKE dissipation rates from SWIFT obs
%
%   J. Thomson, 9/2017
%               3/2019 color by winds, show z/H scaling separately
%
clear all, close all

maxwind = 8; % m/s

flist = dir('SWIFT*.mat');

counter = 0;

for fi = 1:length(flist),
    
    load(flist(fi).name)
    
    for si = 1:length(SWIFT),
        
        if isfield(SWIFT,'windustar')
            F = (SWIFT(si).windustar).^3;
        else
            F = NaN;
        end
        
        H = SWIFT(si).sigwaveheight;
        
        if ~isnan(SWIFT(si).uplooking.tkedissipationrate),
            epsilon = SWIFT(si).uplooking.tkedissipationrate;
            z = SWIFT(si).uplooking.z;
        elseif isfield(SWIFT(si),'signature'),
            if ~isempty( SWIFT(si).signature.profile.z ),
                epsilon = SWIFT(si).signature.HRprofile.tkedissipationrate;
                z = SWIFT(si).signature.HRprofile.z;
            else
                epsilon = NaN;
                z = NaN;
            end
        else
            epsilon = NaN;
            z = NaN;
        end
        
        
        figure(1), % dimensional, colored by wind
        cmap = colormap;
        if isfield(SWIFT,'windspd') && ~isnan(SWIFT(si).windspd) &&... % check field exists and contains data
                SWIFT(si).windspd > 0 && SWIFT(si).windspd < 50            % check data is physical
            ci = ceil( SWIFT(si).windspd ./ maxwind * 64 ); if ci>64, ci=64; end
            thiscolor = cmap(ci,:);
        else
            thiscolor = [0 0 0];
        end %if
        loglog(epsilon,z,'color',thiscolor)
        hold on
        
        
        figure(2), % non-dimen depth, colored by wind
        loglog(epsilon,z./H,'color',thiscolor)
        hold on
        
        figure(3), % non-dimend depth and non-dimen flux
        loglog((epsilon.*H)./F, z./H, 'color',thiscolor)
        hold on
        
    end
    
end

figure(1)
set(gca,'Ydir','reverse')
%plot(1e-5.*[5e-2 1e0].^-2,[5e-2 1e0],'k--')
%axis([1e-7 1e0 1e-4 1e1])
set(gca,'fontsize',16,'fontweight','demi')
xlabel('\epsilon [m^2/s^3]')
ylabel('z [m]')
WindColorbar = colorbar('Location','EastOutside','Ticks',0:0.2:1,'TickLabels',round(linspace(0,maxwind,6)*10)/10 );
WindColorbar.Label.String = 'Wind spd [m/s]';
print -dpng Epsilon_windcolor.png

figure(2)
set(gca,'Ydir','reverse')
%plot(1e-5.*[5e-2 1e0].^-2,[5e-2 1e0],'k--')
%axis([1e-7 1e0 1e-4 1e1])
set(gca,'fontsize',16,'fontweight','demi')
xlabel('\epsilon [m^2/s^3]')
ylabel('z/H []')
WindColorbar = colorbar('Location','EastOutside','Ticks',0:0.2:1,'TickLabels',round(linspace(0,maxwind,6)*10)/10 );
WindColorbar.Label.String = 'Wind spd [m/s]';
print -dpng Epsilon_windcolor_NDdepth.png

figure(3)
set(gca,'Ydir','reverse')
%plot(1e-5.*[5e-2 1e0].^-2,[5e-2 1e0],'k--')
%axis([1e-7 1e0 1e-4 1e1])
set(gca,'fontsize',16,'fontweight','demi')
xlabel('\epsilon H / F []')
ylabel('z/H []')
WindColorbar = colorbar('Location','EastOutside','Ticks',0:0.2:1,'TickLabels',round(linspace(0,maxwind,6)*10)/10 );
WindColorbar.Label.String = 'Wind spd [m/s]';
print -dpng Epsilon_windcolor_NDflux.png