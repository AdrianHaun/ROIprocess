function PlotProfileCheck(EICs,ReportTable)
%%Plot Concentration Profile vs EIC for Components specified by the user.
% User Input
prompt = {'Components:'};
    dlgtitle = 'Specify Components to Plot';
    dims = [1 60];
    definput = "1";
    answer = inputdlg(prompt,dlgtitle,dims,definput);
    Labels = strsplit(answer{1,1},{', ',' ',','});
    Comp = str2double(Labels);
    [numComp,~]=size(ReportTable);
%Plot
for k=1:length(Comp)
    num=Comp(1,k);
    title="Concentration Profiles vs Main EIC for Component "+Labels(1,k);
    figure('Name',title,'NumberTitle','off');
        hold on
        if length(EICs)==2
            plot(ReportTable.AvgConcProfiles{num});
            plot(ReportTable.AvgConcProfiles{num+numComp/2});
            plot(EICs{1,1}(:,num));
            plot(EICs{1,2}(:,num));
            legend(["Pure Concentration Profile Group 1";"Pure Concentration Profile Group 2";"EIC of Main mz Group 1";"EIC of Main mz Group 2"])
        else
            plot(ReportTable.AvgConcProfiles{num});
            plot(EICs{1,1}(:,num));
            legend(["Pure Concentration Profile";"EIC of Main mz"])
        end
        hold off
        xlabel('Scan Number');
        ylabel('Intensity');
end