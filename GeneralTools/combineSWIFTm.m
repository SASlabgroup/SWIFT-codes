function [SWIFT] = combineSWIFTm(filelist)
%combineSWIFTm uses file list from dir function to create concatenated and time
%sorted SWIFT structure
%   To get file list 
%{ 
Example:
% Script to find and list all CSV files containing 'cat' in their names
% from a specified directory and its subfolders

% Define the directory to search (change this to your target directory)
baseDir = 'C:\your\directory\path';  % Specify your directory here

% Use dir function with '**' to search recursively through subfolders
filePattern = fullfile(baseDir, '**', '*cat*.csv');
fileList = dir(filePattern);

% If files are found, list them
if isempty(fileList)
    disp('No files found containing "cat" in their names.');
else
    disp('Files found:');
    
    % Loop through each file found and display its full path
    for i = 1:length(fileList)
        % Combine folder path with file name to get full path
        fullFilePath = fullfile(fileList(i).folder, fileList(i).name);
        disp(fullFilePath);
    end
end
%}
it = 1;
for k=1:length(filelist)
    disp('loading...')
    disp(fullfile(filelist(k).folder, filelist(k).name))
    load(fullfile(filelist(k).folder, filelist(k).name));
    if exist('SWIFT', 'var') ==1 % checks for SWIFT structure
        for i = 1:length(SWIFT)
            swift(it) = SWIFT(i);
            it = it+1;
        end
    end
end

SWIFT = swift;
end