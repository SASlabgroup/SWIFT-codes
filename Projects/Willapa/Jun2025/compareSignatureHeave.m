function results = compareSignatureHeave(missiondir,depth_time,depth)

% Compare accelerometer heave spectra with the canonical SWIFT wave spectrum,
% SBGwaves(u,v,heave), show where finite depth enters SBGwaves, and size the
% second-order term of the |f| - g heave proxy used by SignatureHeaveWaves.
%
%   results = compareSignatureHeave(missiondir,depth_time,depth)
%
% missiondir is a moored mission folder (SBG/Raw and SIG/Raw). depth_time
% (datenum) and depth (m) give the water depth; each burst takes the nearest
% value within 10 minutes. For Willapa, the anchor RBR depth, e.g.
%   t = double(ncread(f,'time'))/1e9/86400 + datenum(2025,6,17,19,50,0);
%   results = compareSignatureHeave(missiondir,t,ncread(f,'water_depth'));
%
% Spectra per burst, all through SBGwaves:
%   heave     SBGwaves(u,v,heave) scalar energy, the SBG onboard heave: the
%             canonical spectrum written by reprocess_SBG
%   sbg_abs   SBG |f| - g
%   sbg_2nd   SBG |f| - g - |a_h|^2/(2g)
%   sbg_az    SBG earth-vertical acceleration, f rotated by EKF roll/pitch
%   sig_abs   Signature |f| - g from SignatureHeaveWaves (the fill input)
% Accelerations are divided by (2*pi*f)^4 at the true band centre, as in
% SignatureHeaveWaves. results.check is the SBGwaves check, Ezz/(Exx+Eyy).
%
% Assumptions
% - SBGwaves E is the heave spectrum; it does not depend on depth. Depth
%   enters only through the deep-water conversion of u,v to displacement,
%   Exx = UU/omega^2. That conversion cancels in a1, b1 (Cxz over
%   sqrt((Exx+Eyy) Ezz)) and in a2, b2 (ratios of horizontal spectra), so
%   only check = Ezz/(Exx+Eyy) depends on depth: linear theory gives
%   tanh^2(kh) instead of 1 (observed frequency, no current).
% - To second order in a/g, |f| - g = a_z + |a_h|^2/(2g). The horizontal
%   term is computed from the SBG EKF tilt.
% - The SBG spectra use the part of each burst where the SBG flags heave as
%   valid (reprocess_SBG crops a fixed 90 s instead; Hs differs by < 2% in
%   80% of bursts). The Signature spectrum uses its own burst; it is not
%   time-matched to the SBG window.
% - Above ~1.25 Hz the Signature is noisy and the hull no longer follows the
%   surface; only 0.05-1.25 Hz is compared.
%
% Conclusions (SWIFT23/MC: 1287 bursts, heave Hs ~0.85 m, depth 12.5 m;
% SWIFT25/EB: 1041 bursts, heave Hs ~0.08 m, depth 8.6 m)
% - Finite depth does not affect the canonical SBGwaves products (E, Hs, Tp,
%   a1, b1, a2, b2, Dp); it changes only the expected check. At MC the
%   observed check follows tanh^2(kh) below 0.2 Hz (0.22/0.53/0.97 vs
%   0.18/0.40/0.81 at 0.05-0.08/0.08-0.12/0.12-0.2 Hz) and falls below 1
%   above 0.2 Hz (0.77-0.16) from GPS horizontal energy that is not waves.
%   At EB check is 0.01-0.31 throughout: the SWIFT25 GPS is unusable.
% - Accelerometer heave matches the canonical SBG heave from 0.12 to
%   0.6 Hz (SBG a_z and Signature 0.97-1.01 at MC; 1.00-1.08 at EB above
%   0.2 Hz). Above 0.6 Hz the SBG onboard heave is attenuated: SBG a_z is
%   1.11x heave at 0.6-1 Hz and 1.96x at 1-1.25 Hz at MC (1.04 and 1.11 at
%   EB). The Signature tracks SBG a_z there within ~7%.
% - The second-order term is real but small: removing |a_h|^2/(2g)
%   recovers the exact a_z in every band (0.99-1.00), and it only matters
%   below 0.08 Hz at MC (1.18x) and below 0.2 Hz at EB (1.06-1.13x). So
%   |f| - g needs no AHRS and no second-order correction.
% - Below the swell band the Signature carries additive accelerometer noise:
%   1.9x the SBG a_z at 0.05-0.08 Hz at MC, and 1.8-2.9x below 0.2 Hz at the
%   low-signal EB. That sets the fill's per-burst low edge in
%   reprocess_SIGheave (median 0.24 Hz on SWIFT25).
%
% M. LeClair w/ claude, Oct 2026

gravity = 9.80665;
nband = 170;          % SBGwaves bands up to 2 Hz at 4 and 5 Hz sampling
frequency = 1/256 + 3/256/2 + 3/256*(0:nband-1);   % SBGwaves band labels
names = ["heave","sbg_abs","sbg_2nd","sbg_az","sig_abs"];

sbgfiles = dir(fullfile(missiondir,'SBG','Raw','**','SWIFT*_SBG_*.mat'));
sbgfiles = sbgfiles(~startsWith({sbgfiles.name},'._'));
sigfiles = dir(fullfile(missiondir,'SIG','Raw','**','SWIFT*_SIG_*.mat'));
sigfiles = sigfiles(~startsWith({sigfiles.name},'._'));
signames = string({sigfiles.name});

nburst = numel(sbgfiles);
energy = NaN(nburst,nband,numel(names));
check = NaN(nburst,nband);
burst_time = NaN(nburst,1);
parfor ib = 1:nburst
    loaded = load(fullfile(sbgfiles(ib).folder,sbgfiles(ib).name),'sbgData');
    if ~hasSBGfields(loaded); continue; end
    sbg = loaded.sbgData;
    E = NaN(nband,numel(names));

    % SBG series on the IMU timestamps (EKF and GPS share them; ShipMotion
    % is 5-15 ms off and is interpolated).
    [ti,f] = cleanSeries(sbg.ImuData.time_stamp, ...
        [sbg.ImuData.accel_x(:) sbg.ImuData.accel_y(:) sbg.ImuData.accel_z(:)],100);
    [te,tilt] = cleanSeries(sbg.EkfEuler.time_stamp, ...
        [sbg.EkfEuler.roll(:) sbg.EkfEuler.pitch(:)],pi);
    [tg,gps] = cleanSeries(sbg.GpsVel.time_stamp, ...
        [sbg.GpsVel.vel_e(:) sbg.GpsVel.vel_n(:)],10);
    heave_valid = bitand(double(sbg.ShipMotion.heave_status(:)),1) > 0;
    [th,heave] = cleanSeries(sbg.ShipMotion.time_stamp(heave_valid), ...
        sbg.ShipMotion.heave(heave_valid),50);
    [t0,t1] = longestRun(th);
    sample_time = ti(ti >= max([t0 te(1) tg(1)]) & ti <= min([t1 te(end) tg(end)]));
    if numel(sample_time) < 1300 || any(diff(sample_time) > 0.25); continue; end   % one 256 s window at 5 Hz

    f = interp1(ti,f,sample_time);
    tilt = interp1(te,unwrap(tilt),sample_time);
    gps = interp1(tg,gps,sample_time);
    heave = interp1(th,heave,sample_time);

    % Specific force: magnitude, down component (FRD body to NED with the
    % EKF roll/pitch) and the horizontal part.
    f_abs = vecnorm(f,2,2);
    f_down = -sin(tilt(:,2)).*f(:,1) + cos(tilt(:,2)).*sin(tilt(:,1)).*f(:,2) + ...
        cos(tilt(:,2)).*cos(tilt(:,1)).*f(:,3);
    a_h2 = max(f_abs.^2 - f_down.^2,0);

    [~,~,~,E_heave,~,~,~,~,~,E_check] = SBGwaves(gps(:,1),gps(:,2),heave,5);
    if numel(E_heave) < nband; continue; end
    E(:,1) = E_heave(1:nband);
    E(:,2) = sbgwavesAcceleration(f_abs - gravity,nband);
    E(:,3) = sbgwavesAcceleration(f_abs - gravity - a_h2/(2*gravity),nband);
    E(:,4) = sbgwavesAcceleration(-f_down - gravity,nband);

    % Signature burst with the same burst id, through the fill's own function.
    burst_id = extractBetween(string(sbgfiles(ib).name),"_SBG_",".mat");
    k = find(startsWith(signames,extractBefore(string(sbgfiles(ib).name),"_SBG_")+"_SIG_"+burst_id),1);
    if ~isempty(k)
        sig = load(fullfile(sigfiles(k).folder,sigfiles(k).name),'burst');
        if isfield(sig,'burst') && isfield(sig.burst,'Accelerometer') && isfield(sig.burst,'time')
            E(:,5) = SignatureHeaveWaves(sig.burst.Accelerometer,sig.burst.time,frequency);
        end
    end

    energy(ib,:,:) = E;
    check(ib,:) = E_check(1:nband);
    burst_time(ib) = datenum(double(sbg.UtcTime.year(end)),double(sbg.UtcTime.month(end)), ...
        double(sbg.UtcTime.day(end)),double(sbg.UtcTime.hour(end)), ...
        double(sbg.UtcTime.min(end)),double(sbg.UtcTime.sec(end)));
end

% Linear theory for check: tanh^2(kh) with the burst's depth.
[dt,nearest] = min(abs(burst_time - depth_time(:)'),[],2);
burst_depth = depth(nearest);
burst_depth(dt > 10/1440) = NaN;
check_theory = NaN(nburst,nband);
for ib = find(isfinite(burst_depth(:)))'
    for j = 1:nband
        check_theory(ib,j) = tanh(wavenumber(frequency(j),burst_depth(ib))*burst_depth(ib))^2;
    end
end

results.frequency = frequency;
results.time = burst_time;
results.depth = burst_depth;
results.names = names;
results.energy = energy;
results.check = check;
results.check_theory = check_theory;

% Summary tables and figure.
band_edges = [0.05 0.08 0.12 0.2 0.35 0.6 1 1.25];
compared = frequency > 0.05 & frequency < 1.25;
ok = all(isfinite(energy(:,compared,:)),[2 3]) & isfinite(burst_depth);
fig = figure('Color','w','Position',[50 50 1500 450]);
tiledlayout(1,3,'TileSpacing','compact');

nexttile; hold on
fprintf('\nMedian energy ratio to the canonical SBGwaves heave (%d bursts)\n',nnz(ok));
printHeader(band_edges)
for j = 2:5
    printBandRatios(names(j),energy(ok,:,j),energy(ok,:,1),frequency,band_edges)
    plot(frequency,median(energy(ok,:,j)./energy(ok,:,1),1),'LineWidth',2,'DisplayName',names(j))
end
formatAxes('vs canonical SBGwaves heave','median energy ratio')

nexttile; hold on
fprintf('\nSBGwaves check, observed vs tanh^2(kh)\n%-10s','');
fprintf(' %4.2f-%-4.2f',[band_edges(1:end-1); band_edges(2:end)]);
fprintf('\n');
printBandMedian('observed',check(ok,:),frequency,band_edges)
printBandMedian('tanh^2',check_theory(ok,:),frequency,band_edges)
plot(frequency,median(check(ok,:),1,'omitnan'),'LineWidth',2,'DisplayName','observed Ezz/(Exx+Eyy)')
plot(frequency,median(check_theory(ok,:),1),'LineWidth',2,'DisplayName','tanh^2(kh)')
formatAxes(sprintf('SBGwaves check, depth %.1f m (median)',median(burst_depth(ok))),'median')

nexttile; hold on
fprintf('\nMedian energy ratio to SBG exact a_z (%d bursts)\n',nnz(ok));
printHeader(band_edges)
for j = [2 3 5]
    printBandRatios(names(j),energy(ok,:,j),energy(ok,:,4),frequency,band_edges)
    plot(frequency,median(energy(ok,:,j)./energy(ok,:,4),1),'LineWidth',2,'DisplayName',names(j))
end
formatAxes('vs SBG exact a_z','median energy ratio')
results.figure = fig;

end

function E = sbgwavesAcceleration(acceleration,nband)

% Heave energy from a 5 Hz vertical acceleration series: SBGwaves spectrum
% divided by (2*pi*f)^4 at the true band centre, half a raw bin below the
% SBGwaves label (as in SignatureHeaveWaves).
zero = zeros(size(acceleration));
[~,~,~,E,f] = SBGwaves(zero,zero,acceleration,5);
E = E(1:nband)'./(2*pi*(f(1:nband)' - 1/(2*256))).^4;

end

function formatAxes(name,label)

yline(1,'k-','HandleVisibility','off')
set(gca,'XScale','log','YScale','log','XLim',[0.05 1.25],'YLim',[0.01 10])
grid on
xlabel('Frequency (Hz)')
ylabel(label)
title(name)
legend('Location','southeast','Interpreter','none','Box','off')

end

function printHeader(band_edges)

fprintf('%-10s','');
fprintf(' %4.2f-%-4.2f',[band_edges(1:end-1); band_edges(2:end)]);
fprintf('   Hs ratio\n');

end

function printBandRatios(name,E,reference,frequency,band_edges)

fprintf('%-10s',name);
for b = 1:numel(band_edges)-1
    in = frequency >= band_edges(b) & frequency < band_edges(b+1);
    fprintf(' %9.2f',median(sum(E(:,in),2)./sum(reference(:,in),2)));
end
in = frequency > band_edges(1) & frequency < band_edges(end);
fprintf('   %.2f\n',median(sqrt(sum(E(:,in),2)./sum(reference(:,in),2))));

end

function printBandMedian(name,values,frequency,band_edges)

fprintf('%-10s',name);
for b = 1:numel(band_edges)-1
    in = frequency >= band_edges(b) & frequency < band_edges(b+1);
    fprintf(' %9.2f',median(values(:,in),'all','omitnan'));
end
fprintf('\n');

end

function [t,x] = cleanSeries(t,x,limit)

% Seconds from the SBG hardware stamp; drop non-finite or out-of-range rows
% and repeated stamps.
t = double(t(:))/1e6;
x = double(x);
if isrow(x); x = x(:); end
ok = isfinite(t) & all(isfinite(x),2) & all(abs(x) < limit,2);
[t,unique_rows] = unique(t(ok));
x = x(ok,:);
x = x(unique_rows,:);

end

function [t0,t1] = longestRun(t)

% Start and end of the longest run without a gap over 0.5 s.
if isempty(t); t0 = Inf; t1 = -Inf; return; end
breaks = [0; find(diff(t) > 0.5); numel(t)];
[~,longest] = max(diff(breaks));
t0 = t(breaks(longest)+1);
t1 = t(breaks(longest+1));

end

function tf = hasSBGfields(loaded)

tf = isfield(loaded,'sbgData') && isfield(loaded.sbgData,'ImuData') && ...
    isfield(loaded.sbgData,'EkfEuler') && isfield(loaded.sbgData,'ShipMotion') && ...
    isfield(loaded.sbgData,'GpsVel') && isfield(loaded.sbgData,'UtcTime') && ...
    ~isempty(loaded.sbgData.UtcTime.year);

end
