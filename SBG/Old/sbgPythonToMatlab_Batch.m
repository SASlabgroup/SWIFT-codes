% Batch Matlab read-in of SWIFT v4.0 SBG data, as output from python
% readBinaryFromFile_Batch.py module
%
% M. Schwendeman, 12/2016

fileDirectory = '/Users/mike/Dropbox/SWIFT_v4.x/Test Data/LakeWA_Test_14Dec2016/SWIFTv4_14Dec2016/SBG/Raw/20161214';
fileNames = dir([fileDirectory,'/*_ASCII.txt']);
for i = 1:length(fileNames)
    sbgData = sbgPythonToMatlab([fileDirectory '/' fileNames(i).name]);
    save([fileDirectory '/' fileNames(i).name(1:(end-10)) '.mat'],'sbgData')
end