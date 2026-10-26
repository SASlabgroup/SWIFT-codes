function [cal,records] = plotSIGmagCalibration3D(source,inclination,options)
%PLOTSIGMAGCALIBRATION3D Fit and plot the 3D Signature magnetometer calibration.
%
%   [cal,records] = plotSIGmagCalibration3D(source,inclination,Name=Value)
%
%   source       a SWIFT mission folder, or a SWIFT .mat file in it.
%                Signature burst files (*_SIG_ddMmmyyyy_HH_s.mat) are found
%                below the folder.
%   inclination  local magnetic inclination, deg (e.g. WMM).
%
%   Fits the raw Signature magnetometer in the body frame
%   (loadSIGmagRecords) and plots it against the onboard heading with
%   plotMagCalibration3D, whose name-value options (Declination, Breaks,
%   Window, Step, SWIFTfile, OutputFile) it takes. The accelerometer
%   direction points up (readSIGmag), so the fit uses -inclination. The
%   figure goes to <folder>/debug/<mission>_Signature_mag3d.png by default.
%
% mleclair (using claude), Oct 2026

arguments
    source (1,1) string
    inclination (1,1) double
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
cal = plotMagCalibration3D(records,folder,-inclination,args{:}, ...
    Sensor="Signature",Reference="onboard heading");
end
