function [startTime, endTime, startClock, endClock] = ...
    presentStim(params, AO)
% Present stim, at startTime, block until endTime

waitTime = (params.cutOff/1000)*0.999;
disp('Presenting...');

startClock = clock;
startTime = GetSecs;
PsychPortAudio('Start', AO.ao);
WaitSecs(waitTime);
endTime = GetSecs;
endClock = clock;
