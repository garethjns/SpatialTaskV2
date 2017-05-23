function [statsA, statsV, uPos] = gatherPCHeatmaps(allData, fold)
% Gather data to plot two heatmaps. One for Aud response, one for Vis
% response. x = A, y = V Pos. 3rd dim: 1 = %, 2 = n)
% Also returns seperate axis for plotting (instead of in stats matrix).
% Same for A and V at the moment - shouldn't need changing.

% Check for data
if isempty(allData)
    statsA = [];
    statsV = [];
    return
end

% Fold space ?
if fold
    % Get abs a and v positions
    vp = abs(allData.Position(:,2));
    % Get all the absolute auditory positions
    ap = abs(allData.Position(:,1));
else
    % Use relative positions as they are
    vp = allData.Position(:,2);
    ap = allData.Position(:,1);
end

% Assuming same positions for A and V
uPos = unique(ap);
nPos = numel(unique(uPos));

% Preallocate
% 3rd dim, 1 = % correct, 2 = n
statsA = NaN(nPos, nPos, 2);
statsV = NaN(nPos, nPos, 2);

for y = 1:nPos % y, V
    
    vPos = uPos(y);
    vIdx = vp == vPos;
    
    for x = 1:nPos % x, A
        aPos = uPos(x);
        aIdx = ap == aPos;
        
        data = allData(vIdx & aIdx,:);
        
        n = height(data);
        statsA(y,x,1) = sum(data.ACorrect)/n;
        statsV(y,x,1) = sum(data.VCorrect)/n;
        
        statsA(y,x,2) = n;
        statsV(y,x,2) = n;
        
    end
end
