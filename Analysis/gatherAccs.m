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
    VADiffs = abs(vp) - abs(ap);
    % Then flip the sign, so negative is aud back towards midline
    VADiffs = 0 - VADiffs;
    % ie.
    % Given V location, aLoc = VLoc + VADiff
    
    % Recalculate AV Diffs
    AVDiffs = abs(ap) - abs(vp);
    % And invert so negative vis back towards midline
    AVDiffs = 0 - AVDiffs;
    % ie.
    % Given A location, ALoc = VLoc + AVDiff
    
    % [ap(1:5),vp(1:5)]
    % [AVDiffs(1:5), VADiffs(1:5)]
    
    
    % And just keep the unique ones
    diffs = unique([AVDiffs, AVDiffs]);
    
else % Abs
    diffs = unique(allData.Diff);
    AVDiffs = allData.Diff;
    VADiffs = allData.Diff;
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
    
    % Get indexes of this difference from the perspective of each modality
    % Ie. If diff=-60 we want trials where:
    % For auditory response, A is at 67 and V is at 7.5 (dAVIdx)
    % For visual response, V is at 67 and A is at 7.5 (dVAIdx)
    dAVIdx = AVDiffs == diffs(d);
    dVAIdx = VADiffs == diffs(d);
    
    % Fold?
    if fold
        x = abs(allData.Position(dAVIdx,1));
    else
        x = allData.Position(dAVIdx,1);
    end
    
    % Get/count positions available for this diff
    xU = unique(x);
    xN = numel(xU);
    y = allData.ACorrect(dAVIdx);
    
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
        x = abs(allData.Position(dVAIdx,2));
    else
        x = allData.Position(dVAIdx,2);
    end
    xU = unique(x);
    xN = numel(xU);
    y = allData.VCorrect(dVAIdx);
    
    [statsV(placeIdx,1,d), ~, xInt] = unique(x);
    statsV(placeIdx,2,d) = accumarray(xInt, y);
    statsV(placeIdx,3,d) = histcounts(xInt, xN);
    statsV(placeIdx,4,d) = statsV(placeIdx,2,d)./statsV(placeIdx,3,d);

end
