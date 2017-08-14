function [H1, H2] = ...
    plotAccuracy(obj, summaryA, summaryV, fold, posAx, tit)
% Plot across subject average with error bars
% Summary is pos x diff x stat
% Stat: 1 = % Correct, 2 = n, 3 = SD, 4 = SE
% pos labels should be included in posAx
% diff labels are coded in legend setting

%


%% Plot - lines/scatter

% Detect if folded or unfolded data
summaryA.aPos

% Set diff labels for legend
if nPoss>5
    % Assume rel
    diffs = [-60, -45, -30, -15, ...
        0, 15, 30, 45, 60];
else
    % Assume abs
    diffs = [0, 15, 30, 45, 60];
end

% Plot each as line and scatter
h1 = gobjects(1, nDiff);
h2 = gobjects(1, nDiff);

H1 = figure;
% Double width ([BLx, BLy, W, H])
H1.Position = [H1.Position(1), H1.Position(2), ...
    H1.Position(3)*2, H1.Position(4)];

for d = 1:nDiff
    
    % Style lines
    % -- for "other stim moving IN" ie. diff -
    if diffs(d)>=0
        ls = '-';
    else
        ls = '--';
    end
    
    % Thicker line for AV congruent
    if diffs(d)==0
        lw = 1.6;
    else
        lw = 1;
    end
    
    % A
    subplot(1,2,1)
    hold on
    h1(d) = errorbar(posAx, summaryA(:,d,1), summaryA(:,d,4), ...
        'LineStyle', ls, 'LineWidth', lw);
    scatter(posAx, summaryA(:,d,1), 'MarkerEdgeColor', h1(d).Color)
    xlabel('Aud physical location, deg')
    ylabel('Aud % correct')
    
    % V
    subplot(1,2,2);
    hold on
    h2(d) = errorbar(posAx, summaryV(:,d,1), summaryV(:,d,4), ...
        'LineStyle', ls, 'LineWidth', lw);
    scatter(posAx, summaryV(:,d,1), 'MarkerEdgeColor', h2(d).Color)
    xlabel('Vis physical location, deg')
    ylabel('Vis % correct')
end

% Finish graphs
subplot(1,2,1)
title('Aud')
subplot(1,2,2)
title('Vis')
suptitle(tit)

% Legend
hLeg = legend(h1, num2str(diffs'));
% Add title to legend
hLeg.Title.String = 'AV disparity, deg';
hLeg = legend(h2, num2str(diffs'));
% Add title to legend
hLeg.Title.String = 'AV disparity, deg';


%% Plot - heatmap version

H2 = figure;
% Double width ([BLx, BLy, W, H])
H2.Position = [H2.Position(1), H2.Position(2), ...
    H2.Position(3)*2, H2.Position(4)];

% A
ax = subplot(1,2,1);
imagesc(summaryA(:,:,1)')
ax.XTick = 1:numel(posAx);
ax.XTickLabel = string(posAx);
ax.YTick = 1:nDiff;
ax.YTickLabel = string(diffs);
ylabel('AV disparity')
xlabel('A Position')

% V
ax = subplot(1,2,2);
imagesc(summaryV(:,:,1)')
ax.XTick = 1:numel(posAx);
ax.XTickLabel = string(posAx);
ax.YTick = 1:nDiff;
ax.YTickLabel = string(diffs);
ylabel('AV disparity')
xlabel('V Position')

% Finish graphs
subplot(1,2,1)
title('Aud')
subplot(1,2,2)
title('Vis')
suptitle(tit)

