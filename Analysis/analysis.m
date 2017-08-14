close all
clear


%% Set paths

exp = SpatialAnalysis();
% Assuming running in \Analysis\
exp = exp.setPaths(pwd);


%% Import 

close all

debug = false;
eyePlot = false;
print = false;
exp = exp.import(eyePlot, debug, print);


%% Apply gaze threshold
% If threshold set, trials will be dropped where onSurfProp is below
% threshold, including if no eye data is available (ie subs 1-6).
% Create indexes for allData and for data.sx

print = false;
exp = applyGazeThresh(exp, print);


%% Average accuracy

close all force
exp = exp.accuracy();


%% GLMs

close all force
exp = exp.GLMNonLinearCor();


%% GLMs

close all force
exp = exp.GLMNonLinearResp();

