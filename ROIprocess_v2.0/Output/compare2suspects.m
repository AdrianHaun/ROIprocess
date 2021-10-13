function ReportTable = compare2suspects(ReportTable,Parameters)
%compare2suspects Checks if Masslist contains masses of Suspect targets
%   Use external .xlsx File with Suspect Target Mass list. MassList must be
%   in a Sheet called 'Suspect Export'. Else Change readtable function on
%   line 31. Output will be Stored in ReportTable corresponding to every Component. 
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
%Select Suspect List GUI
[File,path] = uigetfile({'*.xlsx';'*.csv';'*.txt';'*dat';'*.xls';'*.xlsb';'*.xlsm';'*.xltm';'*.xltx';'*.ods'},'Suspect Masslist','MultiSelect','off');
File=fullfile(path,File);
SuspectList=readtable(File,'Sheet',"Suspect Export"); %Change "Suspect Export" if .xlsx sheet has different name
SuspectList=rmmissing(SuspectList); %Remove Empty Rows
%Preparation
Suspects=cell(height(ReportTable),1);
ConfimedComponentMass=cell(height(ReportTable),1);
SuspectMassTable=SuspectList(:,2:end);
TableHeaders=SuspectMassTable.Properties.VariableNames;
SuspectNames=SuspectList(:,1);
SusMasses=table2array(SuspectMassTable);
if iscell(SusMasses)==1 %when SuspectList contains empty rows SusMasses is char array
    SusMasses=str2double(SusMasses); %convert char array to double array
end
[~,width]=size(SusMasses);
% Comparison Loop
for k=1:height(ReportTable) %Loop Components
    foundSusIdx=false(length(SusMasses),width);
    corMassIdx=false(length(ReportTable.Masslist{k}),length(SusMasses));
    CompMasses=ReportTable.Masslist{k};
    for j=1:length(SusMasses) %Loop Rows of Suspect List
        idx=CompMasses <=SusMasses(j,:) + mzerror/2 & CompMasses >=SusMasses(j,:) - mzerror/2;
        foundSusIdx(j,:)=any(idx,1);
        corMassIdx(:,j)=any(idx,2);
    end
    %Extract confirmed Suspect Masses and Store in Table
    NameIdx=any(foundSusIdx,2);
    Masses=SusMasses;
    Masses(~foundSusIdx)=0;
    Masses=array2table(Masses,'VariableNames',TableHeaders);
    Masses=[SuspectNames Masses];
    Masses(~NameIdx,:)=[];
    %Extract corresponding Component Masses
    corMassIdx=any(corMassIdx,2);
    CompMasses(~corMassIdx)=[];
    ConfimedComponentMass{k,1}=CompMasses;
    %Store final Table Cell
    Suspects{k,1}=Masses;
end
%Add Confirmed Masses to ReportTable
ReportTable.ConfirmedSuspects=Suspects;
ReportTable.ConfimedComponentMass=ConfimedComponentMass;
end

