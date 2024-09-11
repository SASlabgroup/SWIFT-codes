
function swift = catSWIFT(SWIFT)
% Returns concatenated swift data in structure format

%Time, lat, lon, battery
swift.time = [SWIFT.time];
nt = length(swift.time);
swift.lon = 360 + [SWIFT.lon];
swift.lat = [SWIFT.lat];
swift.driftspd = [SWIFT.driftspd];
if isfield(SWIFT,'battery')
swift.battery = [SWIFT.battery];
end

% Air & sea temperature & pressure & salinity
if isfield(SWIFT,'watertemp')
    for it = 1:nt
        swift.tsea(it) = max(SWIFT(it).watertemp);
    end
else
    swift.tsea = NaN(1,nt);
end
if isfield(SWIFT,'airtemp')
swift.tair = [SWIFT.airtemp];
else
    swift.tair = NaN(1,nt);
end
if isfield(SWIFT,'salinity')
    swift.sal = [SWIFT.salinity];
else
    swift.sal = NaN(1,nt);
end
if isfield(SWIFT,'airpres')
    swift.press = [SWIFT.airpres];
else
    swift.press = NaN(1,nt);
end

% Rain
if isfield(SWIFT,'rainaccum')
    swift.rain = [SWIFT.rainaccum];
else
    swift.rain = NaN(1,nt);
end

% Humidity
if isfield(SWIFT,'relhumidity')
    swift.humid = [SWIFT.relhumidity];
else
    swift.humid = NaN(1,nt);
end

% Radiometer
if isfield(SWIFT,'radiometertemp1mean')% This is the brightness (target) temperature
    nrad = length(SWIFT(1).radiometertemp1mean);
    swift.radtemp1 = reshape([SWIFT.radiometertemp1mean],nrad,length(SWIFT));
    if size(swift.radtemp1,2)~= nt
        swift.radtemp1 = swift.radtemp1';
    end
end
if isfield(SWIFT,'radiometerrad1')% This is derived from brightness temp using stefan boltzman
    nrad = length(SWIFT(1).radiometerrad1);
    swift.rad1 = reshape([SWIFT.radiometerrad1],nrad,length(SWIFT));
    if size(swift.rad1,2)~= nt
        swift.rad1 = swift.rad1';
    end
end
if isfield(SWIFT,'radiometertemp2mean')% This is the jacket temperature
    nrad = length(SWIFT(1).radiometertemp2mean);
    swift.radtemp2 = reshape([SWIFT.radiometertemp2mean],nrad,length(SWIFT));
    if size(swift.radtemp2,2)~= nt
        swift.radtemp2 = swift.radtemp2';
    end
end
if isfield(SWIFT,'radiometerrad1')
    nrad = length(SWIFT(1).radiometerrad2);% This is derived from jacket temp using stefan boltzman
    swift.rad2 = reshape([SWIFT.radiometerrad2],nrad,length(SWIFT));
    if size(swift.rad2,2)~= nt
        swift.rad2 = swift.rad2';
    end
end

% Drift velocity
dx = NaN(1,nt);
dy = NaN(1,nt);
dt = NaN(1,nt);
dx(1:end-1) = diff(swift.lon).*111.12*10^3; %m
dx = dx.*cosd(swift.lat);
dy(1:end-1) = diff(swift.lat).*111.12*10^3; %m
dt(1:end-1) = diff(swift.time*24*60*60); %s
driftu = dx./dt;
driftv = dy./dt;
driftu(abs(driftu)>0.5) = NaN;
driftv(abs(driftv)>0.5) = NaN;
swift.driftu = driftu;
swift.driftv = driftv;

% Relative Velocity
if isfield(SWIFT,'signature') && isstruct(SWIFT(1).signature.profile)
    swift.depth = SWIFT(end).signature.profile.z';
    nz = length(swift.depth);
    swift.relu = NaN(nz,nt);
    swift.relv = NaN(nz,nt);
    swift.relw = NaN(nz,nt);
    swift.reluerr = NaN(nz,nt);
    swift.relverr = NaN(nz,nt);
    swift.relwerr = NaN(nz,nt);
    for it = 1:nt
        if isfield(SWIFT(it).signature.profile,'east') && ~isempty(SWIFT(it).signature.profile.east)
            swift.relu(:,it) = SWIFT(it).signature.profile.east;
            swift.relv(:,it) = SWIFT(it).signature.profile.north;
            if isfield(SWIFT(it).signature.profile,'w')
            swift.relw(:,it) = SWIFT(it).signature.profile.w;
            end
        elseif isfield(SWIFT(it).signature.profile,'u')  && ~isempty(SWIFT(it).signature.profile.u)
            swift.relu(:,it) = SWIFT(it).signature.profile.u;
            swift.relv(:,it) = SWIFT(it).signature.profile.v;
            swift.relw(:,it) = SWIFT(it).signature.profile.w;
            if isfield(SWIFT(it).signature.profile,'uvar')
            swift.reluerr(:,it) = SWIFT(it).signature.profile.uvar;
            swift.relverr(:,it) = SWIFT(it).signature.profile.vvar;
            swift.relwerr(:,it) = SWIFT(it).signature.profile.wvar;
            else
            swift.reluerr(:,it) = SWIFT(it).signature.profile.uerr;
            swift.relverr(:,it) = SWIFT(it).signature.profile.verr;
            swift.relwerr(:,it) = SWIFT(it).signature.profile.werr;
            end

        end
    end
elseif isfield(SWIFT,'downlooking')
    swift.depth = SWIFT(end).downlooking.z';
    nz = length(swift.depth);
    swift.relu = NaN(nz,nt);
    swift.relv = NaN(nz,nt);
    swift.relw = NaN(nz,nt);
    swift.reluerr = NaN(nz,nt);
    swift.relverr = NaN(nz,nt);
    swift.relwerr = NaN(nz,nt);       
elseif isfield(SWIFT,'uplooking')
    swift.depth = SWIFT(end).uplooking.z;
    nz = length(swift.depth);
    swift.relu = NaN(nz,nt);
    swift.relv = NaN(nz,nt);
    swift.relw = NaN(nz,nt);
    swift.reluerr = NaN(nz,nt);
    swift.relverr = NaN(nz,nt);
    swift.relwerr = NaN(nz,nt); 
else
    swift.depth = (0:0.5:20)';
    nz = length(swift.depth);
    swift.relu = NaN(nz,nt);
    swift.relv = NaN(nz,nt);
    swift.relw = NaN(nz,nt);
    swift.reluerr = NaN(nz,nt);
    swift.relverr = NaN(nz,nt);
    swift.relwerr = NaN(nz,nt); 
end
% Absolute velocity
swift.subu = swift.relu + swift.driftu;
swift.subv = swift.relv + swift.driftv;

% Wave Spectra
for it = 1:nt
    wavepower = SWIFT(it).wavespectra.energy;
    wavefreq = SWIFT(it).wavespectra.freq;
    if length(wavepower) ~= length(wavefreq)
        wavepower = NaN(size(wavefreq));
    end
    if isempty(wavepower) || isempty(wavefreq)
        swift.wavepower(:,it) = 0;
        swift.wavefreq(:,it) = NaN;
    else
     swift.wavepower(1:length(wavepower),it) = wavepower;
     swift.wavefreq(1:length(wavepower),it) = wavefreq;
    end
end
swift.wavepower(swift.wavepower<0) = 0;
wavefreq = median(swift.wavefreq,2,'omitnan');
wavepower = NaN(length(wavefreq),nt);
% Interpolate to median frequency
for it = 1:nt
    ireal = ~isnan(swift.wavepower(:,it)) & swift.wavepower(:,it)~=0;
    if sum(ireal)>3
    wavepower(:,it) = interp1(swift.wavefreq(ireal,it),swift.wavepower(ireal,it),wavefreq);
    end
end
swift.wavepower = wavepower;
swift.wavefreq = wavefreq;

% Wave Bulk Variables
swift.wavesigH = [SWIFT.sigwaveheight];
swift.wavepeakT = [SWIFT.peakwaveperiod];
swift.wavepeakdir = [SWIFT.peakwavedirT];

% Calculate new Stokes drift (Us = omega*k*(Hs/4)^2)
om = 2*pi./swift.wavepeakT;
k = om.^2./9.81;
swift.waveustokes = (swift.wavesigH./4).^2.*om.*k;
% Re-calculate peak wave period (via centroid method)
wavepower = swift.wavepower;
wavefreq = swift.wavefreq;
wavevar = sum(wavepower,1,'omitnan');
waveweight = sum(wavepower.*repmat(wavefreq,1,size(wavepower,2)),1,'omitnan');
swift.wavepeakT = 1./(waveweight./wavevar);
% Directional Wave Spectra
% [~,swift.wavedir,~,~,~,~,~,~] = SWIFTdirectionalspectra(SWIFT(1),0);
% ndir = length(swift.wavedir);
% nf = length(wavefreq);
% swift.dirwavepower = NaN(nf,ndir,nt);
% for it = 1:nt
%     [swift.dirwavepower(:,:,it),~,~,~,~,~,~,~] = SWIFTdirectionalspectra(SWIFT(it),0);
% end


 % Wind
 if isfield(SWIFT,'windspd')
    swift.windu = [SWIFT.windspd];
 else
    swift.windu = NaN(size(swift.driftspd));
 end
 if isfield(SWIFT,'winddirT')
     swift.winddir = [SWIFT.winddirT];
 elseif isfield(SWIFT,'windmeanu')
    swift.winddir = atan2d([SWIFT.windmeanv],[SWIFT.windmeanu]);
 else
     swift.winddir = NaN(size(swift.driftspd));
 end
 if isfield(SWIFT,'windspectra') 
     for it = 1:nt
        windpower = SWIFT(it).windspectra.energy;
        windfreq = SWIFT(it).windspectra.freq;
        if length(windpower) ~= length(windfreq)
            windpower = NaN(size(windfreq));
        end
        if isempty(windpower) || isempty(windfreq)
            swift.windpower(:,it) = 0;
            swift.windfreq(:,it) = NaN;
        else
         swift.windpower(:,it) = windpower;
         swift.windfreq(:,it) = windfreq;
        end
     end

 else
    swift.windfreq = NaN(116,1);
    swift.windpower = NaN(116,nt);
 end
 swift.windfreq = median(swift.windfreq,2,'omitnan');
 if isfield(SWIFT,'windustar')
     swift.windustar = [SWIFT.windustar];
 end

% TKE Dissipation Rate and HR vertical velocity
if isfield(SWIFT,'signature')
    swift.surfz = SWIFT(end).signature.HRprofile.z';
    nz = length(swift.surfz);
    swift.surftke = NaN(nz,nt);
    for it = 1:nt
        if isfield(SWIFT(it).signature.HRprofile,'tkedissipationrate')
        tke = SWIFT(it).signature.HRprofile.tkedissipationrate;
            if ~isempty(tke)
                swift.surftke(1:length(tke),it) = tke;
            else
                swift.surftke(:,it) = NaN(nz,1);
            end
        else
            swift.surftke(:,it) = NaN(nz,1);
        end
    end
elseif isfield(SWIFT,'uplooking')
    swift.surfz = SWIFT(1).uplooking.z';
    nz = length(swift.surfz);
    swift.surftke = NaN(nz,nt);
    for it = 1:nt
        swift.surftke(:,it) = SWIFT(it).uplooking.tkedissipationrate;
    end
    swift.surftke(1:4,:) = NaN;% Deepest three bins are bad 
else
    swift.surfz = (0.1+0.2+0.04*(0:127));
    swift.surftke = NaN(128,nt);
end

% Echograms
if isfield(SWIFT,'signature')
    if isfield(SWIFT(floor(end/2)).signature,'echogram')
    swift.echoz = SWIFT(1).signature.echogram.z;
    nz = length(swift.echoz);
    swift.echo = NaN(nz,nt);
    for it = 1:nt
        if isfield(SWIFT(it).signature,'echogram')
            echo = SWIFT(it).signature.echogram.echoc;
            swift.echo(1:length(echo),it) = echo;
        else 
            swift.echo(:,it) = NaN(nz,1);
        end
    end
    end
end
  
