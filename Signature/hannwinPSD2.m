function [PX,F,Ph,err] = hannwinPSD2(datax,nwin,fs,norm)
% hannwinPSD2 Computes spectra via windowing
% PS is either unitless (if normalized to integrate to 1) or units of
% variance of data (e.g. m^2/s^2 for velocity (m/s)).

datax = datax(:)'; %force row

% Create taper (window)
N = length(datax); %Total number of data points (whole timeseries)
M = 2*(floor(N/nwin))-1; % Number of windows (%50 overlap)
h = sqrt(8/3)*hanning(nwin);% Hanning window variance preservation

% Frequencies
T = nwin/fs; 
df = 1/T; 
F = (0:nwin-1)*df; 
F = F(1:floor(end/2));

PX = NaN(M,floor(nwin/2));
Ph = NaN(M,floor(nwin/2));
DX = NaN(M,nwin);
for i = 1:M 

    % Select window
    k1 = (i-1)*nwin/2 + 1;
    k2 = (i+1)*nwin/2;
    dataxi = datax(k1:k2);
    
    % Remove mean, trend and apply hanning window
    dataxi(isnan(dataxi)) = mean(dataxi,'omitnan'); % Replace NaN w/mean
    dataxi = dataxi - mean(dataxi,'omitnan'); % Remove mean
    dataxi = detrend(dataxi); % Remove trend
    dataxi = h.*dataxi'; % Window using normalized hanning window

    % Take fft and square
    ph = angle(fft(dataxi));% phase
    px = abs(fft(dataxi)).^2;% power (magnitude)

    % Select for positive frequencies + double magnitude of PS
    ph = ph(1:floor(end/2));
    px = px(1:floor(end/2));
    px(2:end) = 2*px(2:end);

    % Save in matrix for averaging
    PX(i,:) = px;
    Ph(i,:) = ph;
    DX(i,:) = dataxi;
end

% Average
PX = mean(PX,'omitnan');
Ph = mean(Ph,'omitnan');

% Normalize to satisfy Parsevals Theorem or produce PSD
if strcmp(norm,'psd')
    PX = PX/sum(PX);
elseif strcmp(norm,'par')
    PX = PX/(df*nwin^2);
    vard = mean(var(DX,[],2,'omitnan'),'omitnan');
    varPS = sum(PX,'omitnan').*df;
    pvardiff = 100*(varPS-vard)/vard;
    if abs(pvardiff) > 5
        warning('Parseval''s Theorom not satisifed to within 5%')
    else
    end
end
    
% Confidence Intervals
err_low = (2*M)/chi2inv(.05/2,2*M);
err_high = (2*M)/chi2inv(1-.05/2,2*M);
err = [err_low err_high];

end


