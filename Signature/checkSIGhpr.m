function HPR = checkSIGhpr(missiondir,varargin)
% [ Summary of this function goes here
%   Detailed explanation goes here

if ispc
    slash = '\';
else
    slash = '/';
end

bfiles = dir([missiondir slash 'SIG' slash 'Raw' slash '*' slash '*.mat']);
if isempty(bfiles)
    warning('   No burst mat files found    ')
end
bfiles = bfiles(~contains({bfiles.name},'smoothwHR'));

%% Plotting
if nargin == 2
    if strcmp(varargin{1},'plothpr')
        plothpr = true;
    else
        warning('unrecognized command')
        plothpr = false;
    end
elseif nargin == 1
    plothpr = false;
elseif nargin > 2
    warning('too many input arguments')
    plothpr = false;
end

%% Deal with 'partial' files: only use if full file is not available or is smaller
partburst = find(contains({bfiles.name},'partial'));
rmpart = false(1,length(partburst));
for iburst = 1:length(partburst)
    pdir = bfiles(partburst(iburst)).folder;
    pname = bfiles(partburst(iburst)).name;
    matburst = dir([pdir slash pname(1:end-12) '.mat']);
    if ~isempty(matburst) && matburst.bytes > bfiles(partburst(iburst)).bytes
        rmpart(iburst) = true;
    end
end
bfiles(partburst(rmpart)) = [];
nburst = length(bfiles);

%% Initialize HPR structure

HPR.meanpitch = NaN(1,nburst);
HPR.meanroll = NaN(1,nburst);
HPR.meanhead =  NaN(1,nburst);
HPR.stdpitch = NaN(1,nburst);
HPR.stdroll = NaN(1,nburst);
HPR.stdhead = NaN(1,nburst);
HPR.meandt = NaN(1,nburst);
HPR.stddt = NaN(1,nburst);

%% Loop through burst files and plot HPR data, save mean + std values

if plothpr
    figure('color','w');
    fullscreen(2)
end

for iburst = 1:nburst

    bname = bfiles(iburst).name(1:end-4);
    disp(['Burst ' num2str(iburst) ' : ' bname])
    load([bfiles(iburst).folder slash bfiles(iburst).name],'avg','Data')

    if exist('Data','var')
        if isempty(Data)
             disp('No data, skipping burst...')
            continue
        end
        pitch = Data.Average_Pitch;
        roll = Data.Average_Roll;
        head = Data.Average_Heading;
        time = Data.Average_MatlabTimeStamp;
        uvel = Data.Average_VelEast';
    else
        if isempty(avg)
            disp('No data, skipping burst...')
            continue
        end
        pitch = avg.Pitch;
        roll = avg.Roll;
        head = avg.Heading;
        time = avg.time;
        uvel = squeeze(avg.VelocityData(:,:,1))';
    end

t0 = min(time);
times = (time - t0)*24*60*60;
nt = length(times);
dt = diff(times);
HPR.meandt(iburst) = mean(dt,'omitnan');
HPR.stddt(iburst) = std(dt,[],'omitnan');

chead = cosd(head);
shead = sind(head);
cpitch = cosd(pitch);
spitch = sind(pitch);
croll = cosd(roll);
sroll = sind(roll);

% Mean heading + circular std dev
meanchead = mean(chead,'omitnan');
meanshead = mean(shead,'omitnan');
HPR.meanhead(iburst) = atan2d(meanshead,meanchead);
if HPR.meanhead(iburst)  < 0
    HPR.meanhead(iburst)  = HPR.meanhead(iburst) +360;
end
rhead = sqrt(meanchead^2 + meanshead^2)/nt;
HPR.stdhead(iburst) = sqrt(-2*log(rhead));

% Mean pitch + circ std dev
meancpitch = mean(cpitch,'omitnan');
meanspitch = mean(spitch,'omitnan');
HPR.meanpitch(iburst) = atan2d(meanspitch,meancpitch);
rpitch = sqrt(meancpitch^2 + meanspitch^2)/nt;
HPR.stdpitch(iburst) = sqrt(-2*log(rpitch));

% Mean roll + circ std dev
meancroll = mean(croll,'omitnan');
meansroll = mean(sroll,'omitnan');
HPR.meanroll(iburst) = atan2d(meansroll,meancroll);
rroll = sqrt(meancroll^2 + meansroll^2)/nt;
HPR.stdroll(iburst) = sqrt(-2*log(rroll));

if plothpr
    subplot(5,1,1);
    plot(times,head,'-rx','LineWidth',2)
    hold on
    plot(xlim,HPR.meanhead(iburst)*[1 1],'--k','LineWidth',2)
    legend('Heading',['Mean = ' num2str(round(HPR.meanhead(iburst),1)) '^{\circ}'])
    ylim([0 360])
    title(bname,'Interpreter','none');
    
    subplot(5,1,2);
    plot(times,pitch,'-bx','LineWidth',2)
    hold on
    plot(xlim,HPR.meanpitch(iburst)*[1 1],'--k','LineWidth',2)
    legend('Pitch',['Mean = ' num2str(round(HPR.meanpitch(iburst),1)) '^{\circ}'])
    ylim([-180 180])
    
    subplot(5,1,3);
    plot(times,roll,'-mx','LineWidth',2)
    hold on
    plot(xlim,HPR.meanroll(iburst)*[1 1],'--k','LineWidth',2)
    legend('Roll',['Mean = ' num2str(round(HPR.meanroll(iburst),1)) '^{\circ}'])
    ylim([-180 180])
    
    subplot(5,1,4)
    plot(times(1:end-1),dt,'-k','LineWidth',2)
    legend('\Delta T')
    ylim([0 10]);grid minor
    
    subplot(5,1,5)
    pcolor(times,-(1:40),uvel);
    shading flat
    xlabel('Burst Time [s]')
    legend('East')
    clim([-0.5 0.5])
    
    h = findall(gcf,'Type','Axes');
    linkaxes(h,'x')
    xlim([0 512])
    colormap(cmocean('balance'))
    
    set(gcf,'Name',[bname '_HeadPitchRoll'])
    figname = [bfiles(iburst).folder slash get(gcf,'Name')];
    print(figname,'-dpng')
    
    clf
end

end

close all