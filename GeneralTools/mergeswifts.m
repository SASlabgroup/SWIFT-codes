% script to load and plot multiple SWIFT files/structures
% and merge (optional)

clear all, close all

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
    clear epsilon magprofile
    bad = [];
    for ai = 1:length(SWIFT)
        if ~isnan(SWIFT(ai).uplooking.tkedissipationrate),
            epsilon(:,ai) = SWIFT(ai).uplooking.tkedissipationrate;
            epsilon(:,ai) = NaN;
            magprofile(:,ai) = NaN;
        elseif isfield(SWIFT(ai).signature.HRprofile,'z'),
            if ~isempty( SWIFT(ai).signature.profile.z ),
                epsilon(:,ai) = SWIFT(ai).signature.HRprofile.tkedissipationrate;
                magprofile(:,ai) = sqrt( SWIFT(ai).signature.profile.east.^2 + SWIFT(ai).signature.profile.north.^2 ) ; hold on
            else
                epsilon(:,ai) = NaN;
                magprofile(:,ai) = NaN;
            end
        else
                epsilon(:,ai) = NaN;
                magprofile(:,ai) = NaN;
        end
    end
    
    
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
% GENERIC COAST:
%ax = axis;
%load coast
%plot(long,lat,'k')
%axis(ax);
%colorbar

% INNER SHELF
hold on
load('/Users/jthomson/Dropbox/InnerShelfDRI/MooringPlanning/Colosi/G200.mat'),
patch(GRID.patch.X,GRID.patch.Y,[.5 .5 .5]);
%colorbar
%axis([-120.7182 -120.6318   34.8346   34.9715])
axis equal
axis([-120.9 -120.5   34.7   35.2])

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