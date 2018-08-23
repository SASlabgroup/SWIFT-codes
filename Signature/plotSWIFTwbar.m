% script to plot pcolors of mean vertical velocity (wbar) from SWIFT v4 data
% NB: the raw signature data must be read and processed first
%   (this will not work from telemetry)
%   J. Thomson, 4/2018
%               8/2018 editted to get for motion (wave steepness) correlation with wbar

clear all, close all

files = dir('./SWIFT*.mat');

for fi = 1:length(files), 
    
    fi
   
    load(files(fi).name),
    
    % initialize with NaNs
    HRwbar = NaN( length(SWIFT), 128);
    epsilon = NaN( length(SWIFT), 128 );
    wbar = NaN( length(SWIFT), 40 );
    ubar = NaN( length(SWIFT), 40 );
    vbar = NaN( length(SWIFT), 40 );
    
    clear t lat lon

    for i = 3:length(SWIFT),   
                    
        t(i) = SWIFT(i).time; 
        lat(i) = SWIFT(i).lat;
        lon(i) = SWIFT(i).lon;

        if isfield(SWIFT(i).signature.HRprofile,'wbar'),
            HRwbar(i,:) = SWIFT(i).signature.HRprofile.wbar; 
            HRz = SWIFT(i).signature.HRprofile.z;, 
            wbar(i,:) = SWIFT(i).signature.profile.wbar; 
            ubar(i,:) = SWIFT(i).signature.profile.east; 
            vbar(i,:) = SWIFT(i).signature.profile.north; 
            epsilon(i,:) = SWIFT(i).signature.HRprofile.tkedissipationrate_pp';
            z = SWIFT(i).signature.profile.z;, 
        else
            
        end        
    end
    
    %days = range(t); ,for ti = 1:days
            
    figure(1), clf
    pcolor(t,z,wbar')
    set(gca,'fontweight','demi','fontsize',18)
    shading flat, caxis([-0.1 0.1]), colorbar
    datetick
    ylabel('z [m]'), title(files(fi).name,'interpreter','none'), set(gca,'ydir','reverse')
    print('-dpng',[ files(fi).name(1:(end-4)) '_wbarpcolor.png'])
    
    figure(2), clf
    pcolor(t,HRz,HRwbar')
    set(gca,'fontweight','demi','fontsize',18)
    shading flat, caxis([-0.05 0.05]), colorbar
    datetick
    ylabel('z [m]'), title(files(fi).name,'interpreter','none'), set(gca,'ydir','reverse')
    print('-dpng',[ files(fi).name(1:(end-4)) '_HRwbarpcolor.png'])
    
    figure(3), clf
    pcolor(t,HRz,log10(epsilon'))
    set(gca,'fontweight','demi','fontsize',18)
    shading flat, caxis([-6 -3]), colorbar
    datetick
    ylabel('z [m]'), title(files(fi).name,'interpreter','none'), set(gca,'ydir','reverse')
    print('-dpng',[ files(fi).name(1:(end-4)) '_epsilonpcolor.png'])
    
    figure(4), clf
    subplot(1,2,1)
    plot(HRwbar,HRz)
    set(gca,'fontweight','demi','fontsize',18)
    ylabel('z [m]'), xlabel('w [m/s]')
    title(files(fi).name(1:8),'interpreter','none'), 
    set(gca,'ydir','reverse')
    axis([-0.01 0.01 0 5])
    subplot(1,2,2)
    semilogx(epsilon,HRz)
    set(gca,'fontweight','demi','fontsize',18)
    ylabel('z [m]'), xlabel('\epsilon [W/kg]')
    title(files(fi).name(1:8),'interpreter','none'), 
    set(gca,'ydir','reverse')
    axis([1e-7 1e-2 0 5 ])
    set(gca,'Xtick',[1e-7 1e-5 1e-3])
    print('-dpng',[ files(fi).name(1:(end-4)) '_HRprofiles.png'])
    
    figure(5),clf
    zarray = ones(size(ubar,1),1) * z;
    lonarray = lon' * ones(1,size(ubar,2));
    latarray = lat' * ones(1,size(ubar,2));
    quiver3(lonarray,latarray,zarray,ubar,vbar,wbar,1e-3)
    set(gca,'zdir','reverse')
    set(gca,'fontweight','demi','fontsize',18)
    xlabel('lon'),ylabel('lat')
    print('-dpng',[ files(fi).name(1:(end-4)) '_profiles.png'])


    figure(6), hold on
    plot([SWIFT.sigwaveheight]./([SWIFT.peakwaveperiod].^2),wbar,'k.')
    
end

xlabel('H_s / T_p^2'), ylabel('wbar [m/s]')
print('-dpng','wbar_vs_wavesteepness.png')