function algs = getAlgsDir( list)
% Fetch all algorithms from the pred directory for the PCK/PCP metric in
% Observer-Centric/Person-Centric mode.

%% intializations


%% load algorithms prediction from dir
algs = {};
if ~isempty(list)
    % fetch the corresponding folder's data
    for i=1:1:size(list,2)
        algs{end+1} = getDataDir(list{i});
    end

else
    % empty list, fetch all data from all folders
    directories = dir('./algorithms');
    
    for i=3:1:size(directories)
        if directories(i).isdir
            algs{end+1} = getDataDir(directories(i).name);
        end
    end
end


end

function p = getDataDir(dirName)
    assert(exist(['./algorithms/' dirName],'dir')>0, ['Error: dir name does not exist: ' dirName])

    p = struct;
    p.name = GetNameFromFile(['./algorithms/' dirName '/algorithm.txt']);

    if exist(['./algorithms/' dirName '/pred_sticks_lsp_oc.mat'], 'file')
        data_pred = load(['./algorithms/' dirName '/pred_sticks_lsp_oc.mat']);
        p.sticks_oc_lsp = data_pred.pred;
    elseif exist(['./algorithms/' dirName '/pred_keypoints_lsp_oc.mat'], 'file')
        data_pred = load(['./algorithms/' dirName '/pred_keypoints_lsp_oc.mat']);
        p.sticks_oc_lsp = keypoints2sticksLSP(data_pred.pred);
    end
    if exist(['./algorithms/' dirName '/pred_sticks_lsp_pc.mat'], 'file')
        data_pred = load(['./algorithms/' dirName '/pred_sticks_lsp_pc.mat']);
        p.sticks_pc_lsp = data_pred.pred;
    elseif exist(['./algorithms/' dirName '/pred_keypoints_lsp_pc.mat'], 'file')
         data_pred = load(['./algorithms/' dirName '/pred_keypoints_lsp_pc.mat']);
        p.sticks_pc_lsp = keypoints2sticksLSP(data_pred.pred);
    end
    if exist(['./algorithms/' dirName '/pred_keypoints_lsp_oc.mat'], 'file')
        data_pred = load(['./algorithms/' dirName '/pred_keypoints_lsp_oc.mat']);
        p.keypoints_oc_lsp = data_pred.pred;
    end
    if exist(['./algorithms/' dirName '/pred_keypoints_lsp_pc.mat'], 'file')
        data_pred = load(['./algorithms/' dirName '/pred_keypoints_lsp_pc.mat']);
        p.keypoints_pc_lsp = data_pred.pred;
    end
    if exist(['./algorithms/' dirName '/pred_sticks_flic_oc.mat'], 'file')
        data_pred = load(['./algorithms/' dirName '/pred_sticks_flic_oc.mat']);
        p.sticks_oc_flic = data_pred.pred;
    elseif exist(['./algorithms/' dirName '/pred_keypoints_flic_oc.mat'], 'file')
        data_pred = load(['./algorithms/' dirName '/pred_keypoints_flic_oc.mat']);
        p.sticks_oc_flic = keypoints2sticksFLIC(data_pred.pred);
    end
    if exist(['./algorithms/' dirName '/pred_keypoints_flic_oc.mat'], 'file')
        data_pred = load(['./algorithms/' dirName '/pred_keypoints_flic_oc.mat']);
        p.keypoints_oc_flic = data_pred.pred;
    end
end

function fname = GetNameFromFile(filename)
    fid = fopen(filename,'r');
    C = textscan(fid, '%s','delimiter', '\n');
    fname = C{1,1}{1};
end

