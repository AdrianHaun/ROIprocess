function Files=RoiDataselect(multi)
%GUI for Sample file selection. 
%Designed to be used in conjunction with ROIprocess
%Preallocation
Files={};
%GUI Fileselect one Group
if multi==0
    [Files1,path] = uigetfile('*.mzXML','Select Samples','MultiSelect','on');
    FilesPathless1=Files1;
    Files1=fullfile(path,Files1);
        if iscell(Files1) == 0 %Convert Files to cell when only one sample selected
            Files1 = {Files1};
            FilesPathless1={FilesPathless1};
        end
    Files{1,1}=Files1';
    Files{2,1}=FilesPathless1';
    if ischar(path) == 0 %Check Cancel input
        error("Task aborted by User")
    end
%GUI Fileselect two Groups
%Group 1
else
    [Files1,path] = uigetfile('*.mzXML','Select Dataset 1','MultiSelect','on');
    FilesPathless1=Files1;
    Files1=fullfile(path,Files1);
        if iscell(Files1) == 0
            Files1 = {Files1};
            FilesPathless1={FilesPathless1};
        end
    if ischar(path) == 0 %Check Cancel input
        error("Task aborted by User")
    end
%Group 2
    [Files2,path] = uigetfile('*.mzXML','Select Dataset 2','MultiSelect','on');
    FilesPathless2=Files2;
    Files2=fullfile(path,Files2);
        if iscell(Files2) == 0
            Files2 = {Files2};
            FilesPathless2={FilesPathless2};
        end
    if ischar(path) == 0 %Check Cancel input
        error("Task aborted by User")
    end
%Package File Paths into Cellarray
Files{1,1}=Files1';
Files{1,2}=Files2';
Files{2,1}=FilesPathless1';
Files{2,2}=FilesPathless2';
end
end

