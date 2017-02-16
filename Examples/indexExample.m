
%% Get data from position 10 (auditory)

% Get index
p10Idx = allData.PosBin(:,1)==10;

% Get correct
p10C = allData.ACorrect(p10Idx);

% Calculate % correct
mean(p10C)


%% Get data from p10 (auditory) when congruent

% Get index
p10Idx = (allData.PosBin(:,1)==10) & (allData.Type==1);

% Get correct
p10C = allData.ACorrect(p10Idx);

% Calculate % correct
mean(p10C)


%% Get the x axis

xaxis = unique(allData.PosBin(:,1));
