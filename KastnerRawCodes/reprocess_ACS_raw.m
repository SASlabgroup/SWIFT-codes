% reprocess SWIFT v3 ACS results to get raw data
%
% M. Smith 08/2016
%
% S. Kastner 07/2018, include raw data in SWIFT structures
%
% J. Thomson, 9/2019, adjust for more general use
%                       including checking raw file size

% clear all; close all
parentdir = pwd;  % change this to be the parent directory of all raw raw data (CF card offload from SWIFT)
cd(parentdir)

l_ACS=254; % max length of 0.5 Hz ACS file

wd = pwd;
wdi = find(wd == '/',1,'last');
wd = wd((wdi+1):length(wd));

load([wd '_reprocessed.mat']);



if exist([pwd '/COM-9'],'dir')==7 && ~isempty(dir([pwd '/COM-9/Raw/*20*/*ACS*']))     % check number of CT COM ports
    
    numCTs=3;
    
else
    
    numCTs=1;
    
end


if numCTs==1                    % loop through CT COM ports
    
    comlist={'COM-8/'};
    
elseif numCTs==3
    
    comlist={'COM-7/','COM-8/','COM-9/'};
    
    
end

for ci=1:length(comlist)

    cd([char(comlist(ci)) 'Raw'])
    
    dirlist=dir('*20*');

    for di=1:length(dirlist)            % loop through day directories

        cd(dirlist(di).name);

        filelist = dir('*ACS*.dat');

        for fi=1:length(filelist),
            disp(['ACS file ' num2str(fi) ' of ' num2str(length(filelist)) ', directory ' num2str(di) ' of ' ...
                num2str(length(dirlist))])
            
            if filelist(fi).bytes > 4e4,
                
            % read or load raw data
            if isempty(dir([filelist(fi).name(1:end-4) '.mat'])),
                [Conductivity, Temperature, Salinity, Density, Soundspeed] = readSWIFTv3_ACS( filelist(fi).name );
            else
                load([filelist(fi).name(1:end-4) '.mat']),
            end

%             salinity_std(fi)=std(Salinity);
            
                        
           
            ACS_time=datenum(filelist(fi).name(13:21))+datenum(0,0,0,str2num(filelist(fi).name(23:24)),...
                (str2num(filelist(fi).name(26:27))-1)*12,0); % makes time vector of ACS filenames
            
            
            % makes time vector for specific file using l_ACS
            time=ACS_time:datenum(0,0,0,0,0,2):ACS_time+(datenum(0,0,0,0,0,2)*(l_ACS-1)); 
            
            % finds SWIFT index for each ACS_time, knowing SWIFT.time uses start of burst as time stamp
                [tdiff, tindex] = min(abs([SWIFT.time]-ACS_time)); 

            
            if tdiff<datenum(0,0,0,0,12,0); % pre-allocate if tdiff is small
                
                % pre-allocate Salinity, Temperature, Density, Time relative to actual length of time series 
                
                if length(Salinity)<l_ACS;
                    
                    l_diff=l_ACS-length(Salinity);
                    
                    Salinity(end+1:end+l_diff)=NaN*ones(l_diff,1);
                end
                
                if length(Temperature)<l_ACS
                    l_diff=l_ACS-length(Temperature);
                    Temperature(end+1:end+l_diff)=NaN*ones(l_diff,1);
                end
                
                if length(Density)<l_ACS
                    
                    l_diff=l_ACS-length(Density);
                    Density(end+1:end+l_diff)=NaN*ones(l_diff,1);
                end
                
                if length(time)<l_ACS
                    l_diff=l_ACS-length(time);
                    time(end+1:end+l_diff)=NaN*ones(l_diff,1);
                end
                
                % make all vectors same length
                Salinity=Salinity(1:l_ACS);
                Temperature=Temperature(1:l_ACS);
                Density=Density(1:l_ACS);
               
                % NaN Salinity for bad data (short record)
                if isfield(SWIFT,'rawSalinity')==1
                    if length(SWIFT(tindex).rawSalinity)<l_ACS

                       l_diff=l_ACS-length(SWIFT(tindex).rawSalinity);
                       SWIFT(tindex).rawSalinity(end+1:end+l_diff,ci)=NaN*ones(l_diff,1);
                       SWIFT(tindex).rawTemperature(end+1:end+l_diff,ci)=NaN*ones(l_diff,1);
                       SWIFT(tindex).rawDensity(end+1:end+l_diff,ci)=NaN*ones(l_diff,1);
                       SWIFT(tindex).rawACSTime(end+1:end+l_diff,ci)=NaN*ones(l_diff,1);
                    elseif size(SWIFT(tindex).rawSalinity,2)>1 & numCTs==1
                        
                        SWIFT(tindex).rawSalinity=SWIFT(tindex).rawSalinity.';
                        SWIFT(tindex).rawTemperature=SWIFT(tindex).rawTemperature.';
                        
                    end
                
                end

                %             SWIFT(tindex).salinitystd = salinity_std(fi);
                
                % store raw salinity
                SWIFT(tindex).rawSalinity = []; SWIFT(tindex).rawTemperature = []; SWIFT(tindex).rawDensity = [];
                SWIFT(tindex).rawSalinity(:,ci)=Salinity;
                SWIFT(tindex).rawTemperature(:,ci)=Temperature;
                SWIFT(tindex).rawDensity(:,ci)=Density;
                SWIFT(tindex).rawACSTime=time;
                

                clear time tdiff tindex Salinity Temperature Density
               
                
            else
                disp(['time gap too large at ' datestr(ACS_time)])
            end
            
            else
                disp(['file too small'])
            end
        end
        cd ..
    end
    cd(parentdir)
end

save([ wd '_reprocessed.mat'],'SWIFT','-v7.3')