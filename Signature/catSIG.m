function sig = catSIG(SIG,varargin)
%Produces summary plot of burst-averaged signature data stored in 'SIG'
%       also returns concatenated data

plotsig = false;
QCsig = false;

if nargin > 1
    if any(strcmp(varargin,'plot'))
        plotsig = true;
    end
    if any(strcmp(varargin,'qc'))
        QCsig = true;
    end
    if ~(any(strcmp(varargin,'plot') | strcmp(varargin,'qc')))
        error('Optional inputs must be ''plot'' or ''qc''')
    end
end

if isfield(SIG,'time')
sig.time = [SIG.time];

sig.avgz = SIG(round(end/2)).profile.z';
sig.avgu = NaN(length(sig.avgz),length(sig.time));
sig.avgv = sig.avgu;
sig.avgw = sig.avgu;
sig.avgcorr = sig.avgu;
sig.avgamp = sig.avgu;
sig.avguerr = sig.avgu;
sig.avgverr = sig.avgu;
sig.avgwerr = sig.avgu;

sig.hrz = SIG(round(end/2)).HRprofile.z;
sig.hrw = NaN(length(sig.hrz),length(sig.time));
sig.hrwvar = sig.hrw;
sig.hrcorr = sig.hrw;
sig.hramp = sig.hrw;

sig.eps = sig.hrw;
sig.slope = sig.hrw;
sig.pspike = sig.hrw;
sig.mspe = sig.hrw;
sig.epserr = sig.hrw;
sig.N = sig.hrw;

for it = 1:length(sig.time)
    %Broadband
    sig.avgu(:,it) = SIG(it).profile.u;
    sig.avgv(:,it) = SIG(it).profile.v;
    sig.avgw(:,it) = SIG(it).profile.w;
    sig.avguerr(:,it) = SIG(it).profile.uerr;
    sig.avgverr(:,it) = SIG(it).profile.verr;
    sig.avgwerr(:,it) = SIG(it).profile.werr;
    sig.avgamp(:,it) = SIG(it).QC.uamp;
    sig.avgcorr(:,it) = SIG(it).QC.ucorr;
    %HR
    nz = length(SIG(it).HRprofile.w);
    sig.hrw(1:nz,it) = SIG(it).HRprofile.w;
    sig.hrwvar(1:nz,it) = SIG(it).HRprofile.werr;
    sig.hrcorr(1:nz,it) = SIG(it).QC.hrcorr;
    sig.hramp(1:nz,it) = SIG(it).QC.hramp;
    sig.eps(1:nz,it) = SIG(it).HRprofile.eps_structEOF;
    sig.slope(1:nz,it) = SIG(it).QC.slopeEOF;
    sig.pspike(1:nz,it) = SIG(it).QC.pspike;
    sig.mspe(1:nz,it) = SIG(it).QC.mspeEOF;
    sig.epserr(1:nz,it) = SIG(it).QC.epserrEOF;
    sig.N(1:nz,it) = SIG(it).QC.NEOF;
end

%QC
badburst = [SIG.outofwater] | [SIG.smallfile] | [SIG.badcorr] | [SIG.badamp] | [SIG.badvel];
if QCsig && sum(badburst) < length(sig.time)
    sig.avgu(:,badburst) = [];
    sig.avgv(:,badburst) = [];
    sig.avguerr(:,badburst) = [];
    sig.avgverr(:,badburst) = [];
    sig.avgw(:,badburst) = [];
    sig.avgwerr(:,badburst) = [];
    sig.avgcorr(:,badburst) = [];
    sig.avgamp(:,badburst) = [];
    sig.hrw(:,badburst) = [];
    sig.hrwvar(:,badburst) = [];
    sig.hrcorr(:,badburst) = [];
    sig.hramp(:,badburst) = [];
    sig.eps(:,badburst) = [];
    sig.slope(:,badburst) = [];
    sig.pspike(:,badburst) = [];
    sig.mspe(:,badburst) = [];
    sig.epserr(:,badburst) = [];
    sig.N(:,badburst) = [];
    sig.time(badburst) = [];
else
    sig.badburst = badburst;
end

% Plot
if plotsig && length(sig.time)>1
clear b
figure('color','w')
MP = get(0,'monitorposition');
set(gcf,'outerposition',MP(1,:).*[1 1 1 1]);
% East-North Velocity
subplot(4,3,1)
pcolor(sig.time,-sig.avgz,sig.avgu);shading flat
caxis([-0.5 0.5]);
hold on;plot(xlim,max(sig.hrz)*[1 1],'k')
ylabel('Depth (m)');cmocean('balance');title('U')
c = colorbar;c.Label.String = 'ms^{-1}';
xlim([min(sig.time) max(sig.time)])
datetick('x','KeepLimits')
subplot(4,3,4)
pcolor(sig.time,-sig.avgz,sig.avguerr);shading flat
caxis([0 0.03]);
hold on;plot(xlim,max(sig.hrz)*[1 1],'k')
ylabel('Depth (m)');title('\sigma_U')
c = colorbar;c.Label.String = 'ms^{-1}';
xlim([min(sig.time) max(sig.time)])
datetick('x','KeepLimits')
subplot(4,3,7)
pcolor(sig.time,-sig.avgz,sig.avgv);shading flat
caxis([-0.25 0.25]);
hold on;plot(xlim,max(sig.hrz)*[1 1],'k')
ylabel('Depth (m)');cmocean('balance');title('V')
c = colorbar;c.Label.String = 'ms^{-1}';
xlim([min(sig.time) max(sig.time)])
datetick('x','KeepLimits')
subplot(4,3,10)
pcolor(sig.time,-sig.avgz,sig.avgverr);shading flat
caxis([0 0.01]);
hold on;plot(xlim,max(sig.hrz)*[1 1],'k')
ylabel('Depth (m)');title('\sigma_V')
c = colorbar;c.Label.String = 'ms^{-1}';
xlim([min(sig.time) max(sig.time)])
datetick('x','KeepLimits')
%Vertical Velocity
subplot(4,3,2)
pcolor(sig.time,-sig.avgz,sig.avgw);shading flat
caxis([-0.05 0.05]);
hold on;plot(xlim,max(sig.hrz)*[1 1],'k')
cmocean('balance');cmocean('balance');ylabel('Depth (m)');title('W')
c = colorbar;c.Label.String = 'ms^{-1}';
xlim([min(sig.time) max(sig.time)])
datetick('x','KeepLimits')
subplot(4,3,5)
pcolor(sig.time,-sig.avgz,sig.avgwerr);shading flat
caxis([0 0.03]);
hold on;plot(xlim,max(sig.hrz)*[1 1],'k')
ylabel('Depth (m)');title('\sigma_W')
c = colorbar;c.Label.String = 'ms^{-1}';
xlim([min(sig.time) max(sig.time)])
datetick('x','KeepLimits')
subplot(4,3,8)
pcolor(sig.time,-sig.hrz,sig.hrw);shading flat
caxis([-0.05 0.05])
ylabel('Depth (m)');cmocean('balance');title('W_{HR}')
c = colorbar;c.Label.String = 'ms^{-1}';
xlim([min(sig.time) max(sig.time)])
datetick('x','KeepLimits')
subplot(4,3,11)
pcolor(sig.time,-sig.hrz,sig.hrwvar);shading flat
caxis([0 0.03]);
ylabel('Depth (m)');title('\sigma_W_{HR}')
c = colorbar;c.Label.String = 'ms^{-1}';
xlim([min(sig.time) max(sig.time)])
datetick('x','KeepLimits')
%Dissipation
subplot(4,3,3)
pcolor(sig.time,-sig.hrz,log10(sig.eps));shading flat
caxis([-7.5 -4.5]);
ylabel('Depth (m)');title('SF \epsilon')
c = colorbar;c.Label.String = 'log_{10}(m^3s^{-2})';
xlim([min(sig.time) max(sig.time)])
datetick('x','KeepLimits')
subplot(4,3,6)
pcolor(sig.time,-sig.hrz,log10(sig.epserr));shading flat
caxis([-8.5 -5.5]);
ylabel('Depth (m)');title('Error')
c = colorbar;c.Label.String = 'log_{10}(m^3s^{-2})';
xlim([min(sig.time) max(sig.time)])
datetick('x','KeepLimits')
subplot(4,3,9)
pcolor(sig.time,-sig.hrz,sig.slope);shading flat
caxis([0 2*2/3]);
ylabel('Depth (m)');title('SF Slope')
c = colorbar;c.Label.String = 'D \propto r^n';
xlim([min(sig.time) max(sig.time)])
datetick('x','KeepLimits')
cmocean('curl')
subplot(4,3,12)
pcolor(sig.time,-sig.hrz,log10(100*sqrt(sig.mspe)));shading flat
caxis([0 2]);
ylabel('Depth (m)');title('MSPE')
c = colorbar;c.Label.String = 'MSPE {%}';
xlim([min(sig.time) max(sig.time)])
datetick('x','KeepLimits')


end

else
    sig = [];
end
