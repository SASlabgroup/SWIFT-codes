function [tke, epsilon, residual, A, Aerror, N, Nerror] = dissipation(v, z, disspts, plots, deltar);
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
%         9/2017 return to robustfit (instead of simple compensated average)
%         1/2018    play with length limits
%         1/2018    remove the overlapping (but leave disspts as dummy input, for backwards compatibility)

% constants
Cvsq = 2.1;

% bins and points
[bins, pts ] = size(v);


% intialize results
tke = NaN ( [ length(z) 1 ] );
epsilon = NaN( [ length(z) 1 ]  );
A = NaN( [length(z) 1 ]   );
Aerror = NaN( [ length(z) 1 ]  );
N = NaN( [ length(z) 1 ]  );
Nerror = NaN( [ length(z) 1 ]  );
residual = NaN( [ length(z) 1 ] );
fitstats = NaN( [ length(z) 1 ] );


if plots==1,
    clf
    cmap = colormap;
else
end


% estimate tke
tke = 0.5 * ( nanstd( v' ).^2)';

% estimate structure function
[D r] = structureFunction(v, z);

% fit structure function to A r^2/3
for j=fliplr(1:length(z)),%[1 2 5 10 15 20:20:120],%round(linspace(1,length(z),10)),
    
    %% need to limit r values used to be within internial subrange
    
    % scales can't be too big, but must have a least 6 points
    maxr = 5*median(diff(z));

    % smallest r's can be noise contaminated
    minr = 1*median(diff(z));

    % option for double sided fit using abs(r)
    r = abs(r);

    %% fit structure to r^2/3
    
    % identify points for fitting,
    goodpts = find( ~isnan( D(j,:) )  &  r(j,:)< maxr  &  r(j,:) >= minr);
     
    if length(goodpts)>2,
        %warning('off','stats:statrobustfit:IterationLimit')
        [fit stats] = robustfit(r(j,goodpts).^(2/3), D(j,goodpts));
        %A(j) = nanmean( r(j,goodpts).^(-2/3) .* D(j,goodpts) );
        %Aerror(j) = nanstd( r(j,goodpts).^(-2/3) .* D(j,goodpts) );
        A(j) = fit(2);
        N(j) = fit(1);
        %fitstats(j) = stats;
        %residual(j) = stats.s;  %rmse
        %Aerror(j) = stats.se(2);
        %Nerror(j) = stats.se(1);
        
        
        % adjust for tilting
        if A(j)>0 ,
            
            % compensate for tilting... the overlaping cells reduces r
            rnew(j,:) = r(j,:) - deltar(j);
            
            % determine noise intercept after correction
            %newfit = polyfit(r(j,goodpts).^(2/3),A(j).*r(j,goodpts).^(2/3),1);
            %A(j) = newfit(1);
            %N(j) = newfit(2);
            
            % show fit, if plog flag set to true
            if plots==1,
                Dplot = plot( r(j,goodpts), D(j,goodpts),'.','color',cmap(round(j./length(z)*64),:),'markersize',14,'linewidth',1.5);
                hold on
                fitplot = plot( r(j,goodpts), A(j).*r(j,goodpts).^(2/3)+ N(j),'--','color',cmap(round(j./length(z)*64),:),'markersize',14,'linewidth',1.5);
                hold on
                if j==length(z),
                    set(gca,'FontSize',14,'FontWeight','demi'),
                    Dplot = gca;
                    axis([0 inf 0 inf])   % axis([0 .6 0 2e-2])
                    xlabel('r [m]'), ylabel('D(z,r,) [m^2/s^2]'),
                else
                end
            else
            end
            
        else
        end
        
    else
    end
    
end

% dissipation rate [m^2/s^3], switched from W/m^3 on 4/6/2012
posA = find(A>0);
%rho = 1024;
epsilon(posA) = ( A(posA) ./ Cvsq ).^(3/2);  % m^2/s^3

if plots==1,
    set(gca,'fontsize',16,'fontweight','demi')
    cb=colorbar('peer',gca,'EastOutside','YTickLabel',linspace(min(z),max(z),5),'Ytick',[0:.25:1],'ydir','reverse');
    cb.Label.String='z [m]';
    title('Structure function fit colored by range bin')
    xlabel('r [m]')
    ylabel('D [m^/s^2]')
else
end


%figure, pcolor(D), title('D')
%figure, pcolor(r), title('r')
%figure, pcolor(repmat(z,128,1)), title('z')

