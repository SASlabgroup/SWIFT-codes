% make longer-time averages from the standard 10-minute SWIFT bursts
% do this for a whole directory of SWIFT results

clear all, close all, clc

minutes = 30;  % how many minutes-long to make the new averages

datadir = './'  % local copy of processed data

flist = dir([datadir 'SWIFT*.mat']);  % 


counter = 1;

for fi=1:length(flist),
    
    flist(fi).name
    load([datadir flist(fi).name])
    
    newtime = [ floor(min([SWIFT.time])) : minutes/(24*60) : ceil(max([SWIFT.time])) ]; % hourly time base
    
    for si=1:length(newtime),
        
        %si 
        
        f = SWIFT(1).wavespectra.freq;
        df = median(diff(f));
        E = zeros(length(f),1);
        a1 = zeros(length(f),1);
        a2 = zeros(length(f),1);
        b1 = zeros(length(f),1);
        b2 = zeros(length(f),1);
        counter = 0;
        
        inds = find( ( newtime(si) - [SWIFT.time] ) < minutes/(24*60)  & ( newtime(si) - [SWIFT.time] ) > 0 ) ;
        
        if ~isempty(inds),
            
            havedata(si) = true;
            
            for ai = 1:length(inds),
                
                %ai
                
                SWIFT(inds(ai)).wavespectra.energy( SWIFT(inds(ai)).wavespectra.energy==9999 ) = 0;
                SWIFT(inds(ai)).wavespectra.a1( SWIFT(inds(ai)).wavespectra.a1==9999 ) = 0;
                SWIFT(inds(ai)).wavespectra.a2( SWIFT(inds(ai)).wavespectra.a2==9999 ) = 0;
                SWIFT(inds(ai)).wavespectra.b1( SWIFT(inds(ai)).wavespectra.b1==9999 ) = 0;
                SWIFT(inds(ai)).wavespectra.b2( SWIFT(inds(ai)).wavespectra.b2==9999 ) = 0;
                
                
                %if SWIFT(inds(ai)).sigwaveheight > 0 & SWIFT(inds(ai)).sigwaveheight < 10,
                E = E + SWIFT(inds(ai)).wavespectra.energy;
                a1 = a1 + SWIFT(inds(ai)).wavespectra.a1.*SWIFT(inds(ai)).wavespectra.energy;
                a2 = a2 + SWIFT(inds(ai)).wavespectra.a2.*SWIFT(inds(ai)).wavespectra.energy;
                b1 = b1 + SWIFT(inds(ai)).wavespectra.b1.*SWIFT(inds(ai)).wavespectra.energy;
                b2 = b2 + SWIFT(inds(ai)).wavespectra.b2.*SWIFT(inds(ai)).wavespectra.energy;
                counter = counter + 1;
                %else end
            end
            
            I=find(E > 0 & isnan(E) ==0);
            E = E./counter;
            a1(I) = a1(I)./(E(I)*counter);
            b1(I) = b1(I)./(E(I)*counter);
            a2(I) = a2(I)./(E(I)*counter);
            b2(I) = b2(I)./(E(I)*counter);
            Hs = 4 * sqrt(sum(E(I).*df));
            %fwaves = f>0.04 & f<1; % frequency cutoff for wave stats, 0.4 is specific to SWIFT hull
            %E( ~fwaves ) = 0;
            % significant wave height
            %Hs  = 4*sqrt( sum( E(fwaves) ) * df);
            %  energy period instead of peak period
            fe = sum( f(I).*E(I) )./sum( E(I) );
            [~ , feindex] = min(abs(f-fe));
            Tp = 1./fe;
            
            newSWIFT(si).time = newtime(si);
            newSWIFT(si).wavespectra.energy = E;
            newSWIFT(si).wavespectra.freq = f;
            newSWIFT(si).wavespectra.a1 = a1;
            newSWIFT(si).wavespectra.b1 = b1;
            newSWIFT(si).wavespectra.a2 = a2;
            newSWIFT(si).wavespectra.b2 = b2;
            newSWIFT(si).sigwaveheight = Hs;
            newSWIFT(si).peakwaveperiod = Tp;
            newSWIFT(si).peakwavedirT = mean([SWIFT(inds).peakwavedirT]);
            newSWIFT(si).lat = mean([SWIFT(inds).lat]);
            newSWIFT(si).lon = mean([SWIFT(inds).lon]);
            newSWIFT(si).winddirT = mean([SWIFT(inds).winddirT]);
            newSWIFT(si).winddirTstddev = mean([SWIFT(inds).winddirTstddev]);
            newSWIFT(si).windspd = mean([SWIFT(inds).windspd]);
            newSWIFT(si).windspdstddev = mean([SWIFT(inds).windspdstddev]);
            newSWIFT(si).airtemp = mean([SWIFT(inds).airtemp]);
            newSWIFT(si).airtempstddev = mean([SWIFT(inds).airtempstddev]);
            newSWIFT(si).airpres = mean([SWIFT(inds).airpres]);
            newSWIFT(si).airpresstddev = mean([SWIFT(inds).airpresstddev]);
            newSWIFT(si).driftdirT = mean([SWIFT(inds).driftdirT]);
            newSWIFT(si).driftdirTstddev = mean([SWIFT(inds).driftdirTstddev]);
            newSWIFT(si).driftspd = mean([SWIFT(inds).driftspd]);
            newSWIFT(si).driftspdstddev= mean([SWIFT(inds).driftspdstddev]);
            
            
            
            
        else
            
            % do nothing if no data for those minutes
            
        end
        
    end
    
    if diff([newSWIFT.time])*24 == 0,
        disp('timestamp problem')
    end
    
    SWIFT = newSWIFT(havedata);
    
    %plotSWIFT_wavesonly(SWIFT)
    
    save([datadir flist(fi).name([1:(length(flist(fi).name)-4)])  '_' num2str(minutes) 'min'],'SWIFT')
    
    
end
