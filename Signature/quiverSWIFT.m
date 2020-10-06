function h = quiverSWIFT(colorfield, quiverscale);
% plot SWIFT current profiles with adjustments for drift
% ... and maybe for Stokes (to be implemented later)
%   for a given set of SWIFT files in a directory
%   (i.e., for a given mission/project/day)
%
%  h = quiverSWIFT(colorfield, quiverscale);
%
% where colorfield is string with the field name to use for the colors
% and quiverscale adjusts the arrow size (0.01 is recommended)
% and returns h as the handle to the figures
%
% J. Thomson, 9/2018
%   include surf drift as top vector
%   add a plan view with drift vector and lower layer
%   include drift vectors for SWIFTs without signature
%   include option to spoof wave glider structure (with ADCP) as signature
%   10/2020, enable GPS ref velocity (if already applied)
%           allow time as colorfield input

twolayerplot = false;

h(1) = figure(1); clf
h(2) = figure(2); clf
ax(1) = subplot(2,1,1); ax(2) = subplot(2,1,2);
if twolayerplot, h(3) = figure(3); clf, end

flist = dir('*SWIFT*.mat');

wd = pwd;
lastslash = find(wd=='/',1,'last') + 1;
wd = wd( lastslash : end );

for fi=1:length(flist),
    disp(flist(fi).name)
    load(flist(fi).name)
    clear u v w x y z color
    
    % spoof a waveglider to look like a v4 SWIFT
    if isfield(SWIFT,'ADCP')
        SWIFT = makeADCPbecomeSIG(SWIFT);
    else
    end
    
    for si=1:length(SWIFT),
        
        
        if isfield(SWIFT,'driftspd'),
            u(si,1) = SWIFT(si).driftspd * sind( SWIFT(si).driftdirT );
            v(si,1) = SWIFT(si).driftspd * cosd( SWIFT(si).driftdirT );
            w(si,1) = 0;
        else
            u(si,1) = NaN;
            v(si,1) = NaN;
            w(si,1) = NaN;
        end
        
        if isfield(SWIFT,'signature'),
            nc = length( SWIFT(si).signature.profile.east );  % number of cells
            lowerlayer = [round(nc/2):nc]; % define lower layer for plan view plots
            
            if isfield(SWIFT(si).signature.profile,'velreference') && all(SWIFT(si).signature.profile.velreference == 'GPS')
                disp('using GPS ref velocity (already included)')
                u(si,2:(nc+1)) = SWIFT(si).signature.profile.east' ;
                v(si,2:(nc+1)) = SWIFT(si).signature.profile.north' ;
                w(si,1:(nc+1)) = zeros( 1, nc+1 ) ;
            else
                disp('adding GPS ref velocity (for plotting only)')
                u(si,2:(nc+1)) = SWIFT(si).signature.profile.east'  + SWIFT(si).driftspd * sind( SWIFT(si).driftdirT ) .* ones( 1, nc );
                v(si,2:(nc+1)) = SWIFT(si).signature.profile.north' + SWIFT(si).driftspd * cosd( SWIFT(si).driftdirT ) .* ones( 1, nc );;
                w(si,1:(nc+1)) = zeros( 1, nc+1 ) ;
            end
            x(si,:) = SWIFT(si).lon * ones( 1, nc+1 );
            y(si,:) = SWIFT(si).lat * ones( 1,  nc+1 );
            z(si,:) = [0 SWIFT(si).signature.profile.z];
            
        else
            x(si,:) = SWIFT(si).lon;
            y(si,:) = SWIFT(si).lat;
            z(si,:) = 0;
            disp('no sig')
        end
        
        if max( getfield(SWIFT(si),colorfield) ) ~= 0,
            color(si) = max( getfield(SWIFT(si),colorfield) ); % use max incase of multiple values (i.e., 3 CTs)
        elseif min( getfield(SWIFT(si),colorfield) ) ~= 0,
            color(si) = min( getfield(SWIFT(si),colorfield) ); % use max incase of multiple values (i.e., 3 CTs)
        else
            color(si) = NaN;
        end
        
    end
    
    figure(1)
    quiver3(x,y,z,u,v,w,quiverscale,'k'), hold on
    scatter([SWIFT.lon],[SWIFT.lat],50,color,'filled'), 
    
    figure(2)
    axes(ax(1))
    scatter3(x(:),y(:),z(:),10,u(:),'filled'), hold on
    title('east velocity [m/s]'), caxis([-2 2]), colorbar
    axes(ax(2))
    scatter3(x(:),y(:),z(:),10,v(:),'filled'), hold on
    title('north velocity [m/s]'), caxis([-2 2]), colorbar
    
    if twolayerplot,
    figure(3)
    quiver(x(:,1),y(:,1),u(:,1),v(:,1),quiverscale,'k-'), hold on
    if isfield(SWIFT,'signature'),
        quiver(x(:,1),y(:,1),nanmean(u(:,lowerlayer),2),nanmean(v(:,lowerlayer),2),quiverscale,'r-'), hold on
    else
        quiver(x(1,1),y(1,1),0,0,quiverscale,'r-')
    end
    scatter([SWIFT.lon],[SWIFT.lat],50,color,'filled'),
    end
    
    clear x y z u v w
end


%%

figure(1)
xlabel('lon')
ylabel('lat')
zlabel('z [m]')
title(['SWIFT ' wd ' ' colorfield],'interp','none')
grid
%ratio = [1./abs(cosd(nanmean([SWIFT.lat]))),1,100];  % ratio of lat to lon distances at a given latitude
%daspect(ratio)
set(gca,'ZDir','reverse')
grid
cb1 = colorbar; 
cb1.Label.String = colorfield;
if colorfield(1:4) == 'time'
    cb1.TickLabels = datestr([SWIFT.time]);  
end
print('-dpng',[wd '_quiverSWIFT_' colorfield '.png'])

figure(2)
%ratio = [1./abs(cosd(nanmean([SWIFT.lat]))),1,100];  % ratio of lat to lon distances at a given latitude
axes(ax(1))
%daspect(ratio)
xlabel('lon')
ylabel('lat')
zlabel('z [m]')
set(gca,'ZDir','reverse')
colormap nawhimar
grid on
axes(ax(2))
%daspect(ratio)
xlabel('lon')
ylabel('lat')
zlabel('z [m]')
set(gca,'ZDir','reverse')
colormap nawhimar
grid on
hlink = linkprop(ax,{'CameraPosition','CameraUpVector'});
rotate3d on
print('-dpng',[wd '_curtainSWIFT.png'])

if twolayerplot
figure(3),
set(gca,'fontsize',16,'fontweight','demi')
xlabel('lon')
ylabel('lat')
grid
ratio = [1./abs(cosd(nanmean([SWIFT.lat]))),1,100];  % ratio of lat to lon distances at a given latitude
daspect(ratio)
legend('surface','lowerlayer','Location','Northwest')
cb3 = colorbar;
cb3.Label.String = colorfield;
if colorfield(1:4) == 'time'
    cb3.TickLabels = datestr([SWIFT.time]);  
end
print('-dpng',[wd '_twolayervectors_' colorfield '.png'])
end

end

%% makeADCPbecomeSIG
function SWIFT = makeADCPbecomeSIG(SWIFT);

for si=1:length(SWIFT),
    
    if any(~isnan(SWIFT(si).ADCP.currentspd)),
        si
        SWIFT(si).signature.profile.east = SWIFT(si).ADCP.currentspd' .* sind( SWIFT(si).ADCP.currentdirM' );
        SWIFT(si).signature.profile.north = SWIFT(si).ADCP.currentspd' .* cosd( SWIFT(si).ADCP.currentdirM' );
        SWIFT(si).signature.profile.z = SWIFT(si).ADCP.z;
        
        SWIFT(si).driftspd = SWIFT(si).ADCP.currentspd(1);
        SWIFT(si).driftdirT = SWIFT(si).ADCP.currentdirM(1);
        bad(si) = false;
    else
        bad(si) = true;
    end
    
end

SWIFT(bad) = [];

end