function [cal,records] = plotSIGmagCalibration2D(source,options)
%PLOTSIGMAGCALIBRATION2D Fit and plot the 2D (levelled) Signature magnetometer calibration.
%
%   [cal,records] = plotSIGmagCalibration2D(source,Name=Value)
%
%   source  a SWIFT mission folder, or a SWIFT .mat file in it. Signature
%           burst files (*_SIG_ddMmmyyyy_HH_s.mat) are found below the
%           folder.
%
%   Levels the raw Signature magnetometer with its accelerometer
%   (loadSIGmagRecords) and plots the fit against the onboard heading with
%   plotMagCalibration2D, whose name-value options (Declination, Breaks,
%   Window, Step, SWIFTfile, OutputFile) it takes. The figure goes to
%   <folder>/debug/<mission>_Signature_mag2d.png by default.
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
records = loadSIGmagRecords(folder);
args = namedargs2cell(options);
cal = plotMagCalibration2D(records,folder,args{:},Sensor="Signature", ...
    Reference="onboard heading");
end
