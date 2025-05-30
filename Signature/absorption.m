function alpha = absorption(S,T,D,f)

% seawater sound absorption coefficient (alpha), in dB/m
% Adapted from http://resource.npl.co.uk/acoustics/techguides/seaabsorption/

% 	 f frequency (kHz)
% 	 T Temperature (degC)
% 	 S Salinity (ppt)
% 	 D Depth (m)
% 	 pH Acidity = 8(fixed here)

% Francois R. E., Garrison G. R., "Sound absorption based on ocean measurements: Part I:Pure water and magnesium sulfate contributions", Journal of the Acoustical Society of America, 72(3), 896-907, 1982.
% Francois R. E., Garrison G. R., "Sound absorption based on ocean measurements: Part II:Boric acid contribution and equation for total absorption", Journal of the Acoustical Society of America, 72(6), 1879-1890, 1982.

% Total absorption = Boric Acid Contrib. + Magnesium Sulphate Contrib. + Pure Water Contrib.

pH = 8;
T_kel = 273 + T;
% Calculate speed of sound (according to Francois & Garrison, JASA 72 (6) p1886)
% c = 1412 + 3.21*T + 1.19*S + 0.0167*D;
c = sw_svel(S,T,D);

% Boric acid contribution
A1 = (8.86 ./ c ) .* 10.^(0.78 * pH - 5);
P1 = 1;
f1 = 2.8 * sqrt(S / 35) .* 10.^(4 - 1245 ./ T_kel);
Boric = (A1 .* P1 .* f1 .* f.*f)./(f.*f + f1.*f1);

% MgSO4 contribution
A2 = 21.44 * (S ./ c) .* (1 + 0.025 * T);
P2 = 1 - 1.37e-4 * D + 6.2e-9* D.*D;
f2 = (8.17 .* 10.^(8 - 1990./T_kel))./(1 + 0.0018 * (S - 35));
MgSO4 = (A2 .* P2 .* f2 * f.*f)./(f.*f + f2.*f2);

% Pure water contribution
A3 = T*nan;
i1 = (T <= 20);
A3(i1)  = 4.937e-4 - 2.59e-5  * T(i1)  + 9.11e-7 * T(i1).*T(i1)   - 1.50e-8*T(i1).*T(i1).*T(i1);
A3(~i1) = 3.964e-4 - 1.146e-5 * T(~i1) + 1.45e-7 * T(~i1).*T(~i1) - 6.50e-10*T(~i1).*T(~i1).*T(~i1);
P3 = 1 - 3.83e-5 * D + 4.9e-10* D.*D;
H2O = A3 .* P3 .* f.*f;

% Total absorption
alpha = Boric + MgSO4 + H2O;
alpha = alpha/1e3 ; % dB/m
