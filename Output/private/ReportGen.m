function ReportTable = ReportGen(copt,sopt,mzroi_end,Time,numData,numComp,G,thresh)
%Generates MCR-ALS results Table
%   Designed to be used in conjunction with MCRout
%% Table Setup and preallocation

varTypes = {'string','string','double','double','double','double','cell','cell','double','double','cell'};
varNames ={'Component','Group','rt','mz','AvgPeakArea','AvgPeakHeight','ConcProfiles','PureSpectrum','SampleArea','STDArea','Masslist'};
sz = [numComp length(varNames)];
ReportTable = table('Size',sz,'VariableTypes',varTypes,'VariableNames',varNames);
AvgHeight=zeros(numComp,1);
SampArea=cell(numComp,1);
SampHeights=cell(numComp,1);
AvgRT=zeros(numComp,1);
RTRange=zeros(numComp,1);
STD=zeros(numComp,1);
CString="Component ";
name=strings(numComp,1);
G=num2str(G);
Group(1:numComp,1)= G;
profiles=cell(numComp,1);
AvgProfiles=cell(numComp,1);
spectra=cell(numComp,1);
Masslist=cell(numComp,1);
%% Data Extraction
ReportTable.Group=Group;
ReportTable.AvgPeakArea=(sum(copt)/numData)';
[~,idx]=max(sopt,[],2);
ReportTable.mz=mzroi_end(idx)';
    for k = 1:numComp
        numString=num2str(k); %Component Number
        name(k,1)=CString+numString;
        CSamp=copt(:,k);
        CSamp=reshape(CSamp,[],numData); %ConcProfile for each sample
        profiles{k,1}=CSamp;
        AvgProfiles{k,1}=mean(profiles{k},2);
        Areas=sum(CSamp);%Area for each sample
        SampArea{k,:}=Areas;
        STD(k,1)=std(Areas);%Area STD
        [Height,idx]=max(CSamp);% Height
        SampHeights{k,:}=Height;
        AvgHeight(k,1)=mean(Height,2);
        rt=Time(idx);%RetentionTime
        AvgRT(k,1)=mean(rt,2);
        RTRange(k,1)=range(rt,2);
        SSamp=sopt(k,:);%Pure Spectra
        spectra{k,1}=SSamp';
        SSamp=normalize(SSamp,'norm',Inf);
        idx=SSamp > thresh;
        Masslist{k,1}=mzroi_end(idx)';
    end
    %% Data Compile
    ReportTable.Component=name;
    ReportTable.AvgPeakHeight=AvgHeight;
    ReportTable.rt=AvgRT;
    ReportTable.RTRange=RTRange;
    ReportTable.ConcProfiles=profiles;
    ReportTable.AvgConcProfiles=AvgProfiles;
    ReportTable.PureSpectrum=spectra;
    ReportTable.SampleArea=SampArea;
    ReportTable.SampleHeights=SampHeights;
    ReportTable.STDArea=STD;
    ReportTable.Masslist=Masslist;
end

