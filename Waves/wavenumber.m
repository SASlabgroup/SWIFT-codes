
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
%

omega = 2*pi*f;   % convert to radian frequency
g = 9.81;   % gravity in m/s/s
depthR = round(depth);  % less precision in depth... speeds up convergence 

% initial guess 
if depth<20, % shallow 
    guess_k = sqrt( omega / (g*depthR) );
    eps  = 0.01 * guess_k;  % percision (function of wavenumber)
    err = abs(omega^2 - g*guess_k*tanh(guess_k*depthR) );  % initial error
elseif depth>=20 % deep
    guess_k =  omega^2 / g ;
    eps  = 0.01 * guess_k;  % percision (function of wavenumber)
    err = abs(omega^2 - g*guess_k*tanh(guess_k*depthR) );  % initial error
else end

% iterate to improve this guess
% by moving according to derivative of dispersion equation
k = guess_k;
while err>eps,
   k = guess_k - (omega^2 - g*guess_k*tanh(guess_k*depthR)) / (-g*tanh(guess_k*depthR) - g*guess_k*depthR*(cosh(guess_k))^-2 );
   err = abs(omega^2 - g*k*tanh(k*depthR));
   guess_k = k;
end

