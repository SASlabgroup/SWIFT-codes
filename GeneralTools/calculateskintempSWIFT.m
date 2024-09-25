function [SWIFT, Tskin_noselfcorrect] = calculateskintempSWIFT(SWIFT)
%calculateskintempSWIFT Takes uplooking and downlooking point radiometer
%data and calculates skin temp. 
%   [SWIFT.SWrad,SWIFT.LWrad] = calculateskintempSWIFT(SWIFT) 
%   Takes in SWIFT structure with fields:
%   SWIFT.infraredtempmean
%   SWIFT.infraredtempstd
%   SWIFT.ambienttempmean
%   SWIFT.ambienttempstd
%   SWIFT.radiancemean
%   SWIFT.radiancestd
%   and calculates an observed skin temperature according to "Notes on
%   Tskin calculation for Pocari/Behm Canal" by A. Jessup. 
% IMPORTANT:
% Requirement of Cbb and epsilon calculations based on collection equipment
% and setup
%
% Assuming first SWIFT entry is "downlooking" and second SWIFT entry is
% "uplooking"

% Cbb/Cbb-1 and Epsilon entry

% [incidence angle, epsilon] incidence angle is from angle normal to
% surface, NOT grazing angle.
em_matrix = [0,0.98223716
10,0.98223716
20,0.98207259
30,0.98123765
40,0.97834563
45,0.97515589
50,0.96967626
52.5,0.96564758
55,0.96051347
57.5,0.95382714
60,0.94503534
62.5,0.93385285
65,0.91925395
67.5,0.9005596
70,0.87636465
72.5,0.84548479
75,0.80552888
];

% k coeff for Cbb^-1
k.RAD_from_Tbb = [10919.82517627584
273.7289741667266
2.409503341170812
0.008825930999650112
-3.896460428403891e-05];

% k coeff for Cbb
k.Tbb_from_RAD = [-58.88762553221061
0.007836159715023917
-2.956816400914647e-07
7.48156971384736e-12
-8.088049022835674e-17];

% Linear fit of correction term [m,b] in terms of y = mx+b
Terrorcoeff = [0.07601486369602617
    -0.4487941719733867];

% Choose emmissivity value
em = 0.97515589; % 45 degree

for i = 1:length(SWIFT)

    % Calculate RAD from uplooking Tbb
    upRADfromTEM = k.RAD_from_Tbb(1) + (k.RAD_from_Tbb(2)*[SWIFT(i).infraredtempmean(2)]) ...
        + (k.RAD_from_Tbb(3)*[SWIFT(i).infraredtempmean(2)].^2) + (k.RAD_from_Tbb(4)*[SWIFT(i).infraredtempmean(2)].^3) ...
        + (k.RAD_from_Tbb(5)*[SWIFT(i).infraredtempmean(2)].^4);
    
    % Calculate RAD for skin
    RAD_skin = (1/em) * (SWIFT(i).radiancemean(1)- (1-em)*upRADfromTEM);

    % Calculate Tskin from skin radiance
    skinTEMfromRAD(i) = k.Tbb_from_RAD(1) + (k.Tbb_from_RAD(2)*RAD_skin) ...
        + (k.Tbb_from_RAD(3)*RAD_skin.^2) + (k.Tbb_from_RAD(4)*RAD_skin.^3) ...
        + (k.Tbb_from_RAD(5)*RAD_skin.^4);

    % % Apply self-emmision correction term from lab calibration NEED ROSR
    % DATA
    % difference of downlooking case temp and calculated Tskin dependent
    Tdiff = SWIFT(i).ambienttempmean(1) - skinTEMfromRAD(i); %AMB temp - Tbb
    amb(i) = SWIFT(i).ambienttempmean(1);
    inf(i) = SWIFT(i).infraredtempmean(1);
    Terror = Terrorcoeff(1)*(Tdiff) +Terrorcoeff(2); %apply to curve
    Terrorcat(i) = Terror; Tdiffcat(i) = Tdiff; %disp for debu
    SWIFT(i).Tskin = skinTEMfromRAD(i) - Terror;
end;

Tskin_noselfcorrect = skinTEMfromRAD;

end