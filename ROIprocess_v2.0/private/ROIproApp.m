function [MSroi_end,mzroi_end,time_end,nRows,Parameters] = ROIproApp(app)
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

%Data Selection
Files = RoiDataselect(app.MULTI);
%Generating Parameter Dump
Parameters=struct();
Data = struct('DataFiles',Files(2,:));
Parameters.Data=Data;
Files(2,:)=[]; %Remove Pathless Files

if app.BLK == true
    FilesBLK = RoiBLKselect(app.MULTI);
    %Parameter Dump
    [Data.BlankFiles]=FilesBLK{2,:};
    Parameters.Data=Data;
    FilesBLK(2,:)=[]; %Remove Pathless BLKFiles
    Files=[Files;FilesBLK];%Combine Data and BLK files
end
fig = uifigure;
    d = uiprogressdlg(fig,'Title','Processing Data','Message','Please Wait','Indeterminate','on');
    drawnow
clearvars answer definput dims dlgtitle FilesBLK prompt Para BLKPathless FilesPathless Data %Clear unnecessary variables 
%%  Dump Options into Parameters Struct
if app.first1 == app.first2 && app.last1 == app.last2
    nrowDif = true;
else
    nrowDif = false;
end

% ROI parameters
Para = ["Intensity Threshold";"MZ Error";"Minimum ROI Size";"Starting Scan Number Dataset 1";"Last Scan Number Dataset 1"];
Opt = [app.thresh;app.mzerror;app.minroi;app.first1;app.last1];
if nrowDif == true
    Para = [Para;"Starting Scan Number Dataset 2";"Last Scan Number Dataset 2"];
    Opt = [Opt;app.first2;app.last2];
end
Opt = arrayfun(@num2str,Opt,'un',0);
Para = [Para Opt];
Parameters.ROIparameters = Para;
% Baseline Parameters
if app.BASE == true
    Para=["Shifting Window Size";"Step Size";"Regression Method";"Estimation Method";"Smoothing Method";"Quantile Value"];

    Opt = [string(app.SWS);string(app.SS);app.Reg;app.Est;app.Smoo;string(app.Quan)];
    Para = [Para Opt];
    Parameters.BaselineParameters=Para;
end
% Smoothing Parameters
if app.GOLAY == true
    Para=["Frame Size";"Polynomial degree"];
    Opt = [app.Span;app.Poly];
    Opt = arrayfun(@num2str,Opt,'un',0);
    Para = [Para Opt];
    Parameters.GolayParameters=Para;
end
%Applied Filters
Para=["Isotopes Removed"; "Adducts removed"; "Contaminants Removed"; "Polarity"];
if app.ISO == true
    Para(1,2) = "Yes";
else
    Para(1,2) = "No";
end
if app.ADD == true
    Para(2,2) = "Yes";
else
    Para(2,2) = "No";
end
if app.CONT == true
    Para(3,2) = "Yes";
    Para(4,2) = app.polarity;
else
    Para(3,2) = "No";
    Para(4,2) = app.polarity;
end
Parameters.CleanUp=Para;
%% Load Data
        if app.first1 ~= 1
            app.first1 = app.first1+1;
        end
        if app.first2 ~= 1
            app.first2 = app.first2+1;
        end
[Peaklist,Timelist] = RoiDataload(Files,app.first1,app.last1,app.first2,app.last2,nrowDif);

%% ROI search
[MSroi_end,mzroi_end,time_end] = AutoROI(Peaklist,Timelist,app.mzerror,app.minroi,app.thresh);
%% Post processing
if app.BLK == true %Blank Substraction
    if app.MULTI == false %Single Group
        nrows=app.last1-app.first1+1;
        numData=numel(Files{1,1});
        numBLK=numel(Files{2,1});
        [MSroi_end] = BLKcorr(MSroi_end,numData,numBLK,nrows);
        [r,~]=size(MSroi_end);
        time_end=time_end(1:r);
    end
    if app.MULTI == true %2 Groups
        numDataA=numel(Files{1,1}); %Extract number of Matrices per Group
        numBLKA=numel(Files{2,1});
        numDataB=numel(Files{1,2});
        numBLKB=numel(Files{2,2});
        nrowsA=app.last1-app.first1+1; %Gnerate number of Rows per group sample
        nrowsB=app.last2-app.first2+1;
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
end
%%Generate external Variable with Number of Rows of every Sample Matrix
if nrowDif == true && app.MULTI == true
    nrowsA=app.last1-app.first1+1; %Gnerate number of Rows per group sample
    nrowsB=app.last2-app.first2+1;
    nRowsA=zeros(size(Parameters.Data(1).DataFiles));
    nRowsB=zeros(size(Parameters.Data(2).DataFiles));
    nRowsA(:,1)=nrowsA;
    nRowsB(:,1)=nrowsB;
    nRows=[nRowsA' nRowsB'];
elseif nrowDif == false && app.MULTI == true
    nrows=app.last1-app.first1+1;
    nRowsA=zeros(size(Parameters.Data(1).DataFiles));
    nRowsB=zeros(size(Parameters.Data(2).DataFiles));
    nRowsA(:,1)=nrows;
    nRowsB(:,1)=nrows;
    nRows=[nRowsA' nRowsB'];
else
    nrows=app.last1-app.first1+1;
    nRows=zeros(size(Parameters.Data(1).DataFiles));
    nRows(:,1)=nrows;
    nRows=nRows';
end
%Baseline Correction, force negative Intensities to 0
if app.BASE == true 
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
    SWS = app.SWS;
    SS = app.SS;
    Reg = app.Reg;
    Est = app.Est;
    Smoo = app.Smoo;
    Quan = app.Quan;
    parfor k=1:length(nRows) %parallel loop for baseline correction every sample individual
        MSroitemp=MSroisplit{1,k};
        timetemp=timesplit{1,k};
        MSroiout{k,1} = msbackadj(timetemp,MSroitemp,'WindowSize',SWS,'StepSize',SS,'RegressionMethod',Reg,'EstimationMethod',Est,'SmoothMethod',Smoo,'QuantileValue',Quan,'PreserveHeights',true);
    end
    MSroi_end=cell2mat(MSroiout);
    MSroi_end(isnan(MSroi_end))=0; %Remove possible NaN values
    MSroi_end=max(MSroi_end,0); %Force negative Intensities to 0
end
if app.GOLAY == true %Golay Smooting
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
    Span = app.Span;
    Poly = app.Poly;
    parfor k=1:length(nRows) %parallel loop for baseline correction every sample individual
        MSroitemp=MSroisplit{1,k};
        timetemp=timesplit{1,k};
        MSroiout{k,1} = mssgolay(timetemp,MSroitemp,'Span',Span,'Degree',Poly);
    end
    MSroi_end=cell2mat(MSroiout);
end
MSroi_end(isnan(MSroi_end))=0; %Remove possible NaN values
MSroi_end=max(MSroi_end,0); %Force negative Intensities to 0
if app.ISO == true
    Isotopes=readtable('UWPR_CommonMassSpecContaminants.xls','Sheet',"Isotopes");
    [MSroi_end,Found]=ApplyFilterApp(MSroi_end,mzroi_end,app.mzerror,app.thresh,Isotopes);
    Parameters.PossibleIsotopes=mzroi_end(Found);%store possible Isotope masses in Parameters
end
if app.ADD == true
    AdductList=readtable('UWPR_CommonMassSpecContaminants.xls','Sheet',"Adducts");
    [MSroi_end,Found]=ApplyFilterApp(MSroi_end,mzroi_end,app.mzerror,app.thresh,AdductList);
    Parameters.PossibleAdducts=mzroi_end(Found);%store possible Adduct masses in Parameters
end
if app.CONT == true
    [MSroi_end,mzroi_end,Parameters]=filterContaminants(MSroi_end,mzroi_end,Parameters,app.polarity);
end
%replace zeroes with random noise

noise=rand(size(MSroi_end))*0.1*app.thresh;
MSroi_end(MSroi_end==0) = noise(MSroi_end==0);
%remove masses that contain only Intensities < thresh
idx = any(MSroi_end > app.thresh,1);
MSroi_end(:,~idx) = [];
mzroi_end(~idx) = [];
%%Display Final ROI
fig = figure('Name','Final ROIs','NumberTitle','off');
    plot(MSroi_end);
    ylabel('Intensity');
end
