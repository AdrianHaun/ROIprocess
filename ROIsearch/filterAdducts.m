function [MSroi_end,mzroi_end,Parameters]=filterAdducts(MSroi_end,mzroi_end,Parameters)
%% Removes found adducts/ in source fragments/ group exchange (e.g. deamidation) from mass list
%%Preparations
mzerror=Parameters.ROIparameters(2,2);
mzerror=str2double(mzerror);
thresh=Parameters.ROIparameters(1,2);
thresh=str2double(thresh);
AdductList=readtable('UWPR_CommonMassSpecContaminants.xls','Sheet',"Adducts");
numComp=length(mzroi_end);
idxfinal=false(numComp,length(mzroi_end));
[numrows,numMz]=size(MSroi_end);
idxall=false(numrows,numMz);
Addplus=AdductList.MassDifference+mzroi_end;
Addplus=reshape(Addplus,[],1);
Addplus=sort(Addplus,'ascend');
idx=mzroi_end>=Addplus-mzerror/2 & mzroi_end<=Addplus+mzerror/2;

for j=1:numrows %perform adduct search for every scan
    scan=MSroi_end(j,:);
    for k=1:numComp %get Adduct masses for every mzroi
        Addplus=AdductList.MassDifference+mzroi_end(1,k);
        idx=Addplus<mzroi_end+mzerror/2 & Addplus>mzroi_end-mzerror/2;
        idxfinal(k,:)=any(idx,1);
    end
    idxfinal=any(idxfinal,1);
    idxall(j,:)=idxfinal;
    idxfinal=idxfinal==1 & scan >=thresh;
    scan(idxfinal)=0;
    MSroi_end(j,:)=scan;
end
idxall=any(idxall,1);
Parameters.RemovedAdducts=mzroi_end(idxall); %Store removed Masses in Parameters
end
