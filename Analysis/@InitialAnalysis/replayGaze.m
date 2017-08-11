function h = replayGaze(gaze, onSurfIdx, targetFunc, targetIns, lag, speed)
% Plots NP0 vs NP1. Colours scatter points by onSurfIdx. 
% Also plots reference target - does not recaluclate onSurfIdx with this.
% Return function handle

% Set target function
% Note: Passing function handle in input doesn't work, it doesn't find the
% function inside here (it finds others on path first - presumably the
% handle is to them, and isn't replaced by entering here).
% Workaround - input string, switch, set sub-function handle inside this
% function:
switch targetFunc
    case 'rect'
        targetFunc = @rect;
    case 'circle'
        targetFunc = @circle;
    otherwise
        targetFunc = @blank;
        targetIns = [];
end

% Create target
target = targetFunc(targetIns);

% Draw figure
n = height(gaze);
hold on
rs = (1:n)';
% Start from step lag and plot preceding lag points
for r = lag:n
    % Only draw if r divisible by speed value (or on last step)
    if ~mod(r, speed) || r==n
        plIdx = (rs > (r-lag)) & (rs <= r);
        onIdx = onSurfIdx==true;
        
        % Clear figure
        clf
        hold on
        % Redraw
        plot(gaze.NP0(plIdx,1), gaze.NP1(plIdx,1), 'k')
        scatter(gaze.NP0(plIdx & onIdx,1), gaze.NP1(plIdx & onIdx,1), ...
            'MarkerEdgeColor', 'b')
        scatter(gaze.NP0(plIdx & ~onIdx,1), gaze.NP1(plIdx & ~onIdx,1), ...
            'MarkerEdgeColor', 'r')
        plot(target(:,1), target(:,2), 'k')
        axis([-8,8,-8,8])
        title(['Frame: ', num2str(r), '/', num2str(n)])
        drawnow
    end
    
    
end


function target = rect(range)
% range = [xMin, xMax, yMin, yMax]
if isempty(range)
    range = [0, 1, 0, 1];
    % range = [[0;0;1;1;0], [0;1;1;0;0]]
end

target = [[range(1);range(1);range(2);range(2);range(1)], ...
    [range(3);range(4);range(4);range(3);range(3)]];


function target = circle(rad)

if isempty(rad)
    rad = 1;
end

ang=0:0.01:2*pi;
xp=rad*cos(ang);
yp=rad*sin(ang);

target = [xp',yp'];


function target = blank
target = [0,0];
