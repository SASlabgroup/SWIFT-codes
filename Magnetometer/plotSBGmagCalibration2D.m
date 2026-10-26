function [cal,records] = plotSBGmagCalibration2D(source,options)
%PLOTSBGMAGCALIBRATION2D Fit and plot the 2D (levelled) SBG magnetometer calibration.
%
%   [cal,records] = plotSBGmagCalibration2D(source,Name=Value)
%
%   source  a SWIFT mission folder, or a SWIFT .mat file in it. Raw
%           *_SBG_*.mat records are found below the folder.
%
%   Levels the SBG Mag log with the EKF roll/pitch (loadSBGmagRecords) and
%   plots the fit against the EKF yaw with plotMagCalibration2D, whose
%   name-value options (Declination, Breaks, Window, Step, SWIFTfile,
%   OutputFile) it takes. The figure goes to
%   <folder>/debug/<mission>_SBG_mag2d.png by default.
%
% mleclair (using claude), Oct 2026

arguments
    source (1,1) string
    options.Declination (1,1) double = 0
    options.Breaks double = []
    options.Window (1,1) double = 24.84/24
    options.Step (1,1) double = 3/24
    options.SWIFTfile string = ""
    options.OutputFile string = ""
end

folder = source;
if isfile(source); folder = fileparts(source); end
records = loadSBGmagRecords(folder);
args = namedargs2cell(options);
cal = plotMagCalibration2D(records,folder,args{:});
end
