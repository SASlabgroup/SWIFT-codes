function h = mapSWIFT(colorfield);
% make a map of SWIFT drift vectors
%   for a given set of SWIFT files in a directory
%   (i.e., for a given mission/project/day)
% color the drift vectors by the fieldcolor input
%   such as temperature, salinity, or even just time
%
%  h = mapSWIFT(colorfield);
%
% where colorfield is string with the field name to use for the colors
% and returns h as the handle to the figure
%
% J. Thomson, 9/2018

h = figure; clf

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
                color(si) = NaN;
            end
        end
            
            h = scatter([SWIFT.lon],[SWIFT.lat],60,color,'filled'); 
            
            hold on
            
            u = [SWIFT.driftspd] .* sind([SWIFT.driftdirT]);
            v = [SWIFT.driftspd] .* cosd([SWIFT.driftdirT]);
            
            quiver([SWIFT.lon],[SWIFT.lat],u,v,.5,'k-');
            
        else,
            
            disp([colorfield ' not found in SWIFT data structure'])
            
        end
        
end
   
set(gca,'color',[.8 .8 .8],'Fontsize',16,'fontweight','demi')
title([wd ' ' colorfield ],'interp','none')
colorbar
xlabel('lon')
ylabel('lat')
grid
if abs(nanmean([SWIFT.lat]))<90 && abs(nanmean([SWIFT.lat]))>0,
ratio = [1./abs(cosd(nanmean([SWIFT.lat]))),1,1];  % ratio of lat to lon distances at a given latitude
daspect(ratio)
end
print('-dpng',[wd colorfield '_map.png']) 