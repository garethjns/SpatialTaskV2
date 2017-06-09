function [dataA, dataV, pAx, dAx] = ...
    gatherDispHists(allData, rel, pInc)
% Get response error for each modality in folded space, for each disparity
% from perspective of that modality (ie. recalcuated, not .Diff column).

if isempty(allData)
    dataA = [];
    datasV = [];
    return
end

% Not implemented - no point?
binned = false;

% If empty, use all
if isempty(pInc)
    % Includes negatives below
    pInc = [7.5, 22.5, 37.5, 52.5, 67.5];
end

% Use binned or unbinned error?
if binned
    % Use AError and VError - ready to use binned error
else
    % Use unbinned error - .diffAngle?
end

% Abs or relative?
% Need both perspectives here
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

% Use specified postions
nPoss = length(pInc);

% Preallocate
dataA = NaN(round(height(allData)/2), nPoss, nDiff);
dataV = NaN(round(height(allData)/2), nPoss, nDiff);

% For each position
for p = 1:nPoss
    % Get index for A and V and fold space
    pIdxA = abs(allData.Position(:,1)) == pInc(p);
    pIdxV = abs(allData.Position(:,2)) == pInc(p);
    
    % For each diff
    for d = 1:length(diffs)
        
        % Get indexes and data subsets
        % pIdxA = ismember(allData.Position(:,1), [pInc, 0-pInc]);
        % pIdxV = ismember(allData.Position(:,2), [pInc, 0-pInc]);
        
        % Get diff indexes for each modality
        dAVIdx = AVDiffs == diffs(d);
        dVAIdx = VADiffs == diffs(d);
        
        % Get data subsets using dIdx and pIdx
        subsetA = allData(dAVIdx & pIdxA,:);
        subsetV = allData(dVAIdx & pIdxV,:);
        
        if binned
            % Not implemented
        else
            % Collect raw data for use with histogram or ksdensity
            
            % Extract the diff angle column. This is {:}[2x1].
            % Convert to mat - appends all together
            matA = cell2mat(subsetA.diffAngle);
            matV = cell2mat(subsetV.diffAngle);
            
            % Save
            dataA(1:length(matA(1:2:end)),p,d) = matA(1:2:end);
            dataV(1:length(matV(2:2:end)),p,d) = matV(2:2:end);
        end
    end
end

% Drop NaNs where possible
dataA = dataA(~all(all(isnan(dataA),2),3),:,:);
dataV = dataV(~all(all(isnan(dataV),2),3),:,:);

% Axes
pAx = pInc;
dAx = diffs;
