
function swift = catSWIFT(SWIFT)
% Returns concatenated swift data in structure format
    

% Time, lat, lon, battery
swift.time = [SWIFT.time];
nt = length(swift.time);
swift.lon = 360 + [SWIFT.lon];
swift.lat = [SWIFT.lat];
if isfield(SWIFT,'battery')
swift.battery = [SWIFT.battery];
end

% Wind Speed, Air & sea temperature & pressure & salinity
 if isfield(SWIFT,'windspd')
    swift.windu = [SWIFT.windspd];
 else
    swift.windu = NaN(1,nt);
 end
  if isfield(SWIFT,'windspdstddev')
    swift.windustd = [SWIFT.windspdstddev];
 else
    swift.windustd = NaN(1,nt);
  end
    if isfield(SWIFT,'windspdskew')
    swift.winduskew = [SWIFT.windspdskew];
 else
    swift.winduskew = NaN(1,nt);
    end
      if isfield(SWIFT,'windspdkurt')
    swift.windukurt = [SWIFT.windspdkurt];
 else
    swift.windukurt = NaN(1,nt);
      end

if isfield(SWIFT,'tilt')
    swift.tilt = [SWIFT.tilt];
 else
    swift.tilt = NaN(1,nt);
end
if isfield(SWIFT,'tiltstd')
    swift.tiltstd = [SWIFT.tiltstd];
 else
    swift.tiltstd = NaN(1,nt);
end


if isfield(SWIFT,'watertemp')
    swift.tsea = NaN(1,nt);
    for it = 1:nt
        swift.tsea(it) = max(SWIFT(it).watertemp);
    end
else
    swift.tsea = NaN(1,nt);
end
if isfield(SWIFT,'watertempstddev')
    swift.tseastd = NaN(1,nt);
    for it = 1:nt
        swift.tseastd(it) = max(SWIFT(it).watertempstddev);
    end
else
    swift.tseastd = NaN(1,nt);
end
if isfield(SWIFT,'watertemp2')
    swift.tsea2 = NaN(1,nt);
    for it = 1:nt
        if ~isempty(SWIFT(it).watertemp2)
        swift.tsea2(it) = max(SWIFT(it).watertemp2);
        else
            swift.tsea2(it) = NaN;
        end
    end
else
    swift.tsea2 = NaN(1,nt);
end
if isfield(SWIFT,'watertemp2stddev')
    swift.tsea2std = NaN(1,nt);
    for it = 1:nt
        swift.tsea2std(it) = max(SWIFT(it).watertemp2stddev);
    end
else
    swift.tsea2std = NaN(1,nt);
end

if isfield(SWIFT,'watertemp3')
    swift.tsea3 = NaN(1,nt);
    for it = 1:nt
        swift.tsea3(it) = max(SWIFT(it).watertemp3);
    end
else
    swift.tsea3 = NaN(1,nt);
end
if isfield(SWIFT,'watertemp3stddev')
    swift.tsea3std = NaN(1,nt);
    for it = 1:nt
        swift.tsea3std(it) = max(SWIFT(it).watertemp3stddev);
    end
else
    swift.tsea3std = NaN(1,nt);
end


if isfield(SWIFT,'airtemp')
swift.tair = [SWIFT.airtemp];
else
    swift.tair = NaN(1,nt);
end
if isfield(SWIFT,'airtempstddev')
swift.tairstd = [SWIFT.airtempstddev];
else
    swift.tairstd = NaN(1,nt);
end
if isfield(SWIFT,'salinity')
    swift.sal = [SWIFT.salinity];
else
    swift.sal = NaN(1,nt);
end
if isfield(SWIFT,'salinitystddev')
    swift.salstd = [SWIFT.salinitystddev];
else
    swift.salstd = NaN(1,nt);
end
if isfield(SWIFT,'airpres')
    swift.press = [SWIFT.airpres];
else
    swift.press = NaN(1,nt);

end
if isfield(SWIFT,'airpresstddev')
    swift.pressstd = [SWIFT.airpresstddev];
else
    swift.pressstd = NaN(1,nt);
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
if isfield(SWIFT,'relhumiditystddev')
    swift.humidstd = [SWIFT.relhumiditystddev];
else
     swift.humidstd = NaN(1,nt);
end

% O2
if isfield(SWIFT,'O2conc')
    swift.O2conc = [SWIFT.O2conc];
else
    swift.O2conc = NaN(1,nt);
end
if isfield(SWIFT,'O2concstddev')
    swift.O2concstd = [SWIFT.O2concstddev];
else
    swift.O2concstd = NaN(1,nt);
end
if isfield(SWIFT,'O2sat')
    swift.O2sat = [SWIFT.O2sat];
else
    swift.O2sat = NaN(1,nt);
end
if isfield(SWIFT,'O2satstddev')
    swift.O2satstddev = [SWIFT.O2satstddev];
else
    swift.O2satstddev = NaN(1,nt);
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
% time = [SWIFT.time];
% lat = [SWIFT.lat];
% lon = [SWIFT.lon];
% dt = diff(time);
% dlon = diff(lon); % deg
% u = deg2km(dlon,6371*cosd(mean(lat,'omitnan'))) .* 1000 ./ ( dt*24*3600 ); % m/s
% dlat = diff(lat); % deg/days
% v = deg2km(dlat) .* 1000 ./ ( dt*24*3600 ); % m/s
% ibad = abs(u) > 1 | abs(v) > 1 | isinf(u) | isinf(v);
% u(ibad) = NaN;
% v(ibad) = NaN;
% swift.driftu(2:nt) = u;
% swift.driftv(2:nt) = v;
% swift.driftspd(2:nt) = sqrt(u.^2 + v.^2); % m/s
swift.driftspd = [SWIFT.driftspd];
swift.driftdir = [SWIFT.driftdirT];
swift.driftu = sind(swift.driftdir).*swift.driftspd;
swift.driftv = cosd(swift.driftdir).*swift.driftspd;

% Relative Velocity
if isfield(SWIFT,'signature') && isstruct(SWIFT(1).signature.profile)
    it = 1; nz = 0;
    swift.depth = NaN;
    while nz == 0 || any(isnan(swift.depth))
        swift.depth = SWIFT(it).signature.profile.z';
        nz = length(swift.depth);
        it = it + 1;
        if it == nt
            swift.depth = NaN;
            nz = 1;
           break
        end
    end
    swift.relu = NaN(nz,nt);
    swift.relv = NaN(nz,nt);
    swift.relw = NaN(nz,nt);
    swift.reluerr = NaN(nz,nt);
    swift.relverr = NaN(nz,nt);
    swift.relwerr = NaN(nz,nt);
    swift.spd_alt = NaN(nz,nt);
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
        if isfield(SWIFT(it).signature.profile,'spd_alt')
            swift.spd_alt(:,it) = SWIFT(it).signature.profile.spd_alt;
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
    if isfield(SWIFT(it).wavespectra,'check')
    wavea1 = SWIFT(it).wavespectra.a1;
    waveb1 = SWIFT(it).wavespectra.b1;
    wavea2 = SWIFT(it).wavespectra.a2;
    waveb2 = SWIFT(it).wavespectra.b2;
    wavecheck = SWIFT(it).wavespectra.check;
    else
        wavecheck = NaN(size(wavepower));
        wavea1 = NaN(size(wavepower));
        waveb1 = NaN(size(wavepower));
        wavea2 = NaN(size(wavepower));
        waveb2 = NaN(size(wavepower));
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

% Stokes profiles
if isfield(SWIFT,'Stokes')
    swift.stokesu = NaN(40,nt);
    swift.stokesv = NaN(40,nt);
        swift.stokesubulk = NaN(40,nt);
    swift.stokesvbulk = NaN(40,nt);
        swift.stokesu1d = NaN(40,nt);
    swift.stokesv1d = NaN(40,nt);
    swift.stokesz = (.35:.5:19.85)';
    for it = 1:nt
        swift.stokesu(:,it) = SWIFT(it).Stokes.spectral.profile.east;
        swift.stokesv(:,it) = SWIFT(it).Stokes.spectral.profile.north;
        swift.stokesubulk(:,it) = SWIFT(it).Stokes.monochrom.profile.east;
        swift.stokesvbulk(:,it) = SWIFT(it).Stokes.monochrom.profile.north;
        swift.stokesu1d(:,it) = SWIFT(it).Stokes.spec1d.profile.east;
        swift.stokesv1d(:,it) = SWIFT(it).Stokes.spec1d.profile.north;
    end
end

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
if isfield(SWIFT,'peakwaveperiod')
    swift.wavepeakT = [SWIFT.peakwaveperiod];
    swift.wavepeakdir = [SWIFT.peakwavedirT];
    
    % Calculate new Stokes drift (Us = omega*k*(Hs/4)^2)
    om = 2*pi./swift.wavepeakT;
    k = om.^2./9.81;
    swift.waveustokes = (swift.wavesigH./4).^2.*om.*k;
    
    % Re-calculate peak wave period (via centroid method)
    if isfield(SWIFT,'centwaveperiod')
        swift.wavecentT = [SWIFT.centwaveperiod];
    else
    wavepower = swift.wavepower;
    wavefreq = swift.wavefreq;
    wavevar = sum(wavepower,1,'omitnan');
    waveweight = sum(wavepower.*repmat(wavefreq,1,size(wavepower,2)),1,'omitnan');
    swift.wavecentT = 1./(waveweight./wavevar);
    end
end

 % Wind Spectra
 if isfield(SWIFT,'windustar')
     swift.windustar = [SWIFT.windustar];
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
    swift.surfw = NaN(nz,nt);
    for it = 1:nt
        if isfield(SWIFT(it).signature.HRprofile,'tkedissipationrate')
        tke = SWIFT(it).signature.HRprofile.tkedissipationrate;
        if length(tke) > nz
            warning(['Burst ' num2str(it) ' HR profile wrong size. Skipping.'])
            tke = NaN(nz,1);
            w = NaN(nz,1);
        else
            if isfield(SWIFT(it).signature.HRprofile,'w')
            w = SWIFT(it).signature.HRprofile.w;
            else
                w = NaN(size(tke));
            end
        end
            if ~isempty(tke)
                swift.surftke(:,it) = tke;
                swift.surfw(:,it) = w;
            else
                swift.surftke(:,it) = NaN(nz,1);
                swift.surfw(:,it) = NaN(nz,1);
            end
        else
            swift.surftke(:,it) = NaN(nz,1);
            swift.surfw(:,it) = NaN(nz,1);
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
    if isfield(SWIFT(ceil(end/2)).signature,'echo')
        it = 1; nz = 0;
        while nz == 0
            swift.echoz = SWIFT(it).signature.echoz';
            nz = length(swift.echoz);
            it = it + 1;
        end
        swift.echo = NaN(nz,nt);
        for it = 1:nt
            if isfield(SWIFT(it).signature,'echo')
                echo = SWIFT(it).signature.echo;
                swift.echo(1:length(echo),it) = echo;
            else 
                swift.echo(:,it) = NaN(nz,1);
            end
        end
    end
end

% Altimeter
if isfield(SWIFT,'signature')
    swift.altz = NaN(1,nt);
    for it = 1:nt
        if isfield(SWIFT(it).signature,'altimeter')
            swift.altz(it) = SWIFT(it).signature.altimeter;
        end
    end
end
