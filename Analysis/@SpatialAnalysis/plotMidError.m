function h = plotMidError(obj, dataA, dataV, tit, absX, normX, normY)
% Replaces InitialAnalysis.plotMidHist()

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

h = figure;

% Auditory plot
subplot(2,1,1)
hold on
yLim = plotKS(dataA, absX, yLim);
hLeg = legend({'-30', '-15', '0', '15', '30'});
hLeg.Title.String = 'V-A disparity, ^o';
xlabel('A localisation error, ^o')
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
hLeg.Title.String = 'A-V disparity, ^o';
xlabel('V localisation error, ^o')
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

nDiff = size(data, 2);
% Set diff labels for colours
if nDiff>3
    % Assume rel
    diffs = [-30, -15, ...
        0, 15, 30];
else
    % Assume abs
    diffs = [0, 15, 30];
end

% Use middle of colour map
cScale = 2;
cShift = 1;
colours = colormap(lines(numel(unique(abs(diffs)))+cScale));

for d = 1:nDiff
    
    % Line style depending on disparity direction
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
    
    % Line colour based on magnitude
    switch abs(diffs(d))
        case 0
            col = colours(cShift+1,:);
        case 15
            col = colours(cShift+2,:);
        case 30
            col = colours(cShift+3,:);
    end
    
    if absX
        % If folding around 37.5 location, just take absolute before
        % ksdensity
        data = abs(data);
    end
    
    % Get density and aixs
    [line, x] = ksdensity(data(:,d), 'bandwidth', 1);
    
    % Plot with selected line style
    plot(x, line, 'Color', col, ...
        'LineStyle', ls, 'LineWidth', lw)
    
    % Update yLim
    if max(line)>yLim
        yLim = max(line);
    end
end

end
