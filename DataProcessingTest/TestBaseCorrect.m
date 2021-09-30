function MSroiBaseCorr=TestBaseCorrect(MSroi_test,Times)
%TestBaseCorr. Test Baseline Correction parameters.
%   Opens the documentation for msbackadj, performs baseline correction for a test file and plots the original and baseline corrected data. 
%   Run the function, the documentation for msbackadj is loaded and can be
%   reviewed for usage of all selectable parameters. Return to the cammand
%   window and press any key to continue. A window appears to define
%   parameters, click OK. Background correction is performed and plotted as well as the
%   original file. 
doc msbackadj
disp('Review msbackadj documentation for parameters');
disp('Press any key to continue');
pause
prompt = {'Shifting Window Size:','Step Size:','Regression Method:','Estimation Method:','Smoothing Method:','Quantile Value:'};
        dlgtitle = 'Select Baseline Correction Parameters';
        dims = [1 60];
        definput = {'200','200','pchip, linear or spline','quantile or em','none, lowess, loess, rlowess or rloess','0.1'};
        answer = inputdlg(prompt,dlgtitle,dims,definput);
        A=answer{1,1};
        B=answer{2,1};
        Reg=answer{3,1};
        Est=answer{4,1};
        Smoo=answer{5,1};
        C=answer{6,1};
        SWS = str2double(A);
        SS = str2double(B);
        Quan = str2double(C);
   disp('Performing Baseline Correction...');
   MSroiBaseCorr = msbackadj(Times,MSroi_test,'WindowSize',SWS,'StepSize',SS,'RegressionMethod',Reg,'EstimationMethod',Est,'SmoothMethod',Smoo,'QuantileValue',Quan,'PreserveHeights',true);
   MSroiBaseCorr = abs(MSroiBaseCorr);
   disp('DONE');
   fig0 = figure('Name','Original Data','NumberTitle','off');
                plot(Times,MSroi_test);
                xlabel('Elution time');
                ylabel('Intensity');
   fig1 = figure('Name','Corrected Data','NumberTitle','off');
                plot(Times,MSroiBaseCorr);
                xlabel('Elution time');
                ylabel('Intensity');
end

