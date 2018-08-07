Data from the Surface Wave Instrument Float with Tracking (SWIFT) are calculated as 10-minute ensembles and stored in a single structure in Matlab.  The structure is a collection of individual structures, with data products for each 512-second burst.  Use square brackets to index all ensembles, i.e.: 

>> plot([SWIFT.time],[SWIFT.sigwaveheight],'x')



The full variable list and units are as follows: 

SWIFT.uplooking.tkedissipationrate: vertical profiles of turbulent dissipation rate in W/kg (= m^2 / s^3) from an uploading AquadoppHR

SWIFT.uplooking.z: depth bins, in meters below the wave-following surface, for the TKE dissipation rate profiles

SWIFT.downlooking.velocityprofile: vertical profiles of horizontal velocity magnitude, in m/s, relative to the float (not corrected for drift) from an downlooking Aquadopp

SWIFT.downlooking.z: depth bins, in meters below the wave-following surface, for the velocity profiles

SWIFT.signature: as above, but from a Nortek Signature, rather than an Aquadopp

SWIFT.winddirT: true wind direction, in degrees FROM North

SWIFT.winddirTstddev: standard deviation of true wind direction, in degrees

SWIFT.windspd: wind speed, in m/s, at 1 m height above the wave-following surface

SWIFT.windspdstddev: standard deviation, in m/s, of wind speed

SWIFT.time: UTC timestamp in MATLAB datenum format (serial days since 0 Jan 0000)

SWIFT.date: human readable date as day, month, year

SWIFT.airtemp: air temperature, in deg C, at 1 m height above the wave-following surface

SWIFT.airtempstddev: standard deviation of air temperature, in deg C

SWIFT.sigwaveheight: significant wave height, in meters

SWIFT.peakwaveperiod: peak of period orbital velocity spectra (note convention is usually wave height spectrum)

SWIFT.peakwavedirT: wind direction, in degrees FROM North

SWIFT.wavespectra.energy: wave energy spectral density, in m^2/Hz, as a function of frequency.  Note that this is derived from orbital motions and is thus insensitive to low-energy swell conditions.  The technique is best suited to measuring short wind waves. 

SWIFT.wavespectra.freq: spectral frequencies, in Hz

SWIFT.wavespectra.a1: normalized spectral directional moment (positive east)

SWIFT.wavespectra.b1: normalized spectral directional moment (positive north)

SWIFT.wavespectra.a2: normalized spectral directional moment (east-west)

SWIFT.wavespectra.b2: normalized spectral directional moment (north-south)

SWIFT.wavespectra.check: spectral comparison of horizontal to vertical motion (only available with post-processing).  Should be equal to 1 for good data in deep water.

SWIFT.lat: latitude in decimal degrees

SWIFT.lon: longitude in decimal degrees

SWIFT.watertemp: water temperature, in deg C, at 0.5 m below the surface

SWIFT.salinity: water salinity, in PSU, at 0.5 m below the surface

SWIFT.puck: three color channels of a WetLabs puck flourometer

SWIFT.driftdirT: drift direction TOWARDS, in degrees True (equivalent to "course over ground")

SWIFT.dirftspd: drift speed in m/s (equivalent to "speed over ground")

SWIFT.O2conc: oxygen concentration 

SWIFT.FDOM: fluorescent dissolved organic material 

SWIFT.z: raw vertical displacements in meters 

SWIFT.x: raw horizontal east-west displacements in meters

SWIFT.y: raw horizontal east-west displacements in meters

SWIFT.u: raw east-west GPS velocities in m/s

SWIFT.v: raw north-south GPS velocities in m/s

SWIFT.rawtime: raw UTC timestamps in Matlab datenum



