%% Attempt to convert data to a netcdf format

%same as convert2netcdf_all.m, except for level 2 data

%load 'level 1 merged file
%use level 2 wave data from SWIFT 16 and 17
%use level 2 dissipation rates from v4 SWIFTs (Signature 1000)
%backfill reprocessed met data into level 2 v4 SWIFTs

% steps
%1 rename 'merged' product variables (i.e. those corrected for offsets) to
%standard variables.
%2 run modified version of Jim's code 'SWIFT2NC' to convert to nc.

%% load data

load('/Users/suneiliyer/Dropbox/ATOMIC_Codes_Data/data/MetWGSWIFTl2','MetWGSWIFTl2');

load([atomic_datadir '/mat_files/ATOMIC_SWIFT_waves.mat']); %ustar/mss
ATOMIC_SWIFT_centroid=load([atomic_datadir '/mat_files/ATOMIC_SWIFT_centroidperiod.mat']); %Centroid period

MetWGSWIFT = MetWGSWIFTl2;

SWIFT16 = MetWGSWIFT.all.SWIFTtelemetry(1).SWIFT;
SWIFT17 = MetWGSWIFT.all.SWIFTtelemetry(2).SWIFT;
SWIFT22 = MetWGSWIFT.all.SWIFTtelemetry(3).SWIFT;
SWIFT23 = MetWGSWIFT.all.SWIFTtelemetry(4).SWIFT;
SWIFT24 = MetWGSWIFT.all.SWIFTtelemetry(5).SWIFT;
SWIFT25 = MetWGSWIFT.all.SWIFTtelemetry(6).SWIFT;


%% same as above for Wave Gliders

%step 1: interpolate to an hourly timestamp and create a SWIFT-compatible
%structure!

WG245 = MetWGSWIFT.all.WGtelemetry.Waveglider245; %i=7
WG247 = MetWGSWIFT.all.WGtelemetry.Waveglider247; %i=8


%% rename SWIFT variables to the ones that will automatically be read into the code

% rename 'corrected' fields to the original field name
%delete old uncorrected vars
for i=[1:1:6]
    
    if i==1
        SWIFT_c = SWIFT16;
    elseif i==2
        SWIFT_c = SWIFT17;
    elseif i==3
        SWIFT_c = SWIFT22;
    elseif i==4
        SWIFT_c = SWIFT23;
    elseif i==5
        SWIFT_c = SWIFT24;
    elseif i==6
        SWIFT_c = SWIFT25;
    end
        
    
    salinity=extractfield(SWIFT_c,'salinity_corrected');
    watertemp=extractfield(SWIFT_c,'watertemp_corrected');
    if i < 2.5 %for v3 SWIFTs with multiple CTD measurement depths
        for j=1:1:length(SWIFT_c)
            SWIFT_c(j).salinity = salinity((j*2)-1);
            SWIFT_c(j).watertemp = watertemp((j*2)-1);
            SWIFT_c(j).salinity_d2 = salinity((j*2)-0); %salinity and temperature at second depth
            SWIFT_c(j).watertemp_d2 = watertemp((j*2)-0);
        end
    else
        for j=1:1:length(SWIFT_c)
            SWIFT_c(j).salinity = salinity((j));
            SWIFT_c(j).watertemp = watertemp((j));
        end
    end

    
    %create a new structure with only a few fields
    clear SWIFT
    for jj=1:1:length(SWIFT_c)
    SWIFT(jj).time = SWIFT_c(jj).time;
    SWIFT(jj).lat = SWIFT_c(jj).lat;
    SWIFT(jj).lon = SWIFT_c(jj).lon;
    SWIFT(jj).watertemp = SWIFT_c(jj).watertemp;
    SWIFT(jj).salinity = SWIFT_c(jj).salinity;
    if i < 2.5
        SWIFT(jj).watertemp_d2 = SWIFT_c(jj).watertemp_d2;
        SWIFT(jj).salinity_d2 = SWIFT_c(jj).salinity_d2;
        
        %get rid of bad data (spikes with salinity < 34.9)
        if SWIFT(jj).salinity_d2 < 34.9
            SWIFT(jj).salinity_d2=NaN;
        end
    end
    
    %add other fields
    SWIFT(jj).peakwavedirT = SWIFT_c(jj).peakwavedirT;
    SWIFT(jj).peakwaveperiod = SWIFT_c(jj).peakwaveperiod;
    
    if i==1
        SWIFT(jj).centroidwaveperiod = ATOMIC_SWIFT_centroid.Tcentroid16(jj);
    elseif i==2
        SWIFT(jj).centroidwaveperiod = ATOMIC_SWIFT_centroid.Tcentroid17(jj);
    elseif i==3
        SWIFT(jj).centroidwaveperiod = ATOMIC_SWIFT_centroid.Tcentroid22(jj);
    elseif i==4
        SWIFT(jj).centroidwaveperiod = ATOMIC_SWIFT_centroid.Tcentroid23(jj);
    elseif i==5
        SWIFT(jj).centroidwaveperiod = ATOMIC_SWIFT_centroid.Tcentroid24(jj);
    elseif i==6
        SWIFT(jj).centroidwaveperiod = ATOMIC_SWIFT_centroid.Tcentroid25(jj);
    end
    SWIFT(jj).sigwaveheight = SWIFT_c(jj).sigwaveheight;
    SWIFT(jj).wavespectra = SWIFT_c(jj).wavespectra;
    
    %wave mean squared slope and friction velocity
    SWIFT(jj).mss = ATOMIC_SWIFT_waves(i).mss(jj);
    SWIFT(jj).ustar = ATOMIC_SWIFT_waves(i).ustar(jj);
    
    SWIFT(jj).driftdirT = SWIFT_c(jj).driftdirT;
    SWIFT(jj).driftspd = SWIFT_c(jj).driftspd;
%     SWIFT(jj).winddirR = SWIFT_c(jj).winddirR; %redact relative wind direction for now
%     SWIFT(jj).winddirRstddev = SWIFT_c(jj).winddirRstddev; %don't include stdev - no one will use that in the hackathon
    SWIFT(jj).windspd = SWIFT_c(jj).windspd_corrected; %corrected wind speed
%     SWIFT(jj).windspdstddev = SWIFT_c(jj).windspdstddev;

%calculate qsea
    SWIFT(jj).qsea = qsea_calc(SWIFT_c(jj).watertemp);

    if i < 9992.5 %if Airmar, could also use max filtered air temps
%         SWIFT(jj).airtemp = SWIFT_c(jj).airtemp_corrected_maxfilt_ptrm; %corrected air temp (also corrected for spikes)
%     else
        SWIFT(jj).airtemp = SWIFT_c(jj).airtemp_corrected; %corrected air temp
    end
%     SWIFT(jj).airtempstddev = SWIFT_c(jj).airtempstddev;
%     SWIFT(jj).airpres = SWIFT_c(jj).airpres;
%     SWIFT(jj).airpresstddev = SWIFT_c(jj).airpresstddev;
    if i > 2.5 %v4 SWIFTs only
        SWIFT(jj).relhumidity = SWIFT_c(jj).relhumidity_corrected; %corrected rel humidity
%         SWIFT(jj).relhumiditystddev = SWIFT_c(jj).relhumiditystddev;
        SWIFT(jj).signature = SWIFT_c(jj).signature;
%         SWIFT(jj).rainaccum = SWIFT_c(jj).rainaccum; %redact rain data for now
%         SWIFT(jj).rainint = SWIFT_c(jj).rainint;

%AIR PRESSURE - need to convert to Pa from mb - that is the CF convention
        SWIFT(jj).airpres = SWIFT_c(jj).airpres.*100; %redact airmar air pressure - so only include for v4s
%         SWIFT(jj).airpresstddev = SWIFT_c(jj).airpresstddev.*100;
        %eliminate bad data
        if SWIFT(jj).airpres < 1E5
            SWIFT(jj).airpres=NaN;
        end

        %calculate qair
        SWIFT(jj).qair = qair_p([SWIFT(jj).airtemp SWIFT(jj).relhumidity (SWIFT(jj).airpres/100)]);
    elseif i < 2.5 %v3 SWIFTs only
        SWIFT(jj).winddirT = SWIFT_c(jj).winddirT; %true wind direction
%         SWIFT(jj).winddirTstddev = SWIFT_c(jj).winddirTstddev;

%AIR PRESSURE - need to convert to Pa from atm - that is the CF convention
        SWIFT(jj).airpres = SWIFT_c(jj).airpres.*100000; %redact airmar air pressure - so only include for v4s
%         SWIFT(jj).airpresstddev = SWIFT_c(jj).airpresstddev.*100;
        %eliminate bad data
        if SWIFT(jj).airpres < 1E5
            SWIFT(jj).airpres=NaN;
        end
            
    end
    if i==1 %v3 SWIFTs only
        SWIFT(jj).downlooking = SWIFT_c(jj).downlooking;
    elseif i==2
        SWIFT(jj).uplooking = SWIFT_c(jj).uplooking;
    end
%     SWIFT(jj). = SWIFT_c(jj).;

    %remove fields
    %all
        SWIFT(jj).wavespectra = rmfield(SWIFT(jj).wavespectra , 'check');
    
    if i < 2.5 %v3 SWIFTs
        
    else %v4 SWIFTs
        %onboard dissipation rates
        SWIFT(jj).signature.HRprofile = rmfield(SWIFT(jj).signature.HRprofile , 'tkedissipationrate_onboard');
        
        SWIFT(jj).signature.HRprofile = rmfield(SWIFT(jj).signature.HRprofile , 'wbar');
        SWIFT(jj).signature.HRprofile = rmfield(SWIFT(jj).signature.HRprofile , 'wvar');
        
        SWIFT(jj).signature.profile = rmfield(SWIFT(jj).signature.profile , 'altimeter');
        SWIFT(jj).signature.profile = rmfield(SWIFT(jj).signature.profile , 'wbar');
        SWIFT(jj).signature.profile = rmfield(SWIFT(jj).signature.profile , 'wvar');
    end
    
    %Flag values for atmosphere and ocean
    %0=good data, 1=questionable data, 2=bad data
%     SWIFT(jj).flag_values_atmosphere= SWIFT_c(jj).flag_values_atmosphere;
%     SWIFT(jj).flag_values_ocean= SWIFT_c(jj).flag_values_ocean;
    %individual parameters
    SWIFT(jj).flag_values_airtemp= SWIFT_c(jj).flag_values_airtemp;
    SWIFT(jj).flag_values_windspd= SWIFT_c(jj).flag_values_windspd;
    SWIFT(jj).flag_values_watertemp= SWIFT_c(jj).flag_values_watertemp;
    SWIFT(jj).flag_values_salinity= SWIFT_c(jj).flag_values_salinity;
    if i > 2.5
        SWIFT(jj).flag_values_humidity= SWIFT_c(jj).flag_values_humidity;
    end
    
    %Replace NaNs with -999 so it would be easier for climate modeling
    %people to use
    fnm=fieldnames(SWIFT);
    for k=1:1:length(fnm)
        if class(SWIFT(jj).(fnm{k})) == 'double' %can't do this with structure arrays (ADCP)
        if isnan(SWIFT(jj).(fnm{k}))
            SWIFT(jj).(fnm{k}) = -999;
        end
        end
    end


    end

    
    
    
    
    
    
%convert structure files and save
if i==1
    filename = [ql_datadir '/nc/all/EUREC4A_ATOMIC_SWIFT' '16' '_All_v2.4.nc'];
    SWIFT2NC_ATOMIC_all_l2(SWIFT,filename,16);
    
    %save the Matlab file too
    save([ql_datadir '/mat/SWIFT16_All_v2.4.mat'],'SWIFT');
elseif i==2
    filename = [ql_datadir '/nc/all/EUREC4A_ATOMIC_SWIFT' '17' '_All_v2.4.nc'];
    SWIFT2NC_ATOMIC_all_l2(SWIFT,filename,17);
    
    %save the Matlab file too
    save([ql_datadir '/mat/SWIFT17_All_v2.4.mat'],'SWIFT');
elseif i==3
    filename = [ql_datadir '/nc/all/EUREC4A_ATOMIC_SWIFT' '22' '_All_v2.4.nc'];
    SWIFT2NC_ATOMIC_all_l2(SWIFT,filename,22);
    
    %save the Matlab file too
    save([ql_datadir '/mat/SWIFT22_All_v2.4.mat'],'SWIFT');
elseif i==4
    filename = [ql_datadir '/nc/all/EUREC4A_ATOMIC_SWIFT' '23' '_All_v2.4.nc'];
    SWIFT2NC_ATOMIC_all_l2(SWIFT,filename,23);
    
    %save the Matlab file too
    save([ql_datadir '/mat/SWIFT23_All_v2.4.mat'],'SWIFT');
elseif i==5
    filename = [ql_datadir '/nc/all/EUREC4A_ATOMIC_SWIFT' '24' '_All_v2.4.nc'];
    SWIFT2NC_ATOMIC_all_l2(SWIFT,filename,24);
    
    %save the Matlab file too
    save([ql_datadir '/mat/SWIFT24_All_v2.4.mat'],'SWIFT');
elseif i==6
    filename = [ql_datadir '/nc/all/EUREC4A_ATOMIC_SWIFT' '25' '_All_v2.4.nc'];
    SWIFT2NC_ATOMIC_all_l2(SWIFT,filename,25);

    %save the Matlab file too
    save([ql_datadir '/mat/SWIFT25_All_v2.4.mat'],'SWIFT');
end
   


end



%% read data

% [vblnames dimname dimlen vardims ncid]=read_nc(filename,1,0);% get the  variable names in the .nc file
% % specify the variables to load:
% loadvars={'time','lon','lat','watertemp','salinity'};
% % load them one by one
% for vi=1:length(loadvars)
%      eval(['clear ' loadvars{vi}])% clear just to be safe
%      ncload2(filename,loadvars{vi}); % load
% end

%try with MATLAB's built-in function...
% vardata = ncread('SWIFT25.nc','lat_lagrangian');


%% same as above for Wave Gliders

%step 1: interpolate to an hourly timestamp and create a SWIFT-compatible
%structure!

WG245 = WG245; %i=7
WG247 = WG247; %i=8

%use the timestamp of the AanderaaCT as a basis - this has a lower time
%resolution AND doesn't include data from when the platform was on deck!
i=7;
if i==7
    
    %start by finding non-NaN points in water temp - cut off 1st and last
    %b/c of bad data
    idx = find(~isnan(WG245.AanderraaCT.watertemp_corrected));
    
    
    %%%% NEED TO CHANGE THIS for i=7 and i=8!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    %If we want the start and end times to correspond to deployment and
    %recovery (7/22/2020)
    tWG_start = WG245.AanderraaCT.time(idx(2));
    tWG_end = WG245.AanderraaCT.time(idx(end-1));
    tWG = tWG_start:datenum(0,0,0,0,30,0):tWG_end; %time resolution we want
    %CTD timestep = 30 minutes
    %atmos timestep = 10 minutes
    
    %Data flags - find closest point to "tWG" indices
    for ixf=1:1:length(tWG)
        iflagtsWG(ixf)=findclosest(WG245.AanderraaCT.time,tWG(ixf));
        flagtsWG(ixf)=WG245.AanderraaCT.flag_values_watertemp(iflagtsWG(ixf));
        flagsWG(ixf)=WG245.AanderraaCT.flag_values_salinity(iflagtsWG(ixf));
        
        iflagtaWG(ixf)=findclosest(WG245.airmar.time,tWG(ixf));
        flagtaWG(ixf)=WG245.airmar.flag_values_airtemp(iflagtaWG(ixf));
        flagwsWG(ixf)=WG245.airmar.flag_values_windspd(iflagtaWG(ixf));
    end
    
    %determine unique points and interpolate to get data on the hourly
    %timestamp we want!
    [x, index] = unique(WG245.AanderraaCT.time);
    TwWG = interp1(x, WG245.AanderraaCT.watertemp_corrected(index), tWG);
    SWG = interp1(x, WG245.AanderraaCT.salinity_corrected(index), tWG);
    
    %define 8m water temperature and salinity (only have this for WG 245
    [x8, index8] = unique(WG245.GPCTD.time);
    Wt8=(WG245.GPCTD.watertemp(index8));
    S8=(WG245.GPCTD.salinity(index8));
    ix8=find(~isnan(Wt8));
    %don't interpolate NaNs;
    TwWG8 = interp1(x8(ix8), Wt8(ix8), tWG) + 0.40; %correction of 0.088 and 0.40
    SWG8 = interp1(x8(ix8), S8(ix8), tWG) +0.088;
    
    %interpolate lat and lon to the same timestamp
    [x, index] = unique(WG245.airmar.time);

    latWG = interp1(x,MetWGSWIFT.all.WGtelemetry.Waveglider245.airmar.lat(index), tWG);
    lonWG = interp1(x,MetWGSWIFT.all.WGtelemetry.Waveglider245.airmar.lon(index), tWG);

    %interpolate other airmar relevant variables to the same timestamp
%     TaWG = interp1(x,WG245.airmar.airtemp_corrected_maxfilt_ptrm(index), tWG); %air temp - offset and max filter corrected
    TaWG = interp1(x,WG245.airmar.airtemp_corrected(index), tWG); %air temp - offset and max filter corrected
    wsWG = interp1(x,WG245.airmar.windspd_corrected(index), tWG); %windspeed
    wdWG = interp1(x,WG245.airmar.winddirT(index), tWG); %wind direction
    PaWG = interp1(x,WG245.airmar.airpres(index), tWG); %air pres - bad
    
    %interpolate Vaisala to the same timestamp
    [x, index] = unique(WG245.MET4.time);
    
    TaVWG = interp1(x,WG245.MET4.airtemp_corrected(index), tWG); %air temp
    PaVWG = interp1(x,WG245.MET4.airpres(index), tWG) .* 1013; %air pres (convert to Pa to be consistent with other obs and CF)
    RHVWG = interp1(x,WG245.MET4.relhumidity_corrected(index), tWG); %air pres
    
    %interpolate Wave parameters to the same timestamp
    [x, index] = unique(WG245.waves.time);
    %get rid of NaNs
    index(isnan(x))=[];
    x(isnan(x))=[];
    
    swhWG = interp1(x,WG245.waves.sigwaveheight(index), tWG); %sig wave height
    avgpWG = interp1(x,WG245.waves.averageperiod(index), tWG); %avg wave period
    pkpWG = interp1(x,WG245.waves.peakwaveperiod(index), tWG); %peak wave period
    pkdWG = interp1(x,WG245.waves.peakwavedirT(index), tWG); %peak wave direction
    
    
elseif i==8

    %start by finding non-NaN points in water temp - cut off 1st and last
    %b/c of bad data
    idx = find(~isnan(WG247.AanderraaCT.watertemp_corrected));
    
    
    tWG_start = WG247.AanderraaCT.time(idx(2));
    tWG_end = WG247.AanderraaCT.time(idx(end-1));
    tWG = tWG_start:datenum(0,0,0,0,30,0):tWG_end; %time resolution we want
    %CTD timestep = 30 minutes
    %atmos timestep = 10 minutes
    
    %Data flags - find closest point to "tWG" indices
    for ixf=1:1:length(tWG)
        iflagtsWG(ixf)=findclosest(WG247.AanderraaCT.time,tWG(ixf));
        flagtsWG(ixf)=WG247.AanderraaCT.flag_values_watertemp(iflagtsWG(ixf));
        flagsWG(ixf)=WG247.AanderraaCT.flag_values_salinity(iflagtsWG(ixf));
        
        iflagtaWG(ixf)=findclosest(WG247.airmar.time,tWG(ixf));
        flagtaWG(ixf)=WG247.airmar.flag_values_airtemp(iflagtaWG(ixf));
        flagwsWG(ixf)=WG247.airmar.flag_values_windspd(iflagtaWG(ixf));
    end
    
    %determine unique points and interpolate to get data on the hourly
    %timestamp we want!
    [x, index] = unique(WG247.AanderraaCT.time);
    TwWG = interp1(x, WG247.AanderraaCT.watertemp_corrected(index), tWG);
    SWG = interp1(x, WG247.AanderraaCT.salinity_corrected(index), tWG);
    
    
    %interpolate lat and lon to the same timestamp
    [x, index] = unique(WG247.airmar.time);

    latWG = interp1(x,MetWGSWIFT.all.WGtelemetry.Waveglider247.airmar.lat(index), tWG);
    lonWG = interp1(x,MetWGSWIFT.all.WGtelemetry.Waveglider247.airmar.lon(index), tWG);

    %interpolate other airmar relevant variables to the same timestamp
    TaWG = interp1(x,WG247.airmar.airtemp_corrected_maxfilt_ptrm(index), tWG); %air temp - offset and max filter corrected
    TaWG = interp1(x,WG247.airmar.airtemp_corrected(index), tWG); %air temp - offset and max filter corrected
    wsWG = interp1(x,WG247.airmar.windspd_corrected(index), tWG); %windspeed
    wdWG = interp1(x,WG247.airmar.winddirT(index), tWG); %wind direction
    PaWG = interp1(x,WG247.airmar.airpres(index), tWG); %air pres - bad
    
    %interpolate Vaisala to the same timestamp
    [x, index] = unique(WG247.MET4.time);
    
    TaVWG = interp1(x,WG247.MET4.airtemp_corrected(index), tWG); %air temp
    PaVWG = interp1(x,WG247.MET4.airpres(index), tWG); %air pres
    RHVWG = interp1(x,WG247.MET4.relhumidity_corrected(index), tWG); %air pres
    
    %interpolate Wave parameters to the same timestamp
    [x, index] = unique(WG247.waves.time);
    %get rid of NaNs
    index(isnan(x))=[];
    x(isnan(x))=[];
    
    swhWG = interp1(x,WG247.waves.sigwaveheight(index), tWG); %sig wave height
    avgpWG = interp1(x,WG247.waves.averageperiod(index), tWG); %avg wave period
    pkpWG = interp1(x,WG247.waves.peakwaveperiod(index), tWG); %peak wave period
    pkdWG = interp1(x,WG247.waves.peakwavedirT(index), tWG); %peak wave direction

end

%create a new SWIFT-compatible structure with only a few fields
clear SWIFT;
for jj=1:1:length(tWG)
    SWIFT(jj).time = tWG(jj);
    SWIFT(jj).lat = latWG(jj);
    SWIFT(jj).lon = lonWG(jj);
    SWIFT(jj).watertemp = TwWG(jj);
    SWIFT(jj).salinity = SWG(jj);
    
    if i==7 %if we have 8 meter CTD obs (only WG245)
        SWIFT(jj).watertemp_d2 = TwWG8(jj);
        SWIFT(jj).salinity_d2 = SWG8(jj);
    end
    
%add other fields
    SWIFT(jj).peakwavedirT = pkdWG(jj);
    SWIFT(jj).peakwaveperiod = pkpWG(jj);
    SWIFT(jj).centroidwaveperiod = avgpWG(jj);
    SWIFT(jj).sigwaveheight = swhWG(jj);

    
    SWIFT(jj).winddirT = wdWG(jj); %true wind direction - Airmar
    
    SWIFT(jj).windspd = wsWG(jj); %corrected wind speed - Airmar
    
    SWIFT(jj).airtemp = TaWG(jj); %corrected air temp - Airmar

    %air press - convert to Pa for consistency with CF conventions
    SWIFT(jj).airpres = PaWG(jj).*100; %air pressure from Vaisala - we don't trust Airmar!!
    
    SWIFT(jj).relhumidity = RHVWG(jj); %corrected rel humidity - Vaisala
    
    %calculate q_sea and q_air
    SWIFT(jj).qair = qair_p([SWIFT(jj).airtemp SWIFT(jj).relhumidity (SWIFT(jj).airpres/100)]);

    SWIFT(jj).qsea = qsea_calc(SWIFT(jj).watertemp);
    
    %flags values
    SWIFT(jj).flag_values_airtemp=flagtaWG(jj);
    SWIFT(jj).flag_values_windspd=flagwsWG(jj);
    SWIFT(jj).flag_values_watertemp=flagtsWG(jj);
    SWIFT(jj).flag_values_salinity=flagsWG(jj);
    
    
    %Replace NaNs with -999 so it would be easier for climate modeling
    %people to use
    fnm=fieldnames(SWIFT);
    for k=1:1:length(fnm)
        if class(SWIFT(jj).(fnm{k})) == 'double' %can't do this with structure arrays (ADCP)
        if isnan(SWIFT(jj).(fnm{k}))
            SWIFT(jj).(fnm{k}) = -999;
        end
        end
    end


end


%convert structure files and save
if i==7
    filename = [ql_datadir '/nc/all/EUREC4A_ATOMIC_WG' '245' '_All_v2.4.nc'];
    SWIFT2NC_ATOMIC_all_l2(SWIFT,filename,245);
    
    %save the Matlab file too
    save([ql_datadir '/mat/WG245_All_v2.4.mat'],'SWIFT');
elseif i==8
    filename = [ql_datadir '/nc/all/EUREC4A_ATOMIC_WG' '247' '_All_v2.4.nc'];
    SWIFT2NC_ATOMIC_all_l2(SWIFT,filename,247);
    
    %save the Matlab file too
    save([ql_datadir '/mat/WG247_All_v2.4.mat'],'SWIFT');
end
    
   