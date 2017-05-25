function plotDispHists(dataA, dataV, pAx, dAx, normX, normY, tit)

nPoss = length(pAx);
nDiff = length(dAx);

yLim = 0.1;
xLim = 20;

colours = colormap(parula(nDiff));

figure
for p = 1:nPoss
    
    subplot(2,nPoss, p)
    
    [xLim, yLim] =ksPlots(dAx, dataA(:,p,:), colours, xLim, yLim);
    title(string(pAx(p)));
    if p==1
        ylabel('Proportion')
    end
    
    subplot(2,nPoss, nPoss+p)
    [xLim, yLim] =ksPlots(dAx, dataV(:,p,:), colours, xLim, yLim);
    
    title(string(pAx(p)));
    if p==1
        ylabel('Proportion')
    end
    
    
end

% Finish plots
for p = 1:2*nPoss
    subplot(2,nPoss,p)
    
    if normY
        ylim([0, yLim*1.05]);
    end
    
    if normX
        
        xlim([0-xLim*0.5, xLim*0.5]);
    end
    
end

suptitle(tit)

function [xLim, yLim] = ksPlots(dAx, data, colours, xLim, yLim)
nDiff = length(dAx);

hold on
leg = [];
for d = 1:nDiff
    % Run ksdensiy one by one to avoid empty errors
    n = sum(~isnan(data(:,1,d)));
    if n>0
        [line, x] = ksdensity(data(1:n,1,d));
        plot(x, line, 'Color', colours(d,:))
        if max(line)>yLim
            yLim = max(line);
        end
        if max(abs(x))>xLim
            xLim = max(abs(x));
        end
        
        leg = [leg, dAx(d)];
    end
end
hLeg = legend(string(leg));
hLeg.Title.String = 'Disparity';

xlabel('Response error')
