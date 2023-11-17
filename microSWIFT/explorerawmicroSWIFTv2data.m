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
despike = false;
pts = 4096;

if includetelemetry
    load('microSWIFT003_telemetry.mat')
end

for gi = 1:length(GPSflist)
    
    disp(['GPS file ' num2str(gi) ' of ' num2str(length(GPSflist))])
    [north east down] = read_microSWIFTv2_rawdata( GPSflist(gi).name , pts, true );
    
    if despike
        north = filloutliers(north,'nearest');
        east = filloutliers(north,'nearest');
        down = filloutliers(north,'nearest');
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
    NEDresults(gi).wavespectra.freq = f;
    NEDresults(gi).wavespectra.a1 = a1;
    NEDresults(gi).wavespectra.b1 = b1;
    NEDresults(gi).wavespectra.a2 = a2;
    NEDresults(gi).wavespectra.b2 = b2;
    %     NEDresults(gi).time = median(GPS.time);
    %     NEDresults(gi).lat = median(GPS.lat);
    %     NEDresults(gi).lon = median(GPS.lon);
    %     NEDresults(gi).ID =  [GPSflist(gi).name(11:13)];
    
    
    figure(2), clf
    loglog(GPSresults(gi).wavespectra.freq, GPSresults(gi).wavespectra.energy), hold on
    loglog(NEDresults(gi).wavespectra.freq, NEDresults(gi).wavespectra.energy,'--'), hold on
    if includetelemetry
        loglog(SWIFT(gi).wavespectra.freq, SWIFT(gi).wavespectra.energy,'k:'), hold on
        legend(['GPSwaves, H_s = ' num2str(GPSresults(gi).sigwaveheight,2) ],...
            ['NEDwaves memlight, H_s = ' num2str(NEDresults(gi).sigwaveheight,2)],'telemetry')
    else
        legend(['GPSwaves, H_s = ' num2str(GPSresults(gi).sigwaveheight,2) ],...
            ['NEDwaves memlight, H_s = ' num2str(NEDresults(gi).sigwaveheight,2)],'telemetry')
    end
    title(GPSflist(gi).name)
    xlabel('frequency [Hz]')
    ylabel('Energy density [m^2/Hz]')
    print('-dpng',[ GPSflist(gi).name(1:end-4) '_spectra.png'])
    
    
end

save('results.mat','GPSresults','NEDresults');

%%

figure(3),
plot( [NEDresults.sigwaveheight].^2 ./ [GPSresults.sigwaveheight].^2, 'bo','linewidth',3)
ylabel('Variance ratio')
xlabel('file number')
axis([0 inf 0 2])
grid
print -dpng varianceratio.png


