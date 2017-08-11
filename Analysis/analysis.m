close all
clear


%% Set paths

exp = SpatialAnalysis();
% Assuming running in \Analysis\
exp = exp.setPaths(pwd);


%% Import 

close all

debug = false;
exp = exp.import(debug);


%% Apply gaze threshold
% If threshold set, trials will be dropped where onSurfProp is below
% threshold, including if no eye data is available (ie subs 1-6).
% Create indexes for allData and for data.sx

exp = applyGazeThresh(exp);


%% Average accuracy

