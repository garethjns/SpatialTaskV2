function plotDispHists(dataA, dataV, pAx, dAx, normX, normY, tit)
% Plots response distributions for A and V at each locations
% [A locations;  V locations] - line for each disparity.
% pAx and dAx should be position and disparity axes.
% normX and normY scale axes to max of all plots.

% Get ns
nPoss = length(pAx);
nDiff = length(dAx);

% Set preliminary limits for axes
yLim = 0.1;
xLim = 20;

% Create a colourmap to use across plots
colours = colormap(parula(nDiff));

figure
% For each position
for p = 1:nPoss
    
    % Plot auditory response on top row
    subplot(2,nPoss, p)
    % Plot all the lines for one subplot, using colourmap and updating xLim
    % and yLim if they grow
    [xLim, yLim] = ksPlots(dAx, dataA(:,p,:), colours, xLim, yLim);
    % Add plot title
    title(string(pAx(p)));
    % Add ylabel if left most subplot
    if p==1
        ylabel('Proportion')
    end
    
    % Plot visual response on bottom row
    subplot(2,nPoss, nPoss+p)
    [xLim, yLim] =ksPlots(dAx, dataV(:,p,:), colours, xLim, yLim);
    title(string(pAx(p)));
    if p==1
        ylabel('Proportion')
    end

end

% Finish plots
% Run through each plot and apply any finishing touches
for p = 1:2*nPoss
    subplot(2,nPoss,p)
    
    % If normY, set ylim to slightly more than max value on all plots
    if normY
        ylim([0, yLim*1.05]);
    end
    
    % If normX, set a symmetical x limit, but limiting extreme values
    if normX
        xlim([0-xLim*0.5, xLim*0.5]);
    end
    
end

% Add the supertitle
suptitle(tit)

% Add a A and V label for each row


function [xLim, yLim] = ksPlots(dAx, data, colours, xLim, yLim)
% For a 2D matrix, plot ksdensity for each column.
% Add lengend.
% Update axis limits.

nDiff = length(dAx);

hold on
leg = [];
for d = 1:nDiff
    % Run ksdensiy one by one to avoid empty errors
    n = sum(~isnan(data(:,1,d)));
    % If no data, skip
    if n>0
        % Get density and x axis
        [line, x] = ksdensity(data(1:n,1,d));
        % Plot using colourmap
        plot(x, line, 'Color', colours(d,:))
        % Update dimenions 
        if max(line)>yLim
            yLim = max(line);
        end
        if max(abs(x))>xLim
            xLim = max(abs(x));
        end
        % Add to legend
        leg = [leg, dAx(d)]; %#ok<AGROW>
    end
end
% Apply legend and title
hLeg = legend(string(leg));
hLeg.Title.String = 'Disparity';

xlabel('Response error')

