function MSroiSmooth=TestGolaySmooth(MSroiBaseCorr,Times)
%TestGolaySmooth Performs Golay Smoothing for a test file and plots the original and corrected data. 
%   Run the function, a window appears to define
%   parameters, click OK. Golay Smoothing is performed and plotted as well as the original file.
prompt = {'Frame Size:','Polynomial degree:'};
    dlgtitle = 'Select Smoothing Parameters';
    dims = [1 60];
    definput = {'15','2'};
    answer = inputdlg(prompt,dlgtitle,dims,definput);
    span = str2double(answer{1,1});
    degree = str2double(answer{2,1});
    
disp('Performing Golay Smoothing...');
    MSroiSmooth = mssgolay(Times,MSroiBaseCorr,'Span',span,'Degree',degree);
    MSroiSmooth = abs(MSroiSmooth);
    disp('DONE');
    
fig0 = figure('Name','Original Data','NumberTitle','off');
       plot(Times,MSroiBaseCorr);
       xlabel('Elution time');
       ylabel('Intensity');
fig1 = figure('Name','Corrected Data','NumberTitle','off');
       plot(Times,MSroiSmooth);
       xlabel('Elution time');
       ylabel('Intensity');
end

