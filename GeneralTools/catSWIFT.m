
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
if isfield(SWIFT,'infraredtempmean')% This is the brightness (target) temperature
    nrad = length(SWIFT(1).infraredtempmean);
    swift.IRtemp = reshape([SWIFT.infraredtempmean],nrad,length(SWIFT));
    if size(swift.IRtemp,2)~= nt
        swift.IRtemp = swift.IRtemp';
    end
end
if isfield(SWIFT,'ambienttempmean')% This is the jacket temperature
    nrad = length(SWIFT(1).ambienttempmean);
    swift.AMBtemp = reshape([SWIFT.ambienttempmean],nrad,length(SWIFT));
    if size(swift.AMBtemp,2)~= nt
        swift.AMBtemp = swift.AMBtemp';
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
    it = 1; nz = 0;
    swift.depth = NaN;
    while nz == 0 || any(isnan(swift.depth))
        swift.depth = SWIFT(it).signature.profile.z';
        nz = length(swift.depth);
        it = it + 1;
    end
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
    it = 1; nz = 0;
    swift.depth = NaN;
    while nz == 0 || any(isnan(swift.depth))
        swift.depth = SWIFT(it).downlooking.z';
        nz = length(swift.depth);
        it = it + 1;
    end
     if any(isnan(swift.depth)) 
        swift.depth = 1.5+(1:nz)*0.04;
    end
    swift.relu = NaN(nz,nt);
    swift.relv = NaN(nz,nt);
    swift.relw = NaN(nz,nt);
    swift.reluerr = NaN(nz,nt);
    swift.relverr = NaN(nz,nt);
    swift.relwerr = NaN(nz,nt);       
elseif isfield(SWIFT,'uplooking')
    it = 1; nz = 0;
    swift.depth = NaN;
    while nz == 0 || any(isnan(swift.depth)) && it < nt
        swift.depth = SWIFT(it).uplooking.z';
        nz = length(swift.depth);
        it = it + 1;
    end
    if any(isnan(swift.depth)) 
        swift.depth = 0.9+(1:nz)*0.04;
    end
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
    wavea1 = SWIFT(it).wavespectra.a1;
    waveb1 = SWIFT(it).wavespectra.b1;
    wavea2 = SWIFT(it).wavespectra.a2;
    waveb2 = SWIFT(it).wavespectra.b2;
    if isfield(SWIFT(it).wavespectra,'check')
    wavecheck = SWIFT(it).wavespectra.check;
    else
        wavecheck = NaN(size(waveb2));
    end
    if length(wavepower) ~= length(wavefreq)
        wavepower = NaN(size(wavefreq));
        wavea1 = NaN(size(wavefreq));
        waveb1 = NaN(size(wavefreq));
        wavea2 = NaN(size(wavefreq));
        waveb2 = NaN(size(wavefreq));
        wavecheck = NaN(size(wavefreq));
    end
    if isempty(wavepower) || isempty(wavefreq)
        swift.wavepower(:,it) = 0;
        swift.wavea1(:,it) = 0;
        swift.wavea2(:,it) = 0;
        swift.waveb1(:,it) = 0;
        swift.waveb2(:,it) = 0;
        swift.wavecheck(:,it) = 0;
        swift.wavefreq(:,it) = NaN;
    else
     swift.wavepower(1:length(wavepower),it) = wavepower;
     swift.wavea1(1:length(wavepower),it) = wavea1;
     swift.waveb1(1:length(wavepower),it) = waveb1;
     swift.wavea2(1:length(wavepower),it) = wavea2;
     swift.waveb2(1:length(wavepower),it) = waveb2;
     swift.wavecheck(1:length(wavepower),it) = wavecheck;
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

 % Wind
 if isfield(SWIFT,'windustar')
     swift.windustar = [SWIFT.windustar];
 end
 if isfield(SWIFT,'windspd')
    swift.windu = [SWIFT.windspd];
 else
    swift.windu = NaN(size(swift.driftspd));
 end
  if isfield(SWIFT,'windspdR')
    swift.winduR = [SWIFT.windspdR];
 else
    swift.winduR = NaN(size(swift.driftspd));
 end
 if isfield(SWIFT,'winddirT')
     swift.winddir = [SWIFT.winddirT];
 elseif isfield(SWIFT,'windmeanu')
    swift.winddir = atan2d([SWIFT.windmeanv],[SWIFT.windmeanu]);
 else
     swift.winddir = NaN(size(swift.driftspd));
 end
 if isfield(SWIFT,'winddirR')
     swift.winddirR = [SWIFT.winddirR];
 else
     swift.winddirR = NaN(size(swift.driftspd));
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
    it = 1; nz = 0;
    swift.surfz = NaN;
    while nz == 0 || any(isnan(swift.surfz))
        swift.surfz = SWIFT(it).signature.HRprofile.z';
        nz = length(swift.surfz);
        it = it + 1;
    end
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
    it = 1; nz = 0;
    swift.surfz = NaN;
    while nz == 0 || any(isnan(swift.surfz)) && it <= nt
        swift.surfz = SWIFT(it).uplooking.z';
        nz = length(swift.surfz);
        it = it + 1;
    end
    if any(isnan(swift.depth)) 
        swift.depth = 0.9+(1:nz)*0.04;
    end
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
        it = 1; nz = 0;
        while nz == 0
            swift.echoz = SWIFT(it).signature.echogram.z';
            nz = length(swift.echoz);
            it = it + 1;
        end
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
  
