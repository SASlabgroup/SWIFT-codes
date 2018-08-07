% evalute meso-scale wave-current interactions from SWIFT data
% (following Ardhuin et al, 2017)

clear all, close all

%pwd

flist = dir('SWIFT*.mat');

counter = 1;

for fi = 1:length(flist),
    
    load(flist(fi).name),
    
    tdiff = gradient([SWIFT.time]);
    
    tjumps = find(tdiff > 1);
    
    if isempty(tjumps),
        
        E_u(counter) = nanmean([SWIFT.driftspd]).^2;
        E_H(counter) = nanstd([SWIFT.sigwaveheight]).^2;
        Havg(counter) = nanmean([SWIFT.sigwaveheight]);
        Tavg(counter) = nanmean([SWIFT.peakwaveperiod]);
        
        counter = counter + 1;
        
    else
        
        for i = 1:length(tjumps),
            
            if i == 1, 
                cluster = 1:tjumps(1);, 
            else
                cluster = tjumps(i) - tjumps(i-1);
            end
            
            if length(cluster) > 3,
            E_u(counter) = nanmean([SWIFT(cluster).driftspd]).^2;
            E_H(counter) = nanstd([SWIFT(cluster).sigwaveheight]).^2;
            Havg(counter) = nanmean([SWIFT(cluster).sigwaveheight]);
            Tavg(counter) = nanmean([SWIFT(cluster).peakwaveperiod]);
            
            counter = counter + 1;
            else
            end
        end
    end
    
end

%%

E_u( E_u < 1e-2) = NaN;

figure(1),
plot(  E_u, E_H, 'bx')

figure(2),
plot( 70 * Havg.^2 ./ (9.8^2 * Tavg.^2), E_H./E_u, 'bx')
axis([ 0 0.3 0 100])
ylabel('E_H / E_u'), xlabel( ' 70 <H_s>^2 / (g^2 <T>^2)' )
