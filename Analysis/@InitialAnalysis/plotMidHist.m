function plotMidHist(dataA, dataV, tit, absX, normX, normY)

if ~exist('normX', 'var')
    normX = true;
end
if ~exist('normY', 'var')
    normY = true;
end
if ~exist('absX', 'var')
    absX = false;
end

yLim = 0;

figure

% Auditory plot
subplot(2,1,1)
hold on
yLim = plotKS(dataA, absX, yLim);
hLeg = legend({'-30', '-15', '0', '15', '30'});
hLeg.Title.String = 'Visual disparity, deg';
xlabel('Auditory response error magnitude, deg')
ylabel('Proportion')
title('Auditory at 37.5^o')

% If normX (set static axis for this subplot and below)
if normX
    if absX
        xlim([0, 50])
    else
        xlim([-50, 50])
    end
end

% Visual plot
subplot(2,1,2)
hold on
yLim = plotKS(dataV, absX, yLim);
hLeg = legend({'-30', '-15', '0', '15', '30'});
hLeg.Title.String = 'Auditory disparity, deg';
xlabel('Visual response error magnitude, deg')
title('Visual at 37.5^o')
% If normX (set static axis for this subplot as well)
if normX
    if absX
        xlim([0, 50])
    else
        xlim([-50, 50])
    end
end

% If normY (match y axis on both subplots)
if normY
    subplot(2,1,1)
    ylim([0, yLim+yLim*.1])
    subplot(2,1,2)
    ylim([0, yLim+yLim*.1])
end

% Title
if exist('tit', 'var')
    suptitle(tit);
end

end

% Reusing similar function as in plotDispHists, with specific changes.
function yLim = plotKS(data, absX, yLim)

nDiff = size(data,2);
% Use middle of colour map
cScale = 4;
cShift = 2;
colours = colormap(pink(nDiff+cScale));

for d = 1:nDiff
    
    % Line style depedning on disparity direction
    if d < (nDiff/2)
        ls = '--';
        lw = 1;
    elseif d > ceil(nDiff/2)
        ls = ':';
        lw = 2;
    else
        ls = '-';
        lw = 2;
    end
    
    if absX
        % If folding around 37.5 location, just take absolute before
        % ksdensity
        data = abs(data);
    end
    
    % Get density and aixs
    [line, x] = ksdensity(data(:,d), 'bandwidth', 1);
    
    % Plot with selected line style
    plot(x, line, 'Color', colours(d+cShift,:), ...
        'LineStyle', ls, 'LineWidth', lw)
    
    % Update yLim
    if max(line)>yLim
        yLim = max(line);
    end
end

end
