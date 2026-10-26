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

arguments
    wraw
    nfilt
    dspikemax
    filltype {mustBeMember(filltype,{'none','interp'})} = 'interp'
end

% Identify Spikes
wfilt = medfilt1(wraw,nfilt,'omitnan','truncate');
ispike = abs(wraw - wfilt) > dspikemax;

% Discard spikes
if strcmp(filltype,'none')
    wclean = wraw;
    wclean(ispike) = NaN;
    return
end

% Fill spikes with linear interpolation (pings need more than 3 good bins)
wclean = wraw;
wclean(ispike) = NaN;
% Interpolate and extrapolate along dim 1 (bins), within each ping
wclean = fillmissing(wclean,'linear',1,'EndValues','extrap');
% NaN where interp1 would propagate a NaN sample: a filled value is NaN if
% either good bin it comes from is NaN, so fill an indicator the same way
nanw = double(isnan(wraw));
nanw(ispike) = NaN;
wclean(fillmissing(nanw,'linear',1,'EndValues','extrap') ~= 0) = NaN;
wclean(:,sum(~ispike,1) <= 3) = NaN;

end