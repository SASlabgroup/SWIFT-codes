%Addition of dir command to v16
%expansion of dir command to read one entire deployment
%July 3rd, 2014

%Curtis Rusch

%Before running this code, adjust the following parameters
%Change the SWIFT number and date for the fpath2 variable (line 23)
%Change the parameters for the variable jjj in line 26: jjj=#A#:length()-#B#
%where, #A# should be the number of folders to the first folder with in-water
%images, and #B# should be the number of folders at the end of the batch
%with images not taken in the water. (If the first two folders and the last 
%folder in a batch do not contain in-water pictures, #A#=3 and #B#=1. 
%Also change the #A# in line 28, for the variable jjj, to match #A# from above
%Finally, change the savename, in line 25
clc; clear all; close all;
tic;
Count=0;
PIXELNUMLast6=[0,0,0,0,0,0];
checknum=0;
 h=waitbar(0,'Image Processing In Progress...');
fpath1= '/Users/curusch/Documents/MATLAB';  %manually change
fpath2= '/SWIFT05_IMG_28May2013';           %manually change 
fpath3= dir([fpath1 fpath2 '/*GOPRO']);
savename='SWIFT05_Data_28May2013';          %manually change
for jjj=4:length(fpath3)-1          %manually change numbers
        
    if jjj==4                       %manually change number
        files = dir([fpath1 fpath2 '/' fpath3(jjj).name '/GOPR*']); %only find GoPro images
        check=zeros(1,length(files));
        firsttime=files(1).datenum;
        for zz=1:6  %Start by establishing a running mean using the first 6 images
            A=imread([fpath1 fpath2 '/' fpath3(jjj).name '/' files(zz).name]);
            
            [h w d]=size(A);
            [x,y] = meshgrid(1:w,1:h);  %turn image into set of coordinates
            
            
            xo = round(x(end)/2);       %make polar coordinates, then create
            yo = round(y(end)/2);       %a center at the buoy center
            x  = x - xo -20;
            y  = y-yo +80;
            r  = sqrt(x.*x + y.*y);
            
            for jj=1:size(A,3);
                imRawRGB = squeeze(A(:,:,jj));
                imRawRGB(r < 100) = 0;              %Black out buoy and horizon
                imRawRGB(r > 330) = 0;
                
                
                A(:,:,jj) = imRawRGB;
            end
            
            for x=200:600            %Black out post/light
                for y=300:550
                    A(x,y,:)=0;
                end
            end
            
            Agray=rgb2gray(A);     %turn to grayscale image
            
            %%% Contrast analysis method %%%
            Acontrast=imadjust(Agray, [.7,1],[0,1]); %reassigns all pixels with
            %intensities greater than .7 to a 0-1 scale, making all pixels
            %below .7 black
            
            Arow=Acontrast(:);      %turn matrix into vector
            Anozero=Arow;
            Anozero(Anozero==0)=[]; %Delete all zero intensity entries (helps with regress)
            PixelNum=length(Anozero);
            PIXELNUMLast6(zz)=PixelNum;
        end
        for zz=7:length(files)      %Begins running all algorithms on the rest of the files
            A=imread([fpath1 fpath2 '/' fpath3(jjj).name '/' files(zz).name]);
            
            [h w d]=size(A);
            [x,y] = meshgrid(1:w,1:h);  %turn image into set of coordinates
            
            
            xo = round(x(end)/2);       %make polar coordinates, then create
            yo = round(y(end)/2);       %a center at the buoy center
            x  = x - xo -20;
            y  = y-yo +80;
            r  = sqrt(x.*x + y.*y);
            
            for jj=1:size(A,3);
                imRawRGB = squeeze(A(:,:,jj));
                imRawRGB(r < 100) = 0;              %Black out buoy and horizon
                imRawRGB(r > 330) = 0;
                
                
                A(:,:,jj) = imRawRGB;
            end
            
            for x=200:600            %Black out post/light
                for y=300:550
                    A(x,y,:)=0;
                end
            end
            
            Agray=rgb2gray(A);     %turn to grayscale image
            
            %%% Contrast analysis method %%%
            Acontrast=imadjust(Agray, [.7,1],[0,1]); %reassigns all pixels with
            %intensities greater than .7 to a 0-1 scale, making all pixels
            %below .7 black
            
            Arow=Acontrast(:);      %turn matrix into vector
            Anozero=Arow;
            Anozero(Anozero==0)=[]; %Delete all zero intensity entries (helps with regress)
            PixelNum=length(Anozero);
            MEANoverA=mean(PIXELNUMLast6)/PixelNum;
            
            if MEANoverA<.17
                           
                Count=Count+1;
                Score(Count)=0;                                        %Might eliminate the difference if statement?
                ScoredFiles(Count)=files(zz);
                FilePaths(Count)=cellstr([fpath1 fpath2 '/' fpath3(jjj).name '/' files(zz).name]);
                %dynamic threshold for image brightness
                
                if PixelNum >3000
                    Score(Count)=Score(Count)+1;
                end
                
                Atexture=rgb2gray(rangefilt(A));            %texture analysis (range filter)
                if median(imhist(Atexture))>30
                    Score(Count)=Score(Count)+1;
                end
                
                
                if Score(Count)>0
                    ft = fft2(Atexture);
                    
                    [M, N] = size(ft);
                    mask = zeros(M, N);
                    [fy, fx] = ndgrid(0:M/2, 0:N/2);
                    sigmaf = 5;
                    %MIDDLE-PASS FILTER
                    cfreq = min(M, N)/4;
                    % Gaussian mask centred on cfreq
                    mask(1:M/2+1, 1:N/2+1) = exp(-((fx-cfreq).^2+(fy-cfreq).^2)/(2*sigmaf)^2);
                    mask(1:M/2+1, N:-1:N/2+2) = mask(1:M/2+1, 2:N/2);
                    mask(M:-1:M/2+2, :) = mask(2:M/2, :);
                    
                    % Filter the FT and show the result
                    imfiltM = ifft2(mask .* ft);
                    ENTM=entropy(imfiltM);
                    if ENTM>2.8;
                        Score(Count)=Score(Count)+1;
                    end
                end
                %beginning of glare detection
                
                Arow2=Agray(:);      %turn matrix into vector
                Arow2=double(Arow2);      %makes vector of type double (not uint8)
                
                
                rrow=r(:); %turns matrix of radius values into vector
                [rsorted,rr]=sort(rrow);  %Sorts radius values by magnitude
                Asorted=Arow2(rr);         %Sorts pixel values to correspond with radii
                
                rround=round(rsorted); %Rounds radius values to nearest integer
                
                rround(rround<100)=[];  %Remove radii less than 100
                Asorted(1:length(Asorted)-length(rround))=[]; %remove corresponding pixels
                
                rround(rround>330)=[]; %remove radii greater than 330
                Asorted(length(Asorted)-(length(Asorted)-length(rround))+1:end)=[]; %remove corresponding pixels
                rbin=rround;
                Abin=Asorted;
                rplot=zeros(231,1);
                maxplot=rplot;
                for  qq=100:330     % for-loop that examines each rounded radial value, and
                    rbin(rbin<qq+1)=[]; %finds the maximum pixel value for that radius
                    diff=length(Abin)-length(rbin);
                    maxbin=max(Abin(1:diff));
                    rplot(qq-99)=qq;        %Outputs 2 vectors - rplot with each radial value (100-330)
                    maxplot(qq-99)=maxbin;  %maxplot - contains max pixel intensity at each radius
                    Abin(1:diff)=[];
                    
                end
                
                [coeffs]=polyfit(rplot,maxplot,1); %linear approximation to intensity v. radius distribution
              
                
                
                
                if coeffs(1)>0.25                   %glare seen above this threshold
                    Score(Count)=Score(Count)-2;
                end
                
                if Score(Count)>0
                    check(zz)=1;
                end
                
                if Score(Count)<1
                    Count=Count-1;
                elseif  sum(check((zz-5):zz))>1 %This accounts for waves that are counted multiple times
                    Count=Count-1;  %%%%% this could be great at reducing the number of analyzed images
                end
            end
        end
     
    else
        files = dir([fpath1 fpath2 '/' fpath3(jjj).name '/GOPR*']); %only find GoPro images
        check=[check, zeros(1,length(files))];
        
        for zz=1:length(files)      %Begins running all algorithms on the rest of the files
            A=imread([fpath1 fpath2 '/' fpath3(jjj).name '/' files(zz).name]);
            
            [h w d]=size(A);
            [x,y] = meshgrid(1:w,1:h);  %turn image into set of coordinates
            
            
            xo = round(x(end)/2);       %make polar coordinates, then create
            yo = round(y(end)/2);       %a center at the buoy center
            x  = x - xo -20;
            y  = y-yo +80;
            r  = sqrt(x.*x + y.*y);
            
            for jj=1:size(A,3);
                imRawRGB = squeeze(A(:,:,jj));
                imRawRGB(r < 100) = 0;              %Black out buoy and horizon
                imRawRGB(r > 330) = 0;
                
                
                A(:,:,jj) = imRawRGB;
            end
            
            for x=200:600            %Black out post/light
                for y=300:550
                    A(x,y,:)=0;
                end
            end
            
            Agray=rgb2gray(A);     %turn to grayscale image
            
            %%% Contrast analysis method %%%
            Acontrast=imadjust(Agray, [.7,1],[0,1]); %reassigns all pixels with
            %intensities greater than .7 to a 0-1 scale, making all pixels
            %below .7 black
            
            Arow=Acontrast(:);      %turn matrix into vector
            Anozero=Arow;
            Anozero(Anozero==0)=[]; %Delete all zero intensity entries (helps with regress)
            PixelNum=length(Anozero);
            MEANoverA=mean(PIXELNUMLast6)/PixelNum;
            
            if MEANoverA<.17
                Count=Count+1;
                Score(Count)=0;                                        
                ScoredFiles(Count)=files(zz);
                FilePaths(Count)=cellstr([fpath1 fpath2 '/' fpath3(jjj).name '/' files(zz).name]);
                %dynamic threshold for image brightness
                
                if PixelNum >3000
                    Score(Count)=Score(Count)+1;
                end
                
                Atexture=rgb2gray(rangefilt(A));            %texture analysis (range filter)
                if median(imhist(Atexture))>30
                    Score(Count)=Score(Count)+1;
                end
                
                
                if Score(Count)>0
                    ft = fft2(Atexture);
                   
                    [M, N] = size(ft);
                    mask = zeros(M, N);
                    [fy, fx] = ndgrid(0:M/2, 0:N/2);
                    sigmaf = 5;
                    %MIDDLE-PASS FILTER
                    cfreq = min(M, N)/4;
                    % Gaussian mask centred on cfreq
                    mask(1:M/2+1, 1:N/2+1) = exp(-((fx-cfreq).^2+(fy-cfreq).^2)/(2*sigmaf)^2);
                    mask(1:M/2+1, N:-1:N/2+2) = mask(1:M/2+1, 2:N/2);
                    mask(M:-1:M/2+2, :) = mask(2:M/2, :);
                    
                    % Filter the FT and show the result
                    imfiltM = ifft2(mask .* ft);
                    ENTM=entropy(imfiltM);
                    if ENTM>2.8;
                        Score(Count)=Score(Count)+1;
                    end
                end
                %beginning of glare detection
                
                Arow2=Agray(:);      %turn matrix into vector
                Arow2=double(Arow2);      %makes vector of type double (not uint8)
                
                
                rrow=r(:); %turns matrix of radius values into vector
                [rsorted,rr]=sort(rrow);  %Sorts radius values by magnitude
                Asorted=Arow2(rr);         %Sorts pixel values to correspond with radii
                
                rround=round(rsorted); %Rounds radius values to nearest integer
                
                rround(rround<100)=[];  %Remove radii less than 100
                Asorted(1:length(Asorted)-length(rround))=[]; %remove corresponding pixels
                
                rround(rround>330)=[]; %remove radii greater than 330
                Asorted(length(Asorted)-(length(Asorted)-length(rround))+1:end)=[]; %remove corresponding pixels
                rbin=rround;
                Abin=Asorted;
                rplot=zeros(231,1);
                maxplot=rplot;
                for  qq=100:330     % for-loop that examines each rounded radial value, and
                    rbin(rbin<qq+1)=[]; %finds the maximum pixel value for that radius
                    diff=length(Abin)-length(rbin);
                    maxbin=max(Abin(1:diff));
                    rplot(qq-99)=qq;        %Outputs 2 vectors - rplot with each radial value (100-330)
                    maxplot(qq-99)=maxbin;  %maxplot - contains max pixel intensity at each radius
                    Abin(1:diff)=[];
                    
                end
                
                [coeffs]=polyfit(rplot,maxplot,1); %linear approximation to intensity v. radius distribution
                
                
                
                if coeffs(1)>0.25                   %glare seen above this threshold
                    Score(Count)=Score(Count)-2;
                end
                
                
                if Score(Count)>0
                    check(checknum+zz)=1;
                end
                
                
                if Score(Count)<1
                    Count=Count-1;
                elseif  sum(check((checknum+zz-5):checknum+zz))>1 
                    Count=Count-1;  
                end
                
            end
            
            PIXELNUMLast6=[PIXELNUMLast6, PixelNum];
            PIXELNUMLast6(1)=[];
        end
        
        
       
    end
    checknum=checknum+zz;
    waitbar(jjj/length(fpath3))
    lasttime=files(zz).datenum;
    clear files
    
end

% GoPro video breaking count code
%
% % Use left and right arrow to scroll through photos
% % Space bar counts the image as a breaker and steps to the next image
% % 'q' exits the count
% % a .mat file is auto-saved with the name in variable 'savename' upon
% % finishing

% % The time stamp is taken to be initial time (user input) + time difference
% % between the first image file and the current image file in matlab's
% % datenum

%required user input : initial time, saved file name
%itime = datenum('10Sep2013','DDmmmYYYY'); %initial time

%sort by time, not by filename
%[vals,si] = sort( cell2mat({ScoredFiles(:).datenum}) ,'ascend');

fig = figure('KeyPressFcn', @KeyPress); %NOTE: KeyPress is a separate func required with this script
%initialize counting var-ii and brk_count
brk_count = [];
ii = 1;
h.key = [];

while ii< length(FilePaths)
    guidata(fig,h) %save new guidata ... need this to pass data to/from KeyPress.m
    %load in image
    GOPRimg = imread( FilePaths{ii} );
   
    clf
    image(GOPRimg) %plot GoPro image
    
    uiwait(fig)
    h = guidata(fig); %get guidata from callback
    
    switch h.key
        case 'leftarrow'
            ii = ii-1;
            brk_count = brk_count(1:ii);
        case 'rightarrow'
            brk_count(ii) = 0;
            time(ii) = ScoredFiles(ii).datenum - ScoredFiles(1).datenum; % + itime
            ii = ii+1;
        case 'space'
            brk_count(ii) = 1;
            brknum=sum(brk_count);
            BrkTime(brknum)=ScoredFiles(ii).datenum - ScoredFiles(1).datenum;
            Brk_Files(brknum)=cellstr(ScoredFiles(ii).name);
            time(ii) = ScoredFiles(ii).datenum - ScoredFiles(1).datenum; % + itime
            ii = ii+1;
        case 'q'
        break
    end
  
end

close(fig)
figure(1)
plot(time,brk_count)
datetick('x','HH:MM','keeplimits','keepticks')

fivemin=5/(1440);
lastbin=ceil((lasttime-firsttime)/fivemin);
timecheck=BrkTime;
for bbb=1:lastbin
    BinCnt=find(timecheck<(bbb*fivemin));
    BinTime(bbb)=firsttime+bbb*fivemin-fivemin/2;
    BrkRt(bbb)=length(BinCnt);
    timecheck(1:length(BinCnt))=[];
    clear BinCnt;
end

figure(2)
    bar(BinTime, BrkRt)
    datetick('x', 15)
    
    
    
    
% % function KeyPress(ObjH, EventData)
% % h = guidata(gcbo);
% % h.key = EventData.Key;
% %   uiresume(gcf)
% %   guidata(gcbo,h) 
% % end
save(savename, 'BinTime', 'BrkRt', 'Score', 'ScoredFiles')

toc
Count