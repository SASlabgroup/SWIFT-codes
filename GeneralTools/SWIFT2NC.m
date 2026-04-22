function SWIFT2NC(SWIFT_in,filename)
%
% creates a netCDF file using existing SWIFT structure and writes it into 'filename'
% (must include .nc)
%
%   >> SWIFT2NC(SWIFT, filename)
%
% Use SIWFT ID to determine v3 or v4 (sensors at different depths) 
% and skip substructures that are not supported yet
%
% original by L. Hosekova in 2020
%   Edited on May 1, 2020 by Suneil Iyer for ATOMIC with compliant names
%   Feb 2023 by J. Thomson for SASSIE and general use
%   Nov 2024 by J. Thomson to include microSWIFTs

SWIFT = SWIFT_in;

swiftnum = str2num(strrep(strrep(SWIFT(1).ID, 'SWIFT', ''), ' ', '') );

if length(SWIFT(1).ID) == 3
    micro = true;
else
    micro = false;
end

if isfield(SWIFT,'date')
    SWIFT=rmfield(SWIFT,'date');
end

if isfield(SWIFT,'wavehistogram')
    SWIFT=rmfield(SWIFT,'wavehistogram');
end

if isfield(SWIFT,'battery')
    SWIFT=rmfield(SWIFT,'battery');
end

if isfield(SWIFT,'CTdepth')
    SWIFT=rmfield(SWIFT,'CTdepth');
end

if isfield(SWIFT,'Metheight')
    SWIFT=rmfield(SWIFT,'metheight');
end

if isfield(SWIFT,'salinityvariance')
    SWIFT=rmfield(SWIFT,'salinityvariance');
end

if isfield(SWIFT,'replacedrawvalues')
    SWIFT=rmfield(SWIFT,'replacedrawvalues');
end

if isfield(SWIFT,'salinity') && length(SWIFT(1).salinity)>1
    for si=1:length(SWIFT)
        SWIFT(si).salinity = nanmean(SWIFT(si).salinity);
        SWIFT(si).watertemp = nanmean(SWIFT(si).watertemp);
    end
end

if isfield(SWIFT,'sbdfile')
    SWIFT=rmfield(SWIFT,'sbdfile');
end

if isfield(SWIFT,'battery')
    SWIFT=rmfield(SWIFT,'battery');
end

if isfield(SWIFT,'watertemp2')
    SWIFT=rmfield(SWIFT,'watertemp2');
end

if isfield(SWIFT,'burstID')
    SWIFT=rmfield(SWIFT,'burstID');
end

if isfield(SWIFT,'windspdskew')
    SWIFT=rmfield(SWIFT,'windspdskew');
end

if isfield(SWIFT,'windspdkurt')
    SWIFT=rmfield(SWIFT,'windspdkurt');
end

if isfield(SWIFT,'wavespectra')
    for si=1:length(SWIFT)
        specsize(si) = length(SWIFT(si).wavespectra.freq);
        checkcheck(si) = ~isfield(SWIFT(si).wavespectra,'check');
    end
    % WORKAROUND: reprocess_IMU / reprocess_GPS currently emit variable-
    % length wavespectra across bursts (42 onboard vs ~85 post-processed,
    % and sometimes other lengths). The downstream NetCDF write needs a
    % single freq dimension, and the old code "fixed" this by deleting
    % every burst that didn't match — which silently dropped valid
    % signature/CT/met data and made fields like profile.east all NaN.
    %
    % TODO: fix the reprocessing so it always outputs consistent freq
    % vectors; then this truncate block can go away.
    %
    % For now: truncate any burst with >42 freq bins down to 42 (onboard
    % size, f<=0.5 Hz). Match orientation of a known-good 42-bin burst so
    % the downstream size check doesn't trip on [42 1] vs [1 42].
    long = specsize > 42;
    ref42 = find(specsize == 42, 1);
    for si = find(long)
        nfreq = specsize(si);  % original freq length for this burst
        wsfields = fieldnames(SWIFT(si).wavespectra);
        for f = 1:numel(wsfields)
            v = SWIFT(si).wavespectra.(wsfields{f});
            % Only trim spectral fields (freq, energy, a1, b1, a2, b2,
            % check, ...) — i.e. those that share the freq length. Skip
            % scalars and any field of a different size.
            if isnumeric(v) && numel(v) == nfreq
                v = v(1:42);
                if ~isempty(ref42) && isfield(SWIFT(ref42).wavespectra, wsfields{f})
                    refshape = size(SWIFT(ref42).wavespectra.(wsfields{f}));
                    if numel(v) == prod(refshape)
                        v = reshape(v, refshape);
                    end
                end
                SWIFT(si).wavespectra.(wsfields{f}) = v;
            end
        end
        specsize(si) = 42;
    end
    if any(specsize ~= 42 | checkcheck)
        SWIFT = rmfield(SWIFT,'wavespectra');
    end
end


%% loading variables
% extract dimension sizes: time, freq, z, zHR (if available)

ncid=netcdf.create(filename,'CLOBBER');
t_dim=netcdf.defDim(ncid,'time', length(SWIFT));
full_names=fieldnames(SWIFT);

if isfield(SWIFT,'wavespectra') %&& min(SWIFT(1).wavespectra.freq)>0
    % Find the first non-NaN wavespectra to use as reference
    ref_idx = 1;
    for k=1:length(SWIFT)
        if isfield(SWIFT(k), 'wavespectra') && ~isempty(SWIFT(k).wavespectra)
            % Check if freq field exists and is not all NaN
            if isfield(SWIFT(k).wavespectra, 'freq') && ~all(isnan(SWIFT(k).wavespectra.freq(:)))
                ref_idx = k;
                break;
            end
        end
    end
    % Check if anything deviates from this size. Indiciative of a
    % interpolation/missing data issue in reprocess_IMU/reprocess_GPS
    ref_size = size(SWIFT(ref_idx).wavespectra.freq);
    for k=1:length(SWIFT)
        if isfield(SWIFT(k), 'wavespectra') && ~isempty(SWIFT(k).wavespectra)
            % Check if freq field exists and is not all NaN
            if isfield(SWIFT(k).wavespectra, 'freq')
                current_size = size(SWIFT(k).wavespectra.freq);
                if ~isequal(ref_size, current_size)
                    warning('Wavespectra size mismatch at index %d: expected [%s], got [%s].\nCheck reprocess_IMU, reprocess_GPS for frequency interpolation', ...
                        k, num2str(ref_size), num2str(current_size));
                    break;
                end
            end
        end
    end
    f_dim = netcdf.defDim(ncid,'freq', length(SWIFT(ref_idx).wavespectra.freq));
    spec_names=fieldnames(SWIFT(ref_idx).wavespectra);
end
if isfield(SWIFT,'uplooking')
    z_dim = netcdf.defDim(ncid,'z', length(SWIFT(1).uplooking.z));
    z_names = fieldnames(SWIFT(1).uplooking);
end
if isfield(SWIFT,'downlooking')
    z_dim = netcdf.defDim(ncid,'z', length(SWIFT(1).downlooking.z));
    z_names = fieldnames(SWIFT(1).downlooking);
end
if isfield(SWIFT,'signature')  
    sig_names = fieldnames(SWIFT(1).signature);
    %disp(~isempty(SWIFT(1).signature.HRprofile.z))
    %disp(SWIFT(1).signature.HRprofile.z)

    if isfield(SWIFT(1).signature,'HRprofile')
        if ~isempty(SWIFT(1).signature.HRprofile.z)
            zHR_dim = netcdf.defDim(ncid,'zHR', length(SWIFT(1).signature.HRprofile.z));
            zHR_names = fieldnames(SWIFT(1).signature.HRprofile);
        else
            zHR_names = [];
        end
    else
        zHR_names = [];
    end

    if isfield(SWIFT(1).signature,'profile')
        if ~isempty(SWIFT(1).signature.profile.z)
            z_dim = netcdf.defDim(ncid,'z', length(SWIFT(1).signature.profile.z));
            z_names = fieldnames(SWIFT(1).signature.profile);
        else
            z_names = [];
        end
    else
        z_names = [];
    end

    has_echo = false; echo_ref = 1;
    for t=1:length(SWIFT)
        if isfield(SWIFT(t).signature,'echo') && ~isempty(SWIFT(t).signature.echo)
            has_echo = true; echo_ref = t; break
        end
    end
    if has_echo
        zecho_dim = netcdf.defDim(ncid,'zecho', length(SWIFT(echo_ref).signature.echo));
    end
    has_altimeter = false;
    for t=1:length(SWIFT)
        if isfield(SWIFT(t).signature,'altimeter') && ~isempty(SWIFT(t).signature.altimeter)
            has_altimeter = true; break
        end
    end
end
obs_dim = -1;
obs_size = -1;
if isfield(SWIFT, 'OBS_uncalibrated')
    obs_dim = netcdf.defDim(ncid,'obs_sample', length(SWIFT(1).OBS_uncalibrated));
    obs_size = length(SWIFT(1).OBS_uncalibrated);
end
if isfield(SWIFT, 'OBS_ambient')
    if obs_dim == -1
        obs_dim = netcdf.defDim(ncid,'obs_sample', length(SWIFT(1).OBS_ambient));
        obs_size = length(SWIFT(1).OBS_ambient);
    elseif obs_size ~= length(SWIFT(1).OBS_ambient)
        error('bad obs size')
    end
end
if isfield(SWIFT, 'OBS_calibratedNTU')
    if obs_dim == -1
        obs_dim = netcdf.defDim(ncid,'obs_sample', length(SWIFT(1).OBS_calibratedNTU));
    elseif obs_size ~= length(SWIFT(1).OBS_calibratedNTU);
        error('bad obs size')
    end
end


j=1;
for i=1:length(full_names)
    %if ~strcmp(full_names{i},'ID')
        if strcmp(full_names{i},'signature')
            for t=1:length(SWIFT)
                for iz=1:length(z_names)
                    if ~isempty(SWIFT(t).signature.profile.(z_names{iz}))
                        S.signature.profile.(z_names{iz})(t,:) = SWIFT(t).signature.profile.(z_names{iz})(:);
                    else
                        S.signature.profile.(z_names{iz})(t,:) = NaN(size(S.signature.profile.(z_names{iz})(1,:)));
                    end
                end
                for iz=1:length(zHR_names)
                    if ~isempty(SWIFT(t).signature.HRprofile.(zHR_names{iz}))
                        S.signature.HRprofile.([zHR_names{iz} 'HR'])(t,:) = SWIFT(t).signature.HRprofile.(zHR_names{iz})(:);
                    else
                        S.signature.HRprofile.([zHR_names{iz} 'HR'])(t,:) = NaN(size(S.signature.HRprofile.([zHR_names{iz} 'HR'])(1,:)));
                    end
                end
                if has_echo
                    if isfield(SWIFT(t).signature,'echo') && ~isempty(SWIFT(t).signature.echo)
                        S.signature.echo(t,:)  = SWIFT(t).signature.echo(:);
                        S.signature.echoz(t,:) = SWIFT(t).signature.echoz(:);
                    else
                        S.signature.echo(t,:)  = NaN(1, length(SWIFT(echo_ref).signature.echo));
                        S.signature.echoz(t,:) = NaN(1, length(SWIFT(echo_ref).signature.echo));
                    end
                end
                if has_altimeter
                    if isfield(SWIFT(t).signature,'altimeter') && ~isempty(SWIFT(t).signature.altimeter)
                        S.signature.altimeter(t) = SWIFT(t).signature.altimeter;
                    else
                        S.signature.altimeter(t) = NaN;
                    end
                end
            end
        elseif strcmp(full_names{i},'time')
            S.time= [SWIFT.time]-datenum(1970,1,1,0,0,0);
        elseif strcmp(full_names{i},'ID')
            S.ID = ones(length(SWIFT),1) * swiftnum;
        else
            tmp = [SWIFT.(full_names{i})]; % errors here if check factor in some but not all
            if isempty(tmp)
                fprintf('SWIFT2NC: dropping empty field %s\n', full_names{i});
                if isfield(S, full_names{i}), S = rmfield(S, full_names{i}); end
                continue
            end
            if numel(tmp) ~= length(SWIFT)
                fprintf('SWIFT2NC: filling field %s (%d of %d bursts present) with NaN elsewhere\n', ...
                    full_names{i}, numel(tmp), length(SWIFT));
                tmp = NaN(1, length(SWIFT));
                for tt = 1:length(SWIFT)
                    v = SWIFT(tt).(full_names{i});
                    if isscalar(v) && isnumeric(v)
                        tmp(tt) = v;
                    end
                end
            end
            S.(full_names{i}) = tmp;
        end
        names{j} = full_names{i};
        j = j+1;
   % end
end


%% creating netcdf variables
for i=1:length(names)
    if strcmp(names{i},'OBS_uncalibrated')
        var_ids.(names{i})  = netcdf.defVar(ncid, 'OBS_uncalibrated', 'NC_INT', [obs_dim, t_dim]);
    elseif strcmp(names{i},'OBS_ambient')
        var_ids.(names{i})  = netcdf.defVar(ncid, 'OBS_ambient', 'NC_INT', [obs_dim, t_dim]);
    elseif strcmp(names{i},'OBS_calibratedNTU')
        var_ids.(names{i}) = netcdf.defVar(ncid, 'OBS_calibratedNTU', 'NC_INT', [obs_dim, t_dim]);
    elseif strcmp(names{i},'wavespectra')
        for j=1:length(spec_names)
            if strcmp(spec_names{j},'freq')
                spec_var_ids.(spec_names{j}) = netcdf.defVar(ncid, spec_names{j}, 'NC_DOUBLE', f_dim);
            else
                spec_var_ids.(spec_names{j}) = netcdf.defVar(ncid, spec_names{j}, 'NC_DOUBLE', [f_dim, t_dim]);
            end
        end
    elseif strcmp(names{i},'uplooking') || strcmp(names{i},'downlooking')
        for j=1:length(z_names)
            if strcmp(z_names{j},'z')
                z_var_ids.(z_names{j}) = netcdf.defVar(ncid, z_names{j}, 'NC_DOUBLE', z_dim);
                %             elseif strcmp(z_names{j},'tkedissipationrate')
                %                 z_var_ids.(z_names{j}) = netcdf.defVar(ncid, z_names{j}, 'NC_DOUBLE', t_dim);
            else
                z_var_ids.(z_names{j}) = netcdf.defVar(ncid, z_names{j}, 'NC_DOUBLE', [t_dim z_dim]);
            end
        end
    elseif strcmp(names{i},'signature')
        for j=1:length(z_names)
            if strcmp(z_names{j},'altimeter')
                z_var_ids.(z_names{j}) = netcdf.defVar(ncid, z_names{j}, 'NC_DOUBLE', t_dim);
            elseif strcmp(z_names{j},'z')
                z_var_ids.(z_names{j}) = netcdf.defVar(ncid, z_names{j}, 'NC_DOUBLE', z_dim);
            else
                z_var_ids.(z_names{j}) = netcdf.defVar(ncid, z_names{j}, 'NC_DOUBLE', [t_dim z_dim]);
            end
        end
        for j=1:length(zHR_names)
            if strcmp(zHR_names{j},'z')
                zHR_var_ids.([zHR_names{j} 'HR']) = netcdf.defVar(ncid, [zHR_names{j} 'HR'], 'NC_DOUBLE', zHR_dim);
            else
                zHR_var_ids.([zHR_names{j} 'HR']) = netcdf.defVar(ncid, [zHR_names{j} 'HR'], 'NC_DOUBLE', [t_dim zHR_dim]);
            end
        end
        if has_echo
            echo_var_ids.echo  = netcdf.defVar(ncid, 'echo',  'NC_DOUBLE', [t_dim zecho_dim]);
            echo_var_ids.echoz = netcdf.defVar(ncid, 'echoz', 'NC_DOUBLE', [t_dim zecho_dim]);
        end
        if has_altimeter
            echo_var_ids.altimeter = netcdf.defVar(ncid, 'altimeter', 'NC_DOUBLE', t_dim);
        end
        %edit variable names to CF convention names - do this for all vars
        %with different names than the SWIFT defaults
   elseif strcmp(names{i},'ID')
        var_ids.(names{i}) = netcdf.defVar(ncid, 'trajectory', 'NC_DOUBLE', t_dim);
    elseif strcmp(names{i},'lon')
        var_ids.(names{i}) = netcdf.defVar(ncid, 'lon', 'NC_DOUBLE', t_dim);
    elseif strcmp(names{i},'lat')
        var_ids.(names{i}) = netcdf.defVar(ncid, 'lat', 'NC_DOUBLE', t_dim);
    elseif strcmp(names{i},'watertemp')
        var_ids.(names{i}) = netcdf.defVar(ncid, 'sea_water_temperature', 'NC_DOUBLE', t_dim);
    elseif strcmp(names{i},'watertemp_d2')
        var_ids.(names{i}) = netcdf.defVar(ncid, 'sea_water_temperature_at_depth', 'NC_DOUBLE', t_dim);
    elseif strcmp(names{i},'airtemp')
        var_ids.(names{i}) = netcdf.defVar(ncid, 'air_temperature', 'NC_DOUBLE', t_dim);
    elseif strcmp(names{i},'salinity')
        var_ids.(names{i}) = netcdf.defVar(ncid, 'sea_water_salinity', 'NC_DOUBLE', t_dim);
    elseif strcmp(names{i},'salinity_d2')
        var_ids.(names{i}) = netcdf.defVar(ncid, 'sea_water_salinity_at_depth', 'NC_DOUBLE', t_dim);
    elseif strcmp(names{i},'qa')
        var_ids.(names{i}) = netcdf.defVar(ncid, 'specific_humidity', 'NC_DOUBLE', t_dim);
    elseif strcmp(names{i},'peakwavedirT')
        var_ids.(names{i}) = netcdf.defVar(ncid, 'peak_wave_direction', 'NC_DOUBLE', t_dim);
    elseif strcmp(names{i},'peakwaveperiod')
        var_ids.(names{i}) = netcdf.defVar(ncid, 'peak_wave_period', 'NC_DOUBLE', t_dim);
    elseif strcmp(names{i},'centroidwaveperiod')
        var_ids.(names{i}) = netcdf.defVar(ncid, 'mean_wave_period', 'NC_DOUBLE', t_dim);
    elseif strcmp(names{i},'sigwaveheight')
        var_ids.(names{i}) = netcdf.defVar(ncid, 'significant_wave_height', 'NC_DOUBLE', t_dim);
    elseif strcmp(names{i},'mss')
        var_ids.(names{i}) = netcdf.defVar(ncid, 'wave_mean_square_slope', 'NC_DOUBLE', t_dim);
    elseif strcmp(names{i},'ustar')
        var_ids.(names{i}) = netcdf.defVar(ncid, 'friction_velocity_in_air_from_wave_spectra', 'NC_DOUBLE', t_dim);
    elseif strcmp(names{i},'airtempstddev')
        var_ids.(names{i}) = netcdf.defVar(ncid, 'air_temperature_stddev', 'NC_DOUBLE', t_dim);
    elseif strcmp(names{i},'windspd')
        var_ids.(names{i}) = netcdf.defVar(ncid, 'wind_speed', 'NC_DOUBLE', t_dim);
    elseif strcmp(names{i},'windspdstddev')
        var_ids.(names{i}) = netcdf.defVar(ncid, 'wind_speed_stddev', 'NC_DOUBLE', t_dim);
    elseif strcmp(names{i},'winddirT')
        var_ids.(names{i}) = netcdf.defVar(ncid, 'wind_direction', 'NC_DOUBLE', t_dim);
    elseif strcmp(names{i},'winddirTstddev')
        var_ids.(names{i}) = netcdf.defVar(ncid, 'wind_direction_stddev', 'NC_DOUBLE', t_dim);
    elseif strcmp(names{i},'driftspd')
        var_ids.(names{i}) = netcdf.defVar(ncid, 'drift_speed', 'NC_DOUBLE', t_dim);
    elseif strcmp(names{i},'driftdirT')
        var_ids.(names{i}) = netcdf.defVar(ncid, 'drift_direction', 'NC_DOUBLE', t_dim);
    elseif strcmp(names{i},'relhumidity')
        var_ids.(names{i}) = netcdf.defVar(ncid, 'relative_humidity', 'NC_DOUBLE', t_dim);
    elseif strcmp(names{i},'qsea')
        var_ids.(names{i}) = netcdf.defVar(ncid, 'sea_surface_saturation_specific_humidity', 'NC_DOUBLE', t_dim);
    elseif strcmp(names{i},'qair')
        var_ids.(names{i}) = netcdf.defVar(ncid, 'specific_humidity', 'NC_DOUBLE', t_dim);
    elseif strcmp(names{i},'relhumiditystddev')
        var_ids.(names{i}) = netcdf.defVar(ncid, 'relative_humidity_stddev', 'NC_DOUBLE', t_dim);
    elseif strcmp(names{i},'airpres')
        var_ids.(names{i}) = netcdf.defVar(ncid, 'air_pressure', 'NC_DOUBLE', t_dim);
    elseif strcmp(names{i},'airpresstddev')
        var_ids.(names{i}) = netcdf.defVar(ncid, 'air_pressure_stddev', 'NC_DOUBLE', t_dim);
%     elseif strcmp(names{i},'flag_values_watertemp')
%         var_ids.(names{i}) = netcdf.defVar(ncid, 'flag_values_watertemp', 'NC_DOUBLE', t_dim);
%     elseif strcmp(names{i},'flag_values_airtemp')
%         var_ids.(names{i}) = netcdf.defVar(ncid, 'flag_values_airtemp', 'NC_DOUBLE', t_dim);
%     elseif strcmp(names{i},'flag_values_humidity')
%         var_ids.(names{i}) = netcdf.defVar(ncid, 'flag_values_humidity', 'NC_DOUBLE', t_dim);
%     elseif strcmp(names{i},'flag_values_windpsd')
%         var_ids.(names{i}) = netcdf.defVar(ncid, 'flag_values_windspd', 'NC_DOUBLE', t_dim);
%     elseif strcmp(names{i},'flag_values_salinity')
%         var_ids.(names{i}) = netcdf.defVar(ncid, 'flag_values_salinity', 'NC_DOUBLE', t_dim);

    elseif ~strcmp(names{i},'ID')
        var_ids.(names{i}) = netcdf.defVar(ncid, names{i}, 'NC_DOUBLE', t_dim);

    end
end


% define some global attributes
varid = netcdf.getConstant('GLOBAL');
netcdf.putAtt(ncid,varid,'creation_date',datestr(now));
netcdf.putAtt(ncid,varid,'creator','Jim Thomson (APL-UW)');
netcdf.putAtt(ncid,varid,'please_acknowledge:','investigator above');
netcdf.putAtt(ncid,varid,'institution','Applied Physics Laboratory at the University of Washington (APL-UW)');
netcdf.putAtt(ncid,varid,'contact_email_1','jthomson@apl.washington.edu');
netcdf.putAtt(ncid,varid,'id', swiftnum);
%netcdf.putVar(ncid,varid,'trajectory', SWIFT(1).ID );

if ~micro %2 digit input number = SWIFT
    netcdf.putAtt(ncid,varid,'description',['Data collected from Surface Wave Instrument Float with Tracking (SWIFT) ' num2str(swiftnum) '.  See www.apl.uw.edu/SWIFT for more information']);
end
%netcdf.putAtt(ncid,varid,'comment','Corrections were applied to air temperature, water temperature, wind speed, relative humidity, and salinity data to account for offsets between individual sensors. This was done by assuming the ship data were correct and calculating average linear offsets for night-time points within 2-15 km of the ship (distance dictated by data availability). ');
%netcdf.putAtt(ncid,varid,'comment2','Sensor correction offsets were 0-3 degrees C (air temperature), 0-0.4 degrees C (water temperature), 0-2 m/s (wind speed), 0-2.1% (relative humidity), and 0-0.4 psu (salinity). See references 1,2.');
% if swiftnum < 21.5
%     netcdf.putAtt(ncid,varid,'comment3','"flag_values" variables flag poor quality (flag=2) or questionable (flag=1) data. Poor data (flag=2) usually result from unrealistic diurnal heating of sensors. Questionable data generally consist of low spikes that may result from atmospheric cold pools, but may also result from sea spray impacting atmospheric measurements. Air temperature data were flagged as questionable when air temperature changed by more than 0.5 degrees over 3 hours or wind speeds were greater than 7 m/s. Air temperature data were flagged as bad and removed during the day (10:00 to 22:00 UTC). Before using data flagged as questionable, it is recommended that air temperature/humidity spikes are verified with nearby ship observations. Variables without an ancillary flag variable were determined to not contain questionable data.');
% end
% if swiftnum > 21.5 && ~micro
%     netcdf.putAtt(ncid,varid,'comment3','"flag_values" variables flag poor quality (flag=2) or questionable (flag=1) data, possibly resulting sea spray impacting atmospheric measurements. Air temperature and relative humidity data were flagged as questionable when air temperature or relative humidity changed by more than 0.5 degrees or 3% over 3 hours. Most of these rapid temperature/humidity changes are likely reasonable (compare well with atmospheric cold pools observed by the nearby NOAA Ship Ronald H. Brown). Before using data flagged as questionable, it is recommended that air temperature/humidity spikes are verified with nearby ship observations. Variables without an ancillary flag variable were determined to not contain questionable data.');
% end
% if micro
%     netcdf.putAtt(ncid,varid,'comment3','"flag_values" variables flag poor quality (flag=2) or questionable (flag=1) data, usually resulting from either the unrealistic diurnal heating of sensors or sea spray impacting atmospheric measurements. Air temperature data were flagged as questionable when air temperature changed by more than 0.5 degrees over 3 hours or wind speeds were greater than 8.5 m/s. Air temperature and air pressure data were flagged as bad and removed when air temperature changed by more than 1.0 degrees over 3 hours and/or during the day (10:00 to 22:00 UTC). Before using data flagged as questionable, it is recommended that air temperature/humidity spikes are verified with nearby ship observations. Variables without an ancillary flag variable were determined to not contain questionable data.');
% end
% netcdf.putAtt(ncid,varid,'comment4','Ocean "flag_values" variables: Salinity data were flagged as questionable (flag=1) when salinity changed by over 0.02 psu in 3 hours and were flagged as bad and removed when salinity changed by greater than 0.04 psu in 3 hours. Ocean temperature data were flagged (very few points) based on visual identification of poor or questionable data. Variables without an ancillary flag variable were determined to not contain questionable data.');
if ~micro
    netcdf.putAtt(ncid,varid,'temporal_sampling','Data from are ensembles values calculated from 512 secs of raw data recorded at 4 Hz.');
    netcdf.putAtt(ncid,varid,'reference1','Thomson, J., (2012). Wave breaking dissipation observed with SWIFT drifters, Journal of Atmospheric and Oceanic Technology, http://dx.doi.org/10.1175/JTECH-D-12-00018.1');
    netcdf.putAtt(ncid,varid,'reference2','https://github.com/SASlabgroup/SWIFT-codes,https://doi.org/10.5281/zenodo.13922183');
end

netcdf.putAtt(ncid,varid,'level','Version 1');
netcdf.putAtt(ncid,varid,'history','Version 1');
%netcdf.putAtt(ncid,varid,'missing_data_flag','-999');
netcdf.putAtt(ncid,varid,'_FillValue',nan);


%adjust attributes for a microSWIFT
if micro 
    netcdf.putAtt(ncid,varid,'description', 'Data collected from a microSWIFT buoy.  See www.apl.uw.edu/SWIFT for more information' );
    netcdf.putAtt(ncid,varid,'temporal_sampling','Data from are ensembles values calculated from 1024 secs of raw data recorded at 4 Hz.');
    netcdf.putAtt(ncid,varid,'reference1','Thomson et al, Development and testing of microSWIFT expendable wave buoys, Coastal Engineering Journal, https://doi.org/10.1080/21664250.2023.2283325');
    netcdf.putAtt(ncid,varid,'reference2','https://github.com/SASlabgroup/SWIFT-codes, https://doi.org/10.5281/zenodo.13922183');
end


netcdf.endDef(ncid);
%% filling them with values

for i=1:length(names)
    if strcmp(names{i},'OBS_uncalibrated')
        netcdf.putVar(ncid, var_ids.(names{i}), S.OBS_uncalibrated)
    elseif strcmp(names{i},'OBS_ambient')
        netcdf.putVar(ncid, var_ids.(names{i}), S.OBS_ambient)
    elseif strcmp(names{i},'OBS_calibratedNTU')
        netcdf.putVar(ncid, var_ids.(names{i}), S.OBS_calibratedNTU)
    elseif strcmp(names{i},'wavespectra') & exist('spec_names', 'var')
        for j=1:length(spec_names)
            if strcmp(spec_names{j},'freq')
                netcdf.putVar(ncid, spec_var_ids.(spec_names{j}), S.wavespectra(ref_idx).freq);
            else
                % First element with non-NaN data to get the reference size
                ref_size = size(S.wavespectra(ref_idx).(spec_names{j}));
                
                % Pre-allocate cell array to store each field
                temp_data = cell(1, length(S.wavespectra));
                
                % Loop through each element
                for k=1:length(S.wavespectra)
                    current_data = S.wavespectra(k).(spec_names{j});
                    current_size = size(current_data);
                    
                    % Check if size matches
                    if isequal(current_size, ref_size)
                        temp_data{k} = current_data;
                    else
                        % Replace with NaNs of the correct size
                        temp_data{k} = nan(ref_size);
                    end
                end
                
                % Concatenate verticaly and then transpose. [] was not
                % working
                netcdf.putVar(ncid, spec_var_ids.(spec_names{j}), vertcat(temp_data{:}).');
            end
        end
    elseif strcmp(names{i},'uplooking')
        for j=1:length(z_names)
            if strcmp(z_names{j},'z')
                netcdf.putVar(ncid, z_var_ids.(z_names{j}), S.uplooking(1).z);
            else
                netcdf.putVar(ncid, z_var_ids.(z_names{j}), [S.uplooking.(z_names{j})]);
            end

        end
    elseif strcmp(names{i},'downlooking')
        for j=1:length(z_names)
            if strcmp(z_names{j},'z')
                netcdf.putVar(ncid, z_var_ids.(z_names{j}), S.downlooking(1).z);
            else
                netcdf.putVar(ncid, z_var_ids.(z_names{j}), [S.downlooking.(z_names{j})]);
            end
        end
    elseif strcmp(names{i},'signature')
        for j=1:length(z_names)
            if strcmp(z_names{j},'z')
                netcdf.putVar(ncid, z_var_ids.(z_names{j}), S.signature.profile.z(1,:));
            else
                netcdf.putVar(ncid, z_var_ids.(z_names{j}), [S.signature.profile.(z_names{j})]);
            end
        end
        for j=1:length(zHR_names)
            if strcmp(zHR_names{j},'z')
                netcdf.putVar(ncid, zHR_var_ids.([zHR_names{j} 'HR']),  S.signature.HRprofile.zHR(1,:));
            else
                netcdf.putVar(ncid, zHR_var_ids.([zHR_names{j} 'HR']), [S.signature.HRprofile.([zHR_names{j} 'HR'])]);
            end
        end
        if has_echo
            netcdf.putVar(ncid, echo_var_ids.echo,  S.signature.echo);
            netcdf.putVar(ncid, echo_var_ids.echoz, S.signature.echoz);
        end
        if has_altimeter
            netcdf.putVar(ncid, echo_var_ids.altimeter, S.signature.altimeter);
        end
    else
        if numel(S.(names{i})) ~= length(SWIFT)
            fprintf('SWIFT2NC: size mismatch for %s: numel=%d, expected %d\n', ...
                names{i}, numel(S.(names{i})), length(SWIFT));
        end
        netcdf.putVar(ncid, var_ids.(names{i}), S.(names{i}));
    end
end


netcdf.close(ncid)


%% units and descriptions

% Open the file once and stay in define mode for the whole attribute
% section. ncwriteatt reopens/redefs/closes per call, which is ~dozens
% of seconds per variable for a classic netcdf3 file.
ncid_attr = netcdf.open(filename, 'WRITE');
netcdf.reDef(ncid_attr);
putAtt(ncid_attr, '__reset__');  % ncids get reused across files in batch

putAtt(ncid_attr, 'trajectory', 'trajectory_id', SWIFT(1).ID);

for i=1:length(names)
    if strcmp(names{i},'OBS_uncalibrated')
        putAtt(ncid_attr,'OBS_uncalibrated','units','digital count')
        putAtt(ncid_attr,'OBS_uncalibrated','long_name','Raw optical back scatter sensor count')
        putAtt(ncid_attr,'OBS_uncalibrated','instrument','OpenOBS')
    elseif strcmp(names{i},'OBS_ambient')
        putAtt(ncid_attr,'OBS_ambient','units','digital count')
        putAtt(ncid_attr,'OBS_ambient','long_name','Raw optical back scatter sensor count (ambient)')
        putAtt(ncid_attr,'OBS_ambient','instrument','OpenOBS')
    elseif strcmp(names{i},'OBS_calibratedNTU')
        putAtt(ncid_attr,'OBS_calibratedNTU','units','Nephelometric Turbidity Uni')
        putAtt(ncid_attr,'OBS_calibratedNTU','long_name','Calibrated NTU from optical back scatter')
        putAtt(ncid_attr,'OBS_calibratedNTU','instrument','openOBS')
        putAtt(ncid_attr,'OBS_calibratedNTU','method','Optical backscatter as shown in Eidem et al. Limnology and Oceanography: Methods, 2022')
    elseif strcmp(names{i},'wavespectra')
        for j=1:length(spec_names)
            if strcmp(spec_names(j),'a1')
                putAtt(ncid_attr,'a1','units',' ')
                putAtt(ncid_attr,'a1','long_name','normalized spectral directional moment (positive east)')
                if swiftnum < 18 && ~micro %v3 SWIFT
                    putAtt(ncid_attr,'a1','instrument','Microstrain 3DM-GX3-35/AHRS')
                elseif swiftnum >= 18 && ~micro %v4 SWIFT
                    putAtt(ncid_attr,'a1','instrument','SBG Ellipse/AHRS')
                elseif micro % microSWIFT
                    putAtt(ncid_attr,'a1','instrument','GPSWaves / NEDwaves')
                end
                putAtt(ncid_attr,'a1','method','Wave spectral processing as shown in Thomson et al., JTech, 2018.')
            end
            if strcmp(spec_names(j),'b1')
                putAtt(ncid_attr,'b1','units',' ')
                putAtt(ncid_attr,'b1','long_name','normalized spectral directional moment (positive north)')
                if swiftnum < 18 && ~micro%v3 SWIFT
                    putAtt(ncid_attr,'b1','instrument','Microstrain 3DM-GX3-35/AHRS')
                elseif swiftnum >= 18 && ~micro %v4 SWIFT
                    putAtt(ncid_attr,'b1','instrument','SBG Ellipse/AHRS')
                elseif micro % microSWIFT
                    putAtt(ncid_attr,'b1','instrument','GGPSWaves / NEDwaves')
                end
                putAtt(ncid_attr,'b1','method','Wave spectral processing as shown in Thomson et al., JTech, 2018.')
            end
            if strcmp(spec_names(j),'a2')
                putAtt(ncid_attr,'a2','units',' ')
                putAtt(ncid_attr,'a2','long_name','normalized spectral directional moment (east-west)')
                if swiftnum < 18 && ~micro %v3 SWIFT
                    putAtt(ncid_attr,'a2','instrument','Microstrain 3DM-GX3-35/AHRS')
                elseif swiftnum >= 18 && ~micro %v4 SWIFT
                    putAtt(ncid_attr,'a2','instrument','SBG Ellipse/AHRS')
                elseif micro % microSWIFT
                    putAtt(ncid_attr,'a2','instrument','GPSWaves / NEDwaves')
                end
                putAtt(ncid_attr,'a2','method','Wave spectral processing as shown in Thomson et al., JTech, 2018.')
            end
            if strcmp(spec_names(j),'b2')
                putAtt(ncid_attr,'b2','units',' ')
                putAtt(ncid_attr,'b2','long_name','normalized spectral directional moment (north-south)')
                if swiftnum < 18 && ~micro %v3 SWIFT
                    putAtt(ncid_attr,'b2','instrument','Microstrain 3DM-GX3-35/AHRS')
                elseif swiftnum >= 18 && ~micro %v4 SWIFT
                    putAtt(ncid_attr,'b2','instrument','SBG Ellipse/AHRS')
                elseif micro % microSWIFT
                    putAtt(ncid_attr,'b2','instrument','GPSWaves / NEDwaves')
                end
                putAtt(ncid_attr,'b2','method','Wave spectral processing as shown in Thomson et al., JTech, 2018.')
            end
            if strcmp(spec_names(j),'energy')
                putAtt(ncid_attr,'energy','units','m^2/Hz')
                putAtt(ncid_attr,'energy','long_name','wave energy spectral density as a function of frequency')
                putAtt(ncid_attr,'energy','standard_name','sea_surface_wave_variance_spectral_density')
                if swiftnum < 18 && ~micro %v3 SWIFT
                    putAtt(ncid_attr,'energy','instrument','Microstrain 3DM-GX3-35/AHRS')
                elseif swiftnum >= 18 && ~micro %v4 SWIFT
                    putAtt(ncid_attr,'energy','instrument','SBG Ellipse/AHRS')
                elseif micro % microSWIFT
                    putAtt(ncid_attr,'energy','instrument','GPSWaves / NEDwaves')
                end
                putAtt(ncid_attr,'energy','method','Wave spectral processing as shown in Thomson et al., JTech, 2018.')
            end
            if strcmp(spec_names(j),'freq')
                putAtt(ncid_attr,'freq','units','Hz')
                putAtt(ncid_attr,'freq','long_name','spectral frequencies')
                putAtt(ncid_attr,'freq','standard_name','wave_frequency')
                if swiftnum < 18 && ~micro %v3 SWIFT
                    putAtt(ncid_attr,'freq','instrument','Microstrain 3DM-GX3-35/AHRS')
                elseif swiftnum >= 18 && ~micro %v4 SWIFT
                    putAtt(ncid_attr,'freq','instrument','SBG Ellipse/AHRS')
                elseif micro % microSWIFT
                    putAtt(ncid_attr,'freq','instrument','GPSWaves / NEDwaves')
                end
                putAtt(ncid_attr,'freq','method','Wave spectral processing as shown in Thomson et al., JTech, 2018.')
            end
            if strcmp(spec_names(j),'check')
                putAtt(ncid_attr,'check','units',' ')
                putAtt(ncid_attr,'check','long_name','spectral check factor')
                %putAtt(ncid_attr,'check','standard_name','wave_check factor')
                if swiftnum < 18 && ~micro %v3 SWIFT
                    putAtt(ncid_attr,'freq','instrument','Microstrain 3DM-GX3-35/AHRS')
                elseif swiftnum >= 18 && ~micro %v4 SWIFT
                    putAtt(ncid_attr,'freq','instrument','SBG Ellipse/AHRS')
                elseif micro % microSWIFT
                    putAtt(ncid_attr,'freq','instrument','GPSWaves / NEDwaves')
                end
                putAtt(ncid_attr,'check','method','Wave spectral processing as shown in Thomson et al., JTech, 2018.')
            end
        end

    elseif strcmp(names{i},'uplooking')
        for j=1:length(z_names)
            if strcmp(z_names(j),'tkedissipationrate')
                putAtt(ncid_attr,'tkedissipationrate','units','W/kg')
                putAtt(ncid_attr,'tkedissipationrate','long_name','vertical profiles of turbulent dissipation rate beneath the wave-following free surface')
                putAtt(ncid_attr,'tkedissipationrate','standard_name','specific_turbulent_kinetic_energy_dissipation_in_sea_water')
                if swiftnum < 18 && ~micro %v3 SWIFT
                    putAtt(ncid_attr,'tkedissipationrate','instrument','Nortek Aquadopp ADCP')
                elseif swiftnum >= 18 && ~micro %v4 SWIFT
                    putAtt(ncid_attr,'tkedissipationrate','instrument','Nortek Signature 1000 ADCP with AHRS')
                    putAtt(ncid_attr,'tkedissipationrate','comments','Initial examination of these data suggest that these data are questionable as calculated dissipation rates do not decrease with depth. Use with caution.')
                end
            end
            if strcmp(z_names(j),'z')
                putAtt(ncid_attr,'z','units','m')
                putAtt(ncid_attr,'z','long_name','depth bins for the tke dissipation rate profiles')
                putAtt(ncid_attr,'z','standard_name','depth')
            end
        end
    elseif strcmp(names{i},'downlooking')
        for j=1:length(z_names)
            if strcmp(z_names(j),'velocityprofile')
                putAtt(ncid_attr,'velocityprofile','units','m/s')
                putAtt(ncid_attr,'velocityprofile','long_name','vertical profiles of horizontal velocity magnitude relative to the float (not corrected for drift)')
                if swiftnum < 18 && ~micro %v3 SWIFT
                    putAtt(ncid_attr,'velocityprofile','instrument','Nortek Aquadopp ADCP')
                elseif swiftnum >= 18 && ~micro %v4 SWIFT
                    putAtt(ncid_attr,'velocityprofile','instrument','Nortek Signature 1000 ADCP with AHRS')
                elseif swiftnum >=100 %WG
                    putAtt(ncid_attr,'velocityprofile','instrument','RDI Workhorse Monitor 300 kHz ADCP')
                end
            end
            if strcmp(z_names(j),'z')
                putAtt(ncid_attr,'z','units','m')
                putAtt(ncid_attr,'z','long_name','depth bins for the velocity rate profiles')
                putAtt(ncid_attr,'z','standard_name','depth')
            end
        end
    elseif strcmp(names{i},'signature')
        for j=1:length(z_names)
            if strcmp(z_names(j),'tkedissipationrate')
                putAtt(ncid_attr,'tkedissipationrate','units','W/kg')
                putAtt(ncid_attr,'tkedissipationrate','long_name','turbulent dissipation rate')
                putAtt(ncid_attr,'tkedissipationrate','standard_name','specific_turbulent_kinetic_energy_dissipation_in_sea_water')
                if swiftnum < 18 && ~micro %v3 SWIFT
                    putAtt(ncid_attr,'tkedissipationrate','instrument','Nortek Aquadopp ADCP')
                elseif swiftnum >= 18 && ~micro %v4 SWIFT
                    putAtt(ncid_attr,'tkedissipationrate','instrument','Nortek Signature 1000 ADCP with AHRS')
                end
            end
            if strcmp(z_names(j),'z')
                putAtt(ncid_attr,'z','units','m')
                putAtt(ncid_attr,'z','long_name','depth bins for currents')
                putAtt(ncid_attr,'z','standard_name','depth')
            end
            if strcmp(z_names(j),'east')
                putAtt(ncid_attr,'east','units','m/s')
                putAtt(ncid_attr,'east','long_name','eastward currents')
                putAtt(ncid_attr,'east','standard_name','eastward_sea_water_velocity')
                if swiftnum < 18 && ~micro %v3 SWIFT
                    putAtt(ncid_attr,'east','instrument','Nortek Aquadopp ADCP')
                elseif swiftnum >= 18 && ~micro %v4 SWIFT
                    putAtt(ncid_attr,'east','instrument','Nortek Signature 1000 ADCP with AHRS')
                elseif swiftnum >=100 %WG
                    putAtt(ncid_attr,'east','instrument','RDI Workhorse Monitor 300 kHz ADCP')
                end
            end
            if strcmp(z_names(j),'north')
                putAtt(ncid_attr,'north','units','m/s')
                putAtt(ncid_attr,'north','long_name','northward currents')
                putAtt(ncid_attr,'north','standard_name','northward_sea_water_velocity')
                if swiftnum < 18 && ~micro %v3 SWIFT
                    putAtt(ncid_attr,'north','instrument','Nortek Aquadopp ADCP')
                elseif swiftnum >= 18 && ~micro %v4 SWIFT
                    putAtt(ncid_attr,'north','instrument','Nortek Signature 1000 ADCP with AHRS')
                elseif swiftnum >=100 %WG
                    putAtt(ncid_attr,'north','instrument','RDI Workhorse Monitor 300 kHz ADCP')
                end
            end
        end
        for j=1:length(zHR_names)
            if strcmp(zHR_names(j),'tkedissipationrate')
                putAtt(ncid_attr,'tkedissipationrateHR','units','W/kg')
                putAtt(ncid_attr,'tkedissipationrateHR','long_name','turbulent dissipation rate from HR signature')
                putAtt(ncid_attr,'tkedissipationrateHR','standard_name','specific_turbulent_kinetic_energy_dissipation_in_sea_water')
                if swiftnum < 18 && ~micro %v3 SWIFT
                    putAtt(ncid_attr,'tkedissipationrateHR','instrument','Nortek Aquadopp ADCP')
                elseif swiftnum >= 18 && ~micro %v4 SWIFT
                    putAtt(ncid_attr,'tkedissipationrateHR','instrument','Nortek Signature 1000 ADCP with AHRS')
                    putAtt(ncid_attr,'tkedissipationrateHR','comments','Use with caution.  Check with Jim')
                end
            end
            if strcmp(zHR_names(j),'east')
                putAtt(ncid_attr,'east','units','m/s')
                putAtt(ncid_attr,'east','long_name','eastward currents')
                putAtt(ncid_attr,'east','standard_name','eastward_sea_water_velocity')
                if swiftnum < 18 && ~micro %v3 SWIFT
                    putAtt(ncid_attr,'east','instrument','Nortek Aquadopp ADCP')
                elseif swiftnum >= 18 && ~micro %v4 SWIFT
                    putAtt(ncid_attr,'east','instrument','Nortek Signature 1000 ADCP with AHRS')
                elseif swiftnum >=100 %WG
                    putAtt(ncid_attr,'east','instrument','RDI Workhorse Monitor 300 kHz ADCP')
                end
            end
            if strcmp(zHR_names(j),'north')
                putAtt(ncid_attr,'north','units','m/s')
                putAtt(ncid_attr,'north','long_name','northward currents')
                putAtt(ncid_attr,'north','standard_name','northward_sea_water_velocity')
                if swiftnum < 18 && ~micro %v3 SWIFT
                    putAtt(ncid_attr,'north','instrument','Nortek Aquadopp ADCP')
                elseif swiftnum >= 18 && ~micro %v4 SWIFT
                    putAtt(ncid_attr,'north','instrument','Nortek Signature 1000 ADCP with AHRS')
                elseif swiftnum >=100 %WG
                    putAtt(ncid_attr,'north','instrument','RDI Workhorse Monitor 300 kHz ADCP')
                end
            end
            if strcmp(zHR_names(j),'z')
                putAtt(ncid_attr,'zHR','units','m')
                putAtt(ncid_attr,'zHR','long_name','depth bins for turbulent dissipation rate')
                putAtt(ncid_attr,'zHR','standard_name','depth')
            end
        end
        if has_echo
            putAtt(ncid_attr,'echo','units','dB')
            putAtt(ncid_attr,'echo','long_name','acoustic echo intensity profile')
            putAtt(ncid_attr,'echo','instrument','Nortek Signature 1000 ADCP with AHRS')
            putAtt(ncid_attr,'echoz','units','m')
            putAtt(ncid_attr,'echoz','long_name','depth bins for echo intensity profile')
            putAtt(ncid_attr,'echoz','standard_name','depth')
            putAtt(ncid_attr,'echoz','instrument','Nortek Signature 1000 ADCP with AHRS')
        end
        if has_altimeter
            putAtt(ncid_attr,'altimeter','units','m')
            putAtt(ncid_attr,'altimeter','long_name','altimeter range to seabed or target')
            putAtt(ncid_attr,'altimeter','instrument','Nortek Signature 1000 ADCP with AHRS')
        end
    elseif ~strcmp(names{i},'ID')
        if strcmp(names(i),'time')
            putAtt(ncid_attr,'time','units','days since 1970-01-01 00:00:00');
            putAtt(ncid_attr,'time','long_name','Days since 1 January 1970');
            putAtt(ncid_attr,'time','standard_name','time')
        end
        if strcmp(names(i),'lat')
            putAtt(ncid_attr,'lat','units','degree_north')
            putAtt(ncid_attr,'lat','long_name','latitude')
            putAtt(ncid_attr,'lat','standard_name','latitude')
            putAtt(ncid_attr,'lat','instrument','GPS')
        end
        if strcmp(names(i),'lon')
            putAtt(ncid_attr,'lon','units','degree_east')
            putAtt(ncid_attr,'lon','long_name','longitude')
            putAtt(ncid_attr,'lon','standard_name','longitude')
            putAtt(ncid_attr,'lon','instrument','GPS')
        end
        if strcmp(names(i),'watertemp')
            putAtt(ncid_attr,'sea_water_temperature','units','degree_C')
            if swiftnum < 18 && ~micro %v3 SWIFT
                putAtt(ncid_attr,'sea_water_temperature','long_name','sea water temperature at 0.5 m depth')
            elseif swiftnum >= 18 && ~micro %v4 SWIFT
                putAtt(ncid_attr,'sea_water_temperature','long_name','sea water temperature at 0.3 m depth')
            elseif micro % microSWIFT
                putAtt(ncid_attr,'sea_water_temperature','long_name','sea water temperature at 0.5 m depth')
            end
            putAtt(ncid_attr,'sea_water_temperature','standard_name','sea_water_temperature')
            putAtt(ncid_attr,'sea_water_temperature','instrument','Aanderaa 4319')
            %putAtt(ncid_attr,'sea_water_temperature','ancillary_variables','flag_values_watertemp')
            %putAtt(ncid_attr,'sea_water_temperature','comment','Data flagged in the variable specified in the "ancillary_variables" attribute. 0 = Data are reasonable, 1 = Data are questionable, 2 = Data are unreasonable')
            %putAtt(ncid_attr,'sea_water_temperature','_FillValue',-999)
        end
        if strcmp(names(i),'watertemp_d2')
            putAtt(ncid_attr,'sea_water_temperature_at_depth','units','degree_C')
            if swiftnum < 18 && ~micro %v3 SWIFT
                putAtt(ncid_attr,'sea_water_temperature_at_depth','long_name','sea water temperature at 1.0 m depth')
                putAtt(ncid_attr,'sea_water_temperature_at_depth','instrument','Aanderaa 4319')
            elseif micro % microSWIFT
                putAtt(ncid_attr,'sea_water_temperature_at_depth','long_name','sea water temperature at 0.5 m depth')
                putAtt(ncid_attr,'sea_water_temperature_at_depth','instrument','Aanderaa 4319')

            end
            putAtt(ncid_attr,'sea_water_temperature_at_depth','standard_name','sea_water_temperature')
%             putAtt(ncid_attr,'sea_water_temperature_at_depth','ancillary_variables','flag_values_watertemp')
%             putAtt(ncid_attr,'sea_water_temperature_at_depth','comment','Data flagged in the variable specified in the "ancillary_variables" attribute. 0 = Data are reasonable, 1 = Data are questionable, 2 = Data are unreasonable')
%             putAtt(ncid_attr,'sea_water_temperature_at_depth','_FillValue',-999)
        end
        if strcmp(names(i),'qsea')
            putAtt(ncid_attr,'sea_surface_saturation_specific_humidity','units','grams_per_kilogram')
            if swiftnum < 18 && ~micro %v3 SWIFT
                putAtt(ncid_attr,'sea_surface_saturation_specific_humidity','long_name','sea_surface saturation specific humidity from sea water temperature at 0.5 m depth')
            elseif swiftnum >= 18 && ~micro %v4 SWIFT
                putAtt(ncid_attr,'sea_surface_saturation_specific_humidity','long_name','sea_surface saturation specific humidity from sea water temperature at 0.3 m depth')
            elseif micro %microSWIFT
                putAtt(ncid_attr,'sea_surface_saturation_specific_humidity','long_name','sea_surface saturation specific humidity from sea water temperature at 0.24 m depth')
            end
            putAtt(ncid_attr,'sea_surface_saturation_specific_humidity','standard_name','surface_specific_humidity')
%             putAtt(ncid_attr,'sea_surface_saturation_specific_humidity','method','calculated from sea water temperature')
%             putAtt(ncid_attr,'sea_surface_saturation_specific_humidity','ancillary_variables','flag_values_watertemp')
%             putAtt(ncid_attr,'sea_surface_saturation_specific_humidity','comment','Data flagged in the variable specified in the "ancillary_variables" attribute. 0 = Data are reasonable, 1 = Data are questionable, 2 = Data are unreasonable')
%             putAtt(ncid_attr,'sea_surface_saturation_specific_humidity','_FillValue',-999)
        end
        if strcmp(names(i),'sigwaveheight')
            putAtt(ncid_attr,'significant_wave_height','units','m')
            putAtt(ncid_attr,'significant_wave_height','long_name','significant wave height')
            putAtt(ncid_attr,'significant_wave_height','standard_name','sea_surface_wave_significant_height')
            if swiftnum < 18 && ~micro %v3 SWIFT
                putAtt(ncid_attr,'significant_wave_height','instrument','Microstrain 3DM-GX3-35/AHRS')
            elseif swiftnum >= 18 && ~micro %v4 SWIFT
                putAtt(ncid_attr,'significant_wave_height','instrument','SBG Ellipse/AHRS')
            elseif micro % microSWIFT
                putAtt(ncid_attr,'significant_wave_height','instrument','GPSWaves / NEDwaves')
            end
        end
        if strcmp(names(i),'peakwaveperiod')
            putAtt(ncid_attr,'peak_wave_period','units','s')
            putAtt(ncid_attr,'peak_wave_period','long_name','peak of period orbital velocity spectra')
            putAtt(ncid_attr,'peak_wave_period','standard_name','peak_wave_period')
            if swiftnum < 18 && ~micro %v3 SWIFT
                putAtt(ncid_attr,'peak_wave_period','instrument','Microstrain 3DM-GX3-35/AHRS')
            elseif swiftnum >= 18 && ~micro %v4 SWIFT
                putAtt(ncid_attr,'peak_wave_period','instrument','SBG Ellipse/AHRS')
            elseif micro % microSWIFT
                putAtt(ncid_attr,'peak_wave_period','instrument','GPSWaves / NEDwaves')
            end
        end
        if strcmp(names(i),'centroidwaveperiod')
            putAtt(ncid_attr,'mean_wave_period','units','s')
            putAtt(ncid_attr,'mean_wave_period','long_name','centroid (mean) period orbital velocity spectra')
            putAtt(ncid_attr,'mean_wave_period','standard_name','sea_surface_wave_mean_period')
            putAtt(ncid_attr,'mean_wave_period','description','energy-weighted wave period calculated from the ratio of the zeroth moment and first moment of the sea surface wave variance spectral density')
            if swiftnum < 18 && ~micro %v3 SWIFT
                putAtt(ncid_attr,'mean_wave_period','instrument','Microstrain 3DM-GX3-35/AHRS')
            elseif swiftnum >= 18 && ~micro %v4 SWIFT
                putAtt(ncid_attr,'mean_wave_period','instrument','SBG Ellipse/AHRS')
            elseif micro % microSWIFT
                putAtt(ncid_attr,'mean_wave_period','instrument','GPSWaves / NEDwaves')
            end
        end
%         if strcmp(names(i),'mss')
%             putAtt(ncid_attr,'wave_mean_square_slope','units','s')
%             putAtt(ncid_attr,'wave_mean_square_slope','long_name','wave_mean_square_slope_normalized_by_frequency_width of 0.15 (0.25 to 0.4 1/s frequency range). Multiply by frequency width to get unnormalized value.')
%             putAtt(ncid_attr,'wave_mean_square_slope','standard_name','sea_surface_wave_mean_square_slope_normalized_by_frequency_width')
%             if swiftnum < 18 && ~micro %v3 SWIFT
%                 putAtt(ncid_attr,'wave_mean_square_slope','instrument','Microstrain 3DM-GX3-35/AHRS')
%             elseif swiftnum >= 18 && ~micro %v4 SWIFT
%                 putAtt(ncid_attr,'wave_mean_square_slope','instrument','SBG Ellipse/AHRS')
%             elseif micro % microSWIFT
%                 putAtt(ncid_attr,'wave_mean_square_slope','instrument','GPSWaves/Microstrain 3DM-GX3-35/AHRS')
%             end
%             putAtt(ncid_attr,'wave_mean_square_slope','method','Calculated with equation 4 in Iyer et al., JGR Oceans, 2022.')
%         end
%         if strcmp(names(i),'ustar')
%             putAtt(ncid_attr,'friction_velocity_in_air_from_wave_spectra','units','m/s')
%             putAtt(ncid_attr,'friction_velocity_in_air_from_wave_spectra','long_name','friction_velocity_in_air_from_wave_spectra calculated using 0.25 to 0.4 1/s frequency range')
%             putAtt(ncid_attr,'friction_velocity_in_air_from_wave_spectra','standard_name','friction_velocity_in_air')
%             if swiftnum < 18 && ~micro %v3 SWIFT
%                 putAtt(ncid_attr,'friction_velocity_in_air_from_wave_spectra','instrument','Microstrain 3DM-GX3-35/AHRS')
%             elseif swiftnum >= 18 && ~micro %v4 SWIFT
%                 putAtt(ncid_attr,'friction_velocity_in_air_from_wave_spectra','instrument','SBG Ellipse/AHRS')
%             elseif micro %microSWIFT
%                 putAtt(ncid_attr,'friction_velocity_in_air_from_wave_spectra','instrument','GPSWaves/Microstrain 3DM-GX3-35/AHRS')
%             end
%             putAtt(ncid_attr,'friction_velocity_in_air_from_wave_spectra','method','Calculated with equation 3 in Iyer et al., JGR Oceans, 2022.')
%         end
        if strcmp(names(i),'salinity')
            putAtt(ncid_attr,'sea_water_salinity','units','psu')
            if swiftnum < 18 && ~micro %v3 SWIFT
                putAtt(ncid_attr,'sea_water_salinity','long_name','sea water salinity at 0.5 m depth')
            elseif swiftnum >= 18 && ~micro %v4 SWIFT
                putAtt(ncid_attr,'sea_water_salinity','long_name','sea water salinity at 0.3 m depth')
            elseif micro % microSWIFT
                putAtt(ncid_attr,'sea_water_salinity','long_name','sea water salinity at 0.5 m depth')
            end
            putAtt(ncid_attr,'sea_water_salinity','standard_name','sea_water_salinity')
            putAtt(ncid_attr,'sea_water_salinity','instrument','Aanderaa 4319')
%             putAtt(ncid_attr,'sea_water_salinity','ancillary_variables','flag_values_salinity')
%             putAtt(ncid_attr,'sea_water_salinity','comment','Data flagged in the variable specified in the "ancillary_variables" attribute. 0 = Data are reasonable, 1 = Data are questionable, 2 = Data are unreasonable')
%             putAtt(ncid_attr,'sea_water_salinity','_FillValue',-999)
        end
        if strcmp(names(i),'salinity_d2')
            putAtt(ncid_attr,'sea_water_salinity_at_depth','units','psu')
            if swiftnum < 18 && ~micro %v3 SWIFT
                putAtt(ncid_attr,'sea_water_salinity_at_depth','long_name','sea water salinity at 1.0 m depth')
                putAtt(ncid_attr,'sea_water_salinity_at_depth','instrument','Aanderaa 4319')
            elseif micro % microSWIFT
                putAtt(ncid_attr,'sea_water_salinity_at_depth','long_name','sea water salinity at 0.5 m depth')
                putAtt(ncid_attr,'sea_water_salinity_at_depth','instrument','Aanderaa 4319')
            end
            putAtt(ncid_attr,'sea_water_salinity_at_depth','standard_name','sea_water_salinity')
%             putAtt(ncid_attr,'sea_water_salinity_at_depth','ancillary_variables','flag_values_salinity')
%             putAtt(ncid_attr,'sea_water_salinity_at_depth','comment','Data flagged in the variable specified in the "ancillary_variables" attribute. 0 = Data are reasonable, 1 = Data are questionable, 2 = Data are unreasonable')
%             putAtt(ncid_attr,'sea_water_salinity_at_depth','_FillValue',-999)
        end
        if strcmp(names(i),'peakwavedirT')
            putAtt(ncid_attr,'peak_wave_direction','units','degree')
            putAtt(ncid_attr,'peak_wave_direction','long_name','wave direction at spectral peak, direction from north')
            putAtt(ncid_attr,'peak_wave_direction','standard_name','sea_surface_wave_from_direction_at_variance_spectral_density_maximum')
            if swiftnum < 18 && ~micro %v3 SWIFT
                putAtt(ncid_attr,'peak_wave_direction','instrument','Microstrain 3DM-GX3-35/AHRS')
            elseif swiftnum >= 18 && ~micro %v4 SWIFT
                putAtt(ncid_attr,'peak_wave_direction','instrument','SBG Ellipse/AHRS')
            elseif micro % microSWIFT
                putAtt(ncid_attr,'peak_wave_direction','instrument','GPSWaves / NEDwaves')
            end
            putAtt(ncid_attr,'peak_wave_direction','method','Wave spectral processing as described by Thomson et al., JTech, 2018.')
        end
        if strcmp(names(i),'peakwaveperiod')
            putAtt(ncid_attr,'peak_wave_period','units','s')
            putAtt(ncid_attr,'peak_wave_period','long_name','peak of period orbital velocity spectra')
            putAtt(ncid_attr,'peak_wave_period','standard_name','sea_surface_wave_period_at_variance_spectral_density_maximum')
            if swiftnum < 18 && ~micro %v3 SWIFT
                putAtt(ncid_attr,'peak_wave_period','instrument','Microstrain 3DM-GX3-35/AHRS')
            elseif swiftnum >= 18 && ~micro %v4 SWIFT
                putAtt(ncid_attr,'peak_wave_period','instrument','SBG Ellipse/AHRS')
            elseif micro % microSWIFT
                putAtt(ncid_attr,'peak_wave_period','instrument','GPSWaves / NEDwaves')
            end
            putAtt(ncid_attr,'peak_wave_period','method','Wave spectral processing as described by Thomson et al., JTech, 2018.')
        end
        if strcmp(names(i),'winddirT')
            putAtt(ncid_attr,'wind_direction','units','degree')
            if swiftnum < 18 && ~micro %v3 SWIFT
                putAtt(ncid_attr,'wind_direction','long_name','true wind direction at 0.8 m height above the wave-following surface, direction from north')
                putAtt(ncid_attr,'wind_direction','standard_name','wind_from_direction')
                putAtt(ncid_attr,'wind_direction','instrument','Airmar 200WX')
            elseif swiftnum >= 18 && ~micro %v4 SWIFT
                putAtt(ncid_attr,'wind_direction','long_name','true wind direction at 0.5 m height above the wave-following surface, direction from north')
                putAtt(ncid_attr,'wind_direction','standard_name','wind_from_direction')
                putAtt(ncid_attr,'wind_direction','instrument','Vaisala WXT530')
%             elseif micro % microSWIFT
%                 putAtt(ncid_attr,'wind_direction','long_name','true wind direction at 1.0 m height above the wave-following surface, direction from north')
%                 putAtt(ncid_attr,'wind_direction','standard_name','wind_from_direction')
%                 putAtt(ncid_attr,'wind_direction','instrument','Airmar 200WX')
            end
        end
        if strcmp(names(i),'winddirTstddev')
            putAtt(ncid_attr,'wind_direction_stddev','units','degree')
            if swiftnum < 18 && ~micro %v3 SWIFT
                putAtt(ncid_attr,'wind_direction_stddev','long_name','standard deviation of true wind direction at 0.8 m height above the wave-following surface')
                putAtt(ncid_attr,'wind_direction_stddev','instrument','Airmar 200WX')
            elseif swiftnum >= 18 && ~micro %v4 SWIFT
                putAtt(ncid_attr,'wind_direction_stddev','long_name','standard deviation of true wind direction at 0.5 m height above the wave-following surface')
                putAtt(ncid_attr,'wind_direction_stddev','instrument','Vaisala WXT530')
%             elseif micro % microSWIFT
%                 putAtt(ncid_attr,'wind_direction_stddev','long_name','standard deviation of true wind direction at 1.0 m height above the wave-following surface')
%                 putAtt(ncid_attr,'wind_direction_stddev','instrument','Airmar 200WX')
            end
        end
        if strcmp(names(i),'windspd')
            putAtt(ncid_attr,'wind_speed','units','m/s')
            if swiftnum < 18 && ~micro %v3 SWIFT
                putAtt(ncid_attr,'wind_speed','long_name','true wind speed at 0.8 m height above the wave-following surface')
                putAtt(ncid_attr,'wind_speed','instrument','Airmar 200WX')
            elseif swiftnum >= 18 && ~micro %v4 SWIFT
                putAtt(ncid_attr,'wind_speed','long_name','true wind speed at 0.5 m height above the wave-following surface')
                putAtt(ncid_attr,'wind_speed','instrument','Vaisala WXT530')
%             elseif micro % microSWIFT
%                 putAtt(ncid_attr,'wind_speed','long_name','true wind speed at 1.0 m height above the wave-following surface')
%                 putAtt(ncid_attr,'wind_speed','instrument','Airmar 200WX')
            end
            putAtt(ncid_attr,'wind_speed','standard_name','wind_speed')
%             putAtt(ncid_attr,'wind_speed','ancillary_variables','flag_values_windspd')
%             putAtt(ncid_attr,'wind_speed','comment','Data flagged in the variable specified in the "ancillary_variables" attribute. 0 = Data are reasonable, 1 = Data are questionable, 2 = Data are unreasonable')
%             putAtt(ncid_attr,'wind_speed','_FillValue',-999)
        end
        if strcmp(names(i),'windspdstddev')
            putAtt(ncid_attr,'wind_speed_stddev','units','m/s')
            if swiftnum < 18 && ~micro %v3 SWIFT
                putAtt(ncid_attr,'wind_speed_stddev','long_name','standard deviation of true wind speed at 0.8 m height above the wave-following surface')
                putAtt(ncid_attr,'wind_speed','instrument','Airmar 200WX')
            elseif swiftnum >= 18 && ~micro %v4 SWIFT
                putAtt(ncid_attr,'wind_speed_stddev','long_name','standard deviation of true wind speed at 0.5 m height above the wave-following surface')
                putAtt(ncid_attr,'wind_speed_stddev','instrument','Vaisala WXT530')
%             elseif micro % microSWIFT
%                 putAtt(ncid_attr,'wind_speed_stddev','long_name','standard deviation of true wind speed at 1.0 m height above the wave-following surface')
%                 putAtt(ncid_attr,'wind_speed_stddev','instrument','Airmar 200WX')
            end
%             putAtt(ncid_attr,'wind_speed_stddev','ancillary_variables','flag_values_windspd')
%             putAtt(ncid_attr,'wind_speed_stddev','comment','Data flagged in the variable specified in the "ancillary_variables" attribute. 0 = Data are reasonable, 1 = Data are questionable, 2 = Data are unreasonable')
        end
        if strcmp(names(i),'airtemp')
            putAtt(ncid_attr,'air_temperature','units','degree_C')
            if swiftnum < 18 && ~micro %v3 SWIFT
                putAtt(ncid_attr,'air_temperature','long_name','air temperature at 0.8 m height above the wave-following surface')
                putAtt(ncid_attr,'air_temperature','instrument','Airmar 200WX')
                putAtt(ncid_attr,'air_temperature','note','Daytime data (10:00-21:00 UTC) have been replaced with NaNs, because of diurnal heating of the sensor. Additional corrections were made to Airmar air temperature data to correct for unrealistically low values in high wind conditions due to sea spray. This involved applying a 2-hour maximum filter (take the maximum data point every 2 hours). Remaining unrealistic data were removed manually. Because of this processing step, air temperature data should be treated as if the time resolution is 2 hours.');
            elseif swiftnum >= 18 && ~micro %v4 SWIFT
                putAtt(ncid_attr,'air_temperature','long_name','air temperature at 0.5 m height above the wave-following surface')
                putAtt(ncid_attr,'air_temperature','instrument','Vaisala WXT530')
%             elseif micro % microSWIFT
%                 putAtt(ncid_attr,'air_temperature','long_name','air temperature at 1.0 m height above the wave-following surface')
%                 putAtt(ncid_attr,'air_temperature','instrument','Airmar 200WX')
%                 putAtt(ncid_attr,'air_temperature','note','Daytime data (10:00-21:00 UTC) have been replaced with NaNs, because of diurnal heating of the sensor. Additional corrections were made to Airmar air temperature data to correct for unrealistically low values in high wind conditions due to sea spray. This involved applying a 2-hour maximum filter (take the maximum data point every 2 hours). Remaining unrealistic data were removed manually. Because of this processing step, air temperature data should be treated as if the time resolution is 2 hours.');
            end
            putAtt(ncid_attr,'air_temperature','standard_name','air_temperature')
%             putAtt(ncid_attr,'air_temperature','ancillary_variables','flag_values_airtemp')
%             putAtt(ncid_attr,'air_temperature','comment','Data flagged in the variable specified in the "ancillary_variables" attribute. 0 = Data are reasonable, 1 = Data are questionable, 2 = Data are unreasonable')
%             putAtt(ncid_attr,'air_temperature','_FillValue',-999)

        end
        if strcmp(names(i),'airtempstddev')
            putAtt(ncid_attr,'air_temperature_stddev','units','deg C')
            if swiftnum < 18 && ~micro %v3 SWIFT
                putAtt(ncid_attr,'air_temperature_stddev','long_name','standard deviation of air temperature at 0.8 m height above the wave-following surface')
                putAtt(ncid_attr,'air_temperature_stddev','instrument','Airmar 200WX')
            elseif swiftnum >= 18 && ~micro %v4 SWIFT
                putAtt(ncid_attr,'air_temperature_stddev','long_name','standard deviation of air temperature at 0.5 m height above the wave-following surface')
                putAtt(ncid_attr,'air_temperature_stddev','instrument','Vaisala WXT530')
%             elseif micro % microSWIFT
%                 putAtt(ncid_attr,'air_temperature_stddev','long_name','standard deviation of air temperature at 1.0 m height above the wave-following surface')
%                 putAtt(ncid_attr,'air_temperature_stddev','instrument','Airmar 200WX')
            end
%             putAtt(ncid_attr,'air_temperature_stddev','ancillary_variables','flag_values_airtemp')
%             putAtt(ncid_attr,'air_temperature_stddev','comment','Data flagged in the variable specified in the "ancillary_variables" attribute. 0 = Data are reasonable, 1 = Data are questionable, 2 = Data are unreasonable')
%             putAtt(ncid_attr,'air_temperature_stddev','_FillValue',-999)
        end
        if strcmp(names(i),'relhumidity')
            putAtt(ncid_attr,'relative_humidity','units','%')
            if swiftnum < 18 && ~micro %v3 SWIFT
                putAtt(ncid_attr,'relative_humidity','long_name','relative_humidity at 0.8 m height above the wave-following surface')
                putAtt(ncid_attr,'relative_humidity','standard_name','relative_humidity')
            elseif swiftnum >= 18 && ~micro %v4 SWIFT
                putAtt(ncid_attr,'relative_humidity','long_name','relative_humidity at 0.5 m height above the wave-following surface')
                putAtt(ncid_attr,'relative_humidity','instrument','Vaisala WXT530')
                putAtt(ncid_attr,'relative_humidity','standard_name','relative_humidity')
%             elseif micro % microSWIFT
%                 putAtt(ncid_attr,'relative_humidity','long_name','relative_humidity at 1.0 m height above the wave-following surface')
%                 putAtt(ncid_attr,'relative_humidity','standard_name','relative_humidity')
            end
%             putAtt(ncid_attr,'relative_humidity','ancillary_variables','flag_values_humidity')
%             putAtt(ncid_attr,'relative_humidity','comment','Data flagged in the variable specified in the "ancillary_variables" attribute. 0 = Data are reasonable, 1 = Data are questionable, 2 = Data are unreasonable')
%             putAtt(ncid_attr,'relative_humidity','_FillValue',-999)
        end
        if strcmp(names(i),'qair')
            putAtt(ncid_attr,'specific_humidity','units','grams_per_kilogram')
            if swiftnum < 18 && ~micro %v3 SWIFT
                putAtt(ncid_attr,'specific_humidity','long_name','specific_humidity at 0.8 m height above the wave-following surface')
                putAtt(ncid_attr,'specific_humidity','standard_name','specific_humidity')
            elseif swiftnum >= 18 && ~micro %v4 SWIFT
                putAtt(ncid_attr,'specific_humidity','long_name','specific_humidity at 0.5 m height above the wave-following surface')
                putAtt(ncid_attr,'specific_humidity','standard_name','specific_humidity')
%             elseif micro % microSWIFT
%                 putAtt(ncid_attr,'specific_humidity','long_name','specific_humidity at 1.0 m height above the wave-following surface')
%                 putAtt(ncid_attr,'specific_humidity','standard_name','specific_humidity')
            end
            putAtt(ncid_attr,'specific_humidity','method','calculated from air temperature, air pressure, and relative humidity')
%             putAtt(ncid_attr,'specific_humidity','ancillary_variables','flag_values_humidity')
%             putAtt(ncid_attr,'specific_humidity','comment','Data flagged in the variable specified in the "ancillary_variables" attribute. 0 = Data are reasonable, 1 = Data are questionable, 2 = Data are unreasonable')
%             putAtt(ncid_attr,'specific_humidity','_FillValue',-999)
        end
        if strcmp(names(i),'relhumiditystddev')
            putAtt(ncid_attr,'relative_humidity_stddev','units','')
            if swiftnum < 18 && ~micro %v3 SWIFT
                putAtt(ncid_attr,'relative_humidity_stddev','long_name','standard deviation of relative_humidity at 0.8 m height above the wave-following surface')
            elseif swiftnum >= 18 && ~micro %v4 SWIFT
                putAtt(ncid_attr,'relative_humidity_stddev','long_name','standard deviation of relative_humidity at 0.5 m height above the wave-following surface')
                putAtt(ncid_attr,'relative_humidity_stddev','instrument','Vaisala WXT530')
            elseif micro %microSWIFT
                putAtt(ncid_attr,'relative_humidity_stddev','long_name','standard deviation of relative_humidity at 1.0 m height above the wave-following surface')
            end
%             putAtt(ncid_attr,'relative_humidity_stddev','ancillary_variables','flag_values_humidity')
%             putAtt(ncid_attr,'relative_humidity_stddev','comment','Data flagged in the variable specified in the "ancillary_variables" attribute. 0 = Data are reasonable, 1 = Data are questionable, 2 = Data are unreasonable')
%             putAtt(ncid_attr,'relative_humidity_stddev','_FillValue',-999)
        end
        if strcmp(names(i),'airpres')
            putAtt(ncid_attr,'air_pressure','units','bar')
            if swiftnum < 18 && ~micro %v3 SWIFT
                putAtt(ncid_attr,'air_pressure','long_name','air pressure at 0.8 m height above the wave-following surface')
                putAtt(ncid_attr,'air_pressure','instrument','Airmar 200WX')
            elseif swiftnum >= 18 && ~micro %v4 SWIFT
                putAtt(ncid_attr,'air_pressure','long_name','air pressure at 0.5 m height above the wave-following surface')
                putAtt(ncid_attr,'air_pressure','instrument','Vaisala WXT530')
            elseif micro % microSWIFT
                putAtt(ncid_attr,'air_pressure','long_name','air pressure at 1.0 m height above the wave-following surface')
                putAtt(ncid_attr,'air_pressure','instrument','Airmar 200WX')
            end
            putAtt(ncid_attr,'air_pressure','standard_name','air_pressure')
%             putAtt(ncid_attr,'air_pressure','ancillary_variables','flag_values_airtemp')
%             putAtt(ncid_attr,'air_pressure','_FillValue',-999)
        end
        if strcmp(names(i),'airpresstddev')
            putAtt(ncid_attr,'air_pressure_stddev','units','bar')
            if swiftnum < 18 && ~micro %v3 SWIFT
                putAtt(ncid_attr,'air_pressure_stddev','long_name','standard deviation of air pressure at 0.8 m height above the wave-following surface')
                putAtt(ncid_attr,'air_pressure_stddev','instrument','Airmar 200WX')
            elseif swiftnum >= 18 && ~micro %v4 SWIFT
                putAtt(ncid_attr,'air_pressure_stddev','long_name','standard deviation of air pressure at 0.5 m height above the wave-following surface')
                putAtt(ncid_attr,'air_pressure_stddev','instrument','Vaisala WXT530')
            elseif micro %microSWIFT
                putAtt(ncid_attr,'air_pressure_stddev','long_name','standard deviation of air pressure at 1.0 m height above the wave-following surface')
                putAtt(ncid_attr,'air_pressure_stddev','instrument','Airmar 200WX')
            end
%             putAtt(ncid_attr,'air_pressure_stddev','ancillary_variables','flag_values_airtemp')
%             putAtt(ncid_attr,'air_pressure_stddev','_FillValue',-999)
        end
        if strcmp(names(i),'flag_values_watertemp')
            putAtt(ncid_attr,'flag_values_watertemp','description','flags')
            putAtt(ncid_attr,'flag_values_watertemp','long_name','flag_values_for_sea_water_temperature_variable')
            putAtt(ncid_attr,'flag_values_watertemp','comment','flag values for sea water temperature: 0 = reasonable, 1 = questionable data, 2 = bad data')
            putAtt(ncid_attr,'flag_values_watertemp','ancillary_variables','sea_water_temperature')
            if swiftnum > 244 & swiftnum < 246
                putAtt(ncid_attr,'flag_values_watertemp','comment','flag values for sea water temperature and sea water temperature at depth: 0 = reasonable, 1 = questionable data, 2 = bad data')
                putAtt(ncid_attr,'flag_values_watertemp','ancillary_variables','sea_water_temperature,sea_water_temperature_at_depth')
            end
        end
        if strcmp(names(i),'flag_values_salinity')
            putAtt(ncid_attr,'flag_values_salinity','description','flags')
            putAtt(ncid_attr,'flag_values_salinity','long_name','flag_values_for_sea_water_salinity_variable')
            putAtt(ncid_attr,'flag_values_salinity','comment','flag values for sea water salinity: 0 = reasonable, 1 = questionable data, 2 = bad data')
            putAtt(ncid_attr,'flag_values_salinity','ancillary_variables','sea_water_salinity')
            if swiftnum > 244 & swiftnum < 246
                putAtt(ncid_attr,'flag_values_salinity','comment','flag values for sea water salinity and sea water salinity at depth: 0 = reasonable, 1 = questionable data, 2 = bad data')
                putAtt(ncid_attr,'flag_values_salinity','ancillary_variables','sea_water_salinity,sea_water_salinity_at_depth')
            end
        end
        if strcmp(names(i),'flag_values_airtemp')
            putAtt(ncid_attr,'flag_values_airtemp','description','flags')
            putAtt(ncid_attr,'flag_values_airtemp','long_name','flag_values_for_air_temperature_variable')
            putAtt(ncid_attr,'flag_values_airtemp','comment','flag values for air temperature (and air pressure): 0 = reasonable, 1 = questionable data, 2 = bad data')
            if ~micro
                putAtt(ncid_attr,'flag_values_airtemp','comment2','Questionable data (=1) are usually rapid decreases that likely correspond to atmospheric cold pools, but the artificial influence of sea spray cannot be ruled out')
            end
            if micro
                putAtt(ncid_attr,'flag_values_airtemp','comment2','Questionable data (=1) are usually rapid decreases that correspond to either atmospheric cold pools or the artificial influence of sea spray')
            end
            putAtt(ncid_attr,'flag_values_airtemp','ancillary_variables','air_temperature,air_pressure')
        end
        if strcmp(names(i),'flag_values_windspd')
            putAtt(ncid_attr,'flag_values_windspd','description','flags')
            putAtt(ncid_attr,'flag_values_windspd','long_name','flag_values_for_wind_speed_variable')
            putAtt(ncid_attr,'flag_values_windspd','comment','flag values for wind speed: 0 = reasonable, 1 = questionable data, 2 = bad data')
            putAtt(ncid_attr,'flag_values_windspd','ancillary_variables','wind_speed')
        end
        if strcmp(names(i),'flag_values_humidity')
            putAtt(ncid_attr,'flag_values_humidity','description','flags')
            putAtt(ncid_attr,'flag_values_humidity','long_name','flag_values_for_relative_humidity_and_specific_humidity_variable')
            putAtt(ncid_attr,'flag_values_humidity','comment','flag values for relative and specific humidity: 0 = reasonable, 1 = questionable data, 2 = bad data')
            if ~micro
                putAtt(ncid_attr,'flag_values_humidity','comment2','Questionable data (=1) are usually rapid changes that likely correspond to atmospheric cold pools, but the artificial influence of sea spray cannot be ruled out')
            end
            putAtt(ncid_attr,'flag_values_humidity','ancillary_variables','relative_humidity,specific_humidity')
        end
        %         if strcmp(names(i),'qa')
        %             putAtt(ncid_attr,'specific_humidity','units','g/kg')
        %             if swiftnum < 18 && ~micro %v3 SWIFT
        %                 putAtt(ncid_attr,'specific_humidity','long_name','specific_humidity at 0.8 m height above the wave-following surface')
        %             elseif swiftnum >= 18 && ~micro %v4 SWIFT
        %                 putAtt(ncid_attr,'specific_humidity','long_name','specific_humidity at 0.5 m height above the wave-following surface')
        %             elseif micro %microSWIFT
        %                 putAtt(ncid_attr,'specific_humidity','long_name','specific_humidity at 1.0 m height above the wave-following surface')
        %             end
        %             putAtt(ncid_attr,'specific_humidity','standard_name','specific_humidity')
        %         end
        if strcmp(names(i),'puck')
            putAtt(ncid_attr,'puck','units','')
            putAtt(ncid_attr,'puck','long_name','three color channels of a WetLabs puck fluorometer')
        end
        if strcmp(names(i),'driftdirT')
            putAtt(ncid_attr,'drift_direction','units','degree')
            putAtt(ncid_attr,'drift_direction','long_name','platform drift direction toward, in degrees to (equivalent to course over ground)')
            putAtt(ncid_attr,'drift_direction','standard_name','platform_course')
            putAtt(ncid_attr,'drift_direction','instrument','GPS')
        end
        if strcmp(names(i),'driftspd')
            putAtt(ncid_attr,'drift_speed','units','m/s')
            putAtt(ncid_attr,'drift_speed','long_name','platform drift speed (equivalent to speed over ground)')
            putAtt(ncid_attr,'drift_speed','standard_name','platform_speed_wrt_ground')
            putAtt(ncid_attr,'drift_speed','instrument','GPS')
        end
        if strcmp(names(i),'z')
            putAtt(ncid_attr,'z','units','m')
            putAtt(ncid_attr,'z','long_name','reconstruction (via post-processing IMU data) of vertical displacements at 25 Hz')
        end
        if strcmp(names(i),'x')
            putAtt(ncid_attr,'x','units','m')
            putAtt(ncid_attr,'x','long_name','reconstruction (via post-processing IMU data) of horizontal east-west displacements at 25 Hz')
        end
        if strcmp(names(i),'y')
            putAtt(ncid_attr,'y','units','m')
            putAtt(ncid_attr,'y','long_name','reconstruction (via post-processing IMU data) of horizontal north-south displacements at 25 Hz')
        end
        if strcmp(names(i),'u')
            putAtt(ncid_attr,'u','units','m/s')
            putAtt(ncid_attr,'u','long_name','east-west GPS velocities at 4 Hz')
        end
        if strcmp(names(i),'v')
            putAtt(ncid_attr,'v','units','m/s')
            putAtt(ncid_attr,'v','long_name','north-south GPS velocities at 4 Hz')
        end
        if strcmp(names(i),'')
            putAtt(ncid_attr,'','units','')
            putAtt(ncid_attr,'','long_name','')
        end
    end
end
disp('Saving NC')
netcdf.endDef(ncid_attr);
netcdf.close(ncid_attr);

end


function putAtt(ncid, vname, aname, aval)
% Batched replacement for ncwriteatt. Assumes the caller has opened the
% file and entered define mode once; caches varids keyed by name.
% Missing vars warn once and skip (attrs shouldn't abort the whole write).
% Call putAtt(ncid, '__reset__') at the start of each file to clear the
% cache — ncids get reused after close, so identity alone isn't enough.
    persistent vids missing
    if strcmp(vname, '__reset__')
        vids = containers.Map;
        missing = containers.Map;
        return;
    end
    if isempty(vids)
        vids = containers.Map;
        missing = containers.Map;
    end
    if isKey(missing, vname), return; end
    if ~isKey(vids, vname)
        try
            vids(vname) = netcdf.inqVarID(ncid, vname);
        catch
            missing(vname) = true;
            warning('SWIFT2NC:missingVar', ...
                'skipping attributes for undefined variable "%s"', vname);
            return;
        end
    end
    netcdf.putAtt(ncid, vids(vname), aname, aval);
end


