% script to export SWIFT matlab structures into ASCII or Google Earth files
%
% J. Thomson, Oct 2016
%           Aug 2019, include google earth export as option

clear all, close all

type='kml'

flist = dir('./*.mat');

for fi = 1:length(flist),
    
    filename = flist(fi).name(1:end-4);
    
    load(filename)
    
    
%% txt export
if type=='txt',
    
time = datevec([SWIFT.time]);

% scalars
%METWaveoutput = [time [SWIFT.lat]' [SWIFT.lon]' [SWIFT.driftspd]' 	[SWIFT.driftdirT]'	[SWIFT.airpres]'	[SWIFT.airpresstddev]' 	[SWIFT.airtemp]' 	[SWIFT.airtempstddev]'	[SWIFT.windspd]'	[SWIFT.windspdstddev]'	[SWIFT.winddirT]'	[SWIFT.winddirTstddev]'	[SWIFT.sigwaveheight]'	[SWIFT.peakwaveperiod]'	[SWIFT.peakwavedirT]' ];
METWaveoutput = [time [SWIFT.lat]' [SWIFT.lon]' [SWIFT.driftspd]' 	[SWIFT.driftdirT]'	[SWIFT.airtemp]' 	[SWIFT.windspd]'	[SWIFT.sigwaveheight]'	[SWIFT.peakwaveperiod]'	[SWIFT.peakwavedirT]' ];
%METWaveoutput = single(METWaveoutput);

% spectra
for si = 1:length(SWIFT), 
    energyoutput(si,:) = [time(si,:) SWIFT(si).wavespectra.energy'];
    a1output(si,:) = [time(si,:) SWIFT(si).wavespectra.a1'];
    b1output(si,:) = [time(si,:) SWIFT(si).wavespectra.b1'];
    a2output(si,:) = [time(si,:) SWIFT(si).wavespectra.a2'];
    b2output(si,:) = [time(si,:) SWIFT(si).wavespectra.b2'];
end

% save

save([filename '_METWave.txt'],'METWaveoutput','-ascii', '-tabs')
save([filename '_WaveSpectra_energy.txt'],'energyoutput','-ascii', '-tabs')
save([filename '_a1_energy.txt'],'a1output','-ascii', '-tabs')
save([filename '_b1_energy.txt'],'b1output','-ascii', '-tabs')
save([filename '_a2_energy.txt'],'a2output','-ascii', '-tabs')
save([filename '_b2_energy.txt'],'b2output','-ascii', '-tabs')


%% kml export
elseif type=='kml',
  
    gescatter([ filename '.kml' ],[SWIFT.lon],[SWIFT.lat],[SWIFT.sigwaveheight],'time',[SWIFT.time])
    
end

end