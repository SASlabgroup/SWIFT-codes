function [Sv,z,ping] = sigecho_vol(echo,avg,zoff,w,ops,fn,outdir,gainfilename)

% Last modifications: 6 Dec 2023 - C. Bassett

% The calibration file path also needs to be modified. This is located
% below just about the line that checks for 'gainflag'

% sigecho_vol takes outputs from a Nortek Signature echosounder
% and converts the values to the logarthmic unit for the volume
% backscattering coefficient (sigma_v) such that Sv = 10*log10(sigma_v).
% Its units are dB re 1/m and this is a standard unit for volume
% backscattering processes using calibrated instruments in acoustics
% studies. This assumes the unit is being operated in the broadband, pulse 
% compressed output mode.

% The code primarily works from Nortek's Theory of Operations manual.
% However, their formulate for Sv is incorrect for broadband operations
% (although it is correct for narrowband). At the present time, this code
% is restrcited to processing broadband codes without the raw waveforms.
% This is limitation, which may be expanded at a later date, is driven
% primarily by the onboard limitations of the SWIFTs and how it is used at
% the present time. For information about this code can be found in the
% APL Tech Report. 

% Reference
%  C. Bassett and K. Zeiden, Calibration and Processing of Nortek Signature 
%  1000 Echosounders (2020). Technical Report, APL-UW TR 2303. Applied
%  Physics Laboratory, University of Washington, Seattle, 
%  December 2023, 37 pp.



% INPUTS: 
% echo: A structure containing all of the relevant echosounder information
    % that is based by the reprocess_SIG function from which it is called. 
    % The most important variables here are .EchoSounder (the echogram
    % data), .Cellsize (range bin in m), and .Blanking (the transducer's 
    % blanking distance).
    
% avg: A structure provided by the ADCP processing that is solely used to
% bound the bottom. The primary reason for doing so is the general
% contributions of bubbles to high-levels of backscattering that could
% produce articial bottoms higher in the water column if working from the
% volume backscattering along.
    
% zoff: Offset [m] for the transducer depth below the water, default 0.2 m;

% w: a structure containing water properties used to calculate attenuation 
% and sound speed. These values should represented the average over the 
% imaged portion of the water column. 
      % w.T = Temperture [C], default = 10;
      % w.S = Salinity [psu], default = 30;
      % w.pH = default 8.1
      % w.z = mean depth [m], default = 10; % impact is minimal

% ops: An options variable carrying the following options
% ops.gainflag: 0, empty Use mean of all serial numbers
             % 1 - use specific SWIFT serial number for gain
             % either value uses gain associated with top five targets in
             % calibration
% ops.printflag: Saves echogram if == 1, else ignores
% ops.exportflag: Exports echogram data if == 1, else ignores
% ops.bot:   % Will remove sub-bottom data if == 1, else ignores

% fn: Input filename, used to write out processed echogram with consistent
% filename

% outdir: Directory for output data, if outpath not provided data is
% written into the same directory as the filename


% gainfilename: Input path and file name for gainfile
% Contains structure Cal with variables for SWIFT buoy number, Gint (gain
% for each buoy number), and MeanGint (mean gain across all units)
% Other uses may hard code a gain value or rewrite portions of this script

% DEPENDENCIES
% alpha_sea(w.z, w.S, w.T,w.pH, f) where f is frequency in kHz
       % This calculates attenuation in dB/m. Note that there is increasing
       % evidence that the formulations, generally set up for lower
       % frequencies, may not perform well at 1 MHz. Until more
       % measurements and formulation are established this what we'll work
       % with. 
% sw_svel(w.S,w.T,w.z)
       % Calculates sound speed [m/s]. The third input is actually pressure 
       % in decibars, but given that maps to meter of water and has minor
       % impacts on sound speed we'll work with w.z instead.

% sig_makebot(Sv, echo, avg, z, zoff)
       % If called, will use the altimeter data to find the seabed, apply
       % an offset, and NaN out all data below the seabed. It will also use
       % this new echogram to output figures that only plot down to the
       % seabed + the offset, making the figures look better
 
% gainfilename      
% OUTPUTS: 
% Sv [dB re 1/m]. See Technical Report for more details

% z: Depth for plotting the echogram

% ping: ping structure for echograms. It contains
       % ping.ping: Ping count
       % ping.time: Ping time

%OTHER REFERENCES:
%Clay, C. S., and Medwin, H. 1977. Acoustical oceanography: principles and
%applications. Wiley, New York. 544 pp.

% requires path to supporting functions either here or main code
% addpath('functionpath')


% Start by getting SN from the filename
[filepath,name,ext] = fileparts(fn);
SN = str2double(name(6:7)); % Get SWIFT serial number from filename

% check if outdir exists and make it equal to filename if it doesn't
if ~exist('outdir')
    outdir = filepath;
end

% Check for existence of w and write defaults if needed
if ~exist('w')
    w.S  = 30;      % psu
    w.T =  10;      % deg C
    w.pH = 8.1;
    w.z = 10;       % m
end

if ~exist('zoff')
    zoff = 0.2;     % distance below water line
end


% Convert power to decibels (Nortek provides in 100ths of a dB)
Pr = (echo.EchoSounder)./100; % [dB], plug right into sonar equation


% calculate rate vectors.
n_rbins = size(echo.EchoSounder,2);     % Number of range bins in echogram
% Create range vector
r = echo.Blanking+[0:n_rbins-1]'.*echo.CellSize + echo.CellSize/2;

% Vector sounds speed

cvec = 1500; % Nominal speed of sound [m/s] used by instr to calc range
w.c = sw_svel(w.S,w.T,w.z);   % calculate mean sound speed from data.
r = r*(cvec/w.c);             % use ratio of sound speeds to correct
                              % range vector for actual range

z = zoff + r;                 % Create depth vector for plotting
                              

% Current assumes broadband, pulse compressed. 
% If narrowband becomes an option, will need to modify inputs to function
% and change implementation (multiple options) for calculation
% Now let's go through and calculate Sv.
% For now hard-codes the center-frequency [Hz]
% If generalizing the code, move to inputs
fc = 1e6;               % [Hz], 1 MHz center frequency


% Do range compensation, for S_v this is 20log10(R)
Spread = 20*log10(r');
Spread = repmat(Spread,length(Spread(:,1)),1); % Match array to echogram size

% For pulse compress, need to account for attenuation across bandwidth
BW = 0.25;              % 25% bandwidth around center frequency
fmin = (1-BW/2)*fc;     % minimum transmitted frequency, [Hz]
fmax = (1+BW/2)*fc;     % maximum transmitted frequency, [Hz]
f = [fmin:1000:fmax];    % [Hz] Frequency vector covering full bandwidth
alpha = alpha_sea(10,w.S,w.T,w.pH,f./1e3); % Attenuation [dB/m] over band
matten = 10*log10(mean(10.^(alpha./10))); % mean attenuation over bandwidth
alphat = 2*matten.*r';  % total 2-way attenuation as a function of range
% Calculate alpha array for same size as echosounder array
alphat = repmat(alphat,length(echo.EchoSounder(:,1)),1);
dr = r(2) - r(1);        % range bin, used for volume calculation 
                         %with equivalent beam angle


% Equivalent beam angle. Generally should be measured. We will appropximate
% referring to Medwin and Clay (1977), Psiu = eba = 10*log10(5.78/ka.^2)
% To do this we are going to create the beamwidths over frequency vector
% and then take an average. 

k = 2*pi*f./w.c;                     % wavenumber vector 
a = 0.015;                           % radius of transducer in cm 
eba = 10.*log10(5.78./(k.*a).^2);    % Calculate across frequency range
Psi = 10*log10(mean(10.^(eba./10))); % Mean across bandwidth
                                     % Matches Nortek values

% account for Power level
if ~isfield(echo,'PL')
    PL = -10;             % was hard-coded into parameters
else
    PL = echo.PL;         % use parameter if it exists
end

% Load and add gains
% User should modify path for local of gains
load(gainfilename);     % load gain file
% Gint = 0;               % Alternatively manually define a Gint term
% If Gint is manually defined, remove the follwing if statements determining
% Gint from the Cal structure loaded from the gainfile

% Loads the gains associated with the top five targets from the analysis
if ~isfield(ops,'gainflag')
    Gint = round(Cal.MeanGint,1);    
    
    elseif gainflag == 1;
        calindex = find(Cal.SWIFT_SN == SN);   % find index corresponding 
                                               % to proper serial number
        Gint = Cal.Gint(calindex);             % already rounded to 0.1 dB
  
    else
        Gint = round(Cal.MeanGint,1);          % if other flag, use default    
end

% Perform calculations
Sv = Pr + Spread + alphat + PL - 10*log10(dr) - Psi + Gint; % echogram
%% Do Noise correct
% If of interest, replace mean with specific NT threshold value
NT = 19.3;                          % Mean value of the six measured SWIFTs
Svnoise = NT + Spread + alphat + PL - 10*log10(dr) - Psi + Gint; 
Svnoise = Svnoise(1,:);             % Truncate array since each value
                                    % is identical since based on NT
SNR = 3; % Threshold SNR value in SN data. 
Svcorr = 10.^(Sv./10) - 10.^(Svnoise./10);  % Subtract noise
Svcorr(find(Svcorr < 10e-12)) = 10e-16;   % replace low values with -150 dB
Svcorr = 10*log10(Svcorr);                % convert back to log
lowSNR = find(Svcorr - 3 - Svnoise < 0);  % Find points with SNR < 3 dB
Svcorr(lowSNR)= -150;                     % Rewrite with -150 dB
clear Sv
Sv = Svcorr;                              % Rewrite Sv with corrected term

%%
ping.ping = 1:size(Sv,1);                                   % Pings
ping.time = echo.time;
%echonotes = [];                       % Notes to export, modify as needed

if and(isfield(ops,'printflag'),ops.printflag == 1)% then print

    if and(isfield(ops,'bot'),ops.bot == 1)        % then print
   
    [Svnb,zbot] = sig_makebot(Sv,echo,avg,z,zoff);
    
    myfiguresize = [2,2, 5.8, 3.6];
    figure(1)
    set(gcf,'color','w','units','inches','position',myfiguresize)    
    imagesc(ping.ping,z,Svnb'), hold on
    axis([1 length(ping.ping) 0 max(zbot)+1])
    box on, set(gca,'linewidth',2,'layer','top')
    set(gca,'clim',[-75 -40])
    colormap(gray(35))
    hcb = colorbar('linewidth',2)
    ylabel(hcb,'S_v [dB re 1/m]','fontweight','bold')
    ylabel('z [m]','fontweight','bold')
    xlabel('Ping No.','fontweight','bold')
    set(findall(gcf,'-property','FontSize'),'FontSize',11)
    figname = [outdir '\' name '_echo'];
    set(gcf, 'PaperPosition', myfiguresize);
    print('-dpng', '-r300', figname)
    
    else
        
    myfiguresize = [2,2, 5.8, 3.6];
    figure(2)
    set(gcf,'color','w','units','inches','position',myfiguresize)    
    imagesc(ping.ping,z,Sv'), hold on
    axis([1 length(ping.ping) 0 20])
    box on, set(gca,'linewidth',2,'layer','top')
    set(gca,'clim',[-75 -40])
    colormap(gray(35))
    hcb = colorbar('linewidth',2)
    ylabel(hcb,'S_v [dB re 1/m]','fontweight','bold')
    ylabel('z [m]','fontweight','bold')
    xlabel('Ping No.','fontweight','bold')
    set(findall(gcf,'-property','FontSize'),'FontSize',11)
    figname = [outdir '\' name '_echo'];
    set(gcf, 'PaperPosition', myfiguresize);
    print('-dpng', '-r300', figname)
    
    end
end

if and(isfield(ops,'exportflag'),ops.exportflag == 1)% then print
fnout = [outdir '\' name '_echo.mat'];
save(fnout,'Sv','z','ping')
end


end
