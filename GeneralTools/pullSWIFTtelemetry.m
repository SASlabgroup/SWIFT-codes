function [ allbatterylevels lasttime lastlat lastlon] = pullSWIFTtelemetry( IDs, starttime, endtime );
% pull and compile sbd files from swiftserver for multiple SWIFTs
% use for quasi-realtime situtational awareness during a mission / project
%
%   [ allbatterylevels lasttime lastlat lastlon ] = pullSWIFTtelemetry( IDs, starttime, endtime );
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

global battery

options = weboptions('Timeout', 20);


if  size(IDs,2) == 2 && ischar(IDs), % enforce two digit strings for SWIFT IDs
    
    allbatterylevels = NaN(1,length(IDs)); % initialize battery array
    lasttime =  NaN(1,length(IDs)); % initialize time array
    lastlat = NaN(1,length(IDs)); % initialize 
    lastlon = NaN(1,length(IDs)); % initialize 
    
    
    %% loop thru pulling SBDs for each SWIFT ID
    
    for si=1:length(IDs),
        
        baseurl = 'http://swiftserver.apl.washington.edu/services/buoy?action=get_data&buoy_name=';
        buoy = ['SWIFT%20' IDs(si,:) ];
        out = websave(['SWIFT' IDs(si,:) '.zip'],[baseurl buoy  '&start=' starttime '&end=' endtime '&format=zip'],options)
        
        eval(['!unzip SWIFT' IDs(si,:) '.zip']);
        expanded = dir(['*SWIFT ' IDs(si,:) '*']);
        if length(expanded)==1 && expanded(1).isdir == true,
            cd(expanded(1).name)
            
            % run compile SBD, which calls readSWIFT_SBD for each file
            % use a temp file work around the clear all in compile
            save temp si IDs starttime endtime options allbatterylevels lasttime lastlon lastlat
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
    eval(['!cp *SWIFT*/*SWIFT*start*.mat ./'])
    tempfig = mapSWIFT('watertemp');
    salinityfig = mapSWIFT('salinity');
    wavefig = mapSWIFT('sigwaveheight');
    
    clc
    spaces(1:length(IDs)) = ' ';
    commas(1:length(IDs)) = ',';
    Vs(1:length(IDs)) = 'V';
    [IDs commas' spaces' datestr(lasttime) commas' spaces' num2str(lastlat',6) commas' spaces' ...
        num2str(lastlon',6) commas' spaces' num2str(allbatterylevels',3) Vs']
    
    
    
else
    
    disp('input IDs must be two digit strings')
    
    return
    
end