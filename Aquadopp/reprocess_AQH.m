function [SWIFT] = reprocess_AQH(parentdir, readraw, iceflag)
% reprocess SWIFT v3 uplooking AquadoppHR (AQH) results
% loop thru raw data for a given SWIFT deployment, then
% replace values in the SWIFT data structure of results
% (from onboard processing)... assuming that IMU reprocessing has already happened first
%
%
% J. Thomson, Sept 2010
%   cleaned and revised with AQH read function, Thomson, Jun 2016
%   
% revised by M. Smith and J. Thomson, 08/2018 
%   functionalized - input: parentdir should be location of folder with .mat file
%       (_reprocessed_displacements) and AQH folder. output: SWIFT structure
%       with reprocessed AQH, also saved in parentdir
%   added readraw flag (logical input), set to true to force re-read of raw
%   data (rather than existing matlab)
%   added iceflag (logical) - option to mask near surface velocities and dissipations when ice
%       is suspected present, where ice flag is an logical input
%
%   usage is now 
%
%       [SWIFT] = reprocess_AQH(parentdir, readraw, iceflag)
%
%   also, removed phase resolved calcs (maybe should make that another
%   option flag in next version)
%

%% OPTIONS for quality control and AQH settings
mincor = 50; % correlation cutoff, 50 recommended (max value recorded in air), 30 if single beam acq
minamp = 30;  % amplitude cutoff, 30 usually means air
maxQCratio = .5; % maximum allowable ration of remove points to total points

pthreshold = -0.15;  % pressure threshold (m of tolerance from intended z profile)
res = 0.04; % cell size (m) from hdr file
blanking = 0.10; % blanking distance (m) from hdr file
sigma = 0.025;  % nominal velocity noise [m/s]
rate = 4; % sampling rate

spectral = true % spectral processing for dissipation rate


%% load existing SWIFT structure created during concatSWIFTv3_processed or IMUreprocessing, replace only the new results
cd(parentdir);
wd = pwd;
wdi = find(wd == '/',1,'last');
wd = wd((wdi+1):length(wd));

load([wd '_reprocessedIMU_RC_displacements.mat'])
%load([wd '.mat'])


cd('AQH/Raw/') % v3.2 or V3.3


%% loop thru raw data

dirlist = dir('20*');

for di = 1:length(dirlist),
    
    cd([dirlist(di).name])
    filelist = dir('*.dat');
    
    for fi=1:length(filelist),
        
        % read or load raw data
        if isempty(dir([filelist(fi).name(1:end-4) '.mat'])) | readraw == true,
            [time Vel Amp Cor Pressure pitch roll reading ] = readSWIFTv3_AQH( filelist(fi).name );
        else
            load([filelist(fi).name(1:end-4) '.mat']),
        end
        
        [pts cells] = size(Vel);
        [apts acells] = size(Amp);
        [cpts ccells] = size(Cor);
       
        % geometry
        z = blanking + res./2 + [0:(cells-1)]*res; % cell depth
        r = [0.157 0.202 0.246 0.290 0.334 0.378 0.422 0.466 0.510 0.554 0.598 0.642 0.687 0.731 0.775 0.819]; % cell range
        
        % alternate spectral processing 
        if spectral
            beam = 1;
            %[Vc,pTerm,rotTerm] = AQDmotionCorrect2(Vel,heading,pitch,roll,Pressure,beam); 
            [vpsd f ]= pwelch(Vel,[],[],[],4);
            inertial = find(f>0.5 & f < 1.5);
            compwpsd = mean( vpsd(inertial,:) .* ( (2*3.14* f(inertial))).^(5/3) )./ 128;
            advect = std(Vel); %most consistent with Tennekes '75
            
            if advect>0 & compwpsd > 0
                epsilon = ( compwpsd .* advect.^(-2/3) ).^(3/2);
            else
                epsilon = NaN;
            end
            
            epsilon = epsilon';
         
        end

        
        % correct for tilting (range shift to be applied in call to dissipation.m)
        bobbing = min([0.05 std(Pressure)]); % m, usually less than 0.05
        deltatheta = min([ 3.14/180*(5) std(3.14/180*(pitch)) ]);
        thetabar = 3.14/180*(25);
        deltar = 0.5 * z * deltatheta * thetabar ./ cos(thetabar)^2  + bobbing ./ cos(thetabar);
        
        % quality control velocity data
        exclude = Cor < mincor ;
        Vel(exclude)  = NaN;
        QCratio = sum(exclude(:))./(pts*cells);  % ratio of bad:good points
        exclude = Amp < minamp ;
        Vel(exclude)  = NaN;
        
        % ice mask velocities
        if iceflag == true,
            icemask = find( nanmean(Cor) > 95 | nanmean(Amp) > 195 );
            if ~isempty(icemask)
                v(:,icemask(1):end) = NaN;
                icemask_index = icemask(1); 
            else
                icemask_index = nan;
            end
        end
        
        
        % phase averaged TKE dissipation rate of the whole burst
        if ~spectral
            [tke epsilon residual A Aerror N Nerror ] = dissipation(Vel', r, length(Vel), 0, deltar);
        end
        
        epsilon(1:3) = NaN;
            
        
        
%         % phase resolved processing
%         npts = 8;
%         eptimeshift = npts/4/2;
%         for ei=1:(length(Vel)/npts),
%             i = [((npts*ei)-npts+1):(npts*ei)];
%             if max(i) <= length(Vel(:,1)),
%             [tke PRepsilon residual A Aerror N Nerror] = dissipation(Vel(i,:)', r, length(Vel(i,:)), 0, deltar);
%             phaseresolvedepsilon(ei,:) = PRepsilon;
%             else
%                 phaseresolvedepsilon(ei,:) = NaN;
%             end
%         end
%         phasedresolvedepsilon(phaseresolvedepsilon==0) = NaN;
        
        
        % match time to SWIFT structure and replace values
        time = datenum(filelist(fi).name(13:21)) + str2num(filelist(fi).name(23:24))./24 + str2num(filelist(fi).name(26:27))./(24*6);
        [tdiff tindex] = min(abs([SWIFT.time]-time));
        SWIFT(tindex).uplooking.tkedissipationrate = epsilon;
%       SWIFT(tindex).phaseresovledepsilon = phaseresolvedepsilon;
        if iceflag == true,
            SWIFT(tindex).uplooking.icemaskindex = icemask_index;
        end
        
    end
    
    cd('../')
end

cd('../')
cd('../')

if ~spectral
    save([ wd '_reprocessedAQH.mat'],'SWIFT')
elseif spectral
    save([ wd '_reprocessedAQH_spectral.mat'],'SWIFT')
end


end