function [TestPeak,TestTime] = LoadTestData
%LoadTestData loads TestData to aid in selection of parameters for
%ROIprocess and plots TIC/Elution time, BasePeak/ Elution Time and Basepeak/Scan Number.
%

[File,path] = uigetfile('*.mzXML','Select Test Sample','MultiSelect','off');
File=fullfile(path,File);
disp(['Now reading ', File]);
mzxml = mzxmlload(File,'Levels',1);
[TestPeak, TestTime]= mzxml2peaks(mzxml);

TIC = NaN * ones(length(TestPeak),1);
BPC = NaN * ones(length(TestPeak),1);
for f=1:length(TestPeak)
    TIC(f)=sum(TestPeak{f,1}(1:end,2));
    BPC(f)=max(TestPeak{f,1}(1:end,2));
end
fig0 = figure('Name','TIC/ElutionTime','NumberTitle','off');
                plot(TestTime,TIC);
                xlabel('Elution time');
                ylabel('Intensity');
fig1 = figure('Name','BasePeak/ElutionTime','NumberTitle','off');
                plot(TestTime,BPC);
                xlabel('Elution time');
                ylabel('Intensity');               
fig2 = figure('Name','BasePeak/ScanNumber','NumberTitle','off');
                plot(BPC);
                xlabel('Scan Number');
                ylabel('Intensity');
end

