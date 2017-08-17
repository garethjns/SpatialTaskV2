function [summary, data, posAx] = gatherAcrossSubjectAccuracy(stats)
% Gather and plot data for across subject average of accuracy plots
% Stats should be:
% Field - subject
% [pos, numCorrect, n, prop. correct] x diff
% Pos = -67.5:67.5 or 7.5:67.5 (unfolded/folded)
% Diffs = -60:60 or 0:60 (rel/abs)
%
% From these, take prop correct, move to columns (x=location). Put std on
% 3rd dim.

subs = fieldnames(stats);
nSubs = numel(subs);
% Get metadata from first field (will be same for all)
flds = fieldnames(stats);
ff = flds{1};
nPos = size(stats.(ff), 1);
nDiff = size(stats.(ff), 3);

data = NaN(nPos, nDiff, nSubs);
n = 0;
for s = 1:nSubs
    
    subData = stats.(subs{s});
    subAcc = permute(subData(:,4,:), [1,3,2]);
    % If data is empty, don't count n
    if ~all(all(isnan(subAcc)))
        n = n+1;
    end

    data(:,:,s) = subAcc;
end

% Return an x axis for convenience
% (nanmean to get all and avoid NaNs where positon not filled when
% pos/diff combinations didn't exist)
posAx = nanmean(stats.(ff)(:,1,:),3);


%% Takes stats

av = mean(data, 3);
sd = std(data, [], 3);
se = sd/sqrt(n);

summary(:,:,1) = av;
summary(:,:,2) = n;
summary(:,:,3) = sd;
summary(:,:,4) = se;
