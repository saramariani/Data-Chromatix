Data-Chromatix
================
#### Overview
Analysis of biomedical time series plays a key role in clinical management and basic investigation. However, most conventional monitors streaming data in real-time show only the most recent values, not referenced to past dynamics. The proposed visualization method (termed “data chromatix”) was developed to address this challenge by bringing memory of the system’s past behavior into the current display window. 

The function DataChromatix.m (version 1.0) assigns a color to each data point of a time series. The color is determined by the values of a normalized histogram (estimated probability density function) computed from a pre-selected segment of the data. The algorithm receives the time series as input and generates a video of its colorized version as it would look on a typical monitor display, as well as a static graph of the entire colorized signal.

The algorithm has the following parameters: the memory and colorization window lengths, the shift (s), the histogram bin size, and the number of colors (c) in the chromatic map.

At each step, a normalized histogram of the data points in the memory window is computed. Then, the interval [0,1] is divided into c adjacent intervals, and each interval is assigned a color. If the jet color-map is used, the interval [0,1/c) corresponds to dark red and the interval ((c-1)/c,1] corresponds to dark blue. Subsequently, each data point in the colorization window is assigned the color of the histogram bin into which it falls. Finally, the colorization window is advanced by the shift, s, and the memory window is either extended or advanced by the same amount. 

This colorization algorithm is intended to facilitate analysis of physiologic and non-physiologic time series. Future studies will help assess its utility.

For illustrations and further information, please refer to the [Data Chromatix PhysioNet page](https://physionet.org/physiotools/dchromatix/).

#### Sample Input
Mandatory inputs to the function are:
-	The time series to be colorized
-	The units to show on the x and y axis
-	The length of the window to display in the video
-	The shift

Optional inputs to the function are:
-	The length of the memory window (default from the beginning of recording to the end of the colorization window)
-	The length of the colorization window (default equal to the display window)
-	The number of bins of the histogram (default determined by means of Friedman-Diaconis rule)
-	The number of colors in the color-map (default = 64)
-	The smoothing parameter for the histogram (default = 10)
-	The data sampling frequency (default = 1 Hz)
-	The name of the video (if = 0 does not create the video, default = ‘Myvideo’)
-	A flag for data time format, when time units are seconds (if =1, the format is mm:ss, if =0 the format is s, default = 0) 
-	The desired color-map (default jet)

Along with the function, we provide two examples that employ a fetal heart rate time series from the CTU-UHB Intrapartum Cardiotocography Database on PhysioNet, one using a memory window starting from the beginning of the recording, the other using a moving memory window of fixed length. 

#### Requirements
MATLAB R2014a or later. 
Please note that for loading the time series, the [MATLAB version of the wfdb library](http://physionet.org/physiotools/matlab/wfdb-app-matlab/) must be installed.

#### Acknowledgments
Acknowledgements: This package was developed at the Wyss Institute for Biologically Inspired Engineering at Harvard University and Beth Israel Deaconess Medical Center/Harvard Medical School by A. Burykin, S. Mariani, T. Silva, A.L. Goldberger, M.D. Costa and T. Henriques

Users of our software should cite: [Burykin A, Mariani S, Henriques T, Silva T, Schnettler W, Costa MD, Goldberger AL. Remembrance of time series past: simple chromatic method for visualizing trends in biomedical signals. Physiol Meas 2015;36(7):N95.](http://iopscience.iop.org/article/10.1088/0967-3334/36/7/N95)

#### More Questions
Please report bugs and questions at sara.mariani7@gmail.com.


#### Related links
- [National Sleep Research Resource](https://sleepdata.org/)
- [Physionet: Data Chromatix] (https://physionet.org/physiotools/dchromatix/)
