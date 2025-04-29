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
        if isfield(SWIFT, 'windustar')
            zu = [SWIFT.metheight];
            cp = 9.81.*[SWIFT.peakwaveperiod]./(2.*pi); % deep water
            alpha = 0.14.*([SWIFT.windustar]./cp).^(0.61);
            zo = alpha.*[SWIFT.windustar].^2 ./9.81;
            windspd10 = num2cell([SWIFT.windspd].*log(10./zo)./log(zu./zo));
            [SWIFT.windspd10] = deal(windspd10{:});
        else
            for k=1:length(SWIFT);
                zu = SWIFT(k).metheight;
                SWIFT(k).windspd10 = SWIFT(k).windspd.*log(10/1e-4)./log(zu/1e-4);
                % the ratio fo 2 windspeeds and wave heights from Cooper 2022
                % divides out to above. z_0 is assumed 0.0001 for windspeeds ~5
                % m/s
            end
            warning('Weaker approximation ~5 m/s assuming zo = 1e-4, obtain u* for better approx')
        end
    else
        error("Need metheight input")
    end
else
    error("Need windspd input")
end


end