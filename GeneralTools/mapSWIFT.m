function h = mapSWIFT(colorfield,varargin);
% make a map of SWIFT drift vectors
%   for a given set of SWIFT files in a directory
%   (i.e., for a given mission/project/day)
% color the drift vectors by the fieldcolor input
%   such as temperature, salinity, or even just time
%
%  h = mapSWIFT(colorfield,cmap,cscale));
%
% where colorfield is string with the field name to use for the colors
% and cmap, cscale are optional inputs if plotting on top of bathy
%
% function returns h as the handle to the figure
%
% J. Thomson, 9/2018

newmap = false;

if isempty(varargin)
    figure, clf
    newmap = true;
elseif length(varargin)==2
    cmap = varargin{1};
    cscale = varargin{2};
    h = gcf;
else
    return
end

flist = dir('*SWIFT*.mat');

wd = pwd;
lastslash = find(wd=='/',1,'last') + 1;
wd = wd( lastslash : end );

for fi = 1:length(flist),
    
    load(flist(fi).name)
    clear color
    
    if isfield(SWIFT,colorfield) && ~isempty([SWIFT]),
        
        for si = 1:length(SWIFT),
            if max( getfield(SWIFT(si),colorfield) ) ~= 0,
                color(si) = max( getfield(SWIFT(si),colorfield) ); % use max incase of multiple values (i.e., 3 CTs)
            elseif min( getfield(SWIFT(si),colorfield) ) ~= 0,
                color(si) = min( getfield(SWIFT(si),colorfield) ); % use max incase of multiple values (i.e., 3 CTs)
            else
                color(si) = 0;
            end
            if ~newmap,
                cindex = round((color(si)-cscale(1))./(cscale(2)-cscale(1))*64)
                if ~isnan(cindex) && cindex>0 && cindex<65,
                    plot([SWIFT(si).lon],[SWIFT(si).lat],'.','markersize',12,'color',cmap(cindex,:)); hold on % version with bathy
                end
            end
        end
            
        if newmap
            h = scatter([SWIFT.lon],[SWIFT.lat],60,color','filled'); % version with no bathy          
            hold on
            u = [SWIFT.driftspd] .* sind([SWIFT.driftdirT]);
            v = [SWIFT.driftspd] .* cosd([SWIFT.driftdirT]);
            quiver([SWIFT.lon],[SWIFT.lat],u,v,.5,'k-');
        end
        
        else,
            
            disp([colorfield ' not found in SWIFT data structure'])
            
        end
        
end
   
set(gca,'color',[.8 .8 .8],'Fontsize',16,'fontweight','demi')
if newmap
    title([wd ' ' colorfield ],'interp','none')
    colorbar
else
    title([wd ' ' colorfield ', ' num2str(min(cscale)) ' to ' num2str(max(cscale)) ],'interp','none')
end
xlabel('lon')
ylabel('lat')
grid
if abs(nanmean([SWIFT.lat]))<90 && abs(nanmean([SWIFT.lat]))>0,
ratio = [1./abs(cosd(nanmean([SWIFT.lat]))),1,1];  % ratio of lat to lon distances at a given latitude
daspect(ratio)
end
print('-dpng',[wd colorfield '_map.png']) 