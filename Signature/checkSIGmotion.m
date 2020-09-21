% check for motion contamination in SWIFT v4 Signature data
% and test spectral processing for turbulent dissipation rate
% (for which key issue is choosing advective velocity)
%
%  general impression is that burst profiles do not have onboard motion
%  correct, but that the inertial subrange is still evident
%
%   the avg (i.e., broadband) profiles do appear to have onboard correction
%
%   J. Thomson, spring 2019, explore signals
%               Dec 2019, attempet direction motion correction... but
%               uncorrelated with raw signals and
%               Sep 2020, remove variance of motion from inertial subrange
%               Sep 2020 corrected bug in advective velocity applied to spectra
%
%
%

%% set up

clear

filename =  'SWIFT23_SIG_19Jan2020_18_01.mat';
load(filename);

xcdrdepth = 0.2; % depth of transducer [m]


%% check the 'burst' profiles from the center beam in HR mode
z = xcdrdepth + burst.Blanking + burst.CellSize * [1:size(burst.VelocityData,2)];
fs = length( burst.VelocityData(:,1) )./ ( range(burst.time)*24*3000 );
windowlength = 64;

w = burst.VelocityData;
% use gyro rotation rate (deg/sec) to get the motion projected onto
% vertical velocity w, but note that is this correct to w (not the
% correction to the beam measurement
wxrot =(deg2rad(burst.AHRS_GyroX))'*z; % no projection, just scalar tangent velocity
wxrotz = (deg2rad(burst.AHRS_GyroX).*sind(burst.Pitch))'*z; % projected onto vertical
wyrot =(deg2rad(burst.AHRS_GyroY))'*z;  % no projection, just tangent velocity
wyrotz = (deg2rad(burst.AHRS_GyroY).*sind(burst.Roll))'*z; % projected onto vertical
wnew = burst.VelocityData - wxrotz - wyrotz; % corrected vertical velocity?? prob not, since ~0 correlation of raw w/ motion

for HRbin=1:size(burst.VelocityData,2),
    w(:,HRbin) = filloutliers(w(:,HRbin), 'linear');
    [wpsd f] = pwelch(detrend( w(:,HRbin) ),windowlength, [], [], fs);
    [wxpsd f] = pwelch(detrend( wxrotz(:,HRbin) ),windowlength, [], [], fs);
    [wypsd f] = pwelch(detrend( wyrotz(:,HRbin) ),windowlength, [], [], fs);
    [wnpsd f] = pwelch(detrend( wnew(:,HRbin) ),windowlength, [], [], fs);
    [azpsd f] = pwelch(detrend( burst.Accelerometer(:,3) ),windowlength, [], [], fs);
    df = median(diff(f));
    
    inertial = find(f>1);
    tkepsd = wpsd - wxpsd - wypsd; % option to remove motion variance from inertial subrange
    compwpsd = mean( tkepsd(inertial) .* ( 2*3.14* f(inertial)).^(5/3) )./ 8;
    
    %% many choices for advective velocity of "frozen field"
    %advect = ( var(w(:,HRbin)) - var(wxrotz(:,HRbin)) - var(wyrotz(:,HRbin)) ).^.5; % remove variance from motion to get turbulent self-advection
    %advect = ( var(wnew(:,HRbin)) - var(wxrotz(:,HRbin)) ).^.5; % remove variance from motion to get turbulent self-advection
    advect = std(w(:,HRbin)); % simplest interp of Tennekes '75
    %advect = std(wnew(:,HRbin));
    %advect = nansum(tkepsd(inertial)*df).^5;
    %advect = mean((mean(avg.VelocityData(:,1:2,1)).^2 + mean(avg.VelocityData(:,1:2,2)).^2).^.5); % horizontal advection from BB profiles
    %advect = std((mean(avg.VelocityData(:,1:2,1)).^2 + mean(avg.VelocityData(:,1:2,2)).^2).^.5); % horizontal advection from BB profiles
    %advect = 0.1; % constant, for testing
    %advect = nanmean(w(:,HRbin)); % decay with depth, for testing
    
    if advect>0 & compwpsd > 0,
        epsilon(HRbin) = ( compwpsd .* advect.^(-2/3) ).^(3/2);
    else
        epsilon(HRbin) = NaN;
    end
    
    figure(1), clf
    loglog(f, azpsd.*1e-7, 'k'), hold on
    loglog(f, wpsd, f, wxpsd, f, wypsd, f, wnpsd), hold on
    loglog( f, wnpsd,':'), hold on
    loglog([1 3],1e-1*[1 3].^(-5/3),'--','color',[.7 .7 .7],'linewidth',3)
    legend('a_z','w','w_{xr}','w_{yr}','w_n','Location','NortheastOutside')
    xlabel('f [Hz]')
    axis([1e-2 1e1 1e-4 1e1])
    title([filename ', HRbin ' num2str(HRbin)],'interpreter','none')
    print('-dpng',[filename(1:end-4) '_HRbin' num2str(HRbin) '.png'])
    
end

figure(2), clf
subplot(1,2,1)
plot(var(burst.VelocityData),z,var(wxrotz),z,var(wyrotz),z,var(wnew),z)
set(gca,'YDir','reverse','YLim',[0 3])
ylabel('z [m]')
xlabel('velocity variance [m^2/s^2]')
legend('w measured','w rotation x','w rotation y','w corrected')
title([filename(1:end-4) ],'interpreter','none')

subplot(1,2,2)
semilogx(epsilon,z),
set(gca,'ydir','reverse','YLim',[0 3])
ylabel('z [m]')
xlabel('\epsilon [W/Kg]')
print('-dpng',[filename(1:end-4) '_HRvelocitystddevs_epsilons.png'])



%% check the 'avg' profiles from the slant beams in broadband mode
profilez = xcdrdepth + avg.Blanking + avg.CellSize./2 + ( avg.CellSize * [1:size(avg.VelocityData,2)] );
zbin = 25; % pick a bin to look at (out of 40 at 0.5 m spacing)
fs = length(avg.time)./(range(avg.time)*24*3600);
windowlength = 32;

[upsd f] = pwelch(detrend( avg.VelocityData(:,zbin,1) ),windowlength, [], [], fs);
[vpsd f] = pwelch(detrend(avg.VelocityData(:,zbin,2) ),windowlength, [], [], fs);
[w1psd f] = pwelch(detrend(avg.VelocityData(:,zbin,3) ),windowlength, [], [], fs);
[w2psd f] = pwelch(detrend(avg.VelocityData(:,zbin,4) ),windowlength, [], [], fs);

[azpsd f] = pwelch(detrend(avg.Accelerometer(:,3)),[], [], [], fs);

figure(10), clf
loglog(f, azpsd.*1e-7, 'k'), hold on
loglog(f, upsd, f, vpsd, f, w1psd, f, w2psd), hold on
legend('a_z','u','v','w_1','w_2','Location','NortheastOutside')
xlabel('f [Hz]')
title([filename ', avg bin ' num2str(zbin)],'interpreter','none')
print('-dpng',[filename(1:end-4) '_avgbin' num2str(zbin) '.png'])