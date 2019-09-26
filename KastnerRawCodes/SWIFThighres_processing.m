%%%%%%%%%%%%%%%% SWIFThighres_processing.m
% creates products from SWIFT data at higher resolution than the standard burst averages
% Works on a given directory of SWIFT subdirectories. 
% Requires extraction of raw data into SWIFT structures beforehand.
% Note that standard SWIFT structures (full burst length) must use start times as timestamp
%
% S. Kastner, c. 2018
%   J. Thomson, 9/2019 adapted for more general use, 
%                       remove raw from final output (for simplicity, size)
%                       remove fields for payloads not present (i.e., AQD, AQH)
%                       prune Signature profiles for depth
%                       apply a reference velocity (drift) to Signature profiles
%                       use dissipation_simple
%   
% left to do:
%   ** need to add met data... and maybe wave spectra? ***
%                   
clear; close all

fullprocess = false; % option to force concatSWIFT_offloadedSDcard, reprocess_SIG_raw, reprocess_SBG_raw, reprocess_ACS_raw
applyvelreference = true; % apply drift correction to signature velocity data

dt=10; %timestep to average over in seconds
num=floor(512/dt); % number of new bursts per normal burst (512 s)

maxsalinity = 35; % for QC
minsalinity = 5; % for QC
percentdry = .1; % maximum precent dry to allow when retaining a new burst

mincor = 0; % for QC when reprocessing turbulence data

parentdir = '/Users/jthomson/Desktop/JRE2019_local/';  % change to suit data
cd(parentdir)

SW_list=dir('*SWIFT*'); % list of SWIFT directories to reprocess

for sn=1:length(SW_list);
    disp(['SWIFT ' num2str(sn) ' of ' num2str(length(SW_list))])
    %load SWIFT structure (name may change)
    name=SW_list(sn).name;
    cd(name)
    if fullprocess==true | isempty(dir([name '_reprocessed.mat'])),
        save temp
        concatSWIFT_offloadedSDcard, reprocess_SIG_raw, reprocess_SBG_raw, reprocess_ACS_raw
        clear all
        load temp
    end
    load([name '_reprocessed.mat'])    % change suffix depending on naming convention
    
    % set flags (determine the sensors onboard the SWIFT)
    
    % AQD
    if exist([pwd '/AQD'],'dir')==7;
        AQD_flag=1;
    else
        AQD_flag=0;
    end
    
    %AQH
    if exist([pwd '/AQH'],'dir')==7;
        AQH_flag=1;
    else
        AQH_flag=0;
    end
    
    %SIG
    if exist([pwd '/SIG'],'dir')==7;
        SIG_flag=1;
    else
        SIG_flag=0;
    end
    
    %ACS
    if exist([pwd '/COM-9'],'dir')==7  && ~isempty(dir([pwd '/COM-9/Raw/*20*/*ACS*'])) 
        numCTs=3;
    else
        numCTs=1;
    end
    
    %extract original time vector
    time_original=[SWIFT.time];
    
    
    for tn=1:length(time_original);
        
        %make new time vector
        time(:,tn)=time_original(tn): datenum(0,0,0,0,0,dt) : time_original(tn)+datenum(0,0,0,0,0,dt*(num-1));
        parentbursttime(:,tn)=repmat(time_original(tn),size(time(:,tn)));
        parentburstindex(:,tn)=repmat(tn,size(time(:,tn)));
    end
    
    time=time(:);
    parentbursttime(:);
    parentburstindex(:);
    %set parent burst properties
    
    
    %get quantities for interpolation, checking for alternate wave
    %properties
    if isfield(SWIFT,'sigwaveheight_alt')==1
        sigwaveheight_original=[SWIFT.sigwaveheight_alt];
        peakwaveperiod_original=[SWIFT.peakwaveperiod_alt];
    else
        sigwaveheight_original=[SWIFT.sigwaveheight];
        peakwaveperiod_original=[SWIFT.peakwaveperiod];
    end
    
    
    peakwavedirT_original=[SWIFT.peakwavedirT];
    
    sigwaveheight=interp1(time_original,sigwaveheight_original,time);
    peakwaveperiod=interp1(time_original,peakwaveperiod_original,time);
    peakwavedirT=interp1(time_original,peakwavedirT_original,time);
    
    %regroup IMU and CT data
%     salinity=NaN*ones(
    
    for kn=1:length(SWIFT)
        ACS_time_original=SWIFT(kn).rawACSTime;
        
        if ~isempty(ACS_time_original)
        
            ACS_freq = 1 ./ ( (ACS_time_original(2)-ACS_time_original(1)) * 24 * 3600);
            
        else
            
            ACS_freq=0.5;
           
        end
        
        
        %check which GPS time to use
        if ~isfield(SWIFT(kn),'rawtime')==1 || isempty(SWIFT(kn).rawtime)==1 || sum(isnan(SWIFT(kn).rawtime))==...
                length(SWIFT(kn).rawtime)
            GPS_time_original=SWIFT(kn).rawGPStime; 
        else   
            GPS_time_original=SWIFT(kn).rawtime; 
        end
        
        if ((GPS_time_original(2)-GPS_time_original(1))*24*3600)>0 & sum(isnan(GPS_time_original))<length(GPS_time_original)
            GPS_freq=1./((GPS_time_original(2)-GPS_time_original(1))*24*3600);
            
        elseif ((GPS_time_original(2)-GPS_time_original(1))*24*3600)==0 || sum(isnan(GPS_time_original))==...
                length(GPS_time_original)
            GPS_freq=2; %hard coded, found from SWIFT17_02May2017
        end
        
        % check to see if AHRS exists. Will have to do a nan check later.
        if isfield(SWIFT(kn),'rawAHRStime')==1
            AHRS_time_original=SWIFT(kn).rawAHRStime;
            
            if ~isempty(AHRS_time_original)
            
                AHRS_freq=1./((AHRS_time_original(2)-AHRS_time_original(1))*24*3600);
                
            else 
                
                AHRS_time_original=NaN;
                
            end
        else
            AHRS_time_original=NaN;
        end
        
        
        
        salinity_original=SWIFT(kn).rawSalinity;
        temperature_original=SWIFT(kn).rawTemperature;
        density_original=SWIFT(kn).rawDensity;
        
        rawLat_original=SWIFT(kn).rawLat;
        rawLon_original=SWIFT(kn).rawLon;
        
        if size(salinity_original,1)<4      % less than 1 more than the maximum number of CTs
            salinity_original=salinity_original.';
            density_original=density_original.';
            temperature_original=temperature_original.';
        end
        
        u_original=SWIFT(kn).u;
        v_original=SWIFT(kn).v;
        if isfield(SWIFT(kn),'x')==1
            x_original=SWIFT(kn).x;
            y_original=SWIFT(kn).y;
            z_original=SWIFT(kn).z;
        end
        
        
        % take out SIG data, if needed
        
        if AQH_flag==1
            
            if isfield(SWIFT(kn).uplooking,'rawVel')
                rawVelHR_original=SWIFT(kn).uplooking.rawVel;
                rawAQtime_original=SWIFT(kn).uplooking.rawAQtime;
                rawCorHR_original=SWIFT(kn).uplooking.Cor;
                z_AQH=SWIFT(kn).uplooking.z;
                pressure_original=SWIFT(kn).uplooking.pressure;
                pitch_original=SWIFT(kn).uplooking.pitch;
            end
            
        end
        
        if AQD_flag==1
            
            if isfield(SWIFT(kn).downlooking,'rawVelE')
                rawVelE_original=SWIFT(kn).downlooking.rawVelE;
                rawVelN_original=SWIFT(kn).downlooking.rawVelN;
                rawVelU_original=SWIFT(kn).downlooking.rawVelU;
                rawAQtime_original=SWIFT(kn).downlooking.rawAQtime;
%                 rawCor_original=SWIFT(kn).uplooking.Cor;
                z_AQD=SWIFT(kn).downlooking.z;
%                 pressure_original=SWIFT(kn).uplooking.pressure;
%                 pitch_original=SWIFT(kn).uplooking.pitch;
            end
            
        end
        
        if SIG_flag==1
            
            if isfield(SWIFT(kn).signature.profile,'east_raw');
            
                east_raw_original=SWIFT(kn).signature.profile.east_raw;
                north_raw_original=SWIFT(kn).signature.profile.north_raw;
                up_raw_original=SWIFT(kn).signature.profile.up_raw;
                SIGprof_time_original=SWIFT(kn).signature.profile.time_raw;
                depth_raw_original=SWIFT(kn).signature.profile.depth_raw;
                %depth_smooth_original=SWIFT(kn).signature.profile.depth_smooth;
                z_SIGprof_original=SWIFT(kn).signature.profile.z;
                rawAmp_original=mean(SWIFT(kn).signature.profile.rawAmp,3);
                gyro_raw_original=SWIFT(kn).signature.profile.gyro_raw;

                rawVelHR_original=SWIFT(kn).signature.HRprofile.rawVel;
                rawCorHR_original=SWIFT(kn).signature.HRprofile.rawCor;
                rawAmpHR_original=SWIFT(kn).signature.HRprofile.rawAmp;
                SIGhr_time_original=SWIFT(kn).signature.HRprofile.time_raw;
                z_SIGhr_original=SWIFT(kn).signature.HRprofile.z;
            
            end
            
        end
        
        
%         rawtime_original=SWIFT(kn).rawtime;
        
        % segment ACS & IMU by finding start _s and end _e indices
        
        for tn=1:num;
            
            if tn~=num
            
                [~,ACS_s]=min(abs(time((kn-1)*num+tn)-ACS_time_original));
                [~,ACS_e]=min(abs(time((kn-1)*num+tn+1)-ACS_time_original));
                
                [~,GPS_s]=min(abs(time((kn-1)*num+tn)-GPS_time_original));
                [~,GPS_e]=min(abs(time((kn-1)*num+tn+1)-GPS_time_original));
                
                if sum(isnan(AHRS_time_original))==0;
                    
                    [~,AHRS_s]=min(abs(time((kn-1)*num+tn)-AHRS_time_original));
                    [~,AHRS_e]=min(abs(time((kn-1)*num+tn+1)-AHRS_time_original));
                    
                end
                
            elseif tn==num
                
                t_eff=SWIFT(kn).time+datenum(0,0,0,0,0,num*dt);
                [~,ACS_s]=min(abs(time((kn-1)*num+tn)-ACS_time_original));
                [~,ACS_e]=min(abs(t_eff-ACS_time_original));
                
                [~,GPS_s]=min(abs(time((kn-1)*num+tn)-GPS_time_original));
                [~,GPS_e]=min(abs(t_eff-GPS_time_original));
                
                if sum(isnan(AHRS_time_original))==0;
                    
                    [~,AHRS_s]=min(abs(time((kn-1)*num+tn)-AHRS_time_original));
                    [~,AHRS_e]=min(abs(t_eff-AHRS_time_original));
                    
                end
                
            end
                
%             if tn~=num
%             
%             [~,ACS_e]=min(abs(time((kn-1)*num+tn)-ACS_time_original));
%             elseif tn==num
%                 
%             end
            ACS_e = ACS_e - 1;  %make it the last index before the new timestamp
            GPS_e = GPS_e - 1;
            
%             newburst_salinity=NaN*one(
            
            newburst_salinity=salinity_original(ACS_s:ACS_e,:);
            newburst_temperature=temperature_original(ACS_s:ACS_e,:);
            newburst_density=density_original(ACS_s:ACS_e,:);
            newburst_ACS_time=ACS_time_original(ACS_s:ACS_e);
            
            rawLat=rawLat_original(GPS_s:GPS_e);
            rawLon=rawLon_original(GPS_s:GPS_e);
            GPS_time=GPS_time_original(GPS_s:GPS_e);
            
            if ~isempty(x_original) & sum(isnan(AHRS_time_original))<1;
                
                x=x_original(AHRS_s:AHRS_e);
                y=y_original(AHRS_s:AHRS_e);
                z=z_original(AHRS_s:AHRS_e);
                u=u_original(GPS_s:GPS_e);
                v=v_original(GPS_s:GPS_e);
                
                AHRS_time=AHRS_time_original(AHRS_s:AHRS_e);
                
            elseif ~isempty(x_original) & sum(isnan(AHRS_time_original))>=1
                
                x=x_original(GPS_s:GPS_e);
                y=y_original(GPS_s:GPS_e);
                z=z_original(GPS_s:GPS_e);
                u=u_original(GPS_s:GPS_e);
                v=v_original(GPS_s:GPS_e);
                AHRS_time=NaN;
            elseif ~isempty(z_original);
                x=NaN;
                y=NaN;
                u=NaN;
                v=NaN;
                z=NaN;
                AHRS_time=NaN;
               
            else
                
                x=NaN;
                y=NaN;
                u=NaN;
                v=NaN;
                z=NaN;
                AHRS_time=NaN;
                
            end
            
            % QC CT data
            
            ind=find(newburst_salinity>maxsalinity | newburst_salinity<minsalinity);
            
            newburst_salinity(ind)=NaN;
            newburst_temperature(ind)=NaN;
            newburst_density(ind)=NaN;
            
            % if bad data more than 10%, consider SWIFT to be out of water
            dryflag((kn-1)*num+tn) = false; 
            if ( length(ind) ./ length(newburst_salinity) ) > percentdry
                dryflag((kn-1)*num+tn) = true;
            end
            
%             if ~isempty(newburst_salinity)
%                 salinity_raw((kn-1)*num+tn,:,:)=newburst_salinity;
%                 temperature_raw((kn-1)*num+tn,:,:)=newburst_temperature;
%                 density_raw((kn-1)*num+tn,:,:)=newburst_density;
%                 time_raw((kn-1)*num+tn,:)=newburst_time;
%             elseif isempty(newburst_salinity)==1 & kn~=1
%                 salinity_raw((kn-1)*num+tn,:,:)=NaN*ones(size(salinity_raw((kn-1)*num+tn-1,:,:)));
%                 temperature_raw((kn-1)*num+tn,:,:)=NaN*ones(size(temperature_raw((kn-1)*num+tn-1,:,:)));
%                 density_raw((kn-1)*num+tn,:,:)=NaN*ones(size(density_raw((kn-1)*num+tn-1,:,:)));
%                 time_raw((kn-1)*num+tn,:,:)=NaN*ones(size(time_raw((kn-1)*num+tn-1,:,:)));
%             end
          
            
            
            % Store in SWIFT_highres structure
            SWIFT_highres((kn-1)*num+tn).sigwaveheight=sigwaveheight((kn-1)*num+tn);
            SWIFT_highres((kn-1)*num+tn).peakwavedirT=peakwavedirT((kn-1)*num+tn);
            SWIFT_highres((kn-1)*num+tn).peakwaveperiod=peakwaveperiod((kn-1)*num+tn);
            SWIFT_highres((kn-1)*num+tn).salinity=nanmax(newburst_salinity);
            SWIFT_highres((kn-1)*num+tn).watertemp=nanmedian(newburst_temperature);
            SWIFT_highres((kn-1)*num+tn).density=nanmedian(newburst_density);
            SWIFT_highres((kn-1)*num+tn).lat=nanmedian(rawLat);
            SWIFT_highres((kn-1)*num+tn).lon=nanmedian(rawLon);
            if isempty(newburst_salinity)==0
                %SWIFT_highres((kn-1)*num+tn).rawSalinity=newburst_salinity;
                %SWIFT_highres((kn-1)*num+tn).rawTemperature=newburst_temperature;
                %SWIFT_highres((kn-1)*num+tn).rawDensity=newburst_density;
                %SWIFT_highres((kn-1)*num+tn).rawACSTime=newburst_ACS_time;
            elseif isempty(newburst_salinity)==1
                %SWIFT_highres((kn-1)*num+tn).rawSalinity=NaN*ones(1,numCTs);
                %SWIFT_highres((kn-1)*num+tn).rawTemperature=NaN*ones(1,numCTs);
                %SWIFT_highres((kn-1)*num+tn).rawDensity=NaN*ones(1,numCTs);
                %SWIFT_highres((kn-1)*num+tn).rawACSTime=NaN;
                SWIFT_highres((kn-1)*num+tn).salinity=NaN;
                SWIFT_highres((kn-1)*num+tn).watertemp=NaN;
                SWIFT_highres((kn-1)*num+tn).density=NaN;
            end
            %SWIFT_highres((kn-1)*num+tn).x=x;
            %SWIFT_highres((kn-1)*num+tn).y=y;
            %SWIFT_highres((kn-1)*num+tn).z=z;
            
            
            if isempty(GPS_time)==0
            
                %SWIFT_highres((kn-1)*num+tn).rawGPStime=GPS_time;
                %SWIFT_highres((kn-1)*num+tn).rawLat=rawLat;
                %SWIFT_highres((kn-1)*num+tn).rawLon=rawLon;
                SWIFT_highres((kn-1)*num+tn).driftveleast=nanmedian(u);
                SWIFT_highres((kn-1)*num+tn).driftvelnorth=nanmedian(v);
                SWIFT_highres((kn-1)*num+tn).z = nanmedian(z);
                
                SWIFT_highres((kn-1)*num+tn).driftspd=nanmedian(sqrt(u.^2+v.^2));
                SWIFT_highres((kn-1)*num+tn).driftdirT=90-atan2d(nanmedian(v),nanmedian(u));
                
            elseif isempty(GPS_time)==1
                
                %SWIFT_highres((kn-1)*num+tn).rawGPStime=NaN;
                %SWIFT_highres((kn-1)*num+tn).rawLat=NaN;
                %SWIFT_highres((kn-1)*num+tn).rawLon=NaN;
                SWIFT_highres((kn-1)*num+tn).z=NaN;
                SWIFT_highres((kn-1)*num+tn).driftveleast=NaN;
                SWIFT_highres((kn-1)*num+tn).driftvelnorth=NaN;
                SWIFT_highres((kn-1)*num+tn).driftspd=NaN;
                SWIFT_highres((kn-1)*num+tn).driftdirT=NaN;
                
            end
            
            %SWIFT_highres((kn-1)*num+tn).rawAHRStime=AHRS_time;
            SWIFT_highres((kn-1)*num+tn).time=time((kn-1)*num+tn);
            SWIFT_highres((kn-1)*num+tn).parentburstindex=parentburstindex(tn,kn);
            SWIFT_highres((kn-1)*num+tn).parentbursttime=parentbursttime(tn,kn);
            
             %% uplooking Aquadopp re/processing & storage
            if AQH_flag==1
                
                if isfield(SWIFT(kn).uplooking,'rawVel')==1
                    
                    if tn~=num
                        
                        [~,AQH_s]=min(abs(time((kn-1)*num+tn)-rawAQtime_original));
                        [~,AQH_e]=min(abs(time((kn-1)*num+tn+1)-rawAQtime_original));
                        
                    else
                    
                        t_eff=SWIFT(kn).time+datenum(0,0,0,0,0,num*dt);
                        [~,AQH_s]=min(abs(time((kn-1)*num+tn)-rawAQtime_original));
                        [~,AQH_e]=min(abs(t_eff-rawAQtime_original));
                        
                    end
                    
                    rawVel=rawVelHR_original(AQH_s:AQH_e,:);
                    Cor=rawCorHR_original(AQH_s:AQH_e,:);
                    rawAQtime=rawAQtime_original(AQH_s:AQH_e);
                    pressure=pressure_original(AQH_s:AQH_e);
                    pitch=pitch_original(AQH_s:AQH_e);
                    exclude=Cor<mincor;
                    rawVel(exclude)=NaN;
                    
                    bobbing = min([0.05 std(pressure)]); % m, usually less than 0.05
                    deltatheta = min([ 3.14/180*(5) std(3.14/180*(pitch)) ]);
                    thetabar = 3.14/180*(25);
                    deltar = 0.5 * z_AQH * deltatheta * thetabar ./ cos(thetabar)^2  + bobbing ./ cos(thetabar);
                    r = [0.157 0.202 0.246 0.290 0.334 0.378 0.422 0.466 0.510 0.554 0.598 0.642 0.687 0.731 0.775 0.819]; 
                    
                    [tke epsilon residual A Aerror N Nerror ] = dissipation(rawVel', r, length(rawVel), 1, deltar);
                    warning('off','last')
                    
                    SWIFT_highres((kn-1)*num+tn).uplooking.tkedissipationrate=epsilon;
                    SWIFT_highres((kn-1)*num+tn).uplooking.z=z_AQH;
                    SWIFT_highres((kn-1)*num+tn).uplooking.rawVel=rawVel;
                    SWIFT_highres((kn-1)*num+tn).uplooking.rawAQtime=rawAQtime;
                   
                else 
                    
                    SWIFT_highres((kn-1)*num+tn).uplooking.tkedissipationrate=NaN*ones(16,1);
                    SWIFT_highres((kn-1)*num+tn).uplooking.z=NaN*ones(1,16);
                    SWIFT_highres((kn-1)*num+tn).uplooking.rawVel=NaN*ones(241,16);
                    SWIFT_highres((kn-1)*num+tn).uplooking.rawAQtime=NaN*ones(241,1);
                    
                end
            else
                
                %SWIFT_highres((kn-1)*num+tn).uplooking.tkedissipationrate=NaN;
                %SWIFT_highres((kn-1)*num+tn).uplooking.z=NaN;
                %SWIFT_highres((kn-1)*num+tn).uplooking.rawVel=NaN;
                %SWIFT_highres((kn-1)*num+tn).uplooking.rawAQtime=NaN;
                
            end

            %% downlooking Aquadopp processing
            if AQD_flag==1
                
                if tn~=num
                        
                    [~,AQD_s]=min(abs(time((kn-1)*num+tn)-rawAQtime_original));
                    [~,AQD_e]=min(abs(time((kn-1)*num+tn+1)-rawAQtime_original));
                        
                else
                    
                    t_eff=SWIFT(kn).time+datenum(0,0,0,0,0,num*dt);
                    [~,AQD_s]=min(abs(time((kn-1)*num+tn)-rawAQtime_original));
                    [~,AQD_e]=min(abs(t_eff-rawAQtime_original));
                        
                end
                
                % Store AQD data in highres structure
                
                if isfield(SWIFT(kn).downlooking,'rawVelE')==1
                    
                    SWIFT_highres((kn-1)*num+tn).downlooking.rawVelE=rawVelE_original(AQD_s:AQD_e,:);
                    SWIFT_highres((kn-1)*num+tn).downlooking.rawVelN=rawVelN_original(AQD_s:AQD_e,:);
                    SWIFT_highres((kn-1)*num+tn).downlooking.rawVelU=rawVelU_original(AQD_s:AQD_e,:);
                    SWIFT_highres((kn-1)*num+tn).downlooking.east=nanmean(rawVelE_original(AQD_s:AQD_e,:),1);
                    SWIFT_highres((kn-1)*num+tn).downlooking.north=nanmean(rawVelN_original(AQD_s:AQD_e,:),1);
                    SWIFT_highres((kn-1)*num+tn).downlooking.vert=nanmean(rawVelU_original(AQD_s:AQD_e,:),1);
                    SWIFT_highres((kn-1)*num+tn).downlooking.z=z_AQD;
                    SWIFT_highres((kn-1)*num+tn).downlooking.rawAQtime=rawAQtime_original(AQD_s:AQD_e);
                
                else
                    
                    SWIFT_highres((kn-1)*num+tn).downlooking.rawVelE=NaN*ones(512,40);
                    SWIFT_highres((kn-1)*num+tn).downlooking.rawVelN=NaN*ones(512,40);
                    SWIFT_highres((kn-1)*num+tn).downlooking.rawVelU=NaN*ones(512,40);
                    SWIFT_highres((kn-1)*num+tn).downlooking.east=NaN*ones(40,1);
                    SWIFT_highres((kn-1)*num+tn).downlooking.north=NaN*ones(40,1);
                    SWIFT_highres((kn-1)*num+tn).downlooking.vert=NaN*ones(40,1);
                    SWIFT_highres((kn-1)*num+tn).downlooking.z=NaN*ones(1,40);
                    SWIFT_highres((kn-1)*num+tn).downlooking.rawAQtime=NaN*ones(512,1);
                    
                end
            else
                
                %SWIFT_highres((kn-1)*num+tn).downlooking.rawVelE=NaN;
                %SWIFT_highres((kn-1)*num+tn).downlooking.rawVelN=NaN;
                %SWIFT_highres((kn-1)*num+tn).downlooking.rawVelU=NaN;
                %SWIFT_highres((kn-1)*num+tn).downlooking.rawAQtime=NaN;
                %SWIFT_highres((kn-1)*num+tn).downlooking.east=NaN;
                %SWIFT_highres((kn-1)*num+tn).downlooking.north=NaN;
                %SWIFT_highres((kn-1)*num+tn).downlooking.up=NaN;
                %SWIFT_highres((kn-1)*num+tn).downlooking.z=NaN;
                
            end

            %% Signature re/processing
            if SIG_flag==1 && isfield(SWIFT(kn).signature.profile,'east_raw');  
                
                if tn~=num
                    
                    [~,SIGp_s]=min(abs(time((kn-1)*num+tn)-SIGprof_time_original));
                    [~,SIGp_e]=min(abs(time((kn-1)*num+tn+1)-SIGprof_time_original));
                    [~,SIGh_s]=min(abs(time((kn-1)*num+tn)-SIGhr_time_original));
                    [~,SIGh_e]=min(abs(time((kn-1)*num+tn+1)-SIGhr_time_original));
                    
                else
                    
                    t_eff=SWIFT(kn).time+datenum(0,0,0,0,0,num*dt);
                    [~,SIGp_s]=min(abs(time((kn-1)*num+tn)-SIGprof_time_original));
                    [~,SIGp_e]=min(abs(t_eff-SIGprof_time_original));
                    [~,SIGh_s]=min(abs(time((kn-1)*num+tn)-SIGhr_time_original));
                    [~,SIGh_e]=min(abs(t_eff-SIGhr_time_original));
                end
                
                east_raw=east_raw_original(SIGp_s:SIGp_e,:);
                north_raw=north_raw_original(SIGp_s:SIGp_e,:);
                up_raw=up_raw_original(SIGp_s:SIGp_e,:);
                amp_raw=rawAmp_original(SIGp_s:SIGp_e,:);
                timeprof_raw=SIGprof_time_original(SIGp_s:SIGp_e);
                depth_raw=depth_raw_original(SIGp_s:SIGp_e);
                gyro_raw=gyro_raw_original(SIGp_s:SIGp_e);
                z=z_SIGprof_original;
                dz = abs(median(diff(z)));
                %depth_smooth=depth_smooth_original(SIGp_s:SIGp_e);
                
                east=nanmedian(east_raw,1);
                north=nanmedian(north_raw,1);
                backscatter=nanmedian(amp_raw,1);
                wbar=nanmedian(up_raw,1);
                wvar=nanvar(up_raw,1);
                depth=nanmedian(depth_raw); 
                gyro=nanmedian(gyro_raw);
                
                % remove points below seabed
                east( z>(depth-dz) ) = NaN;
                north( z>(depth-dz) ) = NaN;
                wbar( z>(depth-dz) ) = NaN;
                wvar( z>(depth-dz) ) = NaN;
                
                
                
                rawVel=rawVelHR_original(SIGh_s:SIGh_e,:);
                cor=rawCorHR_original(SIGh_s:SIGh_e,:);
                backscatterHR=rawAmpHR_original(SIGh_s:SIGh_e,:);
                timeHR_raw=SIGhr_time_original(SIGh_s:SIGh_e);
               
                exclude=cor<mincor;
                rawVel(exclude)=NaN;
                
                [tke , epsilon , residual, A, Aerror, N, Nerror] = ...
                    dissipation_simple(rawVel', z_SIGhr_original, size(rawVel,1), 0, zeros(size(z_SIGhr_original)));
                warning('off','last')
                
                
                SWIFT_highres((kn-1)*num+tn).signature.HRprofile.tkedissipationrate=epsilon;
                SWIFT_highres((kn-1)*num+tn).signature.HRprofile.z=z_SIGhr_original;
                SWIFT_highres((kn-1)*num+tn).signature.HRprofile.wbar=nanmean(rawVel,1);
                SWIFT_highres((kn-1)*num+tn).signature.HRprofile.wvar=nanvar(rawVel,1);
                SWIFT_highres((kn-1)*num+tn).signature.HRprofile.backscatter = nanmedian(backscatterHR);
%                 SWIFT_highres((kn-1)*num+tn).HRprofile.rawVel=rawVel;
%                 SWIFT_highres((kn-1)*num+tn).HRprofile.cor=cor;
                %SWIFT_highres((kn-1)*num+tn).signature.HRprofile.time_raw=timeHR_raw;
                
                SWIFT_highres((kn-1)*num+tn).signature.profile.east=east;
                SWIFT_highres((kn-1)*num+tn).signature.profile.north=north;
                SWIFT_highres((kn-1)*num+tn).signature.profile.velreference = 'none';
                SWIFT_highres((kn-1)*num+tn).signature.profile.wbar=wbar;
                SWIFT_highres((kn-1)*num+tn).signature.profile.wvar=wvar;
                SWIFT_highres((kn-1)*num+tn).signature.profile.depth=depth;
                SWIFT_highres((kn-1)*num+tn).signature.profile.gyro=gyro;
                SWIFT_highres((kn-1)*num+tn).signature.profile.backscatter = backscatter;
                SWIFT_highres((kn-1)*num+tn).signature.profile.z = z;
                %SWIFT_highres((kn-1)*num+tn).signature.profile.time_raw=timeprof_raw;
                %SWIFT_highres((kn-1)*num+tn).signature.profile.east_raw=east_raw;
                %SWIFT_highres((kn-1)*num+tn).signature.profile.north_raw=north_raw;
                %SWIFT_highres((kn-1)*num+tn).signature.profile.up_raw=up_raw;
                %SWIFT_highres((kn-1)*num+tn).signature.profile.depth_raw=depth_raw;
                %SWIFT_highres((kn-1)*num+tn).signature.profile.depth_smooth=depth_smooth;
                
                
            else
                
                SWIFT_highres((kn-1)*num+tn).signature.HRprofile.tkedissipationrate=NaN;
                SWIFT_highres((kn-1)*num+tn).signature.HRprofile.z=NaN;
                SWIFT_highres((kn-1)*num+tn).signature.HRprofile.wbar=NaN;
                SWIFT_highres((kn-1)*num+tn).signature.HRprofile.wvar=NaN;
%                 SWIFT_highres((kn-1)*num+tn).HRprofile.tkedissipationrate_pp=NaN;
%                 SWIFT_highres((kn-1)*num+tn).HRprofile.rawVel=NaN;
%                 SWIFT_highres((kn-1)*num+tn).HRprofile.cor=NaN;
                SWIFT_highres((kn-1)*num+tn).signature.HRprofile.time_raw=NaN;
                SWIFT_highres((kn-1)*num+tn).signature.profile.east=NaN;
                SWIFT_highres((kn-1)*num+tn).signature.profile.north=NaN;
                SWIFT_highres((kn-1)*num+tn).signature.profile.z=NaN;
                SWIFT_highres((kn-1)*num+tn).signature.profile.wbar=NaN;
                SWIFT_highres((kn-1)*num+tn).signature.profile.wvar=NaN;
                %SWIFT_highres((kn-1)*num+tn).signature.profile.east_raw=NaN;
                %SWIFT_highres((kn-1)*num+tn).signature.profile.north_raw=NaN;
                %SWIFT_highres((kn-1)*num+tn).signature.profile.depth_raw=NaN;
                %SWIFT_highres((kn-1)*num+tn).signature.profile.altimeter_quality=NaN;
                %SWIFT_highres((kn-1)*num+tn).signature.profile.time_raw=NaN;
                %SWIFT_highres((kn-1)*num+tn).signature.profile.depth_smooth=NaN;
                %SWIFT_highres((kn-1)*num+tn).signature.profile.up_raw=NaN;
                
            end
            
        end
        
        
        
    end
    
    % remove newbursts out of water
    SWIFT_highres(dryflag) = [];

    %% apply velocity reference to signature data
    if applyvelreference, 
    for i=1:length(SWIFT_highres), 
        SWIFT_highres(i).signature.profile.east = SWIFT_highres(i).signature.profile.east + SWIFT_highres(i).driftveleast;
        SWIFT_highres(i).signature.profile.north = SWIFT_highres(i).signature.profile.north + SWIFT_highres(i).driftvelnorth;
        SWIFT_highres(i).signature.profile.velreference = 'GPS';
    end
    end
    
    %% plots
    % plot salinity
    figure(1), clf
    for i=1:length(SWIFT), 
        plot(SWIFT(i).rawACSTime,SWIFT(i).rawSalinity,'k.'), hold on, 
        plot(SWIFT(i).time,SWIFT(i).salinity,'kx','markersize',12,'linewidth',2), hold on, 
        datetick
    end
    for i=1:length(SWIFT_highres), 
        %plot(SWIFT_highres(i).rawACSTime,SWIFT_highres(i).rawSalinity,'r.'), hold on, 
        plot(SWIFT_highres(i).time,SWIFT_highres(i).salinity,'ro','markersize',12,'linewidth',2), hold on, 
        datetick
    end
    print('-dpng',[SW_list(sn).name '_highres_dt' num2str(dt) 's_salinity.png'])
    
     % plot drift spds
    figure(2), clf
    for i=1:length(SWIFT), 
        plot(SWIFT(i).rawtime,( SWIFT(i).u.^2 + SWIFT(i).v.^2 ).^.5,'k.'), hold on,
        plot(SWIFT(i).time,SWIFT(i).driftspd,'kx','markersize',12,'linewidth',2), hold on, 
        datetick
    end
    for i=1:length(SWIFT_highres), 
        plot(SWIFT_highres(i).time,SWIFT_highres(i).driftspd,'ro','markersize',12,'linewidth',2), hold on, 
        datetick
    end
    print('-dpng',[SW_list(sn).name '_highres_dt' num2str(dt) 's_driftspd.png'])
    
    % plot drift track
    figure(3), clf
    for i=1:length(SWIFT), 
        plot(SWIFT(i).rawLon,SWIFT(i).rawLat,'k.'), hold on,
        plot(SWIFT(i).lon,SWIFT(i).lat,'kx','markersize',12,'linewidth',2), hold on, 
    end
    for i=1:length(SWIFT_highres), 
        plot(SWIFT_highres(i).lon,SWIFT_highres(i).lat,'ro','markersize',12,'linewidth',2), hold on, 
    end
    print('-dpng',[SW_list(sn).name '_highres_dt' num2str(dt) 's_drifttrack.png'])
    
    % plot signature data
    figure(4), clf
    if isfield(SWIFT(1), 'signature'),
    for i=1:length(SWIFT), 
        %plot(SWIFT(i).signature.profile.east_raw,SWIFT(i).signature.profile.z,'k-'), hold on,
        plot(SWIFT(i).signature.profile.east,SWIFT(i).signature.profile.z,'kx','markersize',12,'linewidth',2), hold on, 
        %plot(SWIFT(i).signature.profile.north_raw,SWIFT(i).signature.profile.z,'c-'), hold on,
        plot(SWIFT(i).signature.profile.north,SWIFT(i).signature.profile.z,'k+','markersize',12,'linewidth',2), hold on, 
    end
    for i=1:length(SWIFT_highres), 
        plot(SWIFT_highres(i).signature.profile.east,SWIFT_highres(i).signature.profile.z,...
            'ro','markersize',12,'linewidth',2), hold on, 
        plot(SWIFT_highres(i).signature.profile.north,SWIFT_highres(i).signature.profile.z,...
            'rs','markersize',12,'linewidth',2), hold on, 
    end
    end
    set(gca,'YDir','reverse')
    print('-dpng',[SW_list(sn).name '_highres_dt' num2str(dt) 's_signatureprofiles.png'])
    

    %% save new highres results
    clear SWIFT
    SWIFT=SWIFT_highres;
    save([SW_list(sn).name '_highres_dt' num2str(dt) 's.mat'],'SWIFT')
    clearvars -except SW_list parentdir num dt fullprocess applyvelreference maxsalinity minsalinity mincor percentdry 
    cd ..
    
    
    
end