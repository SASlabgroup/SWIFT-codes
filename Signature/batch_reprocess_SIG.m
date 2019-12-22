% batch reprocess SWIFT signature data

missions = dir('SWIFT2*2019');
topdir = pwd;

save missionlist missions topdir

for mi=7:length(missions), 
    
cd(missions(mi).name)

run('reprocess_SIG.m')

colormap parula
plotSWIFT(SWIFT)

cd('..')

load('missionlist.mat')

end