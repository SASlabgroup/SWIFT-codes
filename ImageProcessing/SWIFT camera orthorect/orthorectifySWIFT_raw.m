%% orthorectifySWIFT_raw.m
% following http://johnloomis.org/ece564/notes/tform/planar/html/planar2.html
% adapted by M. Smith, 06/2016
% 

clear all;close all;clc
%save images? 1 for yes, 0 for no
saveplot=1;

%set paths and image names
image_folder=cd ;
filename='SWIFT14_PIC_27Oct2015_00_01_01.jpg'; %filename of RAW SWIFT camera image
if saveplot==1;
    name = filename(1:end-4); %base name for saving plots
end
%% load necessary inputs
%SWIFT cam parameters and transformation matrix
load('SWIFT_cam_params.mat')
load('transformSWIFT.mat')

%SWIFT image
img = im2double(rgb2gray(imread([image_folder '/'  filename])));
%% Process image
%undistort using camera parameters
[img,neworgin]=undistortImage(img,cameraParams);
img=imrotate(img,90);
figure;imshow(img);

% %transform - view 1
% [imgt1, xf2_ref] = imwarp(img,tf,'OutputView',xf1_ref1);
% figure;imshow(imgt1)
% if saveplot==1;
%     imwrite(imgt1,[name '_truncated.jpg']);
% end

%transform - view 2
[imgt2, xf2_ref] = imwarp(img,tf,'OutputView',xf1_ref2);


%using imdistline, 55.2 pixels=10 inches =.254 m
x=linspace(0,1.0925,240); % 0 to 10 s, 1000 samples
y=linspace(0,1.4566,320); % 10^1 to 10^3, 1000 samples
xy=meshgrid(x,y);
figure;
imshow(imgt2)
imagesc(x,y,imgt2);
xlabel('x (meters)')
ylabel('y (meters)')

if saveplot==1;
    imwrite(imgt2,[name '_rectified.jpg']);
end

% Use imdistine to measure feature sizes (in meters, real world coordinates)
%imdistline