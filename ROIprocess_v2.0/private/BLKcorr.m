function [MSroi_end] = BLKcorr(MSroi_end,numData,numBLK,nrows)
%BLKcorr Performs blank substraction for augmented ROI matrices.
%   Designed to be used in conjunction with ROIprocess. Generates average
%   Blank data when MSroi_end contains multiple Blank files. MSroi_end must
%   have data for Blanks below the Sample data.
MSroiBLK=MSroi_end((end-nrows)+1:end,:);%Extract Last Blank Matrix from Datamatrix
    if numBLK>1 %calc average BLK Matrix
        for u=2:numBLK
            MSroiBLKtemp=MSroi_end(end-(u*nrows)+1:end-(u-1)*nrows,:);
            MSroiBLK=MSroiBLK+MSroiBLKtemp;
        end
    end
    MSroiBLK=MSroiBLK./numBLK;
    %Extract Data Matrix and Substract Average Blank
    for k=1:numData
        MSroitemp=MSroi_end(k*nrows-nrows+1:k*nrows,:);
        MSroi_end(k*nrows-nrows+1:k*nrows,:)=MSroitemp-MSroiBLK; 
    end
    %Remove Blank data from Data Matrix, force negative Intensity to zero
    MSroi_end((end-(numBLK*nrows)+1):end,:)=[];
    MSroi_end=max(MSroi_end,0);
end