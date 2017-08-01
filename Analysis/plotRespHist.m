function plotRespHist(data, fold, tit)

if ~exist('tit', 'var')
    tit = '';
end

if ~exist('fold', 'var')
    fold = false;
end

% Count number of occurances of each location, for normalisation?
[counts, labels] = hist(data.Position, unique(data.Position));
% Not implemented - balanced.

% Get angles
av = cell2mat(data.Angle);

% Split 
a = av(1:2:end);
v = av(2:2:end);

if fold
    a = abs(a);
    v = abs(v);
end

% Plot
figure
ksdensity(a, 'bandwidth', 3)
hold on
ksdensity(v, 'bandwidth', 3)
legend({'A', 'V'})
title(tit)