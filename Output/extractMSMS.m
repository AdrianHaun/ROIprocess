function ReportTable = extractMSMS(ReportTable,Parameters)
%Finds MSMS spectra from mass list
%   Detailed explanation goes here
%% Define Acceptable Mass Error
answer = questdlg('Set acceptable Mass difference [Da]','Setup','from ROI parameters','Manual','Manual');
        switch answer
        case 'from ROI parameters' %Uses mzerror from Parameters Struct
            mzerror=Parameters.ROIparameters{2,2};
            disp("Mass Error of "+mzerror + " Da from ROI Parameters is used")
            mzerror=str2double(mzerror);
        case 'Manual' %Manual specify mzerror via GUI
            disp('Specify Mass Error')
            prompt = {'MZ Error [Da]:'};
            dlgtitle = 'Set acceptable Mass difference [Da]';
            dims = [1 60];
            definput = {'0.05'};
            answer = inputdlg(prompt,dlgtitle,dims,definput);
            if isempty(answer) %Check abort condition
                error("Task aborted by User")
            end
            mzerror = str2double(answer{1,1});
        end
        if exist('mzerror','var') ~= 1 %Check User Abort
            error('Task aborted by User')
        end
%% Data File Select
[Files,path] = uigetfile('*.mzXML','Select Samples','MultiSelect','on');
Files=fullfile(path,Files);
    if iscell(Files) == 0 %Convert Files to cell when only one sample selected
        Files = {Files};
    end
    if ischar(path) == 0 %Check Cancel input
        error("Task aborted by User")
    end
%% Data Load
parfor k = 1 : length(Files)
           File=Files{1,k};
           disp(['Now reading ', File]);
           mzxml = mzxmlload(File,'Levels',2); %Data extraction
           if isempty(mzxml.scan)==1
               warn=" does not contain MS2 spectra. Select different Data File";
               message = File + warn;
               message=convertStringsToChars(message);
               error(message)
           end
           DataStructs{k,1} = mzxml;
           [Peak, Time]= mzxml2peaks(mzxml,'Levels',2);
           ScanCell{k,1}=Peak;
           TimeCell{k,1}=Time;      
end
% Remove m/z with Intensity < 1% max Intensity
ScanCell=DataCleanUp(ScanCell);
%% ExtractPrecursor Mass
PrecursorMzCell=cell(length(Files),1);
    for k=1:length(Files)
        mzxml=DataStructs{k,1};
        DataPrecursorMz=zeros(length(mzxml.scan),1);
        for i =1:length(mzxml.scan)
            DataPrecursorMz(i,1)=mzxml.scan(i).precursorMz.value;
        end
        PrecursorMzCell{k,1}=DataPrecursorMz;
    end
%% Sort Data into Table
for k=1:length(ScanCell)
    File=convertCharsToStrings(Files{1,k});
    File(1:length(PrecursorMzCell{k,1}),1)=File;
    DataTable=table(PrecursorMzCell{k,1},TimeCell{k,1},ScanCell{k,1},File);
    DataTable.Properties.VariableNames = {'ScanPrecursor','RetentionTime','Spectra','File'};
    DataStructs{k,1}=DataTable;
end    
    clearvars -except DataStructs ReportTable Parameters mzerror
%% Preparation
[~,multi]=size(Parameters.Data);
numComp=height(ReportTable);
if multi == 2
    numComp=numComp/2;
end
masslist=ReportTable.Masslist(1:numComp);
%sort masses and remove duplicates
mz=cell2mat(masslist);
mz=unique(mz,'rows');
%Prepare Storege Table
sz=[length(mz) 2];
varTypes={'double','table'};
varNames={'PrecursorMass','MS2Data'};
FoundTable=table('Size',sz,'VariableTypes',varTypes,'VariableNames',varNames);
FoundTable.PrecursorMass=mz;
numData=length(DataStructs);
%% Extract MSMS
parfor k=1:length(mz)
        Precursor=mz(k,1);
        for j=1:numData
            Data=DataStructs{j};
            idx=Data.ScanPrecursor <= Precursor+mzerror/2 & Data.ScanPrecursor >= Precursor-mzerror/2;
            Spectra{k,j}=Data(idx,:);
        end
end
%% Rearrange Data/ Get RetentionTime Avg and Range
%Preallocate 
AvgRetentionTime=zeros(length(mz),1);
RetentionRange=zeros(length(mz),1);
merge=cell(length(mz),1);
FoundTable.MS2Data=Spectra;
for k=1:length(mz)
    merge{k,1}=cat(1,FoundTable.MS2Data{k,:});
    AvgRetentionTime(k,1)=mean(merge{k,1}.RetentionTime);
    if isempty(merge{k,1}.RetentionTime)==1
        continue
    else
    RetentionRange(k,1)=range(merge{k,1}.RetentionTime);
    end
end
FoundTable.MS2Data=merge;
%% Sort MS2Data to corresponding Component
MSMS=cell(numComp,1);
for k=1:numComp
    idx=FoundTable.PrecursorMass == masslist{k,1}';
    idx=any(idx,2);
    MSMS{k,1}=FoundTable(idx,:);
end
%Store output into ReportTable
if multi == 1
    ReportTable.MSMS=MSMS;
else
    MSMS=[MSMS;MSMS];
    ReportTable.MSMS=MSMS;
end
%% Filter MS2 Spectra Outside Component RT Range
    for k=1:numComp
        rtmin=ReportTable.rt(k)-ReportTable.RTRange(k);
        rtmax=ReportTable.rt(k)+ReportTable.RTRange(k);
        MSMStemp=ReportTable.MSMS{k};
        for j=1:height(MSMStemp)
            MS2Data=MSMStemp.MS2Data{j};
            if isempty(MS2Data)== 0
                idx= MS2Data.RetentionTime <= rtmax & MS2Data.RetentionTime >= rtmin;
                MS2Data(~idx,:)=[];
            else
                continue
            end
            MSMStemp.MS2Data{j}=MS2Data;
        end
        ReportTable.MSMS{k}=MSMStemp;
    end
end

