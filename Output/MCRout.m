function ReportTable = MCRout(copt,sopt,mzroi_end,time_end,nRows,Parameters)
%UNTITLED5 Summary of this function goes here
%   Detailed explanation goes here
prompt = {'Minimum relative Intensity for Masslist [%]'};
    dlgtitle = 'Define Report Parameters';
    dims = [1 60];
    definput = {'10'};
    answer = inputdlg(prompt,dlgtitle,dims,definput);
    thresh = str2double(answer{1,1});
    thresh = thresh/100;
[~,multi]=size(Parameters.Data);
if multi == 2
    numDataA=length(Parameters.Data(1).DataFiles);
    numDataB=length(Parameters.Data(2).DataFiles);
    
else
    numData=length(Parameters.Data(1).DataFiles);
end
[~,numComp] = size(copt);
    if multi == 2
        TimeA=time_end(1:nRows(1,1)*numDataA);
        TimeB=time_end(nRows(1,1)*numDataA+1:end);
        TimeA=reshape(TimeA,[],numDataA);
        TimeB=reshape(TimeB,[],numDataB);
        coptA=copt(1:nRows(1)*numDataA,:);
        coptB=copt(nRows(1)*numDataA+1:end,:);
        ReportTableA = ReportGen(coptA,sopt,mzroi_end,TimeA,numDataA,numComp,1,thresh);
        ReportTableB = ReportGen(coptB,sopt,mzroi_end,TimeB,numDataB,numComp,2,thresh);
        ReportTable = PairwiseReport(ReportTableA,ReportTableB);
    else
        Time=reshape(time_end,[],numData);
        ReportTable = ReportGen(copt,sopt,mzroi_end,Time,numData,numComp,1,thresh);
    end
MCRplots(ReportTable,mzroi_end,time_end)
end

