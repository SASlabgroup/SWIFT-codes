function [eps,wpsd] = PSDdissipation(w,uadvect,nwin,fs)
% Spectral dissipation of self-advected turbulence (Tennekes '75)

[nbin,~] = size(w);
%  Velocity Spectra
eps = NaN(nbin,1);
wpsd = NaN(nbin,nwin*2+1);
for ibin = 1:nbin
    [wpsd(ibin,:),f] = pwelch(detrend(w(ibin,:)),nwin,[],[],fs);
    compwpsd = mean(wpsd(ibin,f>1)'.*(f(f>1)*(2*pi)).^(5/3))./8;
    if (uadvect(ibin)>0) && (compwpsd>0)
        eps(ibin) = (compwpsd.*uadvect(ibin).^(-2/3)).^(3/2);
    end
end