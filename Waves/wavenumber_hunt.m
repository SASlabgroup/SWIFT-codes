function k = wavenumber_hunt(f,depth)

%
% Matlab function to return the wavenumber (m^-1) of a surface-gravity wave
%      given the inputs of frequency (Hz) and depth (m)
%
%   k = wavenumber_hunt( f, depth )
%
% according to linear finite-depth dispersion relation:  omega^2 = g*k * tanh(k*h)
% initial guess from Hunt's (1979) Pade approximation (error < 0.1%), as given in CETN-1-17
% improved with a single Newton-Raphson step (error < 1e-7);
% wavenumber.m iterates Newton-Raphson to convergence instead
%
% f and depth can be scalars or arrays of the same size
%
% M. LeClair w/ claude, Oct 2026 (from wavenumber.m, J. Thomson, January 2002)

omega = 2*pi*f;   % radian frequency
g = 9.81;   % gravity in m/s/s

% initial guess
guess_k = hunt_wavenumber(f, depth);

% iterate to improve this guess with one Newton step
kh = guess_k .* depth;
k = guess_k - (omega.^2 - g*guess_k.*tanh(kh)) ./ (-g*tanh(kh) - g*kh.*sech(kh).^2);
end


function k = hunt_wavenumber(f, d)
% Hunt (1979)'s Pade approximation taken from 
% USACE CETN-1-17 (https://hdl.handle.net/11681/2361)
%   G = 2*pi*(d/L_0) = (2*pi/T)^2 * d/g
%   F = G + 1 / (1.0 + 0.6522G + 0.4622G^2 + 0.0864G^4 + 0.0675G^5)
%   L = T * sqrt(g*d/F),
g = 9.81; % m/s/s
T = 1 ./ f;   % wave period (s)
G = (2*pi./T).^2 .* d / g;
F = G + 1 ./ (1.0 + 0.6522*G + 0.4622*G.^2 + 0.0864*G.^4 + 0.0675*G.^5);
L = T .* sqrt(g*d./F);
k = 2*pi ./ L;
end