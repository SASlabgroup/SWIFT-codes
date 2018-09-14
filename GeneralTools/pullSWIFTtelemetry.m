function [ allbatterylevels ] = pullSWIFTtelemetry( IDs, starttime, endtime );
% pull and compile sbd files from swiftserver for multiple SWIFTs
% use for quasi-realtime situtational awareness during a mission / project
% 
%   [ allbatterylevels ] = pullSWIFTtelemetry( IDs, starttime, endtime );
%
%   where inputs at strings arrays of two-digit SWIFT IDs (e.g., ['16';'17';'18';]
%   startime string (e.g., '2018-09-12T22:00:00')
%   and end time string, which can be empty to pull until present time
%
% note that this puts everything in the current working directory
%
%   J. Thomson, 9/2018


options = weboptions('Timeout', 20);
allbatterylevels = []; % initialize battery array


if  size(IDs,2) == 2 && ischar(IDs), % enforce two digit strings for SWIFT IDs
    
    %% loop thru pulling SBDs for each SWIFT ID
    
    for si=1:length(IDs),
        
        baseurl = 'http://swiftserver.apl.washington.edu/services/buoy?action=get_data&buoy_name=';
        buoy = ['SWIFT%20' IDs(si,:) ];
        out = websave(['SWIFT' IDs(si,:) '.zip'],[baseurl buoy  '&start=' starttime '&end=' endtime '&format=zip'],options)
        
        eval(['!unzip SWIFT' IDs(si,:) '.zip']);
        expanded = dir(['*SWIFT ' IDs(si,:) '*']);
        if length(expanded)==1 && expanded(1).isdir == true,
            cd(expanded(1).name)
        else
            disp(['multiple expanded directories for SWIFT ' IDs(si,:)])
        end
        
        % run compile SBD, which calls readSWIFT_SBD for each file
            % use a temp file work around the clear all in compile
        save temp si IDs starttime endtime options allbatterylevels
        compileSWIFT_SBDservertelemetry
        load temp
        
        allbatterylevels(si) = min(battery);
        
        cd('../')
        
    end
    
    %% combine the resulting mat files in the top level directory and make map plots
    eval(['!cp *SWIFT*/*SWIFT*start*.mat ./'])
    tempfig = mapSWIFT('watertemp');
    salinityfig = mapSWIFT('salinity');
    
    clc
    spaces(1:length(IDs)) = ' ';
    Vs(1:length(IDs)) = 'V';
    [IDs spaces' num2str(allbatterylevels') Vs']
    
else
    disp('input IDs must be two digit strings')

    return
    
end