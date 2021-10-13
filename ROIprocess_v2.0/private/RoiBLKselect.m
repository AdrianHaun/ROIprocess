function FilesBLK=RoiBLKselect(multi)
%GUI for Blank file selection. 
%Designed to be used in conjunction with ROIprocess
%Preallocation
FilesBLK={};
%GUI Fileselect one Group
if multi==true
    [FilesBLK1,path] = uigetfile('*.mzXML','Select Blanks','MultiSelect','on');
    BLKPathless1=FilesBLK1;
    FilesBLK1=fullfile(path,FilesBLK1);
        if iscell(FilesBLK1) == 0
            FilesBLK1 = {FilesBLK1};
            BLKPathless1 = {BLKPathless1};
        end
    FilesBLK{1,1}=FilesBLK1';
    FilesBLK{2,1}=BLKPathless1';
    if ischar(path) == 0 %Check Cancel input
        error("Task aborted by User")
    end
%GUI Fileselect two Groups
%Group 1
else
    [FilesBLK1,path] = uigetfile('*.mzXML','Select Blanks for Dataset 1','MultiSelect','on');
    BLKPathless1=FilesBLK1;
    FilesBLK1=fullfile(path,FilesBLK1);
        if iscell(FilesBLK1) == 0
            FilesBLK1 = {FilesBLK1};
            BLKPathless1 = {BLKPathless1};
        end
    if ischar(path) == 0 %Check Cancel input
        error("Task aborted by User")
    end
%Group2
    [FilesBLK2,path] = uigetfile('*.mzXML','Select Blanks for Dataset 2','MultiSelect','on');
    BLKPathless2=FilesBLK2;
    FilesBLK2=fullfile(path,FilesBLK2);
        if iscell(FilesBLK2) == 0
            FilesBLK2 = {FilesBLK2};
            BLKPathless2 = {BLKPathless2};
        end
    if ischar(path) == 0 %Check Cancel input
        error("Task aborted by User")
    end
%Package File Paths into Cellarray
FilesBLK{1,1}=FilesBLK1';
FilesBLK{1,2}=FilesBLK2';
FilesBLK{2,1}=BLKPathless1';
FilesBLK{2,2}=BLKPathless2';
end
end