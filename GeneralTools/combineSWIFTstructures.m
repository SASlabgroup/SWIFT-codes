% combine SWIFT structures from separate files into a single structure
% this only works if the structures are the same in each file
% set option to force a "simple SWIFT"


clear all, close all

fpath = './';

filelist = dir('*SWIFT*.mat');

forcesimple = false;

Sindex = 0;

% Define name of concatenated structure
var = 'hrSWIFT'


for fi=1:length(filelist), 
    
    load(filelist(fi).name),
    
    % Order fields to prevent misfiltering identical structures
    eval([var ' = orderfields(' var ');']);

    if forcesimple
        for ii=1:length(eval(var))
        simpleSWIFT(ii).time = eval([var,'(ii)']).time;
        simpleSWIFT(ii).lat = eval([var,'(ii)']).lat;
        simpleSWIFT(ii).lon = eval([var,'(ii)']).lon;
        simpleSWIFT(ii).sigwaveheight = eval([var,'(ii)']).sigwaveheight;
        simpleSWIFT(ii).peakwaveperiod = eval([var,'(ii)']).peakwaveperiod;
        simpleSWIFT(ii).peakwavedirT = eval([var,'(ii)']).peakwavedirT;
        simpleSWIFT(ii).wavespectra = eval([var,'(ii)']).wavespectra;
        simpleSWIFT(ii).driftspd = eval([var,'(ii)']).driftspd;
        simpleSWIFT(ii).driftdirT = eval([var,'(ii)']).driftdirT;
        simpleSWIFT(ii).watertemp = eval([var,'(ii)']).watertemp;
        simpleSWIFT(ii).salinity = eval([var,'(ii)']).salinity;
        simpleSWIFT(ii).airtemp = eval([var,'(ii)']).airtemp;
        simpleSWIFT(ii).windspd = eval([var,'(ii)']).windspd;
        end
        
        eval([var, '= simpleSWIFT']);
    
    end

    names = fieldnames(eval(var));

    % Edit by M. James 2025 to include ALL vars regardless of data or not
    if fi == 1
        
        allSWIFT( Sindex + [1:length(eval(var))] ) = eval(var);
        
        allnames = fieldnames(allSWIFT);
        
        Sindex = length(allSWIFT);
        
    elseif fi > 1 && length(names)==length(allnames) && all(all(char(names)==char(allnames)))
        
        allSWIFT( Sindex + [1:length(eval(var))] ) = eval(var);
        
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
            if isnumeric(eval([var,'(1).(uniqueSWIFTFields{i})']))
                for k = 1:length(allSWIFT)
                    allSWIFT(k).(uniqueSWIFTFields{i}) = nan;
                end
            end
        end
        for i = 1:length(uniqueallSWIFTFields);
            if isnumeric(allSWIFT(1).(uniqueallSWIFTFields{i}))
                for k = 1:length(eval(var))
                    eval([var,'(k).(uniqueallSWIFTFields{i}) = nan']);
                end
            end
        end
        
        % <<Can add more capability on fillers here>>


        disp('Numeric fields filled in')

        % Reevaluate what is not matching left
        names = fieldnames(eval(var));
        allnames = fieldnames(allSWIFT);

        uniqueSWIFTFields = setdiff(names, allnames);
        uniqueallSWIFTFields = setdiff(allnames, names);

        fprintf('Removing SWIFT fields: %s\n',...
            string([uniqueSWIFTFields;uniqueallSWIFTFields]) )

        for i = 1:length(uniqueSWIFTFields);
            eval([var,' = rmfield(',var,', uniqueSWIFTFields{i})']);
        end
        for i = 1:length(uniqueallSWIFTFields);
            allSWIFT = rmfield(allSWIFT, uniqueallSWIFTFields{i});
        end

        % Order Fields to allSWIFT
        eval([var,' = orderfields(',var,', fieldnames(allSWIFT))']);
        
        allSWIFT( Sindex + [1:length(eval(var))] ) = eval(var);
        
        allnames = fieldnames(allSWIFT);
        
        Sindex = length(allSWIFT);
        
    else
        disp(['skip ' num2str(fi) ' of ' num2str(length(filelist))])
    end
end

clear eval(var)

eval([var,' = allSWIFT']);

[sortedtimes sti ] = sort([eval(var).time]);

eval([var,' = ',var,'(sti)']);

%trimSWIFT_SIGprofiles

%plotSWIFT(SWIFT)

wd = pwd;
wdi = find(wd == '/',1,'last');
wd = wd((wdi+1):length(wd));

save([wd '_all', var],var)
    