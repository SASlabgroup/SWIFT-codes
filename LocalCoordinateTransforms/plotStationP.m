figure(6), hold on

% old waverider (recovered on 2 Jan 2015 at 22:00 Z)
%hold on, plot(-145.2433,49.9037,'bo','markersize',16,'linewidth',3)

% new waverider (deployed 31 Dec 2014 at 23:00 Z
hold on, plot(-145.2,50.0333,'ko','markersize',16,'linewidth',3)

% SAR corners for 2015-01-01T16:03:20 
%hold on, plot( [ -144.9891 -144.6245 -145.0396 -145.3948 ], [49.4891  50.6110  50.6660  49.5435 ], 'r+','markersize',16,'linewidth',3)

% SAR corners for 2015-01-05T03:29:12
hold on, plot( [-144.6396 -144.8516 -145.2687 -145.0492], [49.6052  50.4805  50.4377  49.5624 ], 'r+','markersize',16,'linewidth',3)

% NOAA met buoy
hold on, plot(-144-52.52/60, 50+3.04/60,'gs','markersize',16,'linewidth',3)


grid on