function [perf, stimOrder, stimLog] = runPT(params, AO, figs)

% Copy parameters
PTParams.Positions = params.Positions;
PTParams.PositionMax = params.PositionMax;
PTParams.Rates = params.Rates;
PTParams.Sides = params.Sides;
PTParams.duration = params.duration;

% Set others
PTParams.Types = 1; % Congruent only
PTParams.nBlocks = params.PTnBlocks;
PTParams.InconLimitMax = 1; % Don't need to set these
PTParams.InconLimitMin = 15;

% Generate stim order
[stimOrder, params.n] = stimOrderGenSCP(PTParams);

% Prepare stimLog
stimLog = prepStimLog(params, stimOrder);

% Preallocate trial times for est. time remaining
tts = NaN(params.n, 1);

for n = 1:params.n
    clear x y RT aStim vStim
    
    % Display trial number and estimated time remaining
    disp(['Trial ', num2str(n), '/' num2str(params.n)]),
    tic
    estTR = nanmedian(tts)*(params.n-n);
    if n>10
        disp(['Est. time remaining: ', ...
            num2str(round(estTR/60)), ...
            ' mins'])
    end
    
    % Prepare next stim
    [AO, aStim, vStim] = prepStim(stimOrder(n,:), params, AO, figs);
    
    % Trigger next stim
   [startTime, endTime, startClock, endClock] = ...
            presentStim(params, AO);
    
    % Wait for response, return location and RT
    % NB: Uses specific function in this file
    [Axy, Vxy, ART, VRT, figs] = waitResponsePT(figs, params, endTime);
    
    % Log response
     stimLog = writeStimLog(...
            stimLog, params, figs, n, Axy, Vxy, ART, VRT, ...
            aStim, vStim, startTime, endTime, startClock, endClock);
    
    % Record trial time for estimated time remaining
    tts(n) = toc;
    
end % End of PT loop

% Calculate performance (localisation accuracy)
score = 0;
for n = 1:params.n
   % Get response bin and compare to position bin
   % Just for A
  score = score + ...
      sum(all([stimLog.PosBinLog{n}(1,:);stimLog.respBinAN{n}(1,:)]));
end

% Return performance on this block
perf = score/params.n;


function [Axy, Vxy, ART, VRT, figs] = waitResponsePT(figs, params, endTime)
% Wait for A response and get RT relative to endTime
% The wait for V response and wait for RT relative to endTime
% Return positions and RTs

disp('Waiting for response...');

% Resp figure should already be selected
% Get A response
figs = updateRespMessage(figs, params, 'Click stimulus location');
Axy = ginput(1);
ART = GetSecs - endTime;

% Only need one response here
Vxy = Axy;
VRT = ART ;

figs = updateRespMessage(figs, params, '  ');