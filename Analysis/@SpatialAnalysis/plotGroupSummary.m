function [obj, h] = plotGroupSummary(obj, group, type, name)
% Handle redoing .accuray, .congruence, .midError on subset
% - eg. integrators (vs non-integrators)
% Take tempoary objects from above methods and save to
% mainobject in sensible place
% Group should be logical of obj.expN x 1
% Type specifies method to apply

if ~exist('type', 'var')
    type = 'Acc';
end
if ~exist('name', 'var')
    name = 'genericSubSet';
end

switch lower(type)
    case {'accuracy', 'acc'}
        statsMethod = @obj.accuracy;
        statsField = 'accuracy';
        plt = [false, false, true, false];
    case {'congruence', 'cong'}
        statsMethod = @obj.congruence;
        statsField = 'congruence';
        plt = [true, true];
    case {'miderror', 'me'}
        statsMethod = @obj.midError;
        statsField = 'midError';
        plt = [true, false, false];
end

% Split groups
subs = unique(obj.expDataAll.Subject);
subs1 = subs(group);

% Apply method
if sum(subs1)>0
    [g1Obj, h] = statsMethod(plt, subs1);
else
    disp('Group is empty')
    return
end

% Extract stats from tempoary objects and save
obj.statsSubsets.(type).(name).group1 = ...
    g1Obj.stats.(statsField);
obj.statsSubsets.(type).(name).group = group;
