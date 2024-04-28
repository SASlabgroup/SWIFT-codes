function [wclean,ispike] = despikeSIG(wraw,nfilt,dspikemax,filltype)
% Function to de-spike Signature 1000 HR velocity data using a median
% filter
%               wraw        raw HR velocity data, assumed size is nbin x nping
%               nfilt       size of median filter (in vertical bins)
%               dwmax       threshold velocity deviation from median
%                               profiles, points that exceed are spikes
%               filltype    string, either 'none' which discards spikes, or
%                               'interp' which filles spikes with linear interpolation
%               wclean      de-spiked data
%               ispike      indices of spikes that were filled

[nbin,nping] = size(wraw);
wclean = NaN(size(wraw));

% Identify Spikes
wfilt = medfilt1(wraw,nfilt,'omitnan','truncate');
ispike = abs(wraw - wfilt) > dspikemax;

% Fill with linear interpolation
if strcmp(filltype,'none')
    wclean = wraw;
    wclean(ispike) = NaN;
elseif strcmp(filltype,'interp')
    for iping = 1:nping    
        igood = find(~ispike(:,iping));
        if length(igood) > 3
        wclean(:,iping) = interp1(igood,wraw(igood,iping),1:nbin,'linear','extrap'); 
        end
    end
else
    error('Fill type must be ''none'' or ''linear''')
end


end