% script to scale near-surface TKE dissipation rates from SWIFT obs
%

close all

for si = 1:length(SWIFT), 
    
    figure(1), 
    loglog(1e-2.*SWIFT(si).uplooking.tkedissipationrate.*SWIFT(si).sigwaveheight./(SWIFT(si).windustar./2).^3, SWIFT(si).uplooking.z./SWIFT(si).sigwaveheight,'b:')
    hold on
    
end

set(gca,'Ydir','reverse')
plot(1e-5.*[5e-2 1e0].^-2,[5e-2 1e0],'k--')
axis([1e-7 1e0 1e-4 1e1])
set(gca,'fontsize',16,'fontweight','demi')
ylabel('\epsilon H / u_*^3')
xlabel('z/H')