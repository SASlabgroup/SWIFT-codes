%Function to motion correct SWIFT uplooking motion

%WARNING... SOMETHIN IS WRONG WITH THE T-cosine MATRIX AT THE MOMENT!!

%AQD HR is pos pitch, bow up
%          pos roll to starbrd down
%          yaw is pos, CW of North
%
% Had previous issues with correct Omega matrix, now it is defined based on
%    original HPR rotations
% Had an issue with the beam vector in ENU b/c beam2xyz matrix does not
%   conserve magnitude
%
% last update Jul 29th, 2015
%
% continuing issues?
%       -rotation velocities are perhaps better correlated at a -1 lag?
%

function [Vc,pTerm,rotTerm] = AQDmotionCorrect2(V,h,p,r,pres,beam)
% clear
% V = [1;1;1;1];
% h = [0,0,0,0];
% r = [0,0,0,0];
% p = [0,10,20,30];
% %pres = [1,1.1,1.2,1.3];
% pres = [0,0,0,0];
% beam = 2;


[pts,cells] = size(V);
if cells > pts
   V = V.';
   [pts,cells] = size(V);
end


h = deg2rad(h); %heading - 90deg is in Nortek transformation code
p = deg2rad(p); %Nortek pitch is defined reversed? from Edson et. al. convention
r = deg2rad(r);

binR = 0.1 + [0:1:15]*0.04 + 0.02; %total distance from AQD head to bin centers

freq = 1/4;
hdot = (h(3:end) - h(1:end-2));
hdot( abs(hdot) > pi) = hdot( abs(hdot) > pi)-sign( hdot( abs(hdot) > pi))*(2*pi);%fix compass difference problem
hdot = hdot./(2*freq) ;

pdot = (p(3:end) - p(1:end-2))./(2*freq) ; %negative, b/c of edson convention reversed from AQD coordds
rdot = (r(3:end) - r(1:end-2))./(2*freq) ; %negative, b/c of edson convention reversed from AQD coordds
presdot = -(pres(3:end) - pres(1:end-2))./(2*freq); %negative to be pos. up?

%shorten other vectors to match derivatives
h = h(2:end-1);
p = p(2:end-1);
r = r(2:end-1);
pres = pres(2:end-1);
V = V(2:end-1,:);

%make component velocities zero
V1 = zeros(size(V));
V2 = zeros(size(V));
V3 = zeros(size(V));

if beam == 1
    V1 = V;
    phi = 0;
elseif beam == 2
    V2 = V;
    phi = -120; %beam2 is 120 CW of beam one, but Y dir is left positive in Nortek systems
elseif beam == 3
    V3 = V;
    phi = +120;
else
    disp('Choose beam 1,2, or 3')
    return
end

theta0 = 25; % AQD beam angle from the vertical
%location of bins relative to the AQD head
binx = binR.*sind(theta0).*cosd(phi); %x is along beam1
biny = binR.*sind(theta0).*sind(phi);%y is left of beam1
binz = binR.*cosd(theta0);

% %Beam 2 XYZ
% % This example shows the transformation matrix for a standard Aquadopp head
% B2xyz =[ 2896  2896    0 ;...
%     -2896  2896    0 ;...
%     -2896 -2896 5792  ];
% B2xyz = B2xyz/4096;   % Scale the transformation matrix correctly to floating point numbers

for ii = 1:pts-2
    %Construct Rotation matrix, first Heading, pitch, and roll rotations
    Hmat = [cos(h(ii)-(pi/2)),sin(h(ii)-(pi/2)),0;...
            -sin(h(ii)-(pi/2)),cos(h(ii)-(pi/2)),0;...
            0,0,1];
    Pmat = [cos(-p(ii)),0,-sin(-p(ii));...
            0,1,0;...
            sin(-p(ii)),0,cos(-p(ii))];
    Rmat = [1,0,0;...
            0,cos(r(ii)),-sin(r(ii));...
            0,sin(r(ii)),cos(r(ii))];
        
    %Total cosine rotation matrix
    T = Hmat*(Pmat*Rmat); %ORDER MATTERS HERE!
    
    %Angular rate pseudovector from Euler angles
    Omega = [0;0;hdot(ii)] + Hmat*[0;-pdot(ii);0] + Hmat*Pmat*[rdot(ii);0;0];
        
    for jj = 1:cells

        beamVec = T*[binx(jj);biny(jj);binz(jj)]; %bin vector from xyz to enu
        beamVec = beamVec./sqrt( sum( beamVec.^2 ) ); %normalized beam Vec
        
        Vmot = dot(beamVec,[0;0;presdot(ii)]); %projection of pressure correction into beam
        
        %ENUrot = cross(Omega,T*[binx(jj);biny(jj);binz(jj)]);
        %ENUrot(3) = 0;%exclude vertical motion to avoid double counting w/ pres.
        
        ENUrot = cross(Omega,T*[0;0;binz(jj)]);
        Vrot = -dot(beamVec,ENUrot);
        
        %-------- Motion Correction --------------
        Vc(ii,jj) = V(ii,jj) + Vrot + Vmot; %in beam coords
        
        % parse terms - component correction
        pTerm(ii,jj) = Vmot;
        rotTerm(ii,jj) = Vrot;
    end
    
end


end