% SWIFT RM Young and IMU processing
%
% Loop through files, grabs raw IMU and sonic data, pass to motion
% correction function, and calculate relevant quantities, saved in
% structure 'sonic'
% S Zippel, 2018?
% J. Thomson, 12/2019 revs


clc
clear

tic

plots = 1;
parentdir = pwd;

cd(parentdir)
wd = pwd;
wdi = find(wd == '/',1,'last');
wd = wd((wdi+1):length(wd));

load([wd '.mat'])

cd('./Y81/Raw/')


%% loop thru raw data

dirlist = dir('20*');

for di = 1:length(dirlist),
    
    cd([dirlist(di).name])
    filelist = dir('*.dat');
    
    for fi=1:length(filelist),
        
        disp(['file ' num2str(fi) ' of ' num2str(length(filelist)) ])
        
        if filelist(fi).bytes > 1e5,
        RMYdata = importdata([filelist(fi).name]);
        uvw = RMYdata.data(:,1:3);
        temp = RMYdata.data(:,4);
        errorflag = RMYdata.data(:,5);
        else 
            uvw = NaN(1000,3);
            temp = NaN(1000,1);
            errorflag = NaN(1000,1);
        end
        
        windspd = mean((uvw(:,1).^2 + uvw(:,2).^2 + uvw(:,3).^2).^.5);
        windspd_alt = (mean(uvw(:,1)).^2 + mean(uvw(:,2).^2)).^.5;
        
        z = 0.71; % SWIFT.metheight
        fs = 10;
        
        [ustar epsilon meanu meanv meanw meantemp anisotropy quality freq tkespectrum ] = inertialdissipation(uvw(:,1), uvw(:,2), uvw(:,3), temp, z, fs);
        
        
        
        %% match time to SWIFT structure and replace values
        time=datenum(filelist(fi).name(13:21))+datenum(0,0,0,str2num(filelist(fi).name(23:24)),(str2num(filelist(fi).name(26:27))-1)*12,0);
        [tdiff tindex] = min(abs([SWIFT.time]-time));
        bad(tindex) = false;
        updated(tindex) = false;
        if ~isempty(tdiff) && tdiff < 1/(24*5)
            SWIFT(tindex).windspd = windspd;
            SWIFT(tindex).winddirR = NaN;
            if ustar ~= 9999
                SWIFT(tindex).windustar = ustar;
                updated(tindex) = true;
            end
        else
        end
        
                if plots
            figure(1), clf
            subplot(3,1,1)
            plot(uvw)
            ylabel('m/s'),
            legend('u','v','w')
            subplot(3,1,2)
            plot(temp)
            ylabel('deg C')
            subplot(3,1,3)
            plot(errorflag)
            ylabel('error flag')
            
            figure(2), clf
            loglog(freq,tkespectrum)
            hold on
            loglog([.5 2],1e0*[.5 2].^-(5/2))
            xlabel('f [Hz]'),ylabel('TKE [m^2/s^2/Hz]')
            
        end

        
        
    end
    
    cd('../')
    
end

cd(parentdir)

figure(3), clf
plot([SWIFT.windspd],[SWIFT.windustar],'bx')
hold on
plot([SWIFT(updated).windspd],[SWIFT(updated).windustar],'r.')
legend('onboard','updated')
xlabel('Wind spd [m/s]')
ylabel('Friction Vel [m/s]')
axis([0 20 0 1]), grid
print('-dpng',[wd '_windstress.png'])


save([ wd '_reprocessedY81.mat'],'SWIFT')

toc