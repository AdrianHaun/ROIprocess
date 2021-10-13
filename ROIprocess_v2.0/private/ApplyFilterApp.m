function [MSroi_end,Found]=ApplyFilterApp(MSroi_end,mzroi_end,mzerror,thresh,Masslist)
%% Removes intensities of masses with mass deltas specified by Masslist (eg Adduct masses, Isotope masses)
%%Preparations
%Generate All possible Adduct masses
Cases=Masslist.MassDifference+mzroi_end;
Cases=rmmissing(Cases);
%Find which Adduct masses are in mzroi_end and get indices
[Found,Indices]=ismembertol(Cases,mzroi_end,mzerror,'DataScale',1,'OutputAllIndices',true);
%% Store possible delta Masses
Found=any(Found,1);
%Split take scan and look for met conditions, if true set to 0
[row,~]=size(MSroi_end);
for k=1:row
    Cell=MSroi_end(k,:);
    MSroi_end(k,:)=findCase(Cell,Indices,Found,thresh,mzroi_end);
end
%% Check if mass delta intensities are present and set them to 0
function scan=findCase(scan,id,Adds,thresh,list)
    for j=1:length(list)
        if scan(1,j)>= thresh %skip if base mz intensity is < thresh
            if Adds(j) == true %skip if no delta masses are present
                idx=id(:,j);
                idx=cell2mat(idx);
                idx(idx==0)=[];
                tX=scan(idx)>=thresh; %check if possible adduct intensities are >= thresh
                scan(idx(tX))=0; %set adduct intensity to 0
            end
        end
    end
end
end
