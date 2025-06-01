Surface Wave Instrument Float with Tracking (SWIFT) data

Processed SWIFT data are ensemble-averages over "bursts" of raw data.
A burst is typically 512-seconds (8.5 minutes) long. 
Bursts are typically obtained at intervals of 720 seconds (12 minutes).  
Raw data are processed (QCd and burst-averaged) and then combined in a single structure in MATLAB ('SWIFT').
The 'SWIFT' structure is an array of individual structures which contain the burst-averaged data products from each instrument, for each burst.
Any given SWIFT data structure will only contain fields corresponding to the instruments that were on that particular SWIFT.    
You can use square brackets to index all burst ensembles (except for substructures), i.e.: 

	>> plot([SWIFT.time],[SWIFT.sigwaveheight],'x')

There are various levels of post-processing, detailed below. 
Each has a corresponding version of the SWIFT structure for a given 'mission' (single deployment)

Level 0 (L0): Raw data contained in burst files. There is no corresponding SWIFT structure for this level.
	Data are contained within a mission directory folder (e.g. 'SWIFT24_24Oct2024'), with subfolders for each instrument payload.
	The instrument subfolders are named either by serial com port # (e.g. 'COM-3'), or instrument short-name (e.g. 'SIG' for Signature1000).  
	Within each instrument subfolder, burst files are further sorted into subfolders based on date (e.g. '20241104' for Nov 04, 2024).
	Burst files are named with the mission name, instrument short-name, burst time to the hour, and burst number within the hour 
	(e.g. 'SWIFT24_SIG_24Nov2025_14_05.dat').

Level 1 (L1): On-board processed data, contains data products such as wave spectra, turbulent dissipation rate, bulk wind speeds, etc. 
	These data are made available in real time via Iridium telemetry, and can be queried after a deployment as well. 
	Quality control is limited. 

Level 2 (L2): Basic QC of the on-board processed data to identify and remove bursts obtained when the SWIFT was out of the water. 

Level 3 (L3): Some or all instruments are reprocessed using the raw burst data offloaded after the SWIFT has been recovered. 
	This product has significantly more quality control than the L2 product. 

Level 4 (L4): Ad hoc, experiment specific quality control applied to a SWIFT structure. This is the highest quality-controlled SWIFT version.

The SWIFT processing code library is available at https://github.com/jthomson-apluw/SWIFT-codes

The full list of SWIFT variables and units follow, but note again that no single SWIFT will have all fields:  

Variable		Units		Description
--------		-----		-----------	
windspd			m/s		wind speed 1 m above the wave-following surface measured by MET sensor
windspdstddev		m/s		standard deviation of wind speed
winddirT		degrees 	true wind direction (from North)
winddirTstddev		degrees		standard deviation of true wind direction
winddirR		degrees 	relative wind direction (from North)
winddirRstddev		degrees		standard deviation of relative wind direction
airtemp			deg C		air temperature 1 m above the wave-following surface  measured by MET sensor
airtempstddev		deg C		standard deviation of air temperature
airtpres		mb		air pressure 1 m above the wave-following surface  measured by MET sensor
airtpresstddev		mb		standard deviation of air pressure
relhumidity		%		relative humidity 1 m above the wave-following surface  measured by MET sensor
relhumiditystddev	%		standard deviation of relative humidity
radiancemean		mV		radiance measured by radiometer
radiancestd		mV		standard deviation of radiance
infraredtemp		deg C		(uncalibrated) target temperature inferred from radiance, should be close to true skin temperature
infraredtempstd		deg C		standard deviation of target temperature
ambienttemp		deg C		ambient temperature measured by radiometer
ambienttempstd		deg C		standard deviation of ambient temperature
sigwaveheight		m		significant wave height estimated from wave energy spectrum
peakwaveperiod		s		period corresponding to peak in wave energy spectrum
peakwavedirT		degrees		wave direction (from North)
wavespectra				structure containing IMU spectral wave data
- energy		m^2/Hz		wave energy spectral density as a function of frequency, derived from surface elevation measured by IMU
- freq			Hz		spectral frequencies
- a1			-		normalized spectral directional moment (positive east)
- b1			-		normalized spectral directional moment (positive north)
- a2			-		normalized spectral directional moment (east-west)
- b2			-		normalized spectral directional moment (north-south)
watertemp		deg C		water temperature 0.5 m below the surface, measured by CT
watertempstddev		deg C		standard deviation of water temperature
salinity		PSU		water salinity 0.5 m below the surface, measured by CT
salinitystddev		PSU		standard deviation of water salinity
signature				structure containing Nortek Signature1000 HR ADCP data (downlooking configuration)
- profile				sub-structure containing broadband data
--- altimeter		m		water depth
--- east		m/s		vertical profiles of zonal velocity (broadband) beneath the wave-following free surface
--- north		m/s		vertical profiles of meridional velocity (broadband) beneath the wave-following free surface
--- w			m/s		vertical profiles of vertical velocity (broadband) beneath the wave-following free surface
--- z			m		depth bins for the velocity profiles
--- spd_alt		m/s		burst-averaged scalar speed (as opposed to scalar speed computed from burst-averaged ENU velocities)
- HRprofile				sub-structure containing pulse-coherent (high-resolution, 'HR') data
--- w			m/s		vertical profiles of vertical velocity (HR) beneath the wave-following free surface
--- wvar		m/s		vertical velocity standard deviation
--- tkedissipationrate	m^2/s^3		vertical profiles of turbulent dissipation rate beneath the wave-following free surface
--- z			m		depth bins for the tke dissipation rate profiles
uplooking				structure containing Nortek Aquadopp HR ADCP data (uplooking configuration)
-- tkedissipationrate	m^2/s^3		vertical profiles of turbulent dissipation rate beneath the wave-following free surface
-- z			m		depth bins for the tke dissipation rate profiles
time			days		MATLAB datenum time 
date			-		string giving burst date in format 'ddmmyyyy'
lat			deg		latitude
lon			deg		longitude
driftdirT		deg		true drift direction TOWARDS (equivalent to "course over ground")
driftspd		m/s		drift speed in m/s (equivalent to "speed over ground")
sbdfile			-		short-burst data file
burstID			-		burstID named by burst timestamp, consistent with all raw sensor burst files
battery			V		battery voltage
ID			-		SWIFT ID
metheight		m		height of the MET sensor
CTdepth			m		depth of the CT sensor
		
Older Version SWIFT Structure		
z			m		vertical displacements at 25 Hz
x			m		horizontal east-west displacements at 25 Hz
y			m		horizontal north-south displacements at 25 Hz
u			m/s		east-west GPS velocities at 4 Hz
v			m/s		north-south GPS velocities at 4 Hz
puck			-		three color channels of a WetLabs puck flourometer
downlooking				structure containing Nortek Aquadopp HR ADCP data (downlooking configuration)                   
- velocityprofile	m/s		vertical profiles of horizontal velocity magnitude
- z			m		depth bins for the velocity profiles
