x = allData (:,26)
x1 = allData.Position (:, 1)
y = table2cell(x)
y1 = cell2mat (y)
plot (x1, y1)
xlabel ('Position of Auditory Stimulus')
ylabel ('Response')
ylim ([-1 2])
xlim ([-67.5 67.5])
xticks ([-67.5 -52.5 -37.5 -22.5 -7.5 7.5 22.5 37.5 52.5 67.5])
xticklabels ({ '-67.5', '-52.5', '-37.5', '-22.5', '-7.5', '7.5', '22.5', '37.5', '52.5', '67.5'})
legend ('Auditory')


%% Code using loops

close all

% "Correct" for auditory is in allData.ACorrct. This is 1 if subject's
% A response location matches A stimulus location and 0 if it doesn't.
% Move this to y for convenience.
y = allData.ACorrect;

% To caluculate accuracy at each possible A stimulus location we can  
% loop over each location and collect the corresponding correct/incorrect
% responses from y.
% Note that, for now, we're ignoring everything else about the trial (rate,
% congruency with the visual, individual subjects, etc.) and just 
% considering A stimulus location.
% A locations are in the left column of allData.Position, ie.
x = allData.Position(:,1);

% Plotting these as they are is pretty, but isn't much use.
figure
plot(x,y)

% Looping over each location to calculate statistics:
% First we'll create a matrix to store our statistics in. For now, it'll be
% two columns, one for location and one for the proportion of correct
% responses
% Find unique locations
xU = unique(x);
% Count how many there are
xN = numel(xU);
% Create ("preallocate") the output matrix with NaNs
stats = NaN(xN, 2);

for l = 1:numel(xU)
    % l increments from 1 to the number of unique locations on each
    % iteration through loop
    
    % Extract the actual location for this iteration from xU
    thisLocation = xU(l);
    % Save this in the output maxtrix in column 1
    stats(l,1) = thisLocation;
    
    % Use this to create an index to get the corresponding data
    locIdx = x == thisLocation;
    
    % Get the data for this location from ACorrect
    data = y(locIdx);
    
    % Calcaute the proportion of correct responses
    propCorrect = mean(data);
    
    % And store in stats column 2
    stats(l,2) = propCorrect;
end

% Plot the proportion correct at each location
figure
plot(stats(:,1), stats(:,2))
hold on
scatter(stats(:,1), stats(:,2))
ylim([0,1])
xlabel('Location, deg.')
ylabel('Prop. Correct')
title('Proportion correct at each location')

% Challenge:
% Modify the loop collect another stats column for standard error, then
% plot the errorbars on the final figure (use the std and errorbar
% functions).


%% Code not using loops

% It's conceptaully simple to use for loops to begin with, but just for
% fun, here's a way to do the above without using loops.

close all

% Get data again incase x and y have changed
x = allData.Position(:,1);
xU = unique(x);
xN = numel(xU);
y = allData.ACorrect;

% Output here will have 4 columns:
% [position, number of correct responses, number of trials, proportion of
% correct responses]
stats = NaN(xN, 4);

% Use unique to find unique positions (first output) and also to get a
% integer representation of these in the original data (instead of the 
% actual values, third output)
[stats(:,1), ~, xInt] = unique(x);

% Use accumarry to count the numnber of correct responses, using the
% interger representation (xInt) of the positions as the key
stats(:,2) = accumarray(xInt, y);

% Use histc to count the number of trials at each position
stats(:,3) = histc(xInt, xN);

% Finally divide the number of correct responses at each location by the
% number of trials to calcualte the proportion of correct responses
stats(:,4) = stats(:,2)./stats(:,3);

% And plot (column 4 this time)
figure
plot(stats(:,1), stats(:,4))
hold on
scatter(stats(:,1), stats(:,4))
ylim([0,1])
xlabel('Location, deg.')
ylabel('Prop. Correct')
title('Proportion correct at each location')
