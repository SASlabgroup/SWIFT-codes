function [i_other, otherDist,TimeDiff] = collocateSWIFT(SWIFT, otherTime, otherLat, otherLon)
%collocateSWIFT Find other measurements collocated within range of SWIFT
%   INPUTS: otherTime in datenum format (NOTE: written for ship
%               measurements or other continuous dataset, so if dataset is patchy, must
%               also limit difference in time allowed)
%           otherLat
%           otherLon
%           maxDist is distance (in km) that measurement may be from SWIFT
%   
%   OUTPUTS: i_other index of measurements closest in time to SWIFT
%            otherDist option to output all distances of mesaurement to SWIFT
%
%   EXAMPLE: add cell to SWIFT structure for ship wind when within 10 km
%     for l=1:length(SWIFT),
%         if otherDist(l)<10 %within 10 km
%             SWIFT(l).shipwindspd=wspd_ref(i_other(l));
%         else
%             SWIFT(l).shipwindspd=NaN;
%         end
%     end
%   
%   M Smith, 06/2016
%   

%make sure lat and lon matrices are correct orientation
if size(otherLat,1)>size(otherLat,2)
    otherLat=otherLat';
end
if size(otherLon,1)>size(otherLon,2)
    otherLon=otherLon';
end

%find closest time to 
i_other=zeros(1,length(SWIFT));
for l=1:length(SWIFT),
    [~,i_other(l)]= min(abs(SWIFT(l).time-otherTime));
    TimeDiff(l) = abs(SWIFT(l).time-otherTime(i_other(l)));
end

%calculate distance from ship to SWIFT
[arclen,~] = distance([SWIFT.lat],[SWIFT.lon],otherLat(i_other),otherLon(i_other));
otherDist=distdim(arclen,'deg','km');

% %plot of distance from other/ship to SWIFT
% figure(1),
% subplot(121)
% hist(otherDist,20) %histogram of distances
% xlabel('distance (km)')
% ylabel('counts')
% 
% subplot(122)
% plot([SWIFT.time],otherDist,'-o') %distance with time
% datetick
% xlabel('time')
% ylabel('distance (km)')
% %lines to visualize how often within certain distance
% line([SWIFT(1).time SWIFT(end).time],[5 5],'Color','r') %or other distance
% line([SWIFT(1).time SWIFT(end).time],[10 10],'Color','m') %ot other distance

end

