% SNAP hydrophone processing
% initial lines from Rob Taylor (ARL-UT)
% refinements by J. Thomson (APL-UW) 

clear 

file_path = './';
fs = 48; % sampling rate [kHz]
gain = 168;  % hydrophone gain

flist = dir('*.wav');

tic
for fi = 1:length(flist)
    
    file_name = flist(fi).name; %file_name = '20210916T150800_42669179072379786_2.0.wav'; % testing
    tstring = file_name(1:15);  % this is datestr type 30 (ISO 8601)
    year = str2num(tstring(1:4));
    month = str2num(tstring(5:6));
    day = str2num(tstring(7:8));
    hour = str2num(tstring(10:11));
    minute = str2num(tstring(12:13));
    second = str2num(tstring(14:15));
    
    % make spectrograms
    [data_T,fs] = audioread([file_path,file_name]); %minute long dataset
    [~,freq_Q,time_S,psd_QS] = spectrogram(data_T,fs,0,fs,fs,'psd');
    amb_sound_QS = 10*log10(psd_QS)+gain; %in dB, adding the gain
   
    % find median values (avoids spiking) 
    mS = median(amb_sound_QS');
       
    % decimate to reduce frequency resolution 
    freq_Q = decimate(freq_Q, 100);
    mS = decimate(mS, 100);
    
    % build results array 
    f_kHz = freq_Q ./ 1e3;
    PSD(:,fi) = mS;
    time(fi) = datenum( year, month, day, hour, minute, second); 
    
end
toc 

save SNAPhydrophonespectra f_kHz PSD time

figure(1), clf
pcolor(time,f_kHz,PSD), shading flat, datetick
print -dpng spectrogram.png

figure(2), clf
loglog(f_kHz, PSD)
ylabel('dB')
xlabel('f [kHz]')
print -dpng spectra.png