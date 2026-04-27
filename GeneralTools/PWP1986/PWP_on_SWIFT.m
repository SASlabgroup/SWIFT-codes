%---------------------------------------------------------------------------
% MATLAB implementation of the Price Weller Pinkel mixed layer model
% 20 4 2026
% Michael James
% University of Washington
% Civil and Environmental Engineering
%--------------------------------------------------------------------------
%
% This version is adapted from the matlab code by Byron Kilbourne (2011),
% provided by Earle Wilson 
%    https://github.com/earlew/pwp_python_00
% 
% Original Fortran written by Jim Price, WHOI, April 27, 1989.
%    https://www.whoi.edu/science/PO/people/jprice/PWP/welcome.html
% 
% References:
%    Price, Weller, Pinkel (1986), JGR 91(C7), 8411-8427.
%    Price, Mooers, Van Leer (1978), JPO 8(4), 582-599.
% 
%--------------------------------------------------------------------------
% input (.mat format)
% met_input_file -> path and file name for MET forcing
%   - format -> SWIFT structure and fluxes table (2 VARIABLES) from runCOARE3_6onSWIFT.m (uses COARE naming)
%       - time: time [days] (positive vector)
%       - sw_net: net shortwave radiation [W/m2] (vector)
%       - lw_net: net longwave radiation [W/m2] (vector)
%       - hlb: latent heat flux [W/m2] (vector)
%       - hsb: sensible heat flux [W/m2] (vector)
%       - tau: wind stress [N/m2] (positive vector)
%       - rain: precipitation rate [m/s]  (positive vector)
%       - winddirT: Wind Direction [deg] (positive vector)
% profile_input_file -> path and file name for intial density profile (1
% VARIABLE)
%   - format -> single cast of CTD as structure array or table
%       - **time is assumed at start of met time**
%       - z: depth [m] (positive vector)
%       - t: temperature [deg C] (vector)
%       - s: salinity [PSU] (vector)
%       - d: density [kg/m^3] (positive vector)
% output (.mat format)
% pwp_output -> path and file name for output
%   - format -> table of profiles for S-T and rho and some settings
%       - dt: time-step increment [seconds] (positive scaler)
%       - dz: depth increment [meters] (positive scaler)
%       - lat: latitude [deg] (scaler)
%       - z: depth [m] (positive vector) 
%       - time: time [days] (positive matrix)
%       - t: temperature [deg C] (matrix)
%       - s: salinity [PSU] (matrix)
%       - d: density [kg/m^3] (positive matrix)
%       - u: u velocity [m/s] (matrix)
%       - v: v velocity [m/s] (matrix)
%       - mld: mixed layer depth [m] (positive vector)
%       
%--------------------------------------------------------------------------
% Dependencies:
% TEOS-10 "Gibbs Seawater toolbox"
%   - https://www.teos-10.org/software.htm
%--------------------------------------------------------------------------
% 
% this code has sections
% 1) set parameters
% 2) read in forcing data
% 3) preallocate variables
% 4) main model loop
%   4.1) heat and salt fluxes
%   4.2) rotate, adjust to wind, rotate
%   4.3) bulk Richardson number mixing
%   4.4) gradient Richardson number mixing
% 5) save results to output file

%--------------------------------------------------------------------------
clear, clc, close all;

%--------------------------------------------------------------------------
% diagnostic plots
% 0 -> no plots
% 1 -> shows depth integrated KE and momentum and current,T, and S profiles
% 2 -> plot momentum after model run
% 3 -> plot mixed layer depth after model run
diagnostics = 0;
%--------------------------------------------------------------------------
tic % log runtime
% set parameters

% % Hard code inputs
met_input_file = ""
profile_input_file = ""
pwp_output_file = ""


dt			= 3600/2;          %time-step increment (seconds)
dz			= 0.1;           %depth increment (meters)
%days 		= 1;           %the number of days to run (max time grid)
depth		= 100;          %the depth to run (max depth grid)
dt_save     = 1;            %time-step increment for saving to file (multiples of dt)
lat 		= 55.35;        %latitude (degrees)
lon         = -131.65       %longitude (degrees)
g			= 9.81;          %gravity (9.8 m/s^2)
cpw			= 4183.3;       %specific heat of water (4183.3 J/kgC)
rb			= 0.65;         %critical bulk richardson number (0.65)
rg			= 0.3;         %critical gradient richardson number (0.25) set to 0.3 as fail safe as written in PWP1986
rkz			= 0;            %background vertical diffusion (0) m^2/s
beta1   	= 0.6;          %longwave extinction coefficient (0.6 m)
beta2   	= 20;           %shortwave extinction coefficient (20 m)

f = gsw_f(lat);              %coriolis term (rad/s)
ucon = (.1*abs(f));         %coefficient of inertial-internal wave dissipation (0) s^-1
%--------------------------------------------------------------------------
% load forcing data

load(met_input_file)
load(profile_input_file)
dtd = dt/86400; % time step days

% Setup a structure of defaults
if ~isfield(SWIFT, 'time') | ~isfield(profile, 'z');
    error('No time or z data in met or profile file, cannot continue. Please check file structure')
end
% vars in time
pwp_input.winddirT = repmat(0, length([SWIFT.time]),1);
pwp_input.sw_net = repmat(0, length([SWIFT.time]),1);
pwp_input.lw_net = repmat(0, length([SWIFT.time]),1);
pwp_input.hsb = repmat(0, length([SWIFT.time]),1);
pwp_input.hlb = repmat(0, length([SWIFT.time]),1);
pwp_input.tau = repmat(0, length([SWIFT.time]),1);
pwp_input.rain = repmat(0, length([SWIFT.time]),1);

% vars in depth
pwp_input.t = [15.5; repmat(15, length(profile.z)-1,1)]; % fake gradient to prevent error for flat profile and help define mld
pwp_input.s = repmat(30, length(profile.z),1);

% Check vars in each array and assign

PWPvars = {'time', 'winddirT', 'sw_net', 'lw_net', 'hsb', 'hlb', 'tau', 'rain', 'z', 't','s'};
inputs = {'SWIFT', 'fluxes','profile'};

for i = 1:length(inputs);
    eval(['missing{i} = setdiff(PWPvars, fieldnames(', inputs{i}, '));']);

    present{i} = setdiff(PWPvars, missing{i});

    for ii = 1:length(present{i})
        if i == 1 | ~any(ismember(horzcat(present{1:i-1}), present{i}{ii}));
            eval(['pwp_input.(present{i}{ii}) = vertcat(', inputs{i},'.', present{i}{ii},');']);
            pwp_input.(present{i}{ii}) = fillmissing(pwp_input.(present{i}{ii}),"nearest");
            fprintf('Assigning %s and filling NaN with nearest value\n', present{i}{ii});
        else
            warning(sprintf('Conflicting input vars across met and profile structure, ignoring %s value in %s input', present{i}{ii}, inputs{i}));
        end
    end
end

horzcat(missing{:});
[~, ~, idx] = unique(ans);
counts = accumarray(idx,1);
missing = ans(counts == 3);

if ~isempty(missing)
    warning(sprintf('Missing %s from inputs, keeping default vals established in header\n', string(missing)))
end



% Setting up vars for model run

time = pwp_input.time(1):dtd:pwp_input.time(end);
nmet = length(time);
clear dtd
qi = interp1([pwp_input.time],pwp_input.sw_net,time); 
qo = interp1([pwp_input.time],(pwp_input.lw_net + pwp_input.hlb + pwp_input.hsb),time); 


tx = interp1([pwp_input.time],pwp_input.tau.*sind(pwp_input.winddirT),time);
ty = interp1([pwp_input.time],pwp_input.tau.*cosd(pwp_input.winddirT),time);
precip = interp1([pwp_input.time],pwp_input.rain,time);
% make depth grid
zmax = max(profile.z);
if zmax < depth
    depth = zmax;
    disp(['Profile input shorter than depth selected, truncating to ' num2str(zmax)])
end
clear zmax
z = 0:dz:depth;
nz = length(z);
% Check the depth-resolution of the profile file
profile_increment = (pwp_input.z(end)-pwp_input.z(1))/(length(pwp_input.z)-1);
if dz < profile_increment/5
    yorn = input('Depth increment, dz, is much smaller than profile resolution. Is this okay? (y/n)','s');
    if yorn == 'n'
        error(['Please restart PWP.m with a new dz >= ' num2str(profile_increment/5)])
    end
end
t = zeros(nz,nmet);
s = zeros(nz,nmet);
t(:,1)	= interp1(pwp_input.z,pwp_input.t,z.','linear','extrap');
s(:,1)	= interp1(pwp_input.z,pwp_input.s,z.','linear','extrap');
d	= calc_seawater_density(s(:,1),t(:,1), gsw_p_from_z(-z(:),lat), lon, lat);
% Interpolate evaporation minus precipitaion at dt resolution
evap = (0.03456/(86400*1000))*interp1(pwp_input.time,pwp_input.hlb,floor(time),'nearest');
emp	= evap - precip;
emp(isnan(emp)) = 0;


%--------------------------------------------------------------------------
% preallocate space
u = zeros(nz,nmet); % east velocity m/s
v = zeros(nz,nmet); % north velocity m/s
% set initial conditions in PWP 18 Mar 2013
%u(1:13,1) = -5.514e-2;v(1:13,1) = -1.602e-1; 
mld = zeros(1,nmet); % mized layer depth m
absrb = absorb(beta1,beta2,nz,dz); % absorbtion of incoming rad. (units?)
dstab = dt*rkz/dz^2; % Courant number
if dstab > 0.5
    disp('!unstable CFL condition for diffusion!')
    pause
end

% output space
pwp_output.dt = dt;
pwp_output.dz = dz;
pwp_output.lat = lat;
pwp_output.z = z;
pwp_output.time	= zeros(nz,floor(nmet/dt_save));
pwp_output.t = zeros(nz,floor(nmet/dt_save));
pwp_output.s = zeros(nz,floor(nmet/dt_save));
pwp_output.d = zeros(nz,floor(nmet/dt_save));
pwp_output.u = zeros(nz,floor(nmet/dt_save));
pwp_output.v = zeros(nz,floor(nmet/dt_save));
pwp_output.mld	= zeros(nz,floor(nmet/dt_save));


%--------------------------------------------------------------------------
% model loop
for n = 2:nmet
     fprintf('loop iter. %2d, %g%% done\n', n, (n/nmet*100));
    % pwpgo function does the "math" for fluxes and vel
    [s(:,n), t(:,n), u(:,n), v(:,n), mld(n)] = pwpgo(qi(n-1),qo(n-1),emp(n-1),tx(n-1),ty(n-1), ...
        dt,dz,g,cpw,rb,rg,nz,z,t(:,n-1),s(:,n-1),d,u(:,n-1),v(:,n-1),absrb,f,ucon,n,lat,lon);
    
    % vertical (diapycnal) diffusion
    if rkz > 0
        diffus(dstab,t);
        diffus(dstab,s);
        d = calc_seawater_density(s,t, gsw_p_from_z(-z(:),lat), lon, lat);
        diffus(dstab,u);
        diffus(dstab,v);
    end % diffusion

    % Diagnostic plots
    switch diagnostics
        case 1
            figure(1)
            subplot(211)
            plot(time(n)-time(1),trapz(z,.5.*d.*(u(:,n).^2+v(:,n).^2)),'b.')
            if n == 2
                set(gcf,'position',[1 400 700 400])
                hold on
                grid on
                title('depth int. KE')
            end
            subplot(212)
            plot(time(n)-time(1),trapz(z,d.*sqrt(u(:,n).^2+v(:,n).^2)),'b.')
            if n == 2
                hold on
                grid on
                title('depth int. momentum')
            end
            figure(2)
            if n == 2
                set(gcf,'position',[700 400 700 400])
            end
            
            subplot(121)
            plot(u(:,n),z,'b',v(:,n),z,'r')
            axis ij
            grid on
            xlabel('u (b) v (r)')
            subplot(143)
            plot(t(:,n),z,'b')
            axis ij
            grid on
            xlabel('temp')
            subplot(144)
            plot(s(:,n),z,'b')
            axis ij
            grid on
            xlabel('salinity')
            
            pause(.2)
        case 2
            mom = zeros(1,nmet);
            if n == nmet
                for k = 1:nmet
                    mom(k) = trapz(z,d.*sqrt(u(:,k).^2+v(:,k).^2));
                    mli = find(sqrt(u(:,k).^2+v(:,k).^2) < 10^-3,1,'first');
                    mld(k) = z(mli);
                end
                w = u(1,:)+1i*v(1,:);
                tau = tx+1i*ty;
                T = tau./mld;
                dTdt = gradient(T,dt);
                pi_w = d(1).*mld.*real((w./1i*f).*dTdt);
                
                figure(1)
                plot(time-time(1),mom,'b.-')

            end
        case 3
            if n == nmet
                plot(time-time(1),mld,'b.')
                axis ij
                pause
            end
    end
    
end % model loop
% save ouput
pwp_output.s = s(:,1:dt_save:end);
pwp_output.t = t(:,1:dt_save:end);
pwp_output.u = u(:,1:dt_save:end);
pwp_output.v = v(:,1:dt_save:end);
pwp_output.d = calc_seawater_density(pwp_output.s,pwp_output.t, gsw_p_from_z(-z(:).*ones(size(pwp_output.s)), lat), lon, lat);
time = repmat(time,nz,1);
pwp_output.time = time(:,1:dt_save:end);
mld(1)=mld(2);
pwp_output.mld = mld(:,1:dt_save:end);

save(pwp_output_file,'pwp_output', 'pwp_input')
toc
% PWP driver routine
%--------------------------------------------------------------------------

function [s t u v mld] = pwpgo(qi,qo,emp,tx,ty,dt,dz,g,cpw,rb,rg,nz,z,t,s, ...
    d,u,v,absrb,f,ucon,n, lat,lon)
    % pwpgo is the part of the model where all the dynamics "happen"
      
    t_old = t(1); s_old = s(1); 
    t(1) = t(1) + (qi*absrb(1)-qo)*dt./(dz*d(1)*cpw); 
    s(1) = s(1)/(1-emp*dt/dz); 
    

    % TEOS-10
    SA_old  = gsw_SA_from_SP(s_old,gsw_p_from_z(-z(1),lat) , lon, lat);   % convert salinity first
    Tf  = gsw_t_freezing(SA_old, gsw_p_from_z(-z(1),lat), 1);  

    if t(1) < Tf;
        t(1) = Tf;
    end
    
    %  Absorb solar radiation at depth.
    if size(dz*d(2:nz)*cpw,2) > 1
        t(2:nz) = t(2:nz)+(qi*absrb(2:nz)*dt)./(dz*d(2:nz)*cpw)'; %THIS IS THE ORIG ONE!
    else
        t(2:nz) = t(2:nz)+(qi*absrb(2:nz)*dt)./(dz*d(2:nz)*cpw);
    end
    
    d = calc_seawater_density(s,t, gsw_p_from_z(-z(:).*ones(size(s)),lat), lon, lat); 
    [t s d u v] = remove_si(t,s,d,u,v,z,lat,lon); %relieve static instability
    
    % original ml_index criteria
    ml_index = find(diff(d)>1E-4,1,'first'); %1E
    %ml_index = find(diff(d)>1E-3,1,'first');
    %ml_index = find( (d-d(1)) > 1e-4 ,1,'first');
    
    % debug MLD index
    %{
    figure(86)
    clf
    plot(d,-z,'b.-')
    hold on
    plot(d(ml_index),-z(ml_index),'r*')
    pause
    %}
    if isempty(ml_index)
	    error_text = 'Mixed layer depth is undefined';
	    error(error_text)
    end
    
    %  Get the depth of the surface mixed-layer.
    ml_depth = z(ml_index+1);
    mld = ml_depth; % added 2013 03 07 
    
    % rotate u,v do wind input, rotate again, apply mixing
    ang = -f*dt/2; % should be moved to main driver
    [u v] = rot(u,v,ang);
    du = (tx/(ml_depth*d(1)))*dt;
    dv = (ty/(ml_depth*d(1)))*dt;
    u(1:ml_index) = u(1:ml_index)+du;
    v(1:ml_index) = v(1:ml_index)+dv;
    
    % Apply drag to the current (this is a horrible parameterization of
    % inertial-internal wave dispersion).
    if ucon > 1E-10
	    u = u*(1-dt*ucon);
	    v = v*(1-dt*ucon);
    end
    [u v] = rot(u,v,ang);
    
    % Bulk Richardson number instability form of mixing (as in PWP).
    if rb > 1E-5
	    [t s d u v] = bulk_mix(t,s,d,u,v,g,rb,nz,z,ml_index,lat, lon);
    end
    
    % Do the gradient Richardson number instability form of mixing.
    if rg > 0
	    [t,s,~,u,v] = grad_mix(t,s,d,u,v,dz,g,rg,nz,z,lat,lon);
    end
    
    % Debugging plots
    %{
    figure(1)
    subplot(211)
    plot(1,1)
    hold on
    plot(u,z,'b')
    plot(v,z,'r')
    axis ij
    grid on
    xlim([-.2 .2])
    
    subplot(212)
    plot(1,1)
    hold on
    plot(s-30,z,'b')
    plot(t,z,'r')
    grid on
    axis ij
    xlim([2 6])
    pause(.05)
    clf
    %}
end % pwpgo

%--------------------------------------------------------------------------
function absrb = absorb(beta1,beta2,nz,dz)
    %  Compute solar radiation absorption profile. This
    %  subroutine assumes two wavelengths, and a double
    %  exponential depth dependence for absorption.
    %
    %  Subscript 1 is for red, non-penetrating light, and
    %  2 is for blue, penetrating light. rs1 is the fraction
    %  assumed to be red.
    
    rs1 = 0.6;
    rs2 = 1.0-rs1;
    %absrb = zeros(nz,1);
    z1 = (0:nz-1)*dz;
    z2 = z1 + dz;
    z1b1 = z1/beta1;
    z2b1 = z2/beta1;
    z1b2 = z1/beta2;
    z2b2 = z2/beta2;
    absrb = (rs1*(exp(-z1b1)-exp(-z2b1))+rs2*(exp(-z1b2)-exp(-z2b2)))';
end % absorb

%--------------------------------------------------------------------------

function [t s d u v] = remove_si(t,s,d,u,v,z,lat,lon)
    % Find and relieve static instability that may occur in the
    % density array d. This simulates free convection.
    % ml_index is the index of the depth of the surface mixed layer after adjustment,
    
    while 1
	    ml_index = find(diff(d)<0,1,'first');
	    if isempty(ml_index)
		    break
        end
        %%{
        figure(86)
        clf
        plot(d,'b-')
        hold on
	    [t s d u v] = mix5(t,s,d,u,v,ml_index+1,z,lat,lon);
        plot(d,'r-')
        
    end

end % remove_si
%--------------------------------------------------------------------------

function [t s d u v] = mix5(t,s,d,u,v,j,z,lat,lon)
    %  This subroutine mixes the arrays t, s, u, v down to level j.
    t(1:j) = mean(t(1:j));
    s(1:j) = mean(s(1:j));
    d(1:j) = calc_seawater_density(s(1:j),t(1:j), gsw_p_from_z(-z(1:j)',lat), lon, lat); 
    u(1:j) = mean(u(1:j));
    v(1:j) = mean(v(1:j));
end % mix5
    
    %--------------------------------------------------------------------------
    
function [u v] = rot(u,v,ang)
%  This subroutine rotates the vector (u,v) through an angle, ang
r = (u+1i*v)*exp(1i*ang);
u = real(r);
v = imag(r);

end %rot
    %--------------------------------------------------------------------------
    
function [t s d u v] = bulk_mix(t,s,d,u,v,g,rb,nz,z,ml_index,lat, lon)
    
    rvc = rb;
    for j = ml_index+1:nz
	    h 	= z(j);
	    dd 	= (d(j)-d(1))/d(1);
	    dv 	= (u(j)-u(1))^2+(v(j)-v(1))^2;
	    if dv == 0
		    dv = 1.0e-8;
        end
		rv = g*h*dd/dv;
	    if rv > rvc
            fprintf('Bulk mixed %g times\n', j-ml_index-1);
		    break
	    else
		    [t s d u v] = mix5(t,s,d,u,v,j,z,lat,lon);
	    end
    end

end % bulk_mix
%--------------------------------------------------------------------------

function [t s d u v] = grad_mix(t,s,d,u,v,dz,g,rg,nz,z,lat,lon)

    %  This function performs the gradeint Richardson Number relaxation
    %  by mixing adjacent cells just enough to bring them to a new
    %  Richardson Number.
    
    rc 	= rg;
    nmix = 0;
    
    %  Compute the gradient Richardson Number, taking care to avoid dividing by
    %  zero in the mixed layer.  The numerical values of the minimum allowable
    %  density and velocity differences are entirely arbitrary, and should not
    %  affect the calculations (except that on some occasions they evidently have!)
    
    j1 = 1;
    j2 = nz-1;
    
    while 1
        r = ones(size(1:j2)); % current grad richardson number up to j2
        %% 
	    for j = j1:j2
		    if j <= 0
			    keyboard
		    end
		    dd = (d(j+1)-d(j)); 
            if dd < 1.0e-3
                dv = 1e-3; % limit density difference.
            end   
            dv = (u(j+1)-u(j))^2+(v(j+1)-v(j))^2;
            if dv < 1.0e-6
                dv = 1e-6; % remove divide by 0;
            end             
            r(j) = g*dz*dd/dv/d(j); % allocate gradient richardson numbers
	    end
    
	    %  Find the smallest value of r in profile
	    [rs js] = min(r);
    
	    %  Check to see whether the smallest r is critical or not.
	    if rs > rc
            fprintf('Gradient mixed %g times\n', nmix);
		    return
        end

        % Check for infinite loop
        infloop = 1e9;
        if nmix > infloop
            error(sprintf('Infinite loop limit exceeds %g times\n', infloop));
        end
    
        %  Mix the cells js and js+1 that had the smallest Richardson Number
	    [t s d u v] = stir(t,s,d,u,v,rc,r,js,z,lat,lon);
    
	    %  Recompute the Richardson Number over the part of the profile
        %  that has changed (fixed at 5 entries)
	    j1 = js-2;
	    if j1 < 1
		     j1 = 1;
	    end
	    j2 = js+2;
	    if j2 > nz-1
		     j2 = nz-1;
        end
        nmix = nmix +1;
    end
end % grad_mix

%--------------------------------------------------------------------------
function [t s d u v] = stir(t,s,d,u,v,rc,r,js,z,lat,lon)
    
    %  This subroutine mixes cells j and j+1 just enough so that
    %  the Richardson number after the mixing is brought up to
    %  the value rnew. In order to have this mixing process
    %  converge, rnew must exceed the critical value of the
    %  richardson number where mixing is presumed to start. If
    %  r critical = rc = 0.25 (the nominal value), and r = 0.20, then
    %  rnew = 0.3 would be reasonable. If r were smaller, then a
    %  larger value of rnew - rc is used to hasten convergence.
    
    %  This subroutine was modified by JFP in Sep 93 to allow for an
    %  aribtrary rc and to achieve faster convergence.
    
    rcon 			= 0.02+(rc-r)/2;
    rnew 			= rc+rcon/5;
    f 				= 1-r(js)/rnew(js); % only apply to mixing boundary
    % Mix temperature
    dt				= (t(js+1)-t(js))*f/2;
    t(js+1)		= t(js+1)-dt;
    t(js) 			= t(js)+dt;
    % Mix salinity
    ds				= (s(js+1)-s(js))*f/2;
    s(js+1)		= s(js+1)-ds;
    s(js) 			= s(js)+ds;
    % find new density
    d(js:js+1) = calc_seawater_density(s(js:js+1),t(js:js+1), gsw_p_from_z(-z(js:js+1)',lat), lon, lat);
    % Mix velocity
    du				= (u(js+1)-u(js))*f/2;
    u(js+1)		= u(js+1)-du;
    u(js) 			= u(js)+du;
    dv				= (v(js+1)-v(js))*f/2;
    v(js+1)		= v(js+1)-dv;
    v(js) 			= v(js)+dv;

end % stir

%--------------------------------------------------------------------------
function [rho, rho_anomaly] = calc_seawater_density(SP, t, p, lon, lat)
% CALC_SEAWATER_DENSITY  Compute in-situ seawater density using TEOS-10.
%
% USAGE:
%   [rho, rho_anomaly] = calc_seawater_density(SP, t, p, lon, lat)
%
% INPUTS:
%   SP   - Practical Salinity          [PSU / PSS-78]   (scalar or array)
%   t    - In-situ temperature         [°C, ITS-90]     (same size as SP)
%   p    - Sea pressure                [dbar]           (same size as SP, or scalar)
%   lon  - Longitude                   [decimal degrees East, 0 – 360 or ±180]
%   lat  - Latitude                    [decimal degrees North, ±90]
%
% OUTPUTS:
%   rho         - In-situ density      [kg m⁻³]
%   rho_anomaly - Density anomaly      [kg m⁻³]  (rho - 1000)
%
% NOTES:
%   * Requires the GSW Toolbox  (https://www.teos-10.org/software.htm).
%     Verify installation with: gsw_check_functions
%
%
% REFERENCES:
%   IOC, SCOR & IAPSO (2010). The international thermodynamic equation of
%   seawater – 2010 (TEOS-10). Intergovernmental Oceanographic Commission,
%   Manuals and Guides No. 56. UNESCO.

    %  0. Input validation 

    narginchk(5, 5);

    if ~isnumeric(SP) || ~isnumeric(t) || ~isnumeric(p) || ...
       ~isnumeric(lon) || ~isnumeric(lat)
        error('calc_seawater_density:badInput', ...
              'All inputs must be numeric.');
    end

    % Broadcast scalar pressure to the size of SP if needed
    if isscalar(p)
        p = p .* ones(size(SP));
    end

    if ~isequal(size(SP), size(t), size(p))
        error('calc_seawater_density:sizeMismatch', ...
              'SP, t, and p must be the same size (or p may be scalar).');
    end

    % Soft range checks (warn, but do not error – GSW handles NaN masking)
    if any(SP(:) < 0 | SP(:) > 42, 'all')
        warning('calc_seawater_density:SPrange', ...
                'Some SP values are outside the typical range 0–42 PSU.');
    end
    if any(t(:) < -2 | t(:) > 40, 'all')
        warning('calc_seawater_density:Trange', ...
                'Some temperature values are outside the range -2–40 °C.');
    end
    if any(p(:) < 0 | p(:) > 12000, 'all')
        warning('calc_seawater_density:Prange', ...
                'Some pressure values are outside the range 0–12000 dbar.');
    end

    %  1. Check GSW toolbox availability

    if ~exist('gsw_SA_from_SP', 'file')
        error('calc_seawater_density:noGSW', ...
              ['GSW Toolbox not found on the MATLAB path.\n' ...
               'Download it from https://www.teos-10.org/software.htm ' ...
               'and add it to your path.']);
    end

    %  2. Practical Salinity  →  Absolute Salinity  (SA, g kg⁻¹)
    SA = gsw_SA_from_SP(SP, p, lon, lat);

    %  3. In-situ temperature  →  Conservative Temperature  (CT, °C)
    CT = gsw_CT_from_t(SA, t, p);


    %  4. Compute in-situ density  (kg m⁻³)
    rho = gsw_rho(SA, CT, p);

    %  5. Potential Density  (sigma, kg m⁻³)
    rho_anomaly = rho - 1000;

end