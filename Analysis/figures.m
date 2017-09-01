close all force
clear all  %#ok<CLALL> Recompile classes


%% Set paths

exp = SpatialAnalysis();
% Assuming running in \Analysis\
exp = exp.setPaths();

close all force

debug = false;
eyePlot = false;
print = false;
exp = exp.import(eyePlot, debug, print);

close all force

print = [false, false, false, false];
exp = applyGazeThresh(exp, print);


%% Figure 1 (unfolded, abs accuracy)

close all force

plt = [true, false, false, false];
[exp, h] = exp.accuracy(plt);

% Save Figure 1
figure(h(1,1))
SpatialAnalysis.ng('spFigure1');
SpatialAnalysis.hgx([exp.paths.gPath, 'Figure1']);


%% Figure 2 (folded, rel accuracy)

close all force

plt = [false, false, true false];
[exp, h] = exp.accuracy(plt);

% Save Figure 2
figure(h(1,3))
SpatialAnalysis.ng('spFigure2');
SpatialAnalysis.hgx([exp.paths.gPath, 'Figure2']);


%% Figure 3 (unfolded mid error)

close all force

plt = [true, false, false];
[exp, h] = exp.midError(plt);

% Save Figure 3
figure(h(1,1))
SpatialAnalysis.ng('spFigure3');
SpatialAnalysis.hgx([exp.paths.gPath, 'Figure3']);


%% Figure 4 (rel congruence)

close all force

plt = [false, true];
[exp, h] = exp.congruence(plt);

% Save figure 4
figure(h(1,2))
SpatialAnalysis.ng('Wide');
SpatialAnalysis.hgx([exp.paths.gPath, 'Figure4']);


%% Figure 5 (GLM figures)

close all force

[exp, h] = exp.GLMNonLinearResp();

% Save figure 5
figure(h)
SpatialAnalysis.ng('spFigure5');
SpatialAnalysis.hgx([exp.paths.gPath, 'Figure5']);


%% Figure 6 (integrators heatmap)

close all force

plt = [true, false, false];
thresh = 0.05;
exp = exp.findIntegrators('NLR', thresh);
h = exp.dispIntergrators('NLR', plt);

% Save figure 6
figure(h(1))
SpatialAnalysis.ng('spFigure6');
SpatialAnalysis.hgx([exp.paths.gPath, 'Figure6']);


%% Figure 7 (integrators)

close all force

group = exp.integrators.NonLinearResp.V_Ar;
disp(['V_Ar: Integrators, n = ', num2str(sum(group))])

type = 'Accuracy';
[exp, h] = exp.plotGroupSummary(group, type);
figure(h(1,3))
SpatialAnalysis.ng('spFigure2');

type = 'MidError';
[exp, h] = exp.plotGroupSummary(group, type);
figure(h(1,1))
SpatialAnalysis.ng('spFigure3');

type = 'Congruence';
[exp, h] = exp.plotGroupSummary(group, type);
figure(h(1,2))
SpatialAnalysis.ng('Wide');


%% Figure 8 (non-integrators)

close all force

group = ~exp.integrators.NonLinearResp.V_Ar;
disp(['V_Ar: Non-integrators, n = ', num2str(sum(group))])

type = 'Accuracy';
[exp, h] = exp.plotGroupSummary(group, type);
figure(h(1,3))
SpatialAnalysis.ng('spFigure2');

type = 'MidError';
[exp, h] = exp.plotGroupSummary(group, type);
figure(h(1,1))
SpatialAnalysis.ng('spFigure3');

type = 'Congruence';
[exp, h] = exp.plotGroupSummary(group, type);
figure(h(1,2))
SpatialAnalysis.ng('Wide');
