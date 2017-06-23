function gazeTrajectories(data, gazeData, tit, thresh, all, x)

% Check there's data
if isempty(gazeData)
    return
end
nTrials = height(data);

% Check params
if ~exist('thresh', 'var')
    thresh = 0.75;
end
if ~exist('x', 'var')
    x = -1000:100:2500;
end
if ~exist('tit', 'var')
    tit = 'Eye trajectory';
else
    tit = ['Eye trajectory ', tit];
end
if ~exist('all', 'var')
    all = true;
end


%% Arrange data

% Use this xaxis
nX = length(x);

% Preallocate outputs:
% Binned trajectories
traj = NaN(nX, nTrials);
osProp = NaN(1, nTrials);

% For each trial
for r = 1:nTrials
    
    % Get start time of this trial
    sTime = data.sTime(r);
    
    % Calculate difference in seconds between start time and eye points
    tDiff = seconds(gazeData.TS4 - sTime);
    
    % Get index of times to include:
    % For the table (may overlap stim if long x)
    tIdx = tDiff>(min(x)/1000) & tDiff<(max(x)/1000);
    % For just this stim
    stimIdx = tDiff>0 & tDiff<1.2;
    
    % Calc prop to colour
    osProp(1,r) = mean(gazeData.onSurf(stimIdx));
    
    % Bin time data in to 100 ms bins
    xAx = round(tDiff(tIdx)*1000, -2);
    % Get group numbers (ints) to use with accumary
    [xUnq, ~, ints] = unique(xAx);
    
    % Get index of available x data for correct placement in to traj matrix
    % Eg. if no data in 1000, bin, ismember will return zero and NaN
    % will be left in matrix at this location.
    xIdx = ismember(x, xUnq);
    
    % Accumulate using mean
    traj(xIdx,r, 1) = accumarray(ints, gazeData.onSurf(tIdx), [], @mean);
    
end


%% Plot

osIdx = osProp>=thresh;

figure
hold on

if all
    if any(osIdx)
    plot(x, traj(:, osIdx), ...
        'Color', [0.85, 0.85, 0.85], ...
        'LineStyle', '--')
    end
    if ~any(osIdx)
    plot(x, traj(:, ~osIdx), ...
        'Color', [1, 0.75, 0.75], ...
        'LineStyle', '--')
    end
end

h(1) = errorbar(x, ...
    nanmean(traj(:, osIdx), 2), ...
    nanstd(traj(:, osIdx), [], 2)./sqrt(nTrials), ...
    'Color', 'k', ...
    'LineWidth', 3);

h(2) = errorbar(x, ...
    nanmean(traj(:, ~osIdx), 2), ...
    nanstd(traj(:, ~osIdx), [], 2)./sqrt(nTrials), ...
    'Color', 'r', ...
    'LineWidth', 3);

line([0,0], [-0.2,1.2], 'Color', 'g', 'LineStyle', '--', 'LineWidth', 2)

ylabel('Prop on Surf')
xlabel('Time relative to stim start')
title(tit)
hLeg = legend(h, ...
    {['Passed thresh n=', num2str(sum(osIdx))], ...
    ['Rejected n=', num2str(sum(~osIdx))]});
hLeg.Title.String = 'Average trajectory';
ng;
