# ROIMCRALS
MatLab Code for ROI-MCR-ALS analysis of .mzXML mass spectrometry data.

ROIprocess automatically performs ROI search, data preprocessing and data augmentation and uses functions (ROIpeaks.mat, ROIplot.mat, MSroiaug.mat) developed by Romà Tauler, Eva Gorrochategui and Joaquim Jaumot https://doi.org/10.1038/protex.2015.102

Outputs from ROIprocess can directly be used for MCR-ALS analysis with MCR-ALS GUI 2.0.
MCR-ALS GUI 2.0 was developed by Joaquim Jaumot, Anna de Juan and Romà Tauler https://doi.org/10.1016/j.chemolab.2014.10.003
Download at https://mcrals.wordpress.com/download/mcr-als-2-0-toolbox/

MCR-ALS output can be sorted, visualizedy evaluated and compared to Databank search results (.csv files) and suspect target lists.
As well as automated search for MS2 spectra.

Required MatLab Toolboxes:

Statistics and Machine Learning Toolbox
Bioinformatics Toolbox
Parallel Computing Toolbox

For MS Data conversion to .mzXML file format use msconvert, distributed with the ProteoWizard Project http://proteowizard.sourceforge.net/download.html 
