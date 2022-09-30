% Matlab script to convert a batch of SWIFT matlab structures into NetCDF
%
% J. Thomson, May 2021

close all, clear all

flist = dir('*SWIFT*.mat')

for fi=1:length(flist), 

    load(flist(fi).name)
%     for si=1:length(SWIFT),
%         SWIFT(si).ID = str2num([flist(fi).name(6:7)]);
%     end
   %if isfield(SWIFT(1),'downlooking'), SWIFT = rmfield(SWIFT,'downlooking'); end
   %if isfield(SWIFT(1),'uplooking'), SWIFT = rmfield(SWIFT,'uplooking'); end
   %if isfield(SWIFT(1),'signature'), SWIFT = rmfield(SWIFT,'signature'); end
   if isfield(SWIFT(1),'winddirR'), SWIFT = rmfield(SWIFT,'winddirR'); end
   if isfield(SWIFT(1),'winddirRstddev'), SWIFT = rmfield(SWIFT,'winddirRstddev'); end
   if isfield(SWIFT(1),'airpres'), SWIFT = rmfield(SWIFT,'airpres'); end
   if isfield(SWIFT(1),'airpresstddev'), SWIFT = rmfield(SWIFT,'airpresstddev'); end
   if isfield(SWIFT(1),'CTdepth'), SWIFT = rmfield(SWIFT,'CTdepth'); end
   if isfield(SWIFT(1),'metheight'), SWIFT = rmfield(SWIFT,'metheight'); end
   if isfield(SWIFT(1),'date'), SWIFT = rmfield(SWIFT,'date'); end
   %SWIFT = rmfield(SWIFT,'ID');


   %% squash multiple CT depths
   if isfield(SWIFT(1),'watertemp') && length(SWIFT(1).watertemp)>1
       for si=1:length(SWIFT)
           SWIFT(si).watertemp = nanmean(   SWIFT(si).watertemp );
       end
   end
   if isfield(SWIFT(1),'salinity') && length(SWIFT(1).salinity)>1
       for si=1:length(SWIFT)
           SWIFT(si).salinity = nanmean(   SWIFT(si).salinity );
       end
   end

    
    SWIFT2NC(SWIFT,[ flist(fi).name(1:end-4) '.nc'] )
    
end