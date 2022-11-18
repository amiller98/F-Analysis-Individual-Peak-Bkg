# PIGEanalysis

**Usage**

Program starts at batchGSpec function. Input is a folder containing spectra of interest. 
An appropriate spectrum file reader function is provided. .SPE or .CHN files may be used.

Requires a single current value with the index. It will use the dead-time correct corrected argon values to determine the appropriate current value for each sample. It reports the dead-time corrected fluorine counts per uC of charge deposited. 
