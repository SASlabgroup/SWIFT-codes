% plotting sparse Sig data from SWIFT v4 telemetry
%
% J. Thomson, Feb 2026

figure(1), clf

for si=1:length(SWIFT)
    if ~isempty(SWIFT(si).signature)
        nbins = length(SWIFT(si).signature.profile.east); % should be 40
        subplot(2,1,1),
        scatter(SWIFT(si).time*ones(1,nbins),SWIFT(si).signature.profile.z,20,SWIFT(si).signature.profile.east,'filled'), hold on,
        subplot(2,1,2)
        scatter(SWIFT(si).time*ones(1,nbins),SWIFT(si).signature.profile.z,20,SWIFT(si).signature.profile.north,'filled'), hold on,
    else
    end
end

subplot(2,1,1),
datetick
set(gca,'YDir','reverse')
cmocean('balance')
ylabel('z [m]')
cb=colorbar; cb.Label.String = 'east [m/s]';
title(['SWIFT ' SWIFT(1).ID ', ' datestr(SWIFT(1).time) ' to ' datestr(SWIFT(end).time) ])

subplot(2,1,2)
datetick
set(gca,'YDir','reverse')
cmocean('balance')
ylabel('z [m]')
cb=colorbar; cb.Label.String = 'north [m/s]';


