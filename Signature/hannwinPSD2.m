function [PS,F,err] = hannwinPSD2(data,M,fs,norm)
% hannwinPSD2 Computes spectra via windowing
% PS is either unitless (if normalized to integrate to 1) or units of
% variance of data (e.g. m^2/s^2 for velocity (m/s)).

data = data(:)'; %force row

N = length(data); %Total number of data points (whole timeseries)
nwin = 2*(floor(N/M))-1; %Number of windows (%50 overlap)
h = sqrt(8/3)*hann(M);% Hanning window variance preservation

PS = NaN(nwin,floor(M/2));
for i=1:nwin 
    k1 = (i-1)*M/2 + 1;
    k2 = (i+1)*M/2;
    datai = data(k1:k2);
    St = datai;
    St(isnan(St)) = nanmean(St); % Replace NaN w/mean
    St = St - nanmean(St); % Remove mean
    St = detrend(St); % Remove trend
    %(IMPORTANT TO REMOVE MEAN BEFORE WINDOW!)
    St = h.*St'; % Window using normalized hanning window
    Sp = (abs(fft(St)).^2);
    Sp = Sp(1:floor(end/2));
    Sp(2:end) = 2*Sp(2:end);
    PS(i,:) = Sp;
end
%Average
PS = nanmean(PS,1);

%Frequencies Computed
T = M/fs; 
ff = 1/T; 
F = (0:M-1)*ff; 
F = F(1:floor(end/2));

%Take Positive Frequencies only

%Normalize to satisfy Parsevals Theorem or produce PSD
if strcmp(norm,'psd')
    PS = PS/sum(PS);
elseif strcmp(norm,'par')
    PS = PS/(ff*M^2);
end
    
%Confidence Intervals
err_low = (2*nwin)/chi2inv(.05/2,2*nwin);
err_high = (2*nwin)/chi2inv(1-.05/2,2*nwin);
err = [err_low err_high];

end


