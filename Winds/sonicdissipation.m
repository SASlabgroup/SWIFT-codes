function [eps,ustar,ps,cs,f,uadv,thetaH,iso,power] = sonicdissipation(u,v,w,temp,fs,twin,z)

%%% Rotate to get streamwise + cross-stream velocities

% Rotate horizontally into downstream direction
thetaH = atan2d(mean(v,'omitnan'),mean(u,'omitnan'));
RH = [cosd(thetaH), -sind(thetaH);...
    sind(thetaH), cosd(thetaH)];
uv_rot = RH'*([u(:)'; v(:)']);
u_rot = uv_rot(1,:);
v_rot = uv_rot(2,:);

% Rotate vertically into tilt direction
thetaV = atan2d(mean(w,'omitnan'),mean(u_rot,'omitnan'));
RV = [cosd(thetaV), -sind(thetaV);...
    sind(thetaV), cosd(thetaV)];
uw_rot = RV'*([u_rot(:)'; w(:)']);
u_rot = uw_rot(1,:);
w_rot = uw_rot(2,:);

uadv = mean(u_rot,'omitnan');

%%% Convert direction to oceanographic convention
thetaH = -thetaH + 90;
if thetaH < 0
    thetaH = thetaH + 360;
end

% Spectra
nwin = floor(twin.*fs);
norm = 'par';
[UU,f,~,~,~] = hannwinPSD2(u_rot,nwin,fs,norm);
[VV,~,~,~,~] = hannwinPSD2(v_rot,nwin,fs,norm);
[WW,~,~,~,~] = hannwinPSD2(w_rot,nwin,fs,norm);
[TT,~,~,~,~] = hannwinPSD2(temp,nwin,fs,norm);

% Cospectra
[UW,~,~] = hannwinCOPSD2(u_rot,w_rot,nwin,fs,norm);
[VW,~,~] = hannwinCOPSD2(v_rot,w_rot,nwin,fs,norm);
[TW,~,~] = hannwinCOPSD2(temp,w_rot,nwin,fs,norm);

% Dissipation Rate and Friction Velocity
K = 0.55;
k = 0.41;
isr = f>= 1.5 & f<=4;

EUisr = mean(UU(isr).*f(isr).^(5/3),2,'omitnan');
EVisr = mean(VV(:,isr).*f(isr).^(5/3),2,'omitnan');
EWisr = mean(WW(:,isr).*f(isr).^(5/3),2,'omitnan');

iso.v = EVisr./EUisr;
iso.w = EWisr./EUisr;

eps.u = (EUisr./K).^(3/2).*(2*pi./uadv);
eps.v = ((3/4)*EVisr./K).^(3/2).*(2*pi./uadv);
eps.w = ((3/4)*EWisr./K).^(3/2).*(2*pi./uadv);

ustar.u = (k.*z.*eps.u).^(1/3);
ustar.v = (k.*z.*eps.v).^(1/3);
ustar.w = (k.*z.*eps.w).^(1/3);

% Best-fit power-law to inertial subrange
[~,mu,bu,~] = fitline(log10(f(isr)),log10(UU(isr)));
[~,mv,bv,~] = fitline(log10(f(isr)),log10(VV(isr)));
[~,mw,bw,~] = fitline(log10(f(isr)),log10(WW(isr)));
power.u = mu;
power.v = mv;
power.w = mw;  
power.uint = bu;
power.vint = bv;
power.wint = bw;

% Save Spectra
ps.UU = UU;
ps.VV = VV;
ps.WW = WW;
ps.TT = TT;

cs.UW = UW;
cs.VW = VW;
cs.TW = TW;

end