function h = quiverSWIFT(colorfield, quiverscale);
% plot SWIFT current profiles with adjustments for drift
% ... and maybe for Stokes (to be implemented later)
%   for a given set of SWIFT files in a directory
%   (i.e., for a given mission/project/day)

%  h = quiverSWIFT(colorfield, quiverscale);
%
% where colorfield is string with the field name to use for the colors
% and quiverscale adjusts the arrow size (0.01 is recommended)
% and returns h as the handle to the figures
%
% J. Thomson, 9/2018

h(1) = figure(1); clf
h(2) = figure(2); clf
ax(1) = subplot(2,1,1); ax(2) = subplot(2,1,2);

flist = dir('*SWIFT*.mat');

wd = pwd;
lastslash = find(wd=='/',1,'last') + 1;
wd = wd( lastslash : end );

for fi=1:length(flist),
    disp(flist(fi).name)
    load(flist(fi).name)
    clear u v w x y z color
    
    if isfield(SWIFT,'signature'),
        
        for si=1:length(SWIFT),
            
            nc = length( SWIFT(si).signature.profile.east );  % number of cells
            
            u(si,:) = SWIFT(si).signature.profile.east'  + SWIFT(si).driftspd * sind( SWIFT(si).driftdirT ) .* ones( 1, nc );
            v(si,:) = SWIFT(si).signature.profile.north' + SWIFT(si).driftspd * cosd( SWIFT(si).driftdirT ) .* ones( 1, nc );;
            w(si,:) = zeros( 1, nc ) ;
            
            x(si,:) = SWIFT(si).lon * ones( 1, nc );
            y(si,:) = SWIFT(si).lat * ones( 1,  nc );
            z(si,:) = SWIFT(si).signature.profile.z;
            
            color(si) = max( getfield(SWIFT(si),colorfield) );
            
        end
        
        figure(1)
        quiver3(x,y,z,u,v,w,quiverscale,'k'), hold on
        scatter([SWIFT.lon],[SWIFT.lat],50,color,'filled'), colorbar
        
        figure(2)
        axes(ax(1))
        scatter3(x(:),y(:),z(:),10,u(:),'filled'), hold on
        title('east velocity [m/s]'), caxis([-.5 .5]), colorbar
        axes(ax(2))
        scatter3(x(:),y(:),z(:),10,v(:),'filled'), hold on
        title('north velocity [m/s]'), caxis([-.5 .5]), colorbar
        
    else
        disp('No signature data.  Someone should expand this to work on AQD profiles too.')
    end
    
end


%% 

figure(1)
xlabel('lon')
ylabel('lat')
zlabel('z [m]')
title(['SWIFT ' wd ' ' colorfield])
grid
%ratio = [1./abs(cosd(nanmean([SWIFT.lat]))),1,100];  % ratio of lat to lon distances at a given latitude
%daspect(ratio)
set(gca,'ZDir','reverse')
grid
print('-dpng',[wd '_quiverSWIFT_' colorfield '.png'])

figure(2)
%ratio = [1./abs(cosd(nanmean([SWIFT.lat]))),1,100];  % ratio of lat to lon distances at a given latitude
axes(ax(1))
%daspect(ratio)
xlabel('lon')
ylabel('lat')
zlabel('z [m]')
set(gca,'ZDir','reverse')
grid
axes(ax(2))
%daspect(ratio)
xlabel('lon')
ylabel('lat')
zlabel('z [m]')
set(gca,'ZDir','reverse')
grid
hlink = linkprop(ax,{'CameraPosition','CameraUpVector'})
rotate3d on
print('-dpng',[wd '_curtainSWIFT.png'])

end