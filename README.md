# XPD
This is a package written in IGOR Pro scripting language for XPD (X-ray photoelectron diffraction) data acquisition, displaying, process, and analysis. 

"XPD.ipf" is the script file of the package. Please read "XPD Package Manual.pdf" for how to install and use the package.

"Data_Sample_1.csv" and "Data_Sample_2.csv" are two data samples for testing.
"Data_Sample_1.csv" has two core levels at every sample position (theta, phi). The 4th Displaying mode can be used for the 2nd core level (Ag3d), i.e., click the 2nd check box in "Two Fitted Components" mode in the "XPD Data Acquisition" panel before starting data acquisition.
"Data_Sample_2.csv" has only one core level.

The package provides an easy-to-use suite of tools for displaying, processing and analyzing XPD data. Processing tools include rotation, cropping, smoothing and making a full 2pi pattern. Analysis tools include displaying the coordinates and intensity of a data point, displaying azimuthal and radial profiles, displaying and fitting the corresponding XPS spectrum of a data point. 

The package was initially designed to interface directly with an XPD system (using Omicron Argus spectrometer) at the Saclay center of the French Alternative Energies and Atomic Energy Commission (CEA), but the algorithms are generally applicable and can be readily adapted to other XPD systems since the package just reads out the data exported from a spectrometer. Users can modify only some parts of the code, for example, the data reading module, to make the package read the XPD data exported from another spectrometer so that the package is adapted to another XPD experiment system since the principle of XPD data processing is the same and most function modules can be called without modification. 

Anyone who uses this package, please reference "Xihui Liang, Nicholas Barrett, XPD package." in publication.

Disclaimer: This package is free for non-commercial use; you can redistribute it and/or modify it for non-commercial purpose. The commercial right is reserved. This package is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
