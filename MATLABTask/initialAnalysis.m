close all
% Load the data (assuming the 'Nicole\07-Apr-2016 16_24_11\ folder is in
% the working direcory)
load('Nicole\07-Apr-2016 16_24_11\SpatialCapture_Nicole.mat')

%% Plot
% For each position, plot absolute error against abosolute difference
% Fold space
% Average over rate

flag = 1; % This sets an option for the function below
% Title for the graph:
tit = 'Absolute incongruency vs absolute response error';
% Get the data/stats for the plot:
stats = gatherPosPlot1(stimLog, flag);
% And plot:
plotSpatialData(stats, tit);
ng;

%% Plot

flag = 2;
tit = 'Absolute incongruency vs relative response error';
stats = gatherPosPlot1(stimLog, flag);
plotSpatialData(stats, tit);
ng;