function [MSroi_end,mzroi_end,Parameters]=filterContaminants(MSroi_end,mzroi_end,Parameters,polarity)
%% Removes found adducts/ in source fragments/ group exchange (e.g. deamidation) from mass list
%%Preparations
mzerror=Parameters.ROIparameters(2,2);
mzerror=str2double(mzerror);
List=readtable('UWPR_CommonMassSpecContaminants.xls','Sheet',polarity);
%find Adducts and set to 0
    Contaminants=List.MonoisotopicIonMass_singlyCharged_;
    idx=Contaminants<mzroi_end+mzerror/2 & Contaminants>mzroi_end-mzerror/2;
    idx=any(idx,1);
    Parameters.RemovedContaminants=mzroi_end(idx);%store found Contaminants in Parameters
%remove contamnant masses from mzroi_end and MSroi_end
mzroi_end(idx)=[];
MSroi_end(:,idx)=[];
end
