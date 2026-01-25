function [SWIFT, T0, T1, T2] = calculateskintempSWIFT(SWIFT, plotflag)
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

if nargin <2
    plotflag = 0;
end


%% Hardcoded Inputs (change to function input in the future)
% Inputs are for CT15 sn14056
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
    % For uplooking and downlooking
    if length(SWIFT(i).ambienttempmean) >1 
        % Commented out for uplooking
        % 
        % % Apply self-emmision correction term from lab calibration 
        % % difference of uplooking case temp and calculated Tskin dependent
        % amb(i) = SWIFT(i).ambienttempmean(2);
        % inf(i) = SWIFT(i).infraredtempmean(2);
        % Tdiff = amb(i) - inf(i); %AMB temp - Tbb
        % Terror = Terrorcoeff(1)*(Tdiff) +Terrorcoeff(2); %apply to curve
        % Terrorcat(i) = Terror; Tdiffcat(i) = Tdiff; %disp for debu
        % selfcorrectedup(i) = SWIFT(i).infraredtempmean(2) - Terror;
        % Calculate RAD from uplooking Tbb 
        % upRADfromTEM = k.RAD_from_Tbb(1) + (k.RAD_from_Tbb(2)*[selfcorrectedup(i)]) ...
        %     + (k.RAD_from_Tbb(3)*[selfcorrectedup(i)].^2) + (k.RAD_from_Tbb(4)*[selfcorrectedup(i)].^3) ...
        %     + (k.RAD_from_Tbb(5)*[selfcorrectedup(i)].^4);
        % 

        %% Uplooking Correction
        % Calculate RAD from uplooking Tbb 
        upRADfromTEM = k.RAD_from_Tbb(1) + (k.RAD_from_Tbb(2)*[SWIFT(i).infraredtempmean(2)]) ...
            + (k.RAD_from_Tbb(3)*[SWIFT(i).infraredtempmean(2)].^2) + (k.RAD_from_Tbb(4)*[SWIFT(i).infraredtempmean(2)].^3) ...
            + (k.RAD_from_Tbb(5)*[SWIFT(i).infraredtempmean(2)].^4);

        
        % Calculate RAD for skin
        RAD_skin = (1/em) * (SWIFT(i).radiancemean(1)- (1-em)*upRADfromTEM);
    
        % Calculate Tskin from skin radianceSWIFT(i).infraredtempmean(2)
        skinTEMfromRAD(i) = k.Tbb_from_RAD(1) + (k.Tbb_from_RAD(2)*RAD_skin) ...
            + (k.Tbb_from_RAD(3)*RAD_skin.^2) + (k.Tbb_from_RAD(4)*RAD_skin.^3) ...
            + (k.Tbb_from_RAD(5)*RAD_skin.^4);
    
    
        %% Emmissivity correction
        % Apply self-emmision correction term from lab calibration 
        % difference of downlookinglooking case temp and calculated Tskin dependent
        Tdiff = SWIFT(i).ambienttempmean(1) - skinTEMfromRAD(i);
        Tskin = skinTEMfromRAD(i) - Terrorcoeff(1)*(Tdiff) - Terrorcoeff(2);

        SWIFT(i).Tskin = Tskin;
        % Does not emmissivity correct
        Tskin_noselfcorrect = skinTEMfromRAD;
    else
        warning('Only 1 radiometer, no sky correction')

        Tdiff = SWIFT(i).ambienttempmean(1) - SWIFT(i).infraredtempmean(1);
        Tskin = SWIFT(i).infraredtempmean(1) - Terrorcoeff(1)*(Tdiff) - Terrorcoeff(2);

        SWIFT(i).Tskin = Tskin;
        
        % Does not emmissivity correct
        Tskin_noselfcorrect(i) = SWIFT(i).infraredtempmean(1);
    end


T0 = arrayfun(@(x) x.infraredtempmean(1), SWIFT, 'UniformOutput', true); % unprocessed brightness
T1 = Tskin_noselfcorrect; % sky correction
T2 = [SWIFT.Tskin]; % self emmission correction

AMB = arrayfun(@(x) x.infraredtempmean(1), SWIFT, 'UniformOutput', true); % case temperature
Tsky = arrayfun(@(x) x.infraredtempmean(2), SWIFT, 'UniformOutput', true); % unprocessed sky brightness

end;

if plotflag
    c = lines;

    figure('Position', [50 50 900 900]);

    subplot 311
    plot([SWIFT.time],T0,'Color', c(1,:), 'DisplayName','T0 (IRT)');
    hold on
    plot([SWIFT.time],T1,'Color', c(2,:), 'DisplayName','T1 (Sky Correct)');
    plot([SWIFT.time],T2,'Color', c(3,:), 'DisplayName','T2 (S. Emis. Correct)');

    legend('location', 'best')
    set(allchild(gca), 'LineWidth',2)
    datetick('x', 6)
    axis padded
    ylabel('[deg C]');
    title('Surface Temperature Corrections')

    subplot 312
    plot([SWIFT.time],AMB,'Color', c(4,:), 'DisplayName','T_A_M_B_ _D_N (Self Emission)');
    hold on
    plot([SWIFT.time],Tsky,'Color', c(5,:), 'DisplayName','T0 _U_P (IRT Sky)');
    legend('location', 'best')
    set(allchild(gca), 'LineWidth',2)
    datetick('x', 6)
    axis padded
    title('Corrective Temperatures')

    subplot 313
    plot([SWIFT.time],[SWIFT.watertemp],'Color', c(6,:), 'DisplayName','-0.66 m T');
    hold on
    plot([SWIFT.time],[SWIFT.airtemp],'Color', c(7,:), 'DisplayName','0.71 m T');
    legend('location', 'best')
    set(allchild(gca), 'LineWidth',2)
    datetick('x', 6)
    axis padded
    xlabel('UTC (AKDT+8hr)')
    title('Contextual Temperatures')    

    axesHandles = findobj(allchild(gcf), 'Type', 'Axes');
    linkaxes(axesHandles, 'x');
    set(findall(0,'-property','FontSize'),'FontSize',13)

    sgtitle(sprintf('SWIFT %s %s', SWIFT(i).ID, char(datetime(SWIFT(1).time, "ConvertFrom", 'datenum',"Format","MM/uuuu"))));

end;

end