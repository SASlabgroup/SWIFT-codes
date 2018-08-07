function [ Esmooth ] = SIWEH(z, Tp, dt);
% function to calculate the "smoothed instantaneous wave energy history"
% following Funke and Mansard (1980)
%  timeseries of heave "z",
%  peak period "Tp",
%  samplingtimestep "dt"
%
%   [ Esmooth ] = SIWEH(z, Tp, dt);
%
%  returning "Esmooth" in units of heave^2
%
% J. Thomson (7/2018... modified from 2/2017 SWIFTwavegroups.m)
%

nT = 2;  % number of wave periods for smoothing


Esmooth( length( z ) ) = NaN;  

for ii = 1:length(z),
    
    starti = max([ 1  (ii-round( 2*Tp./dt))]);
    stopi = min([ length(z)  (ii+round( nT*Tp./dt))]);
    
    Esmooth(ii) = 1./Tp.* nansum( z( starti:stopi ).^2 .*  bartlett( length(starti:stopi) ) .* dt );
    
    if Esmooth(ii) == 0,
        Esmooth(ii) = NaN;
    else
    end
end