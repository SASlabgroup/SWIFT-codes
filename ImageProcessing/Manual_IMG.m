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

clear
close all

%required user input : initial time, saved file name
itime = datenum('10Sep2013','DDmmmYYYY'); %initial time
savename = 'SWIFTXX_DDMMMYYYY';

fpath = pwd;
files = dir([fpath '/GOPR*']); %only find GoPro images
%sort by time, not by filename
[vals,si] = sort( cell2mat({files(:).datenum}) ,'ascend');

fig = figure('KeyPressFcn', @KeyPress); %NOTE: KeyPress is a separate func required with this script
%initialize counting var-ii and brk_count
brk_count = [];
ii = 1;
h.key = [];

while ii< length(files)
    guidata(fig,h) %save new guidata ... need this to pass data to/from KeyPress.m
    %load in image
    GOPRimg = imread( files(si(ii)).name );
   
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
            time(ii) = itime + files(si(ii)).datenum - files(si(1)).datenum;
            ii = ii+1;
        case 'space'
            brk_count(ii) = 1;
            time(ii) = itime + files(si(ii)).datenum - files(si(1)).datenum;
            ii = ii+1;
        case 'q'
        break
    end
  
end

close(fig)
figure(1)
plot(time,brk_count)
datetick('x','HH:MM','keeplimits','keepticks')

save(savename,'time','brk_count')

% % function KeyPress(ObjH, EventData)
% % h = guidata(gcbo);
% % h.key = EventData.Key;
% %   uiresume(gcf)
% %   guidata(gcbo,h) 
% % end