# PIGEanalysis

**Usage**

Program starts at batchGSpec function. Input is a folder containing spectra of interest. 
An appropriate spectrum file reader function is provided. .SPE or .CHN files may be used.

The main branch requires multiple current inputs with the corresponding file indexes.

The single entry branch requires a single current value with the index. It will use the dead-time correct corrected argon values to determine the appropriate current value for each sample. It reports the dead-time corrected fluorine counts per uC of charge deposited. 

***The recommended branch is the single entry branch.***
