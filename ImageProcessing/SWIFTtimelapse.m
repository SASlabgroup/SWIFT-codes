% script to pull all images from a SWIFT deployment
% and make a movie, incuding timestamps
% works on both mast and hull cameras (different coms)
% ** must be run from the mission directory (card offload) **
%
% J. Thomson, 4/2019

clear all, clf
tic

com = 'COM-7'; % 7 is mast and 9 is hull (on v4 SWIFTs)
missiondir = pwd
wd = pwd;
lastslash = find(wd=='/',1,'last') + 1;
wd = wd( lastslash : end );

% initialize movie
fast = false;  % fast means no printed timestamps
vidObj = VideoWriter([wd '_video' com ],'MPEG-4');
open(vidObj);

cd([ com '/Raw/' ]);

daydirs = dir('*');

for di = 1:length(daydirs)
    
    if ~strcmp( daydirs(di).name(1), '.' )
        
        cd([ daydirs(di).name  ] ), pwd
        
        hrdirs = dir('*');
        
        for hi = 1:length(hrdirs)
            
            if ~strcmp( hrdirs(hi).name(1), '.' )
                
                cd([ hrdirs(hi).name  ]), pwd
                
                % list and load images
                filelist = dir('*.jpg');
                
                for fi = 1:length(filelist),
                    pic = imread(filelist(fi).name,'jpg');
                    if fast % fast version, no timestamps
                        currFrame = im2frame(pic);
                    else % slow version, with timestamps
                        %image(pic)
                        image((permute(pic,[2 1 3]))) % rotated
                        %image(flipud(permute(pic,[2 1 3]))) % rotated and flippedfor v3s
                        axis equal, axis tight
                        text(10,10,[filelist(fi).name],'interpreter','none','fontsize',14,'fontweight','demi','color','g')
                        currFrame = getframe(gcf);
                    end
                    writeVideo(vidObj,currFrame);
                    
                end
                
                cd('../')
                
            else end
            
        end
        
        cd('../')
        
    else end
end

cd([ missiondir ])

close(vidObj);

toc
