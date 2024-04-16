% reprocess SWIFT v3 downlooking Aquadopp (AQD) results
% loop thru raw data for a given SWIFT deployment, then
% replace values in the SWIFT data structure of results
% (assuming concatSWIFTv3_processed.m has already been run.
%
%
% M. Smith 10/2015 based on reprocess_AQH.m code
%   J. Thomson 12/2015 to include option phase resolved dissipation (commented-out)
%   cleaned and revised with AQD read function, Thomson, Jun 2016
% M. Moulton 3/2017 correct error in Dir calculation


clear all; close all
%parentdir = ('/Users/jthomson/Desktop/SWIFT15_14Jan2016');  % change this to be the parent directory of all raw raw data (CF card offload from SWIFT)
%parentdir='/Users/msmith/Documents/PIPERS/SWIFT/Polynya_May2017/SWIFT15_05May2017';
parentdir = './';
parentdir = pwd;

plotflag = true;

%quality control parameters
minamp = 30; %amplitude cutoff, usually 30 or 40
minn = 50; %number of cells averaged for each depth
z = [1.25:0.5:20.75];

% raw Doppler velocity precision of 1 MHz Aquadopp
Vert_prec =  .074; %m/s
Hori_prec = .224; %m/s


%% load existing SWIFT structure created during concatSWIFTv3_processed, replace only the new results
cd(parentdir);
wd = pwd;
wdi = find(wd == '/',1,'last');
wd = wd((wdi+1):length(wd));

load([ wd '.mat'])

cd('AQD/Raw/') % v3.2 or V3.3


%% loop thru raw data

dirlist = dir('20*');

for di = 1:length(dirlist),
    
    cd([dirlist(di).name])
    filelist = dir('*.dat');
    
    for fi=1:length(filelist),
        
        % read or load raw data
        if isempty(dir([filelist(fi).name(1:end-4) '.mat'])),
            [time VelE VelN VelU Amp1 Amp2 Amp3 Pressure Pitch Roll Heading ] = readSWIFTv3_AQD( filelist(fi).name );
        else
            load([filelist(fi).name(1:end-4) '.mat']),
        end
        
        %use velocities only when sufficient return
        exclude = Amp1 < minamp | Amp2 < minamp; %used for vel. magnitude
        
        % Average amplitudes of just velocity measurements used
        Amp1(exclude) = NaN; Amp2(exclude) = NaN;
        Amp = (Amp1+Amp2)./2;%corresponds to those used in velocity
        
        if plotflag
            pcolor(time, z, Amp')
            shading flat
            set(gca,'YDir','reverse')
            ylabel('Depth [m]')
            datetick
            title([filelist(fi).name(1:end-4) ' AQD backscatter' ],'interp','none')
            print('-dpng',[filelist(fi).name(1:end-4) '_backscatter.png']),
        end
        
        n = sum(~isnan(Amp),1);
        E_error = Hori_prec./sqrt(n); N_error = E_error;
        Hori_error = sqrt((E_error.^2) + (N_error.^2));
        Hori_error(n < minn) = NaN;
        
        Amp = nanmean(Amp,1);
        Amp(n < minn) = NaN;
        
        %Average velocities first for "net" velocity + direction
        VelE(Amp1<minamp) = NaN; VelN(Amp2<minamp) = NaN;
        VelE(exclude) = NaN; VelN(exclude) = NaN;
        VelE = nanmean(VelE,1); VelN = nanmean(VelN,1);
        Vel = sqrt(VelE.^2 + VelN.^2);
        Vel(n < minn) = NaN;
        
        %Calculate direction from averaged velocities
        Dir = atan2d(VelE,VelN); % MM: Note, using atan rather than atan2 in this line was incorrect: Dir = rad2deg(atan(VelE./VelN));
        for i = 1:length(Dir);
            if Dir(i) <0,
                Dir(i) = Dir(i)+360; %make directions between 0 and 360
            end
        end
        Dir(n < minn) = NaN;
        
        
        % dissipation: phase averaged processing of the whole burst
        %         [ epsilon ] = dissipation_simple(VelU', z, length(time), 0 , 0);
        
        % dissipation: phase resolved processing
        %         npts = 8;
        %         for ei=1:(512/npts),
        %             i = [((npts*ei)-npts+1):(npts*ei)];
        %             phaseresolvedepsilon(ei,:) = dissipation_simple(VelU(i,:)', z);
        %         end
        %         phasedresolvedepsilon(phaseresolvedepsilon==0) = NaN;
        
        
        time = datenum(filelist(fi).name(13:21)) + str2num(filelist(fi).name(23:24))./24 + str2num(filelist(fi).name(26:27))./(24*6);
        % match time to SWIFT structure and replace values
        [tdiff, tindex] = min(abs([SWIFT.time]-time));
        
        SWIFT(tindex).downlooking.velocitydirection = Dir';
        SWIFT(tindex).downlooking.amplitude = Amp';
        SWIFT(tindex).downlooking.z = z;
        SWIFT(tindex).downlooking.velocityerror = Hori_error;
        SWIFT(tindex).downlooking.vertvel=nanmean(VelU,1);
%        SWIFT(tindex).downlooking.epsilon = epsilon;
%        SWIFT(tindex).phaseresolvedepsilon = phaseresolvedepsilon;
        
%         %Plot to check reasonable in comparison
%         figure(1);clf
%         plot(Vel,(SWIFT(tindex).downlooking.z),'--','LineWidth',2);
%         hold on;
%         %herrorbar(Vel,(SWIFT(tindex).downlooking.z),Hori_error);
%         plot(SWIFT(tindex).downlooking.velocityprofile,(SWIFT(tindex).downlooking.z),'*','LineWidth',2)
%         legend('reprocessed','telemetry')
%         xlabel('Velocity (m/s')
%         ylabel('depth')
%         set(gca,'YDir','reverse')
%         drawnow
%         
%         figure(2);
%         plot(Amp,(SWIFT(tindex).downlooking.z));
%         ylabel('depth')
%         xlabel('Amplitude')
%         set(gca,'YDir','reverse')
%         drawnow
        
        if nansum(SWIFT(tindex).downlooking.velocityprofile)>0 && tdiff<0.04,
            SWIFT(tindex).downlooking.velocityprofile = Vel';
        else
            SWIFT(tindex).downlooking.velocityprofile = NaN(40,1);
   %         SWIFT(tindex).downlooking.epsilon = NaN(40,1);
   %         SWIFT(tindex).phaseresolvedepsilon = NaN(size(phaseresolvedepsilon));
            
        end
        
        SWIFT_tindex(di,fi) = tindex;
        
    end
    
    cd('../')
    
end


%If SWIFT structure elements not replaced, fill variables with NaNs
for i = 1:length(SWIFT)
    if length(find(SWIFT_tindex ==i)) < 1,
        SWIFT(i).downlooking.velocitydirection = NaN(40,1);
        SWIFT(i).downlooking.amplitude = NaN(40,1);
        SWIFT(i).downlooking.z = 0.25:0.5:19.75;
        SWIFT(i).downlooking.velocityerror = NaN(40,1);
        SWIFT(i).downlooking.velocityprofile = NaN(40,1);
%        SWIFT(tindex).downlooking.epsilon = NaN(40,1);
%        SWIFT(tindex).phaseresolvedepsilon = NaN(size(phaseresolvedepsilon));
    end
end


cd(parentdir)

save([ wd '_reprocessedAQD.mat'],'SWIFT')


