function [isRunning, stimLog, params, stimOrder, PTLogs] = spatialCapture(params)
% Main function
% Prepares hardware, generates stim, loops through stim, saves
% Retruns isRunning as 0 on successful completion
% Saves throughout and at end, but also return stimLog, params, stimOrder
% to workspace if requested
% Small, speific functions included in here, larger functions moved to own
% files

% Prepare save directory for subject
% Copy over all functions

% Preload GetSecs
GetSecs;

% Get subject directory ready
params = initSubject(params);

% Initialise HW and PsychtoolBox
AO = initHW(params);

% Initialise 'GUI'
[figs, params] = initGUI(params);

% % Ready to start
% figure(figs.resp)
% figs = updateRespMessage(figs, params, 'Place head, then press to start');
% disp('Waiting to start')
% % Wait for tap to start
% ginput(1);
% figs = updateRespMessage(figs, params, '  ');
% WaitSecs(1);

% Run PT
ginput(1);
if params.PTSkip == 1
    perf = 1;
else
    perf = 0;
end
PTLogs = cell(3,1);
c = 0;
while (perf < params.PTThresh) && ~params.PTSkip
    c = c+1;
    disp(['Running PT, attempt: ', num2str(c)]);
    [perf, PTStimOrder, PTLog] = runPT(params, AO, figs);
    PTLogs{1, c} = PTLog;
    PTLogs{2, c} = PTStimOrder;
    PTLogs{3, c} = perf;
    
    if perf >= params.PTThresh
        disp(['PT Successful, perf: ', num2str(perf)])
    else
        disp(['PT Failed, perf: ', num2str(perf)])
    end
    
    % Save here
    OK = writeMat(params, [], [], PTLogs);
end
clear c perf

% Prepare for main loop
% Prepare stim order
[stimOrder, params.n] = stimOrderGenSCP(params);

% Prepare stimLog
stimLog = prepStimLog(params, stimOrder);

% Ready to start
figure(figs.resp)
figs = updateRespMessage(figs, params, ...
    'Place head, then press to start main task');
disp('Waiting to start')
% Wait for tap to start
ginput(1);
figs = updateRespMessage(figs, params, '  ');
WaitSecs(1);

% Preallocate trial times for est. time remaining
tts = NaN(params.n, 1);

% Main loop
try
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
        
        % Save start time
        if n==1
           params.startTime = now; 
        end
        
        % Prepare next stim
        [AO, aStim, vStim] = prepStim(stimOrder(n,:), params, AO, figs);
        
        % Trigger next stim
        [startTime, endTime, startClock, endClock] = ...
            presentStim(params, AO);
        
        % Wait for response, return loaction and RT
        [Axy, Vxy, ART, VRT, figs] = waitResponse(figs, params, endTime);
        
        % Log response
        stimLog = writeStimLog(...
            stimLog, params, figs, n, Axy, Vxy, ART, VRT, ...
            aStim, vStim, startTime, endTime, startClock, endClock);
        
        % Update off-screen figure
        updatePerf(figs, params, stimLog, n)
        
        % Check break
        if breakTime(params, n)
            figs = exInBreak(params, stimOrder, stimLog, PTLogs, figs);
            % Includes save etc
        end
        
        % Record trial time for estimated time remaining
        tts(n) = toc;
        
    end % End of main loop
    
    % Save
    OK = writeMat(params, stimOrder, stimLog, PTLogs);
    
    if ~OK
        % Something went wrong in final save
        disp('Something went wrong in final save, do manually.')
        keyboard
    end
    
    % Return 0 for isRunning
    isRunning = 0;
    
catch err
    % If there is an error during execution of main loop or saving after
    % loop stop here and allow manual saving of data
    disp(err)
    disp('DATA NOT YET SAVED')
    keyboard
end


function updatePerf(figs, params, stimLog, n)
% Update performance figure and response figure

% Scatter last response on to response figure
figure(figs.respMir)
hold on
xy = stimLog.RawResponse{n,:};
h1 = scatter(xy(1,1), xy(1,2), 100, 'filled', 'Marker', 'o');
h2 = scatter(xy(2,1), xy(2,2), 100, 'filled', 'Marker', 'd');

switch stimLog.Type(n,1)
    case 1
        col = 'k';
    case 2
        col = 'r';
end

set([h1, h2], 'MarkerEdgeColor', col)
set([h1, h2], 'MarkerFaceColor', col)

% Plot performance figure
figure(figs.perf)

flag = 2;
tit = 'Absolute incongruency vs relative response error';
stats = gatherPosPlot1(stimLog, flag);
plotSpatialDataOldMATLAB(stats, tit);


function [Axy, Vxy, ART, VRT, figs] = waitResponse(figs, params, endTime)
% Wait for A response and get RT relative to endTime
% The wait for V response and wait for RT relative to endTime
% Return positions and RTs

disp('Waiting for response...');

% Resp figure should already be selected
% Get A response
figs = updateRespMessage(figs, params, 'Click auditory location');
Axy = ginput(1);
ART = GetSecs - endTime;

% Wait brief moment to prevent double press
WaitSecs(0.075);

% Get V response
figs = updateRespMessage(figs, params, 'Click visual location');
Vxy = ginput(1);
VRT = GetSecs - endTime;

figs = updateRespMessage(figs, params, '  ');


function BT = breakTime(params, n)
% Check if it's time for a break
% If so, just return T or F
% Avoid returning true on last trial

m = round(params.n/(params.nBreaks+1));

if ~mod(n, m) && n ~= params.n
    % Break time
    BT = true;
else
    BT = false;
end


function figs = exInBreak(params, stimOrder, stimLog, PTLogs, figs)
% Code to execute in break
% Called from main loop, not breakTime function

% Get time
t = GetSecs;

% Set break message
figs = updateRespMessage(figs, params, 'Break time');

% Save so far
writeMat(params, stimOrder, stimLog, PTLogs);

% Force minimum wait time
passed = GetSecs - t;
while passed < params.breakTimeForcedWait
    % Update figure text every 0.5 seconds or so
    figs = updateRespMessage(figs, params, ...
        ['Break time, please wait: ', ...
        num2str(round(params.breakTimeForcedWait-passed)), ...
        's']);
    drawnow
    WaitSecs(0.5);
    passed = GetSecs - t;
end

% Send final message
figs = updateRespMessage(figs, params, ...
    'Break time, press to continue:');

% And wait to start again
ginput(1);
% Wait before starting
WaitSecs(1)


function [AO, chanMap] = initHW(params)
% Get the chanMap2 from initMOTU. Retrun in AO.chanMap and chanMap

AO = initMOTU(params);

chanMap = params.chanMap2;
AO.chanMap = chanMap;


function params = initSubject(params)

% Create directory for subject
params.subjectDir = [params.Subject, '\'];
if ~exist(params.subjectDir, 'dir')
    mkdir(params.subjectDir)
end

% Create directory for this run
params.dateStr = strrep(datestr(now), ':', '_');
params.expDir = [params.subjectDir, params.dateStr, '\'];
if ~exist(params.expDir, 'dir')
    mkdir(params.expDir)
end

% Create code directory and copy all functions
params.codeDir = [params.subjectDir, params.dateStr, '\Code\'];
if ~exist(params.codeDir, 'dir')
    mkdir(params.codeDir)
end

f2c = {...
    'run.m'; ...
    'spatialCapture.m'; ...
    'background.png'; ...
    'background_wg.png'; ...
    'Church2Spatial.m'; ...
    'convertSpace.m'; ...
    'gatherPosPlot1.m'; ...
    'initGUI.m'; ...
    'initMOTU.m'; ...
    'loadHandler.m'; ...
    'plotSpatialDataOldMATLAB.m'; ...
    'prepStim.m'; ...
    'prepStimLog.m'; ...
    'presentStim.m'; ...
    'runPT.m'; ...
    'saveHandler.m'; ...
    'setParams.m'; ...
    'stimOrderGenSCP.m'; ...
    'updateRespMessage.m'
    'writeStimLog.m'; ...
    };

for f = 1:numel(f2c)
    copyfile(f2c{f,1}, [params.codeDir, f2c{f,1}])
end

% Set name for save file
params.saveFile = ['SpatialCapture_', params.Subject, '.mat'];
% And with relative path
params.saveFile2 = [params.expDir, params.saveFile];


function OK = writeMat(params, stimOrder, stimLog, PTLogs) %#ok<INUSD> (are used)
% Save data collected so far to disk

OK = saveHandler(params.saveFile2, 1, 0, {'stimOrder', 'stimLog', 'PTLogs'});

% Check, but only warn on failure here
if ~OK
    disp('Warning: Save failed.')
end