

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

% Data\ is in directory above.
dPath = [fileparts(pwd), '\Data\'];

% Historical list of exps - add new to end. Will be reassigned numbers in
% processing.
% Paths can be changed here
exp.s1 = [dPath, 'Nicole\07-Apr-2016 16_24_11\SpatialCapture_Nicole.mat'];
exp.s2 = [dPath, 'Data\Gareth\21-Apr-2016 15_56_01\SpatialCapture_Gareth.mat'];
exp.s3 = [dPath, 'Data\2\26-Apr-2016 17_04_28\SpatialCapture_2.mat'];
exp.s4 = [dPath, 'Data\4.2\08-Jul-2016 12_45_35\SpatialCapture_4.2.mat'];
exp.s5 = [dPath, 'Data\5.2\08-Jul-2016 15_03_32\SpatialCapture_5.2.mat'];
exp.s6 = [dPath, 'Data\6.1\08-Jul-2016 16_19_28\SpatialCapture_6.1.mat'];
% exp.s7 = 'Data\7\23-Jan-2017 15_16_25\SpatialCapture_7.mat';
% exp.s8 = 'Data\8\02-Feb-2017 10_39_19\SpatialCapture_8.mat';
exp.s7 = [dPath, 'Data\GarethEye\21-Feb-2017 15_53_30\SpatialCapture_GarethEye.mat'];
exp.s8 = [dPath, 'Data\ShriyaEye2\03-Mar-2017 14_55_20\SpatialCapture_ShriyaEye2.mat'];
% exp.s9 = 'Data\KatEye1\15-Mar-2017 12_32_08\SpatialCapture_KatEye1.mat';
exp.s9 = [dPath, 'Data\GarethEye3\22-Mar-2017 11_04_38\SpatialCapture_GarethEye3.mat'];
% Corresponding list of eyedata paths
eye.s1 = '';
eye.s2 = '';
eye.s3 = '';
eye.s4 = '';
eye.s5 = '';
eye.s6 = '';
% eye.s7 = 'Data\7\23-Jan-2017 15_16_25\7_ProcessedGaze.mat';
% eye.s8 = 'Data\8\02-Feb-2017 10_39_19\8.p.mat';
eye.s7 = ''; % Recording, but time sync failed
eye.s8 = [dPath, 'Data\ShriyaEye2\03-Mar-2017 14_55_20\ShriyaEye2.mat'];
% eye.s9 = 'Data\KatEye1\15-Mar-2017 12_32_08\KatEye1.mat';
eye.s9 = [dPath, 'Data\GarethEye3\22-Mar-2017 11_04_38\GarethEye3.mat'];

eN = numel(fields(exp));

allData = [];
clear data
for e = 1:eN
    % Get subject field
    fn = exp.(['s', num2str(e)]);
    disp(['Loading ', fn])
    
    % Load psychophysics data
    a = load(fn);
    n = height(a.stimLog);
    
    % Process data according to version subject was run on
    % (swithces not mutually exclusive)
    % V1: S1 and S2
    switch fn
        case {exp.s1, exp.s2} 
            % These two lack two columns present in later exps, add dummies
            % PossBinLog and PossBin
            
            poss = [-82.5, unique(a.stimLog.Position)', 82.5];
            
            a.stimLog.PosBinLog = cell(n,1);
            a.stimLog.PosBin = NaN(n,2);
            
            for t = 1:n
                a.stimLog.PosBinLog{t} = ...
                    [a.stimLog.Position(t,1) == poss; ...
                    a.stimLog.Position(t,2) == poss];
                
                a.stimLog.PosBin(t,:) = ...
                    [find(a.stimLog.PosBinLog{t}(1,:));...
                    find(a.stimLog.PosBinLog{t}(2,:))];
            end
    end
    
    % V2: S1-6
    switch fn
        case {exp.s1, exp.s2, exp.s3, exp.s4, exp.s5, exp.s6}
            % These need dummy timing columns
            n = height(a.stimLog);
            a.stimLog.timeStamp = NaN(n, 2);
            a.stimLog.startClock = repmat([1900, 1, 1, 1, 1, 1],n,1);
            a.stimLog.endClock = repmat([1900, 1, 1, 1, 1, 1],n,1);
    end
    
    % V3: - add eyedata if available
    % If not, adds placeholders
    % Available S7 onwards, but run for all
    switch fn 
        case {exp.s1, exp.s2, exp.s3, exp.s4, exp.s5, exp.s6, exp.s7}
            % Not using eye data
            % Give addEyeData2 some dummy params
            a.params = [];

        otherwise % Fututre exps (8 onwards)
            % From here, timesync info is available in params. Need to load
            % this. 
            % Not using eye data from before this.
            % stimlog should contains gaze, not correctedGaze anymore.
            
            % No additional processing here at the moment
            % - handled in addEyeData2
    end
    
    plotOn = true;
    a.stimLog = addEyeData2(a.stimLog, ...
        eye.(['s', num2str(e)]), ...
        a.params, ...
        plotOn);
    
    % All subjects
    % Add a "correct" and "error" columns
    for r = 1:n
        a.stimLog.ACorrect(r,1) = all( a.stimLog.respBinAN{r,1}(1,:) ...
            ==  a.stimLog.PosBinLog{r,1}(1,:));
        a.stimLog.VCorrect(r,1) = all( a.stimLog.respBinAN{r,1}(2,:) ...
            ==  a.stimLog.PosBinLog{r,1}(2,:));
        
        a.stimLog.AError(r,1) = (find( a.stimLog.respBinAN{r,1}(1,:)) ...
            - find( a.stimLog.PosBinLog{r,1}(1,:))) * 15;
        a.stimLog.VError(r,1) = (find( a.stimLog.respBinAN{r,1}(2,:)) ...
            - find( a.stimLog.PosBinLog{r,1}(2,:))) * 15;
    end
    
    % Save subject data in structre and append to allData table
    data.(['s', num2str(e)]) = a.stimLog;
    allData = [allData; a.stimLog]; %#ok<AGROW>
end

figure
scatter(abs(allData.Position(:,1)), allData.AError)
hold on
scatter(abs(allData.Position(:,2)), allData.VError)
legend({'Auditory', ' Visual'})
xlabel('Position')
ylabel('Error')


%% Apply gaze threshold 
% If threshold set, trials will be dropped where onSurfProp is below
% threshold, including if no eye data is available (ie subs 1-6).
% Create indexes for allData and for data.sx

% Which onSurfProp to use?
osp = 'onSurfProp';
% Or
% osp = 'onSurfPropCorrectedED'; - removed

thresh = 0.7;
% thresh = 0; % Turn off

allOK = [];
for e = 1:eN
   fieldName = ['s', num2str(e)];
   
   [data.(fieldName).onSurf, rs1, rs2] = ...
       eyeIndex(data.(fieldName), osp, thresh);
   
   dataFilt.(fieldName) = data.(fieldName)(data.(fieldName).onSurf,:);
   % Lazy
   allOK = [allOK; data.(fieldName).onSurf]; %#ok<AGROW>
   
   disp('----')
   disp(fieldName)
   disp(rs1)
   disp(rs2)
   disp('----')
end

allData.onSurf = allOK;

% Continue with data passing thresh only
dataOrig = data;
data = dataFilt;
allData = allData(allData.onSurf==1,:);
clear dataFilt


%% Plot 1
% For each position, plot absolute error against abosolute difference
% Fold space (and again around actual visual location)
% Average over rate

close all
flag = 1; % This sets an option for the function below
for e = 1:eN
    fieldName = ['s', num2str(e)];
    
    % Title for the graph:
    tit = ['S', num2str(e), ...
        ': Absolute incongruency vs absolute response error'];
    % Get the data/stats for the plot:
    statsP1.(fieldName) = gatherPosPlot1(data.(fieldName), flag);
    % And plot:
    plotSpatialData(statsP1.(fieldName), tit);
    % ng;
end


%% Plot 2
% For each position, plot absolute error against relative difference
% Fold space. Relative error: - = back towards midline
% Average over rate

close all
flag = 2;
for e = 1:eN
    fieldName = ['s', num2str(e)];
    % Title for the graph:
    tit = ['S', num2str(e), ...
        ': Absolute incongruency vs relative response error'];
    % Get the data/stats for the plot:
    statsP2.(fieldName) = gatherPosPlot1(data.(fieldName), flag);
    % And plot:
    plotSpatialData(statsP2.(fieldName), tit);
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
for e = 1:eN
    fieldName = ['s', num2str(e)];
    % Title for the graph:
    tit = ['S', num2str(e), ...
        ': Proportion congruent responses, abs diff between A and V'];
    % Get the data/stats for the plot:
    statsP3.(fieldName) = gatherCongProp(data.(fieldName), flag, flag2);
    % And plot:
    plotCongProp(statsP3.(fieldName), tit);
    
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
for e = 1:eN
    fieldName = ['s', num2str(e)];
    % Title for the graph:
    tit = ['S', num2str(e), ...
        ': Proportion congruent responses, relative diff between A and V'];
    % Get the data/stats for the plot:
    statsP4.(fieldName) = gatherCongProp(data.(fieldName), flag, flag2);
    % And plot:
    plotCongProp(statsP4.(fieldName), tit);
    
    % ng;
end


%% Average plots of P3 and P4 (cong plots)

% Take averages
statsP3Av_tmp = NaN(6,6,5,eN);
statsP4Av_tmp = NaN(6,10,5,eN);
statsP3Av = NaN(6,6,5);
statsP4Av = NaN(6,10,5);
for e = 1:eN
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
% Replace n with eN
statsP3Av(6,:,:) = eN;
statsP4Av(6,:,:) = eN;

% And replot
tit = 'Avg: Proportion congruent responses, abs diff between A and V';
plotCongProp(statsP3Av, tit);

tit = 'Avg: Proportion congruent responses, relative diff between A and V';
plotCongProp(statsP4Av, tit);

clear statsP3Av_tmp statsP4Av_tmp


%% Quick idiot check
% Replot Avg graphs using appended data rather than across subject avg

close all

% P3
flag = 1;
flag2 = 2;
tit = 'Avg: Proportion congruent responses, abs diff between A and V';
% Get the data/stats for the plot:
statsP3AllData = gatherCongProp(allData, flag, flag2);
% And plot:
plotCongProp(statsP3AllData, tit);

% P4
flag = 2;
flag2 = 2;
tit = 'Avg: Proportion congruent responses, relative diff between A and V';
% Get the data/stats for the plot:
statsP4AllData = gatherCongProp(allData, flag, flag2);
% And plot:
plotCongProp(statsP4AllData, tit);


%% Replot raw responses

close all
for e = 1:eN
    fieldName = ['s', num2str(e)];
    replotRaw(data.(fieldName), fieldName)
end


%% Does visual location affect AUDITORY accuracy? - Abs
% Calculate auditory accuracy as function of absolute visual differnece

close all
flag = 1;
for e = 1:eN
    fieldName = ['s', num2str(e)];
    % Title for the graph:
    tit = ['S', num2str(e), ...
        ': Auditory accuracy function of abs visual position'];
    % Get the data/stats for the plot:
    [statsP5.(fieldName), statsP6.(fieldName)] = ...
        gatherAPCvsVL(data.(fieldName), flag);
    % And plot:
    % plotCongProp(statsP4.(fieldName), tit);
    [h1, h2] = plotAPCvsPL(statsP5.(fieldName), statsP6.(fieldName), tit);
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
for e = 1:eN
    fieldName = ['s', num2str(e)];
    % Title for the graph:
    tit = ['S', num2str(e), ...
        ': Auditory accuracy function of relative visual position'];
    % Get the data/stats for the plot:
    [statsP7.(fieldName), statsP8.(fieldName)] = ...
        gatherAPCvsVL(data.(fieldName), flag);
    % And plot:
    % plotCongProp(statsP4.(fieldName), tit);
    [h1, h2] = plotAPCvsPL(statsP7.(fieldName), statsP8.(fieldName), tit);
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

statsP5Av_tmp = NaN([size(statsP5.(fieldName)),eN]);
statsP6Av_tmp = NaN([size(statsP6.(fieldName)),eN]);
statsP5Av = NaN(size(statsP5.(fieldName)));
statsP6Av = NaN(size(statsP6.(fieldName)));
for e = 1:eN
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
statsP5Av(7,:) = eN;
statsP6Av(7,:,:) = eN;

tit = 'All subs: Auditory accuracy function of abs visual position';
[h1, h2] = plotAPCvsPL(statsP5Av, statsP6Av, tit);


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

statsP7Av_tmp = NaN([size(statsP7.(fieldName)),eN]);
statsP8Av_tmp = NaN([size(statsP8.(fieldName)),eN]);
statsP7Av = NaN(size(statsP7.(fieldName)));
statsP8Av = NaN(size(statsP8.(fieldName)));
for e = 1:eN
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
statsP7Av(7,:) = eN;
statsP8Av(7,:,:) = eN;

tit = 'All subs: Auditory accuracy function of rel visual position';
[h1, h2] = plotAPCvsPL(statsP7Av, statsP8Av, tit);


%% Do linear logistic regression
% Won't plot properly until nSubs > 1

% glmfit - on all data
% CorAud = a + b*ALoc + c*VLoc
glmfit([allData.Position(:,1), allData.Position(:,2)], ...
    allData.ACorrect, 'binomial', 'link', 'logit');

% CorVis = a + b*ALoc + c*VLoc
glmfit([allData.Position(:,1), allData.Position(:,2)], ...
    allData.VCorrect, 'binomial', 'link', 'logit');

close all

% fitglm - per subject
for e = 1:eN
    fieldName = ['s', num2str(e)];
    % Title for the graph:
    tit = ['S', num2str(e), ...
        ': GLM Fits'];
    % Get the data/stats for the plot:
    GLMStats.Linear.(fieldName) = fitGLMLinear(data.(fieldName));
end

% Dispay subject coeffs and plot average
gatherGLMCoeffs(GLMStats.Linear, {'ACorr', 'VCorr'});


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
for e = 1:eN
    fieldName = ['s', num2str(e)];
    % Title for the graph:
    tit = ['S', num2str(e), ...
        ': GLM Fits'];
    % Get the data/stats for the plot:
    GLMStats.NLPredictors.(fieldName) = fitGLM2(data.(fieldName));
end

% Gather and plot coeffs
% statsP10 =
gatherGLMCoeffs(GLMStats.NLPredictors, {'ACorr', 'VCorr'})


%% Is auditory response influenced by A, V, locs?

% AResp = a+ b*ALoc + c*Vloc

close all

% On each subject
for e = 1:eN
    fieldName = ['s', num2str(e)];
    % Title for the graph:
    tit = ['S', num2str(e), ...
        ': GLM Fits'];
    % Get the data/stats for the plot:
    GLMStats.LinearResp.(fieldName) = fitGLM4(data.(fieldName));
end

% Gather and plot coeffs
% statsP10 =
gatherGLMCoeffs(GLMStats.LinearResp, {'AResp', 'VResp'})


%% Is auditory response influenced by A, V, A*V locs?
% AResp = a+ b*ALoc + c*Vloc + + d*ALoc*VLoc

close all

% On each subject
for e = 1:eN
    fieldName = ['s', num2str(e)];
    % Title for the graph:
    tit = ['S', num2str(e), ...
        ': GLM Fits'];
    % Get the data/stats for the plot:
    GLMStats.NonLinearResp.(fieldName) = fitGLM4(data.(fieldName));
end

% Gather and plot coeffs
% statsP10 =
gatherGLMCoeffs(GLMStats.NonLinearResp, {'AResp', 'VResp'})