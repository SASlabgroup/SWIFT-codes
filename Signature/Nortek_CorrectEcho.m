function N = Nortek_CorrectEcho(N,S)
% Nortek_CorrectEcho Correct echo (or Amp) fields of a Nortek ADCP (should work the same, right?)
%   Call: N = Nortek_CorrectEcho(N), where N is an Echo record structure 
%   Assumes salinity of 32, or can specify it as a second argument. 
%   Some parameters (most importantly, sound speed!) are hard-wired - check!

% Method: Gartner 2004, http://dx.doi.org/10.1016/j.margeo.2004.6.001
% (and the references therein)

% December 2106 ashcherbina@apl.uw.edu 

FREQUENCY = 1000;
SVEL0 = 1500; % I use fixed soundspeed (but could get it from the file)

if isfield(N,'Echo');
    v = 'Echo';
else
    v = 'Amp';
end

  

if nargin<2,
    S = 32;
    fprintf('Using default S=%.1f\n',S(1));
end
if ~isfield (N,'Temperature')
    T = 15;
    fprintf('Using default T=%.1f\n',T(1));
else
    T = nanmean(N.Temperature);
end
P = nanmean(N.Pressure);
%%
E = N.(v);
sz = size(E);
if size(E,3)==4,
    BEAM_ANGLE = 25; % assume slanted beam
else
    BEAM_ANGLE = 0; % assume vertical beam
end

% remove background noise level (per beam)
% This is non-trivial...
% cf. http://icesjms.oxfordjournals.org/content/64/6/1282.full.pdf+html
% We can do it, but...
% a) we'd have to use linear (not dB) scale 
% b) interpretation?
% So skip for now (and accept the "tail" amplification)
% 
% E0l = 400; % linear noise, = 10.^(E0/10)
% El = 10.^(E/10)-E0l; % do not convert to dB!


% Sound speed range correction
svel = sw_svel(S,T,P);
r = svel./SVEL0;
bz = N.Range*r;

% 2-way transmission loss
% absorption coeff:
% (ideally, we'd want to accoount for depth/time variation of alpha, but can't
% do it untill the mapping stage. So for now, use the *typical* alpha at the instrument.
alpha = absorption(S,T,P,FREQUENCY);

% near-field correction (a-la Gartner 2004)
d = 0.035; % transducer diamerter
FREQUENCY = 1000;
lambda = mean(svel)/(FREQUENCY*1e3); % wavelength
% Rcrit = pi*(d/2)^2/lambda;% m, critical near-field range (a.k.a. Rayleigh Distance) (Gartner 2004, http://dx.doi.org/10.1016/j.margeo.2004.07.001)
Rcrit = 0.44; % empirical

% slant range
% "The [RDI] BBADCP samples the echo intensity in the last quarter of each depth
% cell, not the center. The term D/4 accounts for this." (Deines, 1999:Deines, K.L., 1999, Backscatter estimation using broadband acoustic Doppler current profilers in Oceans 99 MTS/IEEE Conference Proceedings, September 13–16, 1999, Seattle, Wash.)
% How is this done with Nortek? For now, assume co-located sampling. 
% R = (bz+ fd.bin_length/4) / cos(fd.beam_angle*pi/180) ;

R = bz / cos(BEAM_ANGLE*pi/180) ;
Rn = R/Rcrit;
f = 1.35*Rn+(2.5*Rn).^3.2;
Psi =(1+f)./f;

%
TL = 20*log10(R.*Psi)+2*alpha.*R; % on dB scale
N.(v) = E + TL; % relative backscatter



%%%
function Alpha = absorption(S,T,D,f)
% seawater sound absorption coefficient (alpha), in db/m
% Adapted from http://resource.npl.co.uk/acoustics/techguides/seaabsorption/
% 	 f frequency (kHz)
% 	 T Temperature (degC)
% 	 S Salinity (ppt)
% 	 D Depth (m)
% 	 pH Acidity = 8(fixed here)

% Francois R. E., Garrison G. R., "Sound absorption based on ocean measurements: Part I:Pure water and magnesium sulfate contributions", Journal of the Acoustical Society of America, 72(3), 896-907, 1982.
% Francois R. E., Garrison G. R., "Sound absorption based on ocean measurements: Part II:Boric acid contribution and equation for total absorption", Journal of the Acoustical Society of America, 72(6), 1879-1890, 1982.

% 	 Total absorption = Boric Acid Contrib. + Magnesium Sulphate Contrib. + Pure Water Contrib.

pH = 8;
T_kel = 273 + T;
% Calculate speed of sound (according to Francois & Garrison, JASA 72 (6) p1886)
c = 1412 + 3.21*T + 1.19*S + 0.0167*D;

% Boric acid contribution
A1 = (8.86 ./ c ) .* 10.^(0.78 * pH - 5);
P1 = 1;
f1 = 2.8 * sqrt(S / 35) .* 10.^(4 - 1245 ./ T_kel);
Boric = (A1 .* P1 .* f1 .* f.*f)./(f.*f + f1.*f1);

% 	MgSO4 contribution
A2 = 21.44 * (S ./ c) .* (1 + 0.025 * T);
P2 = 1 - 1.37e-4 * D + 6.2e-9* D.*D;
f2 = (8.17 .* 10.^(8 - 1990./T_kel))./(1 + 0.0018 * (S - 35));
MgSO4 = (A2 .* P2 .* f2 * f.*f)./(f.*f + f2.*f2);

% 	 Pure water contribution
A3 = T*nan;
i1 = (T <= 20);
A3(i1)  = 4.937e-4 - 2.59e-5  * T(i1)  + 9.11e-7 * T(i1).*T(i1)   - 1.50e-8*T(i1).*T(i1).*T(i1);
A3(~i1) = 3.964e-4 - 1.146e-5 * T(~i1) + 1.45e-7 * T(~i1).*T(~i1) - 6.50e-10*T(~i1).*T(~i1).*T(~i1);

P3 = 1 - 3.83e-5 * D + 4.9e-10* D.*D;
H2O = A3 .* P3 .* f.*f;

% 	 Total absorption
Alpha = Boric + MgSO4 + H2O;

Alpha = Alpha/1e3 ; % dB/m
