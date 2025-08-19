function [O2,fh] = readSWIFT_ACO(filename,varargin)

% Function to read in ACO data. Data are read in as table, with knoweldge
% of which columns correspond to variables. If columns are not as expected,
% read-in will be wrong. See "Data Fields Explained" at end of function for
% info on variables.
%
% [Temperature Salinity ] = readSWIFT_ACO( filename );
%
% K. Zeiden August 2025

if nargin < 2
    plotburst = false;
else
    plotburst = varargin{1};
end

finfo = dir(filename);
if finfo.bytes == 0
    disp('File is empty.')
    O2.O2Concentration = NaN;
    O2.AirSat = NaN;
    O2.Temp = NaN;
    O2.CalPhase = NaN;
    O2.TCPhase = NaN;
    O2.C2RPh = NaN;
    O2.C1Amp = NaN;
    O2.C2Amp = NaN;
    O2.RawTemp = NaN;
    fh = [];
    return
end

data = readtable(filename, 'Delimiter', '\t', 'FileType', 'text', ...
    'NumHeaderLines', 2, 'ReadVariableNames', false);

O2.O2Concentration = table2array(data(:,5)); % [uM]
O2.AirSat = table2array(data(:,7));% [%]
O2.Temp = table2array(data(:,9));% [deg C]
O2.CalPhase = table2array(data(:,11));% [deg]
O2.TCPhase = table2array(data(:,13));% [deg]
O2.C2RPh = table2array(data(:,15));% [deg]
O2.C1Amp = table2array(data(:,17));% [mV]
O2.C2Amp = table2array(data(:,19));% [mV]
O2.RawTemp = table2array(data(:,21));% [deg C]

fields = fieldnames(O2);
for ifield = 1:length(fields)
    if iscell(O2.(fields{ifield}))
        for inum = 1:length(O2.(fields{ifield}))
            O2.(fields{ifield}){inum} = regexprep(O2.(fields{ifield}){inum},'[^\d.-]',' ');
        end
        O2.(fields{ifield}) = str2double(O2.(fields{ifield}));
    end
end

if plotburst

    figure('color','w');
        subplot(3,1,1);plot(O2.O2Concentration,'LineWidth',2);
        ylabel('[uM]');
        title('O2 Concentration')
        subplot(3,1,2);
        plot(O2.AirSat,'LineWidth',2);
        ylabel('[%]');
        title('Air Saturation')
        subplot(3,1,3);
        plot(O2.Temp,'LineWidth',2);
        ylabel('[^{\circ}C]');
        title('Temperature')
        xlabel('N')
        h = findall(gcf,'Type','Axes');linkaxes(h,'x')
        axis tight
        set(h(2:end),'XTickLabel',[])
        print([filename(1:end-4)],'-dpng')
else
    fh = [];
end

save([filename(1:end-4) '.mat'],'O2')

end

%% Data Fields Explained (AI)
% 
% O2Concentration[uM]:
% Definition: Dissolved oxygen concentration in the water, measured in 
%   micromoles per liter (µM, equivalent to µmol/L).
% Significance: This is the primary measurement, indicating the amount of 
%   oxygen dissolved in seawater. It’s critical for assessing water quality,
%   biological processes (e.g., photosynthesis, respiration), and ecosystem 
%   health. For reference, 1 µM ≈ 0.032 mg/L for oxygen under standard 
%   conditions, though this depends on temperature and salinity.
% Role: Derived from raw sensor measurements (phase and amplitude) using 
%   a calibration model, adjusted for temperature and sometimes 
%   salinity/pressure.
% 
% 
% AirSaturation[%]:
% Definition: The percentage of oxygen saturation in the water relative to
%   the equilibrium concentration of oxygen in water exposed to air at the 
%   same temperature, salinity, and pressure, expressed as a percentage (%).
% Significance: A value of 100% indicates the water is fully saturated with
%   oxygen relative to atmospheric equilibrium. Values >100% suggest 
%   supersaturation (e.g., due to phytoplankton photosynthesis), while <100% 
%   indicates undersaturation (e.g., due to respiration or stratification). 
%   It’s calculated using O2Concentration, temperature, and salinity 
%   (if available) based on oxygen solubility equations 
%   (e.g., Garcia and Gordon, 1992).
% 
% 
% Temperature[Deg.C]:
% Definition: The water temperature measured by the sensor’s integrated 
%   thermistor or similar probe, in degrees Celsius (°C).
% Significance: Temperature is essential for calculating oxygen 
%   concentration and saturation because oxygen solubility in water decreases
%   with increasing temperature. This is the processed temperature value used 
%   in scientific analyses, derived from RawTemp[mV].
% Role: Used to compensate for temperature effects on fluorescence 
%   measurements and to compute AirSaturation.
% 
% 
% CalPhase[Deg]:
% Definition: The raw phase shift of the fluorescence signal in the optode,
%   measured in degrees (Deg). Optodes measure oxygen by exciting a 
%   luminescent dye with light and detecting the phase shift in the emitted 
%   fluorescence, which is quenched by oxygen.
% Significance: The phase shift is inversely related to oxygen 
%   concentration (more oxygen = shorter fluorescence lifetime = smaller 
%   phase shift). This raw measurement is used in the sensor’s calibration
%   algorithm to compute O2Concentration.
% Role: Primarily a diagnostic or intermediate value for verifying sensor
%   performance or recalibrating data.
% 
% 
% TCPhase[Deg]:
% Definition: The temperature-compensated phase shift, also in degrees 
%    (Deg), adjusted to account for the effect of temperature on the 
%   fluorescence signal.
% Significance: Temperature affects the fluorescence decay time, so TCPhase
%   provides a corrected phase measurement for more accurate oxygen 
%   calculations. It’s an intermediate step in deriving O2Concentration.
% Role: Used in the sensor’s algorithm to improve the accuracy of oxygen
%   measurements.
% 
% 
% C1RPh[Deg]:
% Definition: The reference phase shift for the first measurement cycle,
%   in degrees (Deg). Optodes often use multiple excitation cycles or 
%   wavelengths (e.g., a sensing cycle and a reference cycle) to account for
%   sensor drift, fouling, or optical variations.
% Significance: This parameter monitors the baseline fluorescence behavior,
%   helping to correct for non-oxygen-related effects (e.g., sensor aging or 
%   fouling). It’s a diagnostic value used in the calibration process.
% Role: Ensures the accuracy of O2Concentration by providing a reference 
%   for the sensing cycle.
% 
% 
% C2RPh[Deg]:
% Definition: The reference phase shift for a second measurement cycle, 
%   in degrees (Deg), similar to C1RPh but for a different cycle or 
%   wavelength.
% Significance: Like C1RPh, it’s used to monitor sensor performance and 
%   correct for drifts or environmental effects. The presence of two 
%   reference phases (C1RPh and C2RPh) suggests the sensor uses dual cycles 
%   for enhanced reliability.
% Role: Supports calibration and quality control, ensuring robust oxygen 
%   measurements.
% 
% 
% C1Amp[mV]:
% Definition: The amplitude (intensity) of the fluorescence signal during 
%   the first measurement cycle, measured in millivolts (mV).
% Significance: The amplitude reflects the strength of the fluorescence 
%   signal, which can be affected by oxygen concentration, sensor condition 
%   (e.g., fouling of the sensing foil), or optical system performance. It’s
%   used alongside phase measurements to compute O2Concentration and for 
%   diagnostics.
% Role: Helps verify sensor health (e.g., low amplitude may indicate 
%   fouling or sensor degradation).
% 
% 
% C2Amp[mV]:
% Definition: The amplitude of the fluorescence signal during the second 
%   measurement cycle, in millivolts (mV).
% Significance: Similar to C1Amp, it provides amplitude data for a different
%   cycle or wavelength, used for calibration and diagnostics. Comparing C1Amp
%   and C2Amp can reveal inconsistencies in sensor performance.
% Role: Supports accurate oxygen measurements and quality control.
% 
% 
% RawTemp[mV]:
% Definition: The unprocessed temperature signal from the sensor’s
%   thermistor or temperature probe, measured in millivolts (mV).
% Significance: This is the raw electrical output from the temperature 
%   sensor before conversion to °C. It’s used to derive Temperature[Deg.C] 
%   through a calibration curve specific to the sensor.
% Role: Provides the raw data needed to calculate the processed temperature,
%   which is critical for oxygen concentration and saturation calculations.
% 
% Notes:
% Oxygen Measurement: O2Concentration[uM] is calculated from raw 
%   fluorescence measurements (CalPhase[Deg], TCPhase[Deg], C1RPh[Deg], 
%   C2RPh[Deg], C1Amp[mV], C2Amp[mV]) using a calibration model, often 
%   based on the Stern-Volmer equation or a manufacturer-specific algorithm.
% Temperature (from RawTemp[mV] and Temperature[Deg.C]) is used to correct 
%   for its effect on fluorescence and oxygen solubility.
% AirSaturation: AirSaturation[%] is derived from O2Concentration[uM], 
%   Temperature[Deg.C], and (if available) salinity and pressure, using 
%   oxygen solubility equations. It contextualizes oxygen levels relative to 
%   environmental conditions.
% Diagnostics: Parameters like CalPhase, TCPhase, C1RPh, C2RPh, C1Amp, and 
%   C2Amp are raw or intermediate values used for quality control. They help
%   detect issues like biofouling, sensor drift, or calibration errors. For 
%   example, unexpected changes in amplitude (C1Amp, C2Amp) or phase (C1RPh,
%   C2RPh) could indicate fouling or sensor degradation.
% Temperature: RawTemp[mV] is converted to Temperature[Deg.C] using a 
%   calibration curve, and Temperature[Deg.C] is used in both oxygen and 
%   saturation calculations.
