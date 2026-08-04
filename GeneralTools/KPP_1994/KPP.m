function [KM KT KS ghatu ghatv ghatt ghats hbl D] = kpp(U,V,T,S,ZZ,ZP,WUSURF,WVSURF,WTSURF,WSSURF,SWRD,COR,hbl,r1,amu1,r2,amu2,imod)

%USAGE:  [KM KT KS ghatu ghatv ghatt ghats hbl D] = kpp(U,V,T,S,ZZ,ZP,WUSURF,WVSURF,WTSURF,WSSURF,SWRD,COR,hbl,r1,amu1,r2,amu2,imod)
%
%   Subroutine to implement the KPP turbulence closure for use in 1d models 
%   of the upper ocean. The method is described in Smyth et al. (2002).
%   A previous version by McWilliams and Sullivan (2000) and the original by 
%   Large et al. (1994) are included as options.
%
%   REQUIRED INPUTS:
%   U(KB),V(KB),T(KB),S(KB): Real vectors quantifying profiles of zonal and
%            meridional velocity, temperature and salinity, resp.
%   ZZ(KB): depths at which U,V,T,S are computed. ZZ is assumed to be in
%            meters, and <0, with ZZ=0 at the surface.
%   ZP(KB): depths at which km,kt,ks,ghatu,ghatv,ghatt,ghats are computed.
%            ZP is assumed to be in meters, and <0, with ZP=0 at the surface.
%   WUSURF, WVSURF: Zonal and meridional components of the surface momentum
%            flux.
%   WTSURF: Surface temperature flux, NOT including solar radiation.
%   WSSURF: Equivalent surface salinity flux.
%   SWRD: Surface temperature flux carried by solar radiation.
%
%   OPTIONAL INPUTS:
%   COR: Coriolis parameter f, default zero.
%   hbl: Initial guess at boundary layer depth, >0, in meters. Set hbl to zero
%            on the first call. Default 10.
%   r1,amu1,r2,amu2: Constants used in Paulson & Simpson's (1977, JPO 7)
%      penetrative solar flux profile: f(z) = r1*exp(z/amu1) + r2*exp(z/amu2).
%      Default Jerlov Ib.
%   imod: Model version = 0  Large et al. (1994),
%                         1  McWilliams & Sullivan (2000),
%                         2  Smyth et al. (2002), the default.
%
%   AVAILABLE OUTPUTS:
%   KM,KT,KS: Turbulent diffusivities of momentum, temperature and salinity.
%   ghatu,ghatv,ghatt,ghats: Nonlocal transports (equivalent to additional
%      gradients) of zonal and meridional velocity, temperature and salinity.
%   hbl: Computed value of the boundary layer depth. Save this value to input
%        in the next call.
%   D: structure containing further diagnostics that you probably don't need.
%
%   * Modified from 3D version by H. Wijesekera and W.D. Smyth, 2000.
%   * Modified from Fortran version by W.D. Smyth, 2011.
%   * I don't know where the 3D Fortran version came from. If you do, please
%   let me know.
%   * If you use this routine in published research, please reference Smyth
%   et al. (2002) for the method.
%
%   Bill Smyth: smyth@coas.oregonstate.edu
%
%   ....................................................................
%   References:
%     Large, W.G., J.C. McWilliams and S.C. Doney, 1994, [LMD] "Oceanic
%        vertical mixing: A review and a model with a nonlocal boundary
%        layer parameterization", Reviews of Geophysics, Vol. 32 (4)
%        363-403.
%     McWilliams J. and Sullivan P., 2000, [SM] "Vertical mixing by Langmuir
%        circulations." Spill Sci. Technol. Bull. 6, 225–237
%     Smyth, W.D., E.D. Skyllingstad, G.B. Crawford and H. Wijesekera,
%        2002, [SSMC] "Nonlocal fluxes and Stokes drift effects in the
%        K-profile parameterization", Ocean Dynamics 52 (3), 104-115.


%% default parameter choices
if nargin<18    % default  
    imod=2;
end
if imod>2
    disp('model not available')
    stop
end
if nargin <14   %default Jerlov Ib parameters
    amu1=1.0;
    amu2=17;
    r1=0.67;
    r2=1-r1;
end
D.amu1=amu1;D.amu2=amu2;D.r1=r1;D.r2=r2;
if nargin < 13
    hbl=10;
end
if nargin < 12
    COR=0;
end

hbl0=hbl;
D.COR=COR;

%%   ML depth
% compute sigma-t from T and S
sigma = sigmat(S,T); % MKS units
sig0=(sigma(1)+sigma(2))/2+.01;
dml=max(ZZ(sigma>=sig0));
if hbl==0;
    hbl=abs(dml);
else
    hbl=(hbl0+abs(dml))/2;  % initial guess closer to dml
end
D.dml=dml;

%% KPP model constants
KB=length(U);KBM1=KB-1;

% Numerical constants used in similarity flux-profiles; LMD page 392
% am,as,cm,cs are determined by continuity

zetas = -1.0;
zetam = -0.2;
cs    = 24.*(1.-16.*zetas)^(.50);
cm    = 12.*(1.-16.*zetam)^(-.25);
as    = cs*zetas+(1.-16.*zetas)^(1.50);
am    = cm*zetam+(1.-16.*zetam)^(.75);

vonKar = 0.4; % Von Karman constant
tiny = 1.e-20; % numerical constant to avoid devide by zero
gravity=9.81; % accleration due to gravity in m/s^2

% diagnostics
D.zetas=zetas;D.zetam=zetam;
D.cs=cs;D.cm=cm;D.as=as;D.am=am;
D.vonKar=vonKar;D.gravity=gravity;

% Constants used in defining BL depth
Cv  = 1.5; % LMD
if imod==2 % SSCW
    Cv=1.0;
end

Ric = 0.30; %LMD p. 377
D.Cv=Cv;D.Ric=Ric;

betaT = -0.20;
epsilon = 0.1;
hbl_max=200;
D.betaT=betaT;D.epsilon=epsilon;D.hbl_max=hbl_max;

% Constants used in Ri parameterization of deep turbulence (LMD 28, 29, p. 373)
Ri0    = 0.7;
anu0   = 50.e-4;
anum   = 1.0e-4;
anut   = 0.1e-4;
D.Ri0=Ri0;D.anu0=anu0;D.anum=anum;D.anut=anut;


% Constants used in nonlocal fluxes (LMD p. 371).
% In LMD, Cg_m=0. Cg_s=10 (Just someone else's guess.)

C_s = 10.; % LMD
C_m =0.0; % LMD
if imod==2 % SSCW
    C_s = 5.0 ;
    C_m = 3.0;
end
Cg_s=  C_s*vonKar*(cs*vonKar*epsilon)^(1/3.);
Cg_m=  C_m*vonKar*(cm*vonKar*epsilon)^(1/3.);

D.C_s=C_s;D.C_m=C_m;D.Cg_s=Cg_s;D.Cg_m=Cg_m;
% Constants for Stokes drift parameterization (MS01).
% In LMD, Cg_Stokes=0; in Skyllingstad et al Cg_Stokes=11.5.

Cg_Stokes=0;
if imod==1
    Cg_Stokes=11.5*.4;
end
if imod==2;
    Cg_Stokes=11.5*.4*.7;
end
Lam_Stokes=30.;
m_Stokes=4.*pi/Lam_Stokes;
D.Cg_Stokes=Cg_Stokes;D.Lam_Stokes=Lam_Stokes;D.m_Stokes=m_Stokes;

% Constants for Langmuir cell parameterization.
% In MS00, Cw_m=Cw_s=0.08. In LMD, Cw_m=Cw_s=0.
La=.3;
nms=2;
xce=2;
D.La=La;D.nms=nms;D.xce=xce;

Cw_m=0;   % LMD
if imod==1  % MS
    Cw_m=0.08;
end
if imod==2 % SSCW
    Cw_m=.15;
end
Cw_s=Cw_m;
D.Cw_m=Cw_m;D.Cw_s=Cw_s;

%...Roughness length z0<=0
z0=-2.  *.5 *0;
D.z0=z0;


%% initial constants
% Velocity Scale of Turbulence (in m/s)
Vtc = Cv*sqrt(-betaT)/(sqrt(cs*epsilon)*Ric*vonKar*vonKar);
D.Vtc=Vtc;

% Surface Layer Depth: 10% of the OBL (in m/s)
% (both hbl and sl_depth are defined as postive quantities)

% Initial value:
sl_depth = epsilon*hbl  ;
% Surface Friction Velocity (WUSURF and WVSURF are in m^2/s^2)
ustar = sqrt(sqrt(WVSURF^2+WUSURF^2));
ustar2=ustar^2;
ustar3=ustar^3;
ustar4=ustar^4;

% BoNet = net sfc buoyancy flux MINUS SHORTWAVE% (in m^2/s^3)
% BoSol buoyancy flux carried by shortwave radiation
%     WTSURF>0 for cooling, and WTSURF< 0 for heating
alpha=sw_alpha(S(1),T(1),0);
beta=sw_beta(S(1),T(1),0);
BoNet = gravity*(alpha*WTSURF-beta*WSSURF);
BoSol = gravity*alpha*SWRD;


%% Ri, Interior KM, KS

%...
%.....Compute diffusivities based on local gradient Ri:
%.....First Compute Ri and bvf2
%.....Compute gradient Richardson number Rig (uniform grid is assumed)
%.....If a staggered grid is used, bvf2,dudz,dvdz and Rig are computed on ZP.
bvf2=0*T;
dudz=0*U;
dvdz=0*V;
if ZP(1) ~= ZZ(1)
    bvf2(2:end)=-(gravity/1030)*(sigma(1:end-1)-sigma(2:end))./(ZZ(1:end-1)-ZZ(2:end));
    dudz(2:end) = (U(1:end-1)-U(2:end))./(ZZ(1:end-1)-ZZ(2:end));
    dvdz(2:end) = (V(1:end-1)-V(2:end))./(ZZ(1:end-1)-ZZ(2:end));
    bvf2(1)=bvf2(2);
    dudz(1)=dudz(2);dvdz(1)=dvdz(2);
else
    bvf2(2:end-1)=-(gravity/1030)*(sigma(1:end-2)-sigma(3:end))./(ZZ(1:end-2)-ZZ(3:end));
    dudz(2:end-1) = (U(1:end-2)-U(3:end))./(ZZ(1:end-2)-ZZ(3:end));
    dvdz(2:end-1) = (V(1:end-2)-V(3:end))./(ZZ(1:end-2)-ZZ(3:end));
    bvf2(1)=-(gravity/1030)*(sigma(1)-sigma(2))./(ZZ(1)-ZZ(2));
    dudz(1) = (U(1)-U(2))/(ZZ(1)-ZZ(2));
    dvdz(1) = (V(1)-V(2))/(ZZ(1)-ZZ(2));
    bvf2(end)=-(gravity/1030)*(sigma(end-1)-sigma(end))./(ZZ(end-1)-ZZ(end));
    dudz(end) = (U(end-1)-U(end))./(ZZ(end-1)-ZZ(end));
    dvdz(end) = (V(end-1)-V(end))./(ZZ(end-1)-ZZ(end));
end
shear2 = dudz.^2+dvdz.^2;
%
%   Smooth squared buoyancy frequency and shear before dividing?
%
nsmooth=0;
if nsmooth>=1;
    bvf2 = smooth(bvf2,nsmooth);
    shear2 = smooth(shear2,nsmooth);
end
% gradient Richardson number
Rig=bvf2./(shear2+tiny);

% Compute KM and KH based Large et al's Ri-based scheme.
% Effects of Double diffusive convection and salt-fingering are neglected.

fRi=ones(size(Rig));
fRi(Rig>0 & Rig<Ri0) = ( 1 - (Rig(Rig>0 & Rig<Ri0)./Ri0).^2).^3;
fRi(Rig>0 & Rig>=Ri0) = 0;

fRi=smooth(fRi,1);
anusx=anu0.*fRi;

% add background (IGW) diffusivities
KM = anusx + anum;
KH = anusx + anut;



%% bulk Ri, hbl

% Compute bulk Richardson number "Rib" and then find the depth
% of the surface OBL "hbl", such that Rib(hlb)=Ric. Unlike Rig, Rib is computed on ZZ.
% Note:Surface and bottom flux BC are defined at Z=0 and Z=-D
% This iteration scheme doesn't work well
sl_depth0=epsilon*hbl;
niter=0;
kbl=find(-ZP > hbl,1,'first');

maxiter=10;
while niter < maxiter
    niter=niter+1;
    
    sl_depth = .5*(epsilon*hbl+sl_depth0); %update sl_depth based on input value of hbl
    
    % mean values in surface layer ZZ<-sl_depth
    ksl = find(-ZZ>sl_depth,1);
    Z_top=mean(ZZ(1:ksl));
    U_top=mean(U(1:ksl));
    V_top=mean(V(1:ksl));
    T_top=mean(T(1:ksl));
    S_top=mean(S(1:ksl));
    SIG_top=mean(sigma(1:ksl)); % MKS
    
    for k=ksl+1:KBM1
        %.....Compute Solar flux Penetration
        swrdzz = r1*exp(ZZ(k)/amu1) + r2*exp(ZZ(k)/amu2);
        %.....Compute buoyancy flux at a "k" depth level
        %.....Bfsfc = surface buoyancy flux m^2/s^3
        %.....Bfsfc<0: stable forcing;
        %.....Bfsfc>0: unstable forcing.
        Bfsfc = BoNet+BoSol*(1.0-swrdzz);
        %
        %    Convective velocity scale
        %
        wstar=0.;
        if Bfsfc > 0.
            wstar=(Bfsfc*hbl)^(1./3.);
        end
        stab_lc=(ustar3/(ustar3+0.6*wstar^3))^xce;
        %......
        %.....Define the (non-)dimensional vertical co-ordinate, ---zlmd
        %.................................identical to gamma (sigma?) in LMD
        %.................................but not normalized
        %......Note: sl_depth is positive and ZZ(k) is negative;
        %.....
        %.....Compute scales of turbulent velocity based on similarity theory.
        %.....w_m for momentum, and w_s for scalars
        
        zeta  = vonKar*max(ZZ(k),-sl_depth)*Bfsfc/(ustar3+tiny);
        phis = phi_s(zeta,zetas,as,cs);
        w_s = vonKar*ustar/phis   *(1.+stab_lc*Cw_s/La^(2*nms))^(1./nms);
        
        %.....
        %.....Compute the Bulk Ri: Rib.....................................
        %.....Also compute boundary layer depth, hbl, at which Rib=Ric
        delU = U_top-U(k);
        delV = V_top-V(k);
        bvtop = -(gravity/1030)*(SIG_top-sigma(k))*(Z_top-ZZ(k));
        dV2  = delU*delU + delV*delV;
        bvf2_1 = -(gravity/1030)*(sigma(k-1)-sigma(k+1))/(ZZ(k-1)-ZZ(k+1)); % STAGGERED? BS
        dVt2 = Vtc*(-ZZ(k))*w_s*sqrt(abs(bvf2_1));
        Rib(k) = bvtop/(dV2+dVt2+tiny);
    end
    Rib(KB)=Rib(KBM1);Rib=Rib';
    
    hblt=-ZZ(find(Rib>=Ric,1,'first'));
    hblb=-ZZ(find(Rib<Ric,1,'last'));
    if ~isempty(hblb) & ~isempty(hblt);
        hbl = (hblb+hblt)/2;
    elseif ~isempty(hblb)
        hbl=hblb;
    elseif ~isempty(hblt)
        hbl=hblt;
    end
    
    %....Compute other surface layer depths; Ekman and M-O, and
    %....compare with hbl, and get a reasonable mixed layer depth.
    %....During stable conditions, Bfsfc<0, hbl<hmonob
    
    %.....Compute Bfsfc at hbl
    swrdhbl=r1*exp(-hbl/amu1) + r2*exp(-hbl/amu2);
    Bfsfc=BoNet+BoSol*(1.0-swrdhbl);
    
    %.....Compare with other length scales
    cekman = 0.7;
    cmonob = 1.0 ;
    if Bfsfc <0
        hekman = cekman*ustar/max(abs(COR),tiny);
        hmonob = -cmonob*ustar3/(vonKar*(Bfsfc-tiny)); %!!!
        hlimit = min(hekman,hmonob);
        hbl = min(hbl,hlimit);
        hbl = max(hbl,abs(ZZ(1))); %minimum bl depth
        hbl = min(hbl,abs(ZZ(KB)));
    end
    
    %.....Set new boundary layer index kbl just below the hbl
    if isempty(hbl)
        hbl=1;
    end
    kbl=find(-ZP > hbl,1,'first');
    sl_depth0=sl_depth;
    
    if abs(sl_depth-epsilon*hbl)<.25
        break
    end
end

% Evaluate various quantities at the "final" boundary layer base.

swrdhbl=r1*exp(-abs(hbl)/amu1) + r2*exp(-abs(hbl)/amu2);
Bfsfc=BoNet+BoSol*(1.0-swrdhbl); % Net heat flux into the boundary layer

% Convective velocity scale
wstar=0.;
if Bfsfc > 0
    wstar=(Bfsfc*hbl)^(1/3);
end
stab_lc=(ustar3/(ustar3+0.6*wstar^3))^xce;

% Compute turbulent velocity scales (w_m,w_s) at hbl
%hw:  for stable heat flux; zlmd=hbl;
%hw:  for unstable heat flux: zlmd=epsilon*hbl

if Bfsfc >= 0
    zlmd=hbl*epsilon;
else
    zlmd=hbl;
end

zetapar  = -vonKar*zlmd*Bfsfc/(ustar3+tiny);
phim = phi_m(zetapar,zetam,am,cm);
w_m = vonKar*ustar/phim  *(1.+stab_lc*Cw_m/La^(2*nms))^(1./nms);
phis = phi_s(zetapar,zetas,as,cs);
w_s = vonKar*ustar/phis  *(1.+stab_lc*Cw_s/La^(2*nms))^(1./nms);

%%% if hbl is too deep, output diagnostics and quit
if hbl>hbl_max
    idiag=1;
    fign=103;
    figure(fign);clf
    subplot(2,3,1)
    plot(bvf2,ZZ,shear2,ZZ)
    ylim([-120 0])
    legend('bvf2','shear2')
    ylabel('Z')
    subplot(2,3,2)
    semilogx(Rig,ZZ)
    ylim([-120 0])
    xlabel('Rig')
    hold on
    semilogx(Ri0*[1 1],ylim,'k')
    subplot(2,3,3)
    semilogx(KM,ZZ,'b',KH,ZZ,'r','linewidth',2)
    ylim([-120 0])
    xlim([1e-7 1])
    legend('KM','KH')
    KM0=KM;
    KH0=KH;
    stop
end

%% Shape functions and derivatives at hbl
% Compute diffusivities and derivatives for later use in the nondimensional
%  shape function. See LMD equation (18) and accompanying text.
if Bfsfc >= 0
    f1=0.;
else
    f1=-5.0*Bfsfc*vonKar/(ustar4+tiny);
end

% Interpolate Km, Ks among grid points surrounding hbl, compute G and derivative
% See LMD equations (D5a,b) and accompanying text.
if hbl < abs(ZZ(KBM1))
    k=kbl;
    cff_up =  (-hbl-ZP(k)) / ( (ZP(k-1)-ZP(k)) * (ZP(k-1)-ZP(k)) );
    cff_dn = (hbl+ZP(k-1)) / ( (ZP(k-1)-ZP(k)) * (ZP(k)-ZP(k+1)) );
    %.......
    %......Momentum
    KMp = cff_up*max(0.0,KM(k-1)-KM(k)) + cff_dn*max(0.0,KM(k)-KM(k+1));
    KMh = KM(k) + KMp*(-ZP(k)-hbl);
    Gm1 = KMh/(hbl*w_m+tiny) ;
    dGm1ds = min(0.0,KMh*f1-KMp/(w_m+tiny));
    % Scalar fields (assume same shape function for salinity and temperature)
    KHp = cff_up*max(0.0,KH(k-1)-KH(k)) + cff_dn*max(0.0,KH(k)-KH(k+1));
    KHh = KH(k) + KHp*(-ZP(k)-hbl);
    Gt1 = KHh/(hbl*w_s+tiny) ;
    dGt1ds = min(0.0,KHh*f1-KHp/(w_s+tiny));
else
    disp('KPP failed to find hbl')
    stop
end
% Note: The modified diffusivity (LMD's equation D6) is not applied in this
% version.

%% mixing coefficients and nonlocal fluxes within the boundary layer.

%   Bulk differentials
kbl=min([kbl length(U)]); %KLUGE
delU=U_top-U(kbl);
delV=V_top-V(kbl);
delT=T_top-T(kbl);
delS=S_top-S(kbl);

%   dvec_(x,y) is the direction vector for the nonlocal flux.
%	dvec_x=delU/sqrt(delU**2+delV**2)
%	dvec_y=delV/sqrt(delU**2+delV**2)
dvec_x=-WUSURF/ustar2;
dvec_y=-WVSURF/ustar2;

%   stab_nlm determines the effect of stability on the nonlocal
%   momentum flux. Frech & Mahrt (1995) say stab_nlm=1.0+wstar/ustar;
%   Brown & Grant (1998) say stab_nlm=2.7*wstar**3/(ustar3+0.6*wstar**3).
%	stab_nlm=1.0+wstar/ustar
stab_nlm=2.7*wstar^3/(ustar3+0.6*wstar^3);

% Compute mixing coefficients and nonlocal fluxes within the boundary layer.
ghatu=0*U;
ghatv=0*V;
ghatt=0*T;
ghats=0*S;

% Constants for shape functions as per LMD (17)
a2_m = -2.0+3.0*Gm1-dGm1ds;
a3_m = 1.0-2.0*Gm1+dGm1ds;
a2_s = -2.0+3.0*Gt1-dGt1ds;
a3_s = 1.0-2.0*Gt1+dGt1ds;

% loop over boundary layer
for k=2:kbl-1
    sl_depth = hbl*epsilon;
    % Velocity scales
    zetapar  = -vonKar*abs(ZP(k))*Bfsfc/(ustar3+tiny);
    zetapar0  = -vonKar*sl_depth*Bfsfc/(ustar3+tiny);
    zeta=max(zetapar0,zetapar);
    phim = phi_m(zeta,zetam,am,cm);
    phis = phi_s(zeta,zetas,as,cs);
    if ZP(k) > z0
        zeta0 = -vonKar*abs(z0)*Bfsfc/(ustar3+tiny);
        phim = phi_m(zeta0,zetam,am,cm);
        phim = phi_s(zeta,zetas,as,cs);
        phim=phim*abs(ZP(k)/z0) /100.;
        phis=phis*abs(ZP(k)/z0) /100.;
    end
    w_m = vonKar*ustar/phim;
    w_s = vonKar*ustar/phis;
    
    %  Add McWilliams&Sullivan LC parameterization only in stable conditions.
    w_m = w_m *(1.+stab_lc*Cw_m/La^(2*nms))^(1./nms);
    w_s = w_s *(1.+stab_lc*Cw_s/La^(2*nms))^(1./nms);
    
    % Shape functions LMD (11) with a0=0, a1=1 as per discussion on p. 370,371
    sigx = -ZP(k)/(hbl+tiny);
    Gm = sigx*(1.0+a2_m*sigx+a3_m*sigx^2);
    Gs = sigx*(1.0+a2_s*sigx+a3_s*sigx^2);
    %
    % LMD (10)
    %
    KM(k) = hbl*w_m*Gm;
    KH(k) = hbl*w_s*Gs;
    
    % Nonlocal terms (LMD 19,20,A4, 28, 29, p. 373)
    % The first factor is the net flux into the layer above zp(k).
    % The momentum term is parallel to the bulk shear across the OBL,
    % as per Brown & Grant and Frecht & Mahrt.
    
    %  LMD set ghatt proportional to wtsurf+swrd*(1.0-swrdzdepth)*f,
    %  where swrdzdepth=r1*exp(ZP(k)/amu1) + r2*exp(ZP(k)/amu2), but
    %  then decide that f should be zero.
    if Bfsfc >= 0
        ghatt(k)=WTSURF*Cg_s/(w_s*hbl+tiny);
        ghats(k)=WSSURF*Cg_s/(w_s*hbl+tiny);
    else
        ghatt(k)=0.;
        ghats(k)=0.;
    end
    ghatu(k)=-Cg_m*ustar2*stab_nlm*dvec_x/(w_m*hbl+tiny);
    ghatv(k)=-Cg_m*ustar2*stab_nlm*dvec_y/(w_m*hbl+tiny);
    
    %  Add the shear of the Stokes drift to the nonlocal term
    ghatu(k)=ghatu(k)-(-WUSURF/(ustar2+tiny))*Cg_Stokes*ustar*m_Stokes*exp(m_Stokes*ZP(k));
    ghatv(k)=ghatv(k)-(-WVSURF/(ustar2+tiny))*Cg_Stokes*ustar*m_Stokes*exp(m_Stokes*ZP(k));
    
end

% KT and KS both equal KH
KT=KH;
KS=KH;


end

%% subroutine sigmat
function [RHOO] = sigmat(SI,TI)
%         THIS SUBROUTINE COMPUTES DENSITY- 1.025
%         T = POTENTIAL TEMPERATURE
%    ( See: Mellor, 1991, J. Atmos. Oceanic Tech., 609-611)
%
TR=TI;
SR=SI;
TR2=TR.*TR;
TR3=TR2.*TR;
TR4=TR3.*TR;
TR5=TR4.*TR;
%   Approximate pressure in units of bars
% set pressure field to zero to compute sigma_t
% hw      P=-9.81*1.025*ZZ(K)*0.01
P=0.0;
%
RHOR = 999.842594 + 6.793952E-2*TR ...
    - 9.095290E-3*TR2 + 1.001685E-4*TR3 ...
    - 1.120083E-6*TR4 + 6.536332E-9*TR4;

RHOR = RHOR + (0.824493 - 4.0899E-3*TR ...
    + 7.6438E-5*TR2 - 8.2467E-7*TR3 ...
    + 5.3875E-9*TR4) .* SR ...
    + (-5.72466E-3 + 1.0227E-4*TR ...
    - 1.6546E-6*TR2) .* abs(SR).^1.5 ...
    + 4.8314E-4 .* SR.*SR;

CR=1449.1+.0821*P+4.55*TR-.045*TR2 ...
    +1.34*(SR-35.);
RHOR=RHOR + 1.E5*P./(CR.*CR).*(1.-2.*P./(CR.*CR));
RHOO=RHOR-1000;

end


%% subroutine phi_m
%
function phi = phi_m(zeta,zetam,a,c)
%
%   Calculate vertical structure function for momentum as in LMD Appendix B.
%....stable boundary layer
if zeta >=0
    phi = 1.0+5.*zeta;
    %......
    %.....Unstable region
else
    if  zeta > zetam
        phi = (1.0-16.*zeta).^(-1./4.);
    else
        phi = (a-c*zeta).^(-1./3.);
    end
end
return
end

%% subroutine phi_s
function phi = phi_s(zeta,zetas,a,c)
%
%   Calculate vertical structure function for scalar as in LMD Appendix B.
%.....stable boundary layer
if zeta >= 0.0 ;
    phi = 1.0+5.*zeta;
    %......
    %.....Unstable region
else
    if zeta > zetas
        phi = (1.0-16.*zeta).^(-1./2.);
    else
        phi = (a-c*zeta).^(-1./3.);
    end
end
return
end

%% subroutine smooth
function [xs] = smooth(x,f)
%   SMOOTH
%   Apply simple binomial smoothing to the vector x. 
%   (For now, x is assumed to be a column vector!)
%
%   The optional second argument is the smoothing factor f.
%      f=1: full smoothing (the default);
%      f=0: no smoothing.
%      f>1: repeat smoothing floor(f) times;
%
%   Endpoints are not altered.
%
%   Example: If x=[1 4 9 16 25]',
%      then smooth(x) = smooth(x,1) = [1.0 4.5 9.5 16.5 25.0]';
%           smooth(x,.5) = [1.0 4.25 9.25 16.25 25.0]'
%
s=size(x);
nx=s(1);
%
% Determine smothing factor (make sure it's <=1)
%
if nargin>=2
   ff=f;
else
   ff=1;
end

if ff<=1;
    % Smooth data
    xs(1,:)=x(1,:);
    for i=2:nx-1
        xs(i,:)=(1-.5*ff)*x(i,:)+.25*ff*(x(i-1,:)+x(i+1,:));
    end
    xs(nx,:)=x(nx,:);
    
else
    for j=1:floor(ff)
        xs(1,:)=x(1,:);
        for i=2:nx-1
            xs(i,:)=.5*x(i,:)+.25*(x(i-1,:)+x(i+1,:));
        end
        xs(nx,:)=x(nx,:);
        x=xs;
    end
end

% s=size(x);
% if s(1)>s(2);xs=xs';end
return
end