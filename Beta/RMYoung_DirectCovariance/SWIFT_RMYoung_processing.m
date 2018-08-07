% SWIFT RM Young and IMU processing
%
% Loop through files, grabs raw IMU and sonic data, pass to motion
% correction function, and calculate relevant quantities, saved in
% structure 'sonic'


clc
clear

plots = 1;

IMU_path = '../Data/08Mar2018/SWIFT13/COM-6/Raw/20180308/';
IMU_files = dir([IMU_path '*.dat']);
Sonic_path = '../Data/08Mar2018/SWIFT13/Y81/Raw/20180308/';
Sonic_files = dir([Sonic_path '*.dat']);

%declination = -17.3; %magnetic declination = -17.3 for Quebec
declination = 0; %Should report in true north aparently

for ii = 7%5:length(Sonic_files)%
    load([IMU_path IMU_files(ii).name(1:end-3) 'mat'])
    load([Sonic_path Sonic_files(ii).name(1:end-3) '.mat'])
    
    %CHECK FOR EXISTINCE OF REAL GPS DATA
    do_calcs=1;
    if ~isempty(GPS)
        if any(any(GPS.NED_Vel.Velocity_NED))
            do_calcs=1;
        else
            do_calcs=0;
        end
    else
        do_calcs = 0;
    end
    if do_calcs
        
        [sonic_time, uvw_cor] = RMYoung_motion_correction(uvw, AHRS, GPS, plots);
        
        % ------------ Calculations - means, wind stress, heat flux --------
        theta = atan2d(nanmean(uvw_cor(:,2)), nanmean(uvw_cor(:,1)) );
        
        %rotate into along-wind and cross-wind components
        R = [cosd(theta), -sind(theta);...
            sind(theta), cosd(theta)];
        uv_prime = R'*(uvw_cor(:,1:2)');
        uv_prime_mean = nanmean( uv_prime,2);
        U = uv_prime_mean(1); V = uv_prime_mean(2);
        magnitude = nanmean(sqrt(sum(uv_prime.^2,1)));
        
        %convert oceanographic convention
        theta = -theta + 90;
        theta(theta < 0) = theta(theta<0) + 360;
        %adjust for declination
        theta = theta+declination;
        
        %Try some spectra, see if it looks OK
        window_sz = 512;
        noverlap = [];
        z = 1;
        
        %Inertial dissipation method
        [Pww,f] = pwelch(detrend(uvw_cor(:,3)), window_sz,noverlap,[],10);
        f_inds = find(f*z/U > 0.75);
        K = 0.55;
        epsilon = ( nanmean( Pww(f_inds).*f(f_inds).^(5/3) ) ./ K.*(U./2./pi).^(2/3) ).^(3/2);
        u_star_inertial = (0.4 * epsilon .* z).^(1/3);
        z0_inertial = 1./exp( U/u_star_inertial * 0.4);
        U10_inertial = log(10/z0_inertial) / log(1/z0_inertial) * U;
        Cd_inertial = (u_star_inertial./U10_inertial).^2;
        
        %Cov method
        C = cov(uvw_cor(:,3), uv_prime(1,:));
        C2 = cov(detrend(uvw_cor(:,3)), detrend(uv_prime(2,:)));
        C_raw = cov(detrend(uvw(:,3)), detrend(uvw(:,2)));
        C2_raw = cov(detrend(uvw(:,3)), detrend(uvw(:,1)));
        u_star = (C(2,1).^2 + C2(2,1).^2).^(1/4); %direct cov ustar....
        z0 = 1./exp( U/u_star * 0.4);
        U10 = log(10/z0) / log(1/z0) * U;
        Cd_cov = (u_star./U10).^2;
        
        %Heat Flux estimate from Sonic Temp
        heatflux = cov(sonic_temp, uvw_cor(:,3));
        heatflux = heatflux(2,1);
        
        if plots==1
            figure(5),clf
            hold on
            %subplot(1,2,1)
            loglog(f, Pww)
            plot(f(20:end), f(20:end).^(-5/3)/5,'--r')
            xlabel('f [Hz]')
            ylabel('PSD [m^2/Hz]')
            legend('Pww Rotated','-5/3')
            set(gca,'yscale','log','xscale','log')
            grid on
            
            %COspectrum of uw
            [Puw,f] = cpsd(detrend(uv_prime(1,:)), detrend(uvw_cor(:,3)), window_sz,noverlap,[],10);
            [Pvw,f] = cpsd(detrend(uv_prime(2,:)), detrend(uvw_cor(:,3)), window_sz,noverlap,[],10);
            [Puw_raw,f] = cpsd(detrend(uvw(:,1)), detrend(uvw(:,3)), window_sz,noverlap,[],10);
            
            figure(6),clf
            hold on
            semilogx(f, f.*real(Puw),'linewidth',2);
            semilogx(f, f.*real(Puw_raw),'--');
            semilogx(f, f.*real(Pvw),'linewidth',2)
%             semilogx(f, f.*real(Pvw))
%             A = 7/(3*pi)*sin(3/7*pi);
%             f0 = 0.06;
%             kaimal = -A*(f./f0) ./ (1 + (f/f0).^(7/3)) *0.05;
%             semilogx(f, kaimal,'k')
            set(gca,'xscale','log')
            legend({'Motion Corrected','Raw','Co_{uv}'})
            grid on
            xlabel('f [Hz]')
            ylabel('Co_{uw}(f)f')
            
            %cospectrum of w and sonic temp
            [Ptw,f] = cpsd(detrend(sonic_temp), detrend(uvw_cor(:,3)), window_sz,noverlap,[],10);
            [Ptw_raw,f] = cpsd(detrend(sonic_temp), detrend(uvw(:,3)), window_sz,noverlap,[],10);
            
            figure(7),clf
            hold on
            semilogx(f, f.*real(Ptw));
            semilogx(f, f.*real(Ptw_raw),'--')
%             f0 = 0.6;
%             A = 7/(3*pi)*sin(3/7*pi);
%             kaimal = A*(f./f0) ./ (1 + (f/f0).^(7/3)) .* heatflux;
%             semilogx(f, kaimal,'k')
            legend({'Motion Corrected','Raw'})
            set(gca,'xscale','log')
            grid on
            xlabel('f [Hz]')
            ylabel('Co_{T_sw}(f)f')
        end
        %save variables
        sonic(ii).time10Hz = sonic_time;
        sonic(ii).uvw_raw = uvw;
        sonic(ii).uvw_cor = uvw_cor;
        sonic(ii).time = nanmean(sonic_time);
        sonic(ii).winddirT = theta;
        sonic(ii).windspd = magnitude;
        sonic(ii).UV = uv_prime_mean; %rotated into along and cross directions
        sonic(ii).u_star_cov = u_star;
        sonic(ii).z0_cov = z0;
        sonic(ii).cd10_cov = Cd_cov;
        sonic(ii).u_star_inertial = u_star_inertial;
        sonic(ii).z0_inertial = z0_inertial;
        sonic(ii).cd10_inertial = Cd_inertial;
        Cp = 4220;        % Cp is ~ 4.22 kJ/(kg*C)
        rho = 1025;
        sonic(ii).heatflux = rho*Cp*heatflux; %kW to W
        
    else %if bad AHRS/GPS/Sonic data, report NaNs
        sonic(ii).time10Hz = NaN;
        sonic(ii).uvw_raw = NaN;
        sonic(ii).uvw_cor = NaN;
        sonic(ii).time = NaN;
        sonic(ii).winddirT = NaN;
        sonic(ii).windspd = NaN;
        sonic(ii).UV = NaN;
        sonic(ii).u_star_cov = NaN;
        sonic(ii).z0_cov = NaN;
        sonic(ii).cd10_cov =NaN;
        sonic(ii).u_star_inertial = NaN;
        sonic(ii).z0_inertial = NaN;
        sonic(ii).cd10_inertial = NaN;
        sonic(ii).heatflux = NaN;
    end
    
    disp(['u_* inertial: ' num2str(u_star_inertial,3)])
    disp(['C_d inertial: ' num2str(Cd_inertial,3)])
    disp(['u_* cov: ' num2str(u_star,3)])
    disp(['C_d cov: ' num2str(Cd_cov,3)])
    disp(['<Ts''w''>: ' num2str(heatflux)])
    disp(['U: ' num2str(U) ' V: ' num2str(V) ' Theta: ' num2str(theta)])
    
end