function [obj, h] = accuracy(obj, plt, subs)
% Calculate across-subject accuracy for specified subjects (or
% all)
% Note, for now, writes to and returns object - subsequent runs
% replace stats for previous subset if overwriting calling
% object.
% Plot input should either be empty or contain logicals for
% each plt - eg. [true, true, false, true]

if isempty(plt)
    plt = [true, true, true, true];
end
h = gobjects(6, length(plt));

% Default use all subjects
if ~exist('subs', 'var')
    subs = unique(obj.expDataAll.Subject);
end
nSubs = numel(subs);

% Calculate average accuracy for each subject (folded/unfolded,
% rel/abs)
for e = 1:nSubs
    
    s = subs(e);
    fieldName = ['s', num2str(s)];
    
    rel = false;
    fold = false;
    [statsAcAbs.(fieldName), ...
        statsVcAbs.(fieldName)] = ...
        obj.gatherAccs(obj.expDataS.(fieldName), fold, rel);
    
    rel = false;
    fold = true;
    [statsAcFoldAbs.(fieldName), ...
        statsVcFoldAbs.(fieldName)] = ...
        obj.gatherAccs(obj.expDataS.(fieldName), fold, rel);
    
    rel = true;
    fold = false;
    [statsAcRel.(fieldName), ...
        statsVcRel.(fieldName)] = ...
        obj.gatherAccs(obj.expDataS.(fieldName), fold, rel);
    
    rel = true;
    fold = true;
    [statsAcFoldRel.(fieldName), ...
        statsVcFoldRel.(fieldName)] = ...
        obj.gatherAccs(obj.expDataS.(fieldName), fold, rel);
end

% Save
obj.stats.accuracy.AcAbs.data = statsAcAbs;
obj.stats.accuracy.VcAbs.data = statsVcAbs;
obj.stats.accuracy.AcFoldAbs.data = statsAcFoldAbs;
obj.stats.accuracy.VcFoldAbs.data = statsVcFoldAbs;
obj.stats.accuracy.AcRel.data = statsAcRel;
obj.stats.accuracy.VcRel.data = statsVcRel;
obj.stats.accuracy.AcFoldRel.data = statsAcFoldRel;
obj.stats.accuracy.VcFoldRel.data = statsVcFoldRel;

% Get data for stats
% Cong vs abs incong for unfolded
% Cong vs rel ingong for folded


%% Cong vs abs incong for unfolded

% Get vars and create temp table
vars = {obj.expDataAll.ACorrect, 'ACorrect'; ...
    obj.expDataAll.Position(:,1), 'aPos'; ...
    obj.expDataAll.nEvents, 'Rate'; ...
    obj.expDataAll.Diff == 0, 'Cong';
    obj.expDataAll.Subject, 'Sub'};
t = table(vars{:,1}, 'VariableNames', vars(:,2));
% Run group stats
summaryStatsA = grpstats(t, {'Sub', 'Cong', 'aPos', 'Rate'});

% Do same for visual response
vars = {obj.expDataAll.VCorrect, 'VCorrect'; ...
    obj.expDataAll.Position(:,2), 'vPos'; ...
    obj.expDataAll.nEvents, 'Rate'; ...
    obj.expDataAll.Diff == 0, 'Cong';
    obj.expDataAll.Subject, 'Sub'};
t = table(vars{:,1}, 'VariableNames', vars(:,2));
summaryStatsV = grpstats(t, {'Sub', 'Cong', 'vPos', 'Rate'});


%% Cong vs rel incong for folded

% Recalc diff first
diffAV = 0-(abs(obj.expDataAll.Position(:,1)) - ...
    abs(obj.expDataAll.Position(:,2)));
% Then trinary congruence
cong = diffAV;
cong(cong<0) = -1;
cong(cong==0) = 0;
cong(cong>0) = 1;

% Limit positions to exclude those with only one direction of
% disparity (on A position)
idx = (abs(obj.expDataAll.Position(:,1))>7.5) ...
    & (abs(obj.expDataAll.Position(:,1))<67.5);

% Then create temp table using limited set
% And using relative triany congruence
vars = {obj.expDataAll.ACorrect(idx,1), 'ACorrect'; ...
    obj.expDataAll.Position(idx,1), 'aPos'; ...
    obj.expDataAll.nEvents(idx,1), 'Rate'; ...
    cong(idx,1), 'Cong';
    obj.expDataAll.Subject(idx,1), 'Sub'};
t = table(vars{:,1}, 'VariableNames', vars(:,2));

summaryStatsFoldedA = ...
    grpstats(t, {'Sub', 'Cong', 'aPos', 'Rate'});

% Same for visual response
% Diff is the other way round
diffVA = 0-(abs(obj.expDataAll.Position(:,2)) - ...
    abs(obj.expDataAll.Position(:,1)));
% So is congruence
cong = diffVA;
cong(cong<0) = -1;
cong(cong==0) = 0;
cong(cong>0) = 1;

% Index set around visual location
idx = (abs(obj.expDataAll.Position(:,2))>7.5) ...
    & (abs(obj.expDataAll.Position(:,2))<67.5);

vars = {obj.expDataAll.VCorrect(idx,1), 'VCorrect'; ...
    obj.expDataAll.Position(idx,2), 'vPos'; ...
    obj.expDataAll.nEvents(idx,1), 'Rate'; ...
    cong(idx,1), 'Cong';
    obj.expDataAll.Subject(idx,1), 'Sub'};
t = table(vars{:,1}, 'VariableNames', vars(:,2));

summaryStatsFoldedV = ...
    grpstats(t, {'Sub', 'Cong', 'vPos', 'Rate'});


%% Plot unfolded, abs (with stats)

tit = 'Response accuracy - unfold, abs, across subs';
[summaryA, ~, posAx] = ...
    obj.gatherAcrossSubjectAccuracy(statsAcAbs);
[summaryV, ~, ~] = ...
    obj.gatherAcrossSubjectAccuracy(statsVcAbs);
if plt(1)
    h(1:2,1) = obj.plotAcrossSubjectAccuracy(summaryA, ...
        summaryV, posAx, tit);
end
% A stats
[p, tbl, st] = ...
    anovan(summaryStatsA.mean_ACorrect, ...
    {summaryStatsA.Cong, ...
    summaryStatsA.aPos, ...
    summaryStatsA.Rate}, ...
    'model', 'interaction', ...
    'varname', {'cong', 'aPos', 'Rate'});
% Compare on rate
if plt(1)
    h(3,1) = figure;
    multcompare(st, 'Dimension', 3);
    % Compare on cong
    h(4,1) = figure;
    multcompare(st, 'Dimension', 1);
end
% Save
obj.stats.accuracy.AcAbs.ANOVA.stats = st;
obj.stats.accuracy.AcAbs.ANOVA.p = p;
obj.stats.accuracy.AcAbs.ANOVA.tbl = tbl;

% V stats
[p, tbl, st] = ...
    anovan(summaryStatsV.mean_VCorrect, ...
    {summaryStatsV.Cong, ...
    summaryStatsV.vPos, ...
    summaryStatsV.Rate}, ...
    'model', 'interaction', ...
    'varname', {'cong', 'vPos', 'Rate'});

% Save
obj.stats.accuracy.VcAbs.ANOVA.stats = st;
obj.stats.accuracy.VcAbs.ANOVA.p = p;
obj.stats.accuracy.VcAbs.ANOVA.tbl = tbl;

% Compare on rate
if plt(1)
    h(5,1) = figure;
    multcompare(st, 'Dimension', 3);
    % Compare on cong
    h(6,1) = figure;
    multcompare(st, 'Dimension', 1);
end


%% Plot unfolded, rel (no stats)

tit = 'Response accuracy - unfold, rel, across subs';
[summaryA, ~, posAx] = ...
    obj.gatherAcrossSubjectAccuracy(statsAcRel);
[summaryV, ~, ~] = ...
    obj.gatherAcrossSubjectAccuracy(statsVcRel);
if plt(2)
    h(1:2,2) = obj.plotAcrossSubjectAccuracy(summaryA, ...
        summaryV, posAx, tit);
end


%% Plot folded, rel (stats)

tit = 'Response accuracy - fold, rel, across subs';
[summaryA, ~, posAx] = ...
    obj.gatherAcrossSubjectAccuracy(statsAcFoldRel);
[summaryV, ~, ~] = ...
    obj.gatherAcrossSubjectAccuracy(statsVcFoldRel);
if plt(3)
    h(1:2,3) = obj.plotAcrossSubjectAccuracy(summaryA, ...
        summaryV, posAx, tit);
end

% A stats
[p, tbl, st] = ...
    anovan(summaryStatsFoldedA.mean_ACorrect, ...
    {summaryStatsFoldedA.Cong, ...
    summaryStatsFoldedA.aPos, ...
    summaryStatsFoldedA.Rate}, ...
    'model', 'interaction', ...
    'varname', {'cong', 'aPos', 'Rate'});

% Compare on cong
if plt(3)
    h(3,3) = figure;
    multcompare(st, 'Dimension', 1);
    % Compare on cong vs pos
    h(4,3) = figure;
    multcompare(st, 'Dimension', [1, 2]);
end

% Save
obj.stats.accuracy.AcFoldRel.ANOVA.stats = st;
obj.stats.accuracy.AcFoldRel.ANOVA.p = p;
obj.stats.accuracy.AcFoldRel.ANOVA.tbl = tbl;

% V stats
[p, tbl, st] = ...
    anovan(summaryStatsFoldedV.mean_VCorrect, ...
    {summaryStatsFoldedV.Cong, ...
    summaryStatsFoldedV.vPos, ...
    summaryStatsFoldedV.Rate}, ...
    'model', 'interaction', ...
    'varname', {'cong', 'vPos', 'Rate'});

% Compare on cong
if plt(3)
    h(5,3) = figure;
    multcompare(st, 'Dimension', 1);
    % Compare on cong vs pos
    h(6,3) = figure;
    multcompare(st, 'Dimension', [1, 2]);
end

% Save
obj.stats.accuracy.VcFoldRel.ANOVA.stats = st;
obj.stats.accuracy.VcFoldRel.ANOVA.p = p;
obj.stats.accuracy.VcFoldRel.ANOVA.tbl = tbl;


%% Plot folded, abs (no stats)

tit = 'Response accuracy - fold, abs, across subs';
[summaryA, ~, posAx] = ...
    obj.gatherAcrossSubjectAccuracy(statsAcFoldAbs);
[summaryV, ~, ~] = ...
    obj.gatherAcrossSubjectAccuracy(statsVcFoldAbs);
if plt(4)
    h(1:2,4) = obj.plotAcrossSubjectAccuracy(summaryA, ...
        summaryV, posAx, tit);
end
