function SWIFT2NC(SWIFT_in,filename)


% creates a netCDF file using existing SWIFT structure and writes it into 'filename'
% (must include .nc)

% skip substructures that are not supported yet:

SWIFT=SWIFT_in
if isfield(SWIFT,'wavehistogram')
    SWIFT=rmfield(SWIFT,'wavehistogram');
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
    elseif strcmp(names{i},'lon')
        eval(strcat(names{i},'_id = netcdf.defVar(ncid,''lon_lagrangian'',''NC_DOUBLE'',[t_dim])'));
    elseif strcmp(names{i},'lat')
        eval(strcat(names{i},'_id = netcdf.defVar(ncid,''lat_lagrangian'',''NC_DOUBLE'',[t_dim])'));
    elseif ~strcmp(names{i},'ID')
        eval(strcat(names{i},'_id = netcdf.defVar(ncid,''',names{i},''',''NC_DOUBLE'',[t_dim])'));

    end
end

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
            end
            if strcmp(spec_names(j),'b1')
                ncwriteatt(filename,'b1','units','m^2 Hz^-1')
                ncwriteatt(filename,'b1','long_name','normalized spectral directional moment (positive north)')
            end
            if strcmp(spec_names(j),'a2')
                ncwriteatt(filename,'a2','units','m^2 Hz^-1')
                ncwriteatt(filename,'a2','long_name','normalized spectral directional moment (east-west)')
            end
            if strcmp(spec_names(j),'b2')
                ncwriteatt(filename,'b2','units','m^2 Hz^-1')
                ncwriteatt(filename,'b2','long_name','normalized spectral directional moment (north-south)')
            end
            if strcmp(spec_names(j),'b2')
                ncwriteatt(filename,'b2','units','m^2 Hz^-1')
                ncwriteatt(filename,'b2','long_name','normalized spectral directional moment (north-south)')
            end            
            if strcmp(spec_names(j),'energy')
                ncwriteatt(filename,'energy','units','m^2/Hz')
                ncwriteatt(filename,'energy','long_name','wave energy spectral density as a function of frequency')
            end             
            if strcmp(spec_names(j),'freq')
                ncwriteatt(filename,'freq','units','Hz')
                ncwriteatt(filename,'freq','long_name','spectral frequencies')
            end                                      
        end
    
    elseif strcmp(names{i},'uplooking')
        for j=1:length(z_names)
            if strcmp(z_names(j),'tkedissipationrate')
                ncwriteatt(filename,'tkedissipationrate','units','W/kg')
                ncwriteatt(filename,'tkedissipationrate','long_name','vertical profiles of turbulent dissipation rate beneath the wave-following free surface')
            end
            if strcmp(z_names(j),'z')
                ncwriteatt(filename,'z','units','m')
                ncwriteatt(filename,'z','long_name','depth bins for the tke dissipation rate profiles')
            end
        end
    elseif strcmp(names{i},'downlooking')
        for j=1:length(z_names)        
            if strcmp(z_names(j),'velocityprofile')
                ncwriteatt(filename,'velocityprofile','units','m/s')
                ncwriteatt(filename,'velocityprofile','long_name','vertical profiles of horizontal velocity magnitude relative to the float (not corrected for drift)')
            end
            if strcmp(z_names(j),'z')
                ncwriteatt(filename,'z','units','m')
                ncwriteatt(filename,'z','long_name','depth bins for the velocity rate profiles')
            end
        end
    elseif strcmp(names{i},'signature')
        for j=1:length(z_names)
            if strcmp(z_names(j),'tkedissipationrate')
                ncwriteatt(filename,'tkedissipationrate','units','W/kg')
                ncwriteatt(filename,'tkedissipationrate','long_name','turbulent dissipation rate')
            end  
            if strcmp(z_names(j),'z')
                ncwriteatt(filename,'z','units','m')
                ncwriteatt(filename,'z','long_name','depth bins for turbulent dissipation rate')
            end  
        end
        for j=1:length(zHR_names)
            if strcmp(zHR_names(j),'east')
                ncwriteatt(filename,'east','units','m/s')
                ncwriteatt(filename,'east','long_name','eastward currents')
            end 
            if strcmp(zHR_names(j),'north')
                ncwriteatt(filename,'north','units','m/s')
                ncwriteatt(filename,'north','long_name','northward currents')
            end  
            if strcmp(zHR_names(j),'z')
                ncwriteatt(filename,'z','units','m')
                ncwriteatt(filename,'z','long_name','depth bins for currents')
            end  
        end
    elseif ~strcmp(names{i},'ID')
        if strcmp(names(i),'time')
            ncwriteatt(filename,'time','units','days since 1970-01-01 00:00:00');
            ncwriteatt(filename,'time','long_name','Days since 1 January 1970');
        end
        if strcmp(names(i),'lat')
            ncwriteatt(filename,'lat_lagrangian','units','degrees_north')
            ncwriteatt(filename,'lat_lagrangian','long_name','latitude in decimal degrees')
        end       
        if strcmp(names(i),'lon')
            ncwriteatt(filename,'lon_lagrangian','units','degrees_east')
            ncwriteatt(filename,'lon_lagrangian','long_name','longitude in decimal degrees')
        end          
        if strcmp(names(i),'watertemp')
            ncwriteatt(filename,'watertemp','units','C')
            ncwriteatt(filename,'watertemp','long_name','water temperature')
        end           
        if strcmp(names(i),'sigwaveheight')
            ncwriteatt(filename,'sigwaveheight','units','m')
            ncwriteatt(filename,'sigwaveheight','long_name','significant wave height')
        end            
        if strcmp(names(i),'peakwaveperiod')
            ncwriteatt(filename,'peakwaveperiod','units','s')
            ncwriteatt(filename,'peakwaveperiod','long_name','peak of period orbital velocity spectra')
        end     
        if strcmp(names(i),'salinity')
            ncwriteatt(filename,'salinity','units','psu')
            ncwriteatt(filename,'salinity','long_name','water salinity')
        end       
        if strcmp(names(i),'peakwavedirT')
            ncwriteatt(filename,'peakwavedirT','units','degrees from north')
            ncwriteatt(filename,'peakwavedirT','long_name','wave direction FROM North')
        end  
        if strcmp(names(i),'peakwaveperiod')
            ncwriteatt(filename,'peakwaveperiod','units','s')
            ncwriteatt(filename,'peakwaveperiod','long_name','peak of period orbital velocity spectra')
        end  
        if strcmp(names(i),'winddirT')
            ncwriteatt(filename,'winddirT','units','degrees from north')
            ncwriteatt(filename,'winddirT','long_name','true wind direction')
        end          
        if strcmp(names(i),'winddirTstddev')
            ncwriteatt(filename,'winddirTstddev','units','degrees')
            ncwriteatt(filename,'winddirTstddev','long_name','standard deviation of true wind direction')
        end      
        if strcmp(names(i),'windspd')
            ncwriteatt(filename,'windspd','units','m/s')
            ncwriteatt(filename,'windspd','long_name','wind speed at 1 m height above the wave-following surface')
        end   
        if strcmp(names(i),'windspdstddev')
            ncwriteatt(filename,'windspdstddev','units','m/s')
            ncwriteatt(filename,'windspdstddev','long_name','standard deviation of wind speed')
        end   
        if strcmp(names(i),'airtemp')
            ncwriteatt(filename,'airtemp','units','deg C')
            ncwriteatt(filename,'airtemp','long_name','air temperature at 1 m height above the wave-following surface')
        end   
        if strcmp(names(i),'airtempstddev')
            ncwriteatt(filename,'airtempstddev','units','deg C')
            ncwriteatt(filename,'airtempstddev','long_name','standard deviation of air temperature')
        end   
        if strcmp(names(i),'puck')
            ncwriteatt(filename,'puck','units','')
            ncwriteatt(filename,'puck','long_name','three color channels of a WetLabs puck fluorometer')
        end   
        if strcmp(names(i),'driftdirT')
            ncwriteatt(filename,'driftdirT','units','degrees')
            ncwriteatt(filename,'driftdirT','long_name','drift direction TOWARDS, in degrees True (equivalent to course over ground)')
        end   
        if strcmp(names(i),'dirftspd')
            ncwriteatt(filename,'dirftspd','units','m/s')
            ncwriteatt(filename,'dirftspd','long_name','drift speed (equivalent to speed over ground)')
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


    
