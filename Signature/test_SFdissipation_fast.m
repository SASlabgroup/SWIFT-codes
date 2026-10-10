function test_SFdissipation_fast(missiondir,stagedir,nburst)
% Check that the fast Signature path matches the original within tolerance.
%   missiondir  source mission (read only), e.g.
%               /Volumes/PortableSSD/MooredSWIFTS/SWIFT28_20-21Jun2025
%   stagedir    scratch directory for three staged copies of the mission
%   nburst      number of burst MAT files to use (default 24)
%
% 1) SFdissipation vs SFdissipation_fast on synthetic data with NaNs
% 2) processSIGburst (serial vs fast estimator) and altSIGenu (in-place
%    vectorization vs the original loop) on real bursts
% 3) reprocess_SIG L3 and SIG products, with timing: default vs
%    FastDissipation within tolerance, and FastDissipation vs
%    FastDissipation + ParallelBursts exactly equal

if nargin < 3
    nburst = 24;
end
rtol = 1e-7;

%% 1) Synthetic structure functions
rng(1)
nbin = 64;
z = 0.3 + 0.04*(1:nbin)';
w = 0.02*randn(nbin,2000) + 0.01*sin((1:nbin)'/10);
w(rand(size(w)) < 0.1) = NaN;
w(5,:) = NaN;            % all-NaN bin
w(6,2:end) = NaN;        % single good ping
w(7,:) = 1;              % constant bin
for fittype = ["linear" "cubic"]
    [eps0,qual0,sf0] = SFdissipation(w,z,0.04,0.16,1,char(fittype),'mean');
    [eps1,qual1,sf1] = SFdissipation_fast(w,z,0.04,0.16,1,char(fittype),'mean');
    report("synthetic " + fittype + " eps",eps0,eps1,rtol)
    reportStruct("synthetic " + fittype + " qual",qual0,qual1,rtol)
    reportStruct("synthetic " + fittype + " sfdata",sf0,sf1,rtol)
end

%% 2) Real bursts
opt.xz = 0.2;
opt.plotburst = false;
opt.HR.mincorr = 40;
opt.HR.QCbin = true;
opt.HR.pbadmax_bin = 75;
opt.HR.QCping = true;
opt.HR.pbadmax_ping = 75;
opt.HR.NaNbad = false;
opt.HR.nsumeof = 3;
optfast = opt;
optfast.fastdissipation = true;

files = burstFiles(missiondir);
files = files(1:min(nburst,end));
t = zeros(1,4);
for k = 1:length(files)
    data = load(fullfile(files(k).folder,files(k).name),'burst','avg');
    tic; HR0 = processSIGburst(data.burst,opt); t(1) = t(1) + toc;
    tic; HR1 = processSIGburst(data.burst,optfast); t(2) = t(2) + toc;
    reportStruct("burst " + k + " HRprofile",HR0,HR1,rtol)

    heading = mean(data.avg.Heading,'omitnan');
    tic; [enu0,spd0,shear0] = altSIGenu_loop(data.avg,heading); t(3) = t(3) + toc;
    tic; [enu1,spd1,shear1] = altSIGenu(data.avg,heading); t(4) = t(4) + toc;
    report("burst " + k + " altSIGenu enu",enu0,enu1,rtol)
    report("burst " + k + " altSIGenu spd",spd0,spd1,rtol)
    report("burst " + k + " altSIGenu shear",shear0,shear1,rtol)
end
fprintf('processSIGburst serial %.2f s, fast %.2f s (%.2fx)\n',t(1),t(2),t(1)/t(2))
fprintf('altSIGenu loop %.2f s, vectorized %.2f s (%.2fx)\n',t(3),t(4),t(3)/t(4))

%% 3) End-to-end reprocess_SIG
[~,mission] = fileparts(missiondir);
serialMission = stageMission(missiondir,fullfile(stagedir,'serial',mission),files);
fastMission = stageMission(missiondir,fullfile(stagedir,'fast',mission),files);
parallelMission = stageMission(missiondir,fullfile(stagedir,'parallel',mission),files);

tic; reprocess_SIG(serialMission,false,false); tserial = toc;
tic; reprocess_SIG(fastMission,false,false,FastDissipation=true); tfast = toc;
tic; reprocess_SIG(parallelMission,false,false,FastDissipation=true, ...
    ParallelBursts=true); tparallel = toc;
fprintf('reprocess_SIG serial %.2f s, fast %.2f s (%.2fx), fast+parallel %.2f s (%.2fx)\n', ...
    tserial,tfast,tserial/tfast,tparallel,tserial/tparallel)

serialL3 = load(fullfile(serialMission,[mission '_L3.mat']),'SWIFT');
fastL3 = load(fullfile(fastMission,[mission '_L3.mat']),'SWIFT');
parallelL3 = load(fullfile(parallelMission,[mission '_L3.mat']),'SWIFT');
serialSIG = load(fullfile(serialMission,[mission '_SIG.mat']),'SIG');
fastSIG = load(fullfile(fastMission,[mission '_SIG.mat']),'SIG');
parallelSIG = load(fullfile(parallelMission,[mission '_SIG.mat']),'SIG');
reportStruct("L3 SWIFT",serialL3.SWIFT,fastL3.SWIFT,rtol)
reportStruct("SIG",serialSIG.SIG,fastSIG.SIG,rtol)
if ~isequaln(fastL3.SWIFT,parallelL3.SWIFT) || ~isequaln(fastSIG.SIG,parallelSIG.SIG)
    error('ParallelBursts changed the L3 or SIG products')
end

end


function files = burstFiles(missiondir)

files = dir(fullfile(missiondir,'SIG','Raw','*','*.mat'));
files = files(~contains({files.name},'smoothwHR'));

end


function staged = stageMission(missiondir,staged,files)
% Copy the L2 product and symlink burst files; never write to the source.

if isfolder(staged)
    rmdir(staged,'s')
end
mkdir(fullfile(staged,'SIG','Raw','subset'))
l2 = dir(fullfile(missiondir,'*SWIFT*L2.mat'));
copyfile(fullfile(l2.folder,l2.name),staged)
for k = 1:length(files)
    system(sprintf('ln -s "%s" "%s"',fullfile(files(k).folder,files(k).name), ...
        fullfile(staged,'SIG','Raw','subset',files(k).name)));
end

end


function reportStruct(name,a,b,rtol)

if ~isequal(class(a),class(b)) || ~isequal(size(a),size(b))
    error('%s: class or size differs',name)
end
if isstruct(a)
    fa = fieldnames(a);
    if ~isequal(sort(fa),sort(fieldnames(b)))
        error('%s: fields differ',name)
    end
    for i = 1:numel(a)
        for f = fa'
            reportStruct(name + "(" + i + ")." + f{1},a(i).(f{1}),b(i).(f{1}),rtol)
        end
    end
elseif isnumeric(a) || islogical(a)
    report(name,a,b,rtol)
elseif ~isequal(a,b)
    error('%s: values differ',name)
end

end


function report(name,a,b,rtol)
% Relative difference scaled by the field's largest magnitude.

a = double(a);
b = double(b);
if ~isequal(size(a),size(b)) || ~isequal(isnan(a),isnan(b))
    error('%s: size or NaN pattern differs',name)
end
scale = max(abs(a(isfinite(a))),[],'all');
d = max(abs(a(isfinite(a)) - b(isfinite(a))),[],'all');
if isempty(d) || d == 0
    return
end
rel = d/scale;
if rel > rtol
    error('%s: relative difference %.3g exceeds %.3g',name,rel,rtol)
end

end


function [bavgvelENU_alt,bavgspdXY,shearXY] = altSIGenu_loop(avg,hh)
% Original altSIGenu with the per-bin loop, kept as the reference.

T_AHRS = [1.1831         0   -1.1831         0;
               0   -1.1831         0    1.1831;
          0.5518         0    0.5518         0;
               0    0.5518         0    0.5518];
if length(hh) == 3
    pp = hh(2);
    rr = hh(3);
else
    hh = hh(1);
    pp = 0;
    rr = 180;
end
velENU = avg.VelocityData;
[nping,nbin,~] = size(velENU);
R_AHRS = NaN(nping,3,3);
R_AHRS(:,1,1) = avg.AHRS_M11;
R_AHRS(:,1,2) = avg.AHRS_M12;
R_AHRS(:,1,3) = avg.AHRS_M13;
R_AHRS(:,2,1) = avg.AHRS_M21;
R_AHRS(:,2,2) = avg.AHRS_M22;
R_AHRS(:,2,3) = avg.AHRS_M23;
R_AHRS(:,3,1) = avg.AHRS_M31;
R_AHRS(:,3,2) = avg.AHRS_M32;
R_AHRS(:,3,3) = avg.AHRS_M33;
velBEAM = NaN(size(velENU));
velXYZ = NaN(size(velENU));
for iping = 1:nping
    R_attitude = squeeze(R_AHRS(iping,:,:));
    R_velocity4 = [R_attitude(1,1) R_attitude(1,2) R_attitude(1,3)/2 R_attitude(1,3)/2;
                   R_attitude(2,1) R_attitude(2,2) R_attitude(2,3)/2 R_attitude(2,3)/2;
                   R_attitude(3,1) R_attitude(3,2) R_attitude(3,3)                   0;
                   R_attitude(3,1) R_attitude(3,2) 0                  R_attitude(3,3)];
    if any(~isfinite(R_attitude),'all') || ...
            rcond(R_velocity4) < 1e-8 || ...
            abs(det(R_attitude)-1) > 0.1 || ...
            norm(R_attitude*R_attitude'-eye(3),'fro') > 0.1
        continue
    end
    for ibin = 1:nbin
        velXYZ(iping,ibin,:) = inv(R_velocity4)*squeeze(velENU(iping,ibin,:));
        velBEAM(iping,ibin,:) = inv(T_AHRS)*squeeze(velXYZ(iping,ibin,:));
    end
end
bavgvelBEAM = squeeze(mean(velBEAM,1,'omitnan'));
T = T_AHRS;
T(2:4,:) = -T(2:4,:);
Rz = [cosd(hh) -sind(hh) 0; sind(hh) cosd(hh) 0; 0 0 1];
Ry = [cosd(pp) 0 sind(pp); 0 1 0; -sind(pp) 0 cosd(pp)];
Rx = [1 0 0; 0 cosd(rr) -sind(rr); 0 sind(rr) cosd(rr)];
R = Rz*Ry*Rx;
R = [R(1,1) R(1,2) R(1,3)/2 R(1,3)/2;
     R(2,1) R(2,2) R(2,3)/2 R(2,3)/2;
     R(3,1) R(3,2) R(3,3)   0;
     R(3,1) R(3,2) 0        R(3,3)];
bavgvelENU_alt = NaN(size(bavgvelBEAM));
for ibin = 1:nbin
    bavgvelENU_alt(ibin,:) = R*T*bavgvelBEAM(ibin,:)';
end
bavgvelENU_alt(:,2:4) = -bavgvelENU_alt(:,2:4);
dz = avg.CellSize;
spdXY = squeeze(sqrt(velXYZ(:,:,1).^2 + velXYZ(:,:,2).^2));
bavgspdXY = mean(spdXY,'omitnan')';
shearXY = gradient(bavgspdXY)./dz;

end
