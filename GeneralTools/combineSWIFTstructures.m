% combine SWIFT structures from separate files into a single structure
% this only works if the structures are the same in each file
% set option to force a "simple SWIFT"


clear all, close all

fpath = './';

filelist = dir('*SWIFT*.mat');

forcesimple = false;

Sindex = 0;


for fi=1:length(filelist), 
    
    load(filelist(fi).name),
    
    % Order fields to prevent misfiltering identical structures
    SWIFT = orderfields(SWIFT);

    if forcesimple
        for ii=1:length(SWIFT)
        simpleSWIFT(ii).time = SWIFT(ii).time;
        simpleSWIFT(ii).lat = SWIFT(ii).lat;
        simpleSWIFT(ii).lon = SWIFT(ii).lon;
        simpleSWIFT(ii).sigwaveheight = SWIFT(ii).sigwaveheight;
        simpleSWIFT(ii).peakwaveperiod = SWIFT(ii).peakwaveperiod;
        simpleSWIFT(ii).peakwavedirT = SWIFT(ii).peakwavedirT;
        simpleSWIFT(ii).wavespectra = SWIFT(ii).wavespectra;
        simpleSWIFT(ii).driftspd = SWIFT(ii).driftspd;
        simpleSWIFT(ii).driftdirT = SWIFT(ii).driftdirT;
        simpleSWIFT(ii).watertemp = SWIFT(ii).watertemp;
        simpleSWIFT(ii).salinity = SWIFT(ii).salinity;
        simpleSWIFT(ii).airtemp = SWIFT(ii).airtemp;
        simpleSWIFT(ii).windspd = SWIFT(ii).windspd;
        end
        
        SWIFT = simpleSWIFT;
    
    end

    names = fieldnames(SWIFT);

    % Edit by M. James 2025 to include ALL vars regardless of data or not
    if fi == 1
        
        allSWIFT( Sindex + [1:length(SWIFT)] ) = SWIFT;
        
        allnames = fieldnames(allSWIFT);
        
        Sindex = length(allSWIFT);
        
    elseif fi > 1 && length(names)==length(allnames) && all(all(char(names)==char(allnames)))
        
        allSWIFT( Sindex + [1:length(SWIFT)] ) = SWIFT;
        
        allnames = fieldnames(allSWIFT);
        
        Sindex = length(allSWIFT);
        
    elseif fi > 1 && length(setdiff(names, allnames)) >0 | length(setdiff(allnames, names))
        % Find unique field names that are not common
        uniqueSWIFTFields = setdiff(names, allnames);
        uniqueallSWIFTFields = setdiff(allnames, names);

        fprintf('Missing SWIFT values: %s\n',...
            string([uniqueSWIFTFields;uniqueallSWIFTFields]) )

        % Add in nan to numeric fields as filler
        for i = 1:length(uniqueSWIFTFields);
            if isnumeric(SWIFT(1).(uniqueSWIFTFields{i}))
                for k = 1:length(allSWIFT)
                    allSWIFT(k).(uniqueSWIFTFields{i}) = nan;
                end
            end
        end
        for i = 1:length(uniqueallSWIFTFields);
            if isnumeric(allSWIFT(1).(uniqueallSWIFTFields{i}))
                for k = 1:length(SWIFT)
                    SWIFT(k).(uniqueallSWIFTFields{i}) = nan;
                end
            end
        end
        
        % <<Can add more capability on fillers here>>


        disp('Numeric fields filled in')

        % Reevaluate what is not matching left
        names = fieldnames(SWIFT);
        allnames = fieldnames(allSWIFT);

        uniqueSWIFTFields = setdiff(names, allnames);
        uniqueallSWIFTFields = setdiff(allnames, names);

        fprintf('Removing SWIFT fields: %s\n',...
            string([uniqueSWIFTFields;uniqueallSWIFTFields]) )

        for i = 1:length(uniqueSWIFTFields);
            SWIFT = rmfield(SWIFT, uniqueSWIFTFields{i});
        end
        for i = 1:length(uniqueallSWIFTFields);
            allSWIFT = rmfield(allSWIFT, uniqueallSWIFTFields{i});
        end

        % Order Fields to allSWIFT
        SWIFT = orderfields(SWIFT, fieldnames(allSWIFT));
        
        allSWIFT( Sindex + [1:length(SWIFT)] ) = SWIFT;
        
        allnames = fieldnames(allSWIFT);
        
        Sindex = length(allSWIFT);
        
    else
        disp(['skip ' num2str(fi) ' of ' num2str(length(filelist))])
    end
end

clear SWIFT

SWIFT = allSWIFT;

[sortedtimes sti ] = sort([SWIFT.time]);

SWIFT = SWIFT(sti);

%trimSWIFT_SIGprofiles

%plotSWIFT(SWIFT)

wd = pwd;
wdi = find(wd == '/',1,'last');
wd = wd((wdi+1):length(wd));

save([wd '_allSWIFT'],'SWIFT')
    