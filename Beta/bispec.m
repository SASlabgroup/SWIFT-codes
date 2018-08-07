% [B,f] = bispec(xt)
%
% Makes a bispectral estimate, B(f1,f2) of input signal, xt
% where the bispectrum is defined as
%
% B(f1,f2) = X(f1)X(f2)X*(f1+f2)
% 
% with X being the Fourier transform of xt
%
% current implementation uses loops, could be vectorized later for speed

%clear
function [B,f] = bispec(xt)

%t = [1:1:512] ./ (2*pi);
%xt = sawtooth(t);

n = length(xt);

Y = fftshift( fft(xt) );
f = (1/n)*[(-(n-1)/2):((n-1)/2)];

Y = Y(n/2+1:n); %assumes even numbered n
f = f(n/2+1:n);

B = nan(n/2,n/2);
for ii = 1:n/2
   for jj = 1:n/2
        if (ii+jj)< (n/2)
            B(ii,jj) = Y(ii)*Y(jj)*conj( Y(ii+jj) );
        end
   end
end

%surf(f,f, abs(B) );shading flat

% temp = zeros(n,n);
% 
% warning off
% for ii = 1:n
%     temp(:,ii) =  circshift( conj(Y),ii-1);
% end
% warning on
% 
% for ii = 1:n
%     for jj = 1:n
%         if abs(f(ii))+abs(f(jj)) > abs(f(end))
%             temp(ii,jj) = NaN;
%         end
%     end
% end
% B = (transpose(Y)*Y) .* temp;


%end