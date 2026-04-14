% Ad hoc QC Willapa Moored
% K. Zeiden July 2025

% Note: format to NaN out bad data
% ibad = [SWIFT.variable] > varmax;
% if ~isempty(ibad)
%     [SWIFT(ibad).variable] = deal(NaN);
% end

if ispc
    slash = '\';
else
    slash = '/';
end

expdir = 'S:\Willapa\Jun2025\MooredSWIFTs';
% expdir = '/Volumes/Data/Willapa/Jun2025/MooredSWIFTs';

L3files = dir([expdir '\SWIFT*\SWIFT*L3.mat']);

%%

for im = 1:length(L3files)

    disp(['QCing ' L3files(im).name '...'])
    load([L3files(im).folder slash L3files(im).name])

    %%% QC Out-of-water bursts using ACS flags
    iacs = find(strcmp({sinfo.postproc.type}','ACS'));
    iout = sinfo.postproc(iacs(end)).flags.outofwater;
    SWIFT = SWIFT(~iout);

    %%% Crop in time (should only affect SWIFT 28)
    iexp = [SWIFT.time] > datenum([2025 06 16]);
    SWIFT = SWIFT(iexp);

    %%% Trim Altimeter & Remove Bottom Reflections
    if isfield(SWIFT,'signature')
        for it = 1:length(SWIFT)

            % if isfield(SWIFT(it).signature,'altimeter')
            %     maxz = SWIFT(it).signature.altimeter;
            % 
            %     % Trim HR
            %     hrtrim = SWIFT(it).signature.HRprofile.z > maxz;
            %     SWIFT(it).signature.HRprofile.w(hrtrim) = NaN;
            %     SWIFT(it).signature.HRprofile.wvar(hrtrim) = NaN;
            %     SWIFT(it).signature.HRprofile.eps(hrtrim) = NaN;
            % 
            %     % Trim Broadband
            %     avgtrim = SWIFT(it).signature.profile.z > maxz;
            %     SWIFT(it).signature.profile.east(avgtrim) = NaN;
            %     SWIFT(it).signature.profile.north(avgtrim) = NaN;
            %     SWIFT(it).signature.profile.w(avgtrim) = NaN;
            %     SWIFT(it).signature.profile.uvar(avgtrim) = NaN;
            %     SWIFT(it).signature.profile.vvar(avgtrim) = NaN;
            %     SWIFT(it).signature.profile.wvar(avgtrim) = NaN;
            %     SWIFT(it).signature.profile.spd_alt(avgtrim) = NaN;
            % 
            %     % Trim Echogram
            %     echotrim = SWIFT(it).signature.echoz > maxz;
            %     SWIFT(it).signature.echo(echotrim) = NaN;
            % end

            % Remove bottom reflections from dissipation
            ibad = isnan(SWIFT(it).signature.HRprofile.w);
            SWIFT(it).signature.HRprofile.tkedissipationrate(ibad) = NaN;
        end
    end 

    %%% Salintiy
    ibad = [SWIFT.salinity] > 40 | [SWIFT.salinity] < 20;
    if ~isempty(ibad)
        [SWIFT(ibad).salinity] = deal(NaN);
        [SWIFT(ibad).salinitystddev] = deal(NaN);
    end

    %%% Temperature
    ibad = [SWIFT.watertemp] > 18 | [SWIFT.watertemp] < 8;
    if ~isempty(ibad)
        [SWIFT(ibad).watertemp] = deal(NaN);
        [SWIFT(ibad).watertempstddev] = deal(NaN);
    end

    %%% Air Temperature
    if isfield(SWIFT,'airtemp')
        ibad = [SWIFT.airtemp] > 25;
        if ~isempty(ibad)
            [SWIFT(ibad).airtemp] = deal(NaN);
            [SWIFT(ibad).airtempstddev] = deal(NaN);
        end
    end

    %%% Humidity
    if isfield(SWIFT,'relhumidity')
        ibad = [SWIFT.relhumidity] < 70;
        if ~isempty(ibad)
            [SWIFT(ibad).relhumidity] = deal(NaN);
            [SWIFT(ibad).relhumiditystddev] = deal(NaN);
        end
    end

    %%% Bad Position
    if isfield(SWIFT,'lon')
        ibad = [SWIFT.lat] < 46 | [SWIFT.lat] > 48;
        [SWIFT(ibad).lon] = deal(NaN);
        [SWIFT(ibad).lat] = deal(NaN);
    end


    %%% SWIFT24 between Jun 20 and 21, Signature after Jun 17 14 45 00
    if strcmp(SWIFT(1).ID,'24')
        icut = [SWIFT.time] > datenum([2025 06 20 20 00 00]) & [SWIFT.time] < datenum([2025 06 21 06 00 00]);
        SWIFT = SWIFT(~icut);

        itcutsig = find([SWIFT.time] > datenum([2025 06 17 14 45 00]));
        for it = itcutsig
        % HR
        SWIFT(it).signature.HRprofile.w = NaN(size(SWIFT(it).signature.HRprofile.w));
        SWIFT(it).signature.HRprofile.wvar = NaN(size(SWIFT(it).signature.HRprofile.w));
        SWIFT(it).signature.HRprofile.tkedissipationrate = NaN(size(SWIFT(it).signature.HRprofile.w));
        % Broadband
        SWIFT(it).signature.profile.east = NaN(size(SWIFT(it).signature.profile.east));
        SWIFT(it).signature.profile.north = NaN(size(SWIFT(it).signature.profile.east));
        SWIFT(it).signature.profile.w = NaN(size(SWIFT(it).signature.profile.east));
        SWIFT(it).signature.profile.uvar = NaN(size(SWIFT(it).signature.profile.east));
        SWIFT(it).signature.profile.vvar = NaN(size(SWIFT(it).signature.profile.east));
        SWIFT(it).signature.profile.wvar = NaN(size(SWIFT(it).signature.profile.east));
        SWIFT(it).signature.profile.spd_alt = NaN(size(SWIFT(it).signature.profile.east));
        % Echogram
        if isfield(SWIFT(it).signature,'echo')
            SWIFT(it).signature.echo = NaN(size(SWIFT(it).signature.echo));
        end
        end

    end

    % Log in sinfo
    if isfield(sinfo,'postproc')
    ip = length(sinfo.postproc)+1; 
    else
        sinfo.postproc = struct;
        ip = 1;
    end
    sinfo.postproc(ip).type = 'AdHocQC';
    sinfo.postproc(ip).usr = getenv('username');
    sinfo.postproc(ip).time = string(datetime('now'));

    % Save L4 product
    save([L3files(im).folder slash L3files(im).name(1:end-6) 'L4.mat'],'SWIFT','sinfo')

    
end

%% Plot QCd data

swift = allSWIFT(expdir,'L4',true);

