function [startTime, endTime, startClock, endClock] = ...
    presentStim(params, AO)
% Present stim, at startTime, block until endTime
% startTime and endTime are GetSecs

waitTime = (params.cutOff/1000)*0.999;
disp('Presenting...');

startClock = clock;
startTime = GetSecs;
PsychPortAudio('Start', AO.ao);

% Manually block till end
endTime = WaitSecs(waitTime);
endClock = clock;
