function PlotEIC(TestPeak,TestTime)
%% Description
%% Input Dialogue
prompt = {'Masses:','Acceptable Mass Deviation [Da]'};
    dlgtitle = 'Specify Masses to Plot';
    dims = [1 60];
    definput = ["150","0.1"];
    answer = inputdlg(prompt,dlgtitle,dims,definput);
    Labels = strsplit(answer{1,1},{', ',' ',','});
    Masses = str2double(Labels);
    Labels=convertCharsToStrings(Labels);
    Labels = Labels + ' \pm ' + answer{2,1} + " Da";
    range = str2double(answer{2,1});
%% EIC Extraction
EIC=NaN * ones(length(TestPeak),length(Masses));
    for k=1:length(Masses)
        mz=Masses(1,k);
        for j=1:length(TestPeak)
            idx=TestPeak{j,1}(:,1)< mz+range & TestPeak{j,1}(:,1)> mz-range;
            Ints=TestPeak{j,1}(idx,2);
            check=isempty(Ints);
            if check==1
                Ints=0;
            end
            Ints=mean(Ints);
            EIC(j,k)=Ints;
        end
    end
    figure('Name','EIC','NumberTitle','off');
    plot(TestTime,EIC)
    xlabel('Elution time');
    ylabel('Intensity');
    legend(Labels);
end
