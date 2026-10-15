function [cal,records] = plotSBGmagCalibration3D(source,inclination,options)
%PLOTSBGMAGCALIBRATION3D Fit and plot the 3D SBG magnetometer calibration.
%
%   [cal,records] = plotSBGmagCalibration3D(source,inclination,Name=Value)
%
%   source       a SWIFT mission folder, or a SWIFT .mat file in it. Raw
%                *_SBG_*.mat records are found below the folder.
%   inclination  local magnetic inclination, deg (e.g. WMM).
%
%   Fits the SBG Mag log in the body frame (loadSBGmagRecords; down
%   vectors from the EKF roll/pitch, NED) and plots it against the EKF yaw
%   with plotMagCalibration3D, whose name-value options (Declination,
%   Breaks, Window, Step, SWIFTfile, OutputFile) it takes. The figure goes
%   to <folder>/debug/<mission>_SBG_mag3d.png by default.

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
records = loadSBGmagRecords(folder);
args = namedargs2cell(options);
cal = plotMagCalibration3D(records,folder,inclination,args{:});
end
