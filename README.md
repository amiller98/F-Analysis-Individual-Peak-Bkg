# PIGEanalysis

**Usage**

Program starts at batchGSpec function. Input is a folder containing spectra of interest. 
An appropriate spectrum file reader function should be provided. We currently have readchn for the binary format.
One for .spe files is being developed.

Peaks of interest are specified. NOTE: In upcoming versions, we may completely ignore the conversion from channel to energy and work with
just the channel numbers after we've identified which correspond to 109, 197, 660 keV. 

Peaks are fitted and AUC are divided by the live-time corresponding to that spectra.

NOTE: planning on creating an input for the average current for each run.

A normalization routine ensues and the calculations are ejected into a summary spreadsheet 
