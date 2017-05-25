function [dataA, dataV, pAx, dAx] = ...
    gatherDispHists(allData, rel, binned, pInc)

if isempty(allData)
    statsA = [];
    statsV = [];
    return
end

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


% Fold space
x = abs(allData.Position(:,2));

% Get/count all positions
xUAll = unique(x);
xNAll = numel(xUAll);

% Use specified postions
nPoss = length(pInc);

% Preallocate
dataA = NaN(height(allData), nPoss, nDiff);
dataV = NaN(height(allData), nPoss, nDiff);



for p = 1:nPoss
    pIdxA = abs(allData.Position(:,1)) == pInc(p);
    pIdxV = abs(allData.Position(:,2)) == pInc(p);
    
    for d = 1:length(diffs)
        
        
        % Get indexes and data subsets
        % pIdxA = ismember(allData.Position(:,1), [pInc, 0-pInc]);
        % pIdxV = ismember(allData.Position(:,2), [pInc, 0-pInc]);
        
        dAVIdx = AVDiffs == diffs(d);
        subsetA = allData(dAVIdx & pIdxA,:);
        dVAIdx = VADiffs == diffs(d);
        subsetV = allData(dVAIdx & pIdxV,:);
        
        if binned
            
        else
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