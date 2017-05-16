%% LSP dataset benchmark
% Benchmarks all available methods in http://human-pose.mpi-inf.mpg.de/#related_benchmarks
% for the Leeds Sport pose Dataset. The user can define which methods to
% display by simply indicating the folder name of the desired methods.

% Add eval code paths
addpath(genpath('./'))

list = {}; %{'BulatTzimiropoulosECCV16', 'WeiCVPR16','PishchulinCVPR16'};
bSave = true;
printLegend = false;
pcp_threshold = 0.5;
pck_threshold = 0.2;

%% PCP OC (observer-centric)
evaluatePCP(list, 'lsp', 'OC', pcp_threshold, bSave, printLegend);

%% PCP PC (Person-centric)
evaluatePCP(list, 'lsp', 'PC', pcp_threshold, bSave, printLegend);

%% PCK OC (observer-centric)
evaluatePCK(list, 'lsp', 'OC', pck_threshold, bSave, printLegend);

%% PCK PC (Person-centric)
evaluatePCK(list, 'lsp', 'PC', pck_threshold, bSave, printLegend);
