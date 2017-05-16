function [statsA, statsV] = gatherAccs(allData)
% Calculate accuracy for visual and auditory responses at each incongruence

if isempty(allData)
    statsA = [];
    statsV = [];
    return
end

diffs = unique(allData.Diff);
nDiff = length(diffs);

x = allData.Position(:,2);
xU = unique(x);
xN = numel(xU);
    
statsA = NaN(xN, 4, nDiff);
statsV = NaN(xN, 4, nDiff);

figure
for d = 1:nDiff
    
    dIdx = allData.Diff == diffs(d);
    
    x = allData.Position(dIdx,1);
    xU = unique(x);
    xN = numel(xU);
    y = allData.ACorrect(dIdx);
    
    % Output here will have 4 columns:
    % [position, number of correct responses, number of trials, proportion of
    % correct responses]

    % Use unique to find unique positions (first output) and also to get a
    % integer representation of these in the original data (instead of the
    % actual values, third output)
    [statsA(1:xN,1,d), ~, xInt] = unique(x);
    
    % Use accumarry to count the numnber of correct responses, using the
    % interger representation (xInt) of the positions as the key
    statsA(1:xN,2,d) = accumarray(xInt, y);
    
    % Use histc to count the number of trials at each position
    statsA(1:xN,3,d) = histc(xInt, xN);
    
    % Finally divide the number of correct responses at each location by the
    % number of trials to calcualte the proportion of correct responses
    statsA(:,4,d) = statsA(:,2,d)./statsA(:,3,d);
    
    
    % V
    x = allData.Position(dIdx,2);
    xU = unique(x);
    xN = numel(xU);
    y = allData.VCorrect(dIdx);
    
    [statsV(1:xN,1,d), ~, xInt] = unique(x);
    statsV(1:xN,2,d) = accumarray(xInt, y);
    statsV(1:xN,3,d) = histc(xInt, xN);
    statsV(:,4,d) = statsV(:,2,d)./statsV(:,3,d);
    
    subplot(1,2,1)
    hold on
    scatter(statsA(:,1,d), statsA(:,4,d))
    h1(d) = plot(statsA(:,1,d), statsA(:,4,d));
    subplot(1,2,2);
    hold on
    scatter(statsV(:,1,d), statsV(:,4,d))
    h2(d) = plot(statsV(:,1,d), statsV(:,4,d));
    
    
end

subplot(1,2,1)
title('Aud')
subplot(1,2,2)
title('Vis')
suptitle('Accuracy')
legend(h1, string(diffs));