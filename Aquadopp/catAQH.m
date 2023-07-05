function aqh = catAQH(AQH)
%Produces summary plot of burst-averaged signature data stored in 'SIG'
%       also returns concatenated data
plotaqh = true;

aqh.time = [AQH.time];    
aqh.hrz = AQH(round(end/2)).HRprofile.z;
aqh.hrw = NaN(length(aqh.hrz),length(aqh.time));
aqh.hrwvar = aqh.hrw;
aqh.hrcorr = aqh.hrw;
aqh.hramp = aqh.hrw;
aqh.eps_struct = aqh.hrw;
aqh.struct_slope = aqh.hrw;
aqh.pitchvar = NaN(1,length(aqh.time));
for it = 1:length(aqh.time)
    %HR
    aqh.hrw(:,it) = AQH(it).HRprofile.w;
    aqh.hrwvar(:,it) = AQH(it).HRprofile.werr;
    aqh.hrcorr(:,it) = AQH(it).QC.hrcorr;
    aqh.hramp(:,it) = AQH(it).QC.hramp;
    aqh.eps_struct(:,it) = AQH(it).HRprofile.eps_structHP;
    aqh.struct_slope(:,it) = AQH(it).QC.slopeHP;
    aqh.pitchvar(it) = AQH(it).QC.pitchvar;
end

% Plot        
if plotaqh && length(aqh.time)>1
    clear b
    figure('color','w')
    MP = get(0,'monitorposition');
    set(gcf,'outerposition',MP(1,:).*[1 1 1 1]);
    h = tight_subplot(6,1);

    %Pitch + Roll
    axes(h(1))
    b(1) = bar(aqh.time,sqrt(aqh.pitchvar));
    b(1).FaceColor = 'r';
    set(b,'EdgeColor',rgb('grey'))
    ylabel('\sigma_{\phi} (^{\circ})');title('Pitch Variance')
    c = colorbar;c.Visible = 'off';
    xlim([min(aqh.time) max(aqh.time)])
    ylim([0 mean(sqrt(aqh.pitchvar),'omitnan') + 2*std(sqrt(aqh.pitchvar),'omitnan')])
    datetick('x','KeepLimits')

    %Amplitude
    axes(h(2))
    pcolor(aqh.time,-aqh.hrz,aqh.hramp);shading flat
    caxis([80 150])
    ylabel('Depth (m)');cmocean('thermal');title('Amplitude')
    c = colorbar;c.Label.String = 'A [counts]';
    xlim([min(aqh.time) max(aqh.time)])
    datetick('x','KeepLimits')

    %Correlation
    axes(h(3))
    pcolor(aqh.time,-aqh.hrz,aqh.hrcorr);shading flat
    caxis([0 100])
    ylabel('Depth (m)');cmocean('curl');title('Correlation')
    c = colorbar;c.Label.String = 'C [%]';
    xlim([min(aqh.time) max(aqh.time)])
    datetick('x','KeepLimits')

    %Velocity
    axes(h(4))
    pcolor(aqh.time,-aqh.hrz,aqh.hrw);shading flat
    caxis([-0.025 0.025])
    ylabel('Depth (m)');cmocean('balance');title('W_{HR}')
    c = colorbar;c.Label.String = 'ms^{-1}';
    xlim([min(aqh.time) max(aqh.time)])
    datetick('x','KeepLimits')

    % Velocity Variance
    % pcolor(aqh.time,-aqh.hrz,aqh.hrwvar);shading flat
    % caxis([0 0.03]);
    % ylabel('Depth (m)');title('\sigma_W_{HR}')
    % c = colorbar;c.Label.String = 'ms^{-1}';
    % xlim([min(aqh.time) max(aqh.time)])
    % datetick('x','KeepLimits')

    %Dissipation Rate
    axes(h(5))
    pcolor(aqh.time,-aqh.hrz,log10(aqh.eps_struct));shading flat
    caxis([-7.5 -4.5]);
    ylabel('Depth (m)');title('SF \epsilon')
    c = colorbar;c.Label.String = 'log_{10}(m^3s^{-2})';
    xlim([min(aqh.time) max(aqh.time)])
    datetick('x','KeepLimits')

    % SF Slope
    axes(h(6))
    pcolor(aqh.time,-aqh.hrz,aqh.struct_slope);shading flat
    caxis([0 2*2/3]);
    ylabel('Depth (m)');title('SF Slope')
    c = colorbar;c.Label.String = 'D \propto r^n';
    xlim([min(aqh.time) max(aqh.time)])
    datetick('x','KeepLimits')
    cmocean('curl')

    h = findobj('Type','axes');
    h = flipud(h);
    set(h(1:end-1),'XTickLabel',[])
end

end