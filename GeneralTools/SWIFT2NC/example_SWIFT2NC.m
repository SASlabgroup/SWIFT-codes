% Example: write a processed SWIFT .mat file to netCDF with SWIFT2NC
%
% Shows the per-file overrides: the met sensor used on this deployment, an
% extra attribute on two variables, and project-level global attributes.
% See help SWIFT2NC and SWIFT_nc_variables for what can be overridden.
%
% Oct 2026 by M. LeClair (using claude)

matfile = 'SWIFT22_17-26Jun2025_L4.mat'; % contains the SWIFT struct array
ncfile = 'SWIFT22_17-26Jun2025_L4.nc';

load(matfile, 'SWIFT');

% Overrides for this file only; each field replaces just that one value
ov = struct();
ov.platform.met = 'Airmar PB200';  % fills {met} in every met variable's instrument
ov.vars.airtemp.comment = 'sensor in a radiation shield';
ov.vars.signature.profile.east.comment = 'not corrected for platform drift';
ov.globals.project = 'Willapa Bay 2025';
ov.globals.contributor = 'M. LeClair (processing)';

SWIFT2NC(SWIFT, ncfile, overrides=ov);

% Read back: variables, then time and the overridden attributes
ncdisp(ncfile, '/', 'min')
time = ncread(ncfile, 'time'); % days or seconds since 1970 (time.timeUnits)
if startsWith(ncreadatt(ncfile, 'time', 'units'), 'seconds')
    time = datetime(time, 'ConvertFrom', 'epochtime');
else
    time = datetime(1970, 1, 1) + days(time);
end
east = ncread(ncfile, 'east'); % [z x time]
fprintf('%d bursts, %s to %s\n', numel(time), time(1), time(end));
fprintf('air_temperature instrument: %s\n', ncreadatt(ncfile, 'air_temperature', 'instrument'));
fprintf('air_temperature comment: %s\n', ncreadatt(ncfile, 'air_temperature', 'comment'));
fprintf('east comment: %s\n', ncreadatt(ncfile, 'east', 'comment'));
