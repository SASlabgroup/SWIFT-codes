function h = TSscatterSWIFT( colorfield, seawaterflag );
% fucntion for T-S diagrams from SWIFT sturctures
% loading all files from a directory with results from a particular mission
% color the points by the fieldcolor input, such as time or wind speed
%
%    h = TSscatterSWIFT( colorfield, seawaterflag );
%
% where colorfield is string with the field name to use for the colors
% and seawaterflag is a logical (true or false) trigger to use the seawater
% routines for desnity and freezing lines 
% *** sw routines must be in user's Matlab path, as they are not included in SWIFT codes **
%
% functions returns h as the handle to the figure
%
% J. Thomson 9/2018
%   M. Smith added desity and freezing lines using calls to seawater
%   routines (UNESCO / Phil Morgan) and colors by depth
%

multdepths = false; % initialize

h = figure; clf

flist = dir('*SWIFT*.mat');

wd = pwd;
lastslash = find(wd=='/',1,'last') + 1;
wd = wd( lastslash : end );


for fi = 1:length(flist),
    
    load(flist(fi).name)
    clear color
    
    if isfield(SWIFT,'salinity') && isfield(SWIFT,'watertemp') && ~isempty([SWIFT]),
        
        for si = 1:length(SWIFT),
            color(si) = max( getfield(SWIFT(si),colorfield) ); % use max incase of multiple values 
            SWIFT(si).salinity( SWIFT(si).salinity == 0 ) = NaN;   
        end
        
        nCT = length(SWIFT(1).salinity); % number of CT payloads
        
        if nCT == 1
            scatter([SWIFT.salinity],[SWIFT.watertemp],[],color,'o','fill')
            hold on
        elseif nCT == 3
            multdepths = true;
            Tarray = reshape( [SWIFT.watertemp],[],length(SWIFT) )';
            Sarray = reshape( [SWIFT.salinity],[],length(SWIFT) )';
            s1 = scatter(Sarray(:,1),Tarray(:,1),[],color,'s','fill'); hold on
            s2 = scatter(Sarray(:,2),Tarray(:,2),[],color,'o','fill');
            s3 = scatter(Sarray(:,3),Tarray(:,3),[],color,'d','fill');
            CTlabel(1,:) = [ num2str( SWIFT(1).CTdepth(1),2 ) ' m'];
            CTlabel(2,:) = [ num2str( SWIFT(1).CTdepth(2),2 ) ' m'];
            CTlabel(3,:) = [ num2str( SWIFT(1).CTdepth(3),3 ) ' m'];
        end
        
    end
    
end

%axis([ 25 31 -2 4])
title(['SWIFT ' wd ', color is ' colorfield ],'interp','none')
ylabel('Temp [C]')
xlabel('Salinity [PSU]')
grid on;box on
clims = caxis; % store the color axis (automatic from the range of values in the colorfield input)

if seawaterflag == true,

    %freezing point line
    xlims = get(gca,'Xlim');
    salspace = xlims(1):.01:xlims(2);
    fp = sw_fp(salspace,191);    
    plot(salspace,fp,'k--')
    
    %density contours
    ylims = get(gca,'Ylim');
    tempspace = ylims(1):.01:ylims(2);
    [salgrid,tempgrid] =meshgrid(salspace,tempspace);
    densgrid = sw_dens(salgrid,tempgrid,191);
    contour(salgrid,tempgrid,densgrid,'LineColor',[.4 .4 .4])
    
    caxis(clims) % restore the color limits (countour resets them)
    
else
end

if multdepths && ~seawaterflag
    legend([s1 s2 s3],CTlabel,'location','northwest')
elseif multdepths && seawaterflag
    legend([s1 s2 s3],CTlabel,'location','northwest')
    %legend([s1 s2 s3],'0.1 m','0.5 m','1.2 m','freezing','isopyncnals','location','northwest')
else
end

shg
print('-dpng',[wd  '_TSscatter_' colorfield '.png'])

