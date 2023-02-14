% Re-read RAW (.dat) signature data (readSWIFTv4_SIG), saves as mat file,
%   and plot contents in detail. Option to load .mat file if just
%   interested in plotting detail for burst data.

%      Requires parent directories to:
%       - read raw .dat signature files (rawdir)
%       - save raw .mat files (matdir)
%       - save figures (figdir)

%      Defines correlation + amplitude minimums to visualize impact of QC,
%      but no QC is performed here. QC is performed if reprocess_SIG is
%      called later.

%      Figure plotting (and saving) can be toggled on/off.

%      If desired, can only run specific missions by correctly populating
%      list of SWIFT missions (e.g. SWIFTs = dir('SWIFT23*Apr*'); populates
%      only SWIFT 23 missions in APril.

%       K.Zeiden, February 2022

%Relevent directories
datdir = 'C:\Users\kfitz\Dropbox\MATLAB\LC-DRI\Data\SWIFT\Raw\SIG\';
matdir = 'C:\Users\kfitz\Dropbox\MATLAB\LC-DRI\Data\SWIFT\Raw\SIG\';
figdir = 'C:\Users\kfitz\Dropbox\MATLAB\LC-DRI\Figures\SIG\Raw\';

%Toggle load raw dat files
loaddat = true;

%QC Params
mincor = 50;
minamp = 60;

%Toggle figures/Plotting params
plotfig = false;
savefig = false;
amplim = [minamp 150];
corlim = [mincor 100];
ulim = [-0.5 0.5];

%Populate list of SWIFT missions to re-read signature data for
cd(matdir)
SWIFTs = dir('SWIFT22*20Mar*');
SWIFTs = {SWIFTs.name};

%Create folders if necessary
cd(matdir)
matfold = dir('SWIFT*');
for iswift = 1:length(SWIFTs)
    if ~any(strcmp({matfold.name},SWIFTs{iswift}))
        mkdir([SWIFTs{iswift} '\SIG\Raw\'])
    end
end

%Pre-set variables
xcdrdepth = 0.2;

%% Re-read in raw data for each mission, save mat file (if loading .dat), plot, save figure

for iswift = 1:length(SWIFTs)
    
    SNread = SWIFTs{iswift};

    %Creat list of individual burst files (.dat)
    if loaddat
        cd([datdir SNread '\SIG\Raw'])
    else
        cd([matdir SNread '\SIG\Raw'])
    end
        foldlist = dir('2017*');
    
    for ifold = 1:length(foldlist)
        if loaddat
            cd([datdir SNread '\SIG\Raw\' foldlist(ifold).name])
            bfiles = dir('*.dat');
        else
            cd([matdir SNread '\SIG\Raw\' foldlist(ifold).name])
            bfiles = dir('*.mat');
        end
        nburst = length(bfiles);
        
        % Load (Raw) ADCP Data + Plot
        for iburst = 1:nburst
            fsize = dir(bfiles(iburst).name);
            if fsize.bytes<10^4
                disp('Small file')
                continue
            end

            %Re-read in *raw* burst files
            disp(['Reading in ' bfiles(iburst).name ' ...'])
            
            tic
            if loaddat
            [burst,avg,battery,echo] = readSWIFTv4_SIG(bfiles(iburst).name);
            savefold = [matdir SNread '\SIG\Raw\' foldlist(ifold).name '\'];
            save([savefold bfiles(iburst).name(1:end-4) '.mat'],...
                'avg','burst','battery','echo')
            else
                load(bfiles(iburst).name)
            end
            toc
          
            %Burst timestamp
            day = bfiles(iburst).name(13:21);
            hour = bfiles(iburst).name(23:24);
            mint = bfiles(iburst).name(26:27);
            btime = datenum(day)+datenum(0,0,0,str2double(hour),(str2double(mint)-1)*12,0);

            %Depths
            burst.z = xcdrdepth + burst.Blanking + burst.CellSize*[1:size(burst.VelocityData,2)];
            avg.z = xcdrdepth + avg.Blanking + avg.CellSize.*[1:size(avg.AmplitudeData,2)];

            %Correlation & Amplitude QC
            burst.QC = burst.CorrelationData < mincor | burst.AmplitudeData < minamp;
            avg.QC = avg.CorrelationData < mincor | avg.AmplitudeData < minamp;

            %Number of Beams
            nbeam = size(avg.VelocityData,3);

            %Burst-average profiles  
            velavg = avg.VelocityData;
            velavg_qc = velavg;
            velavg_qc(avg.QC) = NaN;
            velavg = squeeze(nanmean(velavg,1));
            velavg_qc = squeeze(nanmean(velavg_qc,1));

            if plotfig
                
                % Plot burst + avg data
                figure('color','w')
                MP = get(0,'monitorposition');
                set(gcf,'outerposition',MP(1,:));
                h = tight_subplot(8,3,0.01,[0.1 0.05],[0.05 0.15]);
                %Burst Mode
                axes(h(1))
                imagesc(burst.time,burst.z,burst.CorrelationData')
                c = slimcolorbar;
                c.Label.String = 'Correlation';
                caxis(corlim)
                title([SNread(1:7) ' - ' datestr(btime,'mmm dd - HH:MM')])
                ylabel('Depth (m)')
                axes(h(4))
                imagesc(burst.time,burst.z,burst.AmplitudeData')
                c = slimcolorbar;
                c.Label.String = 'Amplitude';
                datetick('x','KeepLimits')
                ylabel('Depth (m)')
                caxis(amplim)
                axes(h(7))
                imagesc(burst.time,burst.z,burst.VelocityData')
                c = slimcolorbar;
                c.Label.String = 'Velocity';
                datetick('x','KeepLimits')
                ylabel('Depth (m)')
                caxis(ulim)
                colormap(gca,cmocean('balance'))
                axes(h(10))
                imagesc(burst.time,burst.z,burst.QC')
                hold on
                plot(xlim,burst.z([4 4]),'r','LineWidth',2)
                ylabel('Depth (m)')
                c = slimcolorbar;
                c.Label.String = 'Exclude';
                colormap(gca,flipud(gray))
                axes(h(13))
                yyaxis right
                plot(burst.time,burst.Temperature)
                ylabel('T (^\circC)')
                axis tight
                yyaxis left
                plot(burst.time,burst.Pressure)
                ylabel('P (dbar)')
                axis tight
                datetick('x','HH:MM','KeepLimits')
                % Broadband Mode
                ip = [2 3 14 15];
                for ibeam = 1:nbeam
                axes(h(ip(ibeam)))
                imagesc(avg.time,avg.z,squeeze(avg.CorrelationData(:,:,ibeam))')
                hold on
                plot(xlim,max(burst.z)*[1 1],'k')
                caxis(corlim)
                title(['Beam ' num2str(ibeam)'])
                % t(ibeam) = textlab(['Beam ' num2str(ibeam)],'bottomleft');
                if mod(ip(ibeam),3)== 0; ylabel('Depth (m)'); end; set(gca,'YAxisLocation','right')
                axes(h(ip(ibeam)+3))
                imagesc(avg.time,avg.z,squeeze(avg.AmplitudeData(:,:,ibeam))')
                hold on
                plot(xlim,max(burst.z)*[1 1],'k')
                datetick('x','HH:MM','KeepLimits')
                caxis(amplim)
                % colormap(gca,cmocean('thermal'))
                if mod(ip(ibeam),3)== 0; ylabel('Depth (m)'); end; set(gca,'YAxisLocation','right')
                axes(h(ip(ibeam)+6))
                imagesc(avg.time,avg.z,squeeze(avg.VelocityData(:,:,ibeam))')
                hold on
                plot(xlim,max(burst.z)*[1 1],'k')
                datetick('x','HH:MM','KeepLimits')
                cmocean('balance')
                caxis(ulim)
                if mod(ip(ibeam),3)== 0; ylabel('Depth (m)'); end; set(gca,'YAxisLocation','right')
                axes(h(ip(ibeam)+9))
                imagesc(avg.time,avg.z,squeeze(avg.QC(:,:,ibeam))')
                hold on
                plot(xlim,max(burst.z)*[1 1],'k')
                datetick('x','HH:MM','KeepLimits')
                colormap(gca,flipud(gray))
                caxis([0 1])
                if mod(ip(ibeam),3)== 0; ylabel('Depth (m)'); end; set(gca,'YAxisLocation','right')
                end
                %Burst-Average Profiles
                axes(h(22))
                axu = gca;
                axu.Position = axu.Position.*[1 1 0.5 3];
                plot(velavg(:,1),avg.z,'c','LineWidth',2)
                hold on
                plot(velavg(:,2),avg.z,'m','LineWidth',2)
                plot(velavg_qc(:,1),avg.z,':c','LineWidth',2)
                hold on
                plot(velavg_qc(:,2),avg.z,':m','LineWidth',2)
                plot([0 0],ylim,':k')
                legend('B1','B2','QC','QC','FontSize',7.5)
                xlim(ulim*0.75);set(gca,'YDir','Reverse')
                ylabel('Depth (m)')
                xlabel('U_{rel}(z) (m/s)')
                ylim([0 max(avg.z)+1])
                axes(h(19))
                axw = gca;
                axw.Position = axu.Position;
                axw.Position = axw.Position + [axu.Position(3)+0.02 0 0 0];
                plot(velavg(:,3),avg.z,'g','LineWidth',2)
                hold on
                plot(velavg(:,4),avg.z,'color',rgb('grey'),'LineWidth',2)
                plot(velavg_qc(:,3),avg.z,':g','LineWidth',2)
                plot(velavg_qc(:,4),avg.z,':','color',rgb('grey'),'LineWidth',2)
                plot([0 0],ylim,':k')
                xlim(ulim*0.1);set(gca,'YDir','Reverse')
                axw.YTickLabel = [];
                legend('B3','B4','QC','QC','FontSize',7.5)
                xlabel('U_{rel}(z) (m/s)')
                ylim([0 max(avg.z)+1])
                set(h([1:12 14:18 20:21]),'XTickLabel',[])
                set(h(2:3:24),'YTickLabel',[])
                for ishift = unique([2:3:24 3:3:24])
                    h(ishift).Position = h(ishift).Position + [0.065 0 0 0];
                end
                for ishift = unique([14:3:24 15:3:24])
                    h(ishift).Position = h(ishift).Position + [0 -0.015 0 0];
                end
                for ishift = unique([2:3:12 3:3:12])
                    h(ishift).Position = h(ishift).Position + [0 0.015 0 0];
                end
                for ishift = 3:3:24
                    h(ishift).Position = h(ishift).Position + [0.01 0 0 0];
                end
                rmemptysub
                drawnow
                if savefig
                    saveas(gcf,[figdir SNread '\' dfiles(ifile).name(1:end-4) '.png'])
                    close gcf
                end

                % Motion Metrics
                figure('Name','Motion','color','w')
                h = tight_subplot(3,2,[0.01 0.025],0.1,0.1);
                MP = get(0,'monitorposition');
                set(gcf,'outerposition',MP(1,:));
                axes(h(1))
                scatter(avg.time,(avg.Heading-180)*pi/180,10,'filled')
                hold on
                scatter(avg.time,avg.Pitch*pi/180,10,'filled')
                scatter(avg.time,avg.Roll*pi/180,10,'filled')
                axis tight
                plot(xlim,[-pi -pi],':k')
                plot(xlim,[pi pi],':k')
                set(gca,'YTick',[-pi -pi/2 0 pi/2 pi],'YTickLabel',{'-\pi','-\pi/2','0','\pi/2','\pi'})
                ylabel('[rad]')
                textlab('Orientation','topleft');
                legend('Heading(-\pi)','Pitch','Roll')
                title([SNread(1:7) ' - ' datestr(btime,'mmm dd - HH:MM')])
                axes(h(3))
                plot(avg.time,avg.Magnetometer)
                hold on
                plot(avg.time,sqrt(nansum(avg.Magnetometer.^2,2)),'k')
                axis tight
                ylabel('[counts]')
                textlab('Magnetometer','topleft');
                legend('M_x','M_y','M_z')
                axes(h(5))
                plot(avg.time,avg.Accelerometer)
                axis tight
                ylabel('[g (?)]')
                textlab('Accelerometer','topleft');
                datetick('x','HH:MM','KeepLimits')
                axes(h(6))
                h(6).Position = h(6).Position.*[1 1 1 3];
                scatter(avg.Magnetometer(:,1),avg.Magnetometer(:,2),'filled')
                axis equal
                hold on
                scatter(nanmean(avg.Magnetometer(:,1)),nanmean(avg.Magnetometer(:,2)),'r','filled')
                plot(xlim,[0 0],'k')
                plot([0 0],ylim,'k')
                scatter(0,0,'k','filled')
                xlabel('M_x (counts)');ylabel('M_y (counts)');
                set(gca,'YAxisLocation','right','XAxisLocation','top')
                textlab('Magnetometer','topleft')
                set(h(1:end-1),'XTickLabel',[])
                rmemptysub
                drawnow
                if savefig
                    saveas(gcf,[figdir SNread '\' bfiles(iburst).name(1:end-4) '_Motion.png'])
                    close gcf
                end

                if isfield(avg,'AHRS_M11')
                figure('Name','Motion','color','w')
                h = tight_subplot(3,1,0.01,0.1,0.1);
                MP = get(0,'monitorposition');
                set(gcf,'outerposition',MP(1,:).*[1 1 0.5 1]);           
                axes(h(1))
                plot(avg.time,avg.AHRS_M11)
                hold on
                plot(avg.time,avg.AHRS_M12)
                plot(avg.time,avg.AHRS_M13)
                plot(avg.time,avg.AHRS_M21)
                plot(avg.time,avg.AHRS_M23)
                plot(avg.time,avg.AHRS_M23)
                plot(avg.time,avg.AHRS_M31)
                plot(avg.time,avg.AHRS_M32)
                plot(avg.time,avg.AHRS_M33)
                axis tight
                ylabel('[?]')
                textlab('M_{ij}','topleft');
                title([SNread(1:7) ' - ' datestr(btime,'mmm dd - HH:MM') ' AHRS'])
                axes(h(2))
                plot(avg.time,avg.AHRS_Dummy)
                ylabel('[?]')
                axis tight
                textlab('Dummy','topleft');
                axes(h(3))
                plot(avg.time,avg.AHRS_GyroX)
                hold on
                plot(avg.time,avg.AHRS_GyroY)
                plot(avg.time,avg.AHRS_GyroZ)
                axis tight
                ylabel('[^{\circ}s^{-1}]')
                textlab('Gyro','topleft');
                datetick('x','HH:MM','KeepLimits')
                set(h(1:end-1),'XTickLabel',[])
                rmemptysub
                drawnow
                if savefig
                    saveas(gcf,[figdir SNread '\' dfiles(ifile).name(1:end-4) '_AHRS.png'])
                    close gcf
                end
                end

            end

        % End file loop
        end
        % End folder loop
    end 
    % End mission loop
end

