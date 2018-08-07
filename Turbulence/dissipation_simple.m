function [tke, epsilon, residual, A, Aerror, N, Nerror] = dissipation_simple(v, z, disspts, plots, deltar); 
% function to estimate dissipation rate [m^2/s^3] from velocity profiles
% using subroutine structure function (Wiles et al 2006)
% and a specificied window length (in points)
%
%   [tke epsilon residual A Aerror N Nerror fitstats] = dissipation(v, z, disspts, plots, deltar); 
%
% where velocity is [bins x time] and z is the [1xbins] array of alongbeam locations 
%   disspts is the number of points to using in windows, recommend setting equal to number of velocity obs
%   plots is binary flag for plotting the structure function and fits
%   and delta r is [1 x bins] offset for SWIFT motion (tilting and bobbing)
%
%
% J. Thomson, 6/2010, 
%   revs: 9/2010 (allow data gaps as NaNs ) 
%         5/2011 (robust fit, noise tracking)
%         7/2011 (limit length scale to half of depth)
%         9/2011 (use only forward differencing, r>0)
%         4/2012 (use standard m^2/s^3 units)
%         4/2012 (back to double-sided differencing, |r| )
%         4/2012 (include input arguement to correct r for SWIFT tilting)
%         2/2017 limit the length scales by 6 bins, rather than half of depth
%         9/2017 back to simple fitting as mean of compensated str func
%

% constants
Cvsq = 2.1;

% bins and points
[bins, pts ] = size(v);

% window overlap, only matters if disspts < pts
overlap = 2;  % 2 gives 50% overlap, 1 gives no overlap

% legnth
if disspts<pts,
    lengthresults = floor(pts/(disspts/overlap));
elseif disspts>=pts,
    lengthresults = 1;
else return
end

% intialize results
tke = NaN ( [length(z) lengthresults] ); 
epsilon = NaN( [length(z) lengthresults]  ); 
A = NaN( [length(z) lengthresults]  ); 
Aerror = NaN( [length(z) lengthresults]  ); 
N = NaN( [length(z) lengthresults]  ); 
Nerror = NaN( [length(z) lengthresults]  ); 
residual = NaN( [length(z) lengthresults] );
fitstats = NaN( [length(z) lengthresults] );


for i = [ (disspts/2) : disspts/overlap : (pts-disspts/2) ],
    
    if plots==1,
    clf
    cmap = colormap;
    else 
    end
    
    % indexing
    ept = i/(disspts/overlap);
    vpts = [(i-disspts/2+1):(i+disspts/2)];
    
    % estimate tke
    tke(:,ept) = 0.5 * (nanstd( v(:,vpts)' ).^2)';  
    
    % estimate structure function
    [D r] = structureFunction(v(:,vpts), z);
    
    % fit structure function to A r^2/3
    for j=1:length(z),
        
        % need to limit r values used to be within internial subrange
            % smaller is better, but must have a least 6 points 
            maxr = 6*median(diff(z));
            % other ad hoc limit is proportion of depth
                % maxr = max(z) ./ 2;
            % alternate limit is distanace to boundary
                % maxr = min( abs(z(j) - max(z)), z(j) );
        
            % option for double sided fit using abs(r)
            r = abs(r);             
            
        % identify points for fitting, option to exclude r == 0 
        goodpts = ~isnan( D(j,:) )   &   r(j,:)< maxr  & r(j,:) >= 0;

        % fit structure to r^2/3
        if sum(goodpts)>2, 
             %warning('off','stats:statrobustfit:IterationLimit')
             %[fit stats] = robustfit(r(j,goodpts).^(2/3), D(j,goodpts)); 
             A(j,ept) = nanmean( r(j,goodpts).^(-2/3) .* D(j,goodpts) );
             Aerror(j,ept) = nanstd( r(j,goodpts).^(-2/3) .* D(j,goodpts) );
             %A(j,ept) = fit(2); 
             %N(j,ept) = fit(1);
             %fitstats(j,ept) = stats;
             %residual(j,ept) = stats.s;  %rmse
             %Aerror(j,ept) = stats.se(2);
             %Nerror(j,ept) = stats.se(1);

            % adjust for tilting
            if A(j,ept)>0 ,
                       
               % compensate for tilting... the overlaping cells reduces r 
               rnew(j,:) = r(j,:) - deltar(j);
               
               % determine noise intercept after correction
               newfit = polyfit(real(rnew(j,goodpts).^(2/3)),A(j,ept).*r(j,goodpts).^(2/3) + N(j,ept),1);
               N(j,ept) = newfit(2);
                 
               disp(N(j,ept))
               % show fit, if plog flag set to true
               if plots==1,
               Dplot = plot( real(rnew(j,goodpts).^(2/3)), D(j,goodpts),'.', real(rnew(j,goodpts).^(2/3)), A(j,ept).*r(j,goodpts).^(2/3) + N(j,ept),'--','color',cmap(round(j./length(z)*64),:),'markersize',14,'linewidth',1.5);, 
               drawnow, hold on
                if j==length(z),
                   set(gca,'FontSize',14,'FontWeight','demi'),
                   Dplot = gca;
                   axis([0 .6 0 2e-2])   % axis([0 .6 0 2e-2])
                   xlabel('(r-\Delta r)^{2/3}'), ylabel('D(z,r,) [m^2/s^2]'), 
                   pause(.5)
                else
                end
               else
               end
               
            else
            end

        else
        end
        
    end
    
end


% dissipation rate [m^2/s^3], switched from W/m^3 on 4/6/2012
posA = find(A>0);
    %rho = 1024;
epsilon(posA) = ( A(posA) ./ Cvsq ).^(3/2);  % m^2/s^3

