function [winddirR windspd airtemp relhumidity airpres rainaccum rainint ] = readSWIFT_WXT( filename );
% function to read raw Vaisala WXT files from SWIFTs
% usage:
%
% [winddirR windspd airtemp relhumidity airpres rainaccum rainint ] = readSWIFT_WXT( filename );
%
% where filename is a string including the file extension .dat
%
% J. Thomson, 4/2020

data = importdata( filename );

if iscell(data),
    
    for di = 1:length(data),
        
        thisline = data{di};
        
        equalsigns = find(thisline=='=');
        commas = find(thisline==',');
        
        if length(equalsigns)==7 && length(commas)==7 && length(thisline)>=65,
            temp = str2num( thisline( equalsigns(1)+1:commas(2)-2 ) ) ;
            if ~isempty(temp), winddirR(di)  = temp(1); else winddirR(di) = NaN; end
            temp = str2num( thisline( equalsigns(2)+1:commas(3)-2 ) ) ;
            if ~isempty(temp), windspd(di)   = temp(1) ; else windspd(di) = NaN; end
            temp = str2num( thisline( equalsigns(3)+1:commas(4)-2 ) ) ;
            if ~isempty(temp), airtemp(di)   = temp(1); else airtemp(di) = NaN; end
            temp = str2num( thisline( equalsigns(4)+1:commas(5)-2 ) );
            if ~isempty(temp), relhumidity(di) = temp(1) ; else relhumidity(di) = NaN; end
            temp = str2num( thisline( equalsigns(5)+1:commas(6)-2 ) ) ;
            if ~isempty(temp), airpres(di)   = temp(1); else airpres(di) = NaN; end
            temp = str2num( thisline( equalsigns(6)+1:commas(7)-2 ) ) ;
            if ~isempty(temp), rainaccum(di) = temp(1) ; else rainaccum(di) = NaN; end
            temp = str2num( thisline( equalsigns(7)+1:length(thisline)-1 ) );
            if ~isempty(temp), rainint(di)   = temp(1) ; else rainint(di)   = NaN; end
        else,
            winddirR(di)  = NaN;
            windspd(di)   = NaN;
            airtemp(di)   = NaN;
            relhumidity(di) = NaN;
            airpres(di)   = NaN;
            rainaccum(di)     = NaN;
            rainint(di)     = NaN;
        end
        
        
        
    end
    
    save(filename(1:end-4),'winddirR', 'windspd', 'airtemp', 'relhumidity', 'airpres', 'rainaccum', 'rainint')
    
else
    
    di = 1;
    winddirR(di)  = NaN;
    windspd(di)   = NaN;
    airtemp(di)   = NaN;
    relhumidity(di) = NaN;
    airpres(di)   = NaN;
    rainaccum(di)     = NaN;
    rainint(di)     = NaN;
    
end