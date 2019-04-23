% script to load and plot multiple SWIFT files/structures
% and merge (optional)

clear all, close all

sigHRzoffset = 0; % first HR bin should be at 0.3

%pwd

flist = dir('SWIFT*.mat');

counter = 0;

for fi = 1:length(flist),
    
    load(flist(fi).name)
    
    %allSWIFT( counter + [1:length(SWIFT)] ) = SWIFT;
    %counter = length(allSWIFT);
    
    %% winds and waves
    figure(1),
    subplot(2,1,1)
    plot([SWIFT.time],[SWIFT.sigwaveheight],'kx'), hold on
    subplot(2,1,2)
    plot([SWIFT.time],[SWIFT.windspd],'kx'), hold on
    
    
    %% dissipation
    clear epsilon magprofile z
    bad = [];
    for ai = 1:length(SWIFT)
        if isfield(SWIFT(ai),'uplooking') && ~isnan(SWIFT(ai).uplooking.tkedissipationrate),
            epsilon(:,ai) = SWIFT(ai).uplooking.tkedissipationrate;
            z(:,ai) = SWIFT(ai).uplooking.z;
            magprofile(:,ai) = NaN;
        elseif isfield(SWIFT(ai).signature.HRprofile,'z'),
            if ~isempty( SWIFT(ai).signature.profile.z ),
                epsilon(:,ai) = SWIFT(ai).signature.HRprofile.tkedissipationrate;
                z(:,ai) = SWIFT(ai).signature.HRprofile.z + sigHRzoffset;
                magprofile(:,ai) = sqrt( SWIFT(ai).signature.profile.east.^2 + SWIFT(ai).signature.profile.north.^2 ) ; hold on
            else
                epsilon(:,ai) = NaN;
                z(:,ai) = NaN;
                magprofile(:,ai) = NaN;
            end
        else
                epsilon(:,ai) = NaN;
                z(:,ai) = NaN;
                magprofile(:,ai) = NaN;
        end
    end
    
    % map, colored by various fields
    figure(2),
    if nansum(epsilon)~=0,
        scatter([SWIFT.lon],[SWIFT.lat],20,log10(max(epsilon)),'filled'), hold on
        %scatter([SWIFT.lon],[SWIFT.lat],20,log10(max(abs(gradient(magprofile)))),'filled'), hold on
        %scatter([SWIFT.lon],[SWIFT.lat],20,mean(magprofile(1:10,:)) - mean(magprofile(20:30,:)),'filled'), hold on
        %scatter([SWIFT.lon],[SWIFT.lat],20,[SWIFT.driftspd]), hold on
    else
       %plot([SWIFT.lon],[SWIFT.lat],'b.'), hold on
    end
    
    %% wind stress
    figure(3)
    if isfield(SWIFT,'windustar'),
    plot(1.3*[SWIFT.windspd],[SWIFT.windustar],'kx'), hold on
    else 
    end
    axis([0 15 0 .8])
    
    %% dissipation profiles
    figure(4), 
       if nansum(epsilon)~=0,
           loglog(epsilon,z,'k-'), hold on
           if length(epsilon) == 128, % v4 results
            loglog(epsilon,z,'b-'), hold on
           else
           end
    else
    end
    
end

%% clean up plots

figure(1)
subplot(2,1,1)        
set(gca,'FontSize',16,'fontweight','demi')
datetick('x','ddmmm')
set(gca,'YLim',[0 5])
ylabel('Waves, H_s [m]')

subplot(2,1,2)
set(gca,'FontSize',16,'fontweight','demi')
datetick('x','ddmmm')
set(gca,'YLim',[0 15])
ylabel('Wind, U_1 [m/s]')


figure(2),
hold on, colorbar, axis equal

% GENERIC COAST:
ax = axis;
load coast
plot(long,lat,'k')
axis(ax);
colorbar

% INNER SHELF map specifics
%load('/Users/jthomson/Dropbox/Projects/InnerShelfDRI/MooringPlanning/Colosi/G200.mat'),
%patch(GRID.patch.X,GRID.patch.Y,[.5 .5 .5]);
%axis([-120.9 -120.5   34.7   35.2]) %axis([-120.7182 -120.6318   34.8346   34.9715])


figure(3), 
set(gca,'FontSize',16,'fontweight','demi')
xlabel('Wind Speed, U_{10} [m/s]'),
ylabel('Wind friction velocity, u_* [m/s]')
dw = 1;
windbins = [0:dw:20];

a = 1.4e-3;
b = 1e-6;
Cd = a  +  b * windbins.^2; % ad hoc version of Smith, 1980 
ustarcurve = ( Cd .* windbins.^2 ).^.5;

plot(windbins,ustarcurve,'m','linewidth',2)

figure(4),
set(gca,'YDir','reverse')
xlabel('\epsilon [m^2/s^3')
ylabel('z [m]')