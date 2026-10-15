function plotWatchResidual(key,heading,recordwatch,lobeA,timelimits)
residual = mod(heading-recordwatch+180,360)-180;
if ~any(isfinite(residual))
    title('heading minus watch bearing: no SWIFT position file'); return
end
offset = meandir(residual(isfinite(residual)));
mount90 = 90*round(offset/90);
plot(key(lobeA),residual(lobeA),'.','Color',[0 0.45 0.74],'MarkerSize',5); hold on
plot(key(~lobeA),residual(~lobeA),'.','Color',[0.85 0.33 0.1],'MarkerSize',5)
yline(mount90,'k-'); yline(offset,'k--')
ylim([-180 180]); yticks(-180:90:180); grid on; ylabel('deg')
xlim(timelimits); xticks(floor(timelimits(1)):ceil(timelimits(2)))
datetick('x','mm/dd','keeplimits','keepticks')
legend('lobe A','lobe B',sprintf('nearest 90: %d%c',mount90,char(176)), ...
    sprintf('mean %.1f%c',offset,char(176)),'Location','eastoutside')
title(sprintf('heading minus watch bearing; residual to %d%c = %.1f%c', ...
    mount90,char(176),offset-mount90,char(176)))
end
