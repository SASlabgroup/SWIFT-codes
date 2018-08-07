function [ D r ] = structureFunction( v , z );
%
% Function to calculate the spatial structure function of an ADCP time series (burst w/stationarity)
%
%   [ D r ] = structureFunction( v , z );
%
% Given a velocity profile that is [bins, time] and a corresponding vector of bin heights, 
% the function returns structure and range arrays that are [bins, range]   
% 
%
% J. Thomson, 7/2009, 
%       rev. 7/2010 (efficiency) 
%       rev. 8/2010 (explicitly remove mean [should be done already], allow nans in profiles) 
%       rev. 9/2011  (return signed r value, to allow upward or downward preference in D(z,r) fit)

[bins time] = size(v);

v = v - nanmean(v,2)*ones(1,time); 

for i = [1:bins],
  
    r(i,:) = z(i) - z(:);
    
        for t = 1:time, 
            
        dzrt(:,t) = ( v(i,t) - v(:,t) ).^2;
        
        end
        
    D(i,:) = nanmean(dzrt,2);       
    
end
