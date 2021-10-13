function [Peaklist]=DataCleanUp(Peaklist)
%Remove m/z with Intensity < 1% max Intensity
%   Designed to be used in conjunction with ROIprocess. Removes all m/z
%   values with intensity below thresh.

%% Reshape to Row Vector
sz=size(Peaklist);
Peaklist=reshape(Peaklist,1,[]);
%% Clean Data
parfor k = 1 : length(Peaklist)
    Peak=Peaklist{1,k};
    [nrows,~] = size(Peak);
    for j = 1:nrows
        data=Peak{j,1};
        idx=data(:,2)< max(data(:,2))*0.01;
        data(idx,:)=[];
        Peak{j,1}=data;
    end
    Peaklist{1,k}=Peak;
end
%Reshape to original size
Peaklist=reshape(Peaklist,sz);
end