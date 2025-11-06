function [eps,A,N,lambda] = SFfit(D,r)
% Fit observed second order structure function (D) to Kolmogorov Model,
%   D(r) = Cv*(eps^(2/3))*r^(2/3) + N
%   Cv is a constant ~ 2
%   N is the instrument noise
%   Outputs epsilon estimate, as well as model params, and the best-fit to
%   a power law (D \propto r^(lambda))
%   K. Zeiden Oct 2025, Adapted from Wiles 2006
Cv2 = 2.1;

% % Test
% eps0 = 10^(-6); 
% r = (0.05:0.05:3)'; 
% D0 = Cv2.*eps0.^(2/3).*(r.^(2/3));
% Nobs = (rand(n,1)-0.5)*10^(-4);
% D = D0 + Nobs;

n = length(r);
x0 = ones(n,1);
x23 = r.^(2/3);
d = D;

% Fit to Kolmogorov Model
G = [x23(:) x0(:)];
Gg = (G'*G)\G';
m = Gg*d(:);
A = m(1);
N = m(2);
eps = (A./Cv2).^(3/2);
eps(A<0) = NaN;

% Best-fit power law
x1 = r;
G = [log10(x1(:)) x0];
Gg = (G'*G)\G';
m = Gg*log10(d(:));
lambda = m(1);

% int = m(2); 
% figure('color','w')
% Dfit = A.*(r.^(2/3))+N;
% Dline = 10.^(int).*r.^(lambda);
% plot(r,D0,'k','LineWidth',2)
% hold on
% plot(r,D,'*r')
% plot(r,Dfit,'-b')
% plot(r,Dline,'-g')
% legend('True','Obs','Kolmogorov Model','Best-fit Power-law')

end