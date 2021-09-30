function MCRplots(ReportTable,mzroi_end,time_end)
%MCRplots plots Concentration Profiles and Pure Spectra for all Components
%   Detailed explanation goes here
%%Plot ConcProfiles
[numComp,~]=size(ReportTable);
if ReportTable.Group(end) == '2'
    numComp=numComp/2;
end
[nrowsA,~]=size(ReportTable.ConcProfiles{1});
[nrowsB,~]=size(ReportTable.ConcProfiles{end});
yLabels=ReportTable.Component;
figure('Name','Concentration Profiles','NumberTitle','off');
Concs = tiledlayout('flow','TileSpacing','Compact');
for k=1:numComp
    y=ReportTable.AvgConcProfiles{k};
    nexttile
    plot(time_end(1:nrowsA,1),y)
    if ReportTable.Group(end) == '2'
        hold on
        y2=ReportTable.AvgConcProfiles{k+numComp};
        plot(time_end(1:nrowsB,1),y2,'Color','#D95319')
        hold off
    end
    title(yLabels(k,1))
end
    title(Concs,'Pure Concentration Profiles')
    xlabel(Concs,'Elution time')
    ylabel(Concs,'Intensity')
    if ReportTable.Group(end) == '2'
        legend("Avg. Profiles Group 1","Avg. Profiles Group 2")
    else
        legend("Avg. Profiles")
    end
%% Plot Pure Spectras
Y=cell2mat(ReportTable.PureSpectrum');
figure('Name','Pure Spectras','NumberTitle','off');
spectras = tiledlayout('flow','TileSpacing','Compact');
for k=1:numComp
    nexttile
    stem(mzroi_end,Y(:,k),'Marker','none','Color','k');
    title(yLabels(k,1))
end
title(spectras,'Pure Spectras')
xlabel(spectras,'m/z [Da]')
ylabel(spectras,'Intensity [arb]')
end

