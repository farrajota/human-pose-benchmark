function evaluatePCK(list, dataset, evalMode, threshold, bSave, printLegend)
% implementation of the percentage correct keypoints (PCK) evaluation
% metric.

%% Initializations
if isempty(strmatch(lower(dataset), {'flic', 'lsp'}))
    error(['Undefined dataset: ' dataset])
end
str = sprintf('PCK@%1.1f evaluation - Eval mode: %s ', threshold, evalMode);
fprintf('\n%s\n',strpadd('', '=',length(str),2))
fprintf('%s\n', str)
fprintf('%s\n',strpadd('', '=',length(str),2))

% check if input var printLegend is empty
if ~exist('printLegend','var')
    printLegend = true;
end

range = 0:0.01:threshold;

%% Load ground truth
joints = [];
assert(strcmp(evalMode,'PC') || strcmp(evalMode,'OC'));
if strcmpi(dataset, 'flic')
    load('./FLIC-joints-OC.mat','joints');
    evalMode = 'OC';
else
    load(['./LSP-joints-' evalMode '.mat'],'joints');
end


%% Load algorithms from the list
algs = getAlgsDir(list);
colors = uniqueColors(1, size(algs,2));

%% Cycle all algorithms and compute the PCK metric
pckAlgs = {};
for ilist=1:1:size(algs,2)
    % fetch algorithms info+data
    alg = algs{ilist};
    name = alg.name;
    name(name==10)=[]; % remove \n if it exists
    
    if strcmpi(dataset, 'flic')
        if ~isfield(alg, 'keypoints_oc_flic'), continue; end
        pred = alg.keypoints_oc_flic;
        
        % compute distance to ground truth joints
        dist = getDistPCK(pred, joints, 'flic');
    elseif strcmpi(dataset, 'lsp')
        if strcmp(evalMode,'OC')
            if ~isfield(alg, 'keypoints_oc_lsp'), continue; end
            pred = alg.keypoints_oc_lsp;
        else
            if ~isfield(alg, 'keypoints_pc_lsp'), continue; end
            pred = alg.keypoints_pc_lsp;
        end
        
        % compute distance to ground truth joints
        dist = getDistPCK(pred, joints(1:2,:,1001:2000), 'lsp');
    end
    
    % compute PCK
    pck = computePCK(dist,range);

    % compute area under curve
    auc = area_under_curve(scale01(range),pck(:,end));
    %fprintf('%s, AUC: %1.1f\n',name,auc);

    % assign data to cell
    pckAlgs{end+1} = {pck, colors(ilist,:), name, auc};
end

%% order algs based on the total PCK
pckAlgs = orderAlgs(pckAlgs);

%% plot curves for all body joints
if strcmpi(dataset, 'flic')
    % total
    plotCurve(pckAlgs, 12, range, ['FLIC Total, PCK@' num2str(threshold) ' ' evalMode], ['./plots/FLIC-pck-total-legend-' evalMode], bSave, true)
    % total
    plotCurve(pckAlgs, 12, range, ['FLIC Total, PCK@' num2str(threshold) ' ' evalMode], ['./plots/FLIC-pck-total-' evalMode], bSave, printLegend)
    % hip
    plotCurve(pckAlgs, [7 8], range, ['FLIC Hip, PCK@' num2str(threshold) ' ' evalMode], ['./plots/FLIC-pck-hip-' evalMode], bSave, printLegend)
    % wrist
    plotCurve(pckAlgs, [3 6], range, ['FLIC Wrist, PCK@' num2str(threshold) ' ' evalMode], ['./plots/FLIC-pck-wrist-' evalMode], bSave, printLegend)
    % elbow
    plotCurve(pckAlgs, [2 5], range, ['FLIC Elbow, PCK@' num2str(threshold) ' ' evalMode], ['./plots/FLIC-pck-elbow-' evalMode], bSave, printLegend)
    % shoulder
    plotCurve(pckAlgs, [1 4], range, ['FLIC Shoulder, PCK@' num2str(threshold) ' ' evalMode], ['./plots/FLIC-pck-shoulder-' evalMode], bSave, printLegend)
elseif strcmpi(dataset, 'lsp')
    % total
    plotCurve(pckAlgs, 15, range, ['LSP Total, PCK@' num2str(threshold) ' ' evalMode], ['./plots/LSP-pck-total-legend-' evalMode], bSave, true)
    % total
    plotCurve(pckAlgs, 15, range, ['LSP Total, PCK@' num2str(threshold) ' ' evalMode], ['./plots/LSP-pck-total-' evalMode], bSave, printLegend)
    % ankle
    plotCurve(pckAlgs, [1 6], range, ['LSP Ankle, PCK@' num2str(threshold) ' ' evalMode], ['./plots/LSP-pck-ankle-' evalMode], bSave, printLegend)
    % knee
    plotCurve(pckAlgs, [2 5], range, ['LSP Knee, PCK@' num2str(threshold) ' ' evalMode], ['./plots/LSP-pck-knee-' evalMode], bSave, printLegend)
    % hip
    plotCurve(pckAlgs, [3 4], range, ['LSP Hip, PCK@' num2str(threshold) ' ' evalMode], ['./plots/LSP-pck-hip-' evalMode], bSave, printLegend)
    % wrist
    plotCurve(pckAlgs, [7 12], range, ['LSP Wrist, PCK@' num2str(threshold) ' ' evalMode], ['./plots/LSP-pck-wrist-' evalMode], bSave, printLegend)
    % elbow
    plotCurve(pckAlgs, [8 11], range, ['LSP Elbow, PCK@' num2str(threshold) ' ' evalMode], ['./plots/LSP-pck-elbow-' evalMode], bSave, printLegend)
    % shoulder
    plotCurve(pckAlgs, [9 10], range, ['LSP Shoulder, PCK@' num2str(threshold) ' ' evalMode], ['./plots/LSP-pck-shoulder-' evalMode], bSave, printLegend)
    % head
    plotCurve(pckAlgs, [13 14], range, ['LSP Head, PCK@' num2str(threshold) ' ' evalMode], ['./plots/LSP-pck-head-' evalMode], bSave, printLegend)
end

%% print pck for all parts
print_pck_algs(pckAlgs, dataset)
    
%% Save results to a .tex table
genTablePCK(pckAlgs, dataset, ['./latex/' upper(dataset) '-PCK-' evalMode '.tex'])

%% End of script
fprintf('\nPCK evaluation complete for %s (%s) PCK@%1.1f.\n', upper(dataset), evalMode, threshold)
end


% ========================================
% order the methods (highest total pck first)
% ========================================
function ordered = orderAlgs(Algs)
    pck_vals = [];
    for i=1:1:size(Algs,2)
        pck = Algs{i}{1};
        avg_value = squeeze(mean(pck(:,end),2))';
        pck_vals(i)=avg_value(end);
    end
    
    % sort values
    [~,idx] = sort(pck_vals, 'ascend');
    
    % sort algs cell
    ordered = cell(1,size(Algs,2));
    for i=1:1:size(Algs,2)
        ordered{i} = Algs{idx(i)};
    end
end


% ========================================
% print the pck metric for some body parts
% ========================================
function print_pck_algs(pckAlgs, dataset)
    % fetch biggest name of all algorithms
    max_str_length = 0;
    for ialg=1:1:size(pckAlgs,2)
        name = pckAlgs{ialg}{3};
        max_str_length = max(max_str_length, length(name));
    end

    fprintf('\n')
    max_str_part = 8;
    if strcmpi(dataset, 'flic')
        str1 = sprintf('%s | %s | %s | %s | %s | %s | %s',...
            strpadd('Method',   ' ', max_str_length,2),...
            strpadd('Hip',      ' ', max_str_part,2),...
            strpadd('Wrist',    ' ', max_str_part,2),...
            strpadd('Elbow',    ' ', max_str_part,2),...
            strpadd('Shoulder', ' ', max_str_part,2),...
            strpadd('PCK mean', ' ', max_str_part,2),...
            strpadd('AUC',      ' ', max_str_part,2));
    elseif strcmpi(dataset, 'lsp')
        str1 = sprintf('%s | %s | %s | %s | %s | %s | %s | %s | %s | %s',...
            strpadd('Method',   ' ', max_str_length,2),...
            strpadd('Head',     ' ', max_str_part,2),...
            strpadd('Shoulder', ' ', max_str_part,2),...
            strpadd('Elbow',    ' ', max_str_part,2),...
            strpadd('Wrist',    ' ', max_str_part,2),...
            strpadd('Hip',      ' ', max_str_part,2),...
            strpadd('Knee',     ' ', max_str_part,2),...
            strpadd('Ankle',    ' ', max_str_part,2),...
            strpadd('PCK mean', ' ', max_str_part,2),...
            strpadd('AUC',      ' ', max_str_part,2));
    end
    disp(str1)
    disp(strpadd('', '-', length(str1),0))

    for ialg=1:1:size(pckAlgs,2)
        pckALL = pckAlgs{ialg}{1};
        name = strpadd(pckAlgs{ialg}{3}, ' ',max_str_length,0);
        auc = pckAlgs{ialg}{4};
        
        if strcmpi(dataset, 'flic')
            fprintf('%s | %s | %s | %s | %s | %s | %s \n',name,...
                strpadd(sprintf('%1.2f',(pckALL(end,7)+pckALL(end,8))/2), ' ',max_str_part,2),...
                strpadd(sprintf('%1.2f',(pckALL(end,3)+pckALL(end,6))/2), ' ',max_str_part,2), ...
                strpadd(sprintf('%1.2f',(pckALL(end,2)+pckALL(end,5))/2), ' ',max_str_part,2), ...
                strpadd(sprintf('%1.2f',(pckALL(end,1)+pckALL(end,4))/2), ' ',max_str_part,2), ...
                strpadd(sprintf('%1.2f',pckALL(end,12)), ' ',max_str_part,2),...
                strpadd(sprintf('%1.2f',auc), ' ',max_str_part,2))
        elseif strcmpi(dataset, 'lsp')
            fprintf('%s | %s | %s | %s | %s | %s | %s | %s | %s | %s \n',name,...
                strpadd(sprintf('%1.2f',(pckALL(end,13)+pckALL(end,14))/2), ' ',max_str_part,2), ...
                strpadd(sprintf('%1.2f',(pckALL(end,9)+pckALL(end,10))/2), ' ',max_str_part,2), ...
                strpadd(sprintf('%1.2f',(pckALL(end,8)+pckALL(end,11))/2), ' ',max_str_part,2), ...
                strpadd(sprintf('%1.2f',(pckALL(end,7)+pckALL(end,12))/2), ' ',max_str_part,2), ...
                strpadd(sprintf('%1.2f',(pckALL(end,3)+pckALL(end,4))/2), ' ',max_str_part,2), ...
                strpadd(sprintf('%1.2f',(pckALL(end,2)+pckALL(end,5))/2), ' ',max_str_part,2), ...
                strpadd(sprintf('%1.2f',(pckALL(end,1)+pckALL(end,6))/2), ' ',max_str_part,2), ...
                strpadd(sprintf('%1.2f',pckALL(end,15)), ' ',max_str_part,2),...
                strpadd(sprintf('%1.2f',auc), ' ',max_str_part,2))
        end
    end
    
    disp(strpadd('', '-', length(str1),0))
end
