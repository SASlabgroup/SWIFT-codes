% batch runs of reprocess_IMU for SWIFTs
clear all

directories = dir('SWIFT1*')

for dirindex = 26:length(directories), 
   
    save temp.mat directories dirindex
    
    cd(directories(dirindex).name)
    
    pwd, dirindex
    
    run('reprocess_IMU.m')
    
    cd('..')
    
    load temp.mat
    
    
end
    