close all force
clear all  %#ok<CLALL> Recompile classes


%% Set paths

exp = SpatialAnalysis();
% Assuming running in \Analysis\
exp = exp.setPaths(pwd);


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


%% 

% Change  Ar_useVAV = ArUseV || Ar_Use AV
% AVr_useVAVAAV = Ar_useVAV && Vr_useAAV 
% boxplot summaries difference between Ar_useVAV==1 and Ar_useVAV==0
% And Vr_useAAV ==0 and Vr_useAAV==1

% Normalise:
% Eg. Ar
% V coeff / A coeff
% AV coeff / A coeff
% Boxplot for two groups Ar_useVAV==1 and Ar_useVAV==0


%% Plot single subject summary

congRel = true;
exp.plotSingleSubjectSummary(9, [], [], congRel)


%% Plot single subject summary

exp.plotSingleSubjectSummary(6, [], [], congRel)


%% Plot group summary V_ar - accuracy

close all force

type = 'Accuracy';
group = exp.integrators.NonLinearResp.V_Ar;

exp = exp.plotGroupSummary(group, type);


%% Plot group summary V_ar - midError - not finished yet

close all force

type = 'MidError';
group = exp.integrators.NonLinearResp.V_Ar;

exp = exp.plotGroupSummary(group, type);


%% Plot group summary V_ar - congruence judement

close all force

type = 'Congruence';
group = exp.integrators.NonLinearResp.V_Ar;

exp = exp.plotGroupSummary(group, type);

