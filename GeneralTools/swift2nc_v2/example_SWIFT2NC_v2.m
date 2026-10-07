% Example: write a processed SWIFT .mat file to netCDF with SWIFT2NC_v2
%
% Shows the per-file overrides: the met sensor used on this deployment, an
% extra attribute on two variables, and project-level global attributes.
% See help SWIFT2NC_v2 and SWIFT_nc_schema for what can be overridden.
%
% Oct 2026 by M. LeClair (mleclair)

matfile = 'SWIFT22_17-26Jun2025_L4.mat'; % contains the SWIFT struct array
ncfile = 'SWIFT22_17-26Jun2025_L4.nc';

load(matfile, 'SWIFT');

% Overrides for this file only; each field replaces just that one value
ov = struct();
ov.platform.met = 'Airmar PB200';  % fills {met} in every met variable's instrument
ov.globals.project = 'Willapa Bay 2025';
ov.globals.contributor = 'M. LeClair (processing)';

SWIFT2NC_v2(SWIFT, ncfile, overrides=ov);

% Read back: root variables, then a group variable and its attributes
ncdisp(ncfile, '/', 'min')
time = datetime(ncread(ncfile, 'time'), 'ConvertFrom', 'epochtime');
east = ncread(ncfile, '/signature/profile/eastward_velocity'); % [depth x time]
fprintf('%d bursts, %s to %s\n', numel(time), time(1), time(end));
fprintf('air_temperature instrument: %s\n', ncreadatt(ncfile, 'air_temperature', 'instrument'));
fprintf('eastward_velocity comment: %s\n', ...
    ncreadatt(ncfile, '/signature/profile/eastward_velocity', 'comment'));
