function [h1, h2] = plotAPCvsPL(data1, data2, str)
% Plot accuracy of auditory localisation
% Plot 1: Averaged over A positions
% subplot 1: % Correct
% Subplot 2: Error
% Plot 2: Not averaged over A positions
% subplot row 1: % Correct for each position
% subplot row 2: error for each position
% 
% Stats input has 2 fields
% .PosAv (st x diff)
% .PerPos (st x diff x A pos)
% Each contains stats matrix:
% Position
% Diff
% PC
% PC std
% Error
% Error std
% n


%% Figure 1

data = data1;

h1 = figure;
subplot(2,1,1)
plotCorrect(data);
subplot(2,1,2)
plotError(data);

suptitle(str)

ng;
hgx(['Graphs\', strrep(str, ':', ''), ' _PosAvg']);


%% Figure 2

data = data2; 
nPoss = size(data,3);

h2 = figure;
ng('Wide');
plt = 0;
for p = 1:nPoss
    
    subData = data(:,:,p);
    
    subplot(2, nPoss, p)
    plotCorrect(subData);

    subplot(2, nPoss, p+nPoss)
    plotError(subData);
end

suptitle(str)

hgx(['Graphs\', strrep(str, ':', ''), ' _PerPos']);


function plotCorrect(data)

if ~isempty(data)
    if data(1,1) == 111
        % This is data averaged over A Pos
        tit = 'Accuracy avg. over all A positions';
    else
        tit = ['Accuracy @ A Pos: ', num2str(data(1,1))];
    end
    
    bar(data(2,:), data(3,:))
    hold on
    errorbar(data(2,:), data(3,:), data(4,:)./sqrt(data(7,:)), ...
        'LineStyle', 'none')
    title(tit)
    ylabel('Prop. correct')
    
    ylim([0, 1.2])
    
    a = gca;
    a.XTickLabelRotation = 45;
    
end

function plotError(data)

if ~isempty(data)
    % Is this abs or rel? - For graph title/labels
    if min(data(2,:))<0
        % It's rel
        str2 = 'Rel';
        str3 = 'Signed';
        xlab = 'A Pos - V Pos';
        lim = [-25, 25];
    else
        str2 = 'Abs';
        str3 = 'Unsigned';
        xlab = 'abs(A Pos - V Pos)';
        lim = [-5, 30];
    end
    
    bar(data(2,:), data(5,:))
    hold on
    errorbar(data(2,:), data(5,:), data(6,:)./sqrt(data(7,:)), ...
        'LineStyle', 'none')
    title([str3, ' error'])
    ylabel('Mag., deg.')
    xlabel(xlab)
    
    ylim(lim)
    
    a = gca;
    a.XTickLabelRotation = 45;
end