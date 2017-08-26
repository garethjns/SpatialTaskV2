close all force
clear all  %#ok<CLALL> Recompile classes


%% Set paths

exp = SpatialAnalysis();
% Assuming running in \Analysis\
exp = exp.setPaths();


%% Import 

close all force

debug = false;
eyePlot = false;
print = false;
exp = exp.import(eyePlot, debug, print);


%% Apply gaze threshold
% If threshold set, trials will be dropped where onSurfProp is below
% threshold, including if no eye data is available (ie subs 1-6).
% Create indexes for allData and for data.sx

close all force

print = [true, true, true, true];
exp = applyGazeThresh(exp, print);


%% Average accuracy

close all force

plt = [];
exp = exp.accuracy(plt);


%% Mid error

% Remove abs plots

close all force

plt = [true, false, false];
exp = exp.midError(plt);


%% Congruence judgements


% Remove abs plots
close all force

plt = [true, false];
exp = exp.congruence(plt);


%% GLMs

close all force

exp = exp.GLMNonLinearResp();


%% Find integrators

close all force

thresh = 0.05;
exp = exp.findIntegrators('NLR', thresh);


%% Disp NLR integrators

close all force

exp.dispIntergrators('NLR')


%% Plot single subject summary

close all force

congRel = true;
sub = 1; % Int
exp.plotSingleSubjectSummary(sub, [], [], congRel)


%% Plot single subject summary

close all force

sub = 2; % Non-int
exp.plotSingleSubjectSummary(sub, [], [], congRel)


%% Plot group summary V_ar - int==1

close all force

group = exp.integrators.NonLinearResp.V_Ar;

type = 'Accuracy';
exp = exp.plotGroupSummary(group, type);

type = 'MidError';
exp = exp.plotGroupSummary(group, type);

type = 'Congruence';
exp = exp.plotGroupSummary(group, type);


%% Plot group summary V_ar - int==0

close all force

group = ~exp.integrators.NonLinearResp.V_Ar;

type = 'Accuracy';
exp = exp.plotGroupSummary(group, type);

type = 'MidError';
exp = exp.plotGroupSummary(group, type);

type = 'Congruence';
exp = exp.plotGroupSummary(group, type);


%% Tidy

close all force
clear plt print group eyePlot debug congRel type thresh sub

