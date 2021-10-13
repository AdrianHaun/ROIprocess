function ReportTable=evalDatabaseQuery(ReportTable)
%%Import Database Mass Search, and evaluate results
%DataSelect
[File,path] = uigetfile({'*.csv';'*.txt';'*dat';'*.xls';'*.xlsb';'*.xlsm';'*.xlsx';'*.xltm';'*.xltx';'*.ods'},'Select DataBase Query (delimited text file or spreadsheet)','MultiSelect','off');
File=fullfile(path,File);
DataBankSearch=readtable(File,'Delimiter', ',');
%Preparations
[numComp,~]=size(ReportTable);
FoundQuery=strings(numComp,1);
Yes="Match in Database";
No="No Match in Database";
DataBankResult=cell(numComp,1);
mz=round(ReportTable.mz,8);
queryMass=round(DataBankSearch.query_mass,8);
%Search
    for k=1:numComp
        idx = queryMass == mz(k,1);
        check=all(idx == 0);
        if check == 0
            FoundQuery(k)=Yes;
            DataBankResult{k,1}=DataBankSearch(idx,:);
        else
            FoundQuery(k)=No;
        end
    end
    ReportTable.DatabaseQuery=FoundQuery;
    ReportTable.DataBankResult=DataBankResult;
end