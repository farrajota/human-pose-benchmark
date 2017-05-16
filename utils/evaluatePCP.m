function evaluatePCP(list, dataset, evalMode, threshold, bSave, printLegend)
% implementation of the percentage correct part (PCP) evaluation
% metric.

%% Initializations
if isempty(strmatch(lower(dataset), {'flic', 'lsp'}))
    error(['Undefined dataset: ' dataset])
end
str = sprintf('PCP@%1.1f evaluation - Eval mode: %s ', threshold, evalMode);
fprintf('\n%s\n',strpadd('', '=',length(str),2))
fprintf('%s\n', str)
fprintf('%s\n',strpadd('', '=',length(str),2))

% check if input var printLegend is empty
if ~exist('printLegend','var')
    printLegend = true;
end

% criar var para indicar order global ou ordered local

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
pcpAlgs = {};
for ilist=1:1:size(algs,2)
    % fetch algorithms info+data
    alg = algs{ilist};
    name = alg.name;
    name(name==10)=[]; % remove \n if it exists
    
    if strcmpi(dataset, 'flic')
        if ~isfield(alg, 'keypoints_oc_flic'), continue; end
        pred = alg.sticks_oc_flic;
        
        % compute distance to ground truth joints
        dist = getDistPCP(pred, joints, 'flic');
    elseif strcmpi(dataset, 'lsp')
        if strcmp(evalMode,'OC')
            if ~isfield(alg, 'sticks_oc_lsp'), continue; end
            pred = alg.sticks_oc_lsp;
        else
            if ~isfield(alg, 'sticks_pc_lsp'), continue; end
            pred = alg.sticks_pc_lsp;
        end
        
        % compute distance to ground truth joints
        dist = getDistPCP(pred, joints(1:2,:,1001:2000), 'lsp');
    end
    
    % compute PCP
    pcp = computePCP(dist,range);

    % compute area under curve
    auc = area_under_curve(scale01(range),pcp(:,end));

    % assign data to cell
    pcpAlgs{end+1} = {pcp, colors(ilist,:), name, auc};
end

%% order algs based on the total PCK
pcpAlgs = orderAlgs(pcpAlgs);

%% plot curves for all body joints
if strcmpi(dataset, 'flic')
    % total + legend
    plotCurve(pcpAlgs, 6, range, ['FLIC Total, PCP ' evalMode], ['./plots/FLIC-pcp-total-legend-' evalMode], bSave, true)
    % total
    plotCurve(pcpAlgs, 6, range, ['FLIC Total, PCP ' evalMode], ['./plots/FLIC-pcp-total-' evalMode], bSave, printLegend)
    % Torso
    plotCurve(pcpAlgs, 5, range, ['FLIC Torso, PCP ' evalMode], ['./plots/FLIC-pcp-torso-' evalMode], bSave, printLegend)
    % Upper arm
    plotCurve(pcpAlgs, [1 3], range, ['FLIC Upper arms, PCP ' evalMode], ['./plots/FLIC-pcp-upper_arm-' evalMode], bSave, printLegend)
    % Forearm
    plotCurve(pcpAlgs, [2 4], range, ['FLIC Forearm, PCP ' evalMode], ['./plots/FLIC-pcp-forearm-' evalMode], bSave, printLegend)
elseif strcmpi(dataset, 'lsp')
    % total + legend
    plotCurve(pcpAlgs, 11, range, ['LSP Total, PCP ' evalMode], ['./plots/LSP-pcp-total-legend-' evalMode], bSave, true)
    % total
    plotCurve(pcpAlgs, 11, range, ['LSP Total, PCP ' evalMode], ['./plots/LSP-pcp-total-' evalMode], bSave, printLegend)
    % Torso
    plotCurve(pcpAlgs, 10, range, ['LSP Torso, PCP ' evalMode], ['./plots/LSP-pcp-torso-' evalMode], bSave, printLegend)
    % Upper leg
    plotCurve(pcpAlgs, [2 3], range, ['LSP Upper leg, PCP ' evalMode], ['./plots/LSP-pcp-upper_leg-' evalMode], bSave, printLegend)
    % Lower leg
    plotCurve(pcpAlgs, [1 4], range, ['LSP Lower leg, PCP ' evalMode], ['./plots/LSP-pcp-lower_leg-' evalMode], bSave, printLegend)
    % Upper arm
    plotCurve(pcpAlgs, [6 7], range, ['LSP Upper arm, PCP ' evalMode], ['./plots/LSP-pcp-upper_arm-' evalMode], bSave, printLegend)
    % Forearm
    plotCurve(pcpAlgs, [5 8], range, ['LSP Forearm, PCP ' evalMode], ['./plots/LSP-pcp-forearm-' evalMode], bSave, printLegend)
    % Head
    plotCurve(pcpAlgs, 9, range, ['LSP Head, PCP ' evalMode], ['./plots/LSP-pcp-head-' evalMode], bSave, printLegend)
end

%% print pck for all parts
print_pcp_algs(pcpAlgs, dataset)
    
%% Save results to a .tex table
genTablePCP(pcpAlgs, dataset, ['./latex/' upper(dataset) '-PCP-' evalMode '.tex'])

%% End of script
fprintf('\nPCP evaluation complete for %s (%s) PCP@%1.1f.\n', upper(dataset), evalMode, threshold)
end


% ========================================
% order the methods (highest total pck first)
% ========================================
function ordered = orderAlgs(Algs)
    pcp_vals = [];
    for i=1:1:size(Algs,2)
        pcp = Algs{i}{1};
        avg_value = squeeze(mean(pcp(:,end),2))';
        pcp_vals(i)=avg_value(end);
    end
    
    % sort values
    [~,idx] = sort(pcp_vals, 'ascend');
    
    % sort algs cell
    ordered = cell(1,size(Algs,2));
    for i=1:1:size(Algs,2)
        ordered{i} = Algs{idx(i)};
    end
end


% ========================================
% print the pcp metric for some body parts
% ========================================
function print_pcp_algs(pcpAlgs, dataset)
    % fetch biggest name of all algorithms
    max_str_length = 0;
    for ialg=1:1:size(pcpAlgs,2)
        name = pcpAlgs{ialg}{3};
        max_str_length = max(max_str_length, length(name));
    end

    fprintf('\n')
    max_str_part = 9;
    if strcmpi(dataset, 'flic')
        str1 = sprintf('%s | %s | %s | %s | %s | %s ',...
            strpadd('Method',    ' ', max_str_length,2),...
            strpadd('Torso',     ' ', max_str_part,2),...
            strpadd('Upper arm', ' ', max_str_part,2),...
            strpadd('Forearm',   ' ', max_str_part,2),...
            strpadd('PCP mean',  ' ', max_str_part,2),...
            strpadd('AUC',       ' ', max_str_part,2));
    elseif strcmpi(dataset, 'lsp')
        str1 = sprintf('%s | %s | %s | %s | %s | %s | %s | %s | %s',...
            strpadd('Method',    ' ', max_str_length,2),...
            strpadd('Torso',     ' ', max_str_part,2),...
            strpadd('Upper leg', ' ', max_str_part,2),...
            strpadd('Lower leg', ' ', max_str_part,2),...
            strpadd('Upper arm', ' ', max_str_part,2),...
            strpadd('Forearm',   ' ', max_str_part,2),...
            strpadd('Head',      ' ', max_str_part,2),...
            strpadd('PCP mean',  ' ', max_str_part,2),...
            strpadd('AUC',       ' ', max_str_part,2));
    end
    disp(str1)
    disp(strpadd('', '-', length(str1),0))

    for ialg=1:1:size(pcpAlgs,2)
        pcpAll = pcpAlgs{ialg}{1};
        name = strpadd(pcpAlgs{ialg}{3}, ' ',max_str_length,0);
        auc = pcpAlgs{ialg}{4};
        
        if strcmpi(dataset, 'flic')
            fprintf('%s | %s | %s | %s | %s | %s  \n',name,...
                strpadd(sprintf('%1.2f', pcpAll(end,5)), ' ',max_str_part,2),...
                strpadd(sprintf('%1.2f',(pcpAll(end,1)+pcpAll(end,3))/2), ' ',max_str_part,2),...
                strpadd(sprintf('%1.2f',(pcpAll(end,2)+pcpAll(end,4))/2), ' ',max_str_part,2), ...
                strpadd(sprintf('%1.2f', pcpAll(end,6)), ' ',max_str_part,2),...
                strpadd(sprintf('%1.2f', auc), ' ',max_str_part,2))
        elseif strcmpi(dataset, 'lsp')
            fprintf('%s | %s | %s | %s | %s | %s | %s | %s | %s \n',name,...
                strpadd(sprintf('%1.2f',pcpAll(end,10)), ' ',max_str_part,2),...
                strpadd(sprintf('%1.2f',(pcpAll(end,2)+pcpAll(end,3))/2), ' ',max_str_part,2), ...
                strpadd(sprintf('%1.2f',(pcpAll(end,1)+pcpAll(end,4))/2), ' ',max_str_part,2), ...
                strpadd(sprintf('%1.2f',(pcpAll(end,6)+pcpAll(end,7))/2), ' ',max_str_part,2), ...
                strpadd(sprintf('%1.2f',(pcpAll(end,5)+pcpAll(end,8))/2), ' ',max_str_part,2), ...
                strpadd(sprintf('%1.2f',pcpAll(end,9)), ' ',max_str_part,2),...
                strpadd(sprintf('%1.2f',pcpAll(end,11)), ' ',max_str_part,2),...
                strpadd(sprintf('%1.2f',auc), ' ',max_str_part,2))
        end
    end
    
    disp(strpadd('', '-', length(str1),0))
end
