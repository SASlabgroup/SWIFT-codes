function sig = catSIG(SIG)
%Produces summary plot of burst-averaged signature data stored in 'SIG'
%       also returns concatenated data
plotsig = true;
QCsig = true;

sig.time = [SIG.time];
sig.avgz = SIG(1).profile.z;
sig.hrz = SIG(1).HRprofile.z;
sig.avgu = NaN(length(sig.avgz),length(sig.time));
sig.avgv = sig.avgu;
sig.avgw = sig.avgu;
sig.avgcorr = sig.avgu;
sig.avgamp = sig.avgu;
sig.avguerr = sig.avgu;
sig.avgverr = sig.avgu;
sig.avgwerr = sig.avgu;     
sig.hrw = NaN(length(sig.hrz),length(sig.time));
sig.hrwvar = sig.hrw;
sig.hrcorr = sig.hrw;
sig.hramp = sig.hrw;
sig.eps_struct = sig.hrw;
sig.struct_slope = sig.hrw;
sig.eps_spectral = sig.hrw;
sig.pitchvar = NaN(1,length(sig.time));
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
    sig.hrw(:,it) = SIG(it).HRprofile.w;
    sig.hrwvar(:,it) = SIG(it).HRprofile.werr;
    sig.hrcorr(:,it) = SIG(it).QC.hrcorr;
    sig.hramp(:,it) = SIG(it).QC.hramp;
    sig.eps_struct(:,it) = SIG(it).HRprofile.eps_structEOF;
    sig.struct_slope(:,it) = SIG(it).QC.slopeEOF;
    sig.eps_spectral(:,it) = SIG(it).HRprofile.eps_spectral;
    sig.pitchvar(it) = SIG(it).QC.pitchvar;
end

%QC
oow = [SIG.outofwater];
smallfile = [SIG.smallfile];
if QCsig && sum(oow | smallfile) < length(sig.time)
    sig.avgu(:,oow | smallfile) = [];
    sig.avgv(:,oow | smallfile) = [];
    sig.avguerr(:,oow | smallfile) = [];
    sig.avgverr(:,oow | smallfile) = [];
    sig.avgw(:,oow | smallfile) = [];
    sig.avgwerr(:,oow | smallfile) = [];
    sig.hrw(:,oow | smallfile) = [];
    sig.hrwvar(:,oow | smallfile) = [];
    sig.eps_spectral(:,oow | smallfile) = [];
    sig.eps_struct(:,oow | smallfile) = [];
    sig.struct_slope(:,oow | smallfile) = [];
    sig.pitchvar(oow | smallfile) = [];
    sig.time(oow | smallfile) = [];
end

% Plot        
if plotsig
clear b
figure('color','w')
MP = get(0,'monitorposition');
set(gcf,'outerposition',MP(1,:).*[1 1 1 1]);
% East-North Velocity
subplot(4,3,1)
imagesc(sig.time,sig.avgz,sig.avgu);caxis([-0.5 0.5]);
hold on;plot(xlim,max(sig.hrz)*[1 1],'k')
ylabel('Depth (m)');cmocean('balance');title('U')
c = colorbar;c.Label.String = 'ms^{-1}';
xlim([min(sig.time) max(sig.time)])
datetick('x','KeepLimits')
subplot(4,3,4)
imagesc(sig.time,sig.avgz,sig.avguerr);caxis([0.005 0.015]);
hold on;plot(xlim,max(sig.hrz)*[1 1],'k')
ylabel('Depth (m)');title('\sigma_U')
c = colorbar;c.Label.String = 'ms^{-1}';
xlim([min(sig.time) max(sig.time)])
datetick('x','KeepLimits')
subplot(4,3,7)
imagesc(sig.time,sig.avgz,sig.avgv);caxis([-0.5 0.5]);
hold on;plot(xlim,max(sig.hrz)*[1 1],'k')
ylabel('Depth (m)');cmocean('balance');title('V')
c = colorbar;c.Label.String = 'ms^{-1}';
xlim([min(sig.time) max(sig.time)])
datetick('x','KeepLimits')
subplot(4,3,10)
imagesc(sig.time,sig.avgz,sig.avgverr);caxis([0.005 0.015]);
hold on;plot(xlim,max(sig.hrz)*[1 1],'k')
ylabel('Depth (m)');title('\sigma_V')
c = colorbar;c.Label.String = 'ms^{-1}';
xlim([min(sig.time) max(sig.time)])
datetick('x','KeepLimits')
%Vertical Velocity
subplot(4,3,2)
imagesc(sig.time,sig.avgz,sig.avgw);caxis([-0.05 0.05]);
hold on;plot(xlim,max(sig.hrz)*[1 1],'k')
cmocean('balance');cmocean('balance');ylabel('Depth (m)');title('W')
c = colorbar;c.Label.String = 'ms^{-1}';
xlim([min(sig.time) max(sig.time)])
datetick('x','KeepLimits')
subplot(4,3,5)
imagesc(sig.time,sig.avgz,sig.avgwerr);caxis([0.005 0.015]);
hold on;plot(xlim,max(sig.hrz)*[1 1],'k')
ylabel('Depth (m)');title('\sigma_W')
c = colorbar;c.Label.String = 'ms^{-1}';
xlim([min(sig.time) max(sig.time)])
datetick('x','KeepLimits')
subplot(4,3,8)
imagesc(sig.time,sig.hrz,sig.hrw);caxis([-0.05 0.05])
ylabel('Depth (m)');cmocean('balance');title('W_{HR}')
c = colorbar;c.Label.String = 'ms^{-1}';
xlim([min(sig.time) max(sig.time)])
datetick('x','KeepLimits')
subplot(4,3,11)
imagesc(sig.time,sig.hrz,sig.hrwvar);caxis([0.001 0.005]);
ylabel('Depth (m)');title('\sigma_W_{HR}')
c = colorbar;c.Label.String = 'ms^{-1}';
xlim([min(sig.time) max(sig.time)])
datetick('x','KeepLimits')
%Dissipation
subplot(4,3,3)
imagesc(sig.time,sig.hrz,log10(sig.eps_struct));caxis([-7.5 -4.5]);
ylabel('Depth (m)');title('SF \epsilon')
c = colorbar;c.Label.String = 'log_{10}(m^3s^{-2})';
xlim([min(sig.time) max(sig.time)])
datetick('x','KeepLimits')
subplot(4,3,6)
imagesc(sig.time,sig.hrz,sig.struct_slope);caxis([0 2*2/3]);
ylabel('Depth (m)');title('SF Slope')
c = colorbar;c.Label.String = 'D \propto r^n';
xlim([min(sig.time) max(sig.time)])
datetick('x','KeepLimits')
cmocean('curl')
subplot(4,3,9)
imagesc(sig.time,sig.hrz,log10(sig.eps_spectral));caxis([-5 -2]);
ylabel('Depth (m)');title('Spectral \epsilon')
c = colorbar;c.Label.String = 'log_{10}(m^3s^{-2})';
xlim([min(sig.time) max(sig.time)])
datetick('x','KeepLimits')
%Pitch + Roll
subplot(4,3,12)
b(1) = bar(sig.time,sqrt(sig.pitchvar));
b(1).FaceColor = 'r';
set(b,'EdgeColor',rgb('grey'))
ylabel('\sigma_{\phi} (^{\circ})');title('Pitch Variance')
c = colorbar;c.Visible = 'off';
xlim([min(sig.time) max(sig.time)])
ylim([0 20])
datetick('x','KeepLimits')

end

end