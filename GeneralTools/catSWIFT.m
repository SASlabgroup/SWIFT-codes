
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

%Air & sea temperature & pressure & salinity
if isfield(SWIFT,'airtemp')
swift.tair = [SWIFT.airtemp];
else
    swift.tair = NaN(1,nt);
end
for it = 1:nt
swift.tsea(it) = max(SWIFT(it).watertemp);
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
    swift.depth = SWIFT(1).signature.profile.z';
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
    swift.depth = SWIFT(1).downlooking.z';
    nz = length(swift.depth);
    swift.relu = NaN(nz,nt);
    swift.relv = NaN(nz,nt);
    swift.relw = NaN(nz,nt);
    swift.reluerr = NaN(nz,nt);
    swift.relverr = NaN(nz,nt);
    swift.relwerr = NaN(nz,nt);       
elseif isfield(SWIFT,'uplooking')
    swift.depth = SWIFT(1).uplooking.z;
    nz = length(swift.depth);
    swift.relu = NaN(nz,nt);
    swift.relv = NaN(nz,nt);
    swift.relw = NaN(nz,nt);
    swift.reluerr = NaN(nz,nt);
    swift.relverr = NaN(nz,nt);
    swift.relwerr = NaN(nz,nt); 
else
    swift.depth = [0:0.5:20]';
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

%Waves
% SWIFT = SWIFT_Stokes(SWIFT);
for it = 1:nt
    wavepower = SWIFT(it).wavespectra.energy;
    wavefreq = SWIFT(it).wavespectra.freq;
    if length(wavepower) ~= length(wavefreq)
        wavepower = NaN(size(wavefreq));
    end
 swift.wavepower(:,it) = wavepower;
 swift.wavefreq(:,it) = wavefreq;
end
swift.wavefreq = mean(swift.wavefreq,2,'omitnan');
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
[~,swift.wavedir,~,~,~,~,~,~] = SWIFTdirectionalspectra(SWIFT(1),0);
ndir = length(swift.wavedir);
nf = length(wavefreq);
swift.dirwavepower = NaN(nf,ndir,nt);
for it = 1:nt
    [swift.dirwavepower(:,:,it),~,~,~,~,~,~,~] = SWIFTdirectionalspectra(SWIFT(it),0);
end

 %Wind
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
    swift.windfreq = SWIFT(1).windspectra.freq;
    nf = length(swift.windfreq);
    swift.windpower = NaN(nf,nt);
    for it = 1:nt
     swift.windpower(:,it) = SWIFT(it).windspectra.energy;
    end
 else
    swift.windfreq = NaN(116,1);
    swift.windpower = NaN(116,nt);
 end

%TKE Dissipation Rate and HR vertical velocity
if isfield(SWIFT,'signature')
    swift.surfz = SWIFT(1).signature.HRprofile.z';
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
end
