% Batch Matlab read-in of SWIFT v4.0 SBG data
%
% M. Schwendeman, 01/2017

projectDirectory = '/Volumes/Data/LC-DRI';
% recursively find subdirectories of project directory
p = genpath(projectDirectory);
psplit = regexp(p,':','split');
numsubdirectories = length(psplit);
% loop through subdirectories, find SBG .dat files, decode binary, save as
% .mat
for j = 1:numsubdirectories
    fileDirectory = psplit{j};
    fileNames = dir([fileDirectory,'/*_SBG_*.dat']);
    numFiles = length(fileNames);
    for i = 1:numFiles
        sbgData = sbgBinaryToMatlab([fileDirectory '/' fileNames(i).name]);
        save([fileDirectory '/' fileNames(i).name(1:(end-4)) '.mat'],'sbgData')
    end
    fclose('all');
end