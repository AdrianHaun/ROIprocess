function [EICs,ReportTable]=CheckConcProfiles(ReportTable,Parameters)
%% Checks Correlation between each Average Concentration Profile and main mz EIC for all Components
% User selects mzXML file via GUI, and Correlation between EIC of main
% component mass and Pure Concentration Profile of every component is
% calculated and both graphs are plotted. Correlation Coefficients are
% stored in ReportTable.Correlation
%% User Input
if ReportTable.Group(end) == '2'
    [FileA,pathA] = uigetfile('*.mzXML','Select Comparison Sample for Group 1','MultiSelect','off');
    FileA=fullfile(pathA,FileA);
    [FileB,pathB] = uigetfile('*.mzXML','Select Comparison Sample for Group 2','MultiSelect','off');
    FileB=fullfile(pathB,FileB);
else
    [FileA,pathA] = uigetfile('*.mzXML','Select Comparison Sample','MultiSelect','off');
    FileA=fullfile(pathA,FileA);
end
%% Preparation
yLabels=ReportTable.Component;
    if ReportTable.Group(end) == '2'
        [numComp,~]=size(ReportTable);
        numComp=numComp/2;
        nrowsStartA=str2double(Parameters.ROIparameters{4,2});
        nrowsEndA=str2double(Parameters.ROIparameters{5,2});
        if length(Parameters.ROIparameters) == 5
            nrowsStartB=nrowsStartA;
            nrowsEndB=nrowsEndA;
        else
            nrowsStartB=str2double(Parameters.ROIparameters{6,2});
            nrowsEndB=str2double(Parameters.ROIparameters{7,2});
        end
        if nrowsStartA ~= 1
            nrowsStartA = nrowsStartA+1;
        end
        if nrowsStartB ~= 1
            nrowsStartB = nrowsStartB+1;
        end
    else
        [numComp,~]=size(ReportTable);
        nrowsStartA=str2double(Parameters.ROIparameters{4,2});
        if nrowsStartA ~= 1
            nrowsStartA = nrowsStartA+1;
        end
        nrowsEndA=str2double(Parameters.ROIparameters{5,2});
    end
Corr=NaN*ones(numComp,1);
Query=strings(numComp,1);
NO="Noise Component";
Maybe="Uncertain, Check Profile vs EIC Plot";
Yes="Pure Component";
%%SampleLoad
if ReportTable.Group(end) == '2'
    disp(['Now reading ', FileA]);
    mzxml = mzxmlload(FileA,'Levels',1);
    [CompPeakA,CompTimeA]= mzxml2peaks(mzxml);
    disp(['Now reading ', FileB]);
    mzxml = mzxmlload(FileB,'Levels',1);
    [CompPeakB,CompTimeB]= mzxml2peaks(mzxml);
else
    disp(['Now reading ', FileA]);
    mzxml = mzxmlload(FileA,'Levels',1);
    [CompPeakA,CompTimeA]= mzxml2peaks(mzxml);
end
%% Extract EICs
if ReportTable.Group(end) == '2'
    CompPeakA=CompPeakA(nrowsStartA:nrowsEndA);
    CompPeakB=CompPeakB(nrowsStartB:nrowsEndB);
    EICsA=extractEIC(CompPeakA,numComp,Parameters,ReportTable);
    EICsB=extractEIC(CompPeakB,numComp,Parameters,ReportTable);
    EICs{1,1}=EICsA;
    EICs{1,2}=EICsB;
else
    CompPeakA=CompPeakA(nrowsStartA:nrowsEndA);
    EICsA=extractEIC(CompPeakA,numComp,Parameters,ReportTable);
    EICs{1,1}=EICsA;
end
figure('Name','Concentration Profiles vs Main EIC','NumberTitle','off');
Concs = tiledlayout('flow','TileSpacing','Compact');
if ReportTable.Group(end) == '2' %Plot for 2 Groups
    for h=1:numComp
            yA=ReportTable.AvgConcProfiles{h};
            yB=ReportTable.AvgConcProfiles{h+numComp};
            EICtempA=EICsA(:,h);
            EICtempB=EICsB(:,h);
            Corr(h,1)=corr(yA,EICtempA);
            Corr(h+numComp,1)=corr(yB,EICtempB);
            nexttile
            hold on
            plot(CompTimeA(nrowsStartA:nrowsEndA,1),yA)
            plot(CompTimeB(nrowsStartB:nrowsEndB,1),yB)
            plot(CompTimeA(nrowsStartA:nrowsEndA,1),EICtempA)
            plot(CompTimeB(nrowsStartB:nrowsEndB,1),EICtempB)
            hold off
            title(yLabels(h,1))
    end
    legend("Concentration Profile Group 1","Concentration Profile Group 2","EIC Group 1","EIC Group 2")
else %Plot for one Group
    for h=1:numComp
        y=ReportTable.AvgConcProfiles{h};
        EICtemp=EICsA(:,h);
        Corr(h,1)=corr(y,EICtemp);
        nexttile
        hold on
        plot(CompTimeA(nrowsStartA:nrowsEndA,1),y)
        plot(CompTimeA(nrowsStartA:nrowsEndA,1),EICtemp)
        hold off
        title(yLabels(h,1))
    end
    legend("Concentration Profiles","EIC")
end
%Plot Labels
    title(Concs,'Pure Concentration Profiles vs EIC')
    xlabel(Concs,'Elution time')
    ylabel(Concs,'Intensity')
%% Generate Correlation and add to ReportTable
    ReportTable.Correlation=Corr;
    idxNO= Corr<=0.3;
    idxMaybe=Corr>0.3 & Corr<=0.7;
    idxYes=Corr>0.7;
    Query(idxNO)=NO;
    Query(idxMaybe)=Maybe;
    Query(idxYes)=Yes;
    ReportTable.ProfileEvaluation=Query;
end
