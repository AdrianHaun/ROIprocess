function [MSroi_end,mzroi_end,Parameters]=filterIsotopes(MSroi_end,mzroi_end,Parameters)
%% Removes found adducts/ in source fragments/ group exchange (e.g. deamidation) from mass list
%%Preparations
mzerror=Parameters.ROIparameters(2,2);
mzerror=str2double(mzerror);
Isotopes=readtable('UWPR_CommonMassSpecContaminants.xls','Sheet',"Isotopes");
numComp=length(mzroi_end);
idxfinal=false(numComp,length(mzroi_end));
%find Adducts and set to 0
for k=1:numComp
    Addplus=Isotopes.MassDifference+mzroi_end(1,k);
    idx=Addplus<mzroi_end+mzerror/2 & Addplus>mzroi_end-mzerror/2;
    idxfinal(k,:)=any(idx,1);
end
idxfinal=any(idxfinal,1);
Parameters.RemovedIsotopes=mzroi_end(idxfinal); %Store removed Masses in Parameters
%remove masses with 0 from mzroi_end and MSroi_end
mzroi_end(idxfinal)=0;
idx=mzroi_end==0;
mzroi_end(idx)=[];
MSroi_end(:,idx)=[];
end
