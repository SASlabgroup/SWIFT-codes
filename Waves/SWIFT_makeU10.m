function SWIFT=SWIFT_makeU10(SWIFT)
%%%%%%%%%%%%%%%%%SWIFT_makeU10.m
%
%   Calculates 10 m winds from SWIFT.windspd, follows the code established
%   in COARE 3.6 algorithm. https://github.com/NOAA-PSL/COARE-algorithm. 
% 
%   Scientifically, this adjustment follows the log layer assumption of 
%   the wind profile, where vertical gradient of air density == 0;
%
%   Created: M. James, December 2024

if isfield(SWIFT, 'windspd');
    if isfield(SWIFT, 'metheight');
        for k=1:length(SWIFT);
            zu = SWIFT(k).metheight;
            SWIFT(k).windspd10 = SWIFT(k).windspd.*log(10/1e-4)./log(zu/1e-4);
            % the ratio fo 2 windspeeds and wave heights from Cooper 2022
            % divides out to above. z_0 is assumed 0.0001 for windspeeds ~5
            % m/s
        end
    else
        error("Need metheight input")
    end
else
    error("Need windspd input")
end


end