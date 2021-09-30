function [MSroi_test,mzroi_test,Times] = TestROI(TestPeak,TestTime)
%TestROI Test ROI parameters and plot the result. 
%Output can be used to test Baseline Correction and Golay Smoothing parameters for ROIprocess
%   
prompt = {'Intensity Threshold:','MZ Error [Da]:','Minimum ROI Size:','Starting Scan Number to Process:','Last Scan Number to Process:'};
        dlgtitle = 'Select ROI parameters';
        dims = [1 60];
        definput = {'10000','0.05','20','1','1500'};
        answer = inputdlg(prompt,dlgtitle,dims,definput);
        thresh = str2double(answer{1,1});
        mzerror = str2double(answer{2,1});
        minroi = str2double(answer{3,1});
        nrowsStart = str2double(answer{4,1});
        nrowsEnd = str2double(answer{5,1});
        if nrowsStart ~= 1
            nrowsStart = nrowsStart+1;
        end
TestPeak=TestPeak(nrowsStart:nrowsEnd,:);
Times=TestTime(nrowsStart:nrowsEnd,:);
nrows=length(Times);
[mzroi_test,MSroi_test]=ROIpeaks(TestPeak,thresh,mzerror,minroi,nrows,Times);
end

