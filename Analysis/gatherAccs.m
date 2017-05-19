function [statsA, statsV] = gatherAccs(allData, fold, rel)
% Calculate accuracy for visual and auditory responses at each incongruence

if isempty(allData)
    statsA = [];
    statsV = [];
    return
end

% Abs or relative
if rel
   % Code from gatherCongProp
    vp = abs(allData.Position(:,2));
    % Get all the absolute auditory positions
    ap = abs(allData.Position(:,1));
    
    % Recaulcaute the between these (not the abs difference)
    allDiffs = abs(vp) - abs(ap);
    % Then flip the sign, so negative is back towards midline
    allDiffs = 0 - allDiffs;
    
    % And just keep the unique ones
    diffs = unique(allDiffs);
    
    % Replace allData's diffs column with this one for indexing in loop
    allData.Diff = allDiffs;
else % Abs
    diffs = unique(allData.Diff);
end
nDiff = length(diffs);

% All space or fold space
if fold
    x = abs(allData.Position(:,2));
else    
    x = allData.Position(:,2);
end
% Get/count all positions
xUAll = unique(x);
xNAll = numel(xUAll);

% Preallocate
statsA = NaN(xNAll, 4, nDiff);
statsV = NaN(xNAll, 4, nDiff);

for d = 1:nDiff
    
    % Get index of this difference
    dIdx = allData.Diff == diffs(d);
    
    % Fold?
    if fold
        x = abs(allData.Position(dIdx,1));
    else
        x = allData.Position(dIdx,1);
    end
    
    % Get/count positions available for this diff
    xU = unique(x);
    xN = numel(xU);
    y = allData.ACorrect(dIdx);
    
    % Get index to place these available values in to stats matrix
    placeIdx = ismember(xUAll, xU);
    
    % Output here will have 4 columns:
    % [position, number of correct responses, number of trials, proportion of
    % correct responses]

    % Use unique to find unique positions (first output) and also to get a
    % integer representation of these in the original data (instead of the
    % actual values, third output)
    [statsA(placeIdx,1,d), ~, xInt] = unique(x);
    
    % Use accumarry to count the numnber of correct responses, using the
    % interger representation (xInt) of the positions as the key
    statsA(placeIdx,2,d) = accumarray(xInt, y);
    
    % Use histc to count the number of trials at each position
    statsA(placeIdx,3,d) = histcounts(xInt, xN)';
    
    % Finally divide the number of correct responses at each location by 
    % the number of trials to calcualte the proportion of correct responses
    statsA(placeIdx,4,d) = statsA(placeIdx,2,d)./statsA(placeIdx,3,d);
    
    % V
    % Run same as above for visual response
    if fold
        x = abs(allData.Position(dIdx,2));
    else
        x = allData.Position(dIdx,2);
    end
    xU = unique(x);
    xN = numel(xU);
    y = allData.VCorrect(dIdx);
    
    [statsV(placeIdx,1,d), ~, xInt] = unique(x);
    statsV(placeIdx,2,d) = accumarray(xInt, y);
    statsV(placeIdx,3,d) = histcounts(xInt, xN);
    statsV(placeIdx,4,d) = statsV(placeIdx,2,d)./statsV(placeIdx,3,d);

end
