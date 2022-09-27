function [ allbatterylevels lasttime lastlat lastlon] = pullSWIFTtelemetry( IDs, starttime, endtime );
% pull and compile sbd files from swiftserver for multiple SWIFTs
% use for quasi-realtime situtational awareness during a mission / project
%
%   [ voltage lasttime lastlat lastlon ] = pullSWIFTtelemetry( IDs, starttime, endtime );
%
%   where inputs at strings arrays of two-digit SWIFT IDs (e.g., ['16';'17';'18';]
%   startime string (e.g., '2018-09-12T22:00:00')
%   and end time string, which can be empty to pull until present time
%
%   outputs are the minimum battery reading and the lasttime, lastlat, lastlon of telemetry
%
% note that this puts everything in the current working directory
%
%   J. Thomson, 9/2018
%           5/2021 make compatible with microSWIFTs (three digit IDs)
%           8/2022 make compatible with Winddows PCs

global battery

options = weboptions('Timeout', 60);
pcflag = ispc; % binary flag to determine if a Windows PC (use different commands for copy, unzip)


if  size(IDs,2) == 2 && ischar(IDs), % enforce two digit strings for SWIFT IDs
    
    SWIFTtype = 'v3v4s'
    allbatterylevels = NaN(1,size(IDs,1)); % initialize battery array
    lasttime =  NaN(1,size(IDs,1)); % initialize time array
    lastlat = NaN(1,size(IDs,1)); % initialize
    lastlon = NaN(1,size(IDs,1)); % initialize
    
elseif  size(IDs,2) == 3 && ischar(IDs), % enforce three digit strings for microSWIFT IDs
    
    SWIFTtype = 'micro'
    allbatterylevels = NaN(1,size(IDs,1)); % initialize battery array
    lasttime =  NaN(1,size(IDs,1)); % initialize time array
    lastlat = NaN(1,size(IDs,1)); % initialize
    lastlon = NaN(1,size(IDs,1)); % initialize
    
else
    
    allbatterylevels = NaN(1,size(IDs,1)); % initialize battery array
    lasttime =  NaN(1,size(IDs,1)); % initialize time array
    lastlat = NaN(1,size(IDs,1)); % initialize
    lastlon = NaN(1,size(IDs,1)); % initialize
    
    disp('invalid IDs')
    
    return
    
end

%% loop thru pulling SBDs for each SWIFT ID

for si=1:size(IDs,1),
    
    baseurl = 'http://swiftserver.apl.washington.edu/services/buoy?action=get_data&buoy_name=';
    
    if SWIFTtype =='v3v4s'
        buoy = ['SWIFT%20' IDs(si,:) ];
    elseif SWIFTtype =='micro'
        buoy = ['microSWIFT%20' IDs(si,:) ];
    else
    end
    
    out = websave(['SWIFT' IDs(si,:) '.zip'],[baseurl buoy  '&start=' starttime '&end=' endtime '&format=zip'],options)
    
    if pcflag
        zipfile = ['SWIFT' IDs(si,:) '.zip'];
        unzip(zipfile)
    else
        eval(['!unzip SWIFT' IDs(si,:) '.zip']);
    end
    expanded = dir(['*SWIFT ' IDs(si,:) '*']);
    if length(expanded)==1 && expanded(1).isdir == true,
        cd(expanded(1).name)
        
        % run compile SBD, which calls readSWIFT_SBD for each file
        % use a temp file work around the clear all in compile
        save temp si IDs starttime endtime options allbatterylevels lasttime lastlon lastlat SWIFTtype pcflag
        compileSWIFT_SBDservertelemetry
        load temp
        wd = pwd;
        wdi = find(wd == '/',1,'last');
        wd = wd((wdi+1):end);
        if ~isempty(SWIFT),
            allbatterylevels(si) = battery(end);
            lasttime(si) = max([SWIFT.time]);
            lastlat(si) = SWIFT(end).lat;
            lastlon(si) = SWIFT(end).lon;
        else
            eval(['!rm '  wd '.mat']), % remove file if no results
            allbatterylevels(si) = NaN;
            lasttime(si) = 0;
            lastlat(si) = NaN;
            lastlon(si) = NaN;
        end
        
        % keep going to next SWIFT
        cd('../')
        
    else
        disp(['multiple expanded directories for SWIFT ' IDs(si,:)])
        allbatterylevels(si) = NaN;
        lasttime(si) = 0;
        lastlat(si) = NaN;
        lastlon(si) = NaN;
    end
    
end

%% combine the resulting mat files in the top level directory and make map plots
if pcflag
    copystatus = system(['copy *SWIFT*\*SWIFT*telemetry.mat .\'])
else
    eval(['!cp *SWIFT*/*SWIFT*telemetry.mat ./'])
end

if isfield(SWIFT,'watertemp') && ~isempty(SWIFT)
    tempfig = mapSWIFT('watertemp');
end
if isfield(SWIFT,'salinity') && ~isempty(SWIFT)
    salinityfig = mapSWIFT('salinity');
end
if isfield(SWIFT,'sigwaveheight') && ~isempty(SWIFT)
    wavefig = mapSWIFT('sigwaveheight');
end

%clc,
spaces(1:size(IDs,1)) = ' ';
commas(1:size(IDs,1)) = ',';
Vs(1:size(IDs,1)) = 'V';

[IDs commas' spaces' datestr(lasttime) commas' spaces' num2str(lastlat',6) commas' spaces' ...
    num2str(lastlon',6) commas' spaces' num2str(allbatterylevels',3) Vs']


