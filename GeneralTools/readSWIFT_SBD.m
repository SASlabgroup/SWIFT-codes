function [SWIFT BatteryVoltage ] = readSWIFT_SBD( fname , plotflag );
% Matlab readin of SWIFT Iridum SBD (short burst data) messages
% which are binary files with onboard processed results
% see Sutron documentation for message format
% ** assumes all files for an hour have been stripped of Iridium header
%   and concatanated together... this is done automatically by the
%   swiftserver when requesting data via http, but concat is required if
%   pulling data packets directly from swift@apl email account (backup
%   protocol) or if working with processed files that have been offloaded
%   directly from the SWIFT (via serial)
%
%   inputs is the filename as a string with the full path
%    (or assume local directory) and a flag for plotting
%
%   outputs are processed SWIFT results in a structure
%
%   [SWIFT BatteryVoltage ] = readSWIFT_SBD( fname , plotflag );
%
%
% J. Thomson, 7/2013
%             4/2014, revised for v3.1 Sutron output
%             12/2014, revised for v3.2, includes SOG, COG, and Air press
%                       also no longer applies post-fix to wave direction
%             9/2015    revised for 3.3, which has data grouped by type and
%                       com port (instead of name)
%             6/2016    revised for 3.4, adds Vaisala 536 instrument
%                       and with option for relative wind from Airmar PB200
%             9/2016    stop reading if size of type is zero (happens for picture sometimes)
%             11/2016  adapted for v4.0 testing
%             1/2017  make universal read-in, v3 or v4
%             3/2017  fix z reference for downlooking Aquadopps (was upside down)
%             9/2017 fixed factor of 2 in post-calculation of ustar
%             10/2017   screen the directional wave moments from the SBG
%                       (no longer needed, but harmless, after 11/2017)
%             12/2107   added type 12 (oxygen optode) and type 13 (SeaOwl)
%             9/2018    switched to only filling fields where/when data is
%                       present ** which will require updating plotSWIFT
%                       using isfield(SWIFT,'xxxxx') to make sure there is
%                       something to plot ** 
%                       The only required fields will be time, lat, and lon
%
%             9/2018    accomodating a bug in onboard signature processing,
%                       which reads HR velocities as cm/s instead of m/s 
%                        and thereby scales dissipation rates by 10^(8/3)
%
% 
%   M. Smith  9/2018    added CTdepth and metheight fields
%                       added SWIFT.id field using sbd filename 
%

recip = true; % binary flag to change wave direction to FROM

SWIFT.time = [];
SWIFT.lat = [];
SWIFT.lon = [];

fid = fopen(fname); % open file for reading
BatteryVoltage = NaN; % placeholder

%% SWIFT id flag from file name
SWIFT.ID = fname(6:13);
%%
payloadtype = fread(fid,1,'uint8=>char');

if payloadtype < '6', % v3.3 (2015) and up (com # based)
    disp('Not Version v3.3 (2015) or above.  Use older read-in code.')
    return
end

%skip = fread(fid,1,'uint8')

%%
CTcounter = 0; % count the number of CT sensors in the file
picflag = false; % initialize picture binary flag

while 1
    
    disp('-----------------')
    type = fread(fid,1,'uint8');
    port = fread(fid,1,'uint8');
    size = fread(fid,1,'uint16');
    
    if type == 0 & size > 0, % uplooking high-resolution aquadopp (AQH)
        disp('reading AQH results')
        SWIFT.uplooking.tkedissipationrate = fread(fid,16,'float'); % turbulent dissipation rate in m^2/s^3
        res = 0.04; % cell size (m) from hdr file
        blanking = 0.10; % blanking distance (m) from hdr file
        depth = 0.8; % depth of transducer
        cells = length(SWIFT.uplooking.tkedissipationrate);
        z = blanking + res./2 + [0:(cells-1)]*res;
        SWIFT.uplooking.z = fliplr(z) - blanking;
        
    elseif type == 1 & size > 0, % downlooking aquadopp (AQD)
        disp('reading AQD results')
        SWIFT.downlooking.velocityprofile = fread(fid,40,'float')./1000; % mean horizontal velocity, converted from mm/s to m/s
        res = 0.5; % cell size (m) from hdr file
        blanking = 0.40; % blanking distance (m) from hdr file
        depth = 1.2; % depth of transducer
        cells = length(SWIFT.downlooking.velocityprofile);
        z = blanking + res./2 + [0:(cells-1)]*res;
        SWIFT.downlooking.z = z; %fliplr(z) - blanking;
        
    elseif type == 2 & size > 0, % PB200 weather station (Airmar) and backup GPS
        disp('reading Airmar results')
        SWIFT.winddirT = fread(fid,1,'float'); % mean wind direction (deg T)
        SWIFT.winddirTstddev =  fread(fid,1,'float'); % std dev of wind direction (deg)
        SWIFT.windspd = fread(fid,1,'float'); % mean wind speed (m/s)
        SWIFT.windspdstddev = fread(fid,1,'float');  % std dev of wind spd (m/s)
        PBlat = num2str(fread(fid,1,'float')); % latitude
        PBlon = num2str(fread(fid,1,'float'));  % longitude
        if ~isfield(SWIFT,'lat'), % if no IMU, use this one
            SWIFT.lat = PBlat;
            SWIFT.lon = PBlon;
        end
        if isfield(SWIFT,'lat')& SWIFT.lat == 0, % if IMU did not give position, use this one
            SWIFT.lat = PBlat;
            SWIFT.lon = PBlon;
        else
        end
        PByear = num2str(fread(fid,1,'uint32')); % year
        PBMonth = num2str(fread(fid,1,'uint32')); % month
        PBDay = num2str(fread(fid,1,'uint32'));  % day
        PBhhmmss = num2str(fread(fid,1,'uint32')); % time of day (UTC)
        dec = find( PBhhmmss == '.');
        if dec == 7, hour = str2num(PBhhmmss(1:2));,
        elseif dec == 6, hour = str2num(PBhhmmss(1));, mm = str2num(PBhhmmss(2:3));,
        elseif dec <=5, hour = 0;
        elseif isempty(dec) & length(PBhhmmss)==6, hour = str2num(PBhhmmss(1:2));, mm = str2num(PBhhmmss(3:4));,
        elseif isempty(dec) & length(PBhhmmss)==5, hour = str2num(PBhhmmss(1));, mm = str2num(PBhhmmss(2:3));,
        elseif isempty(dec) & length(PBhhmmss)==4, hour = 0;, mm = str2num(PBhhmmss(1:2));,
        elseif isempty(dec) & length(PBhhmmss)==3, hour = 0;, mm = str2num(PBhhmmss(1));,
        else hour = 0; mm = 0;
        end
        SWIFT.time = datenum( str2num(PByear), str2num(PBMonth), str2num(PBDay), hour, mm, 0);
        SWIFT.date = [PBDay PBMonth PByear];
        SWIFT.airtemp = fread(fid,1,'float');
        SWIFT.airtempstddev = fread(fid,1,'float');
        SWIFT.airpres = fread(fid,1,'float');
        SWIFT.airpresstddev = fread(fid,1,'float');
        SWIFT.driftdirT = fread(fid,1,'float');
        SWIFT.driftdirTstddev = fread(fid,1,'float');
        SWIFT.driftspd = fread(fid,1,'float');
        SWIFT.driftspdstddev = fread(fid,1,'float');
        if PBlat == 0, % if no GPS for AirMar PB200, winddir is relative, not true
            SWIFT.winddirR = SWIFT.winddirT;
            SWIFT.winddirT = NaN;
        else
            SWIFT.winddirR = NaN;
            SWIFT.winddirRstddev = NaN;
        end
        SWIFT.metheight = 0.84; % height of measurement, meters
        
    elseif type == 3 & size > 0, % IMU
        disp('reading Microstrain IMU results')
        SWIFT.sigwaveheight = fread(fid,1,'float'); % sig wave height
        SWIFT.peakwaveperiod = fread(fid,1,'float'); % dominant period
        SWIFT.peakwavedirT = fread(fid,1,'float'); % dominant wave direction
        SWIFT.wavespectra.energy = fread(fid,42,'float'); % spectral energy density of sea surface elevation
        SWIFT.wavespectra.freq = fread(fid,42,'float'); % frequency
        SWIFT.wavespectra.a1 = fread(fid,42,'float'); % spectral moment
        SWIFT.wavespectra.b1 = fread(fid,42,'float'); % spectral moment
        SWIFT.wavespectra.a2 = fread(fid,42,'float'); % spectral moment
        SWIFT.wavespectra.b2 = fread(fid,42,'float'); % spectral moment
        SWIFT.lat = fread(fid,1,'float'); % Latitude
        SWIFT.lon = fread(fid,1,'float'); % Longitude
        if size > 1200 & size < 10000,
            SWIFT.wavehistogram.vertacc = fread(fid,32,'float'); % vertical accelerations
            SWIFT.wavehistogram.vertaccbins = fread(fid,32,'float'); % bins centers of vertical accelerations
            SWIFT.wavehistogram.horacc = fread(fid,32,'float'); % horizontal accelerations
            SWIFT.wavehistogram.horaccbins = fread(fid,32,'float'); % bins centers of horizontal accelerations
            SWIFT.wavehistogram.horspd = fread(fid,32,'float'); % horizontal speeds
            SWIFT.wavehistogram.horspdbins = fread(fid,32,'float'); % bin centers of horizontal speeds
        else
        end
        SWIFTversion = 3;
        
    elseif type == 4 & size > 0, % Aanderra conductivity-temperature cells
        disp('reading CT results')
        ConductivityMean(CTcounter + 1) = fread(fid,1,'float'); %
        SWIFT.watertemp(CTcounter + 1) = fread(fid,1,'float'); %
        SWIFT.salinity(CTcounter + 1) = fread(fid,1,'float'); %
        CTcounter = CTcounter + 1;
        
        if CTcounter == 1 %add field for CT depths (temp and sal), meters
            SWIFT.CTdepth(1) = .18;
        elseif CTcounter == 2
            SWIFT.CTdepth(2) = .66;
        elseif CTcounter == 3
            SWIFT.CTdepth(3) = 1.22;
        end
        
        
    elseif type == 5 & size > 0,  % Ecopuck fluorometer
        disp('reading ECOpuck fluorometer results')
        SWIFT.puck = fread(fid,3,'float'); %
        
        
    elseif type == 6 & size > 0, % system voltage
        disp('reading battery voltage')
        BatteryVoltage = fread(fid,1,'float')   % voltage
        
        
    elseif type == 7 & size > 0, % picture
        picflag = true;
        disp('reading picture')
        Pic = fread(fid,size);
        picfid = fopen([fname '.jpg'],'wb');
        count = fwrite(picfid,Pic);
        image = imread([fname '.jpg']);
        red = rot90( squeeze(image(:,:,1)), 1);
        green = rot90( squeeze(image(:,:,2)), 1);
        blue = rot90( squeeze(image(:,:,3)), 1);
        rotatedimage(:,:,1) = red;
        rotatedimage(:,:,2) = green;
        rotatedimage(:,:,3) = blue;
        imwrite(rotatedimage, [fname '.jpg'],'JPEG')
        
        
    elseif type == 8 & size > 0, % Vaisala 536 met station
        disp('reading Vaisala results')
        SWIFT.winddirR = fread(fid,1,'float'); % mean wind direction (deg T)
        SWIFT.winddirRstddev =  fread(fid,1,'float'); % std dev of wind direction (deg)
        SWIFT.windspd = fread(fid,1,'float'); % mean wind speed (m/s)
        SWIFT.windspdstddev = fread(fid,1,'float');  % std dev of wind spd (m/s)
        SWIFT.airtemp = fread(fid,1,'float'); % deg C
        SWIFT.airtempstddev = fread(fid,1,'float'); % deg C
        SWIFT.relhumidity = fread(fid,1,'float'); % percent
        SWIFT.relhumiditystddev = fread(fid,1,'float'); % percent
        SWIFT.airpres = fread(fid,1,'float'); % millibars
        SWIFT.airpresstddev = fread(fid,1,'float'); % millibars
        SWIFT.rainaccum = fread(fid,1,'float'); % millimeters
        SWIFT.rainint = fread(fid,1,'float'); % millimeters_per_hour
        SWIFT.metheight = 0.84; % height of measurement, meters

    elseif type == 9 & size > 0, % Nortek Signature
        disp('reading Nortek Signature results, applying cm/s correction')
        cmcorrection = 10^(8/3);
        ncells = fread(fid,1,'uint16');
        % HR profile (center beam)
        SWIFT.signature.HRprofile.tkedissipationrate = fread(fid,ncells,'float') * cmcorrection; % turbulent dissipation rate in m^2/s^3
        res = 0.04; % cell size (m) from config file
        blanking = 0.10; % blanking distance (m) from config file
        depth = 0.15; % depth of transducer
        cells = length(SWIFT.signature.HRprofile.tkedissipationrate);
        SWIFT.signature.HRprofile.z = blanking + res./2 + [0:(cells-1)]*res;
        % broadband profile (slant beams)
        nAvgcells = fread(fid,1,'uint16');
        SWIFT.signature.profile.east = fread(fid,nAvgcells,'float'); % east velocity component (m/s)
        SWIFT.signature.profile.north = fread(fid,nAvgcells,'float'); % east velocity component (m/s)
        res = 0.5; % cell size (m) from config file
        blanking = 0.10; % blanking distance (m) from config file
        depth = 0.15; % depth of transducer
        cells = length(SWIFT.signature.profile.east);
        SWIFT.signature.profile.z = blanking + res./2 + [0:(cells-1)]*res;
        if isempty(SWIFT.signature.HRprofile.tkedissipationrate),
            SWIFT = rmfield( SWIFT, 'signature' );
            disp('Signature results are empty!'),
        else 
        end
        
    elseif type == 10 & size > 0, % SBG Ellipse (same as IMU in v3, but with check factor and no histograms)
        disp('reading SBG IMU results'),
        SWIFT.sigwaveheight = fread(fid,1,'float'); % sig wave height
        SWIFT.peakwaveperiod = fread(fid,1,'float'); % dominant period
        SWIFT.peakwavedirT = fread(fid,1,'float'); % dominant wave direction
        SWIFT.wavespectra.energy = fread(fid,42,'float'); % spectral energy density of sea surface elevation
        SWIFT.wavespectra.freq = fread(fid,42,'float'); % frequency
        SWIFT.wavespectra.a1 = fread(fid,42,'float'); % spectral moment
        SWIFT.wavespectra.b1 = fread(fid,42,'float'); % spectral moment
        SWIFT.wavespectra.a2 = fread(fid,42,'float'); % spectral moment
        SWIFT.wavespectra.b2 = fread(fid,42,'float'); % spectral moment
        SWIFT.wavespectra.check = fread(fid,42,'float'); % spectral check factor (should be unity)
        SWIFT.lat = fread(fid,1,'float'); % Latitude
        SWIFT.lon = fread(fid,1,'float'); % Longitude
        if size > 1200,
            SWIFT.wavehistogram.vertacc = fread(fid,32,'float'); % vertical accelerations
            SWIFT.wavehistogram.vertaccbins = fread(fid,32,'float'); % bins centers of vertical accelerations
            SWIFT.wavehistogram.horacc = fread(fid,32,'float'); % horizontal accelerations
            SWIFT.wavehistogram.horaccbins = fread(fid,32,'float'); % bins centers of horizontal accelerations
            SWIFT.wavehistogram.horspd = fread(fid,32,'float'); % horizontal speeds
            SWIFT.wavehistogram.horspdbins = fread(fid,32,'float'); % bin centers of horizontal speeds
        else
        end
        SWIFTversion = 4;
        
    elseif type == 11 & size > 0, % RM Young 8100 Sonic Anemometer
        disp('reading Sonic Anemometer results')
        SWIFT.windustar = fread(fid,1,'float'); % wind friction velocity
        SWIFT.windepsilon = fread(fid,1,'float'); % air-side tke dissipation rate
        SWIFT.windmeanu = fread(fid,1,'float'); % component mean
        SWIFT.windmeanv = fread(fid,1,'float'); % component mean
        SWIFT.windspd = sqrt( SWIFT.windmeanu.^2 + SWIFT.windmeanv.^2 ); % relative wind speed
        SWIFT.windmeanw = fread(fid,1,'float'); % component mean
        SWIFT.airtemp = fread(fid,1,'float'); % airtemp
        SWIFT.windanisotropy = fread(fid,1,'float'); % inertial sub-range ratio
        SWIFT.windustarquality = fread(fid,1,'float'); % quality of inertial spectral fit
        SWIFT.windspectra.freq = fread(fid,116,'float'); % frequency
        SWIFT.windspectra.energy = fread(fid,116,'float'); % spectral energy density of surface winds
        SWIFT.winddirR = rad2deg(atan2(SWIFT.windmeanv, SWIFT.windmeanu) ); % mean wind direction (deg relative)        
        SWIFT.metheight = 0.71; % height of measurement, meters
        
    elseif type == 12 & size > 0, % Oxygen optode
        disp('reading Oxygen optode results')
        SWIFT.O2conc = fread(fid,1,'float');
        
    elseif type == 13 & size > 0, % SeaOwl
        disp('reading SeaOWl results')
        SWIFT.FDOM = fread(fid,1,'float');
              
    else
        
    end  
    
    if isempty(type),% & size == 0,
        %disp('----------')
        disp('all done (nothing else in this file)')
        break,
    end
    
end
fclose(fid);

%% recalc ustar from wind spectra and change indicator for no windstress from 9999 to NaN

if isfield(SWIFT,'windustar'),
    if SWIFT.windustar == 1,  % fix 2017 bug (no longer applies, but harmless to retain in case of re-reading old sbd files)
        z = 0.9; kappa = 0.4;
        SWIFT.windustar = ( kappa * SWIFT.windepsilon * z).^(1/3);
    elseif SWIFT.windustar == 9999
        SWIFT.windustar = NaN;
        SWIFT.windepsilon = NaN;
    else
    end
else
end

if isfield(SWIFT,'windspectra'),
    fmin = 1.5; % Hz
    fmax = 3; % Hz
    K = 0.55 ; % Kolmogorov const, factor by 4/3 for vertical or cross-flow component
    kv = 0.4 ; % von Karman const
    z = 0.95; % meters above sea level, 0.77 for Gill on Waveglider, 0.95 for RM Young on SWIFT 
    inertialrange = find( SWIFT.windspectra.freq > fmin & SWIFT.windspectra.freq < fmax);
    inertiallevel = nanmean( SWIFT.windspectra.energy(inertialrange) .* (SWIFT.windspectra.freq(inertialrange)).^(5/3) ) ;
    epsilon =  ( inertiallevel ./ ( ( SWIFT.windspd ./ (2*pi) ).^(2/3)  .* K ) ).^(3/2);
    SWIFT.windustar = (kv * epsilon * z ).^(1/3) ./ 2;  % assumes neutral 
else
end

%% fix CTdepth field if 1 or 2 values
if isfield(SWIFT,'CTdepth')
    if length(SWIFT.CTdepth) == 1
        if SWIFTversion == 3 %v3, uses IMU waves
            SWIFT.CTdepth = .66;
        elseif SWIFTversion == 4 %v4, uses SBG waves
            SWIFT.CTdepth = .18;
        else 
            SWIFT.CTdepth = nan;
        end
    elseif length(SWIFT.CTdepth) == 2 
        SWIFT.CTdepth = nan(2,1);
    end
end

%% quality control onboard processing of SBG IMU wave directional momements
% which are indicated by momemnts larger than +/- 1 (improper normalization)
% this has been fixed in Oct 2017 version of onboard processing, but it's
% harmless to keep this keep screening in place 
% (in case of rereading pre-2017 sbd files)
if isfield(SWIFT,'wavespectra'),
    if any(abs(SWIFT.wavespectra.b1)>1) | any(abs(SWIFT.wavespectra.a1)>1),
        SWIFT.wavespectra.a1(:) = NaN; %
        SWIFT.wavespectra.b1(:) = NaN; %
        SWIFT.wavespectra.a2(:) = NaN; %
        SWIFT.wavespectra.b2(:) = NaN; %
        SWIFT.peakwavedirT = NaN;
    else
    end
else
end

%% change indicator for no waves

% use NaN instead of 9999 for no wave results
if isfield(SWIFT,'sigwaveheight'),
    if SWIFT.sigwaveheight == 9999,
        SWIFT.sigwaveheight = NaN;
        SWIFT.peakwaveperiod = NaN;
        SWIFT.peakwavedirT = NaN;
    elseif SWIFT.peakwavedirT == 9999,  % sometimes only the directional estimate fails
        SWIFT.peakwavedirT = NaN;
    end
else
    SWIFT.sigwaveheight = NaN;
    SWIFT.peakwaveperiod = NaN;
    SWIFT.peakwavedirT = NaN;
end



%% fill in time if none read (time is a required field)

% if no time
if ~isfield(SWIFT,'time'),
    SWIFT.time = NaN;
else
end


%% take reciprocal of wave directions

if recip,
    dirto = SWIFT.peakwavedirT;
    if dirto >=180,
        SWIFT.peakwavedirT = dirto - 180;
    elseif dirto <180,
        SWIFT.peakwavedirT = dirto + 180;
    else
    end
end


%% display results if plotflag is true


if plotflag == true,
    
    figure(1), clf, figure(2), clf
    
    if isfield(SWIFT, 'signature'),
        
        figure(1),
        plot(SWIFT.signature.HRprofile.tkedissipationrate,SWIFT.signature.HRprofile.z,'linewidth',2)
        set(gca,'YDir','reverse')
        xlabel('\epsilon [m^2/s^3]'),     ylabel('z [m]')
        title(fname,'interpreter','none')
        print('-dpng',[fname '_epsilon.png'])
        
        figure(2),
        plot(SWIFT.signature.profile.east,SWIFT.signature.profile.z,SWIFT.signature.profile.north,SWIFT.signature.profile.z,'linewidth',2),
        set(gca,'YDir','reverse')
        xlabel('Signature profile [m/s]'),     ylabel('z [m]')
        legend('east','north')
        title(fname,'interpreter','none')
        print('-dpng',[fname '_velocityprofile.png'])
        
    elseif isfield(SWIFT,'uplooking'),
        
        figure(1),
        plot(SWIFT.uplooking.tkedissipationrate,SWIFT.uplooking.z,'linewidth',2)
        set(gca,'YDir','reverse')
        xlabel('\epsilon [m^2/s^3]'),     ylabel('z [m]')
        title([fname ', DE/dt = ' num2str(nansum(SWIFT.uplooking.tkedissipationrate*res*1030),3) ' W/m^2'],'interpreter','none')
        print('-dpng',[fname '_epsilon.png'])
        
    elseif  isfield(SWIFT,'downlooking'),
        
        figure(2), clf
        plot(SWIFT.downlooking.velocityprofile,SWIFT.downlooking.z,'linewidth',2),
        set(gca,'YDir','reverse')
        xlabel('u [m/s]'),     ylabel('z [m]')
        title(fname,'interpreter','none')
        print('-dpng',[fname '_velocityprofile.png'])
        
    end
    
    if isfield(SWIFT,'wavespectra'),
        figure(3), clf
        loglog(SWIFT.wavespectra.freq,SWIFT.wavespectra.energy,'linewidth',2), hold on,
        set(gca,'fontweight','demi','fontsize',12)
        xlabel('f [Hz]')
        ylabel('E [m^2/Hz]')
        title([fname], 'interpreter','none')
        legend(['H_s = ' num2str(SWIFT.sigwaveheight,2) ' m, T_p = ' num2str(SWIFT.peakwaveperiod,2) ' s' ])
        print('-dpng',[fname '_wavespectra.png'])
    else
    end
    
    figure(4), clf
    
    if isfield(SWIFT,'windspectra'),
        loglog(SWIFT.windspectra.freq,SWIFT.windspectra.energy,'linewidth',2), hold on,
        set(gca,'fontweight','demi','fontsize',12)
        xlabel('f [Hz]')
        ylabel('E [m^2/Hz]')
        title([fname],'interpreter','none')
        legend(['U_{10} = ' num2str(1.2*SWIFT.windspd,2) ' m/s, u_* = ' num2str(SWIFT.windustar,2) ' m/s' ])
        print('-dpng',[fname '_windspectra.png'])
    else
    end
    
    figure(5), clf,
    if picflag,  % binary flag for picture
        imagesc(rotatedimage)
        print('-dpng',[fname '_img.png'])
        
    else
    end
    
    
else
    
end

%% order and save results

SWIFT = orderfields(SWIFT);

save([ fname '.mat'])

