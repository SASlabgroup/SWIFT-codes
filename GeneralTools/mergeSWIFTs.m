% script to load and plot multiple SWIFT files/structures
% and merge (optional)

clear all, close all

plots = false;
makeallSWIFT = true; 
sigHRzoffset = 0; % first HR bin should be at 0.3
useonboardepsilon = true; % binary flag
onboardcorrection = 1/8;

%pwd

flist = dir('*SWIFT*.mat');

counter = 0;

for fi = 1:length(flist),
   
    load(flist(fi).name)
    
    if makeallSWIFT
        allSWIFT( counter + [1:length(SWIFT)] ) = SWIFT;
        counter = length(allSWIFT);
    end
    
    if plots, 
    
    %% winds and waves
    figure(1),
    if isfield(SWIFT,'windspd')
        subplot(4,1,1)
        plot([SWIFT.time],[SWIFT.windspd],'bx'), hold on
        subplot(4,1,4)
        plot([SWIFT.time],[SWIFT.winddirT],'bx'), hold on
    end
    if isfield(SWIFT,'sigwaveheight')
    subplot(4,1,2)
    plot([SWIFT.time],[SWIFT.sigwaveheight],'g+'), hold on
    subplot(4,1,3)
    plot([SWIFT.time],[SWIFT.peakwaveperiod],'g+'), hold on
    subplot(4,1,4)
    plot([SWIFT.time],[SWIFT.peakwavedirT],'g+'), hold on
    end
    
    %% mean square slope
    [mss, mssnorm] = SWIFTmss( SWIFT );
    
    %% temps and salinities
    figure(2),
    subplot(3,1,1)
    if isfield(SWIFT,'airtemp')
        plot([SWIFT.time],[SWIFT.airtemp],'gx'), hold on
    end
    subplot(3,1,2)
    for si=1:length(SWIFT)
        plot([SWIFT(si).time],[median(SWIFT(si).watertemp)],'bx'), hold on
    end
    subplot(3,1,3)
    for si=1:length(SWIFT)
        plot([SWIFT(si).time],[median(SWIFT(si).salinity)],'bx'), hold on
    end
    
    
    %% dissipation
    clear epsilon magprofile z
    figure(5), 
    cmap = colormap; 
 
    for ai = 1:length(SWIFT),
            cindex = floor( 64 * mssnorm(ai) ./ 0.05); 
        if isfield(SWIFT(ai),'uplooking') && any(~isnan(SWIFT(ai).uplooking.tkedissipationrate)),
            epsilon(:,ai) = SWIFT(ai).uplooking.tkedissipationrate;
            loglog(SWIFT(ai).uplooking.tkedissipationrate,SWIFT(ai).uplooking.z,'-','color',cmap(cindex,:)), hold on
            z(:,ai) = SWIFT(ai).uplooking.z;
            magprofile(:,ai) = NaN;
        elseif isfield(SWIFT(ai),'signature'),
            if ~isempty( SWIFT(ai).signature.profile.z ),
                if useonboardepsilon,
                    epsilon(:,ai) = SWIFT(ai).signature.HRprofile.tkedissipationrate_onboard .* onboardcorrection;
                    loglog(SWIFT(ai).signature.HRprofile.tkedissipationrate_onboard .* onboardcorrection, SWIFT(ai).signature.HRprofile.z,'-','color',cmap(cindex,:)), hold on,
                else
                    epsilon(:,ai) = SWIFT(ai).signature.HRprofile.tkedissipationrate;
                    loglog(SWIFT(ai).signature.HRprofile.tkedissipationrate, SWIFT(ai).signature.HRprofile.z,'-','color',cmap(cindex,:)), hold on,
                end
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
    drawnow
    
    % map, colored by various fields
    figure(3),
    if ~isempty(SWIFT),%nansum(epsilon)~=0,
        %scatter([SWIFT.lon],[SWIFT.lat],20,log10(max(epsilon)),'filled'), hold on
        %scatter([SWIFT.lon],[SWIFT.lat],20,log10(max(abs(gradient(magprofile)))),'filled'), hold on
        %scatter([SWIFT.lon],[SWIFT.lat],20,mean(magprofile(1:10,:)) - mean(magprofile(20:30,:)),'filled'), hold on
        scatter([SWIFT.lon],[SWIFT.lat],20,[SWIFT.driftspd]), hold on, title('drift speed')
    else
        %plot([SWIFT.lon],[SWIFT.lat],'b.'), hold on
    end
    
    %% wind stress
    figure(4)
    if isfield(SWIFT,'windustar'),
        plot(1.3*[SWIFT.windspd],[SWIFT.windustar],'kx'), hold on
    else
    end
    axis([0 15 0 .8])
   
    end
    
end

%% save allSWIFT
if makeallSWIFT
    SWIFT = allSWIFT;
    save('allSWIFT.mat','SWIFT')
end

%% clean up plots
if plots
    
figure(1)
subplot(4,1,1)
title('SWIFT')
set(gca,'FontSize',14,'fontweight','demi')
datetick('x','ddmmm')
set(gca,'YLim',[0 15])
ylabel('Wind, U_1 [m/s]')

subplot(4,1,2)
set(gca,'FontSize',14,'fontweight','demi')
datetick('x','ddmmm')
set(gca,'YLim',[0 5])
ylabel('Waves, H_s [m]')

subplot(4,1,3)
set(gca,'FontSize',14,'fontweight','demi')
datetick('x','ddmmm')
set(gca,'YLim',[0 20])
ylabel('Waves, T_p [s]')

subplot(4,1,4)
set(gca,'FontSize',14,'fontweight','demi')
datetick('x','ddmmm')
set(gca,'YLim',[0 360],'YTick',[0 180 360])
ylabel('Dirs [dir T]')

print -dpng windsandwaves.png

figure(2)
subplot(3,1,1)
set(gca,'FontSize',16,'fontweight','demi')
datetick('x','ddmmm')
%set(gca,'YLim',[0 5])
ylabel('Air Temp [C]')
subplot(3,1,2)
set(gca,'FontSize',16,'fontweight','demi')
datetick('x','ddmmm')
%set(gca,'YLim',[0 15])
ylabel('Water Temp [C]')
subplot(3,1,3)
set(gca,'FontSize',16,'fontweight','demi')
datetick('x','ddmmm')
%set(gca,'YLim',[0 15])
ylabel('Salinity [C]')
print -dpng tempsandsalinities.png

figure(3),
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
print -dpng SWIFtmap.png

figure(4),
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
print -dpng windfrictionvel.png

figure(5),
set(gca,'YDir','reverse')
xlabel('\epsilon [m^2/s^3')
ylabel('z [m]')
print -dpng epsilonprofiles.png

end