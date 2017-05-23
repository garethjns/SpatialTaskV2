function [h] = plotAccs(statsA, statsV, tit)

% Get number of diffs
nDiff = size(statsA, 3);

% Plot each as line and scatter
h1 = gobjects(1, nDiff);
h2 = gobjects(1, nDiff);

h = figure;
% Double width ([BLx, BLy, W, H]) 
h.Position = [h.Position(1), h.Position(2), ...
    h.Position(3)*2, h.Position(4)];

for d = 1:nDiff
    % A
    subplot(1,2,1)
    hold on
    h1(d) = plot(statsA(:,1,d), statsA(:,4,d));
    scatter(statsA(:,1,d), statsA(:,4,d), 'MarkerEdgeColor', h1(d).Color)
    xlabel('Aud physical location, deg')
    ylabel('Aud % correct')
    
    % V
    subplot(1,2,2);
    hold on
    h2(d) = plot(statsV(:,1,d), statsV(:,4,d));
    scatter(statsV(:,1,d), statsV(:,4,d), 'MarkerEdgeColor', h2(d).Color)
    xlabel('Vis physical location, deg')
    ylabel('Vis % correct')
end

% Finish graphs
subplot(1,2,1)
title('Aud')
subplot(1,2,2)
title('Vis')
suptitle(tit)

if nDiff>5
    % Assume rel
    hLeg = legend(h1, {'-60', '-45', '-30', '-15', '0', '15', '30', '45', '60'});
else
    % Assume abs
    hLeg = legend(h1, {'0', '15', '30', '45', '60'});
end

% Add title to legend
hLeg.Title.String = 'AV disparity, deg';
