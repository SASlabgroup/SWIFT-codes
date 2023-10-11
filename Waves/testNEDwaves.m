% matlab script to test NEDwaves,
% especially the memory light version relative to the full version
%
% J Thomson, 6/2023

clear all

%% load a test case
tcase = 4;

cd('/Users/jthomson/Dropbox/engineering/SWIFT/microSWIFT_v2/NEDwaves_testcases')
load(['testcase' num2str(tcase,1) '.mat'])

%% run legacy version of GPSwaves 
u = east; v = north;
[ Hs, Tp, Dp, E, f, a1, b1, a2, b2] = GPSwaves( u, v, [], fs);

figure(1), clf

subplot(2,1,1)
loglog(f,E ), hold on
axis([1e-2 1e0 1e-3 3e2])
ylabel('Energy [m^2/Hz]')
title(['test case' num2str(tcase,1) ])

subplot(8,1,5)
semilogx(f,a1), hold on
axis([1e-2 1e0 -1 1])
ylabel('a_1')

subplot(8,1,6)
semilogx(f,b1), hold on
axis([1e-2 1e0 -1 1])
ylabel('b_1')

subplot(8,1,7)
semilogx(f,a2), hold on
axis([1e-2 1e0 -1 1])
ylabel('a_2')

subplot(8,1,8)
semilogx(f,b2), hold on
axis([1e-2 1e0 -1 1])
ylabel('b_2')
xlabel('frequency [Hz]')

%% run full version of NEDwaves

[ Hs, Tp, Dp, E, fmin, fmax, a1, b1, a2, b2, check] = NEDwaves(north, east, down, fs);
f = linspace(fmin,fmax,length(E));
a1 = double(a1)./100;
b1 = double(b1)./100;
a2 = double(a2)./100;
b2 = double(b2)./100;

figure(1), 

subplot(2,1,1)
loglog(f,E,'--' ), hold on
axis([1e-2 1e0 1e-3 3e2])
ylabel('Energy [m^2/Hz]')
title(['test case' num2str(tcase,1) ])

subplot(8,1,5)
semilogx(f,a1), hold on
axis([1e-2 1e0 -1 1])
ylabel('a_1')

subplot(8,1,6)
semilogx(f,b1), hold on
axis([1e-2 1e0 -1 1])
ylabel('b_1')

subplot(8,1,7)
semilogx(f,a2), hold on
axis([1e-2 1e0 -1 1])
ylabel('a_2')

subplot(8,1,8)
semilogx(f,b2), hold on
axis([1e-2 1e0 -1 1])
ylabel('b_2')
xlabel('frequency [Hz]')

%% compare to memory light

[ Hsml, Tpml, Dpml, E, fmin, fmax, a1, b1, a2, b2, check] = NEDwaves_memlight(north, east, down, fs);
f = linspace(fmin,fmax,length(E));
a1 = double(a1)./100;
b1 = double(b1)./100;
a2 = double(a2)./100;
b2 = double(b2)./100;

figure(1), 

subplot(2,1,1)
loglog(f,E,':' ), hold on
axis([1e-2 1e0 1e-3 3e2])
ylabel('Energy [m^2/Hz]')
title(['test case' num2str(tcase,1) ])
%legend(['Hs = ' num2str(Hs)],['Hs = ' num2str(Hsml)])
legend('GPSwaves','NEDwaves','NEDwaves memory light')

subplot(8,1,5)
semilogx(f,a1,':' ), hold on
axis([1e-2 1e0 -1 1])
ylabel('a_1')

subplot(8,1,6)
semilogx(f,b1,':' ), hold on
axis([1e-2 1e0 -1 1])
ylabel('b_1')

subplot(8,1,7)
semilogx(f,a2,':' ), hold on
axis([1e-2 1e0 -1 1])
ylabel('a_2')

subplot(8,1,8)
semilogx(f,b2,':' ), hold on
axis([1e-2 1e0 -1 1])
ylabel('b_2')
xlabel('frequency [Hz]')


print('-dpng',['test case' num2str(tcase,1) '.png'])

%% compare variance

varratio = Hsml.^2 / Hs.^2

