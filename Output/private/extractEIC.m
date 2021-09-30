function EICs=extractEIC(CompPeak,numComp,Parameters,ReportTable)
EICs=NaN * ones(length(CompPeak),numComp);
    for k=1:numComp
        mz=ReportTable.mz(k);
        range=str2double(Parameters.ROIparameters{2,2});
        for j=1:length(CompPeak)
            idx=CompPeak{j,1}(:,1)< mz+range & CompPeak{j,1}(:,1)> mz-range;
            Ints=CompPeak{j,1}(idx,2);
            check=isempty(Ints);
            if check==1
                Ints=0;
            end
            Ints=mean(Ints);
            EICs(j,k)=Ints;
        end
    end