function plotCurve(dataAlgs, jointIDs, range, titleName, fname, bSave, printLegend)

%% Set figure properties
figure('name', titleName);
hold on
set(0,'DefaultAxesFontSize',20);
set(0,'DefaultTextFontSize',20);

%% plot algs PCK
legendName = cell(size(dataAlgs,2),1);
for ialg = 1:1:size(dataAlgs,2)
    % select algorithm predictions
    pcp_pck_all = dataAlgs{ialg}{1};
    color = dataAlgs{ialg}{2};
    name = dataAlgs{ialg}{3};
    
    % compute mean
    avg_value = squeeze(mean(pcp_pck_all(:,jointIDs),2))';
    
    % plot mean value
    Xi = 0:0.001:range(end);
    Yi = interp1(range, avg_value,Xi,'spline');
    if mod(ialg,2)
        plot(Xi,Yi,'color',color,'LineStyle','-','LineWidth',3);      
    else
        plot(Xi,Yi,'color',color,'LineStyle','--','LineWidth',3);        
    end
    
    % add alg name to the list
    legendName{ialg} = name;
end

title(titleName);
if mod(range(end)*10,2) 
    step_x = floor(size(range,2)/5);
else
    step_x = floor(size(range,2)/4);
end
set(gca,'YLim',[0 100],'xtick',range(1:step_x:end),'ytick',0:10:100);
xlabel('Normalized distance');
ylabel('Detection rate, %');
if printLegend, legend(legendName,'Location','NorthWest'); end
grid on;

%% Save plots do disk
if bSave
    savefig([fname '.fig']);
    print(gcf, '-dpng', [fname '.png']);
    printpdf([fname '.pdf']);
end

%close(h1);
end
