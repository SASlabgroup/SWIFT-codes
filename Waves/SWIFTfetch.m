function SWIFT_edited=SWIFTfetch(SWIFT,other_lat,other_lon,other_z)
%%%%%%%%%%%%%%%%%SWIFTfetch.m
%
%   Calculates fetch from a SWIFT structure and lat, lon, z from the local
%   area. Uses a distance calculation for each SWIFT point and assigns the
%   values in the SWIFT structure as SWIFT.fetch, SWIFT.fetchnondim, SWIFT.fetch_lat, and SWIFT.fetch_lon. Uses
%   the onboard wind speed, wind direction, latitude, and longitude
%   measurements. Uses SWIFTtransform.m. 
%
%   Created: S. Kastner, July 2016


SWIFT_edited=SWIFT;                                                         % copy existing structure



tolerance=1;                                                                % set directional and elevational tolerances/thresholds
z_thresh=0;


g=9.8;                                                                      % get needed SWIFT variables, initialize fetch variables
SWIFT_winddir=[SWIFT.winddirT];
SWIFT_lat=[SWIFT.lat];
SWIFT_lon=[SWIFT.lon];
SWIFT_windspd=[SWIFT.windspd];
fetch=NaN*zeros(length(SWIFT));
fetchnondim=fetch;
fetch_lat=fetch;
fetch_lon=fetch;

if isempty(SWIFT)==0                                                            %check if empty, if so end
   

    for jn=1:length(SWIFT);                                                     % make fetch calculation at each SWIFT index
        wind_dir=SWIFT_winddir(jn);
        
        if wind_dir~=9999 && SWIFT_windspd(jn)~=9999;                           % check if good wind data

            if exist('x')==0 && exist('y')==0                                           % only make transform calculation if this is the first fetch calculated, 
                                                                                        % otherwise transpose grid using deg2km
                [x,y]=SWIFTtransform(other_lat,other_lon,SWIFT_lat(jn),SWIFT_lon(jn));
            
            elseif exist('x')==1 && exist('y')==1
                
                dx=deg2km(SWIFT_lon(jn)-SWIFT_lon(jn-1))*1000;
                dy=deg2km(SWIFT_lat(jn)-SWIFT_lat(jn-1))*1000;
                
                x=x+dx;
                y=y+dy;
                
            end
            theta=90-atan2d(y,x);                                                      % calculate polar coordinates
            theta(theta<0)=theta(theta<0)+360;                      
            r=sqrt(x.^2+y.^2);                                                         

            ind=find(abs((theta-wind_dir))<=tolerance);                                 % find the wind-directional ray

            z_vec=other_z(ind); 
            r_vec=r(ind);

            [fetch(jn), i]=min(r_vec(z_vec>z_thresh));                                  % fetch is the smallest value of r that satisfies the z threshold
            ind=ind(z_vec>z_thresh);
            f_i=ind(i);
            
            U_10=SWIFT_windspd(jn)*1.35;                                                % correct U_1 to U_10
            
            fetchnondim(jn)=g.*fetch(jn)./(U_10.^2);
            
            fetch_lat(jn)=other_lat(f_i);                                               % fetch land origin for drawing lines
            fetch_lon(jn)=other_lon(f_i);
            
        elseif wind_dir==9999 || SWIFT_windspd(jn)==9999;

               disp('No Wind Data')

        end

        SWIFT_edited(jn).fetch=fetch(jn);                                               % populate output structure
        SWIFT_edited(jn).fetchnondim=fetchnondim(jn);
        SWIFT_edited(jn).fetch_lat=fetch_lat(jn);
        SWIFT_edited(jn).fetch_lon=fetch_lon(jn);

    end

elseif isempty(SWIFT)==1;
    disp('Empty SWIFT')
end

end
