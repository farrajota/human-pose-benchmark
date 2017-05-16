%% FLIC dataset benchmark
% Benchmarks available methods for the FLIC Dataset. The user can define which methods to
% display by simply indicating the folder name of the desired methods.

% Add eval code paths
addpath(genpath('./'))

list = {};
bSave = true;
printLegend = false;
pcp_threshold = 0.5;
pck_threshold = 0.2;

%% PCP OC (observer-centric)
evaluatePCP(list, 'flic', 'OC', pcp_threshold, bSave, printLegend);

%% PCK OC (observer-centric)
evaluatePCK(list, 'flic', 'OC', pck_threshold, bSave, printLegend);
