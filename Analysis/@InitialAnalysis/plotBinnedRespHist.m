function plotBinnedRespHist(data, fold, tit)
% Plot counts of responses in bins
% Haven't added folding yet

% Split respBinAn in to A and V (-85 to 85)
rbnAV = cell2mat(data.respBinAn);
a = rbnAV(1:2:end,:);
v = rbnAV(2:2:end,:);

% Get unique positions -67 to 67
x = unique(data.Position);

% Plot resp ignoring 85 positions
figure
plot(x, sum(a(:,2:end-1), 1))
hold on
plot(x, sum(v(:,2:end-1,:), 1))
legend({'A', 'V'})
title(tit)

% Pointless but interesting
if 0
    av  = zeros(size(a));
    av(logical(a)) = 1;
    av(logical(v)) = 1.5;
    av(a&v) = 3;
    imagesc(av)
    
    surf(av)
    
    avs = sum(av,2)
    [~, idx] = sort(avs)
    
    surf(av(idx,:))
end
