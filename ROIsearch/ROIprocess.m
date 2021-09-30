function [MSroi_end,mzroi_end,time_end,nRows,Parameters] = ROIprocess
%ROIprocess Performs ROI search for mzXML Files for single and pairwise data
%   This function automatically imports .mzXML Files and performs ROI
%   search and augmentation with various selectable parameters. The output
%   is designed to be further analyzed with MCR-ALS toolbox 2.0
%   User imputs are handled by GUIs. Selectable options: 
%   Single or Pairwise Data
%   Blank substraction
%   ROI search parameters
%   Baseline Correction and Baseline Correction parameters
%   Savitzky-Golay filter and Savitzky-Golay parameters
%   Isotope removal
%   Adduct removal
%   Polarity specific Common Contaminant removal
%% Initial Setup User Input
%GUI one or two-way data
answer = questdlg('Pairwise or single analysis?','Setup','Pairwise','Single','Single');
        switch answer
        case 'Pairwise'
            disp('Select datasets')
            multi = 1;
        case 'Single'
            disp('Select dataset')
            multi = 0;
            nrowDif=0;
        end
        if exist('multi','var') ~= 1
            error('Task aborted by User')
        end
%Data Selection
Files = RoiDataselect(multi);
%Generating Parameter Dump
Parameters=struct();
Data = struct('DataFiles',Files(2,:));
Parameters.Data=Data;
Files(2,:)=[]; %Remove Pathless Files
%Gui Blank Substraction
answer = questdlg('Subtract Blank?','Setup','Yes','No','No');
        switch answer
            case 'Yes'
            disp('Select Blank')
            BLK = 1;
        case 'No'
            disp('No Blank Subtraction')
            BLK = 0;
        end
        if exist('BLK','var') ~= 1
            disp("Blank Selection aborted by User... skipping Blank subtraction")
            BLK = 0;
        end
if BLK == 1
    FilesBLK = RoiBLKselect(multi);
    %Parameter Dump
    [Data.BlankFiles]=FilesBLK{2,:};
    Parameters.Data=Data;
    FilesBLK(2,:)=[]; %Remove Pathless BLKFiles
    Files=[Files;FilesBLK];%Combine Data and BLK files
end
%ROI Parameter select
%2 Groups - Query different Scan numbers
if multi==1
    answer = questdlg('Datesets with Different Scan Numbers?','Setup','Yes','No','No');
        switch answer
        case 'Yes'
            nrowDif=1;
            disp('Define Scan range for Datasets') %ROI parameter GUI for different Scan numbers
        prompt = {'Intensity Threshold:','MZ Error [Da]:','Minimum ROI Size:','Starting Scan Number to Process Dataset 1:','Last Scan Number to Process Dataset 1:','Starting Scan Number to Process Dataset 2:','Last Scan Number to Process Dataset 2:'};
        dlgtitle = 'Select ROI parameters';
        dims = [1 60];
        definput = {'10000','0.05','20','1','1500','1','1500'};
        answer = inputdlg(prompt,dlgtitle,dims,definput);
        if isempty(answer) %Check abort condition
            error("Task aborted by User")
        end
        thresh = str2double(answer{1,1}); %Variable Generation from answer cell
        mzerror = str2double(answer{2,1});
        minroi = str2double(answer{3,1});
        nrowsStart1 = str2double(answer{4,1});
        nrowsEnd1 = str2double(answer{5,1});
        nrowsStart2 = str2double(answer{6,1});
        nrowsEnd2 = str2double(answer{7,1});
        %Parameter Dump
        Para=["Intensity Threshold";"MZ Error";"Minimum ROI Size";"Starting Scan Number Dataset 1";"Last Scan Number Dataset 1";"Starting Scan Number Dataset 2";"Last Scan Number Dataset 2"];
        Para=[Para answer];
        Parameters.ROIparameters=Para;
        if nrowsStart1 ~= 1
            nrowsStart1 = nrowsStart1+1;
        end
        if nrowsStart2 ~= 1
            nrowsStart2 = nrowsStart2+1;
        end
        case 'No' %ROI parameter GUI for same Scan numbers
            nrowDif=0;
            disp('Define Scan range for both Datasets')
        prompt = {'Intensity Threshold:','MZ Error [Da]:','Minimum ROI Size:','Starting Scan Number to Process:','Last Scan Number to Process:'};
        dlgtitle = 'Select ROI parameters';
        dims = [1 60];
        definput = {'10000','0.05','20','1','1500'};
        answer = inputdlg(prompt,dlgtitle,dims,definput);
        if isempty(answer)
            error("Task aborted by User")
        end
        thresh = str2double(answer{1,1}); %Variable Generation from answer cell
        mzerror = str2double(answer{2,1});
        minroi = str2double(answer{3,1});
        nrowsStart1 = str2double(answer{4,1});
        nrowsEnd1 = str2double(answer{5,1});
        %Parameter Dump
        Para=["Intensity Threshold";"MZ Error";"Minimum ROI Size";"Starting Scan Number";"Last Scan Number"];
        Para=[Para answer];
        Parameters.ROIparameters=Para;
        if nrowsStart1 ~= 1
            nrowsStart1 = nrowsStart1+1;
        end
        nrowsStart2 = nrowsStart1;
        nrowsEnd2 = nrowsEnd1;
        end
else %GUI for ROi parameters one Group
prompt = {'Intensity Threshold:','MZ Error [Da]:','Minimum ROI Size:','Starting Scan Number to Process:','Last Scan Number to Process:'};
        dlgtitle = 'Select ROI parameters';
        dims = [1 60];
        definput = {'10000','0.05','20','1','1500'};
        answer = inputdlg(prompt,dlgtitle,dims,definput);
        if isempty(answer) %check abort condition
            error("Task aborted by User")
        end
        thresh = str2double(answer{1,1}); %Variable Generation from answer cell
        mzerror = str2double(answer{2,1});
        minroi = str2double(answer{3,1});
        nrowsStart1 = str2double(answer{4,1});
        nrowsEnd1 = str2double(answer{5,1});
        %Parameter Dump
        Para=["Intensity Threshold";"MZ Error";"Minimum ROI Size";"Starting Scan Number";"Last Scan Number"];
        Para=[Para answer];
        Parameters.ROIparameters=Para;
        if nrowsStart1 ~= 1
            nrowsStart1 = nrowsStart1+1;
        end
        nrowsStart2 = nrowsStart1;
        nrowsEnd2 = nrowsEnd1;
end
%% Post processing User Input
%BaselineCorrection
answer = questdlg('Perform Baseline Correction?','Data Preprocessing','Yes','No','No');
        switch answer
            case 'Yes'
            disp('Select Baseline Correction Parameters')
            Bcor = 1;
        case 'No'
            disp('No Baseline Correction')
            Bcor = 0;
        end
        if exist('Bcor','var') ~= 1 %Check for Cancel
            disp("Baseline correction parameter selection aborted by User... skipping Baseline Correction")
            Bcor = 0;
        end
if Bcor == 1 %Baseline Correction parameter input GUI
    prompt = {'Shifting Window Size:','Step Size:','Regression Method:','Estimation Method:','Smoothing Method:','Quantile Value:'};
    dlgtitle = 'Select Baseline Correction Parameters';
    dims = [1 60];
    definput = {'200','200','pchip, linear or spline','quantile or em','none, lowess, loess, rlowess or rloess','0.1'};
    answer = inputdlg(prompt,dlgtitle,dims,definput);
    if isempty(answer) %Check for Cancel
        warning("Task aborted by User... skipping Baseline Correction")
        Bcor = 0;
        return
    end
    Reg = answer{3,1}; %Variable genration from answer cell
    Est = answer{4,1};
    Smoo = answer{5,1};
    SWS = str2double(answer{1,1});
    SS = str2double(answer{2,1});
    Quan = str2double(answer{6,1});
    %Parameter Dump
    Para=["Shifting Window Size";"Step Size";"Regression Method";"Estimation Method";"Smoothing Method";"Quantile Value"];
    Para=[Para answer];
    Parameters.BaselineParameters=Para;
end
%GolaySmoothing GUI
answer = questdlg('Apply Savitzky-Golay Filter?','Data post processing','Yes','No','No');
        switch answer
            case 'Yes'
            disp('Select Smoothing Parameters')
            golay = 1;
        case 'No'
            disp('No Signal Smoothing')
            golay = 0;
        end
        if exist('golay','var') ~= 1
            disp("Golay Parameter Selection aborted by User... skipping Golay Smoothing")
            golay = 0;
        end
if golay == 1 %Golay parameter input GUI
    prompt = {'Frame Size:','Polynomial degree:'};
    dlgtitle = 'Select Smoothing Parameters';
    dims = [1 60];
    definput = {'15','2'};
    answer = inputdlg(prompt,dlgtitle,dims,definput);
    if isempty(answer) %Check for cancel
        warning("Task aborted by User... skipping Golay Smoothing")
        golay = 0;
        return
    end
    span = str2double(answer{1,1}); %Variable Generation from answer cell
    degree = str2double(answer{2,1});
    Para=["Frame Size";"Polynomial degree"];
    %Parameter Dump
    Para=[Para answer];
    Parameters.GolayParameters=Para;
end
Para=["Isotopes Removed"; "Adducts removed"; "Contaminants Removed"; "Polarity"];
%Remove Isotopes GUI
answer = questdlg('Remove Isotopes?','Setup','Yes','No','No');
        switch answer
        case 'Yes'
            disp('Remove Isotopes')
            Iso = 1;
            Para(1,2)="Yes";
        case 'No'
            disp('No removal of Isotopes')
            Iso = 0;
            Para(1,2)="No";
        end
        if exist('Iso','var') ~= 1 %Check cancel
            disp("Isotope removal skipped by User")
            Iso = 0;
            Para(1,2)="No";
        end
%Adduct remover GUI
answer = questdlg('Remove Adducts?','Setup','Yes','No','No');
        switch answer
        case 'Yes'
            disp('Remove Adducts')
            add = 1;
            Para(2,2)="Yes";
        case 'No'
            disp('No removal of Adducts')
            add = 0;
            Para(2,2)="No";
        end
        if exist('add','var') ~= 1 %Check cancel
            disp("Adduct removal skipped by User")
            add = 0;
            Para(2,2)="No";
        end
%Contaminant Remover GUI
answer = questdlg('Remove common Contaminants?','Setup','Yes','No','No');
        switch answer
        case 'Yes'
            disp('Remove Contaminants')
            Cont = 1;
            Para(3,2)="Yes";
        case 'No'
            disp('No removal of Contaminants')
            Cont = 0;
            Para(3,2)="No";
        end
        if exist('Cont','var') ~= 1 %Check Cancel
            disp("Contaminant removal skipped by User")
            Cont = 0;
            Para(3,2)="No";
        end
if Cont == 1 %Contaminant polarity GUI
answer = questdlg('Choose MS Polarity','Setup','Positive','Negative','Positive');
        switch answer
        case 'Positive'
            polarity = "Positive";
            Para(4,2)="+";
        case 'Negative'
            polarity = "Negative";
            Para(4,2)="-";
        end
        if exist('polarity','var') ~= 1 %Check Cancel
            disp("Contaminant removal skipped by User")
            Cont = 0;
            Para(3,2)="No";
        end
end
Parameters.CleanUp=Para;
clearvars answer definput dims dlgtitle FilesBLK prompt Para BLKPathless FilesPathless Data %Clear unnecessary variables 
%% DataLoad and Cleanup
[Peaklist,Timelist] = RoiDataload(Files,nrowsStart1,nrowsEnd1,nrowsStart2,nrowsEnd2,nrowDif);

%% ROI search
disp('Performing ROI search...');
[MSroi_end,mzroi_end,time_end] = AutoROI(Peaklist,Timelist,mzerror,minroi,thresh);
delete(findall(groot,'Type','figure'));
%% Post processing
if BLK==1 %Blank Substraction
    disp('Performing Blank Subtraction...');
    if multi == 0 %Single Group
        nrows=nrowsEnd1-nrowsStart1+1;
        numData=numel(Files{1,1});
        numBLK=numel(Files{2,1});
        [MSroi_end] = BLKcorr(MSroi_end,numData,numBLK,nrows);
        [r,~]=size(MSroi_end);
        time_end=time_end(1:r);
    end
    if multi == 1 %2 Groups
        numDataA=numel(Files{1,1}); %Extract number of Matrices per Group
        numBLKA=numel(Files{2,1});
        numDataB=numel(Files{1,2});
        numBLKB=numel(Files{2,2});
        nrowsA=nrowsEnd1-nrowsStart1+1; %Gnerate number of Rows per group sample
        nrowsB=nrowsEnd2-nrowsStart2+1;
        %Split Data Matrix into Groups, perform correction
        MSroi_endA = MSroi_end(1:(numDataA+numBLKA)*nrowsA,:);
        MSroi_endB = MSroi_end((numDataA+numBLKA)*nrowsA+1:end,:);
        [MSroi_endA] = BLKcorr(MSroi_endA,numDataA,numBLKA,nrowsA);
        [MSroi_endB] = BLKcorr(MSroi_endB,numDataB,numBLKB,nrowsB);
        [r,~]=size(MSroi_endA); %remove Blank times from time_end
        TimeA=time_end(1:(numDataA+numBLKA)*nrowsA,:);
        TimeA=TimeA(1:r);
        [r,~]=size(MSroi_endB);
        TimeB=time_end((numDataA+numBLKA)*nrowsA+1:end,:);
        TimeB=TimeB(1:r);
        %Combine Corrected Matrices again 
        MSroi_end = [MSroi_endA;MSroi_endB];
        time_end=[TimeA;TimeB];
    end
    disp('DONE');
end
%%Generate external Variable with Number of Rows of every Sample Matrix
if nrowDif == 1 && multi == 1
    nrowsA=nrowsEnd1-nrowsStart1+1; %Gnerate number of Rows per group sample
    nrowsB=nrowsEnd2-nrowsStart2+1;
    nRowsA=zeros(size(Parameters.Data(1).DataFiles));
    nRowsB=zeros(size(Parameters.Data(2).DataFiles));
    nRowsA(:,1)=nrowsA;
    nRowsB(:,1)=nrowsB;
    nRows=[nRowsA' nRowsB'];
elseif nrowDif == 0 && multi == 1
    nrows=nrowsEnd1-nrowsStart1+1;
    nRowsA=zeros(size(Parameters.Data(1).DataFiles));
    nRowsB=zeros(size(Parameters.Data(2).DataFiles));
    nRowsA(:,1)=nrows;
    nRowsB(:,1)=nrows;
    nRows=[nRowsA' nRowsB'];
else
    nrows=nrowsEnd1-nrowsStart1+1;
    nRows=zeros(size(Parameters.Data(1).DataFiles));
    nRows(:,1)=nrows;
    nRows=nRows';
end
%Baseline Correction, force negative Intensities to 0
if Bcor == 1 
    disp('Performing Baseline Correction...');
    
    var=cumsum(nRows,2); %generate Split varaiables
    t=[1 var(1:end-1)+1];
    var=[t' var'];
    MSroisplit=cell(1,length(nRows));%Preallocate Cells
    timesplit=cell(1,length(nRows));
    [NumData,~]=size(var);
    for k=1:NumData %Loop to split MSroi_end / time_end into chunks
        MSroisplit{1,k}=MSroi_end(var(k,1):var(k,2),:);
        timesplit{1,k}=time_end(var(k,1):var(k,2),:);
    end
    parfor k=1:length(nRows) %parallel loop for baseline correction every sample individual
        MSroitemp=MSroisplit{1,k};
        timetemp=timesplit{1,k};
        MSroiout{k,1} = msbackadj(timetemp,MSroitemp,'WindowSize',SWS,'StepSize',SS,'RegressionMethod',Reg,'EstimationMethod',Est,'SmoothMethod',Smoo,'QuantileValue',Quan,'PreserveHeights',true);
    end
    MSroi_end=cell2mat(MSroiout);
    MSroi_end(isnan(MSroi_end))=0; %Remove possible NaN values
    MSroi_end=max(MSroi_end,0); %Force negative Intensities to 0
    disp('DONE');
end
if golay == 1 %Golay Smooting
    disp('Performing Golay Smoothing...');
    var=cumsum(nRows,2); %generate Split varaiables
    t=[1 var(1:end-1)+1];
    var=[t' var'];
    MSroisplit=cell(1,length(nRows));%Preallocate Cells
    timesplit=cell(1,length(nRows));
    [NumData,~]=size(var);
    for k=1:NumData %Loop to split MSroi_end / time_end into chunks
        MSroisplit{1,k}=MSroi_end(var(k,1):var(k,2),:);
        timesplit{1,k}=time_end(var(k,1):var(k,2),:);
    end
    parfor k=1:length(nRows) %parallel loop for baseline correction every sample individual
        MSroitemp=MSroisplit{1,k};
        timetemp=timesplit{1,k};
        MSroiout{k,1} = mssgolay(timetemp,MSroitemp,'Span',span,'Degree',degree);
    end
    MSroi_end=cell2mat(MSroiout);
    disp('DONE');
end
MSroi_end(isnan(MSroi_end))=0; %Remove possible NaN values
MSroi_end=max(MSroi_end,0); %Force negative Intensities to 0
if Iso == 1
    disp('Removing Isotopes...');
    Isotopes=readtable('UWPR_CommonMassSpecContaminants.xls','Sheet',"Isotopes");
    [MSroi_end,Found]=ApplyFilter(MSroi_end,mzroi_end,Parameters,Isotopes);
    Parameters.PossibleIsotopes=mzroi_end(Found);%store possible Isotope masses in Parameters
    disp('DONE');
end
if add == 1
    disp('Removing Adducts...');
    AdductList=readtable('UWPR_CommonMassSpecContaminants.xls','Sheet',"Adducts");
    [MSroi_end,Found]=ApplyFilter(MSroi_end,mzroi_end,Parameters,AdductList);
    Parameters.PossibleAdducts=mzroi_end(Found);%store possible Adduct masses in Parameters
    disp('DONE');
end
if Cont == 1
    disp('Removing common Contaminants...');
    [MSroi_end,mzroi_end,Parameters]=filterContaminants(MSroi_end,mzroi_end,Parameters,polarity);
    disp('DONE');
end
%replace zeroes with random noise

noise=rand(size(MSroi_end))*0.1*thresh;
MSroi_end(MSroi_end==0) = noise(MSroi_end==0);
%remove masses that contain only Intensities < thresh
idx = any(MSroi_end > thresh,1);
MSroi_end(:,~idx) = [];
mzroi_end(~idx) = [];
%%Display Final ROI
figure('Name','Final ROIs','NumberTitle','off');
    plot(MSroi_end);
    ylabel('Intensity');
end
