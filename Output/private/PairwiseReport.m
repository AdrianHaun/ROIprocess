function ReportTable = PairwiseReport(ReportTableA,ReportTableB)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here
%% Data extraction
AreasA=cell2mat(ReportTableA.SampleArea);
AreasB=cell2mat(ReportTableB.SampleArea);
%% Fold Change
ReportTableA.FoldChange=(mean(AreasA,2)./mean(AreasB,2))-1;
ReportTableB.FoldChange=(mean(AreasB,2)./mean(AreasA,2))-1;
%% p-Value Calculation
%two sample ttest
[hA,pA]=ttest2(AreasA,AreasB,'Dim',2);
[hB,pB]=ttest2(AreasB,AreasA,'Dim',2);
hA=logical(hA);
hB=logical(hB);
X = ["no","yes"];
hA = X(1+hA);
hB = X(1+hB);
ReportTableA.pValue=pA;
ReportTableB.pValue=pB;
ReportTableA.SignificantDifference=hA';
ReportTableB.SignificantDifference=hB';
ReportTable=[ReportTableA; ReportTableB];
end