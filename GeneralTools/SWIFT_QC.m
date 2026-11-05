function [flist, removed] = SWIFT_QC( minsalinity, minwave, maxdrift, varargin )
% Matlab function to apply quality control to SWIFT data
% by listing all SWIFT .mat files in directory and screening for 
% low salinity, low wave heights, or fast speeds 
% (all of which indicate a buoy on deck / on shore (i.e., not in the ocean)
%
%   [flist removed] = SWIFT_QC( minsalinity, minwave, maxdrift, detectice )
%
%   Optional argument detectice: if true (default), flags wave spectra likely collected in sea ice.  
%
%   J. Thomson, Nov 2023
%   L. Crews, Nov 2026 - add optional ice detection from wave spectra

flist = dir('*SWIFT*.mat');

mintemp = -40;

detectice = true; % Default - run ice flagging
if ~isempty(varargin)
    detectice = varargin{1};
end

for fi = 1:length(flist)

    load(flist(fi).name)
    original = length(SWIFT);

    if isfield(SWIFT,'salinity')
        badsal = [SWIFT.salinity] < minsalinity | [SWIFT.salinity]>=9999;  % this will break if multiple salinity values (salty SWIFTs)
        SWIFT(badsal) = [];
    end


    if isfield(SWIFT,'sigwaveheight')
        badwave = [SWIFT.sigwaveheight] < minwave | [SWIFT.sigwaveheight]>=9999; 
        SWIFT(badwave) = [];
    end

    if isfield(SWIFT,'driftspd')
        baddrift = [SWIFT.driftspd] > maxdrift; 
        SWIFT(baddrift) = [];
    end

    if isfield(SWIFT,'watertemp')
        for si=1:length(SWIFT)
            if SWIFT(si).watertemp < mintemp  
                SWIFT(si).watertemp = NaN;
            end
        end 
    end

    if detectice && isfield(SWIFT,'wavespectra')
        for si=1:length(SWIFT)
            Hs = SWIFT(si).sigwaveheight;
            Tp = SWIFT(si).peakwaveperiod;
    
            f = SWIFT(si).wavespectra.freq;
            E = SWIFT(si).wavespectra.energy;               
            
            % Spectral tail shape will be fit for frequencies above f_fit
            % For the red spectra typical of observations in ice, it may be
            % better to specify a constant frequency rather than use the
            % apparent fp (which may be very low if no actual wave peak)
            f_fit = 1/Tp; % Hz. Can can also use a constant - recommend 0.4 if short period waves / substantial fetch limitation are expected
            
            in_ice = flag_icespectra(f, E, Hs, Tp, f_fit);
            SWIFT(si).in_ice = in_ice;
    
            % mask wave stats but retain spetra
            if in_ice        
                SWIFT(si).sigwaveheight = nan;
                SWIFT(si).peakwaveperiod = nan;
                SWIFT(si).peakwavedirT = nan;
            end
        end

    end

    removed(fi) = original - length(SWIFT);

    save(flist(fi).name,'SWIFT*')

end

end