function [TS,z,ping] = sigecho_target(echo,avg,zoff,w,ops,fn,outdir)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Disclaimer: The gain values determined from the Sv gains described
% in the report are not suitable for use with the TS code. This is
% provided primarily as an example. This code also lacks the noise
% correction term. If one is interested in using it, the sigecho_vol
% script's noise correction could be easily modified by replacing
% "Sv" with "TS" in the relevant lines.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Last modifications: 6 Dec 2023 - C. Bassett

%requires path to supporting functions either here or main code
% addpath('functionpath')

% sigecho_target takes "raw" outputs from a Nortek Signature echosounder
% and converts the values to the logarthmic unit for the backscattering
% cross-section (sigma_bs) such that TS = 10*log10(sigma_bs).
% Its units are dB re 1 m^2 and this is a standard unit for target
% strength processing using calibrated instruments in acoustics
% studies. This assumes the unit is being operated in the broadband, pulse 
% compressed output mode, but this does not meaningfully impact the
% processing applied herein.e

% The code primarily works from Nortek's Theory of Operations manual.
% Their formulation for TS is consistent with other sources. 
% More information about this code can be found in the APL Tech Report. 


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
    % blanking distance). .Pitch and .Roll are also accounted for if 
    % flagged for processing.

% avg: A structure provided by the ADCP processing that is solely used to
% bound the bottom. The primary reason for doing so is the general
% contributions of bubbles to high-levels of backscattering that could
% produce articial bottoms higher in the water column if working from the
% backscattering alone.

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

% OUTPUTS: 
% TS [dB re 1/m^2]. See Technical Report for more details


%(INSERT CITATION BELOW)

%OTHER REFERENCES:



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

cvec = 1500; % Normal speed of sound [m/s] used by instrument to calc range
w.c = sw_svel(w.S,w.T,w.z);   % calculate mean sound speed from data.
r = r*(cvec/w.c);             % use ratio of sound speeds to correct
                          	  % range vector for actual range
z = zoff + r;                 % Create depth vector for plotting

                                  
fc = 1e6;               % [Hz], 1 MHz center frequency
% Do range compensation, for TS this is 40log10(R). Accounts for intensity
% and 1/r^2 spreading in both directions.
Spread = 40*log10(r');
% Match array to echogram size
Spread = repmat(Spread,length(Spread(:,1)),1); 

% For pulse compress, need to account for attenuation across bandwidth
BW = 0.25;              % 25% bandwidth around center frequency
fmin = (1-BW/2)*fc;     % minimum transmitted frequency, [Hz]
fmax = (1+BW/2)*fc;     % maximum transmitted frequency, [Hz]
f = [fmin:1000:fmax]; % [Hz] Frequency vector covering full bandwidth
alpha = alpha_sea(10,w.S,w.T,w.pH,f./1e3); % Attenuation [dB/m] for bandwidth
matten = 10*log10(mean(10.^(alpha./10))); % mean attenuation over bandwidth
alphat = 2*matten.*r'; % total 2-way attenuation as a function of range
% Calculate alpha array for same size as echosounder array
alphat = repmat(alphat,length(echo.EchoSounder(:,1)),1);


% account for Power level
if ~isfield(echo,'PL')
    PL = -10;             % was hard-coded into parameters
else
    PL = echo.PL;         % use parameter if it exists
end

% Load and add gains
% Note: This eneds to be different than the Sv gainssigecho_vol code
%load(gainfile)

if ~isfield(ops,'gainflag')
    Gint = round(Cal.MeanGint,1);    
    
    elseif gainflag == 1
        calindex = find(Cal.SWIFT_SN == SN);   % find index corresponding 
                                               % to proper serial number
        Gint = Cal.Gint(calindex);             % already rounded to 0.1 dB
  
    else
        Gint = round(Cal.MeanGint,1);      % if other flag, just use default    
end


% Perform calculations
TS = Pr + Spread + alphat + PL + G; % echogram
ping.ping = 1:size(TS,1);                                % Pings
ping.time = echo.time;                                   % Pings
%echonotes = [];              % Notes to export, modify as needed


if and(isfield(ops,'printflag'),ops.printflag == 1)% then print

    if and(isfield(ops,'bot'),ops.bot == 1)% then print
   
    [TSnb,zbot] = sig_makebot(TS,echo,avg,z,zoff);
    
    myfiguresize = [2,2, 5.8, 3.6];
    figure(1)
    set(gcf,'color','w','units','inches','position',myfiguresize)    
    imagesc(ping.ping,z,TSnb'), hold on
    axis([1 length(ping.ping) 0 max(zbot)+1])
    box on, set(gca,'linewidth',2,'layer','top')
    set(gca,'clim',[-75 -35])
    colormap(gray(40))
    hcb = colorbar('linewidth',2)
    ylabel(hcb,'TS [dB re 1 m^2]','fontweight','bold')
    ylabel('z [m]','fontweight','bold')
    xlabel('Ping No.','fontweight','bold')
    set(findall(gcf,'-property','FontSize'),'FontSize',11)
    figname = [outdir '\' name '_TSecho'];
    set(gcf, 'PaperPosition', myfiguresize);
    %print('-dpng', '-r300', figname)
    
    else
        
    myfiguresize = [2,2, 5.8, 3.6];
    figure(2)
    set(gcf,'color','w','units','inches','position',myfiguresize)    
    imagesc(ping.ping,z,TS'), hold on
    axis([1 length(ping.ping) 0 20])
    box on, set(gca,'linewidth',2,'layer','top')
    set(gca,'clim',[-75 -35])
    colormap(gray(40))
    hcb = colorbar('linewidth',2)
    ylabel(hcb,'[dB re 1 m^2]','fontweight','bold')
    ylabel('z [m]','fontweight','bold')
    xlabel('Ping No.','fontweight','bold')
    set(findall(gcf,'-property','FontSize'),'FontSize',11)
    figname = [outdir '\' name '_TSecho'];
    set(gcf, 'PaperPosition', myfiguresize);
    %print('-dpng', '-r300', figname)
    
    end
end

if and(isfield(ops,'exportflag'),ops.exportflag == 1)% then print
fnout = [outdir '\' name '_TSecho.mat'];
save(fnout,'TS','z','ping')
end



end




