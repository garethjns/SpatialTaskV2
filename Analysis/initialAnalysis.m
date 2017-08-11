% Bugs:
%  - Across-subject averages need sorting out. They don't deal well with
% all-nan data for subjects (eg for early when eyetracker threshold on)
% Use wrong number of subejcts when calculating SE
% Might take NaN to poopulate postion and diff rows - switched to take from
% subject 7 rather than 1 now.
%  - Trying to open tables in variable viewer causes crash in
% variableEditorMetadata() - might be due to NaTs??
% Avoidable if stop on errors is off

close all
clear

%% Set paths

exp = InitialAnalysis();
% Assuming running in \Analysis\
exp = exp.setPaths(pwd);


%% Import 

close all
exp = exp.import();


%% Gaze trajectories

close all
allLines = true;
thresh1 = 0.75;

for e = 1:exp.expN
    fieldName = ['s', num2str(e)];
        tit = ['S', num2str(e)];
    
    InitialAnalysis.gazeTrajectories(exp.expDataS.(fieldName), ...
        exp.eyeDataS.(fieldName), ...
        tit, thresh1, allLines)
    
end

%% Apply gaze threshold
% If threshold set, trials will be dropped where onSurfProp is below
% threshold, including if no eye data is available (ie subs 1-6).
% Create indexes for allData and for data.sx

exp = applyGazeThresh(exp);


%% Plot accuracies - Abs diffs
% Plots:
% 1
% Two subplots, left for auditory response accuracy and right for
% visual response accuracy.
% X is location of the stimulus
% Y is proportion of correct responses
% Lines are location of other modality. In this cell the
% direction of the disparity is ignored.
%
% 2
% A heatmap showing the same data but from a different angle. Colour
% indicates proportion correct.
%
% The first plots for each subject plots accuracy across all of space, the
% second plots for folded space.
%
% The final set of plots is a quick average of all the data that should
% look siliar to the across subject average, but doesn't have error bars.

rel = false;

close all
for e = 1:exp.expN
    fieldName = ['s', num2str(e)];
    
    tit = ['S', num2str(e), ...
        ': Response accuracy - Abs'];
    
    fold = false;
    [statsAcAbs.(fieldName), statsVcAbs.(fieldName)] = ...
        exp.gatherAccs(exp.expDataS.(fieldName), fold, rel);
    
    exp.plotAccs(statsAcAbs.(fieldName), statsVcAbs.(fieldName), tit);
    
    fold = true;
    [statsAcFoldAbs.(fieldName), statsVcFoldAbs.(fieldName)] = ...
        exp.gatherAccs(exp.expDataS.(fieldName), fold, rel);
    exp.plotAccs(statsAcFoldAbs.(fieldName), ...
        statsVcFoldAbs.(fieldName), tit);
end

% All data
fold = false;
[statsAcAllAbs, statsVcAllAbs] = ...
    exp.gatherAccs(exp.expDataAll, fold, rel);
exp.plotAccs(statsAcAllAbs, statsVcAllAbs, 'All data - Abs');

fold = true;
[statsAcAllFoldAbs, statsVcAllFoldAbs] = ...
    exp.gatherAccs(exp.expDataAll, fold, rel);
exp.plotAccs(statsAcAllFoldAbs, statsVcAllFoldAbs, ...
    'All data - Abs');


%% Plot accuracies - Rel diffs
% Plots:
% 1
% Two subplots, left for auditory response accuracy and right for
% visual response accuracy.
% X is location of the stimulus
% Y is proportion of correct responses
% Lines are location of other modality. In this cell the plots include
% direction, where - disparity indicates the other modaility was closer to
% the midline.
%
%
% The first plots for each subject plots accuracy across all of space, the
% second plots for folded space.
%
% The final set of plots is a quick average of all the data that should
% look siliar to the across subject average, but doesn't have error bars.

rel = true;

close all
for e = 1:exp.expN
    fieldName = ['s', num2str(e)];
    
    tit = ['S', num2str(e), ...
        ': Response accuracy - Abs'];
    
    fold = false;
    [statsAcRel.(fieldName), statsVcRel.(fieldName)] = ...
        exp.gatherAccs(exp.expDataS.(fieldName), fold, rel);
    exp.plotAccs(statsAcRel.(fieldName), statsVcRel.(fieldName), tit);
    
    fold = true;
    [statsAcFoldRel.(fieldName), statsVcFoldRel.(fieldName)] = ...
        exp.gatherAccs(exp.expDataS.(fieldName), fold, rel);
    exp.plotAccs(statsAcFoldRel.(fieldName), ...
        statsVcFoldRel.(fieldName), tit);
end

% All data
fold = false;
[statsAcAll, statsVcAll] = ...
    exp.gatherAccs(exp.expDataAll, fold, rel);
exp.plotAccs(statsAcAll, statsVcAll, 'All data - Abs');

fold = true;
[statsAcAllFoldRel, statsVcAllFoldRel] = ...
    exp.gatherAccs(exp.expDataAll, fold, rel);
exp.plotAccs(statsAcAllFoldRel, statsVcAllFoldRel, ...
    'All data - Abs');


%% Across subject averages - accuracy
% This cell plots the above two cells as across-subject averages
% It also adds heatmap showing the same data but from a different angle.
% (ie accuracy vs disparity)

close all

tit = 'Response accuracy - fold, abs, across subs';
[summaryA, dataA, posAx] = exp.gatherAcrossSubjectAccuracy(statsAcFoldAbs);
[summaryV, dataV, ~] = exp.gatherAcrossSubjectAccuracy(statsVcFoldAbs);
exp.plotAcrossSubjectAccuracy(summaryA, summaryV, posAx, tit)

tit = 'Response accuracy - fold, rel, across subs';
[summaryA, dataA, posAx] = exp.gatherAcrossSubjectAccuracy(statsAcFoldRel);
[summaryV, dataV, ~] = exp.gatherAcrossSubjectAccuracy(statsVcFoldRel);
exp.plotAcrossSubjectAccuracy(summaryA, summaryV, posAx, tit)


tit = 'Response accuracy - unfold, abs, across subs';
[summaryA, dataA, posAx] = exp.gatherAcrossSubjectAccuracy(statsAcAbs);
[summaryV, dataV, ~] = exp.gatherAcrossSubjectAccuracy(statsVcAbs);
exp.plotAcrossSubjectAccuracy(summaryA, summaryV, posAx, tit)

tit = 'Response accuracy - unfold, rel, across subs';
[summaryA, dataA, posAx] = exp.gatherAcrossSubjectAccuracy(statsAcRel);
[summaryV, dataV, ~] = exp.gatherAcrossSubjectAccuracy(statsVcRel);
exp.plotAcrossSubjectAccuracy(summaryA, summaryV, posAx, tit)


%% Plot % correct heatmaps - folded and unfolded
% This cell plots heatmaps of A and V localisation accuracy as a postion vs
% v position. These are plotted with and without folded space.
% There are plots of each subject and an across-subject average.

close all
% for e = 1:exp.expN
%     fieldName = ['s', num2str(e)];
%     
%     fold = true;
%     tit = ['S', num2str(e), ...
%         ': Response accuracy - folded'];
%     
%     
%     [hmAFold.(fieldName), hmVFold.(fieldName), ax] = ...
%         gatherPCHeatmaps(data.(fieldName), fold);
%     
%     plotHeatmaps(hmAFold.(fieldName), hmVFold.(fieldName), ax, tit);
%     
%     
%     fold = false;
%     tit = ['S', num2str(e), ...
%         ': Response accuracy - not folded'];
%     
%     [hmA.(fieldName), hmV.(fieldName), ax] = ...
%         gatherPCHeatmaps(data.(fieldName), fold);
%     
%     plotHeatmaps(hmA.(fieldName), hmV.(fieldName), ax, tit);
%     
% end

fold = true;
tit = 'Alldata: Response accuracy - folded';
[hmAFoldAll, hmVFoldAll, ax] = ...
    exp.gatherPCHeatmaps(exp.expDataAll, fold);
exp.plotHeatmaps(hmAFoldAll, hmVFoldAll, ax, tit);

fold = false;
tit = 'AllData : Response accuracy - not folded';
[hmAAll, hmVAll, ax] = ...
    exp.gatherPCHeatmaps(exp.expDataAll, fold);
exp.plotHeatmaps(hmAAll, hmVAll, ax, tit);


%% Response histograms

close all
for e = 1:exp.expN
    fieldName = ['s', num2str(e)];
    
    tit = ['S', num2str(e), ...
        ': folded response hist'];
    
    fold = true;
    exp.plotRespHist(exp.expDataS.(fieldName), fold, tit)
    
    tit = ['S', num2str(e), ...
        ': unfolded response hist'];
    
    fold = false;
    exp.plotRespHist(exp.expDataS.(fieldName), fold, tit)
end

tit = 'All data: Folded response hist';

fold = true;
exp.plotRespHist(exp.expDataAll, fold, tit)

tit = 'All data: Unfolded response hist';

fold = false;
exp.plotRespHist(exp.expDataAll, fold, tit)


%% Binned response histograms (respBinAn)

close all
for e = 1:exp.expN
    fieldName = ['s', num2str(e)];
    
    tit = ['S', num2str(e), ...
        ': unfolded binned response hist'];
    
    fold = false;
    exp.plotBinnedRespHist(exp.expDataS.(fieldName), fold, tit)
end


tit = 'All data: Binned unfolded response hist';

fold = false;
exp.plotBinnedRespHist(exp.expDataAll, fold, tit)


%% Response deviation histograms
% See
% http://journals.plos.org/plosbiology/article?id=10.1371/journal.pbio.1002073
% Fig 2
% Plot, for A and V response in folded space:
% AV cong as baseline
% For each disparity, histogram of response error

close all
binned = false;
pInc = [];

tit = 'Response distributions, all data, rel, normX';
rel = true;
normY = false;
normX = true;
[dataA, dataV, pAx, dAx] = ...
    exp.gatherDispHists(exp.expDataAll, rel, pInc);
exp.plotDispHists(dataA, dataV, pAx, dAx, normX, normY, tit)

tit = 'Response distributions, all data, abs, normX';
rel = false;
normY = false;
normX = true;
[dataA, dataV, pAx, dAx] = ...
    exp.gatherDispHists(exp.expDataAll, rel, pInc);
exp.plotDispHists(dataA, dataV, pAx, dAx, normX, normY, tit)


tit = 'Response distributions, all data, rel, normX, normY';
rel = true;
normY = true;
normX = true;
[dataA, dataV, pAx, dAx] = ...
    exp.gatherDispHists(exp.expDataAll, rel, pInc);
exp.plotDispHists(dataA, dataV, pAx, dAx, normX, normY, tit)

tit = 'Response distributions, all data, abs, normX, normY';
rel = false;
normY = true;
normX = true;
[dataA, dataV, pAx, dAx] = ...
    exp.gatherDispHists(exp.expDataAll, rel, pInc);
exp.plotDispHists(dataA, dataV, pAx, dAx, normX, normY, tit)


%% Middle pos error hists

abs = false;
folded = true;

close all
for e = 1:exp.expN
    fieldName = ['s', num2str(e)];
    
    tit = ['S', num2str(e), ...
        ': '];
    
    % Get data (temp) is relative
    [A, V] = exp.gatherMidHist(exp.expDataS.(fieldName));
    
    % Plot - decide here if rel or abs with respect to response error
    exp.plotMidHist(A, V, tit, abs)
end

abs = false;
tit = 'All subjects, xNorm, yNorm';
[A, V] = exp.gatherMidHist(exp.expDataAll);
exp.plotMidHist(A, V, tit, abs)

abs = false;
tit = 'All subjects, xNorm';
[A, V] = exp.gatherMidHist(exp.expDataAll);
exp.plotMidHist(A, V, tit, abs, true, false)

abs = true;
tit = 'All subjects, xNorm, abs';
[A, V] = exp.gatherMidHist(exp.expDataAll);
exp.plotMidHist(A, V, tit, abs, true, false)


%% Plot 1
% For each position, plot absolute error against abosolute difference
% Fold space (and again around actual visual location)
% Average over rate

close all
flag = 1; % This sets an option for the function below
for e = 1:exp.expN
    fieldName = ['s', num2str(e)];
    
    % Title for the graph:
    tit = ['S', num2str(e), ...
        ': Absolute incongruence vs absolute response error'];
    % Get the data/stats for the plot:
    statsP1.(fieldName) = exp.gatherPosPlot1(exp.expDataS.(fieldName), flag);
    % And plot:
    exp.plotSpatialData(statsP1.(fieldName), tit);
    % ng;
end


%% Plot 2
% For each position, plot absolute error against relative difference
% Fold space. Relative error: - = back towards midline
% Average over rate

close all
flag = 2;
for e = 1:exp.expN
    fieldName = ['s', num2str(e)];
    % Title for the graph:
    tit = ['S', num2str(e), ...
        ': Absolute incongruence vs relative response error'];
    % Get the data/stats for the plot:
    statsP2.(fieldName) = exp.gatherPosPlot1(exp.expDataS.(fieldName), flag);
    % And plot:
    exp.plotSpatialData(statsP2.(fieldName), tit);
    % ng('800');
end


%% Plot 3
% For each position, plot proportion of congruent stimuli classified as
% congruent and incongruent classified as congruent
% Average over rate
% Can't average over actual disparity because these aren't equal for each
% position

close all
flag = 1;
flag2 = 2;
for e = 1:exp.expN
    fieldName = ['s', num2str(e)];
    % Title for the graph:
    tit = ['S', num2str(e), ...
        ': Proportion congruent responses, abs diff between A and V'];
    % Get the data/stats for the plot:
    statsP3.(fieldName) = ...
        exp.gatherCongProp(exp.expDataS.(fieldName), flag, flag2);
    % And plot:
    exp.plotCongProp(statsP3.(fieldName), tit);
    
    % ng('1024ThinLines');
end


%% Plot 4
% For each position, plot proportion of congruent stimuli classified as
% congruent and incongruent classified as congruent
% Average over rate
% Can't average over actual disparity because these aren't equal for each
% position

close all
flag = 2;
flag2 = 2;
for e = 1:exp.expN
    fieldName = ['s', num2str(e)];
    % Title for the graph:
    tit = ['S', num2str(e), ...
        ': Proportion congruent responses, relative diff between A and V'];
    % Get the data/stats for the plot:
    statsP4.(fieldName) = ...
        exp.gatherCongProp(exp.expDataS.(fieldName), flag, flag2);
    % And plot:
    exp.plotCongProp(statsP4.(fieldName), tit);
    
    % ng;
end


%% Average plots of P3 and P4 (cong plots)

% Take averages
statsP3Av_tmp = NaN(6,6,5,exp.expN);
statsP4Av_tmp = NaN(6,10,5,exp.expN);
statsP3Av = NaN(6,6,5);
statsP4Av = NaN(6,10,5);
for e = 1:exp.expN
    fieldName = ['s', num2str(e)];
    
    if ~isempty(statsP3.(fieldName))
        statsP3Av_tmp(:,:,:,e) = statsP3.(fieldName);
        statsP4Av_tmp(:,:,:,e) = statsP4.(fieldName);
    end
    
end

% Dims: (stat, diffs at this pos, pos(of other stim), (sub))
% st(1,1) = pos;
% st(2,1) = dif;
% st(3,1) = congProp;
% st(4,1) = std(congLog);
% st(5,1) = sum(congLog);
% st(6,1) = numel(data);

% Copy pos from one subject
statsP3Av(1,:,:) = statsP3Av_tmp(1,:,:,1);
statsP4Av(1,:,:) = statsP4Av_tmp(1,:,:,1);
% Copy diffs from one subject
statsP3Av(2,:,:) = statsP3Av_tmp(2,:,:,2);
statsP4Av(2,:,:) = statsP4Av_tmp(2,:,:,2);
% Take mean congProp across subjects
statsP3Av(3,:,:) = nanmean(statsP3Av_tmp(3,:,:,:), 4);
statsP4Av(3,:,:) = nanmean(statsP4Av_tmp(3,:,:,:), 4);
% Recalculate std
statsP3Av(4,:,:) = nanstd(statsP3Av_tmp(3,:,:,:), 0, 4);
statsP4Av(4,:,:) = nanstd(statsP4Av_tmp(3,:,:,:), 0, 4);
% Sum across sum of congLog
statsP3Av(5,:,:) = sum(statsP3Av_tmp(5,:,:,:), 4);
statsP4Av(5,:,:) = sum(statsP4Av_tmp(5,:,:,:), 4);
% Replace n with exp.expN
statsP3Av(6,:,:) = exp.expN;
statsP4Av(6,:,:) = exp.expN;

% And replot
tit = 'Avg: Proportion congruent responses, abs diff between A and V';
exp.plotCongProp(statsP3Av, tit);

tit = 'Avg: Proportion congruent responses, relative diff between A and V';
exp.plotCongProp(statsP4Av, tit);

clear statsP3Av_tmp statsP4Av_tmp


%% Quick idiot check
% Replot Avg graphs using appended data rather than across subject avg

close all

% P3
flag = 1;
flag2 = 2;
tit = 'Avg: Proportion congruent responses, abs diff between A and V';
% Get the data/stats for the plot:
statsP3AllData = exp.gatherCongProp(exp.expDataAll, flag, flag2);
% And plot:
exp.plotCongProp(statsP3AllData, tit);

% P4
flag = 2;
flag2 = 2;
tit = 'Avg: Proportion congruent responses, relative diff between A and V';
% Get the data/stats for the plot:
statsP4AllData = exp.gatherCongProp(exp.expDataAll, flag, flag2);
% And plot:
exp.plotCongProp(statsP4AllData, tit);


%% Replot raw responses

close all
for e = 1:exp.expN
    fieldName = ['s', num2str(e)];
    exp.replotRaw(exp.expDataS.(fieldName), fieldName)
end


%% Does visual location affect AUDITORY accuracy? - Abs
% Calculate auditory accuracy as function of absolute visual differnece

close all
flag = 1;
for e = 1:exp.expN
    fieldName = ['s', num2str(e)];
    % Title for the graph:
    tit = ['S', num2str(e), ...
        ': Auditory accuracy function of abs visual position'];
    % Get the data/stats for the plot:
    [statsP5.(fieldName), statsP6.(fieldName)] = ...
        exp.gatherAPCvsVL(exp.expDataS.(fieldName), flag);
    % And plot:
    % plotCongProp(statsP4.(fieldName), tit);
    [h1, h2] = ...
        exp.plotAPCvsPL(statsP5.(fieldName), statsP6.(fieldName), tit);
    % ng;
end

% No effect in top plot because effectively averaging out effect described
% in next cell - the data for the 60 bar is data from the inner and outer
% positions only, which have opposite auditory accuracies regarless of the
% visual stimulus. The plot is not useful.

% The second plot removes the effect of average over auditory accuracy
% across space, but does not account for visual direction. Hence still
% averaging over visual accuracy across space, which changes as well. In
% A 67.5 plot, the visual can only be moving back towards the midline. This
% plot isn't usful either, it's too confusing and still obscures too much.


%% Does visual location affect AUDITORY accuracy? - Rel
% Calculate auditory accuracy as function of relative visual differnece

close all
flag = 2;
for e = 1:exp.expN
    fieldName = ['s', num2str(e)];
    % Title for the graph:
    tit = ['S', num2str(e), ...
        ': Auditory accuracy function of relative visual position'];
    % Get the data/stats for the plot:
    [statsP7.(fieldName), statsP8.(fieldName)] = ...
        exp.gatherAPCvsVL(exp.expDataS.(fieldName), flag);
    
    % And plot:
    % plotCongProp(statsP4.(fieldName), tit);
    [h1, h2] = ...
        exp.plotAPCvsPL(statsP7.(fieldName), statsP8.(fieldName), tit);
    % ng;
end

% The avg plot here averages A accuracy across space, but not visual.
% 60 deg bar is highest because this data must all come from the centre
% auditory position. If "0" is the outper position, V can't be +60.
% Conversly, -60 data can only come from "0" on an outer position.
% This plot is again not useful.

% The seond plot here doesn't avarage A or V accuracy across space.
% Gradient of prop correct over accuracy bars indicates effect of visual.
% Eg. For 37.5, -30 visual increases accuracy where as -30 reduces auditory
% accuracy.
% There's an edge effect on errors, so possibly only worth considering
% middle?


%% Create across subject average of
% "Does visual location affect AUDITORY accuracy? - Abs" (P5 and 6)
% Then plot

% NB:
% Position
% Diff
% PC
% PC std
% Error
% Error std
% n

statsP5Av_tmp = NaN([size(statsP5.(fieldName)),exp.expN]);
statsP6Av_tmp = NaN([size(statsP6.(fieldName)),exp.expN]);
statsP5Av = NaN(size(statsP5.(fieldName)));
statsP6Av = NaN(size(statsP6.(fieldName)));
for e = 1:exp.expN
    fieldName = ['s', num2str(e)];
    
    if ~isempty(statsP5.(fieldName))
        statsP5Av_tmp(:,:,e) = statsP5.(fieldName);
        statsP6Av_tmp(:,:,:,e) = statsP6.(fieldName);
    end
end

% Copy pos
statsP5Av(1,:) = statsP5Av_tmp(1,:,7);
statsP6Av(1,:,:) = statsP6Av_tmp(1,:,:,7);
% Copy diff
statsP5Av(2,:) = statsP5Av_tmp(2,:,7);
statsP6Av(2,:,:) = statsP6Av_tmp(2,:,:,7);
% Mean % correct
statsP5Av(3,:) = nanmean(statsP5Av_tmp(3,:,:), 3);
statsP6Av(3,:,:) = nanmean(statsP6Av_tmp(3,:,:,:), 4);
% Recalculate std
statsP5Av(4,:) = nanstd(statsP5Av_tmp(3,:,:), [], 3);
statsP6Av(4,:,:) = nanstd(statsP6Av_tmp(3,:,:,:), [], 4);
% Mean error
statsP5Av(5,:) = nanmean(statsP5Av_tmp(5,:,:),3);
statsP6Av(5,:,:) = nanmean(statsP6Av_tmp(5,:,:,:), 4);
% Recalculate std
statsP5Av(6,:) = nanstd(statsP5Av_tmp(5,:,:),[], 3);
statsP6Av(6,:,:) = nanstd(statsP6Av_tmp(5,:,:,:), [], 4);
% Set n as number of subs
statsP5Av(7,:) = exp.expN;
statsP6Av(7,:,:) = exp.expN;

tit = 'All subs: Auditory accuracy function of abs visual position';
[h1, h2] = exp.plotAPCvsPL(statsP5Av, statsP6Av, tit);


%% Create across subject average of
% "Does visual location affect AUDITORY accuracy? - Rel" (P7 and 8)
% Then plot

% NB:
% Position
% Diff
% PC
% PC std
% Error
% Error std
% n

statsP7Av_tmp = NaN([size(statsP7.(fieldName)),exp.expN]);
statsP8Av_tmp = NaN([size(statsP8.(fieldName)),exp.expN]);
statsP7Av = NaN(size(statsP7.(fieldName)));
statsP8Av = NaN(size(statsP8.(fieldName)));
for e = 1:exp.expN
    fieldName = ['s', num2str(e)];
    if ~isempty(statsP7.(fieldName))
        statsP7Av_tmp(:,:,e) = statsP7.(fieldName);
        statsP8Av_tmp(:,:,:,e) = statsP8.(fieldName);
    end
end

% Copy pos
statsP7Av(1,:) = statsP7Av_tmp(1,:,7);
statsP8Av(1,:,:) = statsP8Av_tmp(1,:,:,7);
% Copy diff
statsP7Av(2,:) = statsP7Av_tmp(2,:,7);
statsP8Av(2,:,:) = statsP8Av_tmp(2,:,:,7);
% Mean % correct
statsP7Av(3,:) = nanmean(statsP7Av_tmp(3,:,:), 3);
statsP8Av(3,:,:) = nanmean(statsP8Av_tmp(3,:,:,:), 4);
% Recalculate std
statsP7Av(4,:) = nanstd(statsP7Av_tmp(3,:,:), [], 3);
statsP8Av(4,:,:) = nanstd(statsP8Av_tmp(3,:,:,:), [], 4);
% Mean error
statsP7Av(5,:) = nanmean(statsP7Av_tmp(5,:,:),3);
statsP8Av(5,:,:) = nanmean(statsP8Av_tmp(5,:,:,:), 4);
% Recalculate std
statsP7Av(6,:) = nanstd(statsP7Av_tmp(5,:,:),[],3);
statsP8Av(6,:,:) = nanstd(statsP8Av_tmp(5,:,:,:), [], 4);
% Set n as number of subs
statsP7Av(7,:) = exp.expN;
statsP8Av(7,:,:) = exp.expN;

tit = 'All subs: Auditory accuracy function of rel visual position';
[h1, h2] = exp.plotAPCvsPL(statsP7Av, statsP8Av, tit);


%% Do linear logistic regression
% Won't plot properly until nSubs > 1

% glmfit - on all data
% CorAud = a + b*ALoc + c*VLoc
glmfit([exp.expDataAll.Position(:,1), exp.expDataAll.Position(:,2)], ...
    exp.expDataAll.ACorrect, 'binomial', 'link', 'logit');

% CorVis = a + b*ALoc + c*VLoc
glmfit([exp.expDataAll.Position(:,1), exp.expDataAll.Position(:,2)], ...
    exp.expDataAll.VCorrect, 'binomial', 'link', 'logit');

close all

% fitglm - per subject
for e = 1:exp.expN
    fieldName = ['s', num2str(e)];
    % Title for the graph:
    tit = ['S', num2str(e), ...
        ': GLM Fits'];
    % Get the data/stats for the plot:
    GLMStats.Linear.(fieldName) = ...
        exp.fitGLMLinear(exp.expDataS.(fieldName));
end

% Dispay subject coeffs and plot average
exp.gatherGLMCoeffs(GLMStats.Linear, {'ACorr', 'VCorr'});


%% Fit same GLM as above, but per-postition

% ?
% Does that actually make sense?


%% Do non-linear (in predictors) logistic regression using fitglm
% Including interactions
% Won't plot properly until nSubs > 1

% CorAud = a + b*ALoc + c*VLoc + d*ALoc*VLoc
% CorVis = a + b*ALoc + c*VLoc + d*ALoc*VLoc

close all

% On each subject
for e = 1:exp.expN
    fieldName = ['s', num2str(e)];
    % Title for the graph:
    tit = ['S', num2str(e), ...
        ': GLM Fits'];
    % Get the data/stats for the plot:
    GLMStats.NLPredictors.(fieldName) = ...
        exp.fitGLM2(exp.expDataS.(fieldName));
end

% Gather and plot coeffs
% statsP10 =
exp.gatherGLMCoeffs(GLMStats.NLPredictors, {'ACorr', 'VCorr'})


%% Is auditory response influenced by A, V, locs?

% AResp = a+ b*ALoc + c*Vloc

close all

% On each subject
for e = 1:exp.expN
    fieldName = ['s', num2str(e)];
    % Title for the graph:
    tit = ['S', num2str(e), ...
        ': GLM Fits'];
    % Get the data/stats for the plot:
    GLMStats.LinearResp.(fieldName) = ...
        exp.fitGLM4(exp.expDataS.(fieldName));
end

% Gather and plot coeffs
% statsP10 =
exp.gatherGLMCoeffs(GLMStats.LinearResp, {'AResp', 'VResp'})


%% Is auditory response influenced by A, V, A*V locs?
% AResp = a+ b*ALoc + c*Vloc + + d*ALoc*VLoc

close all

normX = false;
normY = false;

% On each subject
for e = 1:exp.expN
    fieldName = ['s', num2str(e)];
    % Title for the graph:
    tit = ['S', num2str(e), ...
        ': GLM Fits'];
    % Get the data/stats for the plot:
    GLMStats.NonLinearResp.(fieldName) = ...
        exp.fitGLM4(exp.expDataS.(fieldName), ...
        normX, normY);
end

% Gather and plot coeffs
% statsP10 =
exp.gatherGLMCoeffs(GLMStats.NonLinearResp, {'AResp', 'VResp'})


%% Is auditory response influenced by A, V, A*V locs? - Limited range
% AResp = a+ b*ALoc + c*Vloc + + d*ALoc*VLoc
% As above, but limits data to where either position is 37.5 or -37.5 to
% avoid edge effects?
% And over positions where iteration is and isn't important.



clear abs
close all

normX = false;
normY = false;

% On each subject
for e = 1:exp.expN
    fieldName = ['s', num2str(e)];
    % Title for the graph:
    tit = ['S', num2str(e), ...
        ': GLM Fits'];
    
    useIdx = any([abs(exp.expDataS.(fieldName).Position)==37.5, ...
        abs(exp.expDataS.(fieldName).Position)==22.5, ...
        abs(exp.expDataS.(fieldName).Position)==67.5], 2);
    
    useIdx = any([abs(exp.expDataS.(fieldName).Position)==37.5, ...
        abs(exp.expDataS.(fieldName).Position)==22.5], 2);
    
    useIdx = any([abs(exp.expDataS.(fieldName).Position)==37.5], 2);
    
    % Limit to data where either position is 37.5 or -37.5
    subData = ...
        exp.expDataS.(fieldName)(useIdx,:);
    
    % Get the data/stats for the plot:
    GLMStats.NonLinearResp.(fieldName) = exp.fitGLM4(subData, ...
        normX, normY);
end

% Gather and plot coeffs
% statsP10 =
exp.gatherGLMCoeffs(GLMStats.NonLinearResp, {'AResp', 'VResp'})

