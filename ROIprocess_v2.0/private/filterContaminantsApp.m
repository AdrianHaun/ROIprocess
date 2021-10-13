function [MSroi_end,mzroi_end]=filterContaminantsApp(MSroi_end,mzroi_end,mzerror,polarity)
%% Removes found adducts/ in source fragments/ group exchange (e.g. deamidation) from mass list
%%Preparations
List=readtable('UWPR_CommonMassSpecContaminants.xls','Sheet',polarity);
%find Adducts and set to 0
    Contaminants=List.MonoisotopicIonMass_singlyCharged_;
    idx=Contaminants<mzroi_end+mzerror/2 & Contaminants>mzroi_end-mzerror/2;
    idx=any(idx,1);
%remove contamnant masses from mzroi_end and MSroi_end
mzroi_end(idx)=[];
MSroi_end(:,idx)=[];
end
