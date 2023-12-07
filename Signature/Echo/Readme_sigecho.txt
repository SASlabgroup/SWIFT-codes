Reference:
C. Bassett and K. Zeiden, Calibration and Processing of Nortek Signature 
1000 Echosounders (2020). Technical Report, APL-UW TR 2303. Applied
Physics Laboratory, University of Washington, Seattle, Dec. 2023, 37 pp.

Last modifications: 6 December 2023 by Chris Bassett

Notes: 

6 Dec 2023
The codes here are those used to processing Nortek Signature1000 data
collected by APL-UW's SWIFT drifters. However, the scripts could be 
modified to support general processing of Signature1000 echosounder 
data with relatively few changes. 

The script for processing volume backscattering uses the gains determined
during tests in June 2023. These gains are only relevent to volume backscattering
measurements due to the sampling parameters used by the SWIFTS. Those gains
should not be directly applied to calculate TS using the sigecho_target script.
The sigecho_target script for calculating TS has been included solely to 
provide a code that could be easily modified for later use if gains are
re-calculated.  

The individual codes all well-commented and describe all input/output varibles.
Please reference the individual functions for further information. 

The script to detect and make the bottom has not been fully tested using
deep water measurements. Once new data are available the codes will be modified.