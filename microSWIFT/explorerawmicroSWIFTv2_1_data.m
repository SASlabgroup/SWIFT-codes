% script to explore microSWIFT v2 raw data
% intended to be run in directory with mission data from a single buoy
% loops thru binaries files: reading, plotting, processing each
%
% J. Thomson, Oct 2023 (adapted from v1 written in Oct 2020)

clear

% load all files in current directory
GPSflist = dir('*.bin');
GPSsamplingrate = 4; % assume 4 Hz
includetelemetry = false;
despike = true;
pts = 4096;
minwaveheight = 1;

if includetelemetry
    load('microSWIFT003_telemetry.mat')
end

for gi = 1:length(GPSflist)
    
    disp(['GPS file ' num2str(gi) ' of ' num2str(length(GPSflist))])
    [north east down] = read_microSWIFTv2_rawdata( GPSflist(gi).name , pts, true );
    save( [GPSflist(gi).name(1:end-4) '.mat'], 'north', 'east', 'down')
    
    if despike
        north = filloutliers(north,'nearest');
        east = filloutliers(east,'nearest');
        down = filloutliers(down,'nearest');
    end
    
    % legacy GPS waves processing
    [ Hs, Tp, Dp, E, f, a1, b1, a2, b2 ] = GPSwaves(east, north, [], GPSsamplingrate);
    % store in SWIFT structure
    GPSresults(gi).sigwaveheight = Hs;
    GPSresults(gi).peakwaveperiod = Tp;
    GPSresults(gi).peakwavedirT = Dp;
    GPSresults(gi).wavespectra.energy = E;
    GPSresults(gi).wavespectra.freq = f;
    GPSresults(gi).wavespectra.a1 = a1;
    GPSresults(gi).wavespectra.b1 = b1;
    GPSresults(gi).wavespectra.a2 = a2;
    GPSresults(gi).wavespectra.b2 = b2;
    %     GPSresults(gi).time = median(GPS.time);
    %     GPSresults(gi).lat = median(GPS.lat);
    %     GPSresults(gi).lon = median(GPS.lon);
    %     GPSresults(gi).ID =  [GPSflist(gi).name(11:13)];
    
    % onboard GPS (NED) waves processing
    [ Hs, Tp, Dp, E, fmin, fmax, a1, b1, a2, b2, check ] = NEDwaves_memlight(north', east', down', GPSsamplingrate);
    %[ Hs, Tp, Dp, E, fmin, fmax, a1, b1, a2, b2, check ] = NEDwaves(north', east', down', GPSsamplingrate);
    % store in SWIFT structure
    NEDresults(gi).sigwaveheight = Hs;
    NEDresults(gi).peakwaveperiod = Tp;
    NEDresults(gi).peakwavedirT = Dp;
    NEDresults(gi).wavespectra.energy = E;
    NEDresults(gi).wavespectra.freq = linspace(fmin, fmax, length(E) );
    NEDresults(gi).wavespectra.a1 = a1;
    NEDresults(gi).wavespectra.b1 = b1;
    NEDresults(gi).wavespectra.a2 = a2;
    NEDresults(gi).wavespectra.b2 = b2;
    %     NEDresults(gi).time = median(GPS.time);
    %     NEDresults(gi).lat = median(GPS.lat);
    %     NEDresults(gi).lon = median(GPS.lon);
    %     NEDresults(gi).ID =  [GPSflist(gi).name(11:13)];
    
    figure(4), clf
    hist([north east down])
    hold on
    plot([0 0],[0 pts],'k--')
    legend('north','east','down')
    xlabel('m/s')
    ylabel('Observations')
     set(gca,'fontsize',16,'fontweight','demi')
    print('-dpng',[ GPSflist(gi).name(1:end-4) '_NEDhistogram.png'])
    
    figure(2), clf
    loglog(GPSresults(gi).wavespectra.freq, GPSresults(gi).wavespectra.energy), hold on
    loglog(NEDresults(gi).wavespectra.freq, NEDresults(gi).wavespectra.energy,'--'), hold on
    if includetelemetry
        loglog(SWIFT(gi).wavespectra.freq, SWIFT(gi).wavespectra.energy,'k:'), hold on
        legend(['GPSwaves, H_s = ' num2str(GPSresults(gi).sigwaveheight,2) ],...
            ['NEDwaves memlight, H_s = ' num2str(NEDresults(gi).sigwaveheight,2)],'telemetry')
    else
        legend(['GPSwaves, H_s = ' num2str(GPSresults(gi).sigwaveheight,2) ],...
            ['NEDwaves memlight, H_s = ' num2str(NEDresults(gi).sigwaveheight,2)])
    end
    title(GPSflist(gi).name)
    xlabel('frequency [Hz]')
    ylabel('Energy density [m^2/Hz]')
     set(gca,'fontsize',16,'fontweight','demi')
    print('-dpng',[ GPSflist(gi).name(1:end-4) '_spectra.png'])
    
    north_all(gi,:) = north;
    east_all(gi,:) = east;
    down_all(gi,:) = down;
    
end

save('results.mat','GPSresults','NEDresults');

%% screen and save raw data
nowaves = find( [NEDresults.sigwaveheight] < minwaveheight );
north_all(nowaves,:) = [];
east_all(nowaves,:) = [];
down_all(nowaves,:) = [];
save rawdata *all

%%

figure(3),
plot( [NEDresults.sigwaveheight].^2 ./ [GPSresults.sigwaveheight].^2, 'bo','linewidth',3)
ylabel('Variance ratio')
xlabel('file number')
axis([0 inf 0 2])
 set(gca,'fontsize',16,'fontweight','demi')
grid
print -dpng varianceratio.png


figure(5), clf
plot([1:length(east_all(:))]./(60*GPSsamplingrate) , smooth(east_all(:),30*GPSsamplingrate),'c-','linewidth',2)
hold on
%plot(reshape(smooth(east_all',30*GPSsamplingrate), size(east_all) ),'.'), hold on
%plot(east_all','.')
plot([0: pts./(60*GPSsamplingrate) : length(east_all(:))./(60*GPSsamplingrate)], zeros(1,1+size(east_all,1)) ,'k-x','linewidth',2,'markersize',10)
ylabel('smoother east velocity component [m/s]')
xlabel('minutes')
grid
 set(gca,'fontsize',16,'fontweight','demi')
print -dpng smoothed_east.png

