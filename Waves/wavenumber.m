
function k = wavenumber(f,depth)

%
% Matlab function to return the wavenumber (m^-1) of a surface-gravity wave 
%      given the inputs of frequency (Hz) and depth (m)
%
%   k = wavenumber( f, depth )
%
% according to linear finite-depth dispersion relation:  omega^2 = g*k * tanh(k*h)
% solved by Newton-Raphson iteration method
%
% J. Thomson, January 2002
% M. LeClair, Oct 2026 update guess_k, derivative, epsilon

omega = 2*pi*f;   % convert to radian frequency
g = 9.81;   % gravity in m/s/s

% initial guess 
if depth<20 % shallow 
    guess_k = omega / sqrt(g*depth); % extra sqrt on omega
    eps  = 1e-10 * guess_k;  % percision (function of wavenumber)
elseif depth>=20 % deep
    guess_k =  omega^2 / g ;
    eps  = 1e-10 * guess_k;  % percision (function of wavenumber)
else 
end

% iterate to improve this guess
% by moving according to derivative of dispersion equation
k = guess_k;
err = Inf;
while err > eps
   k = guess_k - (omega^2 - g*guess_k*tanh(guess_k*depth)) / (-g*tanh(guess_k*depth) - g*guess_k*depth*(cosh(guess_k*depth))^-2 );
   err = abs(k - guess_k);  % Newton step, in units of k
   guess_k = k;
end

