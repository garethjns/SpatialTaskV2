function h = plotHeatmaps(statsA, statsV, uPos, tit)
% Plot heatmaps from statsA and statsV
% Assume same axis for A (y) and V (x) in uPos


h = figure;
% Double width ([BLx, BLy, W, H]) 
h.Position = [h.Position(1), h.Position(2), ...
    h.Position(3)*2, h.Position(4)];

% Aud
ax = subplot(1,2,1);
imagesc(statsA(:,:,1), [0,1])
ax.YTick = 1:numel(uPos);
ax.YTickLabel = string(uPos);
ax.XTick = 1:numel(uPos);
ax.XTickLabel = string(uPos);
xlabel('APos')
ylabel('VPos')
colorbar
title('Auditory')

% Vis
% TRANSPOSE so v is on x (on image)
ax = subplot(1,2,2);
imagesc(statsV(:,:,1)', [0,1])
ax.YTick = 1:numel(uPos);
ax.YTickLabel = string(uPos);
ax.XTick = 1:numel(uPos);
ax.XTickLabel = string(uPos);
xlabel('VPos')
ylabel('APos')
colorbar
title('Visual')

suptitle(tit)
