# ROIMCRALS
MatLab Code for ROI-MCR-ALS analysis of LC/GC/CE - MS  data in the .mzXML file format.

Required MatLab Toolboxes:

 - Statistics and Machine Learning Toolbox
 - Bioinformatics Toolbox
 - Parallel Computing Toolbox

ROIprocess2 loads an MS file and shows the basepeak chromatogram. ROI parameters, preprocessing options and Filters can be set in the GUI and the preview graph is updated for direct visual feedback.

Set parameters are then used to perform ROI search, data preprocessing and data augmentation.
It uses functions (ROIpeaks.mat, ROIplot.mat, MSroiaug.mat) developed by Romà Tauler, Eva Gorrochategui and Joaquim Jaumot https://doi.org/10.1038/protex.2015.102

Outputs from ROIprocess2 can directly be used for MCR-ALS analysis with MCR-ALS GUI 2.0.
MCR-ALS GUI 2.0 was developed by Joaquim Jaumot, Anna de Juan and Romà Tauler https://doi.org/10.1016/j.chemolab.2014.10.003
Download at https://mcrals.wordpress.com/download/mcr-als-2-0-toolbox/

MCR-ALS output can be sorted, visualizedy evaluated and compared to Databank search results (.csv files) and suspect target lists.
As well as automated search for MS2 spectra.

For MS Data conversion to .mzXML file format use msconvert, distributed with the ProteoWizard Project http://proteowizard.sourceforge.net/download.html 

MatLab_ROIMCRALS_Cheatsheet.pdf contains a quick overview of all command line codes.

See ROI_MCR_ALS_Manual_v2.0.pdf for a detailed guide how to use these functions.

For feature requests and bug reports open a new issue or contact me at Adrian.Haun@hs-aalen.de
