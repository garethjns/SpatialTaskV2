function replayComparison(gaze1, onSurf1, params1, gaze2, onSurf2, params2)

% Gaze1 and gaze should be same length - assumed.
% lag and speed used from params1 only

n = height(gaze1);

lag = params1.lag;
speed = params1.speed;

h1 = figure;
h2 = figure;
for r =lag+1:n
    
    figure(h1)
    replayGaze(gaze1(r-lag:r,:), onSurf1(r-lag:r), params1.target, ...
        params1.size, lag, speed)
    title(['Frame: ', num2str(r), '/', num2str(n)])
    
    figure(h2)
    replayGaze(gaze2(r-lag:r,:), onSurf2(r-lag:r), params2.target,...
        params2.size, lag, speed)
    title(['Frame: ', num2str(r), '/', num2str(n)])
    
    
    
end