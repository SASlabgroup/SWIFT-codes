function fh = plotSIGburst(varargin)
%plotSIGburst plots the data from an aquadopp burst
%   Input can be the burst filename/filepath or the burst structure
%   i.e. burst = load(bfile);

if ischar(varargin{1})
    burst = load(bfile);
else
    burst = varargin{1};
end

[nping,nbin] = size(burst.VelocityData);
tilt = atand(sqrt(tand(burst.Pitch).^2 + tand(burst.Roll).^2));

fh = figure('color','w');
MP = get(0,'monitorposition');
set(gcf,'outerposition',MP(1,:).*[1 1 1 1]);

subplot(5,1,1)
plot(1:nping,burst.pitch,'k','LineWidth',2)
hold on
plot(1:nping,burst.roll,'color',rgb('grey'),'LineWidth',2)
plot(1:nping,tilt,'r','LineWidth',2)
plot(1:nping,zeros(1,nping),'--k')
plot(1:nping,-20*ones(1,nping),':k')
plot(1:nping,20*ones(1,nping),':k')
title('Orientation')
c = colorbar;c.Visible = 'off';
ylabel('\Theta [deg]')
l = legend('Pitch','Roll','Tilt');
l.Position(1:2) = c.Position(1:2);

subplot(5,1,2)
imagesc(1:nping,1:nbin,burst.AmplitudeData')
title('Amplitude')
cmocean('haline');caxis([75 175])
set(gca,'YDir','normal')
c = colorbar;c.Label.String = 'A [counts]';
ylabel('Bin #')

subplot(5,1,3)
imagesc(1:nping,1:nbin,burst.CorrelationData')
title('Correlation')
cmocean('thermal');caxis([50 100])
set(gca,'YDir','normal')
c = colorbar;c.Label.String = 'C [%]';
ylabel('Bin #')

subplot(5,1,4)
imagesc(1:nping,1:nbin,burst.VelocityData')
title('Velocity')
cmocean('balance');caxis([-0.5 0.5])
set(gca,'YDir','normal')
c = colorbar;c.Label.String = 'W [ms^{-1}]';
ylabel('Bin #')
    
subplot(5,1,5)
plot(1:nping,burst.Pressure,'k','LineWidth',2)
title('Pressure')
c = colorbar;c.Visible = 'off';
ylabel('P [mb]');xlabel('Ping #')
set(gca,'YDir','reverse')

h = findall(fh,'type','axes');
linkaxes(h,'x')
axis tight

end

