% add hydrophone spectra to SWIFT data structures

load('SWIFT11_11-16Sep2021_hydrophone.mat')
%load('SWIFT12_11-25Sep2021_hydrophone.mat')

load('./L3_merged/SWIFT11_NORSEpilot2021.mat')
%load('./L3_merged/SWIFT12_NORSEpilot2021.mat')

for si = 1:length(SWIFT)
   [tdiff tindex ] = min( abs( SWIFT(si).time - time ) ); 
   if tdiff < 1/(24*10)
       SWIFT(si).hydrophone.spectra = PSD(:,tindex);
       SWIFT(si).hydrophone.f_kHz = f_kHz;
   else
       SWIFT(si).hydrophone.spectra = NaN(length(f_kHz),1);
       SWIFT(si).hydrophone.f_kHz = f_kHz;
   end
    
end

save('./L3_merged/SWIFT11_NORSEpilot2021.mat','SWIFT')
%save('./L3_merged/SWIFT12_NORSEpilot2021.mat','SWIFT')


%% plots 
figure(1), clf
cmap = colormap;

for si=1:length(SWIFT)
    cindex = round( ( SWIFT(si).windspd ./ 20 ) * 256 );
    loglog(SWIFT(si).hydrophone.f_kHz, SWIFT(si).hydrophone.spectra,'-','color',cmap(cindex,:)), hold on, 
end

set(gca,'FontSize',16,'FontWeight','demi')
xlabel('f [kHz]')
ylabel('Acoustic spectra [dB re 1 uPa^2 / Hz]')

cb = colorbar;
cb.Label.String = 'Wind Spd [m/s]';
cb.TickLabels = [num2str([0:2:20]')];

%title('SWIFT during NORSE pilot (2021)')

