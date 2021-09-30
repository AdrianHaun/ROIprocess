function [Peaklist,Timelist] = RoiDataload(Files,nrowsStart1,nrowsEnd1,nrowsStart2,nrowsEnd2,nrowDif)
%for one Group or same number of rows to process
if nrowDif==0
    %Reshape Cell Array to Column Vector
    if numel(Files)== 4 %2 Groups + BLK
        Files=[Files{1,1};Files{2,1};Files{1,2};Files{2,2}]; 
    elseif numel(Files)== 2 %2 Groups w/o BLK, 1 Group + BLK
        Files=reshape(Files,[],1);
        Files=[Files{1,1};Files{2,1}];
    else %1 Group w/o BLK
        Files=[Files{1,1}];
    end
    parfor k = 1 : length(Files)
           File=Files{k,1};
           disp(['Now reading ', File]);
           mzxml = mzxmlload(File,'Levels',1); %Data extraction
           [Peak, Time]= mzxml2peaks(mzxml);
           if length(Time) < nrowsEnd1
                messege="Last scan to process is set to ";
                messege=messege+nrowsEnd1
                messegeMid=", but the Data file only contains "
                messegeMid=messegeMid+length(Time);
                messegeEnd=" Scans. Adjust last Scan to process for Dataset 1.";
                messege=messege+messegeMid+messegeEnd;
                error(messege)
            end
           Peaklist{1,k}=Peak(nrowsStart1:nrowsEnd1); %Cut to size
           Timelist{1,k}=Time(nrowsStart1:nrowsEnd1);
    end
    [Peaklist]=DataCleanUp(Peaklist); %remove Masses with intensity < 1% Max Intensity
% nrows different for Groups   
else
    %Reshape Cell Array to Column Vectors
    if numel(Files)== 4 %2 Groups + BLK
        FilesA=[Files{1,1};Files{2,1}];
        FilesB=[Files{1,2};Files{2,2}];
    else %2 Groups w/o BLK
        FilesA=Files{1,1};
        FilesB=Files{1,2};
    end
    parfor k= 1:length(FilesA)
            FileA=FilesA{k,1}; %Group 1 (first column)
            disp(['Now reading ', FileA]);
            mzxmlA = mzxmlload(FileA,'Levels',1); %Data Extraction
            [PeakA, TimeA]= mzxml2peaks(mzxmlA);
            if length(TimeA) < nrowsEnd1
                messege="Last scan to process is set to ";
                messege=messege+nrowsEnd1;
                messegeMid=", but the Data file only contains ";
                messegeMid=messegeMid+length(TimeA);
                messegeEnd=" Scans. Adjust last Scan to process for Dataset 1.";
                messege=messege+messegeMid+messegeEnd;
                error(messege)
            end
            PeaklistA{1,k}=PeakA(nrowsStart1:nrowsEnd1); %Cut to size
            TimelistA{1,k}=TimeA(nrowsStart1:nrowsEnd1);
    end
    parfor k= 1:length(FilesB)
            FileB=FilesB{k,1};
            disp(['Now reading ', FileB]);
            mzxmlB = mzxmlload(FileB,'Levels',1);%Data Extraction
            [PeakB, TimeB]= mzxml2peaks(mzxmlB);
            if length(TimeB) < nrowsEnd2
                messege="Last scan to process is set to ";
                messege=messege+nrowsEnd2;
                messegeMid=", but the Data file only contains ";
                messegeMid=messegeMid+length(TimeB);
                messegeEnd=" Scans. Adjust last Scan to process for Dataset 2.";
                messege=messege+messegeMid+messegeEnd;
                error(messege)
            end
            PeaklistB{1,k}=PeakB(nrowsStart2:nrowsEnd2); %Cut to size
            TimelistB{1,k}=TimeB(nrowsStart2:nrowsEnd2);
    end
    [PeaklistA]=DataCleanUp(PeaklistA); %remove Masses with intensity < 1% Max Intensity
    [PeaklistB]=DataCleanUp(PeaklistB);
    Peaklist=[PeaklistA PeaklistB]; %Combine Groups
    Timelist=[TimelistA TimelistB];
end