function SWIFT2NC_ATOMIC_all_l2(SWIFT_in,filename,swiftnum)

% Edited on May 1, 2020 by Suneil Iyer to create netcdf files for ATOMIC
% SWIFT and Wave Glider data

% creates a netCDF file using existing SWIFT structure and writes it into 'filename'
% (must include .nc)

%added 'swiftnum' to denote the number of the SWIFT, as sensors were
%located at different depths for v3 and v4 SWIFTs

% skip substructures that are not supported yet:

SWIFT=SWIFT_in
if isfield(SWIFT,'wavehistogram')
    SWIFT=rmfield(SWIFT,'wavehistogram')
end

%% loading variables
% extract dimension sizes: time, freq, z, zHR (if available)

ncid=netcdf.create(filename,'CLOBBER');
t_dim=netcdf.defDim(ncid,'time', length(SWIFT));
full_names=fieldnames(SWIFT);

if isfield(SWIFT,'wavespectra') && min(SWIFT(1).wavespectra.freq)>0
    f_dim = netcdf.defDim(ncid,'freq', length(SWIFT(1).wavespectra.freq));
    spec_names=fieldnames(SWIFT(1).wavespectra);
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
    sig_names = fieldnames(SWIFT(1).signature)
    if isfield(SWIFT(1).signature,'HRprofile')
        zHR_dim = netcdf.defDim(ncid,'zHR', length(SWIFT(1).signature.HRprofile.z));
        zHR_names = fieldnames(SWIFT(1).signature.HRprofile);
    end
    if isfield(SWIFT(1).signature,'profile')
        z_dim = netcdf.defDim(ncid,'z', length(SWIFT(1).signature.profile.z));
        z_names = fieldnames(SWIFT(1).signature.profile);
    end
end



j=1
for i=1:length(full_names);
    if ~strcmp(full_names{i},'ID') && ~strcmp(full_names{i},'date')
        if strcmp(full_names{i},'signature')
            for t=1:length(SWIFT)
                for iz=1:length(z_names)
                    eval(strcat('S.signature.profile.',z_names{iz},'(t,:)=SWIFT(t).signature.profile.',z_names{iz},'(:)'))
                end
                for iz=1:length(zHR_names)
                    eval(strcat('S.signature.HRprofile.',zHR_names{iz},'HR(t,:)=SWIFT(t).signature.HRprofile.',zHR_names{iz},'(:)'))
                end
            end
        elseif strcmp(full_names{i},'time')
            S.time= [SWIFT.time]-datenum(1970,1,1,0,0,0);
        else
            eval(strcat('S.',full_names{i},'=[SWIFT.',full_names{i},']'));
        end
        names{j} = full_names{i};
        j = j+1;
    end
end


%% creating netcdf variables 

for i=1:length(names)
    if strcmp(names{i},'wavespectra')
        for j=1:length(spec_names)
            if strcmp(spec_names{j},'freq')
                eval(strcat(spec_names{j},'_id = netcdf.defVar(ncid,''',spec_names{j},''',''NC_DOUBLE'',[f_dim])'));
            else
                eval(strcat(spec_names{j},'_id = netcdf.defVar(ncid,''',spec_names{j},''',''NC_DOUBLE'',[t_dim f_dim])'));
            end
        end
    elseif strcmp(names{i},'uplooking') || strcmp(names{i},'downlooking')
        for j=1:length(z_names)
            if strcmp(z_names{j},'z')
                eval(strcat(z_names{j},'_id = netcdf.defVar(ncid,''',z_names{j},''',''NC_DOUBLE'',[z_dim])'));
%             elseif strcmp(z_names{j},'tkedissipationrate')
%                 eval(strcat(z_names{j},'_id = netcdf.defVar(ncid,''',z_names{j},''',''NC_DOUBLE'',[t_dim])'));
            else
                eval(strcat(z_names{j},'_id = netcdf.defVar(ncid,''',z_names{j},''',''NC_DOUBLE'',[t_dim z_dim])'));
            end
        end   
    elseif strcmp(names{i},'signature')
        for j=1:length(z_names)
            if strcmp(z_names{j},'altimeter')
                eval(strcat(z_names{j},'_id = netcdf.defVar(ncid,''',z_names{j},''',''NC_DOUBLE'',[t_dim])'));
            elseif strcmp(z_names{j},'z')
                eval(strcat(z_names{j},'_id = netcdf.defVar(ncid,''',z_names{j},''',''NC_DOUBLE'',[z_dim])'));
            else
                eval(strcat(z_names{j},'_id = netcdf.defVar(ncid,''',z_names{j},''',''NC_DOUBLE'',[t_dim z_dim])'));
            end
        end   
        for j=1:length(zHR_names)
            if strcmp(zHR_names{j},'z')
                zHR_id = netcdf.defVar(ncid,'zHR','NC_DOUBLE',[zHR_dim]);
            else
                eval(strcat(zHR_names{j},'HR_id = netcdf.defVar(ncid,''',zHR_names{j},'HR'',''NC_DOUBLE'',[t_dim zHR_dim])'));
            end
        end
        %edit variable names to CF convention names - do this for all vars
        %with different names than the SWIFT defaults
    elseif strcmp(names{i},'lon')
        eval(strcat(names{i},'_id = netcdf.defVar(ncid,''lon'',''NC_DOUBLE'',[t_dim])'));
    elseif strcmp(names{i},'lat')
        eval(strcat(names{i},'_id = netcdf.defVar(ncid,''lat'',''NC_DOUBLE'',[t_dim])'));
    elseif strcmp(names{i},'watertemp')
        eval(strcat(names{i},'_id = netcdf.defVar(ncid,''sea_water_temperature'',''NC_DOUBLE'',[t_dim])'));
    elseif strcmp(names{i},'watertemp_d2')
        eval(strcat(names{i},'_id = netcdf.defVar(ncid,''sea_water_temperature_at_depth'',''NC_DOUBLE'',[t_dim])'));
    elseif strcmp(names{i},'airtemp')
        eval(strcat(names{i},'_id = netcdf.defVar(ncid,''air_temperature'',''NC_DOUBLE'',[t_dim])'));
    elseif strcmp(names{i},'salinity')
        eval(strcat(names{i},'_id = netcdf.defVar(ncid,''sea_water_salinity'',''NC_DOUBLE'',[t_dim])'));
    elseif strcmp(names{i},'salinity_d2')
        eval(strcat(names{i},'_id = netcdf.defVar(ncid,''sea_water_salinity_at_depth'',''NC_DOUBLE'',[t_dim])'));
    elseif strcmp(names{i},'lat')
        eval(strcat(names{i},'_id = netcdf.defVar(ncid,''latitude'',''NC_DOUBLE'',[t_dim])'));
    elseif strcmp(names{i},'qa')
        eval(strcat(names{i},'_id = netcdf.defVar(ncid,''specific_humidity'',''NC_DOUBLE'',[t_dim])'));
    elseif strcmp(names{i},'peakwavedirT')
        eval(strcat(names{i},'_id = netcdf.defVar(ncid,''sea_surface_wave_from_direction_at_variance_spectral_density_maximum'',''NC_DOUBLE'',[t_dim])'));  
    elseif strcmp(names{i},'peakwaveperiod')
        eval(strcat(names{i},'_id = netcdf.defVar(ncid,''sea_surface_wave_period_at_variance_spectral_density_maximum'',''NC_DOUBLE'',[t_dim])'));  
    elseif strcmp(names{i},'centroidwaveperiod')
        eval(strcat(names{i},'_id = netcdf.defVar(ncid,''sea_surface_wave_mean_period'',''NC_DOUBLE'',[t_dim])'));  
    elseif strcmp(names{i},'sigwaveheight')
        eval(strcat(names{i},'_id = netcdf.defVar(ncid,''sea_surface_wave_significant_height'',''NC_DOUBLE'',[t_dim])'));  
    elseif strcmp(names{i},'mss')
        eval(strcat(names{i},'_id = netcdf.defVar(ncid,''sea_surface_wave_mean_square_slope_normalized_by_frequency_width'',''NC_DOUBLE'',[t_dim])'));  
    elseif strcmp(names{i},'ustar')
        eval(strcat(names{i},'_id = netcdf.defVar(ncid,''friction_velocity_in_air_from_wave_spectra'',''NC_DOUBLE'',[t_dim])'));  
    elseif strcmp(names{i},'airtempstddev')
        eval(strcat(names{i},'_id = netcdf.defVar(ncid,''air_temperature_stddev'',''NC_DOUBLE'',[t_dim])'));  
    elseif strcmp(names{i},'windspd')
        eval(strcat(names{i},'_id = netcdf.defVar(ncid,''wind_speed'',''NC_DOUBLE'',[t_dim])'));  
    elseif strcmp(names{i},'windspdstddev')
        eval(strcat(names{i},'_id = netcdf.defVar(ncid,''wind_speed_stddev'',''NC_DOUBLE'',[t_dim])'));  
    elseif strcmp(names{i},'winddirT')
        eval(strcat(names{i},'_id = netcdf.defVar(ncid,''wind_direction'',''NC_DOUBLE'',[t_dim])'));  
    elseif strcmp(names{i},'winddirTstddev')
        eval(strcat(names{i},'_id = netcdf.defVar(ncid,''wind_direction_stddev'',''NC_DOUBLE'',[t_dim])'));  
    elseif strcmp(names{i},'driftspd')
        eval(strcat(names{i},'_id = netcdf.defVar(ncid,''drift_speed'',''NC_DOUBLE'',[t_dim])'));  
    elseif strcmp(names{i},'driftdirT')
        eval(strcat(names{i},'_id = netcdf.defVar(ncid,''drift_direction'',''NC_DOUBLE'',[t_dim])'));  
    elseif strcmp(names{i},'relhumidity')
        eval(strcat(names{i},'_id = netcdf.defVar(ncid,''relative_humidity'',''NC_DOUBLE'',[t_dim])'));
    elseif strcmp(names{i},'qsea')
        eval(strcat(names{i},'_id = netcdf.defVar(ncid,''sea_surface_saturation_specific_humidity'',''NC_DOUBLE'',[t_dim])'));
    elseif strcmp(names{i},'qair')
        eval(strcat(names{i},'_id = netcdf.defVar(ncid,''specific_humidity'',''NC_DOUBLE'',[t_dim])'));
    elseif strcmp(names{i},'relhumiditystddev')
        eval(strcat(names{i},'_id = netcdf.defVar(ncid,''relative_humidity_stddev'',''NC_DOUBLE'',[t_dim])'));
    elseif strcmp(names{i},'airpres')
        eval(strcat(names{i},'_id = netcdf.defVar(ncid,''air_pressure'',''NC_DOUBLE'',[t_dim])'));
    elseif strcmp(names{i},'airpresstddev')
        eval(strcat(names{i},'_id = netcdf.defVar(ncid,''air_pressure_stddev'',''NC_DOUBLE'',[t_dim])'));
    elseif strcmp(names{i},'flag_values_watertemp')
        eval(strcat(names{i},'_id = netcdf.defVar(ncid,''flag_values_watertemp'',''NC_DOUBLE'',[t_dim])'));
    elseif strcmp(names{i},'flag_values_airtemp')
        eval(strcat(names{i},'_id = netcdf.defVar(ncid,''flag_values_airtemp'',''NC_DOUBLE'',[t_dim])'));
    elseif strcmp(names{i},'flag_values_humidity')
        eval(strcat(names{i},'_id = netcdf.defVar(ncid,''flag_values_humidity'',''NC_DOUBLE'',[t_dim])'));
    elseif strcmp(names{i},'flag_values_windpsd')
        eval(strcat(names{i},'_id = netcdf.defVar(ncid,''flag_values_windspd'',''NC_DOUBLE'',[t_dim])'));
    elseif strcmp(names{i},'flag_values_salinity')
        eval(strcat(names{i},'_id = netcdf.defVar(ncid,''flag_values_salinity'',''NC_DOUBLE'',[t_dim])'));
    
    elseif ~strcmp(names{i},'ID')
        eval(strcat(names{i},'_id = netcdf.defVar(ncid,''',names{i},''',''NC_DOUBLE'',[t_dim])'));

    end
end


% define some global attributes
varid = netcdf.getConstant('GLOBAL');
netcdf.putAtt(ncid,varid,'creation_date',datestr(now));
netcdf.putAtt(ncid,varid,'creator','Suneil Iyer (APL-UW), Elizabeth Thompson (NOAA PSL), Jim Thomson (APL-UW), Kyla Drushka (APL-UW)');
netcdf.putAtt(ncid,varid,'please_acknowledge:','four investigators above');
netcdf.putAtt(ncid,varid,'institution','Applied Physics Laboratory at the University of Washington (APL-UW), NOAA Physical Sciences Division (NOAA PSL)');
netcdf.putAtt(ncid,varid,'contact_email_1','iyersk@uw.edu');
netcdf.putAtt(ncid,varid,'contact_email_2','elizabeth.thompson@noaa.gov');
netcdf.putAtt(ncid,varid,'contact_email_3','jthomson@apl.washington.edu');
netcdf.putAtt(ncid,varid,'contact_email_4','kdrushka@apl.uw.edu');
if swiftnum < 100 %2 digit input number = SWIFT
    netcdf.putAtt(ncid,varid,'description',['Data collected from SWIFT ' num2str(swiftnum) ' during the NOAA ATOMIC field campaign in January-February 2020 on the R/V Ronald H. Brown to the northwestern tropical Atlantic (ENE of Barbados), part of the EUREC4A campaign (references 3 and 4).']);
end
netcdf.putAtt(ncid,varid,'comment','Corrections were applied to air temperature, water temperature, wind speed, relative humidity, and salinity data to account for offsets between individual sensors. This was done by assuming the ship data were correct and calculating average linear offsets for night-time points within 2-15 km of the ship (distance dictated by data availability). ');
netcdf.putAtt(ncid,varid,'comment2','Sensor correction offsets were 0-3 degrees C (air temperature), 0-0.4 degrees C (water temperature), 0-2 m/s (wind speed), 0-2.1% (relative humidity), and 0-0.4 psu (salinity). See references 1,2.');
if swiftnum < 21.5
netcdf.putAtt(ncid,varid,'comment3','"flag_values" variables flag poor quality (flag=2) or questionable (flag=1) data. Poor data (flag=2) usually result from unrealistic diurnal heating of sensors. Questionable data generally consist of low spikes that may result from atmospheric cold pools, but may also result from sea spray impacting atmospheric measurements. Air temperature data were flagged as questionable when air temperature changed by more than 0.5 degrees over 3 hours or wind speeds were greater than 7 m/s. Air temperature data were flagged as bad and removed during the day (10:00 to 22:00 UTC). Before using data flagged as questionable, it is recommended that air temperature/humidity spikes are verified with nearby ship observations. Variables without an ancillary flag variable were determined to not contain questionable data.');
end
if swiftnum > 21.5 && swiftnum < 100
netcdf.putAtt(ncid,varid,'comment3','"flag_values" variables flag poor quality (flag=2) or questionable (flag=1) data, possibly resulting sea spray impacting atmospheric measurements. Air temperature and relative humidity data were flagged as questionable when air temperature or relative humidity changed by more than 0.5 degrees or 3% over 3 hours. Most of these rapid temperature/humidity changes are likely reasonable (compare well with atmospheric cold pools observed by the nearby NOAA Ship Ronald H. Brown). Before using data flagged as questionable, it is recommended that air temperature/humidity spikes are verified with nearby ship observations. Variables without an ancillary flag variable were determined to not contain questionable data.');
end
if swiftnum > 100
netcdf.putAtt(ncid,varid,'comment3','"flag_values" variables flag poor quality (flag=2) or questionable (flag=1) data, usually resulting from either the unrealistic diurnal heating of sensors or sea spray impacting atmospheric measurements. Air temperature data were flagged as questionable when air temperature changed by more than 0.5 degrees over 3 hours or wind speeds were greater than 8.5 m/s. Air temperature and air pressure data were flagged as bad and removed when air temperature changed by more than 1.0 degrees over 3 hours and/or during the day (10:00 to 22:00 UTC). Before using data flagged as questionable, it is recommended that air temperature/humidity spikes are verified with nearby ship observations. Variables without an ancillary flag variable were determined to not contain questionable data.');
end
netcdf.putAtt(ncid,varid,'comment4','Ocean "flag_values" variables: Salinity data were flagged as questionable (flag=1) when salinity changed by over 0.02 psu in 3 hours and were flagged as bad and removed when salinity changed by greater than 0.04 psu in 3 hours. Ocean temperature data were flagged (very few points) based on visual identification of poor or questionable data. Variables without an ancillary flag variable were determined to not contain questionable data.');
if swiftnum < 100
netcdf.putAtt(ncid,varid,'temporal_sampling','Data from telemetry. Approximately one measurement per hour. Each data point represents an average of a 10 minute period at the top of each hour.');
end
if swiftnum > 100
netcdf.putAtt(ncid,varid,'temporal_sampling','Data from telemetry. Approximately one measurement per 30 minutes; each data point represents an average over this period of time. Atmospheric data were originally available on a 10 minute resolution but have been smoothed to a 30 minute resolution to be on the same timestamp as ocean data.');
end
netcdf.putAtt(ncid,varid,'level','Version 2.4');
netcdf.putAtt(ncid,varid,'history','Version 2.4 contains Level 2 processed data. Changes from version 2.3 include more detailed quality control (e.g., removing sea spray-influenced variables/other spiky data) and data flags for atmospheric and oceanic parameters, method and instrument documentation, and the addition of wave spectra-derived variables from Iyer et al. (2022).');
netcdf.putAtt(ncid,varid,'missing_data_flag','-999');

%adjust attributes if we have a WaveGlider
%if a waveglider...
if swiftnum > 100 %3 digit input number = Wave Glider
    netcdf.putAtt(ncid,varid,'description',['Data collected from Wave Glider ' num2str(swiftnum) ' during the NOAA ATOMIC field campaign in January-February 2020 on the R/V Ronald H. Brown to the northwestern tropical Atlantic (ENE of Barbados)']);
    netcdf.putAtt(ncid,varid,'temporal_sampling','Data from telemetry. Approximately one measurement per hour. Interpolated from 10 minute lat-lon and 30 minute temperature/salinity data. [See note on air temperature data]');

end

%if a v3 SWIFT...
if swiftnum < 21.5
%     netcdf.putAtt(ncid,varid,'note_2','Additional corrections were made to Airmar air temperature data to correct for unrealistically low values in high wind conditions due to sea spray. This involved applying a 2-hour maximum filter (take the maximum data point every 2 hours). Remaining unrealistic data were removed manually');
    netcdf.putAtt(ncid,varid,'temporal_sampling','Data from telemetry. Approximately one measurement per hour. Each data point represents an average of a 10 minute period at the top of each hour. [See note on air temperature data]');

end

netcdf.putAtt(ncid,varid,'reference1','Iyer, S., Thomson, J., Thompson, E., & Drushka, K. (2022). Variations in wave slope and momentum flux from wave-current interactions in the tropical trade winds. Journal of Geophysical Research: Oceans, 127, e2021JC018003, doi.org/10.1029/2021JC018003.');
netcdf.putAtt(ncid,varid,'reference2','Iyer, S., Drushka, K., Thompson, E., & Thomson, J.. Small-scale spatial variations of air-sea heat and moisture fluxes in the tropical trade winds. Journal of Geophysical Research: Oceans, in prep.');
netcdf.putAtt(ncid,varid,'reference3','Quinn, P.K. et al. (2021). Measurements from the RV Ronald H. Brown and related platforms as part of the Atlantic Tradewind Ocean-Atmosphere Mesoscale Interaction Campaign (ATOMIC). Earth System Science Data 13 (4), 1759-1790, doi.org/10.5194/essd-13-1759-2021.');
netcdf.putAtt(ncid,varid,'reference4','Stevens, B. et al. (2021). EUREC4A. Earth System Science Data 13 (8), 4067-4119, doi.org/10.5194/essd-13-4067-2021.');
netcdf.putAtt(ncid,varid,'reference5','Thomson, J., Girton, J. B., Jha, R., & Trapani, A. (2018). Measurements of directional wave spectra and wind stress from a wave glider autonomous surface vehicle. Journal of Atmospheric and Oceanic Technology, 35(2), 347–363, doi.org/10.1175/JTECH-D-17-0091.1.');

netcdf.endDef(ncid);
%% filling them with values

for i=1:length(names)
    if strcmp(names{i},'wavespectra')
        for j=1:length(spec_names)
            if strcmp(spec_names{j},'freq')
                netcdf.putVar(ncid,freq_id, S.wavespectra(1).freq);
            else
                eval(strcat('netcdf.putVar(ncid,',spec_names{j},'_id, [S.wavespectra.',spec_names{j},']'')'));
            end
        end
    elseif strcmp(names{i},'uplooking')
        for j=1:length(z_names)
            if strcmp(z_names{j},'z')
            	netcdf.putVar(ncid,z_id, S.uplooking(1).z);
            else
                eval(strcat('netcdf.putVar(ncid,',z_names{j},'_id, [S.uplooking.',z_names{j},'])'));
            end
        end   
    elseif strcmp(names{i},'downlooking')
        for j=1:length(z_names)
            if strcmp(z_names{j},'z')
            	netcdf.putVar(ncid,z_id, S.downlooking(1).z);
            else
                eval(strcat('netcdf.putVar(ncid,',z_names{j},'_id, [S.downlooking.',z_names{j},']'')'));
            end                     
        end  
    elseif strcmp(names{i},'signature')
        for j=1:length(z_names)
            if strcmp(z_names{j},'z')
            	netcdf.putVar(ncid,z_id, S.signature.profile.z(1,:));
            else
                eval(strcat('netcdf.putVar(ncid,',z_names{j},'_id, [S.signature.profile.',z_names{j},']'')'));
            end                
        end  
        for j=1:length(zHR_names)
            if strcmp(zHR_names{j},'z')
            	netcdf.putVar(ncid,zHR_id, S.signature.HRprofile.zHR(1,:));
            else
                eval(strcat('netcdf.putVar(ncid,',zHR_names{j},'HR_id, [S.signature.HRprofile.',zHR_names{j},'HR]'')'));
            end              
        end  
    else
        eval(strcat('netcdf.putVar(ncid,',names{i},'_id, S.',names{i},')'));

    end
end


netcdf.close(ncid)


%% units and descriptions
for i=1:length(names)
    if strcmp(names{i},'wavespectra')
        for j=1:length(spec_names)
            if strcmp(spec_names(j),'a1')
                ncwriteatt(filename,'a1','units','m^2 Hz^-1')
                ncwriteatt(filename,'a1','long_name','normalized spectral directional moment (positive east)')
                if swiftnum < 18 %v3 SWIFT
                    ncwriteatt(filename,'a1','instrument','Microstrain 3DM-GX3-35/AHRS')
                elseif swiftnum >= 18 && swiftnum < 100 %v4 SWIFT
                    ncwriteatt(filename,'a1','instrument','SBG Ellipse/AHRS')
                elseif swiftnum >= 100 %Wave Glider
                    ncwriteatt(filename,'a1','instrument','GPSWaves/Microstrain 3DM-GX3-35/AHRS')
                end
                ncwriteatt(filename,'a1','method','Wave spectral processing as shown in Thomson et al., JTech, 2018.')
            end
            if strcmp(spec_names(j),'b1')
                ncwriteatt(filename,'b1','units','m^2 Hz^-1')
                ncwriteatt(filename,'b1','long_name','normalized spectral directional moment (positive north)')
                if swiftnum < 18 %v3 SWIFT
                    ncwriteatt(filename,'b1','instrument','Microstrain 3DM-GX3-35/AHRS')
                elseif swiftnum >= 18 && swiftnum < 100 %v4 SWIFT
                    ncwriteatt(filename,'b1','instrument','SBG Ellipse/AHRS')
                elseif swiftnum >= 100 %Wave Glider
                    ncwriteatt(filename,'b1','instrument','GPSWaves/Microstrain 3DM-GX3-35/AHRS')
                end
                ncwriteatt(filename,'b1','method','Wave spectral processing as shown in Thomson et al., JTech, 2018.')
            end
            if strcmp(spec_names(j),'a2')
                ncwriteatt(filename,'a2','units','m^2 Hz^-1')
                ncwriteatt(filename,'a2','long_name','normalized spectral directional moment (east-west)')
                if swiftnum < 18 %v3 SWIFT
                    ncwriteatt(filename,'a2','instrument','Microstrain 3DM-GX3-35/AHRS')
                elseif swiftnum >= 18 && swiftnum < 100 %v4 SWIFT
                    ncwriteatt(filename,'a2','instrument','SBG Ellipse/AHRS')
                elseif swiftnum >= 100 %Wave Glider
                    ncwriteatt(filename,'a2','instrument','GPSWaves/Microstrain 3DM-GX3-35/AHRS')
                end
                ncwriteatt(filename,'a2','method','Wave spectral processing as shown in Thomson et al., JTech, 2018.')
            end
            if strcmp(spec_names(j),'b2')
                ncwriteatt(filename,'b2','units','m^2 Hz^-1')
                ncwriteatt(filename,'b2','long_name','normalized spectral directional moment (north-south)')
                if swiftnum < 18 %v3 SWIFT
                    ncwriteatt(filename,'b2','instrument','Microstrain 3DM-GX3-35/AHRS')
                elseif swiftnum >= 18 && swiftnum < 100 %v4 SWIFT
                    ncwriteatt(filename,'b2','instrument','SBG Ellipse/AHRS')
                elseif swiftnum >= 100 %Wave Glider
                    ncwriteatt(filename,'b2','instrument','GPSWaves/Microstrain 3DM-GX3-35/AHRS')
                end
                ncwriteatt(filename,'b2','method','Wave spectral processing as shown in Thomson et al., JTech, 2018.')
            end          
            if strcmp(spec_names(j),'energy')
                ncwriteatt(filename,'energy','units','m^2/Hz')
                ncwriteatt(filename,'energy','long_name','wave energy spectral density as a function of frequency')
                ncwriteatt(filename,'energy','standard_name','sea_surface_wave_variance_spectral_density')
                if swiftnum < 18 %v3 SWIFT
                    ncwriteatt(filename,'energy','instrument','Microstrain 3DM-GX3-35/AHRS')
                elseif swiftnum >= 18 && swiftnum < 100 %v4 SWIFT
                    ncwriteatt(filename,'energy','instrument','SBG Ellipse/AHRS')
                elseif swiftnum >= 100 %Wave Glider
                    ncwriteatt(filename,'energy','instrument','GPSWaves/Microstrain 3DM-GX3-35/AHRS')
                end
                ncwriteatt(filename,'energy','method','Wave spectral processing as shown in Thomson et al., JTech, 2018.')
            end             
            if strcmp(spec_names(j),'freq')
                ncwriteatt(filename,'freq','units','Hz')
                ncwriteatt(filename,'freq','long_name','spectral frequencies')
                ncwriteatt(filename,'freq','standard_name','wave_frequency')
                if swiftnum < 18 %v3 SWIFT
                    ncwriteatt(filename,'freq','instrument','Microstrain 3DM-GX3-35/AHRS')
                elseif swiftnum >= 18 && swiftnum < 100 %v4 SWIFT
                    ncwriteatt(filename,'freq','instrument','SBG Ellipse/AHRS')
                elseif swiftnum >= 100 %Wave Glider
                    ncwriteatt(filename,'freq','instrument','GPSWaves/Microstrain 3DM-GX3-35/AHRS')
                end
                ncwriteatt(filename,'freq','method','Wave spectral processing as shown in Thomson et al., JTech, 2018.')

            end                                      
        end
    
    elseif strcmp(names{i},'uplooking')
        for j=1:length(z_names)
            if strcmp(z_names(j),'tkedissipationrate')
                ncwriteatt(filename,'tkedissipationrate','units','W/kg')
                ncwriteatt(filename,'tkedissipationrate','long_name','vertical profiles of turbulent dissipation rate beneath the wave-following free surface')
                ncwriteatt(filename,'tkedissipationrate','standard_name','specific_turbulent_kinetic_energy_dissipation_in_sea_water')
                if swiftnum < 18 %v3 SWIFT
                    ncwriteatt(filename,'tkedissipationrate','instrument','Nortek Aquadopp ADCP')
                elseif swiftnum >= 18 && swiftnum < 100 %v4 SWIFT
                    ncwriteatt(filename,'tkedissipationrate','instrument','Nortek Signature 1000 ADCP with AHRS')
                    ncwriteatt(filename,'tkedissipationrate','comments','Initial examination of these data suggest that these data are questionable as calculated dissipation rates do not decrease with depth. Use with caution.')
                end
            end
            if strcmp(z_names(j),'z')
                ncwriteatt(filename,'z','units','m')
                ncwriteatt(filename,'z','long_name','depth bins for the tke dissipation rate profiles')
                ncwriteatt(filename,'z','standard_name','depth')
            end
        end
    elseif strcmp(names{i},'downlooking')
        for j=1:length(z_names)        
            if strcmp(z_names(j),'velocityprofile')
                ncwriteatt(filename,'velocityprofile','units','m/s')
                ncwriteatt(filename,'velocityprofile','long_name','vertical profiles of horizontal velocity magnitude relative to the float (not corrected for drift)')
                if swiftnum < 18 %v3 SWIFT
                    ncwriteatt(filename,'velocityprofile','instrument','Nortek Aquadopp ADCP')
                elseif swiftnum >= 18 && swiftnum < 100 %v4 SWIFT
                    ncwriteatt(filename,'velocityprofile','instrument','Nortek Signature 1000 ADCP with AHRS')
                elseif swiftnum >=100 %WG
                    ncwriteatt(filename,'velocityprofile','instrument','RDI Workhorse Monitor 300 kHz ADCP')
                end
            end
            if strcmp(z_names(j),'z')
                ncwriteatt(filename,'z','units','m')
                ncwriteatt(filename,'z','long_name','depth bins for the velocity rate profiles')
                ncwriteatt(filename,'z','standard_name','depth')
            end
        end
    elseif strcmp(names{i},'signature')
        for j=1:length(z_names)
            if strcmp(z_names(j),'tkedissipationrate')
                ncwriteatt(filename,'tkedissipationrate','units','W/kg')
                ncwriteatt(filename,'tkedissipationrate','long_name','turbulent dissipation rate')
                ncwriteatt(filename,'tkedissipationrate','standard_name','specific_turbulent_kinetic_energy_dissipation_in_sea_water')
                if swiftnum < 18 %v3 SWIFT
                    ncwriteatt(filename,'tkedissipationrate','instrument','Nortek Aquadopp ADCP')
                elseif swiftnum >= 18 && swiftnum < 100 %v4 SWIFT
                    ncwriteatt(filename,'tkedissipationrate','instrument','Nortek Signature 1000 ADCP with AHRS')
                end
            end  
            if strcmp(z_names(j),'z')
                ncwriteatt(filename,'z','units','m')
                ncwriteatt(filename,'z','long_name','depth bins for currents')
                ncwriteatt(filename,'z','standard_name','depth')
            end  
            if strcmp(z_names(j),'east')
                ncwriteatt(filename,'east','units','m/s')
                ncwriteatt(filename,'east','long_name','eastward currents')
                ncwriteatt(filename,'east','standard_name','eastward_sea_water_velocity')
                if swiftnum < 18 %v3 SWIFT
                    ncwriteatt(filename,'east','instrument','Nortek Aquadopp ADCP')
                elseif swiftnum >= 18 && swiftnum < 100 %v4 SWIFT
                    ncwriteatt(filename,'east','instrument','Nortek Signature 1000 ADCP with AHRS')
                elseif swiftnum >=100 %WG
                    ncwriteatt(filename,'east','instrument','RDI Workhorse Monitor 300 kHz ADCP')
                end
            end 
            if strcmp(z_names(j),'north')
                ncwriteatt(filename,'north','units','m/s')
                ncwriteatt(filename,'north','long_name','northward currents')
                ncwriteatt(filename,'north','standard_name','northward_sea_water_velocity')
                if swiftnum < 18 %v3 SWIFT
                    ncwriteatt(filename,'north','instrument','Nortek Aquadopp ADCP')
                elseif swiftnum >= 18 && swiftnum < 100 %v4 SWIFT
                    ncwriteatt(filename,'north','instrument','Nortek Signature 1000 ADCP with AHRS')
                elseif swiftnum >=100 %WG
                    ncwriteatt(filename,'north','instrument','RDI Workhorse Monitor 300 kHz ADCP')
                end
            end
        end
        for j=1:length(zHR_names)
            if strcmp(zHR_names(j),'tkedissipationrate')
                ncwriteatt(filename,'tkedissipationrateHR','units','W/kg')
                ncwriteatt(filename,'tkedissipationrateHR','long_name','turbulent dissipation rate from HR signature')
                ncwriteatt(filename,'tkedissipationrateHR','standard_name','specific_turbulent_kinetic_energy_dissipation_in_sea_water')
                if swiftnum < 18 %v3 SWIFT
                    ncwriteatt(filename,'tkedissipationrateHR','instrument','Nortek Aquadopp ADCP')
                elseif swiftnum >= 18 && swiftnum < 100 %v4 SWIFT
                    ncwriteatt(filename,'tkedissipationrateHR','instrument','Nortek Signature 1000 ADCP with AHRS')
                    ncwriteatt(filename,'tkedissipationrateHR','comments','Initial examination of these data suggest that these data are questionable as calculated dissipation rates do not decrease with depth. Use with caution.')
                end
            end  
            if strcmp(zHR_names(j),'east')
                ncwriteatt(filename,'east','units','m/s')
                ncwriteatt(filename,'east','long_name','eastward currents')
                ncwriteatt(filename,'east','standard_name','eastward_sea_water_velocity')
                if swiftnum < 18 %v3 SWIFT
                    ncwriteatt(filename,'east','instrument','Nortek Aquadopp ADCP')
                elseif swiftnum >= 18 && swiftnum < 100 %v4 SWIFT
                    ncwriteatt(filename,'east','instrument','Nortek Signature 1000 ADCP with AHRS')
                elseif swiftnum >=100 %WG
                    ncwriteatt(filename,'east','instrument','RDI Workhorse Monitor 300 kHz ADCP')
                end
            end 
            if strcmp(zHR_names(j),'north')
                ncwriteatt(filename,'north','units','m/s')
                ncwriteatt(filename,'north','long_name','northward currents')
                ncwriteatt(filename,'north','standard_name','northward_sea_water_velocity')
                if swiftnum < 18 %v3 SWIFT
                    ncwriteatt(filename,'north','instrument','Nortek Aquadopp ADCP')
                elseif swiftnum >= 18 && swiftnum < 100 %v4 SWIFT
                    ncwriteatt(filename,'north','instrument','Nortek Signature 1000 ADCP with AHRS')
                elseif swiftnum >=100 %WG
                    ncwriteatt(filename,'north','instrument','RDI Workhorse Monitor 300 kHz ADCP')
                end
            end
            if strcmp(zHR_names(j),'z')
                ncwriteatt(filename,'zHR','units','m')
                ncwriteatt(filename,'zHR','long_name','depth bins for turbulent dissipation rate')
                ncwriteatt(filename,'zHR','standard_name','depth')
            end  
        end
    elseif ~strcmp(names{i},'ID')
        if strcmp(names(i),'time')
            ncwriteatt(filename,'time','units','days since 1970-01-01 00:00:00');
            ncwriteatt(filename,'time','long_name','Days since 1 January 1970');
            ncwriteatt(filename,'time','standard_name','time')
        end
        if strcmp(names(i),'lat')
            ncwriteatt(filename,'lat','units','degree_north')
            ncwriteatt(filename,'lat','long_name','latitude')
            ncwriteatt(filename,'lat','standard_name','latitude')
            ncwriteatt(filename,'lat','instrument','GPS')
        end       
        if strcmp(names(i),'lon')
            ncwriteatt(filename,'lon','units','degree_east')
            ncwriteatt(filename,'lon','long_name','longitude')
            ncwriteatt(filename,'lon','standard_name','longitude')
            ncwriteatt(filename,'lon','instrument','GPS')
        end          
        if strcmp(names(i),'watertemp')
            ncwriteatt(filename,'sea_water_temperature','units','degree_C')
            if swiftnum < 18 %v3 SWIFT
                ncwriteatt(filename,'sea_water_temperature','long_name','sea water temperature at 0.5 m depth')
            elseif swiftnum >= 18 && swiftnum < 100 %v4 SWIFT
                ncwriteatt(filename,'sea_water_temperature','long_name','sea water temperature at 0.3 m depth')
            elseif swiftnum >= 100 %Wave Glider
                ncwriteatt(filename,'sea_water_temperature','long_name','sea water temperature at 0.24 m depth')
            end
            ncwriteatt(filename,'sea_water_temperature','standard_name','sea_water_temperature')
            ncwriteatt(filename,'sea_water_temperature','instrument','Aanderaa 4319')
            ncwriteatt(filename,'sea_water_temperature','ancillary_variables','flag_values_watertemp')
            ncwriteatt(filename,'sea_water_temperature','comment','Data flagged in the variable specified in the "ancillary_variables" attribute. 0 = Data are reasonable, 1 = Data are questionable, 2 = Data are unreasonable')
            ncwriteatt(filename,'sea_water_temperature','_FillValue',-999)
        end     
        if strcmp(names(i),'watertemp_d2')
            ncwriteatt(filename,'sea_water_temperature_at_depth','units','degree_C')
            if swiftnum < 18 %v3 SWIFT
                ncwriteatt(filename,'sea_water_temperature_at_depth','long_name','sea water temperature at 1.0 m depth')
                ncwriteatt(filename,'sea_water_temperature_at_depth','instrument','Aanderaa 4319')
            elseif swiftnum >= 100 %Wave Glider
                ncwriteatt(filename,'sea_water_temperature_at_depth','long_name','sea water temperature at 8.0 m depth')
                ncwriteatt(filename,'sea_water_temperature_at_depth','instrument','Seabird GPCTD')
                
            end
            ncwriteatt(filename,'sea_water_temperature_at_depth','standard_name','sea_water_temperature')
            ncwriteatt(filename,'sea_water_temperature_at_depth','ancillary_variables','flag_values_watertemp')
            ncwriteatt(filename,'sea_water_temperature_at_depth','comment','Data flagged in the variable specified in the "ancillary_variables" attribute. 0 = Data are reasonable, 1 = Data are questionable, 2 = Data are unreasonable')
            ncwriteatt(filename,'sea_water_temperature_at_depth','_FillValue',-999)
        end 
        if strcmp(names(i),'qsea')
            ncwriteatt(filename,'sea_surface_saturation_specific_humidity','units','grams_per_kilogram')
            if swiftnum < 18 %v3 SWIFT
                ncwriteatt(filename,'sea_surface_saturation_specific_humidity','long_name','sea_surface saturation specific humidity from sea water temperature at 0.5 m depth')
            elseif swiftnum >= 18 && swiftnum < 100 %v4 SWIFT
                ncwriteatt(filename,'sea_surface_saturation_specific_humidity','long_name','sea_surface saturation specific humidity from sea water temperature at 0.3 m depth')
            elseif swiftnum >= 100 %Wave Glider
                ncwriteatt(filename,'sea_surface_saturation_specific_humidity','long_name','sea_surface saturation specific humidity from sea water temperature at 0.24 m depth')
            end
            ncwriteatt(filename,'sea_surface_saturation_specific_humidity','standard_name','surface_specific_humidity')
            ncwriteatt(filename,'sea_surface_saturation_specific_humidity','method','calculated from sea water temperature')
            ncwriteatt(filename,'sea_surface_saturation_specific_humidity','ancillary_variables','flag_values_watertemp')
            ncwriteatt(filename,'sea_surface_saturation_specific_humidity','comment','Data flagged in the variable specified in the "ancillary_variables" attribute. 0 = Data are reasonable, 1 = Data are questionable, 2 = Data are unreasonable')
            ncwriteatt(filename,'sea_surface_saturation_specific_humidity','_FillValue',-999)
        end   
        if strcmp(names(i),'sigwaveheight')
            ncwriteatt(filename,'sea_surface_wave_significant_height','units','m')
            ncwriteatt(filename,'sea_surface_wave_significant_height','long_name','significant wave height')
            ncwriteatt(filename,'sea_surface_wave_significant_height','standard_name','sea_surface_wave_significant_height')
            if swiftnum < 18 %v3 SWIFT
                ncwriteatt(filename,'sea_surface_wave_significant_height','instrument','Microstrain 3DM-GX3-35/AHRS')
            elseif swiftnum >= 18 && swiftnum < 100 %v4 SWIFT
                ncwriteatt(filename,'sea_surface_wave_significant_height','instrument','SBG Ellipse/AHRS')
            elseif swiftnum >= 100 %Wave Glider
                ncwriteatt(filename,'sea_surface_wave_significant_height','instrument','GPSWaves/Microstrain 3DM-GX3-35/AHRS')
            end
        end            
        if strcmp(names(i),'peakwaveperiod')
            ncwriteatt(filename,'sea_surface_wave_period_at_variance_spectral_density_maximum','units','s')
            ncwriteatt(filename,'sea_surface_wave_period_at_variance_spectral_density_maximum','long_name','peak of period orbital velocity spectra')
            ncwriteatt(filename,'sea_surface_wave_period_at_variance_spectral_density_maximum','standard_name','sea_surface_wave_period_at_variance_spectral_density_maximum')
            if swiftnum < 18 %v3 SWIFT
                ncwriteatt(filename,'sea_surface_wave_period_at_variance_spectral_density_maximum','instrument','Microstrain 3DM-GX3-35/AHRS')
            elseif swiftnum >= 18 && swiftnum < 100 %v4 SWIFT
                ncwriteatt(filename,'sea_surface_wave_period_at_variance_spectral_density_maximum','instrument','SBG Ellipse/AHRS')
            elseif swiftnum >= 100 %Wave Glider
                ncwriteatt(filename,'sea_surface_wave_period_at_variance_spectral_density_maximum','instrument','GPSWaves/Microstrain 3DM-GX3-35/AHRS')
            end
        end    
        if strcmp(names(i),'centroidwaveperiod')
            ncwriteatt(filename,'sea_surface_wave_mean_period','units','s')
            ncwriteatt(filename,'sea_surface_wave_mean_period','long_name','centroid (mean) period orbital velocity spectra')
            ncwriteatt(filename,'sea_surface_wave_mean_period','standard_name','sea_surface_wave_mean_period')
            if swiftnum < 18 %v3 SWIFT
                ncwriteatt(filename,'sea_surface_wave_mean_period','instrument','Microstrain 3DM-GX3-35/AHRS')
            elseif swiftnum >= 18 && swiftnum < 100 %v4 SWIFT
                ncwriteatt(filename,'sea_surface_wave_mean_period','instrument','SBG Ellipse/AHRS')
            elseif swiftnum >= 100 %Wave Glider
                ncwriteatt(filename,'sea_surface_wave_mean_period','instrument','GPSWaves/Microstrain 3DM-GX3-35/AHRS')
            end
        end   
        if strcmp(names(i),'mss')
            ncwriteatt(filename,'sea_surface_wave_mean_square_slope_normalized_by_frequency_width','units','s')
            ncwriteatt(filename,'sea_surface_wave_mean_square_slope_normalized_by_frequency_width','long_name','wave_mean_square_slope_normalized_by_frequency_width of 0.15 (0.25 to 0.4 1/s frequency range). Multiply by frequency width to get unnormalized value.')
            ncwriteatt(filename,'sea_surface_wave_mean_square_slope_normalized_by_frequency_width','standard_name','sea_surface_wave_mean_square_slope')
            if swiftnum < 18 %v3 SWIFT
                ncwriteatt(filename,'sea_surface_wave_mean_square_slope_normalized_by_frequency_width','instrument','Microstrain 3DM-GX3-35/AHRS')
            elseif swiftnum >= 18 && swiftnum < 100 %v4 SWIFT
                ncwriteatt(filename,'sea_surface_wave_mean_square_slope_normalized_by_frequency_width','instrument','SBG Ellipse/AHRS')
            elseif swiftnum >= 100 %Wave Glider
                ncwriteatt(filename,'sea_surface_wave_mean_square_slope_normalized_by_frequency_width','instrument','GPSWaves/Microstrain 3DM-GX3-35/AHRS')
            end
            ncwriteatt(filename,'sea_surface_wave_mean_square_slope_normalized_by_frequency_width','method','Calculated with equation 4 in Iyer et al., JGR Oceans, 2022.')
        end
        if strcmp(names(i),'ustar')
            ncwriteatt(filename,'friction_velocity_in_air_from_wave_spectra','units','m/s')
            ncwriteatt(filename,'friction_velocity_in_air_from_wave_spectra','long_name','friction_velocity_in_air_from_wave_spectra calculated using 0.25 to 0.4 1/s frequency range')
            ncwriteatt(filename,'friction_velocity_in_air_from_wave_spectra','standard_name','friction_velocity_in_air')
            if swiftnum < 18 %v3 SWIFT
                ncwriteatt(filename,'friction_velocity_in_air_from_wave_spectra','instrument','Microstrain 3DM-GX3-35/AHRS')
            elseif swiftnum >= 18 && swiftnum < 100 %v4 SWIFT
                ncwriteatt(filename,'friction_velocity_in_air_from_wave_spectra','instrument','SBG Ellipse/AHRS')
            elseif swiftnum >= 100 %Wave Glider
                ncwriteatt(filename,'friction_velocity_in_air_from_wave_spectra','instrument','GPSWaves/Microstrain 3DM-GX3-35/AHRS')
            end
            ncwriteatt(filename,'friction_velocity_in_air_from_wave_spectra','method','Calculated with equation 3 in Iyer et al., JGR Oceans, 2022.')
        end    
        if strcmp(names(i),'salinity')
            ncwriteatt(filename,'sea_water_salinity','units','psu')
            if swiftnum < 18 %v3 SWIFT
                ncwriteatt(filename,'sea_water_salinity','long_name','sea water salinity at 0.5 m depth')
            elseif swiftnum >= 18 && swiftnum < 100 %v4 SWIFT
                ncwriteatt(filename,'sea_water_salinity','long_name','sea water salinity at 0.3 m depth')
            elseif swiftnum >= 100 %Wave Glider
                ncwriteatt(filename,'sea_water_salinity','long_name','sea water salinity at 0.24 m depth')
            end
            ncwriteatt(filename,'sea_water_salinity','standard_name','sea_water_salinity')
            ncwriteatt(filename,'sea_water_salinity','instrument','Aanderaa 4319')
            ncwriteatt(filename,'sea_water_salinity','ancillary_variables','flag_values_salinity')
            ncwriteatt(filename,'sea_water_salinity','comment','Data flagged in the variable specified in the "ancillary_variables" attribute. 0 = Data are reasonable, 1 = Data are questionable, 2 = Data are unreasonable')
            ncwriteatt(filename,'sea_water_salinity','_FillValue',-999)
        end     
        if strcmp(names(i),'salinity_d2')
            ncwriteatt(filename,'sea_water_salinity_at_depth','units','psu')
            if swiftnum < 18 %v3 SWIFT
                ncwriteatt(filename,'sea_water_salinity_at_depth','long_name','sea water salinity at 1.0 m depth')
                ncwriteatt(filename,'sea_water_salinity_at_depth','instrument','Aanderaa 4319')
            elseif swiftnum >= 100 %Wave Glider
                ncwriteatt(filename,'sea_water_salinity_at_depth','long_name','sea water salinity at 8.0 m depth')
                ncwriteatt(filename,'sea_water_salinity_at_depth','instrument','Seabird GPCTD')
            end
            ncwriteatt(filename,'sea_water_salinity_at_depth','standard_name','sea_water_salinity')
            ncwriteatt(filename,'sea_water_salinity_at_depth','ancillary_variables','flag_values_salinity')
            ncwriteatt(filename,'sea_water_salinity_at_depth','comment','Data flagged in the variable specified in the "ancillary_variables" attribute. 0 = Data are reasonable, 1 = Data are questionable, 2 = Data are unreasonable')
            ncwriteatt(filename,'sea_water_salinity_at_depth','_FillValue',-999)
        end  
        if strcmp(names(i),'peakwavedirT')
            ncwriteatt(filename,'sea_surface_wave_from_direction_at_variance_spectral_density_maximum','units','degree')
            ncwriteatt(filename,'sea_surface_wave_from_direction_at_variance_spectral_density_maximum','long_name','wave direction at spectral peak, direction from north')
            ncwriteatt(filename,'sea_surface_wave_from_direction_at_variance_spectral_density_maximum','standard_name','sea_surface_wave_from_direction_at_variance_spectral_density_maximum')
            if swiftnum < 18 %v3 SWIFT
                ncwriteatt(filename,'sea_surface_wave_from_direction_at_variance_spectral_density_maximum','instrument','Microstrain 3DM-GX3-35/AHRS')
            elseif swiftnum >= 18 && swiftnum < 100 %v4 SWIFT
                ncwriteatt(filename,'sea_surface_wave_from_direction_at_variance_spectral_density_maximum','instrument','SBG Ellipse/AHRS')
            elseif swiftnum >= 100 %Wave Glider
                ncwriteatt(filename,'sea_surface_wave_from_direction_at_variance_spectral_density_maximum','instrument','GPSWaves/Microstrain 3DM-GX3-35/AHRS')
            end
            ncwriteatt(filename,'sea_surface_wave_from_direction_at_variance_spectral_density_maximum','method','Wave spectral processing as described by Thomson et al., JTech, 2018.')
        end  
        if strcmp(names(i),'peakwaveperiod')
            ncwriteatt(filename,'sea_surface_wave_period_at_variance_spectral_density_maximum','units','s')
            ncwriteatt(filename,'sea_surface_wave_period_at_variance_spectral_density_maximum','long_name','peak of period orbital velocity spectra')
            ncwriteatt(filename,'sea_surface_wave_period_at_variance_spectral_density_maximum','standard_name','sea_surface_wave_period_at_variance_spectral_density_maximum')
            if swiftnum < 18 %v3 SWIFT
                ncwriteatt(filename,'sea_surface_wave_period_at_variance_spectral_density_maximum','instrument','Microstrain 3DM-GX3-35/AHRS')
            elseif swiftnum >= 18 && swiftnum < 100 %v4 SWIFT
                ncwriteatt(filename,'sea_surface_wave_period_at_variance_spectral_density_maximum','instrument','SBG Ellipse/AHRS')
            elseif swiftnum >= 100 %Wave Glider
                ncwriteatt(filename,'sea_surface_wave_period_at_variance_spectral_density_maximum','instrument','GPSWaves/Microstrain 3DM-GX3-35/AHRS')
            end
            ncwriteatt(filename,'sea_surface_wave_period_at_variance_spectral_density_maximum','method','Wave spectral processing as described by Thomson et al., JTech, 2018.')
        end  
        if strcmp(names(i),'winddirT')
            ncwriteatt(filename,'wind_direction','units','degree')
            if swiftnum < 18 %v3 SWIFT
                ncwriteatt(filename,'wind_direction','long_name','true wind direction at 0.8 m height above the wave-following surface, direction from north')
                ncwriteatt(filename,'wind_direction','standard_name','wind_from_direction')
                ncwriteatt(filename,'wind_direction','instrument','Airmar 200WX')
            elseif swiftnum >= 18 && swiftnum < 100 %v4 SWIFT
                ncwriteatt(filename,'wind_direction','long_name','true wind direction at 0.5 m height above the wave-following surface, direction from north')
                ncwriteatt(filename,'wind_direction','standard_name','wind_from_direction')
                ncwriteatt(filename,'wind_direction','instrument','Vaisala WXT530')
            elseif swiftnum >= 100 %Wave Glider
                ncwriteatt(filename,'wind_direction','long_name','true wind direction at 1.0 m height above the wave-following surface, direction from north')
                ncwriteatt(filename,'wind_direction','standard_name','wind_from_direction')
                ncwriteatt(filename,'wind_direction','instrument','Airmar 200WX')
            end
        end          
        if strcmp(names(i),'winddirTstddev')
            ncwriteatt(filename,'wind_direction_stddev','units','degree')
            if swiftnum < 18 %v3 SWIFT
                ncwriteatt(filename,'wind_direction_stddev','long_name','standard deviation of true wind direction at 0.8 m height above the wave-following surface')
                ncwriteatt(filename,'wind_direction_stddev','instrument','Airmar 200WX')
            elseif swiftnum >= 18 && swiftnum < 100 %v4 SWIFT
                ncwriteatt(filename,'wind_direction_stddev','long_name','standard deviation of true wind direction at 0.5 m height above the wave-following surface')
                ncwriteatt(filename,'wind_direction_stddev','instrument','Vaisala WXT530')
            elseif swiftnum >= 100 %Wave Glider
                ncwriteatt(filename,'wind_direction_stddev','long_name','standard deviation of true wind direction at 1.0 m height above the wave-following surface')
                ncwriteatt(filename,'wind_direction_stddev','instrument','Airmar 200WX')
            end
        end      
        if strcmp(names(i),'windspd')
            ncwriteatt(filename,'wind_speed','units','m/s')
            if swiftnum < 18 %v3 SWIFT
                ncwriteatt(filename,'wind_speed','long_name','true wind speed at 0.8 m height above the wave-following surface')
                ncwriteatt(filename,'wind_speed','instrument','Airmar 200WX')
            elseif swiftnum >= 18 && swiftnum < 100 %v4 SWIFT
                ncwriteatt(filename,'wind_speed','long_name','true wind speed at 0.5 m height above the wave-following surface')
                ncwriteatt(filename,'wind_speed','instrument','Vaisala WXT530')
            elseif swiftnum >= 100 %Wave Glider
                ncwriteatt(filename,'wind_speed','long_name','true wind speed at 1.0 m height above the wave-following surface')
                ncwriteatt(filename,'wind_speed','instrument','Airmar 200WX')
            end
            ncwriteatt(filename,'wind_speed','standard_name','wind_speed')
            ncwriteatt(filename,'wind_speed','ancillary_variables','flag_values_windspd')
            ncwriteatt(filename,'wind_speed','comment','Data flagged in the variable specified in the "ancillary_variables" attribute. 0 = Data are reasonable, 1 = Data are questionable, 2 = Data are unreasonable')
            ncwriteatt(filename,'wind_speed','_FillValue',-999)
        end   
        if strcmp(names(i),'windspdstddev')
            ncwriteatt(filename,'wind_speed_stddev','units','m/s')
            if swiftnum < 18 %v3 SWIFT
                ncwriteatt(filename,'wind_speed_stddev','long_name','standard deviation of true wind speed at 0.8 m height above the wave-following surface')
                ncwriteatt(filename,'wind_speed','instrument','Airmar 200WX')
            elseif swiftnum >= 18 && swiftnum < 100 %v4 SWIFT
                ncwriteatt(filename,'wind_speed_stddev','long_name','standard deviation of true wind speed at 0.5 m height above the wave-following surface')
                ncwriteatt(filename,'wind_speed_stddev','instrument','Vaisala WXT530')
            elseif swiftnum >= 100 %Wave Glider
                ncwriteatt(filename,'wind_speed_stddev','long_name','standard deviation of true wind speed at 1.0 m height above the wave-following surface')
                ncwriteatt(filename,'wind_speed_stddev','instrument','Airmar 200WX')
            end
            ncwriteatt(filename,'wind_speed_stddev','ancillary_variables','flag_values_windspd')
            ncwriteatt(filename,'wind_speed_stddev','comment','Data flagged in the variable specified in the "ancillary_variables" attribute. 0 = Data are reasonable, 1 = Data are questionable, 2 = Data are unreasonable')
        end
        if strcmp(names(i),'airtemp')
            ncwriteatt(filename,'air_temperature','units','degree_C')
            if swiftnum < 18 %v3 SWIFT
                ncwriteatt(filename,'air_temperature','long_name','air temperature at 0.8 m height above the wave-following surface')
                ncwriteatt(filename,'air_temperature','instrument','Airmar 200WX')
                ncwriteatt(filename,'air_temperature','note','Daytime data (10:00-21:00 UTC) have been replaced with NaNs, because of diurnal heating of the sensor. Additional corrections were made to Airmar air temperature data to correct for unrealistically low values in high wind conditions due to sea spray. This involved applying a 2-hour maximum filter (take the maximum data point every 2 hours). Remaining unrealistic data were removed manually. Because of this processing step, air temperature data should be treated as if the time resolution is 2 hours.');
            elseif swiftnum >= 18 && swiftnum < 100 %v4 SWIFT
                ncwriteatt(filename,'air_temperature','long_name','air temperature at 0.5 m height above the wave-following surface')
                ncwriteatt(filename,'air_temperature','instrument','Vaisala WXT530')
            elseif swiftnum >= 100 %Wave Glider
                ncwriteatt(filename,'air_temperature','long_name','air temperature at 1.0 m height above the wave-following surface')
                ncwriteatt(filename,'air_temperature','instrument','Airmar 200WX')
                ncwriteatt(filename,'air_temperature','note','Daytime data (10:00-21:00 UTC) have been replaced with NaNs, because of diurnal heating of the sensor. Additional corrections were made to Airmar air temperature data to correct for unrealistically low values in high wind conditions due to sea spray. This involved applying a 2-hour maximum filter (take the maximum data point every 2 hours). Remaining unrealistic data were removed manually. Because of this processing step, air temperature data should be treated as if the time resolution is 2 hours.');
            end
            ncwriteatt(filename,'air_temperature','standard_name','air_temperature')
            ncwriteatt(filename,'air_temperature','ancillary_variables','flag_values_airtemp')
            ncwriteatt(filename,'air_temperature','comment','Data flagged in the variable specified in the "ancillary_variables" attribute. 0 = Data are reasonable, 1 = Data are questionable, 2 = Data are unreasonable')
            ncwriteatt(filename,'air_temperature','_FillValue',-999)

        end  
        if strcmp(names(i),'airtempstddev')
            ncwriteatt(filename,'air_temperature_stddev','units','deg C')
            if swiftnum < 18 %v3 SWIFT
                ncwriteatt(filename,'air_temperature_stddev','long_name','standard deviation of air temperature at 0.8 m height above the wave-following surface')
                ncwriteatt(filename,'air_temperature_stddev','instrument','Airmar 200WX')
            elseif swiftnum >= 18 && swiftnum < 100 %v4 SWIFT
                ncwriteatt(filename,'air_temperature_stddev','long_name','standard deviation of air temperature at 0.5 m height above the wave-following surface')
                ncwriteatt(filename,'air_temperature_stddev','instrument','Vaisala WXT530')
            elseif swiftnum >= 100 %Wave Glider
                ncwriteatt(filename,'air_temperature_stddev','long_name','standard deviation of air temperature at 1.0 m height above the wave-following surface')
                ncwriteatt(filename,'air_temperature_stddev','instrument','Airmar 200WX')
            end
            ncwriteatt(filename,'air_temperature_stddev','ancillary_variables','flag_values_airtemp')
            ncwriteatt(filename,'air_temperature_stddev','comment','Data flagged in the variable specified in the "ancillary_variables" attribute. 0 = Data are reasonable, 1 = Data are questionable, 2 = Data are unreasonable')
            ncwriteatt(filename,'air_temperature_stddev','_FillValue',-999)
        end   
        if strcmp(names(i),'relhumidity')
            ncwriteatt(filename,'relative_humidity','units','%')
            if swiftnum < 18 %v3 SWIFT
                ncwriteatt(filename,'relative_humidity','long_name','relative_humidity at 0.8 m height above the wave-following surface')
                ncwriteatt(filename,'relative_humidity','standard_name','relative_humidity')
            elseif swiftnum >= 18 && swiftnum < 100 %v4 SWIFT
                ncwriteatt(filename,'relative_humidity','long_name','relative_humidity at 0.5 m height above the wave-following surface')
                ncwriteatt(filename,'relative_humidity','instrument','Vaisala WXT530')
                ncwriteatt(filename,'relative_humidity','standard_name','relative_humidity')
            elseif swiftnum >= 100 %Wave Glider
                ncwriteatt(filename,'relative_humidity','long_name','relative_humidity at 1.0 m height above the wave-following surface')
                ncwriteatt(filename,'relative_humidity','standard_name','relative_humidity')
            end
            ncwriteatt(filename,'relative_humidity','ancillary_variables','flag_values_humidity')
            ncwriteatt(filename,'relative_humidity','comment','Data flagged in the variable specified in the "ancillary_variables" attribute. 0 = Data are reasonable, 1 = Data are questionable, 2 = Data are unreasonable')
            ncwriteatt(filename,'relative_humidity','_FillValue',-999)
        end
        if strcmp(names(i),'qair')
            ncwriteatt(filename,'specific_humidity','units','grams_per_kilogram')
            if swiftnum < 18 %v3 SWIFT
                ncwriteatt(filename,'specific_humidity','long_name','specific_humidity at 0.8 m height above the wave-following surface')
                ncwriteatt(filename,'specific_humidity','standard_name','specific_humidity')
            elseif swiftnum >= 18 && swiftnum < 100 %v4 SWIFT
                ncwriteatt(filename,'specific_humidity','long_name','specific_humidity at 0.5 m height above the wave-following surface')
                ncwriteatt(filename,'specific_humidity','standard_name','specific_humidity')
            elseif swiftnum >= 100 %Wave Glider
                ncwriteatt(filename,'specific_humidity','long_name','specific_humidity at 1.0 m height above the wave-following surface')
                ncwriteatt(filename,'specific_humidity','standard_name','specific_humidity')
            end
            ncwriteatt(filename,'specific_humidity','method','calculated from air temperature, air pressure, and relative humidity')
            ncwriteatt(filename,'specific_humidity','ancillary_variables','flag_values_humidity')
            ncwriteatt(filename,'specific_humidity','comment','Data flagged in the variable specified in the "ancillary_variables" attribute. 0 = Data are reasonable, 1 = Data are questionable, 2 = Data are unreasonable')
            ncwriteatt(filename,'specific_humidity','_FillValue',-999)
        end
        if strcmp(names(i),'relhumiditystddev')
            ncwriteatt(filename,'relative_humidity_stddev','units','')
            if swiftnum < 18 %v3 SWIFT
                ncwriteatt(filename,'relative_humidity_stddev','long_name','standard deviation of relative_humidity at 0.8 m height above the wave-following surface')
            elseif swiftnum >= 18 && swiftnum < 100 %v4 SWIFT
                ncwriteatt(filename,'relative_humidity_stddev','long_name','standard deviation of relative_humidity at 0.5 m height above the wave-following surface')
                ncwriteatt(filename,'relative_humidity_stddev','instrument','Vaisala WXT530')
            elseif swiftnum >= 100 %Wave Glider
                ncwriteatt(filename,'relative_humidity_stddev','long_name','standard deviation of relative_humidity at 1.0 m height above the wave-following surface')
            end
            ncwriteatt(filename,'relative_humidity_stddev','ancillary_variables','flag_values_humidity')
            ncwriteatt(filename,'relative_humidity_stddev','comment','Data flagged in the variable specified in the "ancillary_variables" attribute. 0 = Data are reasonable, 1 = Data are questionable, 2 = Data are unreasonable')
            ncwriteatt(filename,'relative_humidity_stddev','_FillValue',-999)
        end
        if strcmp(names(i),'airpres')
            ncwriteatt(filename,'air_pressure','units','Pa')
            if swiftnum < 18 %v3 SWIFT
                ncwriteatt(filename,'air_pressure','long_name','air pressure at 0.8 m height above the wave-following surface')
                ncwriteatt(filename,'air_pressure','instrument','Airmar 200WX')
            elseif swiftnum >= 18 && swiftnum < 100 %v4 SWIFT
                ncwriteatt(filename,'air_pressure','long_name','air pressure at 0.5 m height above the wave-following surface')
                ncwriteatt(filename,'air_pressure','instrument','Vaisala WXT530')
            elseif swiftnum >= 100 %Wave Glider
                ncwriteatt(filename,'air_pressure','long_name','air pressure at 1.0 m height above the wave-following surface')
                ncwriteatt(filename,'air_pressure','instrument','Airmar 200WX')
            end
            ncwriteatt(filename,'air_pressure','standard_name','air_pressure')
            ncwriteatt(filename,'air_pressure','ancillary_variables','flag_values_airtemp')
            ncwriteatt(filename,'air_pressure','_FillValue',-999)
        end  
        if strcmp(names(i),'airpresstddev')
            ncwriteatt(filename,'air_pressure_stddev','units','Pa')
            if swiftnum < 18 %v3 SWIFT
                ncwriteatt(filename,'air_pressure_stddev','long_name','standard deviation of air pressure at 0.8 m height above the wave-following surface')
                ncwriteatt(filename,'air_pressure_stddev','instrument','Airmar 200WX')
            elseif swiftnum >= 18 && swiftnum < 100 %v4 SWIFT
                ncwriteatt(filename,'air_pressure_stddev','long_name','standard deviation of air pressure at 0.5 m height above the wave-following surface')
                ncwriteatt(filename,'air_pressure_stddev','instrument','Vaisala WXT530')
            elseif swiftnum >= 100 %Wave Glider
                ncwriteatt(filename,'air_pressure_stddev','long_name','standard deviation of air pressure at 1.0 m height above the wave-following surface')
                ncwriteatt(filename,'air_pressure_stddev','instrument','Airmar 200WX')
            end
            ncwriteatt(filename,'air_pressure_stddev','ancillary_variables','flag_values_airtemp')
            ncwriteatt(filename,'air_pressure_stddev','_FillValue',-999)
        end  
        if strcmp(names(i),'flag_values_watertemp')
            ncwriteatt(filename,'flag_values_watertemp','description','flags')
            ncwriteatt(filename,'flag_values_watertemp','long_name','flag_values_for_sea_water_temperature_variable')
            ncwriteatt(filename,'flag_values_watertemp','comment','flag values for sea water temperature: 0 = reasonable, 1 = questionable data, 2 = bad data')
            ncwriteatt(filename,'flag_values_watertemp','ancillary_variables','sea_water_temperature')
            if swiftnum > 244 & swiftnum < 246
                    ncwriteatt(filename,'flag_values_watertemp','comment','flag values for sea water temperature and sea water temperature at depth: 0 = reasonable, 1 = questionable data, 2 = bad data')
                    ncwriteatt(filename,'flag_values_watertemp','ancillary_variables','sea_water_temperature,sea_water_temperature_at_depth')
            end
        end
        if strcmp(names(i),'flag_values_salinity')
            ncwriteatt(filename,'flag_values_salinity','description','flags')
            ncwriteatt(filename,'flag_values_salinity','long_name','flag_values_for_sea_water_salinity_variable')
            ncwriteatt(filename,'flag_values_salinity','comment','flag values for sea water salinity: 0 = reasonable, 1 = questionable data, 2 = bad data')
            ncwriteatt(filename,'flag_values_salinity','ancillary_variables','sea_water_salinity')
            if swiftnum > 244 & swiftnum < 246
                    ncwriteatt(filename,'flag_values_salinity','comment','flag values for sea water salinity and sea water salinity at depth: 0 = reasonable, 1 = questionable data, 2 = bad data')
                    ncwriteatt(filename,'flag_values_salinity','ancillary_variables','sea_water_salinity,sea_water_salinity_at_depth')
            end
        end
        if strcmp(names(i),'flag_values_airtemp')
            ncwriteatt(filename,'flag_values_airtemp','description','flags')
            ncwriteatt(filename,'flag_values_airtemp','long_name','flag_values_for_air_temperature_variable')
            ncwriteatt(filename,'flag_values_airtemp','comment','flag values for air temperature (and air pressure): 0 = reasonable, 1 = questionable data, 2 = bad data')
            if swiftnum < 100
                    ncwriteatt(filename,'flag_values_airtemp','comment2','Questionable data (=1) are usually rapid decreases that likely correspond to atmospheric cold pools, but the artificial influence of sea spray cannot be ruled out')
            end
            if swiftnum > 100
                    ncwriteatt(filename,'flag_values_airtemp','comment2','Questionable data (=1) are usually rapid decreases that correspond to either atmospheric cold pools or the artificial influence of sea spray')
            end
            ncwriteatt(filename,'flag_values_airtemp','ancillary_variables','air_temperature,air_pressure')
        end
        if strcmp(names(i),'flag_values_windspd')
            ncwriteatt(filename,'flag_values_windspd','description','flags')
            ncwriteatt(filename,'flag_values_windspd','long_name','flag_values_for_wind_speed_variable')
            ncwriteatt(filename,'flag_values_windspd','comment','flag values for wind speed: 0 = reasonable, 1 = questionable data, 2 = bad data')
            ncwriteatt(filename,'flag_values_windspd','ancillary_variables','wind_speed')
        end
        if strcmp(names(i),'flag_values_humidity')
            ncwriteatt(filename,'flag_values_humidity','description','flags')
            ncwriteatt(filename,'flag_values_humidity','long_name','flag_values_for_relative_humidity_and_specific_humidity_variable')
            ncwriteatt(filename,'flag_values_humidity','comment','flag values for relative and specific humidity: 0 = reasonable, 1 = questionable data, 2 = bad data')
            if swiftnum < 100
                    ncwriteatt(filename,'flag_values_humidity','comment2','Questionable data (=1) are usually rapid changes that likely correspond to atmospheric cold pools, but the artificial influence of sea spray cannot be ruled out')
            end
            ncwriteatt(filename,'flag_values_humidity','ancillary_variables','relative_humidity,specific_humidity')
        end
        %         if strcmp(names(i),'qa')
%             ncwriteatt(filename,'specific_humidity','units','g/kg')
%             if swiftnum < 18 %v3 SWIFT
%                 ncwriteatt(filename,'specific_humidity','long_name','specific_humidity at 0.8 m height above the wave-following surface')
%             elseif swiftnum >= 18 && swiftnum < 100 %v4 SWIFT
%                 ncwriteatt(filename,'specific_humidity','long_name','specific_humidity at 0.5 m height above the wave-following surface')
%             elseif swiftnum >= 100 %Wave Glider
%                 ncwriteatt(filename,'specific_humidity','long_name','specific_humidity at 1.0 m height above the wave-following surface')
%             end
%             ncwriteatt(filename,'specific_humidity','standard_name','specific_humidity')
%         end 
        if strcmp(names(i),'puck')
            ncwriteatt(filename,'puck','units','')
            ncwriteatt(filename,'puck','long_name','three color channels of a WetLabs puck fluorometer')
        end   
        if strcmp(names(i),'driftdirT')
            ncwriteatt(filename,'drift_direction','units','degree')
            ncwriteatt(filename,'drift_direction','long_name','platform drift direction toward, in degrees to (equivalent to course over ground)')
            ncwriteatt(filename,'drift_direction','instrument','GPS')
        end   
        if strcmp(names(i),'driftspd')
            ncwriteatt(filename,'drift_speed','units','m/s')
            ncwriteatt(filename,'drift_speed','long_name','platform drift speed (equivalent to speed over ground)')
            ncwriteatt(filename,'drift_speed','instrument','GPS')
        end   
        if strcmp(names(i),'z')
            ncwriteatt(filename,'z','units','m')
            ncwriteatt(filename,'z','long_name','reconstruction (via post-processing IMU data) of vertical displacements at 25 Hz')
        end   
        if strcmp(names(i),'x')
            ncwriteatt(filename,'x','units','m')
            ncwriteatt(filename,'x','long_name','reconstruction (via post-processing IMU data) of horizontal east-west displacements at 25 Hz')
        end   
        if strcmp(names(i),'y')
            ncwriteatt(filename,'y','units','m')
            ncwriteatt(filename,'y','long_name','reconstruction (via post-processing IMU data) of horizontal north-south displacements at 25 Hz')
        end   
        if strcmp(names(i),'u')
            ncwriteatt(filename,'u','units','m/s')
            ncwriteatt(filename,'u','long_name','east-west GPS velocities at 4 Hz')
        end          
        if strcmp(names(i),'v')
            ncwriteatt(filename,'v','units','m/s')
            ncwriteatt(filename,'v','long_name','north-south GPS velocities at 4 Hz')
        end          
        if strcmp(names(i),'')
            ncwriteatt(filename,'','units','')
            ncwriteatt(filename,'','long_name','')
        end          

        
        
        
    end
end





end


    
