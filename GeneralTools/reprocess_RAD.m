function [SWIFT,RAD] = reprocess_RAD(missiondir,savedir,varargin)

% Reprocess SWIFT v4 signature velocities from burst data
%   Loops through burst MAT or DAT files for a given SWIFT deployment,
%   reprocessing signature data: 1) quality control the data, 2) compute
%   mean profiles of velocity, 3) compute dissipation from the HR beam 4)
%   replace signature data in original SWIFT structure with new values 5)
%   save detailed signature data in a separate SIG structure

%      J. Thomson, Sept 2017 (modified from AQH reprocessing)
%       7/2018, fix bug in the burst time stamp applied 4/2019, apply
%       altimeter results to trim profiles
%               and plot echograms, with vertical velocities
