% matlab script to convert horizontal GPS spectra to vertical
% with division by spectral check factor 
% beware that the check factor here is the inverse of Thomson et al, J Tech, 2015
% 
% this removes the deep-water dispersion assmuption 
% which is implicit in the microSWIFT standard NEDwaves output (from telemetry)
% at the expense of [sometimes] higher noise floor
%
% J. Thomson, 10/2024

clear all, close all

flist = dir('*SWIFT*.mat'); 

for fi=1:length(flist)
   load(flist(fi).name)

   for si=1:length(SWIFT)
      
       SWIFT(si).wavespectra.energy = SWIFT(si).wavespectra.energy .* SWIFT(si).wavespectra.check;
       df = median( diff( SWIFT(si).wavespectra.freq ) ); 
       SWIFT(si).sigwaveheight = 4* sqrt( nansum(SWIFT(si).wavespectra.energy) * df ); 
       SWIFT(si).peakwaveperiod = nansum( SWIFT(si).wavespectra.energy  )...
           ./ nansum( SWIFT(si).wavespectra.energy .* SWIFT(si).wavespectra.freq  ); 
   end

   save([flist(fi).name(1:end-4) '_corrected.mat'],'SWIFT')

end