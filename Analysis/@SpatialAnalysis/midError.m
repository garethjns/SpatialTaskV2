function [obj, h] = midError(obj, plt, subs)
% Plt is [(rel, yNorm), rel, abs].
% Runs per sub and saves stats.
% Runs on all data (using all subs or subset) and calculates
% error from this (rather than doing across-subject average).

if isempty(plt)
    plt = [true, true, true];
end
h = gobjects(1, length(plt));

if ~exist('subs', 'var')
    subs = unique(obj.expDataAll.Subject);
end
nSubs = numel(subs);

for e = 1:nSubs
    
    s = subs(e);
    fieldName = ['s', num2str(s)];
    
    % Get data
    [A, V] = ...
        obj.gatherMidHist(obj.expDataS.(fieldName));
    
    obj.stats.midError.(fieldName).A = A;
    obj.stats.midError.(fieldName).V = V;
end

% All data
% Set index of subjects to use
subIdx = ismember(obj.expDataAll.Subject, subs);
% Calculate error hist directly on this data
[A, V] = obj.gatherMidHist(obj.expDataAll(subIdx,:));

% Even if run on subset, save to "All" field. Leave calling
% function to handle object (eg. see plotGroupSummary())
obj.stats.midError.All.A = A;
obj.stats.midError.All.V = V;

if plt(1)
    abs = false;
    tit = 'All subjects, xNorm, yNorm';
    h(1) = obj.plotMidError(A, V, tit, abs);
end
if plt(2)
    abs = false;
    tit = 'All subjects, xNorm';
    h(2) = obj.plotMidError(A, V, tit, abs, true, false);
end
if plt(3)
    abs = true;
    tit = 'All subjects, xNorm, abs';
    h(3) = obj.plotMidError(A, V, tit, abs, true, false);
end
