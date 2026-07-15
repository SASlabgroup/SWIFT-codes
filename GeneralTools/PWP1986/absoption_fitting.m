% SW radiation curve fit
%
% Takes I/I_0 and fits to equation
%  I/I_0 = R e^(z/zeta_1) + (1-R) e^(z/zeta_2)
%  Where z is negative with increasing depth. 
% 
% Based on Paulson and Simpson 1977
% Michael James
% 07/2026

% INPUTS
depth = tbl.depth;
insolation_curve = tbl.c1./100; % from a table, insolation ratio


% FITTING
ft = fittype('a*exp(-z/b) + (1-a)*exp(-z/c)', ...
'independent', 'z', 'dependent', 'ratio');

opts = fitoptions(ft);
opts.Weights = 1 ./ tbl.c1(~isnan(insolation_curve)).^2; % adding weight exponentially.
opts.Lower       = [0.3 0.3    3]; % General bounds as (2) is higher wavelength (reds) and (3) is lower wavelength (blues)
opts.Upper       = [1   2     50];
opts.TolFun = eps; % Tightest tolerance to work with exp fits
opts.TolX = eps;
opts.DiffMinChange = 1e-10;
opts.MaxFunEvals = 10000;
opts.MaxIter = 10000;

fitresults = fit(depth(~isnan(insolation_curve)), insolation_curve(~isnan(insolation_curve)), ft, opts)

% show results
figure;
plot( insolation_curve,depth,'DisplayName','Obs I/I_0');
axis ij
xscale log 
axis manual
grid

hold on
plot(fitresults(depth), depth, 'DisplayName', 'Double Exp Fit')

legend('location', 'best')
