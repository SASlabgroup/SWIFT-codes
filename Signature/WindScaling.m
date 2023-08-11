% sig dissipation profiles by wind speed
%
% J. Thomson, Aug 2023

clear all

maxwind = 25;
U10factor = 1.5;

figure(1), clf

flist = dir('*reprocessedSIG*.mat');

for i = 1:length(flist);

load(flist(i).name)

if isfield(SWIFT,'signature')
    
    
    % Loop through timestamps
    for ai = 1:length(SWIFT)
        % If windspd value exist and are physical, use them to assign plot
        % color:
        cmap = colormap;
        if isfield(SWIFT,'windspd') && ~isnan(SWIFT(ai).windspd) &&... % check field exists and contains data
                SWIFT(ai).windspd > 0 && SWIFT(ai).windspd < 50            % check data is physical
            ci = ceil( U10factor * SWIFT(ai).windspd ./ maxwind * length(cmap) );
            if ci>length(cmap), ci = length(cmap); disp('wind exceeds color scale'), end
            thiscolor = cmap(ci,:);
        else
            thiscolor = [1 1 1];
        end 
        
        semilogx(SWIFT(ai).signature.HRprofile.tkedissipationrate,-SWIFT(ai).signature.HRprofile.z,'linewidth',1,'color',thiscolor);
        hold on
        
    end 
    
    xlabel('\epsilon [W/Kg]');
    ylabel('z [m]')

    if isfield(SWIFT,'windspd') &&  ~isnan(max([SWIFT.windspd]))
        WindColorbar = colorbar('Location','East','Ticks',0:0.2:1,'TickLabels',round(linspace(0,maxwind,6)*10)/10);
        WindColorbar.Label.String = 'Wind spd [m/s]';
    else
        
    end
end

end

%%
set(gca,'FontSize',16,'FontWeight','demi')
axis([1e-9 1e-3 -3 0])
