function [out]=alpha_sea(z,S,T,pH,f)
%  Sound Attenuation in Sea Water in dB/m
%
%      function [out]=alpha_sea(z,S,T,pH,f);
%
%   z m
%   S psu
%   T degress C
%   pH of sea water (=8)
%   f in kHz
%
%   out in db/m
%
%   Medwin and Clay p. 109 Eq. 3.4.29 
%   Francois and Garrison JASA 72(6) 1982 pp 1879-1890 FIG 7

if (length(S)==length(T) && length(T)==length(z))
    c=sw_svel(S,T,z);

    % % BORIC ACID
    A1=8.68./c.*10.^(0.78.*pH-5);
    P1=1;
    f1=2.8.*(S./35).^0.5.*10.^(4-1245./(273+T));
    %q=1412+3.21.*T+1.19.*S+0.00167.*z;

    % % Magnesium SULFATE
    A2=21.44.*S./c.*(1+0.025.*T);
    P2=1-1.37e-4.*z+6.2e-9.*z.^2;
    f2_up=8.17.*10.^(8-1990./(273+T));
    f2_down=1+0.0018.*(S-35);
    f2=f2_up./f2_down;

    % % PURE WATER T<=20
    A3=ones(size(T));
    ij=find(T<=20);
    jk=find(T>20);
    A3(ij) = 4.937e-4 - 2.590e-5.*T(ij) + 9.11e-7.*T(ij).^2 - 1.5e-8.*T(ij).^3;
    A3(jk) = 3.964e-4 - 1.146e-5.*T(jk) + 1.45e-7.*T(jk).^2 - 6.5e-10.*T(jk).^3;
    P3 = 1-3.83e-5.*z+4.9e-10.*z.^2;
    
    out = A1.*P1.*f1.*f.^2./(f.^2+f1.^2) + A2.*P2.*f2.*f.^2./(f.^2+f2.^2) + A3.*P3.*f.^2;   % dB/km
    out=out./1000; % dB/m

elseif (length(T)~=length(z))
    fprintf('TRY AGAIN!\n')
    out=[];
else
    out=[];
    return
end
