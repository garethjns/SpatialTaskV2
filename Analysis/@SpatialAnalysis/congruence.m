function [obj, h] = congruence(obj, plt, subs)
% Parameters are fixed here:
% rel:
% Relative (2) or absolute (1) disparity where everything is
% anchored to V location. -15 means A 15 degrees back
% towards midline.
% Both done.
%
% pec:
% Second input to gaterCongProp. Controls wheher to use
% actual or marked location of visual stim as comparison
% for congruence judgement.
% 1 = Use actual location: Compares A response against
% actual V location, even if V response was elsewhere. Can
% indicate congruenet judgement if responses in different
% locations.
% 2 = Use response location. Ie. Congruent judgement if
% subject response A==V, even if actual location of A or V
% was elsewhere. Ignores localistaion errors.
% Just using pec = 2.
%
% Output to obj.stats.congruence.[abs, rel]

if isempty(plt)
    plt = [true, true];
end
h = gobjects(1, length(plt));

if ~exist('subs', 'var')
    subs = 1:obj.expN;
end
nSubs = numel(subs);

pec = 2;
for e = 1:nSubs
    s = subs(e);
    fieldName = ['s', num2str(s)];
    
    rel = 2;
    obj.stats.congruence.rel.(fieldName) = ...
        obj.gatherCongProp(obj.expDataS.(fieldName), rel, pec);
    
    rel = 1;
    obj.stats.congruence.abs.(fieldName) = ...
        obj.gatherCongProp(obj.expDataS.(fieldName), rel, pec);
end

% Calculate across subject averages and plot
% Take averages (code from initialAnalysis)
statsP3Av_tmp = NaN(6, 6, 5, nSubs);
statsP4Av_tmp = NaN(6, 10, 5, nSubs);
statsP3Av = NaN(6, 6, 5);
statsP4Av = NaN(6, 10, 5);
for e = 1:nSubs
    s = subs(e);
    fieldName = ['s', num2str(s)];
    
    if ~isempty(obj.stats.congruence.abs.(fieldName))
        statsP3Av_tmp(:,:,:,e) = ...
            obj.stats.congruence.abs.(fieldName);
        statsP4Av_tmp(:,:,:,e) = ...
            obj.stats.congruence.rel.(fieldName);
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
statsP3Av(2,:,:) = statsP3Av_tmp(2,:,:,1);
statsP4Av(2,:,:) = statsP4Av_tmp(2,:,:,1);
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
statsP3Av(6,:,:) = nSubs;
statsP4Av(6,:,:) = nSubs;

% Save
obj.stats.congruence.absAV = statsP3Av;
obj.stats.congruence.relAV = statsP4Av;

% Plot
if plt(1)
    tit = ['Avg: Proportion congruent responses,',...
        'abs diff between A and V'];
    h(1) = obj.plotCongProp(statsP3Av, tit);
    
end
if plt(2)
    tit = ['Avg: Proportion congruent responses,', ...
        'relative diff between A and V'];
    h(2) = obj.plotCongProp(statsP4Av, tit);
end
