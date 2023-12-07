function [Sv_w,zbot] = sig_makebot(Sv,echo,avg,z,zoff)

% Last modifications: 6 Dec 2023 - C. Bassett

% sig_makebot takes processed ADCP and echosounder data and uses the
% products to estimate the depth and threshold out the bottom. All values
% below the bottom are replaced with NaNs;

% INPUTS: 
% Svt: A processed volume backscattering or target strength array from the 
    % sigecho_vol or sigecho_ts scripts. Note Sv can also be TS, so this
    % variable name is something of a misnomer but is maintained for
    % similarity throughout the functions.

% echo: A structure containing all of the relevant echosounder information
    % that is based by the reprocess_SIG function from which it is called.
    % This script only uses its time variable at the present time.

% avg: Structure from ADCP data. It is used to approximate any bounds for
    % the seabed, which are then used to inform a search for the maximum 
    % within a range around the ADCP values. 

% zt:  The depth for imaging in the echogram after accounting for the
    % nominal sampling conditions and actual sound speed
    
% zoff: Offset [m] for the transducer depth below the water, default 0.2 m;

% OUTPUTS: 
% Sv_w [dB re 1/m] that has all sub-bottom depths (greater than 0.5 m below
% bottom) replaced as NaN.
% zbot - the bottom depth [m]; used just for plotting


% Reference
%  C. Bassett and K. Zeiden, Calibration and Processing of Nortek Signature 
%  1000 Echosounders (2020). Technical Report, APL-UW TR 2303. Applied
%  Physics Laboratory, University of Washington, Seattle, 
%  December 2023, 37 pp.



Sv_w = Sv;
%%
% calcualte bottom estimate from altimeter

% Start by identifying outliers = 3 SD outside of values, may break down
% with a steep seafloor
[B,badi]=rmoutliers(avg.AltimeterDistance,"mean");
badi = find(badi == 1); % pull out only the outliers
% Interate outliers and just replace them with adjacent bottomes or
% averages. Since we are only using this to clean up the echogram we don't
% need to be precise
for j = 1:length(badi)
if and(badi(j) > 1, badi(j) < length(avg.AltimeterDistance))
    avg.AltimeterDistance(badi(j)) = 0.5*(avg.AltimeterDistance(badi(j)-1)+ ...
    avg.AltimeterDistance(badi(j)+1));

elseif badi(j) == 1
    avg.AltimeterDistance(badi(j)) = avg.AltimeterDistance(2); 

elseif badi(j) == length(avg.AltimeterDistance)
    avg.AltimeterDistanceend(end) = avg.AltimeterDistance(end-2); 
end
end

% now interpolate this onto the same times as the normal echogram
echod= interp1(avg.time, avg.AltimeterDistance, echo.time,'pchip');


% get new bottom estimate with offsets from transducer depths
zest = echod+zoff; % get estimate with offsets

% index for many indices offset below bottom to NaN out, go one meter past 
% the attempt at seafloor based on cell size in the raw data
offind = floor(1/echo.CellSize); 

% MAY NEED TO ADD A LOOP HERE AROUND HERE FOR DEEP WATER
for j = 1:length(Sv(:,1))
    botranges = [zest(j)-1 zest(j)+1];
    searchinds = find(and(z > botranges(1), z < botranges(2)));
    [~,maxi] = max(Sv(j,searchinds));
    zbot(j) = z(searchinds(1) + (maxi-1));
    Sv_w(j, searchinds(1) + (maxi-1) + offind:end) = NaN;
end

% figure
% imagesc(ping,z,Sv_w'), hold on
% axis([1 length(ping) 0 max(zbot)+1])
% box on, set(gca,'linewidth',2,'layer','top')
% set(gca,'clim',[-75 -40])
% colormap(gray(35))
% hcb = colorbar('linewidth',2)
% ylabel(hcb,'S_v [dB re 1/m]','fontweight','bold')
% ylabel('z [m]','fontweight','bold')
% xlabel('Ping No.','fontweight','bold')

end

